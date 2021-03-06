create or replace procedure cpag_nf(emp  in ce_notas.empresa%type
                    ,fil  in ce_notas.filial%type
                    ,p_id ce_notas.id%type)
   /*
      || Integra com C.Pagar
      */
    is

      reg      ce_notas%rowtype;
      reg_cfo  ft_cfo%rowtype;
      reg_oper ft_oper%rowtype;

      cursor cr_parc is
         select *
           from ce_parc_nf
          where id_ce_nota = p_id
          --and parcela >1
          ;
         -- AND (USER != 'GESTAO' OR ID=52518) ;

      v_pos_aberto fn_prgen.pos_aberto%type;
      v_ttit       fn_tipos_tit.tipo_tit%type;
      v_sit        fn_pos_tit_cp.situacao%type;
      v_moeda      fn_moedas.moeda%type;

      reg_cp ft_condpag%rowtype;

      v_historico fn_ctpag.historico%type;

      v_msg varchar2(100);

   begin

      v_msg := 'Le a nota';
      --| Le a nota
      select *
        into reg
        from ce_notas
       where id = p_id;

      v_msg := 'Le o cfo';
      --| Le CFO para verificar os procedimento de integracao
      select * into reg_cfo from ft_cfo where cod_cfo = reg.cod_cfo;

      v_msg := 'Le ft_oper';
      --| Le FT_OPER para verificar natureza
      select *
        into reg_oper
        from ft_oper
       where empresa = emp
         and cod_oper = reg.cod_oper;

      --| Se atualiza c.receber
      if reg_cfo.atl_cpag <> 'S' then
         return;
      end if;

      v_msg := 'Le cond_pagto';
      --| Le condicao de pagto
      select * into reg_cp from ft_condpag where cod_condpag = reg.cod_condpag;

      v_msg := 'Le tipo_titulo';
      --| Tipo de titulo a usar e situacao a usar
      select tipo_tit
            ,situacao
        into v_ttit
            ,v_sit
        from ce_param
       where empresa = emp;

      if v_ttit is null or
         v_sit is null then
         raise_application_error(-20105,
                                 'Falta tipo de titulo e/ou situacao na tabela de parametros');
      end if;

      v_msg := 'Le moeda';
      --| Moeda
      select moeda_pais into v_moeda from fn_param where empresa = emp;

      v_msg := 'Le historico';
      --| Historico
      select user || ' - ' || to_char(sysdate,
                                      'DD/MM/RRRR HH:MI:SS')
        into v_historico
        from dual;

      v_msg := 'insert';
      --| Para cada parcela da nota
      for reg_par in cr_parc loop
         --raise_application_error(-20230,REG.EMPRESA|| ' '|| REG.NUM_NOTA || ' '||REG_PAR.PARCELA || ' '||REG.COD_FORNEC|| ' '||PAR|| ' '||REG.FILIAL ) ;
         begin
            begin
            insert into fn_ctpag
               (empresa
               ,num_titulo
               ,seq_titulo
               ,firma
               ,parte
               ,filial
               ,dt_movto
               ,dt_vencto
               ,moeda
               ,vlr_titulo
               ,situacao
               ,status
               ,producao
               ,periodo
               ,cenario
               ,tipo_tit
               ,rotina_origem
               ,c_apresent
               ,a_vista
               ,historico
               ,sr_nota
               ,tipo_cob
               ,banco_cobranca
               ,dt_emissao
               ,id_ce_nota)
            values
               (reg.empresa
               ,reg.num_nota
               ,reg_par.parcela
               ,reg.cod_fornec
               ,reg.parte
               ,reg.filial
               ,reg.dt_entrada
               ,reg_par.dt_vencto
               ,v_moeda
               ,reg_par.vlr_parcela
               ,v_sit
               ,'A'
               ,reg.producao
               ,reg.periodo
               ,0
               ,nvl(reg.tipo_tit,
                    v_ttit)
               ,1
               ,reg_cp.ct_apres
               ,reg_cp.a_vista
               ,rtrim(nvl(reg.observacao,
                          '')) || ' - ' || rtrim(v_historico)
               ,reg.sr_nota
               ,reg.tipo_cob
               ,reg.banco_cobranca
               ,reg.dt_emissao
               ,p_id);
            exception
              when dup_val_on_index then
                raise_application_error(-20230,'cpag_nf: Aten��o! J� existe duplicata com mesma sequencia');
             when others then
               raise;
            end;
            --/ gera controle de titulos por op/af
            v_msg := 'gera_cpag_nf_opaf';
            ce_nf.gera_cpag_nf_opaf(reg.empresa,
                              reg.filial,
                              reg.num_nota,
                              reg.cod_fornec,
                              reg_par.parcela,
                              reg.parte,
                              reg.sr_nota,
                              reg.id);

            v_msg := 'gera_cpag_nf_af';
             ce_nf.gera_cpag_nf_af(reg.empresa,
                            fil,
                            reg.num_nota,
                            reg.cod_fornec,
                            reg_par.parcela,
                            reg.parte,
                            reg.sr_nota,
                            reg.id);

            v_msg := 'gera_cpag_aprop_plano';
             ce_nf.gera_cpag_apropr_plano(reg.empresa,
                                   fil,
                                   reg.num_nota,
                                   reg.cod_fornec,
                                   reg_par.parcela,
                                   reg.parte,
                                   reg.sr_nota,
                                   reg.id);
            --exception --somente para inclus?es especiais
            -- when others then --somente para inclus?es especiais
            --   null; --somente para inclus?es especiais
         end;
         --resultado.titulos := resultado.titulos + 1;
      end loop;

      /*
      exception
         when others then
            raise_application_error(-20230,'cpag_nf: '|| v_msg || ' ' || substr(sqlerrm,1,100) );
      */
   end;
/
