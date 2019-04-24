CREATE OR REPLACE Package fn_caixa_utl Is

   --||
   --|| fn_caixa_utl.PKS : Rotinas para Digitacao do caixa
   --||

   Procedure fecha(v_emp  fn_caixa.empresa%Type
                  ,v_lote fn_caixa.lote%Type);

   Procedure estorna(v_emp  fn_caixa.empresa%Type
                    ,v_lote fn_caixa.lote%Type);

End fn_caixa_utl;
/
CREATE OR REPLACE Package Body fn_caixa_utl Is

   --||
   --|| fn_caixa_utl.PKB : Digitacao do caixa
   --||

   ----------------------------------------------------------------------------------
   Procedure fecha(v_emp  fn_caixa.empresa%Type
                  ,v_lote fn_caixa.lote%Type)
   
    Is
      Cursor cr Is
         Select *
           From fn_caixa
          Where empresa = v_emp
            And lote = v_lote
            And efetivado = 'N'
            For Update;
   
      Cursor cri Is
         Select *
           From fn_itens_cx
          Where empresa = v_emp
            And lote = v_lote;
   
      Cursor craf(pc_cta cg_plano.cod_conta%Type) Is
         Select 1
           From cg_contas_af
          Where empresa = v_emp
            And cod_conta = pc_cta;
   
      reg_cx         fn_caixa%Rowtype;
      v_lote_oficial Number;
      v_lancto_cg    Number;
      v_lote_cont    Number;
      v_saida        Number;
      v_nat          Char(1);
      v_cod_contabil Number;
      v_oper         fn_movimen.operacao%Type;
      v_origem       Number;
      v_ret          Number;
      v_ccp          cg_plano.cod_conta%Type;
   
   Begin
   
      -- contadores
      v_saida := 0;
   
      -- localiza o caixa
      Open cr;
      Fetch cr
         Into reg_cx;
      If cr%Notfound Then
         Close cr;
         raise_application_error(-20100,
                                 'Lote ja efetivado');
         Return;
      End If;
   
      -- conta contabil CCP
      v_ccp := '2.1.04.01.13';
   
      -- lote contabil inicial
      Select cg_lotes_seq.nextval
        Into v_lote_cont
        From dual;
   
      -- para cada item do caixa
      For regi In cri Loop
         v_saida  := v_saida + regi.valor;
         v_nat    := 'D';
         v_oper   := 'S';
         v_origem := 0;
      
         v_cod_contabil := Null;
         Open craf(regi.cod_contabil);
         Fetch craf
            Into v_ret;
         If craf%Found Then
            v_cod_contabil := regi.firma;
         End If;
         Close craf;
      
         -- gera caixa e bancos
         Insert Into fn_movimen
         Values
            (regi.empresa
            ,reg_cx.conta
            ,reg_cx.data
            ,fn_movimen_seq.nextval
            ,0
            ,regi.valor
            ,v_oper
            ,regi.historico
            ,regi.docto
            ,regi.seq_item
            ,regi.cod_fin
            ,Null
            ,regi.firma
            ,'N'
            ,Null
            ,Null
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
      
         -- baixar contas a pagar
         If regi.natureza = 'P' Then
            Update fn_ctpag
               Set dt_baixa      = reg_cx.data
                  ,vlr_baixa     = regi.valor
                  ,empresa_pagto = 1
                  ,forma_pagto   = 'R'
                  ,docto_pagto   = reg_cx.lote
                  ,conta         = reg_cx.conta
                  ,situacao      = 'BX'
                  ,status        = 'B'
             Where empresa = regi.empresa
               And num_titulo = regi.num_titulo
               And seq_titulo = regi.seq_titulo
               And parte = regi.parte
               And firma = regi.firma;
         End If;
      
         -- gerar adiantamento
         If regi.natureza = 'A' Then
            Insert Into fn_adiant
            Values
               (regi.empresa
               ,regi.firma
               ,reg_cx.data
               ,fn_adiant_seq.nextval
               ,'P'
               ,'R'
               ,regi.valor + nvl(regi.vl_ccp,
                                 0)
               ,regi.docto
               ,reg_cx.lote
               ,regi.historico
               ,User
               ,Null
               ,Sysdate
               ,0
               ,Null
               ,regi.num_titulo
               ,regi.firma,null);
         End If;
      
         -- ccp retido diretamente na nf
         -- lancamento da conta CCP
         If nvl(regi.vl_ccp,
                0) > 0 Then
            Insert Into cp_ccp
            Values
               (regi.empresa
               ,trunc(regi.firma / 100)
               ,to_char(reg_cx.data,
                        'RRRR/MM')
               ,regi.valor
               ,Null
               ,Null
               ,0
               ,regi.vl_ccp
               ,regi.valor
               ,reg_cx.data);
         End If;
      
         -- lancamento contabil inicial
         Select cg_lancto_seq.nextval
           Into v_lancto_cg
           From dual;
      
         Insert Into t_lancto
         Values
            (to_number(to_char(reg_cx.data,
                               'RRRR'))
            ,v_emp
            ,v_lancto_cg
            ,v_lote_cont
            ,v_lote
            ,regi.cod_contabil
            ,trunc(reg_cx.data)
            ,regi.valor + nvl(regi.vl_ccp,
                              0)
            ,v_nat
            ,regi.historico || ' ' || regi.docto || ' ' ||
             cd_firmas_utl.nome(regi.firma)
            ,2
            ,v_cod_contabil
            ,0
            ,v_origem
            ,0);
      
         If regi.ccusto Is Not Null Then
            Insert Into t_lancto_cc
            Values
               (to_number(to_char(reg_cx.data,
                                  'RRRR'))
               ,v_emp
               ,v_lancto_cg
               ,regi.ccusto
               ,regi.valor + nvl(regi.vl_ccp,
                                 0)
               ,v_nat
               ,reg_cx.data
               ,regi.cod_contabil
               ,0);
         End If;
      
         If regi.op_os Is Not Null Then
            Insert Into t_lancto_ar
               (ano
               ,empresa
               ,seq_lancto
               ,area_res
               ,valor
               ,natureza
               ,data
               ,cod_conta
               ,cenario)
            Values
               (to_number(to_char(reg_cx.data,
                                  'RRRR'))
               ,v_emp
               ,v_lancto_cg
               ,regi.op_os
               ,regi.valor + nvl(regi.vl_ccp,
                                 0)
               ,v_nat
               ,reg_cx.data
               ,regi.cod_contabil
               ,0);
         End If;
      
         -- lancamento da conta CCP
         If nvl(regi.vl_ccp,
                0) > 0 Then
            -- lancamento contabil
            Select cg_lancto_seq.nextval
              Into v_lancto_cg
              From dual;
         
            Insert Into t_lancto
            Values
               (to_number(to_char(reg_cx.data,
                                  'RRRR'))
               ,v_emp
               ,v_lancto_cg
               ,v_lote_cont
               ,v_lote
               ,v_ccp
               ,trunc(reg_cx.data)
               ,nvl(regi.vl_ccp,
                    0)
               ,'C'
               ,'CCP Retido de ' || cd_firmas_utl.nome(regi.firma) ||
                ' conforme recibo ' || regi.docto
               ,2
               ,Null
               ,0
               ,0
               ,0);
         End If;
      
      End Loop;
   
      -- Codigo contabil caixa
      Select cod_contabil
        Into v_cod_contabil
        From fn_contas
       Where empresa = reg_cx.empresa
         And conta = reg_cx.conta;
   
      -- lancamento da conta caixa
      Select cg_lancto_seq.nextval
        Into v_lancto_cg
        From dual;
   
      Insert Into t_lancto
      Values
         (to_number(to_char(reg_cx.data,
                            'RRRR'))
         ,v_emp
         ,v_lancto_cg
         ,v_lote_cont
         ,v_lote
         ,'1.1.01.01.01'
         ,trunc(reg_cx.data)
         ,v_saida
         ,'C'
         ,'Pagamentos do Dia Conforme Caixa ' || v_lote
         ,2
         ,v_cod_contabil
         ,0
         ,1
         ,0);
   
      -- efetivar lote contabil
      v_lote_oficial := cg_lote.cg_grava_lote(v_emp,
                                              to_number(to_char(reg_cx.data,
                                                                'RRRR')),
                                              v_lote_cont,
                                              Null,
                                              0);
      If v_lote_oficial Is Null Then
         Rollback;
         raise_application_error(-20101,
                                 'Erro ao contabilizar');
         Return;
      End If;
   
      -- efetivar caixa
      Update fn_caixa
         Set efetivado = 'S'
            ,lote_cont = v_lote_oficial
       Where Current Of cr;
      Close cr;
   
   End;

   ----------------------------------------------------------------------------------
   Procedure estorna(v_emp  fn_caixa.empresa%Type
                    ,v_lote fn_caixa.lote%Type)
   
    Is
      Cursor cr Is
         Select *
           From fn_caixa
          Where empresa = v_emp
            And lote = v_lote
            And efetivado = 'S'
            For Update;
   
      Cursor cri Is
         Select *
           From fn_itens_cx
          Where empresa = v_emp
            And lote = v_lote;
   
      Cursor crl(a cg_lancto.ano%Type
                ,l cg_lancto.lote%Type) Is
         Select *
           From cg_lancto
          Where ano = a
            And empresa = v_emp
            And lote = l;
   
      reg_cx fn_caixa%Rowtype;
   
   Begin
   
      -- localiza o caixa
      Open cr;
      Fetch cr
         Into reg_cx;
      If cr%Notfound Then
         Close cr;
         raise_application_error(-20100,
                                 'Lote n?o efetivado');
         Return;
      End If;
   
      -- para cada item do caixa
      For regi In cri Loop
      
         -- gera caixa e bancos
         Delete fn_movimen
          Where empresa = regi.empresa
            And conta = reg_cx.conta
            And chave = regi.seq_item;
      
         -- baixar contas a pagar
         If regi.natureza = 'P' Then
            Update fn_ctpag
               Set dt_baixa      = Null
                  ,vlr_baixa     = Null
                  ,empresa_pagto = Null
                  ,forma_pagto   = Null
                  ,docto_pagto   = Null
                  ,conta         = Null
                  ,situacao      = 'AB'
                  ,status        = 'A'
             Where empresa = regi.empresa
               And num_titulo = regi.num_titulo
               And seq_titulo = regi.seq_titulo
               And parte = regi.parte
               And firma = regi.firma;
         End If;
      
         -- gerar adiantamento
         If regi.natureza = 'A' Then
            Delete fn_adiant
             Where empresa = regi.empresa
               And lote_cont = reg_cx.lote
               And valor = regi.valor + nvl(regi.vl_ccp,
                                            0)
               And num_doc = regi.docto;
         End If;
      
      End Loop;
   
      -- deletar contabilidade
      lib_marca.marca;
      For reg In crl(to_number(to_char(reg_cx.data,
                                       'RRRR')),
                     reg_cx.lote_cont) Loop
         Delete From cg_lancto_cc
          Where empresa = v_emp
            And seq_lancto = reg.seq_lancto;
         Delete From cg_lancto_ar
          Where empresa = v_emp
            And seq_lancto = reg.seq_lancto;
      End Loop;
      Delete From cg_lancto
       Where ano = to_number(to_char(reg_cx.data,
                                     'RRRR'))
         And empresa = v_emp
         And lote = reg_cx.lote_cont;
      lib_marca.desmarca;
   
      -- efetivar caixa
      Update fn_caixa
         Set efetivado = 'N'
            ,lote_cont = Null
       Where Current Of cr;
      Close cr;
   
   End;

End fn_caixa_utl;
/
