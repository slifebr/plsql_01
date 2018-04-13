select sum(nvl(pendente,
               0))
  from --/solicitações pendentes
       (select opos
              ,sum(case
                      when saldo > 0 then
                       saldo * ultimo_preco
                      else
                       0
                   end) pendente
          from (select ir.opos
                      ,((ir.qtde_req - nvl(ir.qtd_cancel,
                                           0))) -
                       nvl((select sum(cot.qtde - nvl(cot.qtde_dev,
                                                     0))
                             from co_solcot cot
                            where cot.empresa = ir.empresa
                              and cot.filial = ir.filial
                              and cot.num_req = ir.num_req
                              and cot.item_req = ir.item_req),
                           0) saldo
                       
                      ,co_ordens_utl.ultimo_preco(ir.empresa,
                                                  ir.produto) ultimo_preco
                  from co_itens_req ir
                      ,co_requis    r
                 where ir.empresa = 1 --p_emp
                   and ir.filial = 1 --p_fil
                      -- and ir.opos = '9.15.201' --'1.17.351'--p_opos
                   and r.empresa = ir.empresa
                   and r.filial = ir.filial
                   and r.num_req = ir.num_req
                   and (r.origem in ('P',
                                     'C') or trunc(sysdate) - r.dt_req < 30)
                   and r.status != 'R'
                   and (ir.qtde_req - nvl(ir.qtd_cancel,
                                          0)) > 0
                   and ir.qtde_req > nvl((select sum(s.qtde)
                                           from co_solcot s
                                          where s.empresa = ir.empresa
                                            and s.filial = ir.filial
                                            and s.num_req = ir.num_req
                                            and s.item_req = ir.item_req),
                                         0)) v
         group by opos
        
        union all --\ cotações pendentes
        select opos
              ,round(sum((qtde_sol_cot_opos / qtde_sol_cot) * qtde_neg * preco),
                     2) pendente_opos
          from (select ir.opos opos
                      ,ic.num_req cotacao
                      ,ic.item_req item_cot
                      ,ic.qtde_neg
                      ,solc.qtde qtde_sol_cot_opos
                      ,(select sum(sc2.qtde)
                          from co_solcot sc2
                         where sc2.empresa = i.empresa
                           and sc2.filial = i.filial
                           and sc2.num_cot = i.num_cot
                           and sc2.item_cot = i.item_cot) qtde_sol_cot
                      ,ic.preco
                  from co_itens     i
                      ,co_itens_cot ic
                      ,co_solcot    solc
                      ,co_itens_req ir
                
                 where ic.empresa = i.empresa
                   and ic.filial = i.filial
                   and ic.num_req = i.num_cot
                   and ic.item_req = i.item_cot
                      
                   and ic.escolha = 1
                   and solc.empresa = i.empresa
                   and solc.filial = i.filial
                   and solc.num_cot = i.num_cot
                   and solc.item_cot = i.item_cot
                   and ir.empresa = solc.empresa
                   and ir.filial = solc.filial
                   and ir.num_req = solc.num_req
                   and ir.item_req = solc.item_req
                   and ir.opos = '9.15.301'
                      
                   and not exists (select 1
                          from co_itens_ord io
                         where io.num_req = i.num_cot
                           and io.item_req = i.item_cot
                           and io.empresa = i.empresa
                           and io. filial = i.filial)
                   and i.empresa = 1 --p_emp
                   and i.filial = 1 -- p_fil
                ) v2
         group by opos
        union all --\ ordens de compra pendentes
        select iop.opos , sum(co_ordens_utl.saldo_ordem(io.empresa,
                                             io.filial,
                                             io.ordem,
                                             io.item_req) * io.preco * iop.perc / 100) pendente
          from co_itens_ord    io
              ,co_itens_ord_op iop
              ,co_ordens       o
         where iop.empresa = io.empresa
           and iop.filial = io.filial
           and iop.ordem = io.ordem
           and iop.item_req = io.item_req
           and o.empresa = io.empresa
           and o.filial = io.filial
           and o.ordem = io.ordem
           and iop.opos =  '9.15.301'--p_opos
           and iop.empresa = 1--p_emp
           and iop.filial = 1--p_fil
           and (substr(iop.opos,
                       '1') != '9' or
               o.dt_ordem >= trunc(sysdate,
                                    'rr'))
           and io.qtd - nvl(io.qtd_can,0) > 0 
           and o.status != 'C'
           and (io.qtd - nvl(io.qtd_can,0)) > nvl( (select sum(io.qtd) 
                  from ce_itens_nf it 
                  where it.empresa = io.empresa 
                  and it.filial = io.filial 
                  and it.ordem = io.ordem 
                  and it.item_req = io.item_req
                  and it.qtd > nvl((select sum(itd.qtd_dev)
                                      from ce_itdev_nf itd
                                      where itd.seq_item = it.id),0)),0)
                                      group by iop.opos
)
