create or replace package oc_orcam is

   -------------------------------------------------------------------------------------------
   --|| OC_ORCAM.PKS : Funcoes auxiliares controle de Orcamento
   -------------------------------------------------------------------------------------------
   subtype tstring is varchar2(32000);
   -------------------------------------------------------------------------------------------
   function revisao(p_seq oc_proposta.seq_ocprop%type)
      return oc_proposta.revisao%type;
   -------------------------------------------------------------------------------------------
   function estorno_revisao(p_seq oc_proposta.seq_ocprop%type)
      return oc_proposta.seq_ocprop%type;

   -------------------------------------------------------------------------------------------
   function revisao_orcto(p_id      oc_orcam_venda.id_orcamvenda%type
                         ,p_obs_rev varchar2) return oc_orcam_venda.rev%type;
   -------------------------------------------------------------------------------------------
   function estorno_revisao_orcto(p_id oc_orcam_venda.id_orcamvenda%type)
      return oc_orcam_venda.id_orcamvenda%type;
   -------------------------------------------------------------------------------------------
   function contrato(p_emp cd_empresas.empresa%type
                    ,p_seq oc_proposta.seq_ocprop%type
                    ,p_it  oc_prop_item.seq_ocproit%type
                    ,p_td  char) return number;
   -------------------------------------------------------------------------------------------
   procedure perdida(p_seq oc_proposta.seq_ocprop%type);
   ---------------------------------------------------------------------------------------------
   procedure gerar_opos(p_emp      cd_empresas.empresa%type
                       ,p_fil      cd_filiais.filial%type
                       ,p_seq      oc_proposta.seq_ocprop%type
                       ,p_todos    char
                       ,p_montagem char);
   ---------------------------------------------------------------------------------------------
   procedure gerar_opos(p_emp cd_empresas.empresa%type
                       ,p_fil cd_filiais.filial%type
                       ,p_seq oc_proposta.seq_ocprop%type);
   ---------------------------------------------------------------------------------------------                       
   procedure gerar_opos(p_emp   cd_empresas.empresa%type
                       ,p_fil   cd_filiais.filial%type
                       ,p_seq   oc_proposta.seq_ocprop%type
                       ,p_seqit oc_prop_item.seq_ocproit%type);
   ---------------------------------------------------------------------------------------------
   procedure gerar_proposta(p_emp cd_empresas.empresa%type
                           ,p_fil cd_filiais.filial%type
                           ,p_seq oc_orcam_venda.id_orcamvenda%type);
   --|------------------------------------------------------------------
   procedure copiar_espec_tec_rev(p_cd       oc_proposta.cd_prop%type
                                 ,p_rev      oc_proposta.revisao%type
                                 ,p_item     oc_prop_item.item%type
                                 ,p_itm_dest oc_prop_item.seq_ocproit%type);
   ---------------------------------------------------------------------------------------------
   procedure copiar_inclusao_rev_s(p_cd       oc_proposta.cd_prop%type
                                  ,p_rev      oc_proposta.revisao%type
                                  ,p_item     oc_prop_item.item%type
                                  ,p_itm_dest oc_prop_item.seq_ocproit%type);
   ---------------------------------------------------------------------------------------------
   procedure copiar_exclusao_rev_s(p_cd       oc_proposta.cd_prop%type
                                  ,p_rev      oc_proposta.revisao%type
                                  ,p_item     oc_prop_item.item%type
                                  ,p_itm_dest oc_prop_item.seq_ocproit%type);
   ---------------------------------------------------------------------------------------------
   procedure copiar_inclusao_rev(p_prop oc_proposta.seq_ocprop%type
                                ,p_seq  oc_proposta.seq_ocprop%type
                                ,p_cd   oc_proposta.cd_prop%type
                                ,p_rev  oc_proposta.revisao%type);
   ---------------------------------------------------------------------------------------------
   procedure copiar_exclusao_rev(p_prop oc_proposta.seq_ocprop%type
                                ,p_seq  oc_proposta.seq_ocprop%type
                                ,p_cd   oc_proposta.cd_prop%type
                                ,p_rev  oc_proposta.revisao%type);
   --/------------------------------------------------------------------------------------------------
   procedure gerar_espec_tecnica(p_seq   oc_prop_item.seq_ocproit%type
                                ,p_idprd oc_prop_item.id_orcamprod%type);
   --/------------------------------------------------------------------
   procedure gerar_eap_op(p_emp cd_empresas.empresa%type
                         ,p_fil cd_filiais.filial%type
                         ,p_con pp_contratos.contrato%type);

   ---------------------------------------------------------------------------------------------
   procedure copiar_partes_proposta(p_prop_orig oc_proposta.seq_ocprop%type
                                   ,p_item_orig oc_prop_item.seq_ocproit%type
                                   ,p_prop_dest oc_proposta.seq_ocprop%type
                                   ,p_item_dest oc_prop_item.seq_ocproit%type
                                   ,p_parte     varchar2);
   ---------------------------------------------------------------------------------------------
   function fnc_obs(p_prop oc_proposta.seq_ocprop%type) return tstring;

   ---------------------------------------------------------------------------------------------
   procedure pl_copiar_orcto(p_id             oc_orcam_venda.id_orcamvenda%type
                            ,p_id_org         oc_orcam_venda.id_orcamvenda%type
                            ,p_id_prd_org     oc_orcam_prod.id_orcamprod%type
                            ,p_id_prd         oc_orcam_prod.id_orcamprod%type
                            ,p_copiar_produto char
                            ,p_id_grupo       oc_orcam_gr.seq_ocorcamgr%type);

   --|--------------------------------------------------------------------------
   procedure gerar_orcamento_desenho(p_idprd     oc_orcam_prod.id_orcamprod%type
                                    ,p_emp       pp_desenho.empresa%type
                                    ,p_fil       pp_desenho.filial%type
                                    ,p_des       pp_desenho.desenho%type
                                    ,p_ver       pp_desenho_ver.versao%type
                                    ,p_qtde      number
                                    ,p_grp       oc_orcam_gr.grupo%type
                                    ,p_max_filho char default 'S'
                                    ,p_opos      pp_ordens.ordem%type);
   --------------------------------------------------------------------------------------------------------------------
   --/ Atualizar proposta com textos padroes do orcamento
   --------------------------------------------------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------

   procedure atualiza_texto_padrao_prop(p_emp cd_empresas.empresa%type
                                       ,p_fil cd_filiais.filial%type
                                       ,p_seq oc_orcam_venda.id_orcamvenda%type);

   --------------------------------------------------------------------------------------------------------------------
   --/ Atualizar proposta com valores do orcamento
   --------------------------------------------------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------

   procedure atualiza_proposta_orcto(p_emp  cd_empresas.empresa%type
                                    ,p_fil  cd_filiais.filial%type
                                    ,p_seq  oc_orcam_venda.id_orcamvenda%type
                                    ,p_seqi oc_orcam_prod.id_orcamprod%type);
   --------------------------------------------------------------------------------------------------------------------
   --/ Atualizar proposta com revisao anterior
   --------------------------------------------------------------------------------------------------------------------
   procedure atualizar_proposta_com_revisao(p_emp cd_empresas.empresa%type
                                           ,p_fil cd_filiais.filial%type
                                           ,p_seq oc_proposta.seq_ocprop%type);

   --/--------------------------------------------------------------------------
   --/ GERAR TEMP RESUMO ABC DE PRODUTOS NO ORCTO
   --/--------------------------------------------------------------------------

   procedure gerar_resumo_orcto_abc(p_id  oc_orcam_venda.id_orcamvenda%type
                                   ,p_sec char default 'N');
end oc_orcam;
/
create or replace package body oc_orcam is

   -------------------------------------------------------------------------------------------
   --|| OC_PROPOSTA.PKB : Funcoes auxiliares controle de proposta
   -------------------------------------------------------------------------------------------

   -------------------------------------------------------------------------------------------
   -------------------------------------------------------------------------------------------
   function revisao(p_seq oc_proposta.seq_ocprop%type)
      return oc_proposta.revisao%type
   
      --|| Gera nova Proposta para Ajustes (Revisao)
   
    is
      cursor crorig is
         select * from oc_proposta where seq_ocprop = p_seq;
      --/
      cursor critem is
         select * from oc_prop_item i where seq_ocprop = p_seq;
   
      --/
      cursor crorc(p_it oc_prop_item.seq_ocproit%type) is
         select dt_orc_env
               ,usu_orc_env
           from oc_propit_orc
          where seq_ocproit = p_it;
      --/
      cursor creng(p_it oc_prop_item.seq_ocproit%type) is
         select dt_eng_env
               ,usu_eng_env
           from oc_propit_eng
          where seq_ocproit = p_it;
      --/
      cursor crele(p_it oc_prop_item.seq_ocproit%type) is
         select dt_ele_env
               ,usu_ele_env
           from oc_propit_ele
          where seq_ocproit = p_it;
   
      --/ estrutura
      cursor cri(p_itm oc_prop_item.seq_ocproit%type) is
         select /*seq_ocproites
                                                                                                ,seq_ocproit
                                                                                                ,item
                                                                                                ,descricao
                                                                                                ,complemento
                                                                                                ,empresa
                                                                                                ,produto
                                                                                                ,qtd
                                                                                                ,unidade
                                                                                                ,valor_unit*/
          *
           from oc_prop_item_estr a
          where a.seq_ocproit = p_itm;
      --/ Inclus?es
      cursor crin(p_itm oc_prop_item.seq_ocproit%type) is
         select /*seq_ocproitin
                                                                                                ,seq_ocproit
                                                                                                ,item
                                                                                                ,descricao
                                                                                                ,complemento
                                                                                                ,vl_incl*/
          *
           from oc_prop_item_incl a
          where a.seq_ocproit = p_itm;
   
      cursor cre(p_itm oc_prop_item.seq_ocproit%type) is
         select /*a.seq_ocproitex
                                                                                                ,seq_ocproit
                                                                                                ,item
                                                                                                ,descricao
                                                                                                ,complemento*/
          *
           from oc_prop_item_excl a
          where a.seq_ocproit = p_itm;
   
      --/---------------------------------------------------------------------
      v_revisao oc_proposta.revisao%type;
      v_seq     oc_proposta.seq_ocprop%type;
      v_item    oc_prop_item.seq_ocproit%type;
      --
   
      v_dt  date;
      v_usu oc_propit_ele.usu_ele_env%type;
      --
   begin
   
      -- Da Proposta Original
      for reg in crorig loop
      
         -- Novo Numero
         v_revisao := oc_util.fnc_maior_rev(reg.cd_prop);
      
         v_revisao := nvl(v_revisao,
                          0) + 1;
         --
      
         --
      
         -- Insere Nova Proposta
         select oc_proposta_seq.nextval into v_seq from dual;
      
         insert into oc_proposta
         values
            (v_seq
            ,reg.cd_ocmerc
            ,reg.num_prop
            ,reg.ano
            ,reg.revisao
            ,reg.cd_prop
            ,reg.dt
            ,reg.firma
            ,reg.contato
            ,'R' --reg.status
            ,reg.cd_ocforma
            ,reg.usuario
            ,reg.dt_sis
            ,reg.moeda
            ,reg.responsavel
            ,reg.mercado
            ,reg.vl_negoc
            ,reg.vl_ipi
            ,reg.seq_ocprop_or
            ,reg.dt_nec
            ,reg.dt_val
            ,reg.firma_01
            ,reg.dt_envio_cli
            ,reg.usu_envio_cli
            ,reg.dt_aprov_cli
            ,reg.usu_aprov_cli
            ,reg.tp_serv
            ,reg.obs
            ,reg.firma_oc
            ,reg.contato_oc
            ,reg.tipo_venda
            ,reg.id_orcamvenda
            ,reg.garantia
            ,reg.cond_pagto
            ,reg.cod_tec
            ,reg.cod_com
            ,reg.usu_assina
            ,reg.dt_assina
            ,reg.firma_assina
            ,reg.validade_proposta
            ,reg.obs2
            ,reg.obs3
            ,reg.dt_entrega_prop
            ,reg.usu_impr
            ,reg.dt_impr
            ,reg.usu_rev
            ,reg.dt_rev
            ,reg.obs_rev
            ,reg.verificado_rev
            ,reg.aprovado_rev
            ,reg.dt_aprov_rev
            ,reg.dt_verif_rev);
      
         --/
         --/ Itens da proposta
         --/
         for regit in critem loop
         
            select oc_prop_item_seq.nextval into v_item from dual;
         
            insert into oc_prop_item
            values
               (v_item
               ,v_seq
               ,regit.seq_ocproit
               ,regit.empresa
               ,regit.produto
               ,regit.qtde
               ,regit.status
               ,sysdate --regit.dt_sis
               ,user --regit.usu_sis
               ,regit.peso_unit
               ,regit.preco_unit
               ,regit.preco_unit_simp
               ,regit.custo_unit
               ,regit.forma_pagto
               ,regit.capacidade
               ,regit.seq_ocprop_ori
               ,regit.cd_ocmotivo
               ,null --regit.dt_aprov
               ,null --regit.usu_aprov
               ,regit.obs
               ,regit.prazo_entr
               ,regit.contrato
               ,regit.valor_neg
               ,regit.aliq_icms
               ,regit.aliq_ipi
               ,regit.descr_compl
               ,regit.tipo_frete
               ,regit.perc_frete
               ,regit.obs_frete
               ,regit.comprimento
               ,regit.largura
               ,regit.obs_entrega
               ,regit.icms_incl
               ,regit.classe
               ,regit.produto_oc
               ,regit.perc_pc
               ,regit.piscof_incl
               ,regit.perc_inss
               ,regit.inss_incl
               ,regit.perc_ir
               ,regit.ir_sll
               ,regit.perc_iss
               ,regit.iss_incl
               ,regit.perc_csll
               ,regit.csll_sll
               ,regit.perc_irrf
               ,regit.ipi_incl_icms
               ,regit.margem
               ,regit.id_orcamprod
               ,regit.cod_clafis
               ,regit.preco_valido
               ,regit.dt_contrato
               ,regit.dias_entrega
               ,regit.tipo_dias
               ,regit.per_desp_fin
               ,regit.per_desp_adm
               ,regit.per_fabric
               ,regit.per_royal
               ,regit.pis_cof
               ,regit.per_desp_com
               ,regit.formula_calc);
            --/
         
            open crorc(regit.seq_ocproit);
            fetch crorc
               into v_dt
                   ,v_usu;
            if crorc%found then
               insert into oc_propit_orc
                  (seq_ocproit
                  ,dt_orc_env
                  ,usu_orc_env)
               values
                  (v_seq
                  ,v_dt
                  ,v_usu);
            end if;
            close crorc;
            --/
            --/
            open creng(regit.seq_ocproit);
            fetch creng
               into v_dt
                   ,v_usu;
         
            if creng%found then
               insert into oc_propit_eng
                  (seq_ocproit
                  ,dt_eng_env
                  ,usu_eng_env)
               values
                  (v_seq
                  ,v_dt
                  ,v_usu);
            end if;
         
            close creng;
            --/
            --/
         
            open crele(regit.seq_ocproit);
            fetch crele
               into v_dt
                   ,v_usu;
            if crele%found then
               insert into oc_propit_ele
                  (seq_ocproit
                  ,dt_ele_env
                  ,usu_ele_env)
               values
                  (v_seq
                  ,v_dt
                  ,v_usu);
            end if;
            close crele;
            --/
            --/ ESTRUTURA
            for regest in cri(regit.seq_ocproit) loop
               insert into oc_prop_item_estr
               values
                  (oc_prop_item_estr_seq.nextval
                  ,v_item
                  ,regest.item
                  ,regest.descricao
                  ,regest.complemento
                  ,regest.empresa
                  ,regest.produto
                  ,regest.qtd
                  ,regest.unidade
                  ,regest.valor_unit);
            end loop;
            --/ INCLUSOES
            for regincl in crin(regit.seq_ocproit) loop
               insert into oc_prop_item_incl
               values
                  (oc_prop_item_incl_seq.nextval
                  ,v_item
                  ,regincl.item
                  ,regincl.descricao
                  ,regincl.complemento
                  ,regincl.vl_incl);
            end loop;
            --/ EXCLUS?ES
            for regexcl in cre(regit.seq_ocproit) loop
               insert into oc_prop_item_excl
               values
                  (oc_prop_item_excl_seq.nextval
                  ,v_item
                  ,regexcl.item
                  ,regexcl.descricao
                  ,regexcl.complemento);
            end loop;
         end loop;
      end loop;
   
      -- Atualiza Proposta
      --Update Oc_Proposta Set Status = 'R' Where Seq_Ocprop = p_Seq;
      update oc_proposta p
         set revisao       = v_revisao
            ,status        = 'D'
            ,seq_ocprop_or = v_seq
            ,p.dt_sis      = sysdate
            ,p.usuario     = user
       where seq_ocprop = p_seq;
      -- Validar
      commit;
   
      -- Retorna Numero da Revisao
      return v_revisao;
   
   end;

   -------------------------------------------------------------------------------------------
   function estorno_revisao(p_seq oc_proposta.seq_ocprop%type)
      return oc_proposta.seq_ocprop%type
   
      --|| Estorna Revis?o de proposta
   
    is
      cursor crorig is
         select seq_ocprop_or
               ,p.revisao
           from oc_proposta p
          where seq_ocprop = p_seq;
   
      --/
      cursor critem(p_seq2 oc_proposta.seq_ocprop%type) is
         select seq_ocproit from oc_prop_item where seq_ocprop = p_seq2;
   
      cursor crcopia(p_seq2 number) is
         select seq_ocprop_or from oc_proposta where seq_ocprop = p_seq2;
   
      --/
      cursor critemc(p_seq2 number) is
         select seq_ocproit from oc_prop_item where seq_ocprop = p_seq2;
      --/
   
      v_seq oc_proposta.seq_ocprop%type;
      --
      v_revisao number(10);
      v_msg     varchar2(1000);
   begin
      /*
       raise_application_error(-20100,
                               'Estorno provisoriamente suspenso!');
      */
   
      -- Da Proposta Original
      for reg in crorig loop
         if nvl(reg.revisao,
                0) = 0 then
            return 0;
         end if;
         --/ Itens da proposta
         --/
         for regit in critem(reg.seq_ocprop_or) loop
            begin
            
               delete from oc_propit_orc where seq_ocproit = regit.seq_ocproit;
               delete from oc_propit_eng where seq_ocproit = regit.seq_ocproit;
               delete from oc_propit_ele where seq_ocproit = regit.seq_ocproit;
               delete from oc_prop_item where seq_ocproit = regit.seq_ocproit;
            exception
               when others then
                  v_msg := sqlerrm;
                  raise_application_error(-20100,
                                          'Id Prop: ' || reg.seq_ocprop_or ||
                                          ' - Id Item: ' || regit.seq_ocproit ||
                                          ' - ' || v_msg);
            end;
         
         end loop;
         begin
            for reg2 in crcopia(reg.seq_ocprop_or) loop
               update oc_proposta
                  set seq_ocprop_or = reg2.seq_ocprop_or
                where seq_ocprop = p_seq;
               delete from oc_proposta where seq_ocprop = reg.seq_ocprop_or;
            end loop;
         exception
            when others then
               v_msg := sqlerrm;
               raise_application_error(-20101,
                                       'Id Prop: ' || reg.seq_ocprop_or ||
                                       ' - ' || v_msg);
         end;
      end loop;
      if nvl(v_revisao,
             0) > 0 then
         v_revisao := v_revisao - 1;
      end if;
   
      update oc_proposta
         set status  = 'D'
            ,revisao = nvl(v_revisao,
                           0)
       where seq_ocprop = p_seq;
   
      -- Validar
      commit;
   
      -- Retorna Numero da Revisao
      return v_revisao;
   
   end;

   -------------------------------------------------------------------------------------------
   function revisao_orcto(p_id      oc_orcam_venda.id_orcamvenda%type
                         ,p_obs_rev varchar2) return oc_orcam_venda.rev%type is
   
      cursor cr is
         select * from oc_orcam_venda a where a.id_orcamvenda = p_id;
   
      cursor cr2 is
         select *
           from oc_orcam_prod p
          where p.id_orcamvenda = p_id
          order by p.id_orcamprod;
   
      cursor cr3(p_prd oc_orcam_prod.id_orcamprod%type) is
         select *
           from oc_orcam_gr g
          where g.id_orcamprod = p_prd
          order by g.grupo;
   
      cursor cr4(p_gr oc_orcam_gr.seq_ocorcamgr%type) is
         select *
           from oc_orcam_gr_prod gp
          where gp.seq_ocorcamgr = p_gr
          order by gp.seq_ocorgprod;
      --/---------------------------------------------------------------------
      v_revisao oc_orcam_venda.rev%type;
      v_id      oc_orcam_venda.id_orcamvenda%type;
      v_id_prd  oc_orcam_prod.id_orcamprod%type;
      v_id_gr   oc_orcam_gr.seq_ocorcamgr%type;
   
      --
   begin
      for reg in cr loop
         -- Novo Numero
         v_revisao := oc_util.fnc_maior_rev_orcto(reg.cd_orcam);
      
         v_revisao := nvl(v_revisao,
                          0) + 1;
      
         --| altera orcamento atual para nova revisao
         update oc_orcam_venda v
            set v.rev    = v_revisao
               ,usu_incl = user
               ,dt_incl  = sysdate
               ,status   = 'D'
               ,usu_rev  = user
               ,dt_rev   = sysdate
               ,obs_rev  = p_obs_rev
          where v.id_orcamvenda = p_id;
      
         -- Insere Nova Proposta
         select oc_orcam_venda_seq.nextval into v_id from dual;
      
         -- inclusao
         insert into oc_orcam_venda
         values
            (v_id
            ,reg.cd_orcam
            ,reg.rev
            , --v_Revisao,
             reg.dt_orcam
            ,'R'
            ,reg.numero_orc
            ,reg.resp
            ,reg.firma_orc
            ,reg.firma
            ,reg.nome_cli
            ,reg.item
            ,reg.usu_incl
            ,reg.dt_incl
            ,user
            ,sysdate
            ,reg.dt_orc_rec
            ,reg.usu_orc_rec
            ,reg.dt_orc_ret
            ,reg.dt_orc_env
             
            ,reg.empresa
            ,reg.obs
            ,reg.custo_prod
            ,reg.custo_mo
            ,reg.preco
            ,reg.peso_bruto
            ,reg.peso_liq
             
            ,reg.id_solicorcam
            ,reg.dt_entrega_prop
            ,reg.usu_cancel
            ,reg.dt_cancel
            ,reg.obs_cancel
            ,reg.orcamentista
            ,reg.usu_rev
            ,reg.dt_rev
            ,reg.obs_rev);
      
         for reg2 in cr2 loop
         
            select oc_orcam_prod_seq.nextval into v_id_prd from dual;
         
            insert into oc_orcam_prod
            values
               (v_id_prd
               ,v_id
               ,reg2.status
               ,reg2.descr_prod
               ,reg2.produto_orc
               ,reg2.empresa
               ,reg2.produto
               ,reg2.qtd
               ,reg2.custo_prod
               ,reg2.preco
               ,reg2.usu_incl
               ,reg.dt_incl
               ,reg2.usu_alt
               ,reg2.dt_alt
               ,reg2.custo_mo
               ,reg2.peso_bruto
               ,reg2.peso_liq
               ,reg2.id_orcamprod
               ,reg2.item
               ,reg2.id_solicorcprod);
         
            for reg3 in cr3(reg2.id_orcamprod) loop
            
               select oc_orcam_gr_seq.nextval into v_id_gr from dual;
            
               insert into oc_orcam_gr
               values
                  (v_id_gr
                  ,reg3.grupo
                  ,reg3.descr
                  ,reg3.classe
                  ,reg3.empresa
                  ,reg3.filial
                  ,reg3.desenho
                  ,reg3.versao
                  ,reg3.seq_ocorcamgr_01
                  ,v_id_prd
                  , --ID_ORCAMPROD     ,
                   reg3.obs
                  ,reg3.eap
                  ,reg3.secundario
                  ,reg3.custo_prod
                  ,reg3.custo_mo
                  ,reg3.preco
                  ,reg3.peso_bruto
                  ,reg3.peso_liq
                  ,reg3.seq_ocorcamgr
                  ,reg3.qtde);
            
               for reg4 in cr4(reg3.seq_ocorcamgr) loop
                  insert into oc_orcam_gr_prod
                  values
                     (oc_orcam_gr_prod_seq.nextval
                     ,v_id_gr
                     ,reg4.empresa
                     ,reg4.produto
                     ,reg4.unidade
                     ,reg4.qtde
                     ,reg4.peso_liq
                     ,reg4.peso_bruto
                     ,reg4.fator
                     ,reg4.manual
                     ,reg4.custo_unit
                     ,reg4.dt_custo
                     ,reg4.origem
                     ,reg4.rendimento
                     ,reg4.custo_rend
                     ,reg4.grupo
                     ,reg4.tp_custo
                     ,reg4.descr_prod
                     ,reg4.prod_orc
                     ,reg4.secundario
                     ,reg4.perc_recupev
                     ,reg4.vl_recupev
                     ,reg4.comprimento
                     ,reg4.larg
                     ,reg4.peso_esp
                     ,reg4.qtd_pc
                     ,reg4.diam_int
                     ,reg4.diam_ext
                     ,reg4.usu_incl
                     ,reg4.dt_incl
                     ,reg4.usu_alt
                     ,reg4.dt_alt
                     ,reg4.altura
                     ,reg4.espessura
                     ,reg4.custo_unit_cimp
                     ,reg4.aliq_icms
                     ,reg4.aliq_ipi
                     ,reg4.aliq_piscof
                     ,reg4.aliq_cof
                     ,reg4.seq_ocorgprod_rev
                     ,reg4.item
                     ,reg4.id_octipoprod);
               end loop; --/ material
            end loop; --/ grupo
         end loop; --/ produto pa
      
      end loop; --/ cabec_orcto
   
      /* posicionado para nates da inclusao
      --| altera orcamento atual para nova revisao
      Update Oc_Orcam_Venda v
         Set v.Rev     = v_Revisao
             ,Usu_Incl = User
             ,Dt_Incl  = Sysdate
             ,Status   = 'D'
       Where v.Id_Orcamvenda = p_Id;
      */
      --   UPDATE OC_ORCAM_VENDA V
      --     SET REV = V_REVISAO - 1
      --  WHERE V.iD_ORCAMVENDA = p_ID;
      /*
         --| MUDA ID DE PRECO VENDA PARA ID DA REVISAO ANTERIOR
         UPDATE Gs_Preco_Venda v
            set v.id_orcamvenda = v_id
          where v.id_orcamvenda = p_id;
      
         --| MUDA ID DE proposta PARA ID DA REVISAO ANTERIOR
         UPDATE oc_proposta v
            set v.id_orcamvenda = v_id
          where v.id_orcamvenda = p_id;
      */
      commit;
      return v_revisao;
   end;
   -------------------------------------------------------------------------------------------
   function estorno_revisao_orcto(p_id oc_orcam_venda.id_orcamvenda%type)
      return oc_orcam_venda.id_orcamvenda%type is
   
      cursor cr is
         select vc.id_orcamvenda
               ,vc.cd_orcam
               ,vc.rev
               ,v.rev rev_atual
           from oc_orcam_venda v
               ,oc_orcam_venda vc
          where v.id_orcamvenda = p_id --5642
            and vc.cd_orcam = v.cd_orcam
            and vc.rev = (select max(v2.rev)
                            from oc_orcam_venda v2
                           where v2.cd_orcam = v.cd_orcam
                             and v2.rev < v.rev);
   
      cursor cr2(pl_id number) is
         select *
           from oc_orcam_prod p
          where p.id_orcamvenda = pl_id
          order by p.id_orcamprod;
   
      cursor cr3(p_prd oc_orcam_prod.id_orcamprod%type) is
         select *
           from oc_orcam_gr g
          where g.id_orcamprod = p_prd
          order by g.grupo;
   
      cursor cr4(p_gr oc_orcam_gr.seq_ocorcamgr%type) is
         select *
           from oc_orcam_gr_prod gp
          where gp.seq_ocorcamgr = p_gr
          order by gp.seq_ocorgprod;
   
      v_rev_atual number(9);
   
   begin
      /*
      raise_application_error(-20100,
                              'Estorno provisoriamente suspenso!');
      */
      for reg in cr loop
      
         v_rev_atual := reg.rev_atual;
      
         for reg2 in cr2(reg.id_orcamvenda) loop
            for reg3 in cr3(reg2.id_orcamprod) loop
            
               for reg4 in cr4(reg3.seq_ocorcamgr) loop
                  delete from oc_orcam_gr_prod a
                   where a.seq_ocorcamgr = reg4.seq_ocorcamgr;
               end loop;
            
               delete from oc_orcam_gr a
                where a.seq_ocorcamgr = reg3.seq_ocorcamgr;
            end loop;
         
            --\ excluir formacao de preco (itens)
            delete from gs_preco_venda_prod gpv
             where gpv.nr_pc_seq =
                   (select vp.nr_pc_seq
                      from gs_preco_venda vp
                     where vp.id_orcamvenda = reg.id_orcamvenda) -- 5850
               and gpv.id_orcamprod = reg2.id_orcamprod;
         
            delete from oc_orcam_prod a
             where a.id_orcamprod = reg2.id_orcamprod;
         
         end loop;
         --\ excluir formacao de preco (cabecalho)         
         delete from gs_preco_venda vp
          where vp.id_orcamvenda = reg.id_orcamvenda;
      
         delete from oc_orcam_venda a
          where a.id_orcamvenda = reg.id_orcamvenda;
      end loop;
   
      if nvl(v_rev_atual,
             0) > 0 then
         update oc_orcam_venda v
            set v.rev = v.rev - 1
          where v.id_orcamvenda = p_id;
      end if;
   
      commit;
   
      return p_id;
      /*17/12/2013
      Exception
         When Others Then
            Return 0;
      */
   end;
   -------------------------------------------------------------------------------------------
   function contrato(p_emp cd_empresas.empresa%type
                    ,p_seq oc_proposta.seq_ocprop%type
                    ,p_it  oc_prop_item.seq_ocproit%type
                    ,p_td  char) return number
   
      -- Encerra Proposta e Gera Contrato
    is
   
      cursor crorig is
         select a.seq_ocprop
               ,a.cd_ocmerc
               ,a.num_prop
               ,a.ano
               ,a.revisao
               ,a.cd_prop
               ,null pcpra_cli
               ,a.dt
               ,a.firma
               ,a.contato
               ,a.cd_ocforma
               ,a.tipo_venda
               ,a.moeda
               ,a.responsavel
               ,a.mercado
               ,a.dt_nec
               ,a.dt_val
               ,a.firma_01
               ,a.tp_serv
               ,a.obs obs_oc
               ,a.firma_oc
               ,a.contato_oc
               ,sum(nvl(b.peso_unit,
                        0)) peso_unit
               ,max(trunc(b.dt_aprov)) dt_aprov
               ,null obs
               ,max(b.prazo_entr) prazo_entr
               ,sum(b.valor_neg) valor_neg
               ,sum((nvl(b.aliq_icms,
                         0) * b.valor_neg / 100)) valor_icms
               ,sum((nvl(b.aliq_ipi,
                         0) * b.valor_neg / 100)) valor_ipi
         
           from oc_proposta  a
               ,oc_prop_item b
          where a.seq_ocprop = b.seq_ocprop
            and b.seq_ocprop = p_seq
            and ((p_td = 'N' and b.seq_ocproit = p_it) or
                (p_td = 'S' and nvl(b.valor_neg,
                                     0) > 0))
          group by a.seq_ocprop
                  ,a.cd_ocmerc
                  ,a.num_prop
                  ,a.ano
                  ,a.revisao
                  ,a.cd_prop
                  ,a.dt
                  ,a.firma
                  ,a.contato
                  ,a.cd_ocforma
                  ,a.tipo_venda
                  ,a.moeda
                  ,a.responsavel
                  ,a.mercado
                  ,a.dt_nec
                  ,a.dt_val
                  ,a.firma_01
                  ,a.tp_serv
                  ,a.obs
                  ,a.firma_oc
                  ,a.contato_oc;
   
      cursor curparam(pc_emp pp_param.empresa%type) is
         select ult_contrato from pp_param where empresa = pc_emp;
   
      cursor cr_merc(sigla pp_mercado.sigla%type) is
         select a.seq from pp_mercado a where a.sigla = sigla;
   
      v_merc      number(9);
      v_contrato  pp_param.ult_contrato%type;
      v_vl_ipi    number(15,
                         2);
      v_vl_icms   number(15,
                         2);
      v_valor_neg number(15,
                         2);
   begin
      -- Da Proposta Original
      for reg in crorig loop
      
         -- Localiza Ultimo Numero de Contrato no Cursor
         open curparam(p_emp);
         fetch curparam
            into v_contrato;
         if curparam%notfound then
            close curparam;
            raise_application_error(-20100,
                                    'falta parametro ultimo numero de contrato');
         end if;
         close curparam;
      
         --| Passa ultimo nro do contrato + 1 para tabela de contratos
         v_contrato := nvl(v_contrato,
                           0) + 1;
      
         --| Atualiza numero do ultimo contrato
         update pp_param
            set ult_contrato = nvl(v_contrato,
                                   0)
          where empresa = p_emp;
      
         --/MERCADO
         open cr_merc(reg.mercado);
         fetch cr_merc
            into v_merc;
         close cr_merc;
      
         v_valor_neg := nvl(reg.valor_neg,
                            0);
         v_vl_ipi    := nvl(reg.valor_ipi,
                            0);
         v_vl_icms   := nvl(reg.valor_icms,
                            0);
      
         -- Insere Contrato
         insert into pp_contratos
            (empresa
            ,contrato
            ,firma
            ,proposta
            ,prazo
            ,resp_venda
            ,coordenador
            ,anexo_conf
            ,anexo_publ
            ,anexo_obrig
            ,encerramento
            ,usr_encerramento
            ,cotacao_venda
            ,moeda
            ,pcpra_cli
            ,tpprazo
            ,seq_mercado
            ,vl_negoc
            ,vl_ipi
            ,vl_icms
            ,vl_desc
            ,vl_serv
            ,tp_serv
            ,obs
            ,dt
            ,usu_incl
            ,dt_incl)
         values
            (p_emp
            ,v_contrato
            ,reg.firma
            ,reg.cd_prop
            ,null
            ,reg.responsavel
            ,null
            ,null
            ,null
            ,null
            ,null
            ,null
            ,null
            ,reg.moeda
            ,reg.pcpra_cli
             
            ,null
            ,v_merc
            ,reg.valor_neg
            ,v_vl_ipi
            ,v_vl_icms
            ,null
            ,null
            ,reg.tp_serv
            ,reg.obs
            ,reg.dt_aprov
            ,user
            ,sysdate);
      
      end loop;
      commit;
   
      -- Atualiza Proposta
      update oc_proposta
         set status        = 'N'
            ,dt_aprov_cli  = sysdate
            ,usu_aprov_cli = user
            ,vl_negoc      = nvl(vl_negoc,
                                 0) + v_valor_neg
            ,vl_ipi        = nvl(vl_ipi,
                                 0) + v_vl_ipi
       where seq_ocprop = p_seq;
      if p_td = 'N' then
         update oc_prop_item
            set status   = 'G'
               ,contrato = v_contrato
          where seq_ocproit = p_it;
      else
         update oc_prop_item a
            set status   = 'G'
               ,contrato = v_contrato
          where a.seq_ocprop = p_seq
            and nvl(a.valor_neg,
                    0) > 0;
      end if;
   
      --atualiza eventos gerados pela proposta
      update cd_contr_evenfat a
         set a.contrato = v_contrato
            ,a.empresa  = p_emp
       where a.seq_ocprop = p_seq;
   
      --atualiza cronograma financeiro gerados pela proposta     
      update cd_contratos_cron a
         set a.contrato = v_contrato
            ,a.empresa  = p_emp
       where a.seq_ocprop = p_seq;
   
      -- Validar
      commit;
   
      -- Retorna Numero do contrato
      return v_contrato;
   
   end;

   -------------------------------------------------------------------------------------------
   procedure perdida(p_seq oc_proposta.seq_ocprop%type)
   
      --|| Registra a Perda do Negocio
   
    is
   
   begin
   
      -- Atualiza Proposta
      update oc_proposta
         set status        = 'P'
            ,dt_aprov_cli  = sysdate
            ,usu_aprov_cli = user
       where seq_ocprop = p_seq;
   
      -- Validar
      commit;
   
   end;
   ---------------------------------------------------------------------------------------------
   procedure gerar_opos_montagem(p_emp      cd_empresas.empresa%type
                                ,p_fil      cd_filiais.filial%type
                                ,p_seq      oc_proposta.seq_ocprop%type
                                ,p_contrato pp_contratos.contrato%type) is
   --/ contrato
   cursor cr is
    select a.seq_ocprop
      ,b.seq_ocproit
      ,b.contrato
      , a.cd_ocmerc mercado
      ,3 classe  --/ MONTAGEM NO CAMPO
      ,27752 produto
      ,'MONTAGEM MECANICA' descricao
      ,sum(b.qtde * (nvl(b.peso_unit,
                         0))) peso
      ,max(trunc(b.dt_aprov)) dt_aprov
      ,max(b.prazo_entr) prazo_entr
      

  from oc_proposta  a
      ,oc_prop_item b
      ,oc_produto   c
 where a.seq_ocprop = b.seq_ocprop
   and b.seq_ocprop = p_seq
   and b.contrato  = P_CONTRATO
   and c.codigo(+) = b.produto_oc
   GROUP BY a.seq_ocprop
      ,b.seq_ocproit
      ,b.contrato
      , a.cd_ocmerc;
          
   --/ cursor gera codigo op/os incrementa por classe
      cursor cr2(p_cl number) is
         select max(nvl(to_number(substr(ordem,
                                         6,
                                         3)),
                        0)) conta
           from pp_ordens
          where substr(ordem,
                       1,
                       1) = p_cl;
      
      --/origem
      cursor cr3 is
         select firma from cd_firmas where usuario = user;
   
      --/ variaveis
      v_msk_titulo pp_ordens.msk_titulo%type;
      v_opos       pp_ordens.ordem%type;
      v_tipo       pp_ordens.tipo%type;
      v_versao     cg_ccusto.versao%type;
      v_ccusto     cg_ccusto.ccusto%type;
      v_espec      pp_ordens.especif_serv%type;
      v_conta      number(3);
      v_origem     number(9);
      v_gerou_op   boolean;
   
   begin
      v_tipo       := 'S';
      v_versao     := 1;
      v_ccusto     := '5.01';
      v_msk_titulo := '9.99.99.99';
      v_espec      := 'F';
   
      open cr3;
      fetch cr3
         into v_origem;
      close cr3;
     
      for reg in cr loop
      --/definição do numero da op
       
         open cr2(reg.classe);
         fetch cr2
            into v_conta;
         close cr2;
      
         v_opos := reg.classe || '.' || to_char(reg.dt_aprov,
                                                'rr') || '.' ||
                   lpad(nvl(v_conta,
                            0) + 1,
                        3,
                        '0');

      --Raise_Application_Error(-20101, v_Opos);
      insert into pp_ordens
         (empresa
         ,filial
         ,ordem
         ,numero
         ,tipo
         ,produto
         ,contrato
         ,descricao
         ,criacao
         ,quantidade
         ,origem
         ,peso
         ,usr_criacao
         ,encerramento
         ,usr_encerramento
         ,data_entrega
         ,peso_entrega
         ,vl_total
         ,vl_ordem
         ,vl_ipi
         ,vl_icms
         ,vl_iss
         ,vl_pis
         ,vl_cofins
         ,vl_ret_inss
         ,msk_titulo
         ,grupov
         ,status
         ,vl_comissao
         ,especif_serv
         ,data_contratual
         ,vl_ret_irrf
         ,vl_ret_csll
         ,vl_ret_pis
         ,vl_ret_cofins
         ,area_res
         ,est_cred
         ,prazo_fabrica
         ,ordem01
         ,versao
         ,ccusto
         ,recnoib
         ,tipox
         ,fator_unv
         )
      values
         (p_emp
         ,p_fil
         ,v_opos
         ,v_opos
         ,v_tipo
         ,reg.produto
         ,p_contrato
         ,substr(reg.descricao,
                 1,
                 200)
         ,trunc(sysdate)
         ,1 --reg.qtde
         ,v_origem
         ,0 --peso
         ,user
         ,null
         ,null
         ,reg.prazo_entr
         ,round(reg.peso,
                3)
         ,0
         ,0
         ,0
         ,0
         ,null
         ,null
         ,null
         ,null
         ,v_msk_titulo
         ,reg.mercado
         ,'A'
         ,null
         ,v_espec
         ,reg.dt_aprov
         ,null
         ,null
         ,null
         ,null
         ,null
         ,null
         ,reg.prazo_entr
         ,null
         ,v_versao
         ,v_ccusto
         ,null
         ,'M'
         ,round(reg.peso,
                3)
         );
      --/

   

     end loop;
   end;
   ---------------------------------------------------------------------------------------------
   procedure gerar_opos(p_emp      cd_empresas.empresa%type
                       ,p_fil      cd_filiais.filial%type
                       ,p_seq      oc_proposta.seq_ocprop%type
                       ,p_todos    char
                       ,p_montagem char)
   
      --
    is
   
      cursor cr is
         select a.seq_ocprop
               ,b.seq_ocproit
               ,a.cd_ocmerc
               ,a.num_prop
               ,b.contrato
               ,a.ano
               ,a.revisao
               ,a.cd_prop
               ,a.dt
               ,a.firma
               ,a.contato
               ,a.cd_ocforma
               ,a.tipo_venda
               ,a.moeda
               ,
                --10001 Origem,
                a.cd_ocmerc mercado
               ,a.dt_nec
               ,a.dt_val
               ,a.firma_01
               ,a.tp_serv
               ,a.obs obs_oc
               ,a.firma_oc
               ,a.contato_oc
               ,b.classe
               ,b.empresa
               ,case
                   when nvl(b.produto,
                            0) > 0 then
                    b.produto
                   else
                    c.produto
                end produto
               ,b.descr_compl descricao
               ,b.qtde
               ,b.qtde * (nvl(b.peso_unit,
                              0)) peso
               ,
                
                (trunc(b.dt_aprov)) dt_aprov
               ,(b.prazo_entr) prazo_entr
               ,(b.valor_neg) valor_neg
               ,((nvl(b.aliq_icms,
                      0) * b.valor_neg / 100)) valor_icms
               ,((nvl(b.aliq_ipi,
                      0) * b.valor_neg / 100)) valor_ipi
               ,b.perc_ir
               ,b.perc_inss
               ,b.perc_pc
               ,b.perc_iss
               ,b.perc_csll
               ,b.perc_irrf
               ,b.obs
           from oc_proposta  a
               ,oc_prop_item b
               ,oc_produto   c
          where a.seq_ocprop = b.seq_ocprop
            and b.seq_ocprop = p_seq
            and b.contrato is not null
            and b.status <> 'S'
            and c.codigo(+) = b.produto_oc
          order by b.item;
   
      --/ cursor gera codigo op/os incrementa por classe/ano
      cursor cr1(p_cl  number
                ,p_ano varchar2) is
         select substr(ordem,
                       1,
                       1) || '.' || lpad(substr(ordem,
                                                3,
                                                2),
                                         2,
                                         '0') || '.' ||
                lpad(nvl(max(to_number(substr(ordem,
                                              6,
                                              3))),
                         0) + 1,
                     3,
                     '0') conta
           from pp_ordens
          where substr(ordem,
                       1,
                       1) = p_cl
            and substr(ordem,
                       3,
                       2) = p_ano
          group by substr(ordem,
                          1,
                          1)
                  ,substr(ordem,
                          3,
                          2);
   
      --/ cursor gera codigo op/os incrementa por classe
      cursor cr2(p_cl number) is
         select max(nvl(to_number(substr(ordem,
                                         6,
                                         3)),
                        0)) conta
           from pp_ordens
          where substr(ordem,
                       1,
                       1) = p_cl;
      --/origem
      cursor cr3 is
         select firma from cd_firmas where usuario = user;
   
      --/ variaveis
      v_msk_titulo pp_ordens.msk_titulo%type;
      v_opos       pp_ordens.ordem%type;
      v_tipo       pp_ordens.tipo%type;
      v_versao     cg_ccusto.versao%type; --VERSAO           ,--NUMBER(9)     Y
      v_ccusto     cg_ccusto.ccusto%type;
      v_espec      pp_ordens.especif_serv%type;
      v_conta      number(3);
      v_origem     number(9);
      v_gerou_op   boolean;
   begin
      v_msk_titulo := '9.99.99.99';
      v_espec      := 'F';
   
      --se for selecionado a opção para gerar somente uma op, 
      -- será flagado para true após criação da op
      v_gerou_op := false;
   
      open cr3;
      fetch cr3
         into v_origem;
      close cr3;
   
      for reg in cr loop
         --/ definic?o do tipo de op
         if not v_gerou_op then
            if reg.classe in (1,
                              2) then
               v_tipo   := 'P';
               v_versao := 1;
               v_ccusto := '3.01';
            elsif reg.classe in (3) then
               v_tipo   := 'S';
               v_versao := 1;
               v_ccusto := '5.01';
            elsif reg.classe in (9) then
               v_tipo   := 'C';
               v_versao := 1;
               v_ccusto := '2.01';
            
            else
               v_tipo   := 'P';
               v_versao := 1;
               v_ccusto := '3.01';
            
            end if;
            --/definic?o do numero da op
            if 1 = 2 then
               open cr1(reg.classe,
                        to_char(reg.dt_aprov,
                                'rr'));
               fetch cr1
                  into v_opos;
               close cr1;
            
               if v_opos is null then
                  v_opos := reg.classe || '.' ||
                            to_char(reg.dt_aprov,
                                    'rr') || '.' ||
                            lpad(v_conta,
                                 3,
                                 '0');
               end if;
            else
               open cr2(reg.classe);
               fetch cr2
                  into v_conta;
               close cr2;
            
               v_opos := reg.classe || '.' ||
                         to_char(reg.dt_aprov,
                                 'rr') || '.' ||
                         lpad(nvl(v_conta,
                                  0) + 1,
                              3,
                              '0');
            end if;
            --Raise_Application_Error(-20101, v_Opos);
            insert into pp_ordens
               (empresa
               ,filial
               ,ordem
               ,numero
               ,tipo
               ,produto
               ,contrato
               ,descricao
               ,criacao
               ,quantidade
               ,origem
               ,peso
               ,usr_criacao
               ,encerramento
               ,usr_encerramento
               ,data_entrega
               ,peso_entrega
               ,vl_total
               ,vl_ordem
               ,vl_ipi
               ,vl_icms
               ,vl_iss
               ,vl_pis
               ,vl_cofins
               ,vl_ret_inss
               ,msk_titulo
               ,grupov
               ,status
               ,vl_comissao
               ,especif_serv
               ,data_contratual
               ,vl_ret_irrf
               ,vl_ret_csll
               ,vl_ret_pis
               ,vl_ret_cofins
               ,area_res
               ,est_cred
               ,prazo_fabrica
               ,ordem01
               ,versao
               ,ccusto
               ,recnoib
               ,tipox
               ,fator_unv
               ,seq_ocproit)
            values
               (p_emp
               ,p_fil
               ,v_opos
               ,v_opos
               ,v_tipo
               ,reg.produto
               ,reg.contrato
               ,substr(reg.descricao,
                       1,
                       200)
               ,trunc(sysdate)
               ,reg.qtde
               ,v_origem
               ,round(reg.peso,
                      3)
               ,user
               ,null
               ,null
               ,reg.prazo_entr
               ,round(reg.peso,
                      3)
               ,round(reg.valor_neg,
                      3)
               ,round(reg.valor_neg / reg.qtde,
                      3)
               ,round(reg.valor_ipi,
                      3)
               ,round(reg.valor_icms,
                      3)
               ,null
               ,null
               ,null
               ,null
               ,v_msk_titulo
               ,reg.mercado
               ,'A'
               ,null
               ,v_espec
               ,reg.dt_aprov
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,reg.prazo_entr
               ,null
               ,v_versao
               ,v_ccusto
               ,null
               ,'M'
               ,round(reg.peso,
                      3)
               ,reg.seq_ocproit);
            --/
            if p_todos = 'S' then
               v_gerou_op := true;
            end if;
         
         end if;
         --/ atualiza item
         update oc_prop_item
            set status = 'S'
          where seq_ocproit = reg.seq_ocproit;
      
         insert into oc_prop_item_opos
            (seq_ocproit
            ,empresa
            ,filial
            ,opos
            ,usu_incl
            ,dt_incl)
         values
            (reg.seq_ocproit
            ,p_emp
            ,p_fil
            ,v_opos
            ,user
            ,sysdate);
      
      end loop;
      commit;
   end;

   ---------------------------------------------------------------------------------------------
   procedure gerar_opos(p_emp cd_empresas.empresa%type
                       ,p_fil cd_filiais.filial%type
                       ,p_seq oc_proposta.seq_ocprop%type)
   
      --
    is
   
      cursor cr is
         select a.seq_ocprop
               ,b.seq_ocproit
               ,a.cd_ocmerc
               ,a.num_prop
               ,b.contrato
               ,a.ano
               ,a.revisao
               ,a.cd_prop
               ,a.dt
               ,a.firma
               ,a.contato
               ,a.cd_ocforma
               ,a.tipo_venda
               ,a.moeda
               ,a.cd_ocmerc mercado
               ,a.dt_nec
               ,a.dt_val
               ,a.firma_01
               ,a.tp_serv
               ,a.obs obs_oc
               ,a.firma_oc
               ,a.contato_oc
               ,b.classe
               ,b.empresa
               ,case
                   when nvl(b.produto,
                            0) > 0 then
                    b.produto
                   else
                    c.produto
                end produto
               ,b.descr_compl descricao
               ,b.qtde
               ,b.qtde * (nvl(b.peso_unit,
                              0)) peso
               ,
                
                (trunc(b.dt_aprov)) dt_aprov
               ,(b.prazo_entr) prazo_entr
               ,(b.valor_neg) valor_neg
               ,((nvl(b.aliq_icms,
                      0) * b.valor_neg / 100)) valor_icms
               ,((nvl(b.aliq_ipi,
                      0) * b.valor_neg / 100)) valor_ipi
               ,b.perc_ir
               ,b.perc_inss
               ,b.perc_pc
               ,b.perc_iss
               ,b.perc_csll
               ,b.perc_irrf
               ,b.obs
           from oc_proposta  a
               ,oc_prop_item b
               ,oc_produto   c
          where a.seq_ocprop = b.seq_ocprop
            and b.seq_ocprop = p_seq
            and b.contrato is not null
            and b.status <> 'S'
            and c.codigo(+) = b.produto_oc
          order by b.item;
   
      --/ cursor gera codigo op/os incrementa por classe/ano
      cursor cr1(p_cl  number
                ,p_ano varchar2) is
         select substr(ordem,
                       1,
                       1) || '.' || lpad(substr(ordem,
                                                3,
                                                2),
                                         2,
                                         '0') || '.' ||
                lpad(nvl(max(to_number(substr(ordem,
                                              6,
                                              3))),
                         0) + 1,
                     3,
                     '0') conta
           from pp_ordens
          where substr(ordem,
                       1,
                       1) = p_cl
            and substr(ordem,
                       3,
                       2) = p_ano
          group by substr(ordem,
                          1,
                          1)
                  ,substr(ordem,
                          3,
                          2);
   
      --/ cursor gera codigo op/os incrementa por classe
      cursor cr2(p_cl number) is
         select max(nvl(to_number(substr(ordem,
                                         6,
                                         3)),
                        0)) conta
           from pp_ordens
          where substr(ordem,
                       1,
                       1) = p_cl;
      --/origem
      cursor cr3 is
         select firma from cd_firmas where usuario = user;
   
      --/ variaveis
      v_msk_titulo pp_ordens.msk_titulo%type;
      v_opos       pp_ordens.ordem%type;
      v_tipo       pp_ordens.tipo%type;
      v_versao     cg_ccusto.versao%type;
      v_ccusto     cg_ccusto.ccusto%type;
      v_espec      pp_ordens.especif_serv%type;
      v_conta      number(3);
      v_origem     number(9);
   begin
      v_msk_titulo := '9.99.99.99';
      v_espec      := 'F';
      /*   
      raise_application_error(-20100,
                                    'OC_ORCAM.1: ' ||p_seq);
      */
      open cr3;
      fetch cr3
         into v_origem;
      close cr3;
   
      for reg in cr loop
         --/ definic?o do tipo de op
         if reg.classe in (1,
                           2) then
            v_tipo   := 'P';
            v_versao := 1;
            v_ccusto := '3.01';
         elsif reg.classe in (3) then
            v_tipo   := 'S';
            v_versao := 1;
            v_ccusto := '5.01';
         elsif reg.classe in (9) then
            v_tipo   := 'C';
            v_versao := 1;
            v_ccusto := '2.01';
         
         else
            v_tipo   := 'P';
            v_versao := 1;
            v_ccusto := '3.01';
         
         end if;
         --/definic?o do numero da op
         if 1 = 2 then
            open cr1(reg.classe,
                     to_char(reg.dt_aprov,
                             'rr'));
            fetch cr1
               into v_opos;
            close cr1;
         
            if v_opos is null then
               v_opos := reg.classe || '.' ||
                         to_char(reg.dt_aprov,
                                 'rr') || '.' ||
                         lpad(v_conta,
                              3,
                              '0');
            end if;
         else
            open cr2(reg.classe);
            fetch cr2
               into v_conta;
            close cr2;
         
            v_opos := reg.classe || '.' || to_char(reg.dt_aprov,
                                                   'rr') || '.' ||
                      lpad(nvl(v_conta,
                               0) + 1,
                           3,
                           '0');
         end if;
         --Raise_Application_Error(-20101, v_Opos);
         insert into pp_ordens
            (empresa
            ,filial
            ,ordem
            ,numero
            ,tipo
            ,produto
            ,contrato
            ,descricao
            ,criacao
            ,quantidade
            ,origem
            ,peso
            ,usr_criacao
            ,encerramento
            ,usr_encerramento
            ,data_entrega
            ,peso_entrega
            ,vl_total
            ,vl_ordem
            ,vl_ipi
            ,vl_icms
            ,vl_iss
            ,vl_pis
            ,vl_cofins
            ,vl_ret_inss
            ,msk_titulo
            ,grupov
            ,status
            ,vl_comissao
            ,especif_serv
            ,data_contratual
            ,vl_ret_irrf
            ,vl_ret_csll
            ,vl_ret_pis
            ,vl_ret_cofins
            ,area_res
            ,est_cred
            ,prazo_fabrica
            ,ordem01
            ,versao
            ,ccusto
            ,recnoib
            ,tipox
            ,fator_unv
            ,seq_ocproit)
         values
            (p_emp
            ,p_fil
            ,v_opos
            ,v_opos
            ,v_tipo
            ,reg.produto
            ,reg.contrato
            ,substr(reg.descricao,
                    1,
                    200)
            ,trunc(sysdate)
            ,reg.qtde
            ,v_origem
            ,round(reg.peso,
                   3)
            ,user
            ,null
            ,null
            ,reg.prazo_entr
            ,round(reg.peso,
                   3)
            ,round(reg.valor_neg,
                   3)
            ,round(reg.valor_neg / reg.qtde,
                   3)
            ,round(reg.valor_ipi,
                   3)
            ,round(reg.valor_icms,
                   3)
            ,null
            ,null
            ,null
            ,null
            ,v_msk_titulo
            ,reg.mercado
            ,'A'
            ,null
            ,v_espec
            ,reg.dt_aprov
            ,null
            ,null
            ,null
            ,null
            ,null
            ,null
            ,reg.prazo_entr
            ,null
            ,v_versao
            ,v_ccusto
            ,null
            ,'M'
            ,round(reg.peso,
                   3)
            ,reg.seq_ocproit);
         --/ atualiza item
         update oc_prop_item
            set status = 'S'
          where seq_ocproit = reg.seq_ocproit;
         --/
         insert into oc_prop_item_opos
            (seq_ocproit
            ,empresa
            ,filial
            ,opos
            ,usu_incl
            ,dt_incl)
         values
            (reg.seq_ocproit
            ,p_emp
            ,p_fil
            ,v_opos
            ,user
            ,sysdate);
      end loop;
      commit;
   end;
   ---------------------------------------------------------------------------------------------
   procedure gerar_opos(p_emp   cd_empresas.empresa%type
                       ,p_fil   cd_filiais.filial%type
                       ,p_seq   oc_proposta.seq_ocprop%type
                       ,p_seqit oc_prop_item.seq_ocproit%type)
   
      -- 
    is
   
      cursor cr is
         select a.seq_ocprop
               ,b.seq_ocproit
               ,a.cd_ocmerc
               ,a.num_prop
               ,b.contrato
               ,a.ano
               ,a.revisao
               ,a.cd_prop
               ,a.dt
               ,a.firma
               ,a.contato
               ,a.cd_ocforma
               ,a.tipo_venda
               ,a.moeda
               ,
                --10001 Origem,
                a.cd_ocmerc mercado
               ,a.dt_nec
               ,a.dt_val
               ,a.firma_01
               ,a.tp_serv
               ,a.obs obs_oc
               ,a.firma_oc
               ,a.contato_oc
               ,b.classe
               ,b.empresa
               ,case
                   when nvl(b.produto,
                            0) > 0 then
                    b.produto
                   else
                    c.produto
                end produto
               ,b.descr_compl descricao
               ,b.qtde
               ,b.qtde * (nvl(b.peso_unit,
                              0)) peso
               ,
                
                (trunc(b.dt_aprov)) dt_aprov
               ,(b.prazo_entr) prazo_entr
               ,(b.valor_neg) valor_neg
               ,((nvl(b.aliq_icms,
                      0) * b.valor_neg / 100)) valor_icms
               ,((nvl(b.aliq_ipi,
                      0) * b.valor_neg / 100)) valor_ipi
               ,b.perc_ir
               ,b.perc_inss
               ,b.perc_pc
               ,b.perc_iss
               ,b.perc_csll
               ,b.perc_irrf
               ,b.obs
           from oc_proposta  a
               ,oc_prop_item b
               ,oc_produto   c
          where a.seq_ocprop = b.seq_ocprop
            and b.seq_ocprop = p_seq
            and b.seq_ocproit = p_seqit
            and b.contrato is not null
            and b.status <> 'S'
            and c.codigo(+) = b.produto_oc
          order by b.item;
   
      --/ cursor gera codigo op/os incrementa por classe/ano
      cursor cr1(p_cl  number
                ,p_ano varchar2) is
         select substr(ordem,
                       1,
                       1) || '.' || lpad(substr(ordem,
                                                3,
                                                2),
                                         2,
                                         '0') || '.' ||
                lpad(nvl(max(to_number(substr(ordem,
                                              6,
                                              3))),
                         0) + 1,
                     3,
                     '0') conta
           from pp_ordens
          where substr(ordem,
                       1,
                       1) = p_cl
            and substr(ordem,
                       3,
                       2) = p_ano
          group by substr(ordem,
                          1,
                          1)
                  ,substr(ordem,
                          3,
                          2);
   
      --/ cursor gera codigo op/os incrementa por classe
      cursor cr2(p_cl number) is
         select max(nvl(to_number(substr(ordem,
                                         6,
                                         3)),
                        0)) conta
           from pp_ordens
          where substr(ordem,
                       1,
                       1) = p_cl;
      --/origem
      cursor cr3 is
         select firma from cd_firmas where usuario = user;
   
      --/ variaveis
      v_msk_titulo pp_ordens.msk_titulo%type;
      v_opos       pp_ordens.ordem%type;
      v_tipo       pp_ordens.tipo%type;
      v_versao     cg_ccusto.versao%type; --VERSAO           ,--NUMBER(9)     Y
      v_ccusto     cg_ccusto.ccusto%type;
      v_espec      pp_ordens.especif_serv%type;
      v_conta      number(3);
      v_origem     number(9);
   begin
      v_msk_titulo := '9.99.99.99';
      v_espec      := 'F';
   
      open cr3;
      fetch cr3
         into v_origem;
      close cr3;
   
      for reg in cr loop
         --/ definic?o do tipo de op
         if reg.classe in (1,
                           2) then
            v_tipo   := 'P';
            v_versao := 1;
            v_ccusto := '3.01';
         elsif reg.classe in (3) then
            v_tipo   := 'S';
            v_versao := 1;
            v_ccusto := '5.01';
         elsif reg.classe in (9) then
            v_tipo   := 'C';
            v_versao := 1;
            v_ccusto := '2.01';
         
         else
            v_tipo   := 'P';
            v_versao := 1;
            v_ccusto := '3.01';
         
         end if;
         --/definic?o do numero da op
         if 1 = 2 then
            open cr1(reg.classe,
                     to_char(reg.dt_aprov,
                             'rr'));
            fetch cr1
               into v_opos;
            close cr1;
         
            if v_opos is null then
               v_opos := reg.classe || '.' ||
                         to_char(reg.dt_aprov,
                                 'rr') || '.' ||
                         lpad(v_conta,
                              3,
                              '0');
            end if;
         else
            open cr2(reg.classe);
            fetch cr2
               into v_conta;
            close cr2;
         
            v_opos := reg.classe || '.' || to_char(reg.dt_aprov,
                                                   'rr') || '.' ||
                      lpad(nvl(v_conta,
                               0) + 1,
                           3,
                           '0');
         end if;
         --Raise_Application_Error(-20101, v_Opos);
         insert into pp_ordens
            (empresa
            , --   NUMBER(9)
             filial
            , --   NUMBER(9)
             ordem
            , --VARCHAR2(30)
             numero
            , --VARCHAR2(30)
             tipo
            , --CHAR(1)
             produto
            , --NUMBER(9)
             contrato
            , --NUMBER(9)
             descricao
            , --VARCHAR2(200)
             criacao
            , --DATE
             quantidade
            , --NUMBER(9)
             origem
            , --NUMBER(9)
             peso
            , --NUMBER(15,3)   Y
             usr_criacao
            , --VARCHAR2(30)  Y
             encerramento
            , --DATE          Y
             usr_encerramento
            , --VARCHAR2(30)  Y
             data_entrega
            , --DATE          Y
             peso_entrega
            , --NUMBER(9,3)   Y
             vl_total
            , --NUMBER(15,3)  Y
             vl_ordem
            , --NUMBER(15,3)  Y
             vl_ipi
            , --NUMBER(15,3)  Y
             vl_icms
            , --NUMBER(15,3)  Y
             vl_iss
            , --NUMBER(15,3)  Y
             vl_pis
            , --NUMBER(15,3)  Y
             vl_cofins
            , --NUMBER(15,3)  Y
             vl_ret_inss
            , --NUMBER(15,3)  Y
             msk_titulo
            , --VARCHAR2(30)  Y
             grupov
            , --NUMBER(9)
             status
            , --CHAR(1)
             vl_comissao
            , --NUMBER(15,3)  Y
             especif_serv
            , --VARCHAR2(1)
             data_contratual
            , --DATE          Y
             vl_ret_irrf
            , --NUMBER(15,3)  Y
             vl_ret_csll
            , --NUMBER(15,3)  Y
             vl_ret_pis
            , --NUMBER(15,3)  Y
             vl_ret_cofins
            , --NUMBER(15,3)  Y
             area_res
            , --VARCHAR2(20)  Y
             est_cred
            , --CHAR(1)       Y
             prazo_fabrica
            , --DATE          Y
             ordem01
            , --VARCHAR2(30)  Y
             versao
            , --NUMBER(9)     Y
             ccusto
            , --VARCHAR2(20)  Y
             recnoib
            , --NUMBER        Y
             tipox
            , --VARCHAR2(1)   Y
             fator_unv
            , --NUMBER(15,6)  Y
             seq_ocproit)
         values
            (p_emp
            ,p_fil
            ,v_opos
            ,v_opos
            , --           ,--VARCHAR2(30)
             v_tipo
            , --(P =1 e 2 ) (S=3) (C=9)
             reg.produto
            , --NUMBER(9)
             reg.contrato
            , --NUMBER(9)
             substr(reg.descricao,
                    1,
                    200)
            , --VARCHAR2(200)
             trunc(sysdate)
            , --CRIACAO          ,--DATE
             reg.qtde
            , --QUANTIDADE       ,--NUMBER(9)
             v_origem
            , --NUMBER(9)
             round(reg.peso,
                   3)
            , --NUMBER(9,3)   Y
             user
            , --USR_CRIACAO      ,--VARCHAR2(30)  Y
             null
            , --ENCERRAMENTO     ,--DATE          Y
             null
            , --USR_ENCERRAMENTO ,--VARCHAR2(30)  Y
             reg.prazo_entr
            , --DATE          Y
             round(reg.peso,
                   3)
            , --PESO_ENTREGA     ,--NUMBER(9,3)   Y
             round(reg.valor_neg,
                   3)
            , --VL_TOTAL         ,--NUMBER(15,3)  Y
             round(reg.valor_neg / reg.qtde,
                   3)
            , --VL_ORDEM         ,--NUMBER(15,3)  Y
             round(reg.valor_ipi,
                   3)
            , --NUMBER(15,3)  Y
             round(reg.valor_icms,
                   3)
            , --NUMBER(15,3)  Y
             null
            , --VL_ISS           ,--NUMBER(15,3)  Y
             null
            , --VL_PIS           ,--NUMBER(15,3)  Y
             null
            , --VL_COFINS        ,--NUMBER(15,3)  Y
             null
            , --VL_RET_INSS      ,--NUMBER(15,3)  Y
             v_msk_titulo
            , --VARCHAR2(30)  Y
             reg.mercado
            , --GRUPOV           ,--NUMBER(9)
             'A'
            , --STATUS           ,--CHAR(1)
             null
            , --VL_COMISSAO      ,--NUMBER(15,3)  Y
             v_espec
            , --'F' , --ESPECIF_SERV     ,--VARCHAR2(1)
             reg.dt_aprov
            , --                data_contratual, --DATE          Y
             null
            , --VL_RET_IRRF      ,--NUMBER(15,3)  Y
             null
            , --VL_RET_CSLL      ,--NUMBER(15,3)  Y
             null
            , --VL_RET_PIS       ,--NUMBER(15,3)  Y
             null
            , --VL_RET_COFINS    ,--NUMBER(15,3)  Y
             null
            , --AREA_RES         ,--VARCHAR2(20)  Y
             null
            , --EST_CRED         ,--CHAR(1)       Y
             reg.prazo_entr
            , --PRAZO_FABRICA    ,--DATE          Y
             null
            , --ORDEM01          ,--VARCHAR2(30)  Y
             v_versao
            , --VERSAO           ,--NUMBER(9)     Y
             v_ccusto
            , --VARCHAR2(20)  Y
             null
            , --RECNOIB          ,--NUMBER        Y
             'M'
            , --TIPOX            ,--VARCHAR2(1)   Y
             round(reg.peso,
                   3)
            , --FATOR_UNV       --NUMBER(15,6)  Y
             reg.seq_ocproit);
         --/ atualiza item
         update oc_prop_item
            set status = 'S'
          where seq_ocproit = reg.seq_ocproit;
         --/
         insert into oc_prop_item_opos
            (seq_ocproit
            ,empresa
            ,filial
            ,opos
            ,usu_incl
            ,dt_incl)
         values
            (reg.seq_ocproit
            ,p_emp
            ,p_fil
            ,v_opos
            ,user
            ,sysdate);
      end loop;
      commit;
   end;

   ---------------------------------------------------------------------------------------------
   -------------------------------------------------------------------------------------------------------------------
   --/ gerar proposta
   --------------------------------------------------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------
   procedure gerar_proposta(p_emp cd_empresas.empresa%type
                           ,p_fil cd_filiais.filial%type
                           ,p_seq oc_orcam_venda.id_orcamvenda%type) is
      cursor cr is
         select a.*
           from oc_orcam_venda a
          where a.id_orcamvenda = p_seq
         --and not exists
         --(select 1 from oc_proposta a where id_orcamvenda = p_seq)
         ;
   
      cursor cr1 is
         select g.per_icms
               ,decode(nvl(g.per_icms,
                           0),
                       0,
                       'N',
                       'S') icms_incl
               ,g.per_iss
               ,decode(nvl(g.per_iss,
                           0),
                       0,
                       'N',
                       'S') iss_incl
               ,g.per_pis_cofins
               ,decode(nvl(g.per_pis_cofins,
                           0),
                       0,
                       'N',
                       'S') piscof_incl
               ,g.per_csll
               ,case
                   when nvl(g.per_csll,
                            0) = 0 or
                        g.per_csll <= 1.08 then
                    'N'
                   else
                    'S'
                end csll_incl
               ,g.per_inss
               ,decode(nvl(g.per_inss,
                           0),
                       0,
                       'N',
                       'S') inss_incl
               ,g.per_ir
               ,case
                   when nvl(g.per_ir,
                            0) = 0 or
                        g.per_ir <= 2 then
                    'N'
                   else
                    'S'
                end ir_incl
               ,g.margem
               ,g.per_ipi
               ,decode(nvl(g.per_ipi,
                           0),
                       0,
                       'N',
                       'S') ipi_incl_icms
               ,g.per_desp_fin
               ,g.per_desp_adm
               ,g.per_desp_com
               ,g.per_fabric
               ,g.per_royal
               ,g.pis_cofins pis_cof
               ,g.formula_calc
               ,a.*
               ,(select sum(nvl(gp.peso_liq,
                                0) * gr.qtde) peso_liq
                   from oc_orcam_gr      gr
                       ,oc_orcam_gr_prod gp
                  where gp.seq_ocorcamgr = gr.seq_ocorcamgr
                    and gr.id_orcamprod = a.id_orcamprod) peso_liq_mp
               ,(select sum(nvl(gp.peso_bruto,
                                0) * gr.qtde) peso_br
                   from oc_orcam_gr      gr
                       ,oc_orcam_gr_prod gp
                  where gp.seq_ocorcamgr = gr.seq_ocorcamgr
                    and gr.id_orcamprod = a.id_orcamprod) peso_br_mp
           from oc_orcam_prod       a
               ,gs_preco_venda_prod g
               ,gs_preco_venda      v
          where a.id_orcamvenda = p_seq
            and g.id_orcamprod(+) = a.id_orcamprod
            and v.empresa(+) = g.empresa
            and v.nr_pc_seq(+) = g.nr_pc_seq
          order by a.item;
   
      cursor cr2(p_idprd number) is
         select a.* from oc_orcam_gr a where a.id_orcamprod = p_idprd;
   
      cursor crcont(p_cto in number) is
         select a.seq_contato
           from oc_contatos a
          where a.firma_oc = a.firma_oc
            and a.indice = 1;
   
      cursor crtexto(p_id_tipo number) is
         select m.complemento
           from oc_tipo_modelo tp
               ,oc_modelo      m
          where m.id_oc_tipo_modelo = tp.id
            and tp.id = p_id_tipo
            and m.cd = 1;
   
      cursor crrev is
         select max(a.revisao)
           from oc_proposta a
          where a.id_orcamvenda = p_seq;
   
      v_seq     number(9);
      v_seq_itm number(9);
   
      v_cont       number(9);
      v_ind        number(2);
      v_cd_ocmerc  number(4);
      v_nro_prop   number(9);
      v_item       number(9) := 0;
      v_item2      number(9) := 0;
      v_item_str   varchar2(40);
      v_preco_simp number(15,
                          2);
      v_custo_unit number(15,
                          2);
      v_cod_clafis ft_clafis.cod_clafis%type;
   
      v_texto clob;
      v_obs1  varchar2(4000);
      v_obs2  varchar2(4000);
      v_obs3  varchar2(4000);
   
      v_garantia    varchar2(4000);
      v_cond_pag    varchar2(4000);
      v_validade    varchar2(4000);
      v_obs_frete   oc_prop_item.obs_frete%type;
      v_obs_entrega oc_prop_item.obs_entrega%type;
   
      v_dt_entrega_prop date;
      v_rev             number(9);
      v_tem_revisao     varchar2(1) := 'N';
   begin
   
      for reg in cr loop
         if reg.firma_orc is not null then
            open crcont(reg.firma_orc);
            fetch crcont
               into v_cont;
            close crcont;
         else
            v_ind := 1;
         end if;
      
         select oc_proposta_seq.nextval into v_seq from dual;
         --| revisao
         v_rev := null;
         open crrev;
         fetch crrev
            into v_rev;
         close crrev;
      
         v_cd_ocmerc := 1; -- mercado fabrica de acucar
         v_nro_prop  := oc_util.proposta_mercado(v_cd_ocmerc);
      
         --|texto padrao para obs
         v_texto := null;
         open crtexto(7);
         fetch crtexto
            into v_texto;
         close crtexto;
      
         v_obs1 := rtrim(ltrim(dbms_lob.substr(v_texto,
                                               4000,
                                               1)));
         v_obs2 := rtrim(ltrim(dbms_lob.substr(v_texto,
                                               4000,
                                               4001)));
         v_obs3 := rtrim(ltrim(dbms_lob.substr(v_texto,
                                               4000,
                                               8001)));
         --| texto padrao de garantia
         v_texto := null;
         open crtexto(3);
         fetch crtexto
            into v_texto;
         close crtexto;
         v_garantia := rtrim(ltrim(dbms_lob.substr(v_texto,
                                                   4000,
                                                   1)));
      
         --| texto padrao de condições de pagamento
         v_texto := null;
         open crtexto(4);
         fetch crtexto
            into v_texto;
         close crtexto;
         v_cond_pag := rtrim(ltrim(dbms_lob.substr(v_texto,
                                                   4000,
                                                   1)));
      
         --| texto padrao de validade da proposta
         v_texto := null;
         open crtexto(5);
         fetch crtexto
            into v_texto;
         close crtexto;
      
         v_validade := rtrim(ltrim(dbms_lob.substr(v_texto,
                                                   4000,
                                                   1)));
      
         v_dt_entrega_prop := reg.dt_entrega_prop;
      
         if v_dt_entrega_prop is null then
            v_dt_entrega_prop := trunc(sysdate) + 5;
         end if;
      
         if v_rev is null then
            v_rev         := reg.rev;
            v_tem_revisao := 'S';
         else
            v_rev := v_rev + 1;
            update oc_proposta a
               set a.status = 'R'
             where a.id_orcamvenda = p_seq
               and a.status not in ('R');
         
            v_tem_revisao := 'N';
         
         end if;
      
         insert into oc_proposta a
            (seq_ocprop
            ,cd_ocmerc
            ,num_prop
            ,ano
            ,revisao
            ,cd_prop
            ,dt
            ,firma
            ,contato
            ,status
            ,cd_ocforma
            ,usuario
            ,dt_sis
            ,moeda
            ,responsavel
            ,mercado
            ,vl_negoc
            ,vl_ipi
            ,firma_oc
            ,contato_oc
            ,tipo_venda
            ,id_orcamvenda
            ,obs
            ,obs2
            ,obs3
            ,garantia
            ,a.cond_pagto
            ,a.validade_proposta
            ,dt_entrega_prop
            ,usu_rev
            ,dt_rev
            ,obs_rev
             
             )
         values
            (v_seq
            ,1
            , --mercado fabrica de acucar
             v_nro_prop
            ,to_char(reg.dt_orcam,
                     'rrrr')
            ,v_rev
            ,reg.cd_orcam
            ,reg.dt_orcam
            ,reg.firma
            ,v_ind
            , --indice do contato
             'D'
            , --status
             5
            , -- outras
             user
            ,sysdate
            ,'R$'
            ,reg.resp
            ,'I'
            , --mercado interno/ externo
             reg.preco
            ,null
            ,reg.firma_orc
            ,v_cont
            ,1
            ,p_seq
            ,v_obs1
            ,v_obs2
            ,v_obs3
            ,v_garantia
            ,v_cond_pag
            ,v_validade
            ,v_dt_entrega_prop
            ,user
            ,sysdate
            ,reg.obs_rev);
      
         --/ se for revis?o muda status de propostas de vers?es anteriores para revisada
         if nvl(reg.rev,
                0) > 0 then
            update oc_proposta p
               set p.status = 'R'
             where p.cd_prop = reg.cd_orcam
               and p.status <> 'R'
               and p.revisao < reg.rev;
         
         end if;
      
         for reg1 in cr1 loop
         
            select oc_prop_item_seq.nextval into v_seq_itm from dual;
            v_item := v_item + 1;
            begin
               v_preco_simp := null;
               v_custo_unit := (nvl(reg1.custo_prod,
                                    0) + nvl(reg1.custo_mo,
                                              0)) / 1; -- reg1.qtd;
            
               v_preco_simp := round(v_custo_unit *
                                     (100 / (100 - round(nvl(reg1.margem,
                                                             0),
                                                         2))),
                                     2);
            exception
               when others then
                  null;
            end;
            --/
            v_cod_clafis := null;
            if nvl(reg1.produto,
                   0) > 0 then
               v_cod_clafis := ce_produtos_utl.cod_clafis(reg1.empresa,
                                                          reg1.produto);
            end if;
         
            if nvl(v_cod_clafis,
                   0) > 0 then
               v_cod_clafis := null;
            end if;
         
            --| texto padrao de Observacoes de Entrega
            v_texto := null;
            open crtexto(9);
            fetch crtexto
               into v_texto;
            close crtexto;
            v_obs_entrega := rtrim(ltrim(dbms_lob.substr(v_texto,
                                                         4000,
                                                         1)));
         
            --| texto padrao de Observacoes de Frete
            v_texto := null;
            open crtexto(8);
            fetch crtexto
               into v_texto;
            close crtexto;
            v_obs_frete := rtrim(ltrim(dbms_lob.substr(v_texto,
                                                       4000,
                                                       1)));
         
            insert into oc_prop_item
               (seq_ocproit
               ,seq_ocprop
               ,item
               ,empresa
               ,produto
               ,qtde
               ,status
               ,dt_sis
               ,usu_sis
               ,peso_unit
               ,preco_unit
               ,preco_unit_simp
               ,custo_unit
               ,forma_pagto
               ,capacidade
               ,obs
               ,prazo_entr
               ,contrato
               ,valor_neg
               ,aliq_icms
               ,aliq_ipi
               ,descr_compl
               ,tipo_frete
               ,perc_frete
               ,comprimento
               ,largura
               ,classe
               ,icms_incl
               ,produto_oc
               ,perc_pc
               ,piscof_incl
               ,perc_inss
               ,inss_incl
               ,perc_ir
               ,ir_sll
               ,perc_iss
               ,iss_incl
               ,perc_csll
               ,csll_sll
               ,ipi_incl_icms
               ,margem
               ,id_orcamprod
               ,cod_clafis
               ,obs_frete
               ,obs_entrega
               ,per_desp_fin
               ,per_desp_adm
               ,per_fabric
               ,per_royal
               ,pis_cof
               ,per_desp_com
               ,formula_calc)
            values
               (v_seq_itm
               ,v_seq
               ,v_item
               ,p_emp
               ,reg1.produto
               ,reg1.qtd
               ,'D'
               , --orcando
                sysdate
               ,user
               ,reg1.peso_liq_mp / 1 --reg1.qtd
               , --pPESO_UNIT       ,
                reg1.preco / 1 --reg1.qtd
               , --PRECO_UNIT      ,
                v_preco_simp
               , --preco_sem impostos      ,
                v_custo_unit
               , --CUSTO_UNIT      ,
                null
               , --FORMA_PAGTO     ,
                null
               , --CAPACIDADE      ,
                null
               , --OBS             ,
                null
               , --PRAZO_ENTR      ,
                null
               , --CONTRATO        ,
                null
               , --VALOR_NEG       ,
                reg1.per_icms
               , --ALIQ_ICMS       ,
                reg1.per_ipi
               , --ALIQ_IPI        ,
                reg1.descr_prod
               , -- DESCR_COMPL     ,
                null
               , --TIPO_FRETE      ,
                null
               , -- PERC_FRETE      ,
                null
               , -- COMPRIMENTO     ,
                null
               , -- LARGURA         ,
                null
               , -- CLASSE
                'S'
               ,reg1.produto_orc
               ,reg1.per_pis_cofins
               ,reg1.piscof_incl
               ,reg1.per_inss
               ,reg1.inss_incl
               ,reg1.per_ir
               ,reg1.ir_incl
               ,reg1.per_iss
               ,reg1.iss_incl
               ,reg1.per_csll
               ,reg1.csll_incl
               ,reg1.ipi_incl_icms
               ,reg1.margem
               ,reg1.id_orcamprod
               ,v_cod_clafis
               ,v_obs_frete --v_obs_frete
               ,v_obs_entrega --v_obs_entrega
               ,reg1.per_desp_fin
               ,reg1.per_desp_adm
               ,reg1.per_fabric
               ,reg1.per_royal
               ,reg1.pis_cof
               ,reg1.per_desp_com
               ,reg1.formula_calc);
            if v_tem_revisao = 'N' then
               for reg2 in cr2(reg1.id_orcamprod) loop
                  v_item2 := v_item2 + 1;
                  if reg2.grupo is null then
                     v_item_str := lpad(to_char(v_item2),
                                        3,
                                        '0');
                  else
                     v_item_str := reg2.grupo;
                  end if;
               
                  insert into oc_prop_item_estr
                     (seq_ocproites
                     ,seq_ocproit
                     ,item
                     ,descricao
                     ,complemento
                     ,empresa
                     ,produto
                     ,qtd
                     ,unidade
                     ,valor_unit)
                  values
                     (oc_prop_item_estr_seq.nextval
                     ,v_seq_itm
                     ,v_item_str
                     ,reg2.descr
                     ,null
                     , --COMPLEMENTO   ,
                      null
                     , --EMPRESA       ,
                      null
                     , --PRODUTO       ,
                      1
                     , --QTD           ,
                      'UND'
                     , --UNIDADE       ,
                      reg2.preco / 1 --reg1.qtd --VALOR_UNIT
                      );
               end loop;
            else
               --/ copia estrutura de versao anterior
               /*
               copiar_espec_tec_rev(v_nro_prop,
                                    v_rev,
                                    v_item,
                                    v_seq_itm);
               copiar_inclusao_rev_s(v_nro_prop,
                                     v_rev,
                                     v_item,
                                     v_seq_itm);
               copiar_exclusao_rev_s(v_nro_prop,
                                     v_rev,
                                     v_item,
                                     v_seq_itm);
               */
               null;
            end if;
         end loop;
      end loop;
   
      update oc_orcam_venda v set v.status = 'P' where v.id_orcamvenda = p_seq;
      atualizar_proposta_com_revisao(p_emp,
                                     p_fil,
                                     v_seq);
      commit;
   end;

   --------------------------------------------------------------------------------------------------------------------
   --/ Atualizar proposta com revisao anterior
   --------------------------------------------------------------------------------------------------------------------
   procedure atualizar_proposta_com_revisao(p_emp cd_empresas.empresa%type
                                           ,p_fil cd_filiais.filial%type
                                           ,p_seq oc_proposta.seq_ocprop%type) is
      cursor cr_rev is
         select rev.*
           from oc_proposta p
               ,oc_proposta rev
          where rev.cd_prop = p.cd_prop
            and p.seq_ocprop = p_seq
            and rev.revisao = (p.revisao - 1);
   
      --/itens da proposta       
      cursor crit_rev(pl_seq oc_proposta.seq_ocprop%type) is
         select * from oc_prop_item it where it.seq_ocprop = pl_seq;
   
      --/estrutura do item da proposta
      cursor crestr_rev(pl_seqit oc_prop_item.seq_ocproit%type) is
         select * from oc_prop_item_estr e where e.seq_ocproit = pl_seqit;
   
      --/inclusoes do item da proposta
      cursor crincl_rev(pl_seqit oc_prop_item.seq_ocproit%type) is
         select * from oc_prop_item_incl e where e.seq_ocproit = pl_seqit;
   
      --/excluoes do item da proposta
      cursor crexcl_rev(pl_seqit oc_prop_item.seq_ocproit%type) is
         select * from oc_prop_item_excl e where e.seq_ocproit = pl_seqit;
   
      --/ itens produto atuais
      cursor cr_it(pl_seq          oc_proposta.seq_ocprop%type
                  ,pl_id_orcamprod oc_prop_item.id_orcamprod%type) is
         select *
           from oc_prop_item it
          where it.seq_ocprop = pl_seq
            and it.id_orcamprod = pl_id_orcamprod;
   
      --/variaveis
      vt_itpro oc_prop_item%rowtype;
      vt_estr  oc_prop_item_estr%rowtype;
      vt_incl  oc_prop_item_incl%rowtype;
      vt_excl  oc_prop_item_excl%rowtype;
   
   begin
      for reg_rev in cr_rev loop
         for reg_itrev in crit_rev(reg_rev.seq_ocprop) loop
         
            vt_itpro := null;
         
            open cr_it(p_seq,
                       reg_itrev.id_orcamprod);
            fetch cr_it
               into vt_itpro;
            close cr_it;
         
            if vt_itpro.seq_ocproit is not null then
               delete oc_prop_item_estr estr
                where estr.seq_ocproit = vt_itpro.seq_ocproit;
            
               for reg_estrrev in crestr_rev(reg_itrev.seq_ocproit) loop
                  insert into oc_prop_item_estr
                  values
                     (oc_prop_item_estr_seq.nextval
                     ,vt_itpro.seq_ocproit
                     ,reg_estrrev.item
                     ,reg_estrrev.descricao
                     ,reg_estrrev.complemento
                     ,reg_estrrev.empresa
                     ,reg_estrrev.produto
                     ,reg_estrrev.qtd
                     ,reg_estrrev.unidade
                     ,reg_estrrev.valor_unit);
               end loop;
            
               delete oc_prop_item_incl estr
                where estr.seq_ocproit = vt_itpro.seq_ocproit;
            
               for reg_inclrev in crincl_rev(reg_itrev.seq_ocproit) loop
                  insert into oc_prop_item_incl
                  values
                     (oc_prop_item_incl_seq.nextval
                     ,vt_itpro.seq_ocproit
                     ,reg_inclrev.item
                     ,reg_inclrev.descricao
                     ,reg_inclrev.complemento
                     ,reg_inclrev.vl_incl);
               end loop;
            
               delete oc_prop_item_excl estr
                where estr.seq_ocproit = vt_itpro.seq_ocproit;
            
               for reg_exclrev in crexcl_rev(reg_itrev.seq_ocproit) loop
                  insert into oc_prop_item_excl
                  values
                     (oc_prop_item_excl_seq.nextval
                     ,vt_itpro.seq_ocproit
                     ,reg_exclrev.item
                     ,reg_exclrev.descricao
                     ,reg_exclrev.complemento);
               end loop;
            
               update oc_prop_item it
                  set --ITEM            = reg_itrev.item,
                      empresa = reg_itrev.empresa
                     ,produto = reg_itrev.produto
                     ,qtde    = reg_itrev.qtde
                     ,
                      --STATUS          = reg_itrev.status,
                      dt_sis          = reg_itrev.dt_sis
                     ,usu_sis         = reg_itrev.usu_sis
                     ,peso_unit       = reg_itrev.peso_unit
                     ,preco_unit      = reg_itrev.preco_unit
                     ,preco_unit_simp = reg_itrev.preco_unit_simp
                     ,custo_unit      = reg_itrev.custo_unit
                     ,forma_pagto     = reg_itrev.forma_pagto
                     ,capacidade      = reg_itrev.capacidade
                     ,seq_ocprop_ori  = reg_itrev.seq_ocprop_ori
                     ,cd_ocmotivo     = reg_itrev.cd_ocmotivo
                     ,dt_aprov        = reg_itrev.dt_aprov
                     ,usu_aprov       = reg_itrev.usu_aprov
                     ,obs             = reg_itrev.obs
                     ,prazo_entr      = reg_itrev.prazo_entr
                     ,contrato        = reg_itrev.contrato
                     ,valor_neg       = reg_itrev.valor_neg
                     ,aliq_icms       = reg_itrev.aliq_icms
                     ,aliq_ipi        = reg_itrev.aliq_ipi
                     ,descr_compl     = reg_itrev.descr_compl
                     ,tipo_frete      = reg_itrev.tipo_frete
                     ,perc_frete      = reg_itrev.perc_frete
                     ,obs_frete       = reg_itrev.obs_frete
                     ,comprimento     = reg_itrev.comprimento
                     ,largura         = reg_itrev.largura
                     ,obs_entrega     = reg_itrev.obs_entrega
                     ,icms_incl       = reg_itrev.icms_incl
                     ,classe          = reg_itrev.classe
                     ,produto_oc      = reg_itrev.produto_oc
                     ,perc_pc         = reg_itrev.perc_pc
                     ,piscof_incl     = reg_itrev.piscof_incl
                     ,perc_inss       = reg_itrev.perc_inss
                     ,inss_incl       = reg_itrev.inss_incl
                     ,perc_ir         = reg_itrev.perc_ir
                     ,ir_sll          = reg_itrev.ir_sll
                     ,perc_iss        = reg_itrev.perc_iss
                     ,iss_incl        = reg_itrev.iss_incl
                     ,perc_csll       = reg_itrev.perc_csll
                     ,csll_sll        = reg_itrev.csll_sll
                     ,perc_irrf       = reg_itrev.perc_irrf
                     ,ipi_incl_icms   = reg_itrev.ipi_incl_icms
                     ,margem          = reg_itrev.margem
                     ,id_orcamprod    = reg_itrev.id_orcamprod
                     ,cod_clafis      = reg_itrev.cod_clafis
                     ,preco_valido    = reg_itrev.preco_valido
                     ,dt_contrato     = reg_itrev.dt_contrato
                     ,dias_entrega    = reg_itrev.dias_entrega
                     ,tipo_dias       = reg_itrev.tipo_dias
                     ,per_desp_fin    = reg_itrev.per_desp_fin
                     ,per_desp_adm    = reg_itrev.per_desp_adm
                     ,per_fabric      = reg_itrev.per_fabric
                     ,per_royal       = reg_itrev.per_royal
                     ,pis_cof         = reg_itrev.pis_cof
                     ,per_desp_com    = reg_itrev.per_desp_com
                     ,formula_calc    = reg_itrev.formula_calc
                where seq_ocproit = vt_itpro.seq_ocproit;
            end if;
         
            update oc_proposta a
               set cd_ocmerc = reg_rev.cd_ocmerc
                  ,num_prop  = reg_rev.num_prop
                  ,ano       = reg_rev.ano
                  ,dt        = reg_rev.dt
                  ,firma     = reg_rev.firma
                  ,contato   = reg_rev.contato
                  ,
                   --STATUS                         = reg_rev.status,
                   cd_ocforma        = reg_rev.cd_ocforma
                  ,moeda             = reg_rev.moeda
                  ,responsavel       = reg_rev.responsavel
                  ,mercado           = reg_rev.mercado
                  ,vl_negoc          = reg_rev.vl_negoc
                  ,vl_ipi            = reg_rev.vl_ipi
                  ,seq_ocprop_or     = reg_rev.seq_ocprop_or
                  ,dt_nec            = reg_rev.dt_nec
                  ,dt_val            = reg_rev.dt_val
                  ,firma_01          = reg_rev.firma_01
                  ,dt_envio_cli      = reg_rev.dt_envio_cli
                  ,usu_envio_cli     = reg_rev.usu_envio_cli
                  ,dt_aprov_cli      = reg_rev.dt_aprov_cli
                  ,usu_aprov_cli     = reg_rev.usu_aprov_cli
                  ,tp_serv           = reg_rev.tp_serv
                  ,obs               = reg_rev.obs
                  ,firma_oc          = reg_rev.firma_oc
                  ,contato_oc        = reg_rev.contato_oc
                  ,tipo_venda        = reg_rev.tipo_venda
                  ,id_orcamvenda     = reg_rev.id_orcamvenda
                  ,garantia          = reg_rev.garantia
                  ,cond_pagto        = reg_rev.cond_pagto
                  ,cod_tec           = reg_rev.cod_tec
                  ,cod_com           = reg_rev.cod_com
                  ,usu_assina        = reg_rev.usu_assina
                  ,dt_assina         = reg_rev.dt_assina
                  ,firma_assina      = reg_rev.firma_assina
                  ,validade_proposta = reg_rev.validade_proposta
                  ,obs2              = reg_rev.obs2
                  ,obs3              = reg_rev.obs3
                  ,dt_entrega_prop   = reg_rev.dt_entrega_prop
             where a.seq_ocprop = p_seq;
         
         end loop;
      
      end loop;
      commit;
   end;
   --------------------------------------------------------------------------------------------------------------------
   --/ Atualizar proposta com textos padroes do orcamento
   --------------------------------------------------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------

   procedure atualiza_texto_padrao_prop(p_emp cd_empresas.empresa%type
                                       ,p_fil cd_filiais.filial%type
                                       ,p_seq oc_orcam_venda.id_orcamvenda%type) is
      cursor cr is
         select a.* from oc_orcam_venda a where a.id_orcamvenda = p_seq;
   
      cursor crtexto(p_id_tipo number) is
      --select texto from oc_texto_padrao2 where tipo = p_tipo;
         select m.complemento
           from oc_tipo_modelo tp
               ,oc_modelo      m
          where m.id_oc_tipo_modelo = tp.id
            and tp.id = p_id_tipo
            and m.cd = 1;
      --|variaveis
      v_seq             number(9);
      v_texto           varchar2(32000);
      v_obs1            varchar2(4000);
      v_obs2            varchar2(4000);
      v_obs3            varchar2(4000);
      v_garantia        varchar2(4000);
      v_validade        varchar2(4000);
      v_dt_entrega_prop date;
      v_cond_pag        oc_proposta.cond_pagto%type;
   
   begin
      for reg in cr loop
         v_seq := reg.id_orcamvenda;
         --|texto padrao para obs
         v_texto := null;
         open crtexto(7);
         fetch crtexto
            into v_texto;
         close crtexto;
      
         v_obs1 := rtrim(ltrim(dbms_lob.substr(v_texto,
                                               4000,
                                               1)));
         v_obs2 := rtrim(ltrim(dbms_lob.substr(v_texto,
                                               4000,
                                               4001)));
         v_obs3 := rtrim(ltrim(dbms_lob.substr(v_texto,
                                               4000,
                                               8001)));
         --| texto padrao de garantia
         v_texto := null;
         open crtexto(3);
         fetch crtexto
            into v_texto;
         close crtexto;
         v_garantia := rtrim(ltrim(dbms_lob.substr(v_texto,
                                                   4000,
                                                   1)));
      
         --| texto padrao de condições de pagamento
         v_texto := null;
         open crtexto(4);
         fetch crtexto
            into v_texto;
         close crtexto;
         v_cond_pag := rtrim(ltrim(dbms_lob.substr(v_texto,
                                                   4000,
                                                   1)));
      
         --| texto padrao de validade da proposta
         v_texto := null;
         open crtexto(5);
         fetch crtexto
            into v_texto;
         close crtexto;
         v_validade := rtrim(ltrim(dbms_lob.substr(v_texto,
                                                   4000,
                                                   1)));
      
         v_dt_entrega_prop := reg.dt_entrega_prop;
      
         if v_dt_entrega_prop is null then
            v_dt_entrega_prop := trunc(sysdate) + 5;
         end if;
      
         update oc_proposta a
            set obs                 = v_obs1
               ,obs2                = v_obs2
               ,obs3                = v_obs3
               ,garantia            = v_garantia
               ,a.cond_pagto        = v_cond_pag
               ,a.validade_proposta = v_validade
               ,dt_entrega_prop     = v_dt_entrega_prop
         
          where a.seq_ocprop = p_seq;
      
      end loop;
   end;
   --------------------------------------------------------------------------------------------------------------------
   --/ Atualizar proposta com valores do orcamento
   --------------------------------------------------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------

   procedure atualiza_proposta_orcto(p_emp  cd_empresas.empresa%type
                                    ,p_fil  cd_filiais.filial%type
                                    ,p_seq  oc_orcam_venda.id_orcamvenda%type
                                    ,p_seqi oc_orcam_prod.id_orcamprod%type) is
   
      cursor cr is
         select a.seq_ocprop
               ,max(b.item)
           from oc_proposta  a
               ,oc_prop_item b
          where a.id_orcamvenda = p_seq
            and b.seq_ocprop = a.seq_ocprop
          group by a.seq_ocprop
         --and not exists
         --(select 1 from oc_proposta a where id_orcamvenda = p_seq)
         ;
   
      cursor cr1 is
         select g.per_icms
               ,decode(nvl(g.per_icms,
                           0),
                       0,
                       'N',
                       'S') icms_incl
               ,g.per_iss
               ,decode(nvl(g.per_iss,
                           0),
                       0,
                       'N',
                       'S') iss_incl
               ,g.per_pis_cofins
               ,decode(nvl(g.per_pis_cofins,
                           0),
                       0,
                       'N',
                       'S') piscof_incl
               ,g.per_csll
               ,case
                   when nvl(g.per_csll,
                            0) = 0 or
                        g.per_csll <= 1.08 then
                    'N'
                   else
                    'S'
                end csll_incl
               ,g.per_inss
               ,decode(nvl(g.per_inss,
                           0),
                       0,
                       'N',
                       'S') inss_incl
               ,v.per_ir
               ,case
                   when nvl(v.per_ir,
                            0) = 0 or
                        v.per_ir <= 2 then
                    'N'
                   else
                    'S'
                end ir_incl
               ,g.margem
               ,g.per_ipi
               ,decode(nvl(g.per_ipi,
                           0),
                       0,
                       'N',
                       'S') ipi_incl_icms
               ,a.*
           from oc_orcam_prod       a
               ,gs_preco_venda_prod g
               ,gs_preco_venda      v
          where a.id_orcamvenda = p_seq
            and (p_seqi is null or a.id_orcamprod = p_seqi)
            and g.id_orcamprod(+) = a.id_orcamprod
            and v.empresa(+) = g.empresa
            and v.nr_pc_seq(+) = g.nr_pc_seq
          order by a.item;
   
      cursor cr2(p_idprd number) is
         select a.* from oc_orcam_gr a where a.id_orcamprod = p_idprd;
   
      cursor crcont(p_cto in number) is
         select a.seq_contato
           from oc_contatos a
          where a.firma_oc = a.firma_oc
            and a.indice = 1;
      /*
         cursor crtexto(p_tipo number) is
            select texto from oc_texto_padrao where tipo = p_tipo;
      */
      cursor crachou(p_seq  oc_orcam_venda.id_orcamvenda%type
                    ,p_idor oc_prop_item.id_orcamprod%type) is
         select seq_ocproit
           from oc_prop_item m
               ,oc_proposta  p
          where m.id_orcamprod = p_idor
            and m.seq_ocprop = p.seq_ocprop
            and p.id_orcamvenda = p_seq;
   
      v_seq     number(9);
      v_seq_itm number(9);
   
      v_cont       number(9);
      v_ind        number(2);
      v_cd_ocmerc  number(4);
      v_nro_prop   number(9);
      v_item       number(9) := 0;
      v_item2      number(9) := 0;
      v_item_str   varchar2(40);
      v_preco_simp number(15,
                          2);
      v_custo_unit number(15,
                          2);
      v_cod_clafis ft_clafis.cod_clafis%type;
   
      v_texto clob;
      v_obs1  varchar2(4000);
      v_obs2  varchar2(4000);
      v_obs3  varchar2(4000);
   
      v_garantia        varchar2(4000);
      v_cond_pag        varchar2(4000);
      v_validade        varchar2(4000);
      v_obs_frete       oc_prop_item.obs_frete%type;
      v_obs_entrega     oc_prop_item.obs_entrega%type;
      v_dt_entrega_prop date;
      v_achou           number(9); --| id do item do orcto na proposta
   begin
   
      open cr;
      fetch cr
         into v_seq
             ,v_item;
      close cr;
   
      if v_seq is null then
         raise_application_error(-20100,
                                 'Proposta não encontrada para atualização!');
      end if;
   
      atualiza_texto_padrao_prop(p_emp,
                                 p_fil,
                                 p_seq);
      /*
      for reg in cr loop
         v_seq := reg.id_orcamvenda;
         --|texto padrao para obs
         v_texto := null;
         open crtexto(0);
         fetch crtexto
            into v_texto;
         close crtexto;
      
         v_obs1 := rtrim(ltrim(dbms_lob.substr(v_texto,
                                               4000,
                                               1)));
         v_obs2 := rtrim(ltrim(dbms_lob.substr(v_texto,
                                               4000,
                                               4001)));
         v_obs3 := rtrim(ltrim(dbms_lob.substr(v_texto,
                                               4000,
                                               8001)));
         --| texto padrao de garantia
         v_texto := null;
         open crtexto(1);
         fetch crtexto
            into v_texto;
         close crtexto;
         v_garantia := rtrim(ltrim(dbms_lob.substr(v_texto,
                                                   4000,
                                                   1)));
      
         --| texto padrao de condições de pagamento
         v_texto := null;
         open crtexto(2);
         fetch crtexto
            into v_texto;
         close crtexto;
         v_cond_pag := rtrim(ltrim(dbms_lob.substr(v_texto,
                                                   4000,
                                                   1)));
      
         --| texto padrao de validade da proposta
         v_texto := null;
         open crtexto(3);
         fetch crtexto
            into v_texto;
         close crtexto;
         v_validade := rtrim(ltrim(dbms_lob.substr(v_texto,
                                                   4000,
                                                   1)));
      
         v_dt_entrega_prop := reg.dt_entrega_prop;
      
         if v_dt_entrega_prop is null then
            v_dt_entrega_prop := trunc(sysdate) + 5;
         end if;
      
         update oc_proposta a
            set obs                 = v_obs1
               ,obs2                = v_obs2
               ,obs3                = v_obs3
               ,garantia            = v_garantia
               ,a.cond_pagto        = v_cond_pag
               ,a.validade_proposta = v_validade
               ,dt_entrega_prop     = v_dt_entrega_prop
          where a.seq_ocprop = p_seq;
      
      end loop;
      */
      --| itens da proposta
   
      for reg1 in cr1 loop
      
         begin
            v_preco_simp := null;
            v_custo_unit := (nvl(reg1.custo_prod,
                                 0) + nvl(reg1.custo_mo,
                                           0)) / reg1.qtd;
         
            v_preco_simp := round(v_custo_unit *
                                  (100 / (100 - round(nvl(reg1.margem,
                                                          0),
                                                      2))),
                                  2);
         exception
            when others then
               null;
         end;
         --/
         v_cod_clafis := null;
         if nvl(reg1.produto,
                0) > 0 then
            v_cod_clafis := ce_produtos_utl.cod_clafis(reg1.empresa,
                                                       reg1.produto);
         end if;
      
         if nvl(v_cod_clafis,
                0) > 0 then
            v_cod_clafis := null;
         end if;
      
         v_achou := 0;
      
         open crachou(p_seq,
                      reg1.id_orcamprod);
         fetch crachou
            into v_achou;
         close crachou;
      
         if nvl(v_achou,
                0) = 0 then
            --/inclui
            select oc_prop_item_seq.nextval into v_seq_itm from dual;
            v_item := v_item + 1;
            insert into oc_prop_item
               (seq_ocproit
               ,seq_ocprop
               ,item
               ,empresa
               ,produto
               ,qtde
               ,status
               ,dt_sis
               ,usu_sis
               ,peso_unit
               ,preco_unit
               ,preco_unit_simp
               ,custo_unit
               ,forma_pagto
               ,capacidade
               ,obs
               ,prazo_entr
               ,contrato
               ,valor_neg
               ,aliq_icms
               ,aliq_ipi
               ,descr_compl
               ,tipo_frete
               ,perc_frete
               ,comprimento
               ,largura
               ,classe
               ,icms_incl
               ,produto_oc
               ,perc_pc
               ,piscof_incl
               ,perc_inss
               ,inss_incl
               ,perc_ir
               ,ir_sll
               ,perc_iss
               ,iss_incl
               ,perc_csll
               ,csll_sll
               ,ipi_incl_icms
               ,margem
               ,id_orcamprod
               ,cod_clafis
               ,obs_frete
               ,obs_entrega)
            values
               (v_seq_itm
               ,v_seq
               ,v_item
               ,p_emp
               ,reg1.produto
               ,reg1.qtd
               ,'D'
               , --orcando
                sysdate
               ,user
               ,reg1.peso_liq / reg1.qtd
               , --pPESO_UNIT       ,
                reg1.preco / reg1.qtd
               , --PRECO_UNIT      ,
                v_preco_simp
               , --preco_sem impostos      ,
                v_custo_unit
               , --CUSTO_UNIT      ,
                null
               , --FORMA_PAGTO     ,
                null
               , --CAPACIDADE      ,
                null
               , --OBS             ,
                null
               , --PRAZO_ENTR      ,
                null
               , --CONTRATO        ,
                null
               , --VALOR_NEG       ,
                reg1.per_icms
               , --ALIQ_ICMS       ,
                reg1.per_ipi
               , --ALIQ_IPI        ,
                reg1.descr_prod
               , -- DESCR_COMPL     ,
                null
               , --TIPO_FRETE      ,
                null
               , -- PERC_FRETE      ,
                null
               , -- COMPRIMENTO     ,
                null
               , -- LARGURA         ,
                null
               , -- CLASSE
                'S'
               ,reg1.produto_orc
               ,reg1.per_pis_cofins
               ,reg1.piscof_incl
               ,reg1.per_inss
               ,reg1.inss_incl
               ,reg1.per_ir
               ,reg1.ir_incl
               ,reg1.per_iss
               ,reg1.iss_incl
               ,reg1.per_csll
               ,reg1.csll_incl
               ,reg1.ipi_incl_icms
               ,reg1.margem
               ,reg1.id_orcamprod
               ,v_cod_clafis
               ,null --v_obs_frete
               ,null --v_obs_entrega
                );
         
            for reg2 in cr2(reg1.id_orcamprod) loop
               v_item2 := v_item2 + 1;
               if reg2.grupo is null then
                  v_item_str := lpad(to_char(v_item2),
                                     3,
                                     '0');
               else
                  v_item_str := reg2.grupo;
               end if;
            
               insert into oc_prop_item_estr
                  (seq_ocproites
                  ,seq_ocproit
                  ,item
                  ,descricao
                  ,complemento
                  ,empresa
                  ,produto
                  ,qtd
                  ,unidade
                  ,valor_unit)
               values
                  (oc_prop_item_estr_seq.nextval
                  ,v_seq_itm
                  ,v_item_str
                  ,reg2.descr
                  ,null
                  , --COMPLEMENTO   ,
                   null
                  , --EMPRESA       ,
                   null
                  , --PRODUTO       ,
                   1
                  , --QTD           ,
                   'UND'
                  , --UNIDADE       ,
                   reg2.preco / reg1.qtd --VALOR_UNIT
                   );
            end loop;
         else
            --| achou item na proposta
            update oc_prop_item m
               set produto         = reg1.produto
                  ,qtde            = reg1.qtd
                  ,peso_unit       = reg1.peso_liq --/ reg1.qtd
                  ,preco_unit      = reg1.preco / reg1.qtd
                  ,preco_unit_simp = v_preco_simp
                  ,custo_unit      = v_custo_unit
                  ,aliq_icms       = reg1.per_icms
                  ,aliq_ipi        = reg1.per_ipi
                  ,descr_compl     = reg1.descr_prod
                  ,produto_oc      = reg1.produto_orc
                  ,perc_pc         = reg1.per_pis_cofins
                  ,piscof_incl     = reg1.piscof_incl
                  ,perc_inss       = reg1.per_inss
                  ,inss_incl       = reg1.inss_incl
                  ,perc_ir         = reg1.per_ir
                  ,ir_sll          = reg1.ir_incl
                  ,perc_iss        = reg1.per_iss
                  ,iss_incl        = reg1.iss_incl
                  ,perc_csll       = reg1.per_csll
                  ,csll_sll        = reg1.csll_incl
                  ,ipi_incl_icms   = reg1.ipi_incl_icms
                  ,margem          = reg1.margem
                  ,cod_clafis      = v_cod_clafis
             where m.seq_ocproit = v_achou;
         end if;
      end loop;
   
      commit;
   end;
   --|------------------------------------------------------------------
   procedure copiar_espec_tec_rev(p_cd       oc_proposta.cd_prop%type
                                 ,p_rev      oc_proposta.revisao%type
                                 ,p_item     oc_prop_item.item%type
                                 ,p_itm_dest oc_prop_item.seq_ocproit%type) is
      --| origem
      cursor cr_orig is
         select b.seq_ocproit
               ,b.item
           from oc_proposta  a
               ,oc_prop_item b
          where a.cd_prop = p_cd
            and a.revisao = p_rev
            and b.item = p_item
            and b.seq_ocprop = a.seq_ocprop;
   
      --| detalhes da origem
      cursor cr(p_seq number) is
         select c.* from oc_prop_item_estr c where c.seq_ocproit = p_seq;
   
      v_seq number(9);
   
   begin
      for regorig in cr_orig loop
         for reg in cr(v_seq) loop
            insert into oc_prop_item_estr
               (seq_ocproites
               ,seq_ocproit
               ,item
               ,descricao
               ,complemento
               ,empresa
               ,produto
               ,qtd
               ,unidade
               ,valor_unit)
            values
               (oc_prop_item_estr_seq.nextval
               ,p_itm_dest
               ,reg.item
               ,reg.descricao
               ,reg.complemento
               ,reg.empresa
               ,reg.produto
               ,reg.qtd
               ,reg.unidade
               ,reg.valor_unit);
         end loop;
      end loop;
   end;
   ---------------------------------------------------------------------------------------------
   procedure copiar_inclusao_rev_s(p_cd       oc_proposta.cd_prop%type
                                  ,p_rev      oc_proposta.revisao%type
                                  ,p_item     oc_prop_item.item%type
                                  ,p_itm_dest oc_prop_item.seq_ocproit%type) is
   
      --| sem pragma autonomous_transaction;
      cursor cr is
         select b.seq_ocproit
           from oc_proposta  a
               ,oc_prop_item b
          where a.cd_prop = p_cd
            and a.revisao = p_rev
            and b.item = p_item
            and b.seq_ocprop = a.seq_ocprop;
   
      cursor cr2(p_itm oc_prop_item.item%type) is
         select c.* from oc_prop_item_incl c where c.seq_ocproit = p_itm;
   
   begin
      for reg in cr loop
         for reg2 in cr2(reg.seq_ocproit) loop
            insert into oc_prop_item_incl
               (seq_ocproitin
               ,seq_ocproit
               ,item
               ,descricao
               ,complemento
               ,vl_incl)
            values
               (oc_prop_item_incl_seq.nextval
               ,p_itm_dest
               ,reg2.item
               ,reg2.descricao
               ,reg2.complemento
               ,reg2.vl_incl);
         end loop;
      end loop;
   end;
   ---------------------------------------------------------------------------------------------
   procedure copiar_exclusao_rev_s(p_cd       oc_proposta.cd_prop%type
                                  ,p_rev      oc_proposta.revisao%type
                                  ,p_item     oc_prop_item.item%type
                                  ,p_itm_dest oc_prop_item.seq_ocproit%type) is
   
      --| sem pragma autonomous_transaction;
      cursor cr is
         select b.seq_ocproit
           from oc_proposta  a
               ,oc_prop_item b
          where a.cd_prop = p_cd
            and a.revisao = p_rev
            and b.item = p_item
            and b.seq_ocprop = a.seq_ocprop;
   
      cursor cr2(p_item oc_prop_item.seq_ocproit%type) is
         select c.* from oc_prop_item_excl c where c.seq_ocproit = p_item;
   
   begin
      for reg in cr loop
         for reg2 in cr2(reg.seq_ocproit) loop
            insert into oc_prop_item_excl
               (seq_ocproitex
               ,seq_ocproit
               ,item
               ,descricao
               ,complemento)
            values
               (oc_prop_item_excl_seq.nextval
               ,p_itm_dest
               ,reg2.item
               ,reg2.descricao
               ,reg2.complemento
                
                );
         end loop;
      end loop;
   end;
   ---------------------------------------------------------------------------------------------
   procedure copiar_inclusao_rev(p_prop oc_proposta.seq_ocprop%type
                                ,p_seq  oc_proposta.seq_ocprop%type
                                ,p_cd   oc_proposta.cd_prop%type
                                ,p_rev  oc_proposta.revisao%type) is
   
      pragma autonomous_transaction;
      cursor cr is
         select item item2
               ,a.seq_ocproit
           from oc_prop_item a
          where a.seq_ocprop = p_prop;
   
      cursor cr2(p_item oc_prop_item.item%type) is
         select b.item item2
               ,c.*
           from oc_proposta       a
               ,oc_prop_item      b
               ,oc_prop_item_incl c
          where c.seq_ocproit = b.seq_ocproit
            and b.seq_ocprop = a.seq_ocprop
            and (p_cd is null or a.cd_prop = p_cd)
            and (p_rev is null or a.revisao = p_rev)
            and (p_seq is null or a.seq_ocprop = p_seq)
            and b.item = p_item;
   
   begin
      for reg in cr loop
         for reg2 in cr2(reg.item2) loop
            insert into oc_prop_item_incl
               (seq_ocproitin
               ,seq_ocproit
               ,item
               ,descricao
               ,complemento
               ,vl_incl)
            values
               (oc_prop_item_incl_seq.nextval
               ,reg.seq_ocproit
               ,reg2.item
               ,reg2.descricao
               ,reg2.complemento
               ,reg2.vl_incl);
         end loop;
      end loop;
      commit;
   end;
   ---------------------------------------------------------------------------------------------
   procedure copiar_exclusao_rev(p_prop oc_proposta.seq_ocprop%type
                                ,p_seq  oc_proposta.seq_ocprop%type
                                ,p_cd   oc_proposta.cd_prop%type
                                ,p_rev  oc_proposta.revisao%type) is
   
      pragma autonomous_transaction;
      cursor cr is
         select item item2
               ,a.seq_ocproit
           from oc_prop_item a
          where a.seq_ocprop = p_prop;
   
      cursor cr2(p_item oc_prop_item.item%type) is
         select b.item item2
               ,c.*
           from oc_proposta       a
               ,oc_prop_item      b
               ,oc_prop_item_excl c
          where c.seq_ocproit = b.seq_ocproit
            and b.seq_ocprop = a.seq_ocprop
            and (p_cd is null or a.cd_prop = p_cd)
            and (p_rev is null or a.revisao = p_rev)
            and (p_seq is null or a.seq_ocprop = p_seq)
            and b.item = p_item;
   
   begin
      for reg in cr loop
         for reg2 in cr2(reg.item2) loop
            insert into oc_prop_item_excl
               (seq_ocproitex
               ,seq_ocproit
               ,item
               ,descricao
               ,complemento)
            values
               (oc_prop_item_excl_seq.nextval
               ,reg.seq_ocproit
               ,reg2.item
               ,reg2.descricao
               ,reg2.complemento
                
                );
         end loop;
      end loop;
      commit;
   end;
   --/------------------------------------------------------------------------------------------------
   procedure gerar_espec_tecnica(p_seq   oc_prop_item.seq_ocproit%type
                                ,p_idprd oc_prop_item.id_orcamprod%type) is
      cursor cr is
         select * from oc_prop_item a where a.seq_ocproit = p_seq;
   
      cursor cr2 is
         select a.* from oc_orcam_gr a where a.id_orcamprod = p_idprd;
   
      v_item2    number(9);
      v_item_str oc_prop_item_estr.item%type;
   
   begin
      delete from oc_prop_item_estr a where a.seq_ocproit = p_seq;
   
      for reg1 in cr loop
      
         for reg2 in cr2 loop
            v_item2 := v_item2 + 1;
            if reg2.grupo is null then
               v_item_str := lpad(to_char(v_item2),
                                  3,
                                  '0');
            else
               v_item_str := reg2.grupo;
            end if;
         
            insert into oc_prop_item_estr
               (seq_ocproites
               ,seq_ocproit
               ,item
               ,descricao
               ,complemento
               ,empresa
               ,produto
               ,qtd
               ,unidade
               ,valor_unit)
            values
               (oc_prop_item_estr_seq.nextval
               ,reg1.seq_ocproit
               ,v_item_str
               ,reg2.descr
               ,null
               , --COMPLEMENTO   ,
                null
               , --EMPRESA       ,
                null
               , --PRODUTO       ,
                reg2.qtde
               , --QTD           ,
                'UND'
               , --UNIDADE       ,
                reg2.preco / reg2.qtde --VALOR_UNIT
                );
         end loop;
      end loop;
      commit;
   exception
      when others then
         rollback;
         raise_application_error(-20100,
                                 'OC_ORCAM.Gerar_Espec_Tecnica: ' ||
                                 substr(sqlerrm,
                                        1,
                                        200));
   end;
   --/------------------------------------------------------------------
   procedure gerar_eap_op(p_emp cd_empresas.empresa%type
                         ,p_fil cd_filiais.filial%type
                         ,p_con pp_contratos.contrato%type) is
      cursor cr is
         select e.ordem
               ,c.seq_ocproit
               ,
                
                c.seq_ocproites
               ,
                
                lpad(b.item,
                     2,
                     '0') || '.' || lpad(c.item,
                                         3,
                                         '0') cd_eap
               ,c.descricao
               ,b.id_orcamprod
               ,g.custo_prod
               ,g.custo_mo
               ,g.peso_bruto
               ,nvl(g.custo_prod,
                    0) + nvl(g.custo_mo,
                             0) custo_total
               ,g.peso_liq
               ,g.preco
               ,g.qtde qtde_gr
           from oc_prop_item      b
               ,oc_prop_item_estr c
               ,pp_ordens         e
               ,oc_orcam_prod     f
               ,oc_orcam_gr       g
          where c.seq_ocproit = b.seq_ocproit
            and e.seq_ocproit = b.seq_ocproit
            and f.id_orcamprod = b.id_orcamprod
            and g.id_orcamprod = f.id_orcamprod
            and g.grupo = c.item
            and b.empresa = p_emp
            and b.contrato = p_con
         --and 1=2
         union
         select e.ordem
               ,c.seq_ocproit
               ,
                
                c.seq_ocproites
               ,
                
                lpad(b.item,
                     2,
                     '0') || '.' || lpad(c.item,
                                         3,
                                         '0') cd_eap
               ,c.descricao
               ,b.id_orcamprod
               ,g.custo_prod
               ,g.custo_mo
               ,g.peso_bruto
               ,nvl(g.custo_prod,
                    0) + nvl(g.custo_mo,
                             0) custo_total
               ,g.peso_liq
               ,g.preco
               ,g.qtde qtde_gr
           from oc_prop_item      b
               ,oc_prop_item_estr c
               ,pp_ordens         e
               ,oc_orcam_prod     f
               ,oc_orcam_gr       g
          where c.seq_ocproit = b.seq_ocproit
            and e.seq_ocproit = b.seq_ocproit
            and f.id_orcamprod(+) = b.id_orcamprod
            and g.id_orcamprod(+) = f.id_orcamprod
            and g.seq_ocorcamgr is null
            and b.empresa = p_emp
            and b.contrato = p_con;
   
   begin
      for reg in cr loop
         insert into pp_eap_proj
            (id_eap
            ,cd_eap
            ,descricao
            ,empresa
            ,filial
            ,opos
            ,usu_incl
            ,dt_incl
            ,paralelo
            ,peso_bruto
            ,peso_liq
            ,vl_total
            ,custo_total_prev
            ,custo_mp_prev
            ,custo_mod_prev
            ,leadtime
            ,dt_prev_ini
            ,dt_prev_fim
            ,perc_concl
            ,cronograma_f
            ,seq_ocproites)
         values
            (pp_eap_proj_seq.nextval
            ,reg.cd_eap
            ,reg.descricao
            ,p_emp
            ,p_fil
            ,reg.ordem
            ,user
            ,sysdate
            ,'S' --paralelo
            ,reg.peso_bruto
            ,reg.peso_liq
            ,reg.preco --VL_TOTAL
            ,reg.custo_total --CUSTO_TOTAL_PREV
            ,reg.custo_prod --CUSTO_MP_PREV
            ,reg.custo_mo
            ,0 --LEADTIME
            ,null --DT_PREV_INI
            ,null --DT_PREV_FIM
            ,0 --PERC_CONCL
            ,'S' --CRONOGRAMA_F
            ,reg.seq_ocproites
             
             );
      
      end loop;
      commit;
   end;
   --------------------------------------------------------------------------------------------------
   --/ processo local chamado pela copiar_partes_proposta
   --/-----------------------------------------------------------------------------------------------
   procedure copiar_espec_tec(p_prop_orig oc_proposta.seq_ocprop%type
                             ,p_item_orig oc_prop_item.seq_ocproit%type
                             ,p_prop_dest oc_proposta.seq_ocprop%type
                             ,p_item_dest oc_prop_item.seq_ocproit%type) is
      --| origem
      cursor cr_orig is
         select b.seq_ocproit
               ,b.item
           from oc_proposta  a
               ,oc_prop_item b
          where a.seq_ocprop = p_prop_orig
            and b.seq_ocprop = a.seq_ocprop
            and (p_item_orig is null or b.seq_ocproit = p_item_orig)
            and b.seq_ocproit != nvl(p_item_dest,
                                     0)
         
         ;
      --| detalhes da origem
      cursor cr(p_itm number) is
         select c.*
           from oc_proposta       a
               ,oc_prop_item      b
               ,oc_prop_item_estr c
          where b.seq_ocprop = a.seq_ocprop
            and c.seq_ocproit = b.seq_ocproit
            and a.seq_ocprop = p_prop_orig
            and (p_itm is null or b.item = p_itm)
            and (p_item_orig is null or b.seq_ocproit = p_item_orig);
   
      --| destino
      cursor crd(p_itm number) is
         select b.seq_ocproit
           from oc_proposta  a
               ,oc_prop_item b
          where b.seq_ocprop = a.seq_ocprop
            and a.seq_ocprop = p_prop_dest
            and (p_itm is null or b.item = p_itm)
            and (p_item_dest is null or b.seq_ocproit = p_item_dest);
   
      v_itm number(9);
   
   begin
      for regorig in cr_orig loop
      
         if p_item_dest is not null then
            delete from oc_prop_item_estr m
             where m.seq_ocproit = p_item_dest
               and m.seq_ocproit != nvl(p_item_orig,
                                        0);
         else
            delete from oc_prop_item_estr m
             where m.seq_ocproit in
                   (select b.seq_ocproit
                      from oc_prop_item b
                     where b.seq_ocprop = p_prop_dest
                       and b.seq_ocproit != nvl(p_item_orig,
                                                0));
         end if;
      
         -- destino
         if (p_prop_orig != p_prop_dest and p_item_dest is null) or
            p_item_dest is null then
            v_itm := regorig.item;
         else
            v_itm := null;
         end if;
      
         for regdest in crd(v_itm) loop
         
            for reg in cr(v_itm) loop
               insert into oc_prop_item_estr
                  (seq_ocproites
                  ,seq_ocproit
                  ,item
                  ,descricao
                  ,complemento
                  ,empresa
                  ,produto
                  ,qtd
                  ,unidade
                  ,valor_unit)
               values
                  (oc_prop_item_estr_seq.nextval
                  ,regdest.seq_ocproit
                  ,reg.item
                  ,reg.descricao
                  ,reg.complemento
                  ,reg.empresa
                  ,reg.produto
                  ,reg.qtd
                  ,reg.unidade
                  ,reg.valor_unit);
            end loop;
         
         end loop;
      
      end loop;
   end;

   --------------------------------------------------------------------------------------------------
   --/ processo local chamado pela copiar_partes_proposta
   --/-----------------------------------------------------------------------------------------------
   procedure copiar_frete_entrega(p_prop_orig oc_proposta.seq_ocprop%type
                                 ,p_item_orig oc_prop_item.seq_ocproit%type
                                 ,p_prop_dest oc_proposta.seq_ocprop%type
                                 ,p_item_dest oc_prop_item.seq_ocproit%type) is
   
      cursor cro is
         select b.seq_ocproit
               ,b.item
           from oc_proposta  a
               ,oc_prop_item b
          where a.seq_ocprop = p_prop_orig
            and b.seq_ocprop = a.seq_ocprop
            and (p_item_orig is null or b.seq_ocproit = p_item_orig);
   
      cursor croi(p2_id number) is
         select b.obs_frete
               ,b.obs_entrega
               ,b.prazo_entr
               ,b.perc_frete
               ,b.tipo_frete
                
               ,b.cod_clafis
               ,b.preco_unit
               ,b.preco_unit_simp
               ,b.dias_entrega
               ,b.tipo_dias
               ,b.valor_neg
               ,b.aliq_icms
               ,b.aliq_ipi
               ,b.icms_incl
               ,b.classe
               ,b.perc_pc
               ,b.piscof_incl
               ,b.perc_inss
               ,b.inss_incl
               ,b.perc_ir
               ,b.ir_sll
               ,b.perc_iss
               ,b.iss_incl
               ,b.perc_csll
               ,b.perc_irrf
               ,b.ipi_incl_icms
               ,b.margem
           from oc_proposta  a
               ,oc_prop_item b
          where b.seq_ocprop = a.seq_ocprop
            and b.seq_ocproit = p2_id;
   
      cursor crd(p_item number) is
         select b.seq_ocproit
           from oc_proposta  a
               ,oc_prop_item b
          where b.seq_ocprop = a.seq_ocprop
            and a.seq_ocprop = p_prop_dest
            and ((p_item_dest is null and b.item = p_item) or
                (b.seq_ocproit = p_item_dest));
   
      v_id number(9);
   
   begin
      for reg2 in cro loop
      
         -- destino
         v_id := null;
      
         open crd(reg2.item);
         fetch crd
            into v_id;
         close crd;
      
         for reg in croi(reg2.seq_ocproit) loop
         
            update oc_prop_item b
               set obs_frete    = reg.obs_frete
                  ,obs_entrega  = reg.obs_entrega
                  ,b.prazo_entr = reg.prazo_entr
                  ,b.perc_frete = reg.perc_frete
                  ,b.tipo_frete = reg.tipo_frete
                   
                  ,b.cod_clafis      = reg.cod_clafis
                  ,b.preco_unit      = reg.preco_unit
                  ,b.preco_unit_simp = reg.preco_unit_simp
                  ,b.dias_entrega    = reg.dias_entrega
                  ,b.tipo_dias       = reg.tipo_dias
                   --,b.valor_neg       = reg.valor_neg
                  ,b.aliq_icms     = reg.aliq_icms
                  ,b.aliq_ipi      = reg.aliq_ipi
                  ,b.icms_incl     = reg.icms_incl
                  ,b.classe        = reg.classe
                  ,b.perc_pc       = reg.perc_pc
                  ,b.piscof_incl   = reg.piscof_incl
                  ,b.perc_inss     = reg.perc_inss
                  ,b.inss_incl     = reg.inss_incl
                  ,b.perc_ir       = reg.perc_ir
                  ,b.ir_sll        = reg.ir_sll
                  ,b.perc_iss      = reg.perc_iss
                  ,b.iss_incl      = reg.iss_incl
                  ,b.perc_csll     = reg.perc_csll
                  ,b.perc_irrf     = reg.perc_irrf
                  ,b.ipi_incl_icms = reg.ipi_incl_icms
                  ,b.margem        = reg.margem
             where b.seq_ocproit = v_id;
         
         end loop;
      
      end loop;
   end;
   --------------------------------------------------------------------------------------------------
   --/ processo local chamado pela copiar_partes_proposta
   --/-----------------------------------------------------------------------------------------------
   procedure copiar_inclusao(p_prop_orig oc_proposta.seq_ocprop%type
                            ,p_item_orig oc_prop_item.seq_ocproit%type
                            ,p_prop_dest oc_proposta.seq_ocprop%type
                            ,p_item_dest oc_prop_item.seq_ocproit%type) is
   
      cursor cro is
         select b.seq_ocproit
               ,b.item
           from oc_proposta  a
               ,oc_prop_item b
          where a.seq_ocprop = p_prop_orig
            and b.seq_ocprop = a.seq_ocprop
            and (p_item_orig is null or b.seq_ocproit = p_item_orig);
   
      cursor cr is
         select c.*
           from oc_proposta       a
               ,oc_prop_item      b
               ,oc_prop_item_incl c
          where b.seq_ocprop = a.seq_ocprop
            and c.seq_ocproit = b.seq_ocproit
            and a.seq_ocprop = p_prop_orig
            and (p_item_orig is null or b.seq_ocproit = p_item_orig);
   
      cursor crd(p_item oc_prop_item.item%type) is
         select b.seq_ocproit
           from oc_proposta  a
               ,oc_prop_item b
          where b.seq_ocprop = a.seq_ocprop
            and a.seq_ocprop = p_prop_dest
            and ((p_item_dest is null and b.item = p_item) or
                (b.seq_ocproit = p_item_dest));
   
      v_id number(9);
   
   begin
   
      for reg2 in cro loop
      
         if p_item_dest is not null then
            delete from oc_prop_item_incl m where m.seq_ocproit = p_item_dest;
         else
            delete from oc_prop_item_incl m
             where m.seq_ocproit in
                   (select b.seq_ocproit
                      from oc_prop_item b
                     where b.seq_ocprop = p_prop_dest);
         end if;
         -- destino
         open crd(reg2.item);
         fetch crd
            into v_id;
         close crd;
      
         for reg in cr loop
            insert into oc_prop_item_incl
               (seq_ocproitin
               ,seq_ocproit
               ,item
               ,descricao
               ,complemento
               ,vl_incl)
            values
               (oc_prop_item_incl_seq.nextval
               ,v_id
               ,reg.item
               ,reg.descricao
               ,reg.complemento
               ,reg.vl_incl);
         end loop;
      end loop;
   end;

   --------------------------------------------------------------------------------------------------
   --/ processo local chamado pela copiar_partes_proposta
   --/-----------------------------------------------------------------------------------------------
   procedure copiar_exclusao(p_prop_orig oc_proposta.seq_ocprop%type
                            ,p_item_orig oc_prop_item.seq_ocproit%type
                            ,p_prop_dest oc_proposta.seq_ocprop%type
                            ,p_item_dest oc_prop_item.seq_ocproit%type) is
   
      --origem
      cursor cro is
         select b.seq_ocproit
               ,b.item
           from oc_proposta  a
               ,oc_prop_item b
          where a.seq_ocprop = p_prop_orig
            and b.seq_ocprop = a.seq_ocprop
            and (p_item_orig is null or b.seq_ocproit = p_item_orig);
      --origem tecnica
      cursor cr is
         select c.*
           from oc_proposta       a
               ,oc_prop_item      b
               ,oc_prop_item_excl c
          where b.seq_ocprop = a.seq_ocprop
            and c.seq_ocproit = b.seq_ocproit
            and a.seq_ocprop = p_prop_orig
            and (p_item_orig is null or b.seq_ocproit = p_item_orig);
   
      cursor crd(p_item oc_prop_item.item%type) is
         select b.seq_ocproit
           from oc_proposta  a
               ,oc_prop_item b
          where b.seq_ocprop = a.seq_ocprop
            and a.seq_ocprop = p_prop_dest
            and ((p_item_dest is null and b.item = p_item) or
                (b.seq_ocproit = p_item_dest));
   
      v_id number(9);
   
   begin
   
      for reg2 in cro loop
      
         if p_item_dest is not null then
            delete from oc_prop_item_excl m where m.seq_ocproit = p_item_dest;
         else
            delete from oc_prop_item_excl m
             where m.seq_ocproit in
                   (select b.seq_ocproit
                      from oc_prop_item b
                     where b.seq_ocprop = p_prop_dest);
         end if;
      
         -- destino
         open crd(reg2.item);
         fetch crd
            into v_id;
         close crd;
      
         for reg in cr loop
         
            insert into oc_prop_item_excl
               (seq_ocproitex
               ,seq_ocproit
               ,item
               ,descricao
               ,complemento)
            values
               (oc_prop_item_excl_seq.nextval
               ,v_id
               ,reg.item
               ,reg.descricao
               ,reg.complemento);
         
         end loop;
      end loop;
   end;
   --------------------------------------------------------------------------------------------------
   --/ processo local chamado pela copiar_partes_proposta
   --/ garantia/validade/Cond Pagto
   --/-----------------------------------------------------------------------------------------------
   procedure copiar_cabec(p_prop_orig oc_proposta.seq_ocprop%type
                         ,p_prop_dest oc_proposta.seq_ocprop%type) is
   
      cursor cr is
         select a.obs
               ,a.garantia
               ,a.validade_proposta
               ,a.cond_pagto
           from oc_proposta a
          where a.seq_ocprop = p_prop_orig;
   
      v_id number(9);
   
   begin
      v_id := p_prop_dest;
   
      for reg in cr loop
         update oc_proposta a
            set a.obs               = reg.obs
               ,a.garantia          = reg.garantia
               ,a.validade_proposta = reg.validade_proposta
               ,a.cond_pagto        = reg.cond_pagto
          where a.seq_ocprop = v_id;
      
      end loop;
   end;

   ---------------------------------------------------------------------------------------------
   procedure copiar_partes_proposta(p_prop_orig oc_proposta.seq_ocprop%type
                                   ,p_item_orig oc_prop_item.seq_ocproit%type
                                   ,p_prop_dest oc_proposta.seq_ocprop%type
                                   ,p_item_dest oc_prop_item.seq_ocproit%type
                                   ,p_parte     varchar2) is
      /*
      p_parte: (T) Todos 
               (ET)Especificac?o Tecnica
               (IN)Inclus?o
               (EX)Exclus?o
               (CA)Cabecalho (Garantia | Validade | Cond. pagamento
      */
   begin
      /*
      raise_application_error(-20100,p_Prop_Orig||' - '||
                           p_Item_Orig||' - '||
                           p_Prop_Dest||' - '||
                           p_Item_Dest||' - '||
                           p_parte);
        */
      if p_parte in ('T',
                     'ET') then
         copiar_espec_tec(p_prop_orig,
                          p_item_orig,
                          p_prop_dest,
                          p_item_dest);
      
      end if;
   
      if p_parte in ('T',
                     'IN') then
         copiar_inclusao(p_prop_orig,
                         p_item_orig,
                         p_prop_dest,
                         p_item_dest);
      end if;
   
      if p_parte in ('T',
                     'EX') then
         copiar_exclusao(p_prop_orig,
                         p_item_orig,
                         p_prop_dest,
                         p_item_dest);
      end if;
   
      if p_parte in ('T',
                     'CA') then
         copiar_cabec(p_prop_orig,
                      p_prop_dest);
      
         copiar_frete_entrega(p_prop_orig,
                              p_item_orig,
                              p_prop_dest,
                              p_item_dest);
      end if;
   
      commit;
   end;
   --|-------------------------------------------------------------------------------------------
   function fnc_obs(p_prop oc_proposta.seq_ocprop%type) return tstring is
      cursor cr is
         select p.obs
               ,p.obs2
               ,p.obs3
           from oc_proposta p
          where p.seq_ocprop = p_prop;
   
      v_ret  varchar2(32000);
      v_obs  varchar2(10000);
      v_obs2 varchar2(10000);
      v_obs3 varchar2(10000);
   begin
      open cr;
      fetch cr
         into v_obs
             ,v_obs2
             ,v_obs3;
      close cr;
   
      v_ret := rtrim(rtrim(v_obs) || ' ' || rtrim(v_obs2) || ' ' ||
                     rtrim(v_obs3));
      return v_ret;
   end;
   ---|-------------------------------------------------------------------------------------------
   procedure pl_copiar_orcto(p_id             oc_orcam_venda.id_orcamvenda%type
                            ,p_id_org         oc_orcam_venda.id_orcamvenda%type
                            ,p_id_prd_org     oc_orcam_prod.id_orcamprod%type
                            ,p_id_prd         oc_orcam_prod.id_orcamprod%type
                            ,p_copiar_produto char
                            ,p_id_grupo       oc_orcam_gr.seq_ocorcamgr%type) is
   
      cursor cr is
         select id_orcamprod
               ,descr_prod
               ,produto_orc
               ,produto
               ,empresa
               ,qtd
               ,custo_prod
               ,custo_mo
               ,preco
               ,item
           from oc_orcam_prod
          where id_orcamvenda = p_id_org
            and (p_id_prd_org is null or id_orcamprod = p_id_prd_org);
   
      cursor crgr(p_id    number
                 ,p_id_gr number) is
         select grupo
               ,descr
               ,custo_prod
               ,custo_mo
               ,preco
               ,secundario
               ,seq_ocorcamgr
               ,qtde qtde_gr
         
           from oc_orcam_gr
          where id_orcamprod = p_id
            and (p_id_gr is null or seq_ocorcamgr = p_id_gr)
          order by grupo;
   
      cursor crpr(p_seq oc_orcam_gr.seq_ocorcamgr%type) is
         select seq_ocorgprod
               ,seq_ocorcamgr
               ,empresa
               ,produto
               ,prod_orc
               ,unidade
               ,qtde
               ,peso_liq
               ,peso_bruto
               ,fator
               ,manual
               ,custo_unit
               ,dt_custo
               ,origem
               ,rendimento
               ,custo_rend
               ,descr_prod
               ,gp.secundario
               ,gp.perc_recupev
               ,gp.comprimento
               ,gp.larg
               ,gp.qtd_pc
               ,gp.peso_esp
               ,gp.diam_int
               ,gp.diam_ext
               ,gp.altura
               ,gp.espessura
               ,gp.custo_unit_cimp
               ,gp.aliq_icms
               ,gp.aliq_ipi
               ,gp.aliq_piscof
               ,gp.item
           from oc_orcam_gr_prod gp
          where seq_ocorcamgr = p_seq
          order by seq_ocorgprod;
   
      --| copiar formacao de preco de venda
      cursor crpv0 is
         select 1 from gs_preco_venda gv where gv.id_orcamvenda = p_id;
   
      cursor crpv1 is
         select * from gs_preco_venda gv where gv.id_orcamvenda = p_id_org;
   
      cursor crpv2(p2_id number) is
         select * from gs_preco_venda_prod gvp where gvp.id_orcamprod = p2_id;
   
      v_seqgr        number(9);
      v_id_orcamprod number(9);
      v_achoupv      number(2);
      v_id_pv        number(9);
   begin
      /*
      raise_application_error(-20100,p_id  ||' - '||
                                    p_id_prd  ||' - '||
                                    p_copiar_produto  ||' - '||
                                    p_id_grupo);
      */
      /*
      delete from oc_orcam_gr_prod pr
       where seq_ocorcamgr in(select seq_ocorcamgr
                                from oc_orcam_gr gr
                               where gr.seq_ocproit = :OC_ORCAM_VENDA.seq_ocproit);
      delete from oc_orcam_gr
       where seq_ocproit = :OC_ORCAM_VENDA.seq_ocproit;
       */
      for reg0 in cr loop
      
         if p_copiar_produto = 'S' then
            select oc_orcam_prod_seq.nextval into v_id_orcamprod from dual;
         
            insert into oc_orcam_prod
               (id_orcamvenda
               ,id_orcamprod
               ,descr_prod
               ,produto
               ,produto_orc
               ,qtd
               ,custo_prod
               ,custo_mo
               ,preco
               ,status
               ,item)
            values
               (p_id
               ,v_id_orcamprod
               ,reg0.descr_prod
               ,reg0.produto
               ,reg0.produto_orc
               ,reg0.qtd
               ,reg0.custo_prod
               ,reg0.custo_mo
               ,reg0.preco
               ,'A'
               ,reg0.item);
         else
            v_id_orcamprod := p_id_prd;
         
         end if;
         --/
         for reg in crgr(reg0.id_orcamprod,
                         p_id_grupo) loop
         
            select oc_orcam_gr_seq.nextval into v_seqgr from dual;
         
            insert into oc_orcam_gr
               (seq_ocorcamgr
               ,id_orcamprod
               ,grupo
               ,descr
               ,secundario
               ,custo_mo
               ,custo_prod
               ,preco
               ,qtde)
            values
               (v_seqgr
               ,v_id_orcamprod
               ,reg.grupo
               ,reg.descr
               ,reg.secundario
               ,reg.custo_mo
               ,reg.custo_prod
               ,reg.preco
               ,reg.qtde_gr);
         
            for regpr in crpr(reg.seq_ocorcamgr) loop
               insert into oc_orcam_gr_prod
                  (seq_ocorgprod
                  ,seq_ocorcamgr
                  ,empresa
                  ,produto
                  ,prod_orc
                  ,unidade
                  ,qtde
                  ,peso_liq
                  ,peso_bruto
                  ,fator
                  ,manual
                  ,custo_unit
                  ,dt_custo
                  ,origem
                  ,rendimento
                  ,custo_rend
                  ,descr_prod
                  ,secundario
                  ,perc_recupev
                  ,comprimento
                  ,larg
                  ,qtd_pc
                  ,peso_esp
                  ,diam_int
                  ,diam_ext
                  ,altura
                  ,espessura
                  ,custo_unit_cimp
                  ,aliq_icms
                  ,aliq_ipi
                  ,aliq_piscof
                  ,item)
               values
                  (oc_orcam_gr_prod_seq.nextval
                  ,v_seqgr
                  ,regpr.empresa
                  ,regpr.produto
                  ,regpr.prod_orc
                  ,regpr.unidade
                  ,regpr.qtde
                  ,regpr.peso_liq
                  ,regpr.peso_bruto
                  ,regpr.fator
                  ,'S'
                  ,regpr.custo_unit
                  ,regpr.dt_custo
                  ,regpr.origem
                  ,regpr.rendimento
                  ,regpr.custo_rend
                  ,regpr.descr_prod
                  ,regpr.secundario
                  ,regpr.perc_recupev
                  ,regpr.comprimento
                  ,regpr.larg
                  ,regpr.qtd_pc
                  ,regpr.peso_esp
                  ,regpr.diam_int
                  ,regpr.diam_ext
                  ,regpr.altura
                  ,regpr.espessura
                  ,regpr.custo_unit_cimp
                  ,regpr.aliq_icms
                  ,regpr.aliq_ipi
                  ,regpr.aliq_piscof
                  ,regpr.item);
            end loop;
         end loop;
      
         --| copiar formação de preço
         begin
            open crpv0;
            fetch crpv0
               into v_achoupv;
            close crpv0;
         
            if nvl(v_achoupv,
                   0) = 0 then
            
               if nvl(v_id_pv,
                      0) = 0 then
                  for regpv in crpv1 loop
                     select gs_preco_venda_seq.nextval into v_id_pv from dual;
                  
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
                        ,per_imposto
                        ,formula_calc
                        ,per_fabric
                        ,per_royal
                        ,per_ir)
                     values
                        (regpv.empresa
                        ,v_id_pv
                        ,regpv.mercado
                        ,regpv.consumidor
                        ,trunc(sysdate)
                        ,p_id
                        ,regpv.moeda
                        ,regpv.comissao
                        ,regpv.per_desp
                        ,regpv.per_adm
                        ,regpv.per_imposto
                        ,regpv.formula_calc
                        ,regpv.per_fabric
                        ,regpv.per_royal
                        ,regpv.per_ir);
                  end loop;
               end if;
            
               for regpv2 in crpv2(reg0.id_orcamprod) loop
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
                     ,per_inss)
                  values
                     (regpv2.empresa
                     ,v_id_pv
                     ,gs_preco_venda_prod_seq.nextval
                     ,null
                     ,null
                     ,regpv2.produto
                     ,regpv2.produto_orc
                     ,regpv2.descr_prod
                     ,regpv2.custo
                     ,regpv2.peso
                     ,regpv2.qtd
                     ,reg0.id_orcamprod
                     ,regpv2.margem
                     ,regpv2.per_iss
                     ,regpv2.per_pis_cofins
                     ,regpv2.per_csll
                     ,regpv2.per_inss);
               end loop;
            end if;
         exception
            when others then
               null;
            
         end;
      end loop;
      commit;
   
   end;

   --|--------------------------------------------------------------------------
   procedure gerar_orcamento_desenho(p_idprd     oc_orcam_prod.id_orcamprod%type
                                    ,p_emp       pp_desenho.empresa%type
                                    ,p_fil       pp_desenho.filial%type
                                    ,p_des       pp_desenho.desenho%type
                                    ,p_ver       pp_desenho_ver.versao%type
                                    ,p_qtde      number
                                    ,p_grp       oc_orcam_gr.grupo%type
                                    ,p_max_filho char default 'S'
                                    ,p_opos      pp_ordens.ordem%type) is
      /*
      select pp.quantidade
                  ,pp.pos_desenhover
                  ,pp.id_desenhover
                  ,d.id_desenho
                  ,pp.posicao
                  ,pp.descricao      descr_pos
                  ,d.descricao       descr_des
                  ,v.versao
                  ,d.desenho
              from pp_desenho_pos pp
                  ,pp_desenho     d
                  ,pp_desenho_ver v
                  ,pp_desenho_ver vp
                  ,pp_desenho     dp
             where dp.desenho = '001.1.0015'
               and vp.versao = '01'
               and vp.id_desenho = dp.id_desenho
               and pp.id_desenhover = vp.id_desenhover
               and pp.tp_posicao = 'D'
               and dp.tipo = 'D'
               and v.id_desenhover = pp.pos_desenhover
               and d.id_desenho = v.id_desenho
               and vp.versao = (select max(v2.versao)
                                  from pp_desenho_ver v2
                                 where v2.id_desenho = dp.id_desenho)
             order by d.desenho
                     ,pp.posicao; 
                     */
      cursor cr0 is
         select * from t_des_f order by rowid;
   
      cursor cr(pc_des pp_desenho.desenho%type
               ,pc_ver pp_desenho_ver.versao%type) is
         select d.desenho
               ,d.descricao descr_des
               ,v.versao
               ,po.quantidade qtd_pc
               ,po.posicao
               ,po.pos_produto
               ,po.descricao descr_pos
               ,ce_produtos_utl.descricao(po.empresa,
                                          po.pos_produto) descr_prod
               ,po.comprimento
               ,po.largura
               ,po.unid_pos unidade
               ,po.peso_unit
               ,po.peso_total peso_total
               ,po.peso_acabado_total peso_acabado_total
               ,po.qtd_unid qtd_unid
         
           from pp_desenho_pos po
               ,pp_desenho_ver v
               ,pp_desenho     d
          where d.id_desenho = v.id_desenho
            and po.id_desenhover = v.id_desenhover
            and po.tp_posicao = 'P'
            and d.desenho = pc_des
            and v.versao = pc_ver
          order by d.desenho
                  ,v.versao
                  ,po.posicao;
   
      cursor cr_param is
         select * from gs_param where empresa = p_emp;
   
      v_cabec_gr  boolean;
      v_id_gr     number(9);
      v_des       varchar2(40);
      v_grupo     varchar2(40);
      v_grupo2    varchar2(40);
      v_conta     number;
      v_peso_acab number;
      v_peso_br   number;
      reg_param   gs_param%rowtype;
      v_item      number(9);
   
   begin
      open cr_param;
      fetch cr_param
         into reg_param;
      close cr_param;
   
      --| gera filhotes
      -- Call the procedure
      if p_opos is not null then
         pp_rel.t_des_op_f(1,
                           1,
                           p_opos,
                           p_des,
                           p_ver,
                           p_qtde,
                           p_max_filho);
      else
         pp_rel.prc_t_des_f(1,
                            1,
                            p_des,
                            p_ver,
                            p_qtde,
                            p_max_filho);
      end if;
   
      v_grupo := p_grp;
      for reg0 in cr0 loop
         v_conta := 0;
      
         if reg0.nivel is not null and
            reg0.nivel > '0' then
            if length(reg0.nivel) = 1 then
               v_grupo := p_grp || '.' || lpad(reg0.nivel,
                                               2,
                                               '0');
            else
               v_grupo := replace(p_grp || '.' || reg0.nivel,
                                  '..',
                                  '.');
            end if;
         end if;
      
         v_cabec_gr := false;
         for reg in cr(reg0.desenho,
                       reg0.versao) loop
         
            if not v_cabec_gr then
               v_cabec_gr := true;
               v_des      := reg.desenho;
            
               v_grupo2 := v_grupo; --lib_util.mascara(replace(v_grupo,'.','')||lpad(v_conta,2,'0'),'99.99.99');
               v_conta  := 1;
            
               select oc_orcam_gr_seq.nextval into v_id_gr from dual;
            
               insert into oc_orcam_gr
                  (seq_ocorcamgr
                  ,grupo
                  ,descr
                  ,id_orcamprod
                  ,eap
                  ,secundario
                  ,desenho
                  ,versao
                  ,qtde
                  ,obs)
               values
                  (v_id_gr
                  ,v_grupo2
                  ,reg.descr_des
                  ,p_idprd
                  ,null
                  ,'N'
                  ,reg0.desenho
                  ,reg0.versao
                  ,reg0.qtde --p_qtde
                  ,'Des: ' || reg0.desenho || ' - ' || reg0.versao);
            
               -- v_cabec_gr := false;
               v_item := 0;
            end if;
            if nvl(reg.peso_total,
                   0) = 0 then
               if reg.comprimento > 0 then
                  v_peso_acab := reg.comprimento * reg.peso_unit / 1000;
               
                  if reg.largura > 0 then
                     v_peso_acab := v_peso_acab * reg.largura / 1000;
                  end if;
                  v_peso_acab := v_peso_acab * reg.qtd_pc;
               else
                  v_peso_acab := reg.qtd_pc * reg.peso_unit;
               end if;
            else
               v_peso_acab := reg.peso_total;
            end if;
         
            if nvl(reg_param.fator_metal,
                   0) > 0 then
               v_peso_br := v_peso_acab * reg_param.fator_metal;
            else
               v_peso_br := v_peso_acab;
            end if;
            v_item := v_item + 1;
            insert into oc_orcam_gr_prod p
               (item
               ,seq_ocorgprod
               ,seq_ocorcamgr
               ,empresa
               ,produto
               ,unidade
               ,qtde
               ,qtd_pc
               ,peso_liq
               ,peso_bruto
               ,comprimento
               ,larg
               ,peso_esp
               ,fator
               ,manual
               ,custo_unit
               ,dt_custo
               ,origem
               ,rendimento
               ,custo_rend
               ,grupo
               ,tp_custo
               ,descr_prod
               ,prod_orc
               ,secundario)
            values
               (v_item
               ,oc_orcam_gr_prod_seq.nextval
               ,v_id_gr
               ,p_emp
               ,reg.pos_produto
               ,reg.unidade
               ,reg.qtd_unid
               ,reg.qtd_pc
               ,reg.peso_total --peso_liq, 
               ,v_peso_br
               ,reg.comprimento
               ,reg.largura
               ,reg.peso_unit
               ,reg_param.fator_metal --fator, 
               ,'S' --manual, 
               ,co_ordens_utl.ultimo_preco(1,
                                           reg.pos_produto) --custo_unit, 
               ,null --dt_custo, 
               ,'U' --origem, 
               ,reg_param.rend_hh --rendimento, 
               ,reg_param.valor_hr --custo_rend, 
               ,null --grupo, 
               ,null --tp_custo, 
               ,reg.descr_prod -- descr_prod, 
               ,null --prod_orc, 
               ,'N' --secundario
                );
         
         end loop;
      end loop;
      commit;
   end;
   --|-----------------------------------------------------
   procedure envia_solicitacao_email(p_id           number
                                    ,p_remetente    varchar2
                                    ,p_destinatario varchar2) is
      cursor cr0 is
         select * from oc_solic_orcam a where a.id_solicorcam = p_id;
   
      cursor cr1(p_id0 oc_solic_orcam.id_solicorcam%type) is
         select *
           from oc_solic_orc_prod p
          where p.id_solicorcam = p_id0
          order by p.id_solicorcprod;
   
      cursor cr2(p_id1 oc_solic_orc_prod.id_solicorcprod%type) is
         select r.*
               ,rs.descr
               ,rs.resp_padrao
           from oc_solic_orc_req r
               ,oc_requisito_orc rs
          where r.id_solicorcprod = p_id1
            and rs.id_requistorc = r.id_requistorc
          order by r.id_solicorcreq;
   
      v_texto        varchar2(32000);
      v_motivo_email varchar2(500);
      v_crlf         varchar2(10);
      v_subject      varchar2(500);
   
      clob_css   clob;
      clob_final clob;
      clob_corpo clob;
   
   begin
      v_texto        := 'Solicitação(' || p_id || ')';
      v_motivo_email := 'Solicitação de Orçamento';
      v_crlf         := chr(10);
      clob_css       := '<HTML>
        <HEAD>
          <TITLE>SAGE</TITLE>
          <META HTTP-EQUIV="Pragma"       CONTENT="no-cache">
          <META HTTP-EQUIV="Expires"      CONTENT="-1">
          <META NAME="Copyright" CONTENT="SERMASA">
          <META HTTP-EQUIV="us-ascii" CONTENT="text/html; charset=us-ascii">
          <META NAME="robots" CONTENT="noindex">
        <STYLE>
        </STYLE>
        </THEAD>
        <TBODY>';
      /*
      <html>
      <head>
        <meta http-equiv="content-type"
       content="text/html; charset=ISO-8859-1">
        <title></title>
      </head>
      <body>
      Orçamento: 001 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
      &nbsp; &nbsp; &nbsp; &nbsp; Data: 01/01/2015 <br>
      Solicitante: Jose &nbsp; &nbsp; &nbsp; &nbsp;
      &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
      &nbsp;Entrega Proposta: 30/01/2015<br>
      ------------------------------------------------------------------------<br>
      &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
      &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
      &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
      &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
      Produto<br>
      Código&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
      &nbsp;&nbsp;&nbsp; &nbsp;
      Descrição &nbsp;
      &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
      &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
      &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
      &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
      &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
      &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
      &nbsp; &nbsp; 
      Qtde<br>
      <table style="text-align: left; width: 538px; height: 273px;"
       border="1" cellpadding="2" cellspacing="1">
        <tbody>
          <tr>
            <td style="width: 70px;">10009</td>
            <td style="width: 300px;">condensador</td>
            <td style="width: 60px;">10</td>
          </tr>
          
        </tbody>
      </table>
      </body>
      </html>
              
              */
      clob_final := ' </TBODY>';
   
      v_subject  := 'Solicitacao de Orcamento: ' || p_id;
      clob_corpo := empty_clob;
   
      for reg in cr0 loop
         clob_corpo := clob_corpo || '<body>
          Orçamento: ' || reg.id_solicorcam ||
                       ' &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
          &nbsp; &nbsp; &nbsp; &nbsp; Data: ' ||
                       to_char(reg.dt,
                               'dd/mm/rrrr') || ' <br>
          Solicitante: ' || reg.resp ||
                       ' &nbsp; &nbsp; &nbsp; &nbsp;
          &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
          &nbsp;Entrega Proposta:' ||
                       to_char(reg.entrega_prop,
                               'dd/mm/rrrr') ||
                       '<br>
         ------------------------------------------------------------------------<br>';
      
      end loop;
   
      clob_corpo := clob_corpo || '<h5> Data: ' ||
                    to_char(sysdate,
                            'DD/MM/YYYY hh24:mi:ss') || '</h5>';
      clob_corpo := clob_corpo ||
                    '<h6> E-Mail gerado automaticamente pelo sistema SGN-ERP </h5>';
   
      --clob_corpo := clob_css || v_cab || clob_corpo || clob_final;
   
      lib_html.html_email(p_remetente, --v_email,
                          p_destinatario,
                          v_subject,
                          'texto',
                          'mail.sermasa.com.br',
                          465,
                          clob_corpo);
   
   exception
      when others then
         --v_env_email := 'N';
         raise_application_error(-20200,
                                 sqlerrm);
   end;
   --/--------------------------------------------------------------------------
   --/ GERAR TEMP RESUMO ABC DE PRODUTOS NO ORCTO
   --/--------------------------------------------------------------------------

   procedure gerar_resumo_orcto_abc(p_id  oc_orcam_venda.id_orcamvenda%type
                                   ,p_sec char default 'N') is
      cursor cr is
         select id_orcamvenda
               ,orcto
               ,produto
               ,descr_prod
               ,unidade
               ,qtde
               ,peso_liq
               ,peso_bruto
               ,custo_unitario_mp
               ,custo_total_mp
               ,total_hrs
               ,custo_mo
               ,total_custo
               ,custo_rend
               ,rendimento
               ,a.origem_produto
         
           from voc_orcto_custo_abc a
          where a.id_orcamvenda = p_id
            and (p_sec = 'S' or a.secundario = 'N');
   begin
   
      delete toc_orcto_custo_abc;
   
      for reg in cr loop
         insert into toc_orcto_custo_abc
            (id_orcamvenda
            ,orcto
            ,produto
            ,descr_prod
            ,unidade
            ,qtde
            ,peso_liq
            ,peso_bruto
            ,custo_unitario_mp
            ,custo_total_mp
            ,total_hrs
            ,custo_mo
            ,total_custo
            ,custo_rend
            ,rendimento
            ,produto_old
            ,descr_prod_old
            ,unidade_old
            ,custo_unitario_mp_old
            ,custo_rend_old
            ,rendimento_old
            ,origem_produto)
         values
            (reg.id_orcamvenda
            ,reg.orcto
            ,reg.produto
            ,reg.descr_prod
            ,reg.unidade
            ,reg.qtde
            ,reg.peso_liq
            ,reg.peso_bruto
            ,reg.custo_unitario_mp
            ,reg.custo_total_mp
            ,reg.total_hrs
            ,reg.custo_mo
            ,reg.total_custo
            ,reg.custo_rend
            ,reg.rendimento
            ,reg.produto
            ,reg.descr_prod
            ,reg.unidade
            ,reg.custo_unitario_mp
            ,reg.custo_rend
            ,reg.rendimento
            ,reg.origem_produto);
      end loop;
   end;

end oc_orcam;
/
