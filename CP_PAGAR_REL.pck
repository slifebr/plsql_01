CREATE OR REPLACE PACKAGE CP_PAGAR_REL IS

   --||
   --|| CP_PAGAR_REL.PKS : Gera tabela temporaria de contas as pagar .
   --||
  function classifica_cp_0111cg( p_emp fn_ctpag.Empresa%type,
                                    p_num  fn_ctpag.NUM_TITULO%type,
                                    p_seq  fn_ctpag.SEQ_TITULO%type,
                                    p_firm fn_ctpag.FIRMA%type,
                                    p_par  fn_ctpag.PARTE%type) return number;
                                    
  PROCEDURE cp_0111 (p_emp   co_requis.empresa%TYPE,
                          p_fil   co_requis.filial%TYPE,
                          p_opos  co_requis.ordem%TYPE,
                          p_where IN OUT VARCHAR2,
                          p_con   pp_contratos.contrato%TYPE,
                          p_plano ce_apropr_nf.cod_conta%type,
                          P_REL   VARCHAR2);

END CP_PAGAR_REL;
/
CREATE OR REPLACE PACKAGE BODY CP_PAGAR_REL IS

   --||
   --|| CP_APAGAR_REL.PKB : pacote para relatorios de contas a pagar CP_0111
   --||

  function classifica_cp_0111cg( p_emp fn_ctpag.Empresa%type,
                                 p_num  fn_ctpag.NUM_TITULO%type,
                                 p_seq  fn_ctpag.SEQ_TITULO%type,
                                 p_firm fn_ctpag.FIRMA%type,
                                 p_par  fn_ctpag.PARTE%type) return number
   is
   v_ret number(1);
   
   begin
     v_ret := 0;
     if CD_FIRMAS_UTL.is_arrecadador(p_firm) = 'S' then
         v_ret := 3;
     elsif CD_FIRMAS_UTL.is_funcionario(p_firm) = 'S' then
          v_ret := 1;
     /*elsif fn_util.is_outros_operacionais( p_emp ,
                             p_num ,
                             p_seq ,
                             p_firm,
                             p_par ) = 'S' then                       
           v_ret := 2;*/
                           
    end if;
    return v_ret;
  end;
  
      
  --| POR FORNECEDOR
  PROCEDURE CP_0111CG (p_emp   co_requis.empresa%TYPE,
                       p_fil   co_requis.filial%TYPE,
                       p_opos  co_requis.ordem%TYPE,
                       p_where IN OUT VARCHAR2,
                       p_con   pp_contratos.contrato%TYPE,
                       p_plano ce_apropr_nf.cod_conta%type,
                        p_erro  number) IS
  BEGIN
    NULL;
  END;

  --| POR VENCIMENTO
  PROCEDURE CP_0111VG (p_emp   co_requis.empresa%TYPE,
                       p_fil   co_requis.filial%TYPE,
                       p_opos  co_requis.ordem%TYPE,
                       p_where IN OUT VARCHAR2,
                       p_con   pp_contratos.contrato%TYPE,
                       p_plano ce_apropr_nf.cod_conta%type,
                       p_erro  number) IS
    --|------------------------------
    --| variaveis locais
    --|------------------------------
    TYPE trefcur IS REF CURSOR;
    v_refcur    trefcur;
    v_sql       varchar2(32000);  
    v_where     varchar2(32000);  
    v_groupby   varchar2(32000);  
    v_orderby   varchar2(32000);  
    
    --| CAMPOS DA TEMP                   
    vt_firma            dbms_sql.number_table;
    vt_empresa          dbms_sql.number_table;
    vt_filial           dbms_sql.number_table;
    vt_dsp_fornecedor   dbms_sql.varchar2_table;
    vt_entrada          dbms_sql.date_table;
    vt_dt_vencto        dbms_sql.date_table;
    vt_emissao          dbms_sql.date_table;
    vt_situacao         dbms_sql.varchar2_table;
    vt_num_titulo       dbms_sql.number_table;
    vt_seq_titulo       dbms_sql.number_table;
    vt_seq_nro          dbms_sql.number_table;
    vt_vlr_titulo       dbms_sql.number_table;
    vt_vlr_jrs_acum     dbms_sql.number_table;
    vt_tipo_titulo      dbms_sql.varchar2_table;
    vt_pagamento        dbms_sql.date_table;
    vt_vlr_baixa        dbms_sql.number_table;
    vt_docto_pagto      dbms_sql.number_table;
    vt_forma_pagto      dbms_sql.varchar2_table;
    vt_parte            dbms_sql.number_table;
    vt_status           dbms_sql.varchar2_table;
    vt_historico        dbms_sql.varchar2_table;
    vt_obs              dbms_sql.varchar2_table;
    vt_banco_cobranca   dbms_sql.varchar2_table;
    vt_pc_juros         dbms_sql.number_table;
    vt_vl_juros         dbms_sql.number_table;
    vt_tipo_juros       dbms_sql.varchar2_table;
    vt_pc_multa         dbms_sql.number_table;
    vt_vl_multa         dbms_sql.number_table;
    vt_tipo_multa       dbms_sql.varchar2_table;
    vt_sr_nota          dbms_sql.varchar2_table;
    vt_vlr_adiantamento dbms_sql.number_table;
    vt_valor_acumulado  dbms_sql.number_table;
    vt_folha            dbms_sql.number_table;
    vt_descr_folha      dbms_sql.varchar2_table;
    
    
  BEGIN
    v_sql := '  select t.firma
                      ,t.empresa
                      ,t.filial
                      ,cd_firmas_utl.nome(t.firma) dsp_fornecedor
                      ,t.dt_movto entrada
                      ,t.dt_vencto
                      ,t.dt_emissao emissao
                      ,p.descricao situacao
                      ,t.num_titulo
                      ,t.seq_titulo
                      ,row_number() over(order by t.firma, t.num_titulo, t.seq_titulo) seq_nro
                      ,t.vlr_titulo
                      ,t.vlr_jrs_acum
                      ,d.descricao tipo_titulo
                      ,t.dt_baixa pagamento
                      ,t.vlr_baixa
                      ,t.docto_pagto
                      ,t.forma_pagto
                      ,t.parte
                      ,t.status
                      ,t.historico
                      ,t.obs
                      ,t.banco_cobranca
                      ,t.pc_juros
                      ,t.vl_juros
                      ,t.tipo_juros
                      ,t.pc_multa
                      ,t.vl_multa
                      ,t.tipo_multa
                      ,t.sr_nota
                      ,t.vlr_adiantamento
                      ,sum(t.vlr_titulo) over(order by t.dt_vencto) valor_acumulado
                      ,t.seq_rhpgto folha
                      ,(select rm.descr
                          from rh_func_pagto rfp
                              ,rh_folha      rf
                              ,rh_modalidade  rm
                         where rf.seq_folha = rfp.seq_folha
                           and rm.seq_rhmodal = rf.seq_rhmodal
                           and rfp.seq_rhpgto = t.seq_rhpgto) descr_folha     
             
                  from fn_ctpag      t
                      ,fn_pos_tit_cp p
                      ,fn_tipos_tit  d
                      ,fn_tipos_cob  o ';

             --| clausula where
             v_where :=  
                       p_where ||'
                   and p.situacao = t.situacao
                   and d.tipo_tit = t.tipo_tit
                   and o.tipo_cob = t.tipo_cob
                   ';
             if p_plano is not null then
                v_where := v_where ||'    
                   and exists
                        (select 1
                           from fn_plano     p
                               ,ce_apropr_nf n
                          where n.num_nota = t.num_titulo
                            and n.sr_nota = t.sr_nota
                            and n.cod_fornec = t.firma
                            and n.empresa = t.empresa
                            and n.filial = t.filial
                            and n.parte = t.parte
                            and n.cod_conta = p.cod_fin
                            and p.cod_fin = '||''''||p_plano||''''||') ';
             end if;
             v_groupby := '
                 group by cd_firmas_utl.nome(t.firma)
                         ,t.num_titulo
                         ,t.seq_titulo
                         ,t.empresa
                         ,t.filial
                         ,t.firma
                         ,t.dt_movto
                         ,t.dt_vencto
                         ,p.descricao
                         ,t.vlr_titulo
                         ,t.vlr_jrs_acum
                         ,d.descricao
                         ,t.dt_baixa
                         ,t.vlr_baixa
                         ,t.docto_pagto
                         ,t.forma_pagto
                         ,t.parte
                         ,t.status
                         ,t.historico
                         ,t.dt_emissao
                         ,t.obs
                         ,t.banco_cobranca
                         ,t.pc_juros
                         ,t.vl_juros
                         ,t.tipo_juros
                         ,t.pc_multa
                         ,t.vl_multa
                         ,t.tipo_multa
                         ,t.sr_nota
                         ,t.vlr_adiantamento
                         ,t.seq_rhpgto
                 ';

                 --| ordenação
                 v_orderby := '
                 order by t.dt_vencto
                         ,2
                         ,4
                         ,t.num_titulo
                         ,t.seq_titulo';
                         
     v_sql := v_sql || v_where|| v_groupby ||v_orderby;
     
     
     delete tab_erro2;
     insert into tab_erro2 values (1000,v_sql);
     
     delete TCP_0111;
     COMMIT;
   
     --|REF CURSOR
     OPEN v_refcur FOR v_sql;
     FETCH v_refcur BULK COLLECT
      INTO vt_firma            ,
           vt_empresa          ,
           vt_filial           ,
           vt_dsp_fornecedor   ,
           vt_entrada          ,
           vt_dt_vencto        ,
           vt_emissao          ,
           vt_situacao         ,
           vt_num_titulo       ,
           vt_seq_titulo       ,
           vt_seq_nro          ,
           vt_vlr_titulo       ,
           vt_vlr_jrs_acum     ,
           vt_tipo_titulo      ,
           vt_pagamento        ,
           vt_vlr_baixa        ,
           vt_docto_pagto      ,
           vt_forma_pagto      ,
           vt_parte            ,
           vt_status           ,
           vt_historico        ,
           vt_obs              ,
           vt_banco_cobranca   ,
           vt_pc_juros         ,
           vt_vl_juros         ,
           vt_tipo_juros       ,
           vt_pc_multa         ,
           vt_vl_multa         ,
           vt_tipo_multa       ,
           vt_sr_nota          ,
           vt_vlr_adiantamento ,
           vt_valor_acumulado ,
           vt_folha            ,
           vt_descr_folha      ;
     CLOSE v_refcur;
     --|
     IF nvl(vt_num_titulo.COUNT,
               0) > 0 THEN
           FORALL x IN nvl(vt_num_titulo.FIRST,
                           0) .. nvl(vt_num_titulo.LAST,
                                     0)
              INSERT INTO TCP_0111(FIRMA,
                                   EMPRESA,
                                   FILIAL,
                                   DSP_FORNECEDOR,
                                   ENTRADA,
                                   DT_VENCTO,
                                   EMISSAO,
                                   SITUACAO,
                                   NUM_TITULO,
                                   SEQ_TITULO,
                                   SEQ_NRO,
                                   VLR_TITULO,
                                   VLR_JRS_ACUM,
                                   TIPO_TITULO,
                                   PAGAMENTO,
                                   VLR_BAIXA,
                                   DOCTO_PAGTO,
                                   FORMA_PAGTO,
                                   PARTE,
                                   STATUS,
                                   HISTORICO,
                                   OBS,
                                   BANCO_COBRANCA,
                                   PC_JUROS,
                                   VL_JUROS,
                                   TIPO_JUROS,
                                   PC_MULTA,
                                   VL_MULTA,
                                   TIPO_MULTA,
                                   SR_NOTA,
                                   VLR_ADIANTAMENTO,
                                   VALOR_ACUMULADO,
                                   folha,
                                   descr_folha)
                           values (vt_firma(x)            ,
                                   vt_empresa(x)          ,
                                   vt_filial(x)           ,
                                   vt_dsp_fornecedor(x)   ,
                                   vt_entrada(x)          ,
                                   vt_dt_vencto(x)        ,
                                   vt_emissao(x)          ,
                                   vt_situacao(x)         ,
                                   vt_num_titulo(x)       ,
                                   vt_seq_titulo(x)       ,
                                   vt_seq_nro(x)          ,
                                   vt_vlr_titulo(x)       ,
                                   vt_vlr_jrs_acum(x)     ,
                                   vt_tipo_titulo(x)      ,
                                   vt_pagamento(x)        ,
                                   vt_vlr_baixa(x)        ,
                                   vt_docto_pagto(x)      ,
                                   vt_forma_pagto(x)      ,
                                   vt_parte(x)            ,
                                   vt_status(x)           ,
                                   vt_historico(x)        ,
                                   vt_obs(x)              ,
                                   vt_banco_cobranca(x)   ,
                                   vt_pc_juros(x)         ,
                                   vt_vl_juros(x)         ,
                                   vt_tipo_juros(x)       ,
                                   vt_pc_multa(x)         ,
                                   vt_vl_multa(x)         ,
                                   vt_tipo_multa(x)       ,
                                   vt_sr_nota(x)          ,
                                   vt_vlr_adiantamento(x)  ,
                                   vt_valor_acumulado(x),
                                   vt_folha(x),
                                   vt_descr_folha(x)  );
     end if;                                 
     commit;
  END;
  --| resumo com plano financeiro
  PROCEDURE CP_0111VRF (p_emp   co_requis.empresa%TYPE,
                       p_fil   co_requis.filial%TYPE,
                       p_opos  co_requis.ordem%TYPE,
                       p_where IN OUT VARCHAR2,
                       p_con   pp_contratos.contrato%TYPE,
                       p_plano ce_apropr_nf.cod_conta%type,
                       p_erro  number) IS

        --
        TYPE trefcur IS REF CURSOR;
        v_cur_plano trefcur;
        v_sql       VARCHAR2(32000);
        --
     
        vt_dsp_fornecedor dbms_sql.varchar2_table;
        vt_dt_vencto      dbms_sql.date_table;
        vt_num_titulo     dbms_sql.number_table;
        vt_seq_titulo     dbms_sql.number_table;
        vt_cod_fin        dbms_sql.varchar2_table;
        vt_descr_plano    dbms_sql.varchar2_table;
        vt_firma          dbms_sql.number_table;
        vt_emissao        dbms_sql.date_table;
        vt_situacao       dbms_sql.varchar2_table;
        vt_vlr_titulo     dbms_sql.number_table;
        vt_vlr_jrs_acum   dbms_sql.number_table;
        vt_tipo_titulo    dbms_sql.varchar2_table;
        vt_pagamento      dbms_sql.date_table;
        vt_vlr_baixa      dbms_sql.number_table;
        vt_docto_pagto    dbms_sql.number_table;
        vt_forma_pagto    dbms_sql.varchar2_table;
        vt_parte          dbms_sql.number_table;
        vt_status         dbms_sql.varchar2_table;
        vt_historico      dbms_sql.varchar2_table;
        vt_fator          dbms_sql.number_table;
     
        x NUMBER;
        v_erro  NUMBER;
  begin
            --| GERA TEMPORARIA DE TITULOS
          CP_0111VG(p_emp  ,
                  p_fil  ,
                  p_opos ,
                  p_where,
                  p_con  ,
                  p_plano,
                  v_erro);
            
            delete tcp_pag_opplan;
            commit;
            
            V_SQL := ' select 
                            t.dsp_fornecedor ,
                            t.dt_vencto     ,
                            t.num_titulo    ,
                            t.seq_titulo    ,
                            p.cod_fin       ,
                            DECODE(p.descricao,NULL,'||''''||'NÃO INFORMADO'||''''||',P.DESCRICAO) descr_plano   ,
                            t.firma         ,
                            t.emissao       ,
                            t.situacao      ,
                            t.vlr_titulo    ,
                            t.vlr_jrs_acum   ,     
                            t.tipo_titulo     ,    
                            t.pagamento       ,    
                            NVL(t.vlr_baixa,0) + nvl(T.VLR_ADIANTAMENTO,0)  vlr_baixa    ,   
                            t.docto_pagto     ,    
                            t.forma_pagto     ,    
                            t.parte           ,    
                            t.status          ,    
                            t.historico       ,    
                            DECODE(N.PERC_APROPR,NULL ,100,N.PERC_APROPR) fator               
                        from tcp_0111       t
                            ,fn_plano       p
                            ,fn_ctpag_plano n
                       where n.num_titulo(+) = t.num_titulo
                         and n.firma(+) = t.firma
                         and n.empresa(+) = t.empresa
                         and n.filial(+) = t.filial
                         and n.parte(+) = t.parte
                         and n.seq_titulo(+) = t.seq_titulo
                         and n.cod_conta = p.cod_fin(+)
                 ';
        v_sql := v_sql || '   ';
        
        if nvl(p_erro,0) = 1 then
           if length(v_sql) > 4000 then
              --raise_application_error(-20101,v_sql);
              insert into tab_erro values(3,3, null,v_sql );
           else
             --raise_application_error(-20100,'1');
            insert into tab_erro2 values(3,v_sql );
           end if;
           commit;
        end if;     

        OPEN v_cur_plano FOR v_sql;
        FETCH v_cur_plano BULK COLLECT
           INTO vt_dsp_fornecedor, vt_dt_vencto, vt_num_titulo, vt_seq_titulo, vt_cod_fin, vt_descr_plano, vt_firma, vt_emissao, vt_situacao, vt_vlr_titulo, vt_vlr_jrs_acum, vt_tipo_titulo, vt_pagamento, vt_vlr_baixa, vt_docto_pagto, vt_forma_pagto, vt_parte, vt_status, vt_historico, vt_fator;
        CLOSE v_cur_plano;
     
        IF nvl(vt_num_titulo.COUNT,
               0) > 0 THEN
           FORALL x IN nvl(vt_num_titulo.FIRST,
                           0) .. nvl(vt_num_titulo.LAST,
                                     0)     
       
       INSERT INTO tcp_pag_opplan
                 (dsp_fornecedor,
                  dt_vencto,
                  num_titulo,
                  seq_titulo,
                  cod_fin,
                  descr_plano,
                  firma,
                  emissao,
                  situacao,
                  vlr_titulo,
                  vlr_jrs_acum,
                  tipo_titulo,
                  pagamento,
                  vlr_baixa,
                  docto_pagto,
                  forma_pagto,
                  parte,
                  status,
                  historico,
                  fator)
              VALUES
                 (vt_dsp_fornecedor(x),
                  vt_dt_vencto(x),
                  vt_num_titulo(x),
                  vt_seq_titulo(x),
                  vt_cod_fin(x),
                  vt_descr_plano(x),
                  vt_firma(x),
                  vt_emissao(x),
                  vt_situacao(x),
                  vt_vlr_titulo(x),
                  vt_vlr_jrs_acum(x),
                  vt_tipo_titulo(x),
                  vt_pagamento(x),
                  vt_vlr_baixa(x),
                  vt_docto_pagto(x),
                  vt_forma_pagto(x),
                  vt_parte(x),
                  vt_status(x),
                  vt_historico(x),
                  vt_fator(x));  

      END IF;
  end; 

  --|----------------------------------------------------------------
  PROCEDURE cp_0111 (p_emp   co_requis.empresa%TYPE,
                     p_fil   co_requis.filial%TYPE,
                     p_opos  co_requis.ordem%TYPE,
                     p_where IN OUT VARCHAR2,
                     p_con   pp_contratos.contrato%TYPE,
                     p_plano ce_apropr_nf.cod_conta%type,
                     P_REL   VARCHAR2
                     ) IS


   v_erro number;
   BEGIN
      --raise_application_error(-20100,'aqui');

      DELETE TCP_0111;

      v_erro := 1; --| se nao quiser gerar tab_erro informar 0(zero)
      --delete tab_erro;
      --delete tab_erro2;
      commit;
        
      IF P_REL = 'VG' THEN
        --|POR VENCIMENTO
        CP_0111VG(p_emp  ,
                  p_fil  ,
                  p_opos ,
                  p_where,
                  p_con  ,
                  p_plano,
                  v_erro);
                  
      ELSIF P_REL = 'CG' THEN
        --|POR FORNECEDOR
        CP_0111VG(p_emp  ,
                  p_fil  ,
                  p_opos ,
                  p_where,
                  p_con,
                  p_plano,
                  v_erro  );
                    
      ELSIF P_REL = 'VRF' THEN
        --|POR FORNECEDOR
        CP_0111VRF(p_emp  ,
                  p_fil  ,
                  p_opos ,
                  p_where,
                  p_con,
                  p_plano,
                  v_erro  );                  
      END IF;

   END;


                      
END CP_PAGAR_REL;
/
