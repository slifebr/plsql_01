create or replace package oc_util is

   --||
   --|| OC_UTIL.PKS : Rotinas utilitarias
   --||

   --/ variaveis publicas
   -- arrays Bi-Dimensionais
   type t_ult_cst_gr is table of dbms_sql.number_table index by binary_integer;

   type t_ult_dt_gr is table of dbms_sql.date_table index by binary_integer;

   vt_ult_cst_gr t_ult_cst_gr;
   vt_ult_dt_gr  t_ult_dt_gr;

   --------------------------------------------------------------------------------
   /*
   || Funcoes
   */
   function nome_oc(p_id oc_cliente.id%type) return oc_cliente.nome%type;
   --|----------------------------------------------------------------------------------------
   --| retorna o percentual do custo sobre o preco de venda
   --|----------------------------------------------------------------------------------------
   function fnc_fator_custo_prop(p_id oc_proposta.seq_ocprop%type) return number;
   --|----------------------------------------------------------------------------------------
   --| retorna o percentual do custo sobre o preco de venda passando o codigo do orcamento
   --|----------------------------------------------------------------------------------------
   function fnc_fator_custo_prop(p_cd oc_proposta.cd_prop%type) return number;

   --|----------------------------------------------------------------------------------------
   --| retorna  preco de venda passando o codigo do orcamento
   --|----------------------------------------------------------------------------------------
   function fnc_preco_venda_prop(p_cd oc_proposta.cd_prop%type) return number;

   --|----------------------------------------------------------------------------------------
   --| retorna o percentual do custo do produto sobre o preco de venda passando o codigo do orcamento
   --| eo item da proposta
   --|----------------------------------------------------------------------------------------
   function fnc_fator_custo_prod_prop(p_cd  oc_proposta.cd_prop%type
                                     ,p_id  oc_orcam_prod.id_orcamprod%type
                                     ,p_itm oc_orcam_prod.item%type) return number;
   --|----------------------------------------------------------------------------------------
   --| retorna o valor total de venda com impostos
   --|----------------------------------------------------------------------------------------
   function fnc_preco_cimp_prop(p_id oc_proposta.seq_ocprop%type) return number;
   --------------------------------------------------------------------------------   
   function fnc_rend_padrao(p_emp gs_param.empresa%type) return number;
   --------------------------------------------------------------------------------
   function fnc_ultimo_custo_gr(p_idx1 number
                               ,p_idx2 number) return number;

   function fnc_ultima_data_gr(p_idx1 number
                              ,p_idx2 number) return date;
   --------------------------------------------------------------------------------
   function proposta_mercado(p_merc in oc_mercado.cd_ocmerc%type)
      return oc_mercado.ult_prop%type;

   --------------------------------------------------------------------------------
   function fnc_maior_rev(p_cd oc_proposta.cd_prop %type)
      return oc_proposta.revisao%type;

   --------------------------------------------------------------------------------
   function fnc_maior_rev_orcto(p_cd oc_orcam_venda.cd_orcam%type)
      return oc_orcam_venda.rev%type;
   --------------------------------------------------------------------------------
   function fnc_checa_envio(p_seq oc_prop_item.seq_ocproit %type
                           ,p_dep varchar2) return char;
   --------------------------------------------------------------------------------

   function fnc_qtde_unid(p_seq oc_orcam_gr_prod.seq_ocorgprod%type) return number;

   --------------------------------------------------------------------------------
   function fnc_produto_pagto(p_seq     gs_preco_condpag.nr_pc_seq%type
                             ,p_seq_pag gs_preco_condpag.id%type
                             ,p_perc    gs_preco_condpag.perc%type
                             ,p_descr   gs_preco_condpag.descricao%type)
      return varchar2;

   --------------------------------------------------------------------------------
   function fnc_custo_material_orcto(p_seq oc_orcam_gr_prod.seq_ocorgprod%type)
      return number;
   --------------------------------------------------------------------------------
   function fnc_custo_mo_orcto(p_seq oc_orcam_gr_prod.seq_ocorgprod%type)
      return number;
   --------------------------------------------------------------------------------
   function fnc_qtd_hrs_orcto(p_seq oc_orcam_gr_prod.seq_ocorgprod%type)
      return number;
   --/-------------------------------------------------------------------------------------
   function fnc_descr_material_orcto(p_id oc_orcam_gr_prod.seq_ocorgprod%type)
      return varchar2;
   /*
   || Procedures
   */
   --------------------------------------------------------------------------------
   procedure ajusta_merc(p_merc in oc_mercado.cd_ocmerc%type
                        ,p_num  in oc_mercado.ult_prop%type);

   --------------------------------------------------------------------------------
   procedure prc_ultimo_gr(p_cst  number
                          ,p_dt   date
                          ,p_idx1 number
                          ,p_idx2 number);

   --------------------------------------------------------------------------------
   procedure prc_ultimo_custo(p_emp   cd_filiais.empresa%type
                             ,p_fil   cd_filiais.filial%type
                             ,p_prd   ce_produtos.produto%type
                             ,p_gr    ce_grupos.grupo%type
                             ,p_custo in out oc_orcam_gr_prod.custo_unit%type
                             ,p_dt    in out date);
   --------------------------------------------------------------------------------
   procedure prc_custo_medio_orcto(p_emp   cd_filiais.empresa%type
                                  ,p_fil   cd_filiais.filial%type
                                  ,p_prd   ce_produtos.produto%type
                                  ,p_gr    ce_grupos.grupo%type
                                  ,p_tempo number
                                  ,p_custo in out oc_orcam_gr_prod.custo_unit%type
                                  ,p_dt    in out date);
   --------------------------------------------------------------------------------
   procedure prc_custo_cotado(p_emp   cd_filiais.empresa%type
                             ,p_fil   cd_filiais.filial%type
                             ,p_prd   ce_produtos.produto%type
                             ,p_gr    ce_grupos.grupo%type
                             ,p_tp    char
                             ,p_custo out oc_orcam_gr_prod.custo_unit%type
                             ,p_dt    out date
                             ,p_tempo number);

   ----------------------------------------------------------------------------------------
   procedure gera_cliente(p_cli varchar2
                         ,p_id  out number);
   ----------------------------------------------------------------------------------------
   procedure gera_cliente(p_cli varchar2
                         ,p_cid varchar2
                         ,p_id  out number);

   ----------------------------------------------------------------------------------------
   procedure atualiza_cliente(p_id      number
                             ,p_nome    varchar2
                             ,p_cidade  varchar2
                             ,p_fone    varchar2
                             ,p_email   varchar2
                             ,p_contato varchar2);

   ----------------------------------------------------------------------------------------
   procedure gera_produto(p_descr varchar2
                          
                         ,p_id out number);

   ----------------------------------------------------------------------------------------
   procedure atualiza_produto(p_id    oc_produto.codigo%type
                             ,p_und   oc_produto.unidade%type
                             ,p_preco oc_produto.preco%type
                             ,p_peso  oc_produto.peso_esp%type);
   ----------------------------------------------------------------------------------------
   procedure gera_prod_orcto(p_descr varchar2
                            ,p_compl varchar2 default null
                            ,p_id    out number);
   ----------------------------------------------------------------------------------------
   procedure atualiza_numero_orcto(p_emp number
                                  ,p_fil number
                                  ,p_id  out number);

   ----------------------------------------------------------------------------------------
   procedure gera_preco_venda(p_emp   number
                             ,p_id    number
                             ,p_moeda varchar2);
   ----------------------------------------------------------------------------------------
   procedure atualiza_orcto(p_id number);
   ------------------------------------------------------------
   procedure efetiva_preco_orcto(p_id number);

   ------------------------------------------------------------
   procedure efetiva_preco_orcto(p_id         number
                                ,p_seq_ocprop oc_proposta.seq_ocprop%type);
   ----------------------------------------------------------------------------------------
   procedure gera_requisito(p_descr varchar2
                           ,p_id    out number);
   ----------------------------------------------------------------------------------------
   ----------------------------------------------------------------------------------------
   function status_prop(p_stat varchar2) return varchar2;
   --\-------------------------------------------------------
   --\ (P)erdido | (C)ancelado | (A)berto | (G)anho
   function situacao_prop(p_stat varchar2) return char;
   ----------------------------------------------------------------------------------------
   ----------------------------------------------------------------------------------------

   function fnc_nome_cliente_prop(p_id oc_proposta.seq_ocprop%type)
      return varchar2;
   ----------------------------------------------------------------------------------------
   function fnc_contato_cliente_prop(p_id oc_proposta.seq_ocprop%type)
      return varchar2;
   ----------------------------------------------------------------------------------------
   function fnc_contato_cliente_orcto(p_id oc_orcam_venda.id_orcamvenda%type)
      return varchar2;
   ----------------------------------------------------------------------------------------    
   ----------------------------------------------------------------------------------------
   function fnc_preco_bruto_prop(p_id oc_proposta.seq_ocprop%type) return number;
   ----------------------------------------------------------------------------------------
   function fnc_nome_cliente_solic(p_id oc_solic_orcam.id_solicorcam%type)
      return varchar2;
   --|----------------------------------------------------------------------------------------------------
   function fnc_tem_proposta(p_id  oc_orcam_venda.id_orcamvenda%type
                            ,p_rev out number)
      return oc_orcam_venda.id_orcamvenda%type;

   --|----------------------------------------------------------------------------------------
   function fnc_fator_mod_gr_evento(p_emp pp_contratos.empresa%type
                                   ,p_con pp_contratos.contrato%type
                                   ,p_cd  oc_proposta.cd_prop%type
                                   ,p_gr  cd_contrev_orcgr.grupo%type)
      return number;
   --|----------------------------------------------------------------------------------------
   function fnc_fator_mat_gr_evento(p_emp pp_contratos.empresa%type
                                   ,p_con pp_contratos.contrato%type
                                   ,p_cd  oc_proposta.cd_prop%type
                                   ,p_gr  cd_contrev_orcgr.grupo%type)
      return number;

   ----------------------------------------------------------------------------------
   procedure split_clob_modelo(p_id    oc_modelo.id%type
                              ,po_txt1 out varchar2
                              ,po_txt2 out varchar2
                              ,po_txt3 out varchar2);

   --/-------------------------------------------------------------
   function fnc_ultimo_orcto_cd(p_descr oc_produto.descr%type)
      return oc_orcam_venda.cd_orcam%type;
   --/-------------------------------------------------------------
   function fnc_ultimo_orcto_dt(p_descr oc_produto.descr%type) return date;
   --/-------------------------------------------------------------
   function fnc_ultimo_orcto_cliente(p_descr oc_produto.descr%type)
      return oc_orcam_venda.nome_cli%type;

   --|------------------------------------------------------------------------
   --| Custo total de Material e Servico
   --|------------------------------------------------------------------------
   function fnc_custo_total_material(p_id_prd oc_orcam_prod.id_orcamprod%type)
      return oc_orcam_prod.custo_prod%type;

   --|------------------------------------------------------------------------
   --| Custo total MOD
   --|------------------------------------------------------------------------
   function fnc_custo_total_mod(p_id_prd oc_orcam_prod.id_orcamprod%type)
      return oc_orcam_prod.custo_prod%type;

   --|------------------------------------------------------------------------
   --| Custo total de Material e Servico por OP/OS
   --|------------------------------------------------------------------------
   function fnc_custo_total_material_opos(p_emp  pp_ordens.empresa%type
                                         ,p_fil  pp_ordens.filial%type
                                         ,p_opos pp_ordens.ordem%type)
      return oc_orcam_prod.custo_prod%type;

   --|------------------------------------------------------------------------
   --| Custo total MOD por OP/OS
   --|------------------------------------------------------------------------
   function fnc_custo_total_mod_opos(p_emp  pp_ordens.empresa%type
                                    ,p_fil  pp_ordens.filial%type
                                    ,p_opos pp_ordens.ordem%type)
      return oc_orcam_prod.custo_prod%type;
end;
/
create or replace package body oc_util is

   --||
   --|| OC_UTIL.PKB : Rotinas utilitarias
   --||

   --------------------------------------------------------------------------------
   /*
   || Funcoes
   */

   function nome_oc(p_id oc_cliente.id%type) return oc_cliente.nome%type is
      cursor cr is
         select o.nome from oc_cliente o where o.id = p_id;
   
      v_ret oc_cliente.nome%type;
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;
   --------------------------------------------------------------------------------   
   function fnc_rend_padrao(p_emp gs_param.empresa%type) return number is
      cursor cr is
         select a.rend_hh from gs_param a where a.empresa = p_emp;
   
      v_ret number;
   begin
   
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 1);
   
   end;
   --------------------------------------------------------------------------------
   function fnc_ultimo_custo_gr(p_idx1 number
                               ,p_idx2 number) return number is
      v_cst number;
   begin
   
      v_cst := vt_ult_cst_gr(p_idx1) (p_idx2);
      --v_dt_cst  := vt_ult_dt_gr (v_idx1)(v_idx2);
      return v_cst;
   exception
      when others then
         return - 1;
   end;
   --------------------------------------------------------------------------------
   procedure prc_ultimo_custo(p_emp   cd_filiais.empresa%type
                             ,p_fil   cd_filiais.filial%type
                             ,p_prd   ce_produtos.produto%type
                             ,p_gr    ce_grupos.grupo%type
                             ,p_custo in out oc_orcam_gr_prod.custo_unit%type
                             ,p_dt    in out date) is
      cursor cr is
         select (vlr_tot_mov / qtde_mov) custo
               ,dt_mov
           from ce_movest m
          where dt_mov = (select max(dt_mov)
                            from ce_movest m2
                           where m2. produto = m.produto
                             and m2.empresa = m.empresa
                             and m2.filial = m.filial
                             and m2.cod_oper = m.cod_oper)
            and produto = p_prd
            and cod_oper = 'REM'
            and empresa = p_emp
            and filial = p_fil;
   
      type t_refcur is ref cursor;
      v_refcur t_refcur;
      v_sql    varchar2(32000);
      v_gr     varchar2(100);
   
   begin
      if p_prd is not null then
         open cr;
         fetch cr
            into p_custo
                ,p_dt;
         close cr;
      else
         v_gr := lib_cniv.cod_blank(p_gr,
                                    lib_cniv.nivel(p_gr));
         v_gr := '''' || v_gr || '%' || '''';
      
         v_sql := '	select
							  (vlr_tot_mov / qtde_mov) custo ,
								 dt_mov
						  from ce_produtos p,
								 ce_movest m
						 where m.produto = p.produto
							and m.empresa  = p.empresa
							and m.cod_oper = ''REM''
							and m.empresa  = :p_emp
							and m.filial   = :p_fil
						   and m.qtde_mov  > 0
						   and p.grupo like ' || v_gr || '
      				 order by 2 desc';
      
         open v_refcur for v_sql
            using p_emp, p_fil;
         fetch v_refcur
            into p_custo
                ,p_dt;
         close v_refcur;
      end if;
   end;
   --------------------------------------------------------------------------------

   --------------------------------------------------------------------------------
   procedure prc_custo_medio_orcto(p_emp   cd_filiais.empresa%type
                                  ,p_fil   cd_filiais.filial%type
                                  ,p_prd   ce_produtos.produto%type
                                  ,p_gr    ce_grupos.grupo%type
                                  ,p_tempo number
                                  ,p_custo in out oc_orcam_gr_prod.custo_unit%type
                                  ,p_dt    in out date) is
      cursor cr is
         select avg(vlr_tot_mov / qtde_mov) custo
               ,max(dt_mov)
           from ce_movest m
          where dt_mov between
                trunc(sysdate) - nvl(p_tempo,
                                     6) and sysdate
            and produto = p_prd
            and cod_oper = 'REM'
            and empresa = p_emp
            and filial = p_fil;
   
      type t_refcur is ref cursor;
      v_refcur t_refcur;
      v_sql    varchar2(32000);
      v_gr     varchar2(100);
      v_ini    date := add_months(trunc(sysdate),
                                  -nvl(p_tempo,
                                       6));
   
   begin
      if p_prd is not null then
         open cr;
         fetch cr
            into p_custo
                ,p_dt;
         close cr;
      else
         v_gr := lib_cniv.cod_blank(p_gr,
                                    lib_cniv.nivel(p_gr));
         v_gr := '''' || v_gr || '%' || '''';
      
         v_sql := '	select
							  avg (vlr_tot_mov / qtde_mov) custo ,
							  max( dt_mov)
						  from ce_produtos p,
								 ce_movest m
						 where m.produto = p.produto
							and m.empresa  = p.empresa
							and m.dt_mov   between :ini and sysdate
							and m.cod_oper = ''REM''
							and m.empresa  = :p_emp
							and m.filial   = :p_fil
						   and m.qtde_mov  > 0
						   and p.grupo like ' || v_gr || '
      				 ';
      
         open v_refcur for v_sql
            using v_ini, p_emp, p_fil;
         fetch v_refcur
            into p_custo
                ,p_dt;
         close v_refcur;
      end if;
   end;
   --------------------------------------------------------------------------------

   function fnc_ultima_data_gr(p_idx1 number
                              ,p_idx2 number) return date is
      v_dt date;
   begin
   
      v_dt := vt_ult_dt_gr(p_idx1) (p_idx2);
      return v_dt;
   exception
      when others then
         return null;
      
   end;

   --------------------------------------------------------------------------------
   function proposta_mercado(p_merc in oc_mercado.cd_ocmerc%type)
      return oc_mercado.ult_prop%type is
      cursor cr is
         select ult_prop from oc_mercado where cd_ocmerc = p_merc;
   
      v_ult oc_mercado.ult_prop%type;
   
      pragma autonomous_transaction;
   
   begin
      open cr;
      fetch cr
         into v_ult;
      close cr;
   
      v_ult := nvl(v_ult,
                   0) + 1;
   
      update oc_mercado set ult_prop = v_ult where cd_ocmerc = p_merc;
      commit;
   
      return v_ult;
   exception
      when others then
         rollback;
         -- raise_application_error(-20100,sqlerrm);
         return null;
   end;
   --------------------------------------------------------------------------------------
   function fnc_maior_rev(p_cd oc_proposta.cd_prop %type)
      return oc_proposta.revisao%type is
      cursor cr is
         select max(revisao) from oc_proposta where cd_prop = p_cd;
   
      v_ret oc_proposta.revisao%type;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   end;

   --------------------------------------------------------------------------------
   function fnc_maior_rev_orcto(p_cd oc_orcam_venda.cd_orcam%type)
      return oc_orcam_venda.rev%type is
      cursor cr is
         select max(rev) from oc_orcam_venda a where a.cd_orcam = p_cd;
   
      v_ret oc_orcam_venda.rev%type;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
   end;
   --------------------------------------------------------------------------------------
   function fnc_checa_envio(p_seq oc_prop_item.seq_ocproit %type
                           ,p_dep varchar2) return char is
      --/ cursores
   
      cursor creng is
         select 'S' from oc_propit_eng where seq_ocproit = p_seq;
      --/
      cursor crele is
         select 'S' from oc_propit_ele where seq_ocproit = p_seq;
      --/
      cursor crpcp is
         select 'S' from oc_propit_pcp where seq_ocproit = p_seq;
      --/
      --/variaveis
   
      v_ret char(1) := 'N';
   
      --/
   begin
      if p_dep = 'ENG' then
         open creng;
         fetch creng
            into v_ret;
         close creng;
      elsif p_dep = 'ELE' then
         open crele;
         fetch crele
            into v_ret;
         close crele;
      elsif p_dep = 'PCP' then
         open crpcp;
         fetch crpcp
            into v_ret;
         close crpcp;
      end if;
   
      return v_ret;
   
   end;
   --/-------------------------------------------------------------------------------------
   function fnc_descr_material_orcto(p_id oc_orcam_gr_prod.seq_ocorgprod%type)
      return varchar2 is
   
      cursor cr2 is
         select nvl(a.possui_dim,
                    'N') possui_dim
               ,b.descr_prod
               ,b.comprimento
               ,b.larg
               ,b.altura
               ,b.espessura
           from oc_produto       a
               ,oc_orcam_gr_prod b
          where a.codigo(+) = b.prod_orc
            and b.seq_ocorgprod = p_id;
   
      v_descr varchar2(1000);
      v_mm    varchar2(10);
      v_sep   varchar2(10);
   begin
      for reg in cr2 loop
         v_descr := reg.descr_prod;
         if reg.possui_dim = 'S' then
            v_sep := ' ';
            if reg.comprimento is not null then
               v_descr := v_descr || v_sep || reg.comprimento;
               v_sep   := ' X ';
               v_mm    := ' mm';
            end if;
            if nvl(reg.espessura,
                   0) > 0 then
               v_descr := v_descr || v_sep || reg.espessura;
               v_sep   := ' X ';
               v_mm    := ' mm';
            end if;
         
            if nvl(reg.larg,
                   0) > 0 then
               v_descr := v_descr || v_sep || reg.larg;
               v_sep   := ' X ';
               v_mm    := ' mm';
            end if;
         end if;
      end loop;
      v_descr := v_descr || v_mm;
      return v_descr;
   end;

   --------------------------------------------------------------------------------------
   function fnc_qtde_unid(p_seq oc_orcam_gr_prod.seq_ocorgprod%type) return number is
   
      cursor cr is
         select unidade
               ,peso_bruto
               ,qtde
           from oc_orcam_gr_prod
          where seq_ocorgprod = p_seq;
   
      v_unid ce_produtos.unidade%type;
      v_peso number;
      v_qtde number;
      v_ret  number;
   begin
      open cr;
      fetch cr
         into v_unid
             ,v_peso
             ,v_qtde;
      close cr;
   
      --if v_unid in ('KG','M3','M','M2','MT') THEN
      if v_unid in ('KG') then
         v_ret := v_peso;
      else
         v_ret := v_qtde;
      end if;
   
      return nvl(v_ret,
                 0);
   end;
   --------------------------------------------------------------------------------------
   procedure ajusta_merc(p_merc in oc_mercado.cd_ocmerc%type
                        ,p_num  in oc_mercado.ult_prop%type) is
      cursor cr is
         select ult_prop from oc_mercado where cd_ocmerc = p_merc;
   
      v_ult oc_mercado.ult_prop%type;
   
      pragma autonomous_transaction;
   
   begin
      open cr;
      fetch cr
         into v_ult;
      close cr;
   
      if v_ult = p_num then
         v_ult := nvl(v_ult,
                      0) - 1;
         --/
         if v_ult < 0 then
            v_ult := 0;
         end if;
         --/
         update oc_mercado set ult_prop = v_ult where cd_ocmerc = p_merc;
         commit;
      end if;
   
   exception
      when others then
         rollback;
   end;
   ------------------------------------------------------------------------------------------
   function fnc_produto_pagto(p_seq     gs_preco_condpag.nr_pc_seq%type
                             ,p_seq_pag gs_preco_condpag.id%type
                             ,p_perc    gs_preco_condpag.perc%type
                             ,p_descr   gs_preco_condpag.descricao%type)
      return varchar2 is
      cursor cr is
         select prp.produto
           from gs_preco_venda      pr
               ,gs_preco_condpag    pc
               ,gs_preco_venda_prod prp
          where pc.nr_pc_seq = p_seq
            and pc.id = p_seq_pag
            and pc.perc = p_perc
            and prp.empresa = pr.empresa
            and pr.nr_pc_seq = pr.nr_pc_seq
            and rtrim(pc.descricao) = rtrim(p_descr)
          order by pc.data_venc
                  ,pc.parcela;
   
      v_ret varchar2(100);
      v_sep varchar2(1);
   begin
   
      for reg in cr loop
         v_ret := v_ret || v_sep || reg.produto;
         v_sep := '/';
      end loop;
      return v_ret;
   
   end;
   procedure prc_ultimo_gr(p_cst  number
                          ,p_dt   date
                          ,p_idx1 number
                          ,p_idx2 number) is
   begin
   
      vt_ult_cst_gr(p_idx1)(p_idx2) := p_cst;
      vt_ult_dt_gr(p_idx1)(p_idx2) := p_dt;
   
   end;
   --------------------------------------------------------------------------------
   procedure prc_custo_cotado(p_emp   cd_filiais.empresa%type
                             ,p_fil   cd_filiais.filial%type
                             ,p_prd   ce_produtos.produto%type
                             ,p_gr    ce_grupos.grupo%type
                             ,p_tp    char
                             ,p_custo out oc_orcam_gr_prod.custo_unit%type
                             ,p_dt    out date
                             ,p_tempo number) is
   
      type t_refcur is ref cursor;
      v_refcur t_refcur;
      v_sql    varchar2(32000);
      v_gr     varchar2(100);
      v_ini    date := add_months(trunc(sysdate),
                                  -nvl(p_tempo,
                                       6));
      v_dt_txt varchar2(12) := '''' || to_char(v_ini,
                                               'dd/mm/rrrr') || '''';
      v_pl     number;
      v_pbrt   number;
      v_ord    number(3);
   
   begin
      if p_prd is null then
         v_gr := lib_cniv.cod_blank(p_gr,
                                    lib_cniv.nivel(p_gr));
         v_gr := '''' || v_gr || '%' || '''';
      end if;
   
      v_sql := ' select ';
   
      if p_tp = 'L' then
         --/ maior preco liquido cotado
      
         v_sql := v_sql || ' max(ic.preco) pliq ,
		                   c.dt_cot ';
      
      elsif p_tp = 'B' then
         --/ maior preco bruto cotado
      
         v_sql := v_sql || '
					max(decode(nvl(ic.preco_bruto,0),0, ic.preco, ic.preco_bruto) ) pbrto ,
			      c.dt_cot ';
      
      elsif p_tp = 'E' then
         --/ ultimo maior preco liquido cotado
      
         v_sql := v_sql || '    ic.preco pliq ,
		                   max(c.dt_cot) ';
      
      elsif p_tp = 'F' then
         --/ ultimo maior preco bruto cotado
      
         v_sql := v_sql || '    decode(nvl(ic.preco_bruto,0),0, ic.preco, ic.preco_bruto) pliq ,
		                   max(c.dt_cot) ';
      
      elsif p_tp = 'G' then
         --/ Media de preco liquido cotado
      
         v_sql := v_sql || '   avg( ic.preco ) pliq ,
		                      c.dt_cot ';
      else
         --'H'        --/ Media preco bruto cotado
      
         v_sql := v_sql || '   avg( decode(nvl(ic.preco_bruto,0),0, ic.preco, ic.preco_bruto)) pliq ,
		                      c.dt_cot ';
      
      end if;
      v_sql := v_sql || '
			  from co_itens_cot ic
				  , co_itens     i
				  , co_cotacao   c
			 where ic.empresa  = i.empresa
				and ic.filial   = i.filial
				and ic.num_req  = i.num_cot
				and ic.item_req = i.item_cot
				and i.empresa  = c.empresa
				and i.filial   = c.filial
				and i.num_cot  = c.num_cot ';
   
      if nvl(p_prd,
             0) > 0 then
         v_sql := v_sql || '
				and i.produto  = :p_prd ';
      else
         v_sql := v_sql || '				and p.grupo     like ' || v_gr;
      end if;
      --/
      if nvl(p_tempo,
             0) > 0 then
         v_sql := v_sql || ' and c.dt_cot  between ' || v_dt_txt ||
                  ' and  sysdate ';
      end if;
      --/
      v_sql := v_sql || '
				and c.empresa  = :p_emp
				and c.filial   = :p_fil ';
      if p_tp in ('L',
                  'B',
                  'G',
                  'H') then
         v_sql := v_sql || ' group by dt_cot
			                order by 1 desc ';
      elsif p_tp = 'E' then
         v_sql := v_sql || ' group by ic.preco
                           order by 2 desc ';
      else
         -- 'F'
         v_sql := v_sql || ' group by decode(nvl(ic.preco_bruto,0),0, ic.preco, ic.preco_bruto)
                           order by 2 desc ';
      end if;
   
      if nvl(p_prd,
             0) > 0 then
         --/
         open v_refcur for v_sql
            using p_prd, p_emp, p_fil;
         fetch v_refcur
            into p_custo
                ,p_dt;
         close v_refcur;
         --/
      else
         open v_refcur for v_sql
            using p_emp, p_fil;
         fetch v_refcur
            into p_custo
                ,p_dt;
         close v_refcur;
      end if;
   
   end;
   ----------------------------------------------------------------------------------------
   procedure gera_cliente(p_cli varchar2
                         ,p_id  out number) is
   
      pragma autonomous_transaction;
   
      v_id number(9);
   
   begin
      select oc_firmas_seq.nextval into v_id from dual;
      insert into oc_cliente
         (id
         ,nome
         ,apelido
         ,data_sis
         ,usuario)
      values
         (v_id
         ,p_cli
         ,p_cli
         ,sysdate
         ,user);
   
      --/
      insert into oc_firmas
         (firma_oc
         ,nome
         ,apelido
         ,data_sis
         ,usuario)
      values
         (v_id
         ,p_cli
         ,p_cli
         ,sysdate
         ,user);
   
      p_id := v_id;
      commit;
   end;

   ----------------------------------------------------------------------------------------
   procedure gera_cliente(p_cli varchar2
                         ,p_cid varchar2
                         ,p_id  out number) is
   
      pragma autonomous_transaction;
   
      v_id number(9);
      /*
      firmas_oc
      FIRMA_OC    NUMBER(9)          
      NOME        VARCHAR2(100)      
      APELIDO     VARCHAR2(100)      
      DATA_SIS    DATE               
      USUARIO     VARCHAR2(50)       
      ENDERECO    VARCHAR2(50)   Y   
      COMPLEMENTO VARCHAR2(50)   Y   
      BAIRRO      VARCHAR2(50)   Y   
      COD_CIDADE  NUMBER(9)      Y   
      UF          VARCHAR2(3)    Y   
      PAIS        VARCHAR2(2)    Y   
      CEP         VARCHAR2(30)   Y   
      FIRMA       NUMBER(9)      Y   
      OBS         VARCHAR2(1000) Y   
      CIDADE      VARCHAR2(30)   Y   
      */
   
   begin
      select oc_firmas_seq.nextval into v_id from dual;
      insert into oc_cliente
         (id
         ,nome
         ,apelido
         ,cidade
         ,data_sis
         ,usuario)
      values
         (v_id
         ,p_cli
         ,p_cli
         ,p_cid
         ,sysdate
         ,user);
      --/
      insert into oc_firmas
         (firma_oc
         ,nome
         ,apelido
         ,cidade
         ,data_sis
         ,usuario)
      values
         (v_id
         ,p_cli
         ,p_cli
         ,p_cid
         ,sysdate
         ,user);
   
      p_id := v_id;
      commit;
   end;

   ----------------------------------------------------------------------------------------
   procedure atualiza_cliente(p_id      number
                             ,p_nome    varchar2
                             ,p_cidade  varchar2
                             ,p_fone    varchar2
                             ,p_email   varchar2
                             ,p_contato varchar2) is
   
      pragma autonomous_transaction;
   
      v_id number(9);
      cursor cr is
         select max(indice) from oc_contatos where firma_oc = p_id;
   
      v_achou number(9);
   
   begin
   
      update oc_cliente
         set nome   = decode(p_nome,
                             null,
                             nome,
                             p_nome)
            ,cidade = decode(p_cidade,
                             null,
                             cidade,
                             p_cidade)
       where id = p_id;
      --
      open cr;
      fetch cr
         into v_achou;
      close cr;
   
      if nvl(v_achou,
             0) = 0 then
         insert into oc_contatos b
            (b.seq_contato
            ,firma_oc
            ,indice
            ,contato
            ,tipo_cont
            ,fone
            ,email)
         values
            (oc_contatos_seq.nextval
            ,p_id
            ,1
            ,p_contato
            ,'COMERCIAL'
            ,p_fone
            ,p_email);
      else
         update oc_contatos
            set fone    = decode(p_fone,
                                 null,
                                 fone,
                                 p_fone)
               ,contato = decode(p_contato,
                                 null,
                                 contato,
                                 p_contato)
               ,email   = decode(p_email,
                                 null,
                                 email,
                                 p_email)
          where firma_oc = p_id
            and indice = v_achou;
      end if;
   
      commit;
   end;

   ----------------------------------------------------------------------------------------
   procedure gera_produto(p_descr varchar2
                         ,p_id    out number) is
   
      pragma autonomous_transaction;
   
      v_id number(9);
   
   begin
      select oc_produto_seq.nextval into v_id from dual;
      insert into oc_produto
         (codigo
         ,descr
         ,tipo
         ,usu_incl
         ,dt_incl
         ,possui_dim)
      values
         (v_id
         ,p_descr
         ,'M'
         ,user
         ,sysdate
         ,'N');
      p_id := v_id;
      commit;
   end;

   ----------------------------------------------------------------------------------------
   procedure atualiza_produto(p_id    oc_produto.codigo%type
                             ,p_und   oc_produto.unidade%type
                             ,p_preco oc_produto.preco%type
                             ,p_peso  oc_produto.peso_esp%type) is
   
      pragma autonomous_transaction;
   
      cursor cr is
         select * from oc_produto a where a.codigo = p_id;
   
      v_reg oc_produto%rowtype;
      v_id  number(9);
   
   begin
      open cr;
      fetch cr
         into v_reg;
      close cr;
   
      if p_und is not null and
         p_und <> v_reg.unidade then
         v_reg.unidade := p_und;
      end if;
      if nvl(p_preco,
             0) > 0 and
         p_preco <> nvl(v_reg.preco,
                        0) then
         v_reg.preco := p_preco;
      end if;
   
      if nvl(p_peso,
             0) > 0 and
         p_preco <> nvl(v_reg.peso_esp,
                        0) then
         v_reg.peso_esp := p_peso;
      end if;
   
      update oc_produto
         set unidade  = v_reg.unidade
            ,preco    = v_reg.preco
            ,peso_esp = v_reg.peso_esp
            ,usu_alt  = user
            ,dt_alt   = sysdate
       where codigo = p_id;
   
      commit;
   
   end;

   ----------------------------------------------------------------------------------------
   procedure gera_prod_orcto(p_descr varchar2
                            ,p_compl varchar2 default null
                            ,p_id    out number) is
   
      pragma autonomous_transaction;
   
      v_id number(9);
   
   begin
      select oc_produto_seq.nextval into v_id from dual;
      insert into oc_produto
         (codigo
         ,descr
         ,complemento
         ,status
         ,tipo
         ,usu_incl
         ,dt_incl)
      values
         (v_id
         ,p_descr
         ,p_compl
         ,'A'
         ,'P'
         ,user
         ,sysdate);
      p_id := v_id;
      commit;
   end;

   ----------------------------------------------------------------------------------------
   procedure atualiza_numero_orcto(p_emp number
                                  ,p_fil number
                                  ,p_id  out number) is
      pragma autonomous_transaction;
   begin
      update oc_param a
         set a.ultimo_orc = nvl(a.ultimo_orc,
                                0) + 1
       where a.empresa = p_emp
         and a.filial = p_fil
      returning a.ultimo_orc into p_id;
   
      commit;
   
   end;
   ----------------------------------------------------------------------------------------
   procedure gera_preco_venda(p_emp   number
                             ,p_id    number
                             ,p_moeda varchar2) is
      pragma autonomous_transaction;
   
      cursor cr is
         select a.id_orcamprod
               ,a.produto_orc
               ,a.produto
               ,a.descr_prod
               ,a.qtd
           from oc_orcam_prod a
          where a.id_orcamvenda = p_id;
      --/--------------------
      v_id     number(9);
      vt_param gs_param%rowtype;
      /*
      EMPRESA       
      COD_OPER_SM   
      MARGEM_MIN    
      PC_FRETE      
      USA_PC_FRETE  
      CPMF          
      VALOR_HR      
      FATOR_METAL   
      REND_HH       
      VALIDADE_PROP 
      IR            
      DESP_COM      
      DESP_IMP      
      DESP_FAT      
      DESP_ADM      
      CONT_FABR     
      ROYALTIES     
      PERC_ISS      
      PERC_INSS     
      PERC_CSLL     
      PERC_PIS      
      PERC_COF      
      IRCSLL_MARGEM 
      */
   
   begin
      if p_id = 612 then
         --Raise_Application_Error(-20100, 'aqui');
         null;
      end if;
      --/
      begin
         select * into vt_param from gs_param a where a.empresa = p_emp;
      exception
         when others then
            raise_application_error(-20105,
                                    'Falta cadastrar parametros');
      end;
      --/
      select gs_preco_venda_seq.nextval into v_id from dual;
   
      insert into gs_preco_venda
         (empresa
         ,nr_pc_seq
         ,mercado
         ,consumidor
         ,data
         ,id_orcamvenda
         ,moeda
         ,comissao
         ,per_desp
         ,per_adm
          --,per_imposto
         ,formula_calc
         ,per_fabric
         ,per_royal
         ,per_ir)
      values
         (p_emp
         ,v_id
         ,'N'
         ,'F'
         ,trunc(sysdate)
         ,p_id
         ,p_moeda
         ,vt_param.desp_com -- comissao
         ,vt_param.desp_fin -- per_desp
         ,vt_param.desp_adm --per_adm
          -- ,vt_param.desp_imp    per_imposto
         ,'M' -- formula_calc
         ,vt_param.cont_fabr -- per_fabric
         ,vt_param.royalties --per_royal
         ,vt_param.ir);
   
      for reg in cr loop
         insert into gs_preco_venda_prod
            (empresa
            ,nr_pc_seq
            ,nr_pc_seq_pro
            ,mercado
            ,seq_ocproit
            ,produto
            ,produto_orc
            ,descr_prod
            ,custo
            ,peso
            ,qtd
            ,id_orcamprod
            ,
             --8
             margem
            ,per_iss
            ,per_pis_cofins
            ,per_csll
            ,per_inss
            ,per_ir
            ,csll_sll
            ,ir_sll
            ,per_desp_fin
            ,per_desp_adm
            ,per_desp_com
            ,per_fabric
            ,per_royal)
         values
            (p_emp
            ,v_id
            ,gs_preco_venda_prod_seq.nextval
            ,null
            ,null
            ,reg.produto
            ,reg.produto_orc
            ,reg.descr_prod
            ,null
            ,null
            ,reg.qtd
            ,reg.id_orcamprod
            ,vt_param.margem_min
            ,vt_param.perc_iss
            , -- PER_ISS       ,                
             nvl(vt_param.perc_pis,
                 0) + nvl(vt_param.perc_cof,
                          0)
            , -- PER_PIS_COFINS     ,               
             nvl(vt_param.perc_csll,
                 0)
            , -- PER_CSLL         ,             
             nvl(vt_param.perc_inss,
                 0)
            ,nvl(vt_param.ir,
                 0)
            ,vt_param.ircsll_margem
            ,vt_param.ircsll_margem
            ,vt_param.desp_fin
            ,vt_param.desp_adm
            ,vt_param.desp_com
            ,vt_param.cont_fabr
            ,vt_param.royalties);
      end loop;
   
      commit;
   end;
   ----------------------------------------------------------------------------------------
   procedure atualiza_orcto(p_id number) is
      pragma autonomous_transaction;
   
      cursor cr0 is
         select op.item
               ,op.id_orcamprod
               ,gpv.empresa
               ,op.descr_prod
               ,gpv.descr_prod descr_preco
               ,gpv.nr_pc_seq_pro
               ,op.produto_orc
               ,op.produto
               ,op.qtd
           from gs_preco_venda_prod gpv
               ,oc_orcam_prod       op
          where op.id_orcamvenda = p_id
            and gpv.id_orcamprod(+) = op.id_orcamprod
            and (gpv.empresa is null or op.descr_prod <> gpv.descr_prod);
   
      cursor cr is
         select c.id_orcamprod
               ,sum(a.custo_unit * decode(lower(a.unidade),
                                          'kg',
                                          a.peso_bruto,
                                          a.qtde) * b.qtde) custo_mp
               ,sum((case
                       when nvl(rendimento,
                                0) > 0 and
                            nvl(a.peso_liq,
                                0) = 0 then
                        a.qtde / rendimento * custo_rend
                       when nvl(rendimento,
                                0) > 0 and
                            nvl(a.peso_liq,
                                0) > 0 then
                        a.peso_liq / rendimento * custo_rend
                       else
                        0
                    end) * b.qtde) custo_mo
               ,sum(a.peso_liq * b.qtde) peso_liq
               ,sum(a.peso_bruto * b.qtde) peso_bruto
           from oc_orcam_gr_prod a
               ,oc_orcam_gr      b
               ,oc_orcam_prod    c
               ,oc_orcam_venda   d
          where a.seq_ocorcamgr = b.seq_ocorcamgr
            and b.id_orcamprod = c.id_orcamprod
            and c.id_orcamvenda = d.id_orcamvenda
            and b.secundario = 'N'
            and a.secundario = 'N'
            and d.id_orcamvenda = p_id
          group by c.id_orcamprod;
   
      cursor crv is
         select gv.nr_pc_seq
           from gs_preco_venda gv
          where gv.id_orcamvenda = p_id;
   
      v_id     number(9);
      vt_param gs_param%rowtype;
   
   begin
   
      open crv;
      fetch crv
         into v_id;
      close crv;
   
      begin
         select * into vt_param from gs_param a where a.empresa = 1;
      exception
         when others then
            raise_application_error(-20105,
                                    'Falta cadastrar parametros');
      end;
      for reg in cr0 loop
         --/
         if reg.descr_preco is null then
         
            insert into gs_preco_venda_prod
               (empresa
               ,nr_pc_seq
               ,nr_pc_seq_pro
               ,mercado
               ,seq_ocproit
               ,produto
               ,produto_orc
               ,descr_prod
               ,custo
               ,peso
               ,qtd
               ,id_orcamprod
               ,margem
               ,per_iss
               ,per_pis_cofins
               ,per_csll
               ,per_inss
               ,per_ir
               ,csll_sll
               ,ir_sll
               ,per_desp_fin
               ,per_desp_adm
               ,per_desp_com
               ,per_fabric
               ,per_royal)
            values
               (1
               ,v_id
               ,gs_preco_venda_prod_seq.nextval
               ,null
               ,null
               ,reg.produto
               ,reg.produto_orc
               ,reg.descr_prod
               ,null
               ,null
               ,reg.qtd
               ,reg.id_orcamprod
               ,vt_param.margem_min
               ,vt_param.perc_iss
               , -- PER_ISS       ,                
                nvl(vt_param.perc_pis,
                    0) + nvl(vt_param.perc_cof,
                             0)
               , -- PER_PIS_COFINS     ,               
                nvl(vt_param.perc_csll,
                    0)
               , -- PER_CSLL         ,             
                nvl(vt_param.perc_inss,
                    0)
               ,nvl(vt_param.ir,
                    0)
               ,vt_param.ircsll_margem
               ,vt_param.ircsll_margem
               ,vt_param.desp_fin
               ,vt_param.desp_adm
               ,vt_param.desp_com
               ,vt_param.cont_fabr
               ,vt_param.royalties);
         else
            update gs_preco_venda_prod v
               set descr_prod = reg.descr_prod
             where v.nr_pc_seq_pro = reg.nr_pc_seq_pro;
         
         end if;
      end loop;
      commit;
   
      for reg in cr loop
         update gs_preco_venda_prod d
            set d.peso     = reg.peso_bruto
               ,d.peso_liq = reg.peso_liq
               ,d.custo    = nvl(reg.custo_mp,
                                 0) + nvl(reg.custo_mo,
                                          0)
          where d.id_orcamprod = reg.id_orcamprod;
      end loop;
      commit;
   end;
   --|-----------------------------------------------
   procedure prc_limpa_valor(p_id number) is
      cursor crlimpa1 is
         select o.id_orcamvenda
           from gs_preco_venda v
               ,oc_orcam_venda o
          where v.nr_pc_seq = p_id
            and o.id_orcamvenda = v.id_orcamvenda;
   
      cursor crlimpa2 is
         select p.id_orcamprod
           from gs_preco_venda v
               ,oc_orcam_venda o
               ,oc_orcam_prod  p
          where v.nr_pc_seq = p_id
            and o.id_orcamvenda = v.id_orcamvenda
            and p.id_orcamvenda = o.id_orcamvenda;
   
      cursor crlimpa3 is
         select g.seq_ocorcamgr
           from gs_preco_venda v
               ,oc_orcam_venda o
               ,oc_orcam_prod  p
               ,oc_orcam_gr    g
          where v.nr_pc_seq = p_id
            and o.id_orcamvenda = v.id_orcamvenda
            and p.id_orcamvenda = o.id_orcamvenda
            and g.id_orcamprod = p.id_orcamprod;
   
      cursor crlimpa4 is
         select gp.seq_ocorgprod
           from gs_preco_venda   v
               ,oc_orcam_venda   o
               ,oc_orcam_prod    p
               ,oc_orcam_gr      g
               ,oc_orcam_gr_prod gp
          where v.nr_pc_seq = p_id
            and o.id_orcamvenda = v.id_orcamvenda
            and p.id_orcamvenda = o.id_orcamvenda
            and g.id_orcamprod = p.id_orcamprod
            and gp.seq_ocorcamgr = g.seq_ocorcamgr;
   begin
      for reg in crlimpa1 loop
         update oc_orcam_venda v
            set v.preco      = null
               ,v.custo_prod = null
               ,v.custo_mo   = null
               ,v.peso_bruto = null
               ,v.peso_liq   = null
          where v.id_orcamvenda = reg.id_orcamvenda;
      end loop;
      for reg in crlimpa2 loop
         update oc_orcam_prod v
            set v.preco      = null
               ,v.custo_prod = null
               ,v.custo_mo   = null
               ,v.peso_bruto = null
               ,v.peso_liq   = null
          where v.id_orcamprod = reg.id_orcamprod;
      end loop;
   
      for reg in crlimpa3 loop
         update oc_orcam_gr v
            set v.preco      = null
               ,v.custo_prod = null
               ,v.custo_mo   = null
               ,v.peso_bruto = null
               ,v.peso_liq   = null
          where v.seq_ocorcamgr = reg.seq_ocorcamgr;
      end loop;
      commit;
   end;
   ------------------------------------------------------------
   procedure efetiva_preco_orcto(p_id number) is
      pragma autonomous_transaction;
   
      cursor crgr is
         select a.id_orcamprod
               ,b.seq_ocorcamgr
               ,decode(a.produto,
                       null,
                       a.produto_orc,
                       a.produto) produto
               ,b.grupo
               ,a.valor_produto
               ,a.valor_produto_br
               ,a.valor_produto_liq
               ,a.custo custo_prod
               ,a.qtd
               ,b.qtde qtd_grupo
               ,sum(1 * c.peso_bruto) peso_bruto
               ,sum(1 * c.peso_liq) peso_liq
               ,round(nvl(sum(b.qtde * c.custo_unit * (c.qtde)),
                          0),
                      2) custo_prod_gr
                
               ,round(nvl(sum(b.qtde * case
                                 when nvl(rendimento,
                                          0) > 0 and
                                      nvl(c.peso_liq,
                                          0) = 0 then
                                  (c.qtde) / rendimento * custo_rend
                                 when nvl(rendimento,
                                          0) > 0 and
                                      nvl(c.peso_liq,
                                          0) > 0 then
                                  (c.peso_liq) / rendimento * custo_rend
                                 else
                                  0
                              end),
                          0),
                      2) custo_mo_gr
                
               ,(round(nvl(sum(b.qtde * c.custo_unit * (c.qtde)),
                           0),
                       2) + round(nvl(sum(b.qtde * case
                                              when nvl(rendimento,
                                                       0) > 0 and
                                                   nvl(c.peso_liq,
                                                       0) = 0 then
                                               (c.qtde) / rendimento * custo_rend
                                              when nvl(rendimento,
                                                       0) > 0 and
                                                   nvl(c.peso_liq,
                                                       0) > 0 then
                                               (c.peso_liq) / rendimento * custo_rend
                                              else
                                               0
                                           end),
                                       0),
                                   2)) custo_gr
                
               ,sum(round(nvl(sum(b.qtde * c.custo_unit * (c.qtde)),
                              0),
                          2) + round(nvl(sum(b.qtde * case
                                                when nvl(rendimento,
                                                         0) > 0 and
                                                     nvl(c.peso_liq,
                                                         0) = 0 then
                                                 (c.qtde) / rendimento * custo_rend
                                                when nvl(rendimento,
                                                         0) > 0 and
                                                     nvl(c.peso_liq,
                                                         0) > 0 then
                                                 (c.peso_liq) / rendimento * custo_rend
                                                else
                                                 0
                                             end),
                                         0),
                                     2)) over(partition by a.id_orcamprod) custo_tot_gr
           from gs_preco_venda_prod a
               ,oc_orcam_gr         b
               ,oc_orcam_gr_prod    c
          where b.id_orcamprod = a.id_orcamprod
            and b.secundario = 'N'
            and c.secundario = 'N'
            and a.nr_pc_seq = p_id
            and c.seq_ocorcamgr = b.seq_ocorcamgr
          group by a.id_orcamprod
                  ,b.seq_ocorcamgr
                  ,decode(a.produto,
                          null,
                          a.produto_orc,
                          a.produto)
                  ,b.grupo
                  ,a.valor_produto
                  ,a.valor_produto_br
                  ,a.valor_produto_liq
                  ,a.qtd
                  ,b.qtde
                  ,a.custo;
   
      cursor crprod is
         select a.id_orcamprod
               ,a.valor_produto_br
               ,a.qtd
               ,sum(b.peso_bruto * b.qtde) peso_bruto
               ,sum(b.peso_liq * b.qtde) peso_liq
               ,sum(b.custo_prod * b.qtde) custo_prod
               ,sum(b.custo_mo * b.qtde) custo_mo
               ,sum(b.preco * b.qtde) preco_prod
           from gs_preco_venda_prod a
               ,oc_orcam_gr         b
          where b.id_orcamprod = a.id_orcamprod
            and a.nr_pc_seq = p_id
            and b.secundario = 'N'
          group by a.id_orcamprod
                  ,a.valor_produto_br
                  ,a.qtd;
   
      cursor crorc is
         select b.id_orcamvenda
               ,sum(a.valor_produto_br * b.qtd) valor_produto_br
               ,sum(b.peso_bruto * b.qtd) peso_bruto
               ,sum(b.peso_liq * b.qtd) peso_liq
               ,sum(b.custo_prod * b.qtd) custo_prod
               ,sum(b.custo_mo * b.qtd) custo_mo
               ,sum(b.preco * b.qtd) preco_mo
           from gs_preco_venda_prod a
               ,oc_orcam_prod       b
          where b.id_orcamprod = a.id_orcamprod
            and a.nr_pc_seq = p_id
          group by b.id_orcamvenda;
      --|--------------------------------------------
   
      --|--------------------------------------------
      v_preco_gr number;
      v_fator_gr number;
   
      v_custo_mo_gr      number;
      v_custo_prd_gr     number;
      v_soma_preco_gr    number;
      v_id_orcamgr       number(9);
      v_valor_produto_br number;
   
      v_id_prod_ant number(9) := 0;
   begin
   
      prc_limpa_valor(p_id);
   
      for reg in crgr loop
      
         v_fator_gr         := 0;
         v_custo_mo_gr      := 0;
         v_custo_prd_gr     := 0;
         v_preco_gr         := 0;
         v_valor_produto_br := reg.valor_produto_br;
         v_id_orcamgr       := reg.seq_ocorcamgr;
      
         if nvl(reg.custo_gr,
                0) = 0 then
            raise_application_error(-20100,
                                    'OC_UTIL.EFETIVA_PRECO_ORCTO: Grupo: ' ||
                                    reg.grupo || ' do Produto: ' || reg.produto ||
                                    ' com custo 0 (zero)');
         end if;
      
         if v_id_prod_ant <> reg.id_orcamprod then
            v_id_prod_ant   := reg.id_orcamprod;
            v_soma_preco_gr := 0;
         end if;
      
         v_fator_gr      := (reg.custo_gr / reg.custo_tot_gr);
         v_custo_mo_gr   := reg.custo_mo_gr;
         v_custo_prd_gr  := reg.custo_prod_gr;
         v_preco_gr      := round(v_fator_gr * reg.valor_produto_br,
                                  2) / reg.qtd_grupo;
         v_soma_preco_gr := nvl(v_soma_preco_gr,
                                0) + v_preco_gr;
      
         if v_soma_preco_gr > reg.valor_produto_br then
            v_preco_gr := v_preco_gr - (v_soma_preco_gr - reg.valor_produto_br);
         end if;
      
         update oc_orcam_gr d
            set d.custo_prod = v_custo_prd_gr / reg.qtd_grupo
               ,d.custo_mo   = v_custo_mo_gr / reg.qtd_grupo
               ,d.preco     =
                (v_preco_gr)
               ,d.peso_bruto = reg.peso_bruto
               ,d.peso_liq   = reg.peso_liq
          where d.seq_ocorcamgr = reg.seq_ocorcamgr;
      
      end loop;
      /*
      --/ verifica se valor tem diferenca do valor final
        if v_soma_preco_gr <> v_valor_produto_br then
            --if user = 'GESTAO' then
              raise_application_error(-20101, v_preco_gr ||' - ' ||v_soma_preco_gr ||' - ' || v_valor_produto_br);
           -- end if;
      
            v_preco_gr := v_preco_gr - (v_soma_preco_gr - v_valor_produto_br); 
            Update oc_orcam_gr d
               Set d.preco      = v_preco_gr 
             Where d.seq_ocorcamgr = v_id_orcamgr;
         end if;
         */
      --/
   
      v_id_prod_ant := 0;
   
      for reg in crprod loop
         if v_id_prod_ant <> reg.id_orcamprod then
            v_id_prod_ant   := reg.id_orcamprod;
            v_soma_preco_gr := 0;
         end if;
         v_valor_produto_br := reg.valor_produto_br;
         v_preco_gr         := reg.preco_prod;
         v_soma_preco_gr    := nvl(v_soma_preco_gr,
                                   0) + (v_preco_gr * 1); --reg.qtd);
      
         if v_soma_preco_gr > reg.valor_produto_br then
            v_preco_gr := v_preco_gr - (v_soma_preco_gr - reg.valor_produto_br);
         end if;
      
         update oc_orcam_prod d
            set d.custo_prod = reg.custo_prod
               ,d.custo_mo   = reg.custo_mo
               ,d.preco      = reg.preco_prod
               ,d.peso_bruto = v_preco_gr
               ,d.peso_liq   = reg.peso_liq
          where d.id_orcamprod = reg.id_orcamprod;
      end loop;
   
      --/ verifica se valor tem diferenca do valor final
      if v_soma_preco_gr <> v_valor_produto_br then
         --if user = 'GESTAO' then
         -- raise_application_error(-20101, v_preco_gr ||' - ' ||v_soma_preco_gr ||' - ' || v_valor_produto_br);
         -- end if;
      
         v_preco_gr := v_preco_gr - (v_soma_preco_gr - v_valor_produto_br);
         update oc_orcam_prod d
            set d.preco = v_preco_gr
          where d.id_orcamprod = v_id_prod_ant;
      end if;
   
      --/      
   
      --/
      for reg in crorc loop
         update oc_orcam_venda d
            set d.custo_prod = reg.custo_prod
               ,d.custo_mo   = reg.custo_mo
               ,d.preco      = reg.valor_produto_br
               ,d.peso_bruto = reg.peso_bruto
               ,d.peso_liq   = reg.peso_liq
          where d.id_orcamvenda = reg.id_orcamvenda;
      end loop;
      --/  
      commit;
   end;

   ------------------------------------------------------------
   procedure efetiva_preco_orcto(p_id         number
                                ,p_seq_ocprop oc_proposta.seq_ocprop%type) is
      pragma autonomous_transaction;
   
      cursor crgr is
         select a.id_orcamprod
               ,b.seq_ocorcamgr
               ,decode(a.produto,
                       null,
                       a.produto_orc,
                       a.produto) produto
               ,b.grupo
               ,a.valor_produto
               ,a.valor_produto_br
               ,a.valor_produto_liq
               ,a.custo custo_prod
               ,a.qtd
               ,b.qtde qtd_grupo
               ,sum(1 * c.peso_bruto) peso_bruto
               ,sum(1 * c.peso_liq) peso_liq
               ,round(nvl(sum(b.qtde * c.custo_unit * (c.qtde)),
                          0),
                      2) custo_prod_gr
                
               ,round(nvl(sum(b.qtde * case
                                 when nvl(rendimento,
                                          0) > 0 and
                                      nvl(c.peso_liq,
                                          0) = 0 then
                                  (c.qtde) / rendimento * custo_rend
                                 when nvl(rendimento,
                                          0) > 0 and
                                      nvl(c.peso_liq,
                                          0) > 0 then
                                  (c.peso_liq) / rendimento * custo_rend
                                 else
                                  0
                              end),
                          0),
                      2) custo_mo_gr
                
               ,(round(nvl(sum(b.qtde * c.custo_unit * (c.qtde)),
                           0),
                       2) + round(nvl(sum(b.qtde * case
                                              when nvl(rendimento,
                                                       0) > 0 and
                                                   nvl(c.peso_liq,
                                                       0) = 0 then
                                               (c.qtde) / rendimento * custo_rend
                                              when nvl(rendimento,
                                                       0) > 0 and
                                                   nvl(c.peso_liq,
                                                       0) > 0 then
                                               (c.peso_liq) / rendimento * custo_rend
                                              else
                                               0
                                           end),
                                       0),
                                   2)) custo_gr
                
               ,sum(round(nvl(sum(b.qtde * c.custo_unit * (c.qtde)),
                              0),
                          2) + round(nvl(sum(b.qtde * case
                                                when nvl(rendimento,
                                                         0) > 0 and
                                                     nvl(c.peso_liq,
                                                         0) = 0 then
                                                 (c.qtde) / rendimento * custo_rend
                                                when nvl(rendimento,
                                                         0) > 0 and
                                                     nvl(c.peso_liq,
                                                         0) > 0 then
                                                 (c.peso_liq) / rendimento * custo_rend
                                                else
                                                 0
                                             end),
                                         0),
                                     2)) over(partition by a.id_orcamprod) custo_tot_gr
           from gs_preco_venda_prod a
               ,oc_orcam_gr         b
               ,oc_orcam_gr_prod    c
          where b.id_orcamprod = a.id_orcamprod
            and b.secundario = 'N'
            and c.secundario = 'N'
            and a.nr_pc_seq = p_id
            and c.seq_ocorcamgr = b.seq_ocorcamgr
          group by a.id_orcamprod
                  ,b.seq_ocorcamgr
                  ,decode(a.produto,
                          null,
                          a.produto_orc,
                          a.produto)
                  ,b.grupo
                  ,a.valor_produto
                  ,a.valor_produto_br
                  ,a.valor_produto_liq
                  ,a.qtd
                  ,b.qtde
                  ,a.custo;
   
      cursor crprod is
         select a.id_orcamprod
               ,a.valor_produto_br
               ,a.qtd
               ,decode(nvl(a.valor_produto,
                           0),
                       0,
                       round(a.valor_produto_br /
                             (nvl(a.per_ipi,
                                  0) / 100 + 1),
                             2),
                       a.valor_produto) preco_unit
               ,a.valor_produto_liq preco_unit_simp
               ,a.custo custo_unit
               ,a.per_icms aliq_icms
               ,a.per_ipi aliq_ipi
               ,a.icms icms_incl
               ,a.per_pis_cofins perc_pc
               ,a.pis_cofins piscof_incl
               ,a.per_inss perc_inss
               ,a.per_ir perc_ir
               ,a.ir_sll ir_sll
               ,a.per_iss perc_iss
               ,a.iss iss_incl
               ,a.per_csll perc_csll
               ,a.csll_sll csll_sll
               ,a.ipi ipi_incl_icms
               ,a.margem margem
               ,'S' preco_valido
               ,a.per_desp_fin per_desp_fin
               ,a.per_desp_adm per_desp_adm
               ,a.per_fabric per_fabric
               ,a.per_royal per_royal
               ,a.pis_cofins pis_cof
               ,a.per_desp_com per_desp_com
               ,a.formula_calc formula_calc
               ,sum(b.peso_bruto * b.qtde) peso_bruto
               ,sum(b.peso_liq * b.qtde) peso_liq
               ,sum(b.custo_prod * b.qtde) custo_prod
               ,sum(b.custo_mo * b.qtde) custo_mo
               ,sum(b.preco * b.qtde) preco_prod
           from gs_preco_venda_prod a
               ,oc_orcam_gr         b
          where b.id_orcamprod = a.id_orcamprod
            and a.nr_pc_seq = p_id
            and b.secundario = 'N'
          group by a.id_orcamprod
                  ,a.valor_produto_br
                  ,a.qtd
                  ,decode(nvl(a.valor_produto,
                              0),
                          0,
                          round(a.valor_produto_br /
                                (nvl(a.per_ipi,
                                     0) / 100 + 1),
                                2),
                          a.valor_produto)
                  ,a.valor_produto_br
                  ,a.valor_produto_liq
                  ,a.custo
                  ,a.per_icms
                  ,a.per_ipi
                  ,a.icms
                  ,a.per_pis_cofins
                  ,a.pis_cofins
                  ,a.per_inss
                  ,a.per_ir
                  ,a.ir_sll
                  ,a.per_iss
                  ,a.iss
                  ,a.per_csll
                  ,a.csll_sll
                  ,a.ipi
                  ,a.margem
                  ,a.per_desp_fin
                  ,a.per_desp_adm
                  ,a.per_fabric
                  ,a.per_royal
                  ,a.pis_cofins
                  ,a.per_desp_com
                  ,a.formula_calc;
      /*
         Select a.id_orcamprod
               ,a.valor_produto_br
               ,a.qtd
               ,Sum(b.peso_bruto * b.qtde) peso_bruto
               ,Sum(b.peso_liq * b.qtde) peso_liq
               ,Sum(b.custo_prod * b.qtde) custo_prod
               ,Sum(b.custo_mo * b.qtde) custo_mo
               ,Sum(b.preco * b.qtde) preco_prod
           From gs_preco_venda_prod a
               ,oc_orcam_gr         b
          Where b.id_orcamprod = a.id_orcamprod
            And a.nr_pc_seq = p_id
            And b.secundario = 'N'
          Group By a.id_orcamprod,a.valor_produto_br, a.qtd;
      */
      cursor crorc is
         select b.id_orcamvenda
               ,sum(a.valor_produto_br * b.qtd) valor_produto_br
               ,sum(b.peso_bruto * b.qtd) peso_bruto
               ,sum(b.peso_liq * b.qtd) peso_liq
               ,sum(b.custo_prod * b.qtd) custo_prod
               ,sum(b.custo_mo * b.qtd) custo_mo
               ,sum(b.preco * b.qtd) preco_mo
           from gs_preco_venda_prod a
               ,oc_orcam_prod       b
          where b.id_orcamprod = a.id_orcamprod
            and a.nr_pc_seq = p_id
          group by b.id_orcamvenda;
      --|--------------------------------------------
   
      --|--------------------------------------------
      v_preco_gr number;
      v_fator_gr number;
   
      v_custo_mo_gr      number;
      v_custo_prd_gr     number;
      v_soma_preco_gr    number;
      v_id_orcamgr       number(9);
      v_valor_produto_br number;
   
      v_id_prod_ant number(9) := 0;
   begin
   
      prc_limpa_valor(p_id);
   
      --| Grupos do Produto do Orcamento      
      for reg in crgr loop
      
         v_fator_gr         := 0;
         v_custo_mo_gr      := 0;
         v_custo_prd_gr     := 0;
         v_preco_gr         := 0;
         v_valor_produto_br := reg.valor_produto_br;
         v_id_orcamgr       := reg.seq_ocorcamgr;
      
         if nvl(reg.custo_gr,
                0) = 0 then
            raise_application_error(-20100,
                                    'OC_UTIL.EFETIVA_PRECO_ORCTO: Grupo: ' ||
                                    reg.grupo || ' do Produto: ' || reg.produto ||
                                    ' com custo 0 (zero)');
         end if;
      
         if v_id_prod_ant <> reg.id_orcamprod then
            v_id_prod_ant   := reg.id_orcamprod;
            v_soma_preco_gr := 0;
         end if;
      
         v_fator_gr      := (reg.custo_gr / reg.custo_tot_gr);
         v_custo_mo_gr   := reg.custo_mo_gr;
         v_custo_prd_gr  := reg.custo_prod_gr;
         v_preco_gr      := round(v_fator_gr * reg.valor_produto_br,
                                  2) / reg.qtd_grupo;
         v_soma_preco_gr := nvl(v_soma_preco_gr,
                                0) + v_preco_gr;
      
         if v_soma_preco_gr > reg.valor_produto_br then
            v_preco_gr := v_preco_gr - (v_soma_preco_gr - reg.valor_produto_br);
         end if;
      
         update oc_orcam_gr d
            set d.custo_prod = v_custo_prd_gr / reg.qtd_grupo
               ,d.custo_mo   = v_custo_mo_gr / reg.qtd_grupo
               ,d.preco     =
                (v_preco_gr)
               ,d.peso_bruto = reg.peso_bruto
               ,d.peso_liq   = reg.peso_liq
          where d.seq_ocorcamgr = reg.seq_ocorcamgr;
      
      end loop;
      /*
      --/ verifica se valor tem diferenca do valor final
        if v_soma_preco_gr <> v_valor_produto_br then
            --if user = 'GESTAO' then
              raise_application_error(-20101, v_preco_gr ||' - ' ||v_soma_preco_gr ||' - ' || v_valor_produto_br);
           -- end if;
      
            v_preco_gr := v_preco_gr - (v_soma_preco_gr - v_valor_produto_br); 
            Update oc_orcam_gr d
               Set d.preco      = v_preco_gr 
             Where d.seq_ocorcamgr = v_id_orcamgr;
         end if;
         */
      --/
   
      --| Produtos do Orcamento e da Proposta
      v_id_prod_ant := 0;
      for reg in crprod loop
         if v_id_prod_ant <> reg.id_orcamprod then
            v_id_prod_ant   := reg.id_orcamprod;
            v_soma_preco_gr := 0;
         end if;
         v_valor_produto_br := reg.valor_produto_br;
         v_preco_gr         := reg.preco_prod;
         v_soma_preco_gr    := nvl(v_soma_preco_gr,
                                   0) + (v_preco_gr * 1); --reg.qtd);
      
         if v_soma_preco_gr > reg.valor_produto_br then
            v_preco_gr := v_preco_gr - (v_soma_preco_gr - reg.valor_produto_br);
         end if;
      
         --| Produtos do Orcamento: 
         update oc_orcam_prod d
            set d.custo_prod = reg.custo_prod
               ,d.custo_mo   = reg.custo_mo
               ,d.preco      = reg.preco_prod
               ,d.peso_bruto = v_preco_gr
               ,d.peso_liq   = reg.peso_liq
          where d.id_orcamprod = reg.id_orcamprod;
      
         --| Produtos da Proposta: 
      
         if p_seq_ocprop is not null then
            update oc_prop_item pi
               set preco_unit      = reg.preco_unit
                  ,preco_unit_simp = reg.preco_unit_simp
                  ,custo_unit      = reg.custo_unit
                  ,aliq_icms       = reg.aliq_icms
                  ,aliq_ipi        = reg.aliq_ipi
                  ,icms_incl       = 'S' --reg.icms_incl
                  ,perc_pc         = reg.perc_pc
                  ,piscof_incl     = reg.piscof_incl
                  ,perc_inss       = reg.perc_inss
                   --                 , INSS_INCL       = reg.inss_incl
                  ,perc_ir       = reg.perc_ir
                  ,ir_sll        = reg.ir_sll
                  ,perc_iss      = reg.perc_iss
                  ,iss_incl      = reg.iss_incl
                  ,perc_csll     = reg.perc_csll
                  ,csll_sll      = reg.csll_sll
                  ,ipi_incl_icms = reg.ipi_incl_icms
                  ,margem        = reg.margem
                  ,preco_valido  = reg.preco_valido
                  ,per_desp_fin  = reg.per_desp_fin
                  ,per_desp_adm  = reg.per_desp_adm
                  ,per_fabric    = reg.per_fabric
                  ,per_royal     = reg.per_royal
                  ,pis_cof       = reg.pis_cof
                  ,per_desp_com  = reg.per_desp_com
                  ,formula_calc  = reg.formula_calc
             where pi.id_orcamprod = reg.id_orcamprod
               and pi.seq_ocprop = p_seq_ocprop;
         end if;
      
      end loop;
   
      --/ verifica se valor tem diferenca do valor final
      if v_soma_preco_gr <> v_valor_produto_br then
         --if user = 'GESTAO' then
         -- raise_application_error(-20101, v_preco_gr ||' - ' ||v_soma_preco_gr ||' - ' || v_valor_produto_br);
         -- end if;
      
         v_preco_gr := v_preco_gr - (v_soma_preco_gr - v_valor_produto_br);
         update oc_orcam_prod d
            set d.preco = v_preco_gr
          where d.id_orcamprod = v_id_prod_ant;
      end if;
   
      --/      
   
      --/ Cabecalho: orcamento
      for reg in crorc loop
         update oc_orcam_venda d
            set d.custo_prod = reg.custo_prod
               ,d.custo_mo   = reg.custo_mo
               ,d.preco      = reg.valor_produto_br
               ,d.peso_bruto = reg.peso_bruto
               ,d.peso_liq   = reg.peso_liq
          where d.id_orcamvenda = reg.id_orcamvenda;
      end loop;
      --/  
   
      commit;
   end;

   ----------------------------------------------------------------------------------------
   procedure gera_requisito(p_descr varchar2
                           ,p_id    out number) is
      pragma autonomous_transaction;
   
      v_id number(9);
   
   begin
      select oc_requisito_orc_seq.nextval into v_id from dual;
   
      insert into oc_requisito_orc
         (id_requistorc
         ,descr
         ,usu_incl
         ,dt_incl)
      values
         (v_id
         ,p_descr
         ,user
         ,sysdate);
   
      p_id := v_id;
      commit;
   end;

   --------------------------------------------------------------------------------
   function fnc_custo_material_orcto(p_seq oc_orcam_gr_prod.seq_ocorgprod%type)
      return number is
   
      cursor cr is
         select case
                   when a.unidade = 'KG' then
                    case
                       when nvl(a.peso_bruto,
                                0) > 0 then
                        a.peso_bruto * a.custo_unit
                       else
                        a.qtde * a.custo_unit
                    end
                   else
                    a.qtde * a.custo_unit
                end custo_total
           from oc_orcam_gr_prod a
         
          where a.seq_ocorgprod = p_seq;
      v_ret number;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
      return nvl(v_ret,
                 0);
   
   end;

   --------------------------------------------------------------------------------
   function fnc_custo_mo_orcto(p_seq oc_orcam_gr_prod.seq_ocorgprod%type)
      return number is
      cursor cr is
         select case
                   when nvl(rendimento,
                            0) = 0 then
                    0
                   when nvl(peso_liq,
                            0) > 0 then
                    peso_liq / rendimento
                   when nvl(qtde,
                            0) > 0 then
                    qtde / rendimento
                end * a.custo_rend
           from oc_orcam_gr_prod a
          where a.seq_ocorgprod = p_seq;
   
      v_ret number;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
      return nvl(v_ret,
                 0);
   
   end;

   --------------------------------------------------------------------------------
   function fnc_qtd_hrs_orcto(p_seq oc_orcam_gr_prod.seq_ocorgprod%type)
      return number is
      cursor cr is
         select case
                   when nvl(rendimento,
                            0) = 0 then
                    0
                   when nvl(peso_liq,
                            0) > 0 then
                    peso_liq / rendimento
                   when nvl(qtde,
                            0) > 0 then
                    qtde / rendimento
                end
           from oc_orcam_gr_prod a
          where a.seq_ocorgprod = p_seq;
   
      v_ret number;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
      return nvl(v_ret,
                 0);
   
   end;

   ----------------------------------------------------------------------------------------
   function status_prop(p_stat varchar2) return varchar2 is
      v_ret varchar2(100);
   begin
      if p_stat = 'R' then
         v_ret := 'Revisado';
      elsif p_stat = 'O' then
         v_ret := 'Orcando';
      elsif p_stat = 'P' then
         v_ret := 'Perdido';
      elsif p_stat = 'N' then
         v_ret := 'Negociada';
      elsif p_stat = 'C' then
         v_ret := 'Cancelado';
      elsif p_stat = 'D' then
         v_ret := 'Digitado';
      elsif p_stat = 'E' then
         v_ret := 'Enviado Cliente';
      elsif p_stat = 'G' then
         v_ret := 'Contrato (G)erado';
      elsif p_stat = 'S' then
         v_ret := ' OP/OS Gerado';
      else
         v_ret := 'N/A';
      end if;
   
      return v_ret;
   end;

   ----------------------------------------------------------------------------------------
   function estado_civil(p_stat varchar2) return varchar2 is
      v_ret varchar2(100);
   begin
      if p_stat = 'CA' then
         v_ret := 'Casado';
      elsif p_stat = 'O' then
         v_ret := 'Orcando';
      elsif p_stat = 'P' then
         v_ret := 'Perdido';
      elsif p_stat = 'N' then
         v_ret := 'Negociada';
      elsif p_stat = 'C' then
         v_ret := 'Cancelado';
      elsif p_stat = 'D' then
         v_ret := 'Digitado';
      elsif p_stat = 'E' then
         v_ret := 'Enviado Cliente';
      elsif p_stat = 'G' then
         v_ret := 'Contrato (G)erado';
      elsif p_stat = 'S' then
         v_ret := ' OP/OS Gerado';
      else
         v_ret := 'N/A';
      end if;
   
      return v_ret;
   end;
   --\-------------------------------------------------------
   --\ (P)erdido | (C)ancelado | (A)berto | (G)anho
   --\-------------------------------------------------------
   function situacao_prop(p_stat varchar2) return char is
      v_ret varchar2(100);
   begin
      if p_stat in ('P') then
         v_ret := 'P'; -- perdido
      elsif p_stat = 'C' then
         v_ret := 'C'; -- cancelado     
      elsif p_stat in ('O',
                       'D',
                       'E') then
         v_ret := 'A'; -- aberto
      elsif p_stat in ('N',
                       'G',
                       'S') then
         v_ret := 'G';
      else
         v_ret := 'N/A';
      end if;
   
      return v_ret;
   end;

   ----------------------------------------------------------------------------------------
   function fnc_nome_cliente_prop(p_id oc_proposta.seq_ocprop%type)
      return varchar2 is
   
      cursor cr is
         select 2 origem
               ,c.nome
           from oc_proposta p
               ,oc_cliente  c
          where c.id = p.firma_oc
            and p.seq_ocprop = p_id
         union all
         select 1 origem
               ,c.nome
           from oc_proposta p
               ,cd_firmas   c
          where c.firma = p.firma
            and p.seq_ocprop = p_id
          order by 1;
   
      v_ret varchar2(2000);
      v_aux number(9);
   begin
      open cr;
      fetch cr
         into v_aux
             ,v_ret;
      close cr;
   
      return v_ret;
   
   end;

   ----------------------------------------------------------------------------------------
   function fnc_nome_cliente_solic(p_id oc_solic_orcam.id_solicorcam%type)
      return varchar2 is
   
      cursor cr is
         select 2 origem
               ,c.nome
           from oc_solic_orcam p
               ,oc_cliente     c
          where c.id = p.firma_oc
            and p.id_solicorcam = p_id
         union all
         select 1 origem
               ,c.nome
           from oc_solic_orcam p
               ,cd_firmas      c
          where c.firma = p.firma
            and p.id_solicorcam = p_id
          order by 1;
   
      v_ret varchar2(2000);
      v_aux number(9);
   begin
      open cr;
      fetch cr
         into v_aux
             ,v_ret;
      close cr;
   
      return v_ret;
   
   end;

   ----------------------------------------------------------------------------------------
   function fnc_contato_cliente_prop(p_id oc_proposta.seq_ocprop%type)
      return varchar2 is
   
      cursor cr is
         select 2 origem
               ,c.contato
           from oc_proposta p
               ,oc_cliente  c
          where c.id = p.firma_oc
            and p.seq_ocprop = p_id
         union all
         select 1 origem
               ,cd_firmas_utl.contato(c.firma)
           from oc_proposta p
               ,cd_firmas   c
          where c.firma = p.firma
            and p.seq_ocprop = p_id
          order by 1;
   
      v_ret varchar2(2000);
      v_aux number(9);
   begin
      open cr;
      fetch cr
         into v_aux
             ,v_ret;
      close cr;
   
      return v_ret;
   
   end;

   ----------------------------------------------------------------------------------------
   function fnc_contato_cliente_orcto(p_id oc_orcam_venda.id_orcamvenda%type)
      return varchar2 is
   
      cursor cr is
         select 2 origem
               ,c.contato
           from oc_orcam_venda p
               ,oc_cliente     c
          where c.id = p.firma_orc
            and p.id_orcamvenda = p_id
         union all
         select 1 origem
               ,cd_firmas_utl.contato(c.firma)
           from oc_orcam_venda p
               ,cd_firmas      c
          where c.firma = p.firma
            and p.id_orcamvenda = p_id
          order by 1;
   
      v_ret varchar2(2000);
      v_aux number(9);
   begin
      open cr;
      fetch cr
         into v_aux
             ,v_ret;
      close cr;
   
      return v_ret;
   
   end;
   --|----------------------------------------------------------------------------------------
   --| retorna o percentual do custo sobre o preco de venda
   --|----------------------------------------------------------------------------------------
   function fnc_fator_custo_prop(p_id oc_proposta.seq_ocprop%type) return number is
   
      cursor cr is
         select sum((it.qtde * it.custo_unit) / fnc_preco_venda_prop(a.cd_prop))
                /*(sum(case when nvl(it.valor_neg,0) > 0 then
                   it.valor_neg
                else
                   (it.qtde * it.preco_unit)
                end)*/
                 * 100 fator_custo_prop
           from oc_proposta  a
               ,oc_prop_item it
          where a.seq_ocprop = p_id
            and it.seq_ocprop = a.seq_ocprop;
   
      v_ret number(15,
                   6);
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;

   --|----------------------------------------------------------------------------------------
   --| retorna  preco de venda passando o codigo do orcamento
   --|----------------------------------------------------------------------------------------
   function fnc_preco_venda_prop(p_cd oc_proposta.cd_prop%type) return number is
   
      cursor cr is
         select sum(case
                       when nvl(it.valor_neg,
                                0) > 0 then
                        it.valor_neg
                       else
                        (it.qtde * it.preco_unit)
                    end) valor_prop
           from oc_proposta  a
               ,oc_prop_item it
          where a.cd_prop = p_cd
            and it.seq_ocprop = a.seq_ocprop
            and a.revisao = (select max(a2.revisao)
                               from oc_proposta a2
                              where a2.cd_prop = a.cd_prop);
   
      v_ret number(15,
                   6);
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;
   --|----------------------------------------------------------------------------------------
   --| retorna o percentual do custo sobre o preco de venda passando o codigo do orcamento
   --|----------------------------------------------------------------------------------------
   function fnc_fator_custo_prop(p_cd oc_proposta.cd_prop%type) return number is
   
      cursor cr is
         select sum((it.qtde * it.custo_unit) / fnc_preco_venda_prop(a.cd_prop)) /*sum(sum(case when nvl(it.valor_neg,0) > 0 then
                                                                                                                                                it.valor_neg
                                                                                                                                             else
                                                                                                                                                (it.qtde * it.preco_unit)
                                                                                                                                             end)) over()*/
                * 100 fator_custo_prop
           from oc_proposta  a
               ,oc_prop_item it
          where a.cd_prop = p_cd
            and it.seq_ocprop = a.seq_ocprop
            and a.revisao = (select max(a2.revisao)
                               from oc_proposta a2
                              where a2.cd_prop = a.cd_prop);
   
      v_ret number(15,
                   6);
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;

   --|----------------------------------------------------------------------------------------
   --| retorna o percentual do custo do produto sobre o preco de venda passando o codigo do orcamento
   --|----------------------------------------------------------------------------------------
   function fnc_fator_custo_prod_prop(p_cd  oc_proposta.cd_prop%type
                                     ,p_id  oc_orcam_prod.id_orcamprod%type
                                     ,p_itm oc_orcam_prod.item%type) return number is
   
      cursor cr is
         select sum(it.qtde * it.custo_unit) /
                sum(sum(case
                           when nvl(it.valor_neg,
                                    0) > 0 then
                            it.valor_neg
                           else
                            (it.qtde * it.preco_unit)
                        end)) over() fator_custo_prop
           from oc_proposta  a
               ,oc_prop_item it
          where a.cd_prop = p_cd
            and it.seq_ocprop = a.seq_ocprop
            and (it.id_orcamprod = p_id or it.item = p_itm)
            and a.revisao = (select max(a2.revisao)
                               from oc_proposta a2
                              where a2.cd_prop = a.cd_prop);
   
      v_ret number(15,
                   6);
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;
   --|----------------------------------------------------------------------------------------
   function fnc_fator_mod_gr_evento(p_emp pp_contratos.empresa%type
                                   ,p_con pp_contratos.contrato%type
                                   ,p_cd  oc_proposta.cd_prop%type
                                   ,p_gr  cd_contrev_orcgr.grupo%type)
      return number is
   
      cursor cr is
         select sum(nvl(gr.perc_mod,
                        0))
           from cd_contrev_orcgr gr
               ,cd_contr_evenfat ev
               ,pp_contratos     pc
          where gr.grupo = p_gr
            and gr.id_conevenfat = ev.id_conevenfat
            and ev.contrato = pc.contrato
            and pc.empresa = p_emp
            and pc.contrato = p_con;
   
      cursor cr2 is
         select sum(nvl(gr.perc_mod,
                        0))
           from cd_contrev_orcgr gr
               ,cd_contr_evenfat ev
               ,pp_contratos     pc
          where gr.grupo = p_gr
            and gr.id_conevenfat = ev.id_conevenfat
            and pc.contrato = pc.contrato
            and pc.empresa = p_emp
            and pc.proposta = p_cd;
   
      v_ret number(15,
                   6);
   begin
      if p_con is not null then
         open cr;
         fetch cr
            into v_ret;
         close cr;
      else
         open cr2;
         fetch cr2
            into v_ret;
         close cr2;
      end if;
   
      return v_ret;
   
   end;

   --|----------------------------------------------------------------------------------------
   function fnc_fator_mat_gr_evento(p_emp pp_contratos.empresa%type
                                   ,p_con pp_contratos.contrato%type
                                   ,p_cd  oc_proposta.cd_prop%type
                                   ,p_gr  cd_contrev_orcgr.grupo%type)
      return number is
   
      cursor cr is
         select sum(nvl(gr.perc_mat,
                        0))
           from cd_contrev_orcgr gr
               ,cd_contr_evenfat ev
               ,pp_contratos     pc
          where gr.grupo = p_gr
            and gr.id_conevenfat = ev.id_conevenfat
            and ev.contrato = pc.contrato
            and pc.empresa = p_emp
            and pc.contrato = p_con;
   
      cursor cr2 is
         select sum(nvl(gr.perc_mat,
                        0))
           from cd_contrev_orcgr gr
               ,cd_contr_evenfat ev
               ,pp_contratos     pc
          where gr.grupo = p_gr
            and gr.id_conevenfat = ev.id_conevenfat
            and pc.contrato = pc.contrato
            and pc.empresa = p_emp
            and pc.proposta = p_cd;
   
      v_ret number(15,
                   6);
   begin
      if p_con is not null then
         open cr;
         fetch cr
            into v_ret;
         close cr;
      else
         open cr2;
         fetch cr2
            into v_ret;
         close cr2;
      end if;
   
      return v_ret;
   
   end;
   ----------------------------------------------------------------------------------------
   function fnc_preco_cimp_prop(p_id oc_proposta.seq_ocprop%type) return number is
   
      cursor cr is
         select sum(it.qtde * it.preco_unit) preco_total
           from oc_proposta  a
               ,oc_prop_item it
          where a.seq_ocprop = p_id
            and it.seq_ocprop = a.seq_ocprop;
   
      v_ret number(15,
                   2);
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;
   ----------------------------------------------------------------------------------------
   function fnc_preco_bruto_prop(p_id oc_proposta.seq_ocprop%type) return number is
   
      cursor cr is
         select sum(p.preco_unit * p.qtde)
           from oc_prop_item p
          where p.seq_ocprop = p_id;
   
      v_ret number(15,
                   2);
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;
   --|----------------------------------------------------------------------------------------------------
   function fnc_tem_proposta(p_id  oc_orcam_venda.id_orcamvenda%type
                            ,p_rev out number)
      return oc_orcam_venda.id_orcamvenda%type is
      cursor cr is
         select a.revisao
               ,a.seq_ocprop
           from oc_proposta a
          where a.id_orcamvenda = p_id
            and a.status != 'D'
            and a.revisao = (select max(a2.revisao)
                               from oc_proposta a2
                              where a2.cd_prop = a.cd_prop);
      v_ret oc_orcam_venda.id_orcamvenda%type;
   begin
      open cr;
      fetch cr
         into p_rev
             ,v_ret;
      close cr;
   
      return v_ret;
   
   end;
   ----------------------------------------------------------------------------------

   procedure split_clob_modelo(p_id    oc_modelo.id%type
                              ,po_txt1 out varchar2
                              ,po_txt2 out varchar2
                              ,po_txt3 out varchar2) is
   
      cursor cr is
         select m.complemento from oc_modelo m where m.id = p_id;
   
      v_clob clob;
   
   begin
      open cr;
      fetch cr
         into v_clob; --v_obs1, v_obs2, v_obs3;
      close cr;
   
      if dbms_lob.getlength(v_clob) > 0 then
         po_txt1 := to_char(substr(v_clob,
                                   1,
                                   4000));
         po_txt2 := to_char(substr(v_clob,
                                   4001,
                                   4000));
         po_txt3 := to_char(substr(v_clob,
                                   8001,
                                   4000));
      end if;
   
   end;
   --/-------------------------------------------------------------
   function fnc_ultimo_orcto_cd(p_descr oc_produto.descr%type)
      return oc_orcam_venda.cd_orcam%type is
   
      cursor cr is
         select v.cd_orcam
           from oc_orcam_venda   v
               ,oc_orcam_prod    p
               ,oc_orcam_gr      g
               ,oc_orcam_gr_prod gp
          where v.id_orcamvenda = p.id_orcamvenda
            and p.id_orcamprod = g.id_orcamprod
            and g.seq_ocorcamgr = gp.seq_ocorcamgr
            and gp.descr_prod = upper(trim(p_descr))
            and v.dt_orcam = (select max(v2.dt_orcam)
                                from oc_orcam_venda v2
                               where v2.cd_orcam = v.cd_orcam)
            and v.rev = (select max(v2.rev)
                           from oc_orcam_venda v2
                          where v2.cd_orcam = v.cd_orcam);
   
      v_ret oc_orcam_venda.cd_orcam%type;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;

   --/-------------------------------------------------------------
   function fnc_ultimo_orcto_dt(p_descr oc_produto.descr%type) return date is
   
      cursor cr is
         select max(v.dt_orcam)
           from oc_orcam_venda   v
               ,oc_orcam_prod    p
               ,oc_orcam_gr      g
               ,oc_orcam_gr_prod gp
          where v.id_orcamvenda = p.id_orcamvenda
            and p.id_orcamprod = g.id_orcamprod
            and g.seq_ocorcamgr = gp.seq_ocorcamgr
            and gp.descr_prod = upper(trim(p_descr))
            and v.rev = (select max(v2.rev)
                           from oc_orcam_venda v2
                          where v2.cd_orcam = v.cd_orcam);
   
      v_ret date;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;

   --/-------------------------------------------------------------
   function fnc_ultimo_orcto_cliente(p_descr oc_produto.descr%type)
      return oc_orcam_venda.nome_cli%type is
   
      cursor cr is
         select v.nome_cli
           from oc_orcam_venda   v
               ,oc_orcam_prod    p
               ,oc_orcam_gr      g
               ,oc_orcam_gr_prod gp
          where v.id_orcamvenda = p.id_orcamvenda
            and p.id_orcamprod = g.id_orcamprod
            and g.seq_ocorcamgr = gp.seq_ocorcamgr
            and gp.descr_prod = upper(trim(p_descr))
            and v.dt_orcam = (select max(v2.dt_orcam)
                                from oc_orcam_venda v2
                               where v2.cd_orcam = v.cd_orcam)
            and v.rev = (select max(v2.rev)
                           from oc_orcam_venda v2
                          where v2.cd_orcam = v.cd_orcam);
   
      v_ret oc_orcam_venda.nome_cli%type;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;
   --|------------------------------------------------------------------------
   --| Custo total de Material e Servico
   --|------------------------------------------------------------------------
   function fnc_custo_total_material(p_id_prd oc_orcam_prod.id_orcamprod%type)
      return oc_orcam_prod.custo_prod%type is
   
      cursor cr is
         select round(sum(p.qtd * gr.qtde * gpr.qtde * gpr.custo_unit),
                      2) custo_total_mp
           from oc_orcam_prod    p
               ,oc_orcam_gr      gr
               ,oc_orcam_gr_prod gpr
          where gpr.seq_ocorcamgr = gr.seq_ocorcamgr
            and gr.id_orcamprod = p.id_orcamprod
            and p.id_orcamprod = p_id_prd;
   
      v_ret oc_orcam_prod.custo_prod%type;
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
   end;

   --|------------------------------------------------------------------------
   --| Custo total MOD
   --|------------------------------------------------------------------------
   function fnc_custo_total_mod(p_id_prd oc_orcam_prod.id_orcamprod%type)
      return oc_orcam_prod.custo_prod%type is
   
      cursor cr is
         select round(sum(qtde_orcto * qtde_gr * vv.custo_hr),
                      2) custo_mo
           from (select p.qtd qtde_orcto
                       ,gr.qtde qtde_gr
                       ,gpr.qtde
                       ,gpr.unidade
                       ,gpr.custo_rend
                       ,gpr.rendimento
                       ,case
                           when nvl(gpr.rendimento,
                                    0) = 0 then
                            0
                           when nvl(gpr.peso_liq,
                                    0) > 0 then
                            nvl(gpr.peso_liq,
                                0) / gpr.rendimento
                           when nvl(gpr.qtde,
                                    0) > 0 then
                            nvl(gpr.qtde,
                                0) / gpr.rendimento
                           else
                            0
                        end qtd_hr
                       ,case
                           when nvl(gpr.rendimento,
                                    0) = 0 then
                            0
                           when nvl(gpr.peso_liq,
                                    0) > 0 then
                            nvl(gpr.peso_liq,
                                0) / gpr.rendimento
                           when nvl(gpr.qtde,
                                    0) > 0 then
                            nvl(gpr.qtde,
                                0) / gpr.rendimento
                           else
                            0
                        end * nvl(gpr.custo_rend,
                                  0) custo_hr
                   from oc_orcam_prod    p
                       ,oc_orcam_gr      gr
                       ,oc_orcam_gr_prod gpr
                  where gpr.seq_ocorcamgr = gr.seq_ocorcamgr
                    and gr.id_orcamprod = p.id_orcamprod
                    and p.id_orcamprod = p_id_prd
                 
                 ) vv;
   
      v_ret oc_orcam_prod.custo_prod%type;
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
   end;

   --|------------------------------------------------------------------------
   --| Custo total de Material e Servico por OP/OS
   --|------------------------------------------------------------------------
   function fnc_custo_total_material_opos(p_emp  pp_ordens.empresa%type
                                         ,p_fil  pp_ordens.filial%type
                                         ,p_opos pp_ordens.ordem%type)
      return oc_orcam_prod.custo_prod%type is
      
      cursor cr is
         select sum(oc_util.fnc_custo_total_material(op.seq_ocproit))
           from oc_prop_item_opos op
          where op.empresa = p_emp
            and op.filial = p_fil
            and op.opos = p_opos;
           
       v_ret oc_orcam_prod.custo_prod%type;
   begin
      open cr;
      fetch cr into v_ret;
      close cr;
      
      return v_ret;
   end;
   --|------------------------------------------------------------------------
   --| Custo total MOD por OP/OS
   --|------------------------------------------------------------------------
   function fnc_custo_total_mod_opos(p_emp  pp_ordens.empresa%type
                                    ,p_fil  pp_ordens.filial%type
                                    ,p_opos pp_ordens.ordem%type)
      return oc_orcam_prod.custo_prod%type is
      
      cursor cr is
         select sum(oc_util.fnc_custo_total_mod(op.seq_ocproit))
           from oc_prop_item_opos op
          where op.empresa = p_emp
            and op.filial = p_fil
            and op.opos = p_opos;
                 
       v_ret oc_orcam_prod.custo_prod%type;
   begin
     
      open cr;
      fetch cr into v_ret;
      close cr;
      
      return v_ret;
   end;
end oc_util;
/
