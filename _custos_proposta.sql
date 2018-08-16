select pc.proposta
      ,pc.contrato
      ,po.ordem opos
      ,po.descricao
      ,po.produto
    --,PRI.DESCR_COMPL
      ,po.quantidade qtde_opos
      ,sum(pri.custo_unit * pri.qtde) custo_total
      ,sum(nvl(pri.peso_unit,
               0) * pri.qtde) peso_total
      ,sum(pri.valor_neg) valor_neg
      
      ,sum(pri.preco_unit * pri.qtde) preco_total
      
      ,sum(oc_util.fnc_peso_total_prod(pri.id_orcamprod)) peso_liq_total
      
      ,sum(round(oc_util.fnc_hrs_total_prod(pri.id_orcamprod),
                 2)) hrs_total
                 
      ,sum(oc_util.fnc_custo_total_mod(pri.id_orcamprod)) custo_mod
      ,sum(oc_util.fnc_custo_total_material(pri.id_orcamprod)) custo_material
      ,ct_util.fnc_compras_pendentes_opos(po.empresa,
                                          po.filial,
                                          po.ordem) compras_pendentes
      ,ct_util.fnc_compras_recebidas_opos(po.empresa,
                                          po.filial,
                                          po.ordem) compras_recebidas
      ,prop.seq_ocprop
    --,pri.seq_ocproit
  from pp_ordens         po
      ,pp_contratos      pc
      ,oc_prop_item_opos props
      ,oc_proposta       prop
      ,oc_prop_item      pri
 where po.empresa     = pc.empresa
   and po.contrato    = pc.contrato
   and props.seq_ocproit = pri.seq_ocproit
   and props.empresa  = po.empresa
   and props.filial   = po.filial
   and props.opos     = po.ordem
   and pri.seq_ocprop = prop.seq_ocprop
   and prop.cd_prop = pc.proposta
   and pri.contrato = pc.contrato
   and pri.empresa  = pc.empresa
   and pc.contrato  = 420
-- and prop.seq_ocprop = 2167

 group by pc.proposta
         ,prop.seq_ocprop
         ,pc.contrato
         ,po.empresa
         ,po.filial
         ,po.ordem
         ,po.descricao
         ,po.produto
         ,po.quantidade
