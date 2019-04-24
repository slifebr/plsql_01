CREATE OR REPLACE Package fn_adt_utl Is

   --||
   --||FN_ADT_UTL : Administracao de titulos
   --||

   Procedure fecha(p_emp  In fn_adt_lotes.empresa%Type
                  ,p_lote In fn_adt_lotes.lote%Type
                  ,p_jur  In Char);

   Function tipo_doc(p_debito In Number
                    ,p_conta  fn_adt.conta%Type
                    ,p_titulo fn_adt.num_titulo%Type) Return Char;

End fn_adt_utl;
/
CREATE OR REPLACE Package Body fn_adt_utl Is

   --||
   --||FN_ADT_UTL : Administracao de titulos
   --||

   --------------------------------------------------------------------------------
   /*
   || Rotinas internas
   */
   --------------------------------------------------------------------------------
   Procedure contab(p_emp  In fn_adt_lotes.empresa%Type
                   ,p_lote In fn_adt_lotes.lote%Type
                   ,p_tot  In Number
                   ,p_jur  In Number
                   ,p_des  In Number
                   ,p_l1   In Out cg_lancto.lote%Type
                   ,p_l2   In Out cg_lancto.lote%Type)
   --||
      --|| Contabiliza operacao
      --||
    Is
   
      Cursor cr_partes Is
         Select Distinct parte
           From tfn_adt;
   
      Cursor cr_adt(p tfn_adt.parte%Type) Is
         Select *
           From tfn_adt
          Where parte = p;
   
      v_lote cg_lancto.lote%Type;
   
      v_ano Number(4);
      v_mes Number(2);
   
      Cursor cr(a cg_exerc.ano%Type) Is
         Select mes
           From cg_exerc
          Where empresa = p_emp
            And ano = a;
   
      dummy       Number;
      v_val       Number;
      v_trans     ft_oper_trans.cod_trans%Type;
      v_lote_cont cg_lancto.lote%Type;
      v_difer     Number;
      v_afonte    cg_trans.cod_afonte%Type;
      v_con       Char(1);
      reg_cli     cd_firmas%Rowtype;
      v_ret_lote  cg_lancto.lote%Type;
      v1          Number;
      v2          Number;
      v_data      Date;
      reg_lote    fn_adt_lotes%Rowtype;
      v_valor1    Number;
      v_valor2    Number;
      v_ctb       fn_contas.cod_contabil%Type;
      v_nome      cd_firmas.nome%Type;
      v_jur       Number;
      v_des       Number;
      b_pri       Boolean := True;
      v_aux       Number;
      v_j         Number;
      v_d         Number;
      v_ja        Number;
      v_da        Number;
   
   Begin
   
      --| Le o lote
      Select *
        Into reg_lote
        From fn_adt_lotes
       Where empresa = p_emp
         And lote = p_lote;
   
      Select nvl(reg_lote.dt_ref,
                 Sysdate)
        Into v_data
        From dual;
   
      v_data := trunc(v_data);
   
      Select nome
        Into v_nome
        From cd_firmas
       Where firma = reg_lote.firma;
   
      --| Verifica a transacao
      Select cod_trans_vin
        Into v_trans
        From fn_param
       Where empresa = p_emp;
   
      v_jur := p_jur;
      v_des := p_des;
      v_ja  := 0;
      v_da  := 0;
   
      --| Para cada parte distinta na operacao
      For reg_parte In cr_partes Loop
      
         -- Prepara para integracao contabil
         cg_int.novo_lote;
         cg_int.inicia('',
                       '');
      
         v_valor1 := 0;
         v_valor2 := 0;
      
         --| Para cada registro temporario de contabilizacao
         For reg_adt In cr_adt(reg_parte.parte) Loop
         
            -- Tipo 1 : duplicata sendo vinculada
            If reg_adt.tipo = 1 Then
               v_valor1 := v_valor1 + reg_adt.valor;
               -- Tipo 2 : Cheque pre datado
            Elsif reg_adt.tipo = 2 Then
               Select cod_contabil
                 Into v_ctb
                 From fn_contas
                Where empresa = p_emp
                  And conta = reg_adt.conta;
               cg_int.seta_valor_ter(10,
                                     v_ctb,
                                     reg_adt.valor);
               -- Tipo 3 : Titulo de terceiros
            Elsif reg_adt.tipo = 3 Then
               v_valor2 := v_valor2 + reg_adt.valor;
            End If;
         
         End Loop;
      
         cg_int.seta_valor(1,
                           v_valor1);
         cg_int.seta_valor(11,
                           v_valor2);
      
         -- Se tem juros ou descontos : ratear entre as partes
         If b_pri Then
            If p_jur > 0 Then
               v_j := round(p_jur * (v_valor1 / p_tot),
                            2);
               v_d := 0;
               cg_int.seta_valor(12,
                                 v_j);
               v_jur := v_jur - v_j;
            Elsif p_des > 0 Then
               v_d := round(p_des * (v_valor1 / p_tot),
                            2);
               v_j := 0;
               cg_int.seta_valor(2,
                                 v_d);
               v_des := v_des - v_d;
            End If;
            b_pri := False;
         Else
            If v_jur > 0 Then
               cg_int.seta_valor(12,
                                 v_jur);
               v_j   := v_jur;
               v_d   := 0;
               v_jur := 0;
            Elsif v_des > 0 Then
               cg_int.seta_valor(2,
                                 v_des);
               v_d   := v_des;
               v_j   := 0;
               v_des := 0;
            End If;
         End If;
      
         If v_j > 0 Then
            v_ja := 0;
         End If;
         If v_d > 0 Then
            v_da := 0;
         End If;
         Select Sum(valor)
           Into v1
           From tfn_adt
          Where tipo = 1
            And parte = reg_parte.parte;
         Select Sum(valor)
           Into v2
           From tfn_adt
          Where tipo > 1
            And parte = reg_parte.parte;
         v_difer := abs(nvl(v1,
                            0) + v_j - v_ja - nvl(v2,
                                                  0) - v_d + v_da);
         If nvl(v1,
                0) + v_j > nvl(v2,
                               0) + v_d Then
            cg_int.seta_valor(28,
                              v_difer);
         Else
            cg_int.seta_valor(29,
                              v_difer);
         End If;
         v_ja := v_j;
         v_da := v_d;
      
         cg_int.seta_historico(2,
                               to_char(reg_lote.lote));
         cg_int.seta_historico(4,
                               v_nome);
      
         Select cg_lotes_seq.nextval
           Into v_lote_cont
           From dual;
         cg_int.prepara(p_emp,
                        v_lote_cont,
                        v_trans,
                        v_data,
                        v_afonte,
                        reg_lote.firma,
                        Null,
                        Null);
         cg_int.cenario(reg_parte.parte);
         cg_int.estorno(False);
         cg_int.set_commit(False);
         cg_int.monta_transacao;
         cg_int.grava_lote;
      
         If reg_parte.parte = 0 Then
            p_l1 := cg_int.ler_ultlote;
         Else
            p_l2 := cg_int.ler_ultlote;
         End If;
      
      End Loop; -- for reg_parte...
   
   End;

   --------------------------------------------------------------------------------
   /*
   || Rotinas exportadas
   */
   --------------------------------------------------------------------------------
   Procedure fecha(p_emp  In fn_adt_lotes.empresa%Type
                  ,p_lote In fn_adt_lotes.lote%Type
                  ,p_jur  In Char)
   /*
      || Fechamento do lote
      */
    Is
   
      Cursor cr_tit Is
         Select a.*
               ,t.tipo_tit
               ,t.banco
               ,t.dt_vence
               ,t.documento
               ,t.firma
               ,t.tipo_cob
               ,t.historico
               ,t.producao
               ,t.periodo
               ,t.dt_movim
           From fn_adt_dup a
               ,fn_ctrec   t
          Where a.empresa = p_emp
            And a.lote = p_lote
            And t.empresa = a.empresa
            And t.filial = a.filial
            And t.num_titulo = a.num_titulo
            And t.seq_titulo = a.seq_titulo
            And t.parte = a.parte
            And t.status = 'A'
          Order By a.num_titulo
                  ,a.seq_titulo
                  ,a.parte Desc;
   
      Cursor cr_adt Is
         Select *
           From fn_adt
          Where empresa = p_emp
            And lote = p_lote
            And dt_envio Is Null
            For Update;
   
      Cursor cr_ultdup(emp fn_param.empresa%Type) Is
         Select ult_duplic
           From fn_param
          Where empresa = emp
            For Update Of ult_duplic;
   
      Cursor cr_ctb1(t tfn_adt.tipo%Type
                    ,p tfn_adt.parte%Type
                    ,f tfn_adt.firma%Type) Is
         Select 1
           From tfn_adt
          Where tipo = t
            And parte = p
            And firma = f;
      Cursor cr_ctb2(t tfn_adt.tipo%Type
                    ,p tfn_adt.parte%Type
                    ,f tfn_adt.conta%Type) Is
         Select 1
           From tfn_adt
          Where tipo = t
            And parte = p
            And conta = f;
   
      Cursor curtit(pc_tipo_origem fn_tipos_tit.tipo_tit%Type) Is
         Select tipo_destino
               ,banco
           From fn_tit_bxvin
          Where tipo_origem = pc_tipo_origem;
   
      v_ctb            Number;
      v_ne             Number;
      v_seq            Number;
      v_pos_bx         fn_prgen.pos_bxvin%Type;
      v_trans          fn_param.cod_trans_vin%Type;
      v_val_bx         Number;
      v_val_pg         Number;
      v_val            Number;
      reg_lote         fn_adt_lotes%Rowtype;
      reg_par          cd_prgen%Rowtype;
      v_pos_aberto     fn_prgen.pos_aberto%Type;
      v_pos_ren        fn_prgen.pos_aberto%Type;
      v_ult_duplic     fn_param.ult_duplic%Type;
      v_l1             cg_lancto.lote%Type;
      v_l2             cg_lancto.lote%Type;
      v_val_jur        Number;
      v_val_des        Number;
      v_tipo_destino   fn_tit_bxvin.tipo_destino%Type;
      v_banco_destino  fn_tit_bxvin.banco%Type;
      v_data           Date;
      v_sqt            fn_ctrec.seq_titulo%Type;
      v_dt_envio       Date;
      v_uvenc          Date;
      v_val_sl         Number;
      v_ult_empresa    fn_ctrec.empresa%Type;
      v_ult_filial     fn_ctrec.filial%Type;
      v_ult_num_titulo fn_ctrec.num_titulo%Type;
      v_ult_seq_titulo fn_ctrec.seq_titulo%Type;
      v_ult_parte      fn_ctrec.parte%Type;
   
   Begin
   
      --| Verifica se tem itens nao enviados
      Select Count(*)
        Into v_ne
        From fn_adt
       Where empresa = p_emp
         And lote = p_lote
         And dt_envio Is Null;
      If nvl(v_ne,
             0) = 0 Then
         raise_application_error(-20101,
                                 'Nenhum item a efetivar.');
         Return;
      End If;
   
      v_dt_envio := trunc(Sysdate);
   
      --| Le os parametros necessarios
      Select pos_bxvin
            ,pos_abvin
            ,pos_aberto
        Into v_pos_bx
            ,v_pos_ren
            ,v_pos_aberto
        From fn_prgen;
      Select *
        Into reg_par
        From cd_prgen;
   
      --| Le o lote
      Select *
        Into reg_lote
        From fn_adt_lotes
       Where empresa = p_emp
         And lote = p_lote;
   
      Select nvl(reg_lote.dt_ref,
                 Sysdate)
        Into v_data
        From dual;
   
      v_data := trunc(v_data);
   
      --| Ultimo nr de duplicata
      Open cr_ultdup(p_emp);
      Fetch cr_ultdup
         Into v_ult_duplic;
   
      v_val_pg := 0;
   
      --| Para cada registro em fn_adt
      For reg_adt In cr_adt Loop
      
         v_val_pg := v_val_pg + reg_adt.valor;
      
         --| Se for um cheque
         If reg_adt.conta Is Not Null Then
         
            Select fn_movimen_seq.nextval
              Into v_seq
              From dual;
            --/
            Insert Into fn_movimen
            Values
               (reg_adt.empresa
               ,reg_adt.conta
               ,(v_data)
               ,v_seq
               ,reg_adt.parte
               ,reg_adt.valor
               ,'E'
               ,rtrim(reg_adt.historico) ||
                ' - Receb.ref.Duplicatas vinculadas lote ' || reg_adt.lote
               ,reg_adt.documento
               ,''
               ,''
               ,reg_par.producao
               ,reg_lote.firma
               ,'N'
               ,0
               ,reg_adt.dt_vence
               ,Null
               ,Null
               ,Null
               ,Null
               ,Null
               ,Null
               ,0
               ,Null
               ,Null
               ,null
               ,null
               );
            --/
            Update fn_adt
               Set seq_mov  = v_seq
                  ,dt_envio = v_dt_envio
             Where Current Of cr_adt;
         
            --| Grava registro para contabilizacao cheques recebidos
            --open cr_ctb2(2, reg_adt.parte, reg_adt.conta);
            --fetch cr_ctb2 into v_ctb;
            --if cr_ctb2%notfound then
            --  v_ctb := 0;
            --  end if;
            --close cr_ctb2;
            --if v_ctb = 0 then
            --  insert into tfn_adt values(2, reg_adt.parte, reg_lote.firma, reg_adt.conta, reg_adt.valor);
            --else
            --  update tfn_adt set valor = valor + reg_adt.valor
            --   where tipo = 2 and
            --         parte = reg_adt.parte and
            --         conta = reg_adt.conta;
            --  end if;
         
            --| Se for adiantamento
         Elsif reg_adt.docto_tit Is Null Then
            Select fn_adiant_seq.nextval
              Into v_seq
              From dual;
            Insert Into fn_adiant
            Values
               (reg_adt.empresa
               ,reg_lote.firma
               ,reg_adt.data
               ,v_seq
               ,'A'
               ,'U'
               ,reg_adt.valor
               ,reg_adt.documento
               ,Null
               ,reg_adt.historico
               ,User
               ,Null
               ,trunc(Sysdate)
               ,reg_adt.parte
               ,Null
               ,null  -- titulo_vinc
               ,null  --firma_vinc
               ,null
               );
         
            Update fn_adt
               Set seq_mov  = v_seq
                  ,dt_envio = v_dt_envio
             Where Current Of cr_adt;
            --| Grava registro para contabilizacao adiantamentos
            --open cr_ctb1(4, reg_adt.parte, reg_lote.firma);
            --fetch cr_ctb1 into v_ctb;
            --if cr_ctb1%notfound then
            --  v_ctb := 0;
            --  end if;
            --close cr_ctb1;
            --if v_ctb = 0 then
            --  insert into tfn_adt values(4, reg_adt.parte, reg_lote.firma, null, reg_adt.valor);
            --else
            --  update tfn_adt set valor = valor + reg_adt.valor
            --   where tipo = 4 and
            --         parte = reg_adt.parte and
            --         firma = reg_lote.firma;
            --  end if;
         
            --| Se for um titulo de terceiros
         Else
         
            v_ult_duplic := nvl(v_ult_duplic,
                                0) + 1;
         
            Insert Into fn_ctrec
               (empresa
               ,filial
               ,num_titulo
               ,seq_titulo
               ,parte
               ,firma
               ,dt_movim
               ,dt_vence
               ,valor
               ,tipo_tit
               ,tipo_cob
               ,tp_juros
               ,situacao
               ,status
               ,historico
               ,producao
               ,periodo
               ,sac_aval
               ,banco
               ,documento)
            Values
               (reg_adt.empresa
               ,reg_adt.filial
               ,v_ult_duplic
               ,1
               ,reg_adt.parte
               ,reg_adt.firma
               ,reg_adt.data
               ,reg_adt.dt_vence
               ,reg_adt.valor
               ,reg_adt.tipo_tit
               ,reg_adt.tipo_cob
               ,'M'
               ,v_pos_aberto
               ,'A'
               ,reg_adt.historico
               ,reg_par.producao
               ,reg_par.periodo
               ,reg_lote.firma
               ,reg_adt.banco
               ,reg_adt.docto_tit);
         
            Update fn_adt
               Set num_titulo = v_ult_duplic
                  ,seq_titulo = 1
                  ,dt_envio   = v_dt_envio
             Where Current Of cr_adt;
            --| Grava registro para contabilizacao tit recebidos
            --open cr_ctb1(3, reg_adt.parte, reg_lote.firma);
            --fetch cr_ctb1 into v_ctb;
            --if cr_ctb1%notfound then
            --  v_ctb := 0;
            --  end if;
            --close cr_ctb1;
            --if v_ctb = 0 then
            --  insert into tfn_adt values(3, reg_adt.parte, reg_lote.firma, null, reg_adt.valor);
            --else
            --  update tfn_adt set valor = valor + reg_adt.valor
            --   where tipo = 3 and
            --         parte = reg_adt.parte and
            --         firma = reg_lote.firma;
            --  end if;
         
         End If;
      
      End Loop;
   
      --| Atualiza ultimo nr de duplicata
      Update fn_param
         Set ult_duplic = v_ult_duplic
       Where Current Of cr_ultdup;
   
      v_val_sl := v_val_pg;
      v_uvenc  := Null;
   
      --| Para cada registro em fn_adt_dup : baixa o titulo correspondente
      For reg_tit In cr_tit Loop
      
         -- Novo Tipo de Titulo
         Open curtit(reg_tit.tipo_tit);
         Fetch curtit
            Into v_tipo_destino
                ,v_banco_destino;
         If curtit%Notfound Then
            v_tipo_destino  := reg_tit.tipo_tit;
            v_banco_destino := reg_tit.banco;
         End If;
         Close curtit;
      
         If v_uvenc Is Null
            Or trunc(reg_tit.dt_vence) > v_uvenc Then
            v_uvenc := trunc(reg_tit.dt_vence);
         End If;
      
         --| Valor total do titulo
         Select (nvl(valor,
                     0) + nvl(vl_operacao,
                               0))
           Into v_val
           From fn_ctrec
          Where empresa = reg_tit.empresa
            And filial = reg_tit.filial
            And num_titulo = reg_tit.num_titulo
            And seq_titulo = reg_tit.seq_titulo
            And parte = reg_tit.parte;
      
         --| Se valor do titulo menor que saldo efetivando : baixa total
         If v_val <= v_val_sl Then
            v_val_bx := v_val;
            v_val_sl := v_val_sl - v_val;
            -- Atualiza titulo original
            Update fn_ctrec
               Set tipo_tit     = v_tipo_destino
                  ,banco        = v_banco_destino
                  ,situacao     = v_pos_bx
                  ,status       = 'B'
                  ,dt_baixa    =
                   (v_data)
                  ,vl_total_rec = v_val_bx
             Where empresa = reg_tit.empresa
               And filial = reg_tit.filial
               And num_titulo = reg_tit.num_titulo
               And seq_titulo = reg_tit.seq_titulo
               And parte = reg_tit.parte;
            v_ult_empresa    := reg_tit.empresa;
            v_ult_filial     := reg_tit.filial;
            v_ult_num_titulo := reg_tit.num_titulo;
            v_ult_seq_titulo := reg_tit.seq_titulo;
            v_ult_parte      := reg_tit.parte;
         
            --| Se valor do titulo maior que saldo efetivando e sem desconto : baixa parcial
         Elsif p_jur = 'N' Then
            v_val_bx := v_val_sl;
            v_val_sl := 0;
            -- Atualiza Titulo Original
            Update fn_ctrec
               Set tipo_tit     = v_tipo_destino
                  ,banco        = v_banco_destino
                  ,situacao     = v_pos_ren
                  ,status       = 'B'
                  ,dt_baixa    =
                   (v_data)
                  ,vl_total_rec = v_val_bx
             Where empresa = reg_tit.empresa
               And filial = reg_tit.filial
               And num_titulo = reg_tit.num_titulo
               And seq_titulo = reg_tit.seq_titulo
               And parte = reg_tit.parte;
            Select Max(seq_titulo)
              Into v_sqt
              From fn_ctrec
             Where empresa = reg_tit.empresa
               And filial = reg_tit.filial
               And num_titulo = reg_tit.num_titulo
               And parte = reg_tit.parte;
            v_sqt := nvl(v_sqt,
                         0) + 1;
            Insert Into fn_ctrec
               (empresa
               ,filial
               ,num_titulo
               ,seq_titulo
               ,parte
               ,firma
               ,dt_movim
               ,dt_vence
               ,valor
               ,tipo_tit
               ,tipo_cob
               ,tp_juros
               ,situacao
               ,status
               ,historico
               ,producao
               ,periodo
               ,sac_aval
               ,banco
               ,documento
               ,num_ant
               ,seq_ant)
            Values
               (reg_tit.empresa
               ,reg_tit.filial
               ,reg_tit.num_titulo
               ,v_sqt
               ,reg_tit.parte
               ,reg_tit.firma
               ,reg_tit.dt_movim
               ,reg_tit.dt_vence
               ,(v_val - v_val_bx)
               ,reg_tit.tipo_tit
               ,reg_tit.tipo_cob
               ,'M'
               ,v_pos_aberto
               ,'A'
               ,reg_tit.historico
               ,reg_tit.producao
               ,reg_tit.periodo
               ,reg_tit.firma
               ,reg_tit.banco
               ,reg_tit.documento
               ,reg_tit.num_titulo
               ,reg_tit.seq_titulo);
            Insert Into fn_adt_dup
            Values
               (reg_tit.empresa
               ,reg_tit.filial
               ,reg_tit.num_titulo
               ,v_sqt
               ,reg_tit.parte
               ,p_lote
               ,1
               ,Null
               ,Null);
         
            --| Se valor do titulo maior que saldo efetivando e com desconto
         Elsif p_jur = 'S' Then
            v_val_bx := v_val_sl;
            v_val_sl := 0;
            -- Atualiza Titulo Original
            Update fn_ctrec
               Set tipo_tit     = v_tipo_destino
                  ,banco        = v_banco_destino
                  ,situacao     = v_pos_bx
                  ,status       = 'B'
                  ,dt_baixa    =
                   (v_data)
                  ,vl_desc      = v_val - v_val_bx
                  ,vl_total_rec = v_val_bx
             Where empresa = reg_tit.empresa
               And filial = reg_tit.filial
               And num_titulo = reg_tit.num_titulo
               And seq_titulo = reg_tit.seq_titulo
               And parte = reg_tit.parte;
         End If;
      
         --| Atualiza registro do titulo no lote
         Update fn_adt_dup
            Set vl_baixa = v_val_bx
               ,dt_envio = v_dt_envio
          Where empresa = reg_tit.empresa
            And filial = reg_tit.filial
            And num_titulo = reg_tit.num_titulo
            And seq_titulo = reg_tit.seq_titulo
            And parte = reg_tit.parte
            And lote = p_lote;
      
         --| Grava registro para contabilizacao tit pagos
         Open cr_ctb1(1,
                      reg_tit.parte,
                      reg_lote.firma);
         Fetch cr_ctb1
            Into v_ctb;
         If cr_ctb1%Notfound Then
            v_ctb := 0;
         End If;
         Close cr_ctb1;
         If v_ctb = 0 Then
            Insert Into tfn_adt
            Values
               (1
               ,reg_tit.parte
               ,reg_lote.firma
               ,Null
               ,v_val);
         Else
            Update tfn_adt
               Set valor = valor + v_val
             Where tipo = 1
               And parte = reg_tit.parte
               And firma = reg_lote.firma;
         End If;
      
         If v_val_sl = 0 Then
            Exit;
         End If;
      
      End Loop;
   
      --| Se sobrou saldo : joga como juros ou adiantamento
      If v_val_sl > 0 Then
         If p_jur = 'S' Then
            v_val_jur := v_val_sl;
            Update fn_ctrec
               Set vl_juros_rec = v_val_jur
                  ,vl_total_rec = vl_total_rec + v_val_jur
             Where empresa = v_ult_empresa
               And filial = v_ult_filial
               And num_titulo = v_ult_num_titulo
               And seq_titulo = v_ult_seq_titulo
               And parte = v_ult_parte;
         Else
         
            Select fn_adiant_seq.nextval
              Into v_seq
              From dual;
            Insert Into fn_adiant
            Values
               (reg_lote.empresa
               ,reg_lote.firma
               ,v_uvenc
               ,v_seq
               ,'A'
               ,'R'
               ,v_val_sl
               ,to_char(v_dt_envio,
                        'ddmmyyyy')
               ,Null
               ,'Vinculacao em ' ||
                to_char(v_dt_envio,
                        'dd/mm/yyyy')
               ,User
               ,Null
               ,trunc(Sysdate)
               ,0
               ,Null
               , null -- titulo_vinc
               ,null --firma_vinc
               ,null
               );
         End If;
      
      End If;
   
      /*****
        --| Verifica se teve juros ou descontos
        v_val_jur := 0;
        v_val_des := 0;
        if v_val_bx > v_val_pg then
          v_val_des := v_val_bx - v_val_pg;
        elsif v_val_bx < v_val_pg then
          v_val_jur := v_val_pg - v_val_bx;
          end if;
      
        --| Contabilizacao
      
        v_l1 := null;
        v_l2 := null;
      
        contab(p_emp, p_lote, v_val_bx, v_val_jur, v_val_des, v_l1, v_l2);
      
        --| Para cada titulo vinculado, grava a transacao contabil
        for reg_tit in cr_tit loop
          if reg_tit.parte = 0 and v_l1 is not null then
            update fn_ctrec
               set lote1 = to_char(v_l1)
             where empresa = reg_tit.empresa and
                   filial = reg_tit.filial and
                   num_titulo = reg_tit.num_titulo and
                   seq_titulo = reg_tit.seq_titulo and
                   parte = reg_tit.parte;
          elsif reg_tit.parte = 1 and v_l2 is not null then
            update fn_ctrec
               set lote1 = to_char(v_l2)
             where empresa = reg_tit.empresa and
                   filial = reg_tit.filial and
                   num_titulo = reg_tit.num_titulo and
                   seq_titulo = reg_tit.seq_titulo and
                   parte = reg_tit.parte;
            end if;
          end loop;
      
      ****/
   
   End;

   Function tipo_doc(p_debito In Number
                    ,p_conta  fn_adt.conta%Type
                    ,p_titulo fn_adt.num_titulo%Type) Return Char
   
    Is
   
   Begin
   
      If p_debito > 0 Then
         Return 'TITULO';
      End If;
   
      If p_conta Is Not Null Then
         Return 'CHEQUE';
      Elsif p_conta Is Null
            And p_titulo Is Not Null Then
         Return 'TIT TERC/PROPRIO';
      Else
         Return 'UTLZ ADTO';
      End If;
   
   End;

End fn_adt_utl;
/
