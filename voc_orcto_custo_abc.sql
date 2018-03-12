create or replace view voc_orcto_custo_abc as
select vv.id_orcamvenda
      ,id_orcamprod
      ,vv.orcto
      ,vv.produto
      ,vv.descr_prod
      ,vv.unidade
      ,sum(qtde_orcto * qtde_gr * vv.qtde) qtde
      ,round(sum(qtde_orcto * qtde_gr * vv.peso_liq),
             2) peso_liq
      ,round(sum(qtde_orcto * qtde_gr * vv.peso_bruto),
             2) peso_bruto
      ,vv.custo_unit custo_unitario_mp
      ,round(avg(vv.custo_rend),
             2) custo_rend
      ,round(avg(vv.rendimento),
             2) rendimento
       
      ,round(sum(qtde_orcto * qtde_gr * vv.custo_unit * vv.qtde),
             2) custo_total_mp
      ,round(sum(qtde_orcto * qtde_gr * vv.qtd_hr),
             2) total_hrs
      ,round(sum(qtde_orcto * qtde_gr * vv.custo_hr),
             2) custo_mo
      ,round(nvl(sum(qtde_orcto * qtde_gr * vv.custo_hr),
                 0),
             2) + round(nvl(sum(qtde_orcto * qtde_gr * vv.custo_unit * vv.qtde),
                            0),
                        2) total_custo
      ,origem_produto
      ,secundario
  from (select v.id_orcamvenda
              ,v.cd_orcam orcto
              ,p.id_orcamprod
              ,decode(p.produto,
                      null,
                      p.produto_orc,
                      p.produto) prod_orcto
              ,p.descr_prod descr_prod_orcto
              ,p.qtd qtde_orcto
               
              ,gr.qtde qtde_gr
               
              ,decode(gpr.produto,
                      null,
                      gpr.prod_orc,
                      gpr.produto) produto
              ,decode(gpr.produto,
                      null,
                      'ORCTO',
                      'OFICIAL') origem_produto
              ,gpr.descr_prod
              ,gpr.qtde
              ,gpr.unidade
              ,gpr.peso_liq
              ,gpr.peso_bruto
              ,gpr.custo_unit
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
              ,decode(gr.secundario,
                      'S',
                      gr.secundario,
                      gpr.secundario) secundario
          from oc_orcam_venda   v
              ,oc_orcam_prod    p
              ,oc_orcam_gr      gr
              ,oc_orcam_gr_prod gpr
         where gpr.seq_ocorcamgr = gr.seq_ocorcamgr
           and gr.id_orcamprod = p.id_orcamprod
           and p.id_orcamvenda = v.id_orcamvenda
           and v.rev = (select max(v2.rev)
                          from oc_orcam_venda v2
                         where v2.cd_orcam = v.cd_orcam)) vv
 group by vv.id_orcamvenda
         ,vv.id_orcamprod
         ,vv.orcto
         ,vv.custo_unit
         ,vv.produto
         ,vv.descr_prod
         ,vv.unidade
         ,origem_produto
         ,secundario;
