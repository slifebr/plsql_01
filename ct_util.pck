create or replace package ct_util is

   --||
   --|| CT_UTIL.PKS : Rotinas para CUSTOS
   --||
   --|-------------------------------------------------------
   --| FUNCTIONS
   --|-------------------------------------------------------
   --|-------------------------------------------------------

   --|-------------------------------------------------------
   --| fnc_compras_pendentes_opos
   --|-------------------------------------------------------
   function fnc_compras_pendentes_opos(p_emp  pp_ordens.empresa%type
                                      ,p_fil  pp_ordens.filial%type
                                      ,p_opos pp_ordens.ordem%type) return number;

   --|-------------------------------------------------------
   --| fnc_compras_recebidas_opos
   --|-------------------------------------------------------
   function fnc_compras_recebidas_opos(p_emp  pp_ordens.empresa%type
                                      ,p_fil  pp_ordens.filial%type
                                      ,p_opos pp_ordens.ordem%type) return number;
   --|-------------------------------------------------------
   --| fnc_compras_recebidas_opos_nf
   --|-------------------------------------------------------
   function fnc_compras_recebidas_opos_nf(p_emp  pp_ordens.empresa%type
                                      ,p_fil  pp_ordens.filial%type
                                      ,p_opos pp_ordens.ordem%type
                                      ,p_id ce_notas.id%type) return number;
   --|-------------------------------------------------------
   --| fnc_compras_pendentes_prop
   --|-------------------------------------------------------
   function fnc_compras_pendentes_prop(p_emp  pp_ordens.empresa%type
                                      ,p_fil  pp_ordens.filial%type
                                      ,p_prop pp_contratos.proposta%type)
      return number;

   --|-------------------------------------------------------
   --| fnc_compras_recebidas_prop
   --|-------------------------------------------------------
   function fnc_compras_recebidas_prop(p_emp  pp_ordens.empresa%type
                                      ,p_fil  pp_ordens.filial%type
                                      ,p_prop pp_contratos.proposta%type)
      return number;

   --|-------------------------------------------------------   
   --|-------------------------------------------------------
   --| PROCEDURES
   --|-------------------------------------------------------
   --|-------------------------------------------------------

   procedure gera_compras_opos(p_emp in ce_notas.empresa%type
                              ,p_fil in ce_notas.filial%type
                              ,p_dt  in date);
   --|--------------------------------------------------------------
   --| Orcado X Realizado OP/OS
   --|--------------------------------------------------------------
   procedure gera_orcado_realizado_opos(p_emp  pp_ordens.empresa%type
                                       ,p_fil  pp_ordens.filial%type
                                       ,p_opos pp_ordens.ordem%type);
   --|--------------------------------------------------------------
   --| Orcado X Realizado OP/OS - por solicitação de compra
   --|--------------------------------------------------------------
   procedure gera_orcado_realizado_opos_sol(p_emp pp_ordens.empresa%type
                                           ,p_fil pp_ordens.filial%type
                                           ,p_req co_requis.num_req%type);
   --|--------------------------------------------------------------
   --| Orcado X Realizado - PROPOSTA
   --|--------------------------------------------------------------
   procedure gera_orcado_realizado_prop(p_emp  pp_ordens.empresa%type
                                       ,p_fil  pp_ordens.filial%type
                                       ,p_prop pp_contratos.proposta%type);
   --|--------------------------------------------------------------
   --| Orcado X Realizado PROPOSTA - por solicitação de compra
   --|--------------------------------------------------------------
   procedure gera_orcado_realizado_prop_sol(p_emp pp_ordens.empresa%type
                                           ,p_fil pp_ordens.filial%type
                                           ,p_req co_requis.num_req%type);
end ct_util;
/
create or replace package body ct_util is

   --||
   --|| CT_UTIL.PKS : Rotinas para CUSTOS
   --||

   --|-------------------------------------------------------
   --|-------------------------------------------------------
   --| FUNCTIONS
   --|-------------------------------------------------------
   --|-------------------------------------------------------

   --|-------------------------------------------------------
   --| fnc_compras_pendentes_opos
   --|-------------------------------------------------------
   function fnc_compras_pendentes_opos(p_emp  pp_ordens.empresa%type
                                      ,p_fil  pp_ordens.filial%type
                                      ,p_opos pp_ordens.ordem%type) return number is
      cursor cr is
         select sum(nvl(pendente,
                        0))
           from --/solicitações pendentes
                (select sum(case
                               when saldo > 0 then
                                saldo * ultimo_preco
                               else
                                0
                            end) pendente
                   from (select ((ir.qtde_req - nvl(ir.qtd_cancel,
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
                          where ir.empresa = p_emp
                            and ir.filial = p_fil
                            and ir.opos = p_opos
                            and ir.qtde_req > nvl((select sum(s.qtde)
                                                    from co_solcot s
                                                   where s.empresa = ir.empresa
                                                     and s.filial = ir.filial
                                                     and s.num_req = ir.num_req
                                                     and s.item_req = ir.item_req),
                                                  0)) v
                 union all --\ cotações pendentes
                 select round(sum((qtde_sol_cot_opos / qtde_sol_cot) * qtde_neg *
                                  preco),
                              2) pendente_opos
                   from (select ic.num_req cotacao
                               ,ic.item_req item_cot
                               ,ic.qtde_neg
                               ,(select sum(sc2.qtde)
                                   from co_solcot    sc2
                                       ,co_itens_req ir
                                  where sc2.empresa = i.empresa
                                    and sc2.filial = i.filial
                                    and sc2.num_cot = i.num_cot
                                    and sc2.item_cot = i.item_cot
                                    and ir.empresa = sc2.empresa
                                    and ir.filial = sc2.filial
                                    and ir.num_req = sc2.num_req
                                    and ir.item_req = sc2.item_req
                                    and ir.opos = p_opos) qtde_sol_cot_opos
                               ,(select sum(sc2.qtde)
                                   from co_solcot sc2
                                  where sc2.empresa = i.empresa
                                    and sc2.filial = i.filial
                                    and sc2.num_cot = i.num_cot
                                    and sc2.item_cot = i.item_cot) qtde_sol_cot
                               ,ic.preco
                           from co_itens     i
                               ,co_itens_cot ic
                          where ic.empresa = i.empresa
                            and ic.filial = i.filial
                            and ic.num_req = i.num_cot
                            and ic.item_req = i.item_cot
                            and ic.escolha = 1
                            and exists (select 1
                                   from co_solcot    sc
                                       ,co_itens_req ir
                                  where sc.empresa = i.empresa
                                    and sc.filial = i.filial
                                    and sc.num_cot = i.num_cot
                                    and sc.item_cot = i.item_cot
                                    and ir.empresa = sc.empresa
                                    and ir.filial = sc.filial
                                    and ir.num_req = sc.num_req
                                    and ir.item_req = sc.item_req
                                    and ir.opos = p_opos)
                            and not exists
                          (select 1
                                   from co_itens_ord io
                                  where io.num_req = i.num_cot
                                    and io.item_req = i.item_cot
                                    and io.empresa = i.empresa
                                    and io. filial = i.filial)
                            and i.empresa = p_emp
                            and i.filial = p_fil) v2
                 union all --\ ordens de compra pendentes
                 select sum(co_ordens_utl.saldo_ordem(io.empresa,
                                                      io.filial,
                                                      io.ordem,
                                                      io.item_req) * io.preco *
                            iop.perc / 100) pendente
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
                    and iop.opos = p_opos
                    and iop.empresa = p_emp
                    and iop.filial = p_fil
                    and (substr(iop.opos,
                                '1') != '9' or
                        o.dt_ordem >= trunc(sysdate,
                                             'rr'))
                    and io.qtd - nvl(io.qtd_can,
                                     0) > 0
                    and o.status != 'C'
                    and (io.qtd - nvl(io.qtd_can,
                                      0)) >
                        nvl((select sum(io.qtd)
                              from ce_itens_nf it
                             where it.empresa = io.empresa
                               and it.filial = io.filial
                               and it.ordem = io.ordem
                               and it.item_req = io.item_req
                               and it.qtd > nvl((select sum(itd.qtd_dev)
                                                  from ce_itdev_nf itd
                                                 where itd.seq_item = it.id),
                                                0)),
                            0));
   
      v_ret number(15,
                   2);
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
   end;

   --|-------------------------------------------------------
   --| fnc_compras_recebidas_opos
   --|-------------------------------------------------------
   function fnc_compras_recebidas_opos(p_emp  pp_ordens.empresa%type
                                      ,p_fil  pp_ordens.filial%type
                                      ,p_opos pp_ordens.ordem%type) return number is
      cursor cr is
         select round(sum((v.recebido +
                          (v.recebido * nvl(aliq_ipi,
                                             0) / 100)) * perc_opos / 100),
                      2) recebido
           from (select (i.qtd - nvl((select sum(dev.qtd_dev)
                                       from ce_itdev_nf dev
                                      where dev.seq_item = i.id),
                                     0)) * i.valor_unit -
                        nvl(i.vl_desconto,
                            0) + nvl(i.vl_despesa,
                                     0) + nvl(i.vl_frete,
                                              0) +
                        nvl(i.vl_despesa,
                            0) + nvl(i.vl_acrescimo,
                                     0) recebido
                       ,i.aliq_ipi
                       ,iop.perc perc_opos
                   from ce_itens_nf     i
                       ,co_itens_ord_op iop
                  where i.empresa = iop.empresa
                    and i.filial = iop.filial
                    and i.ordem = iop.ordem
                    and i.item_req = iop.item_req
                    and iop.opos = p_opos
                    and iop.empresa = p_emp
                    and iop.filial = p_fil
                 union all
                 select (i.qtd - nvl((select sum(dev.qtd_dev)
                                       from ce_itdev_nf dev
                                      where dev.seq_item = i.id),
                                     0)) * i.valor_unit -
                        nvl(i.vl_desconto,
                            0) + nvl(i.vl_despesa,
                                     0) + nvl(i.vl_frete,
                                              0) +
                        nvl(i.vl_despesa,
                            0) + nvl(i.vl_acrescimo,
                                     0) recebido
                       ,i.aliq_ipi
                       ,100 perc_opos
                   from ce_itens_nf        i
                       ,co_req_compra_item rci
                       ,co_req_compra      rc
                  where i.id_reqcpraitem = rci.id
                    and rc.id = rci.id_req_compra
                    and rc.ordem = p_opos
                    and i.empresa = p_emp
                    and i.filial = p_fil) v;
   
      v_ret number(15,
                   2);
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
   end;
   
   --|-------------------------------------------------------
   --| fnc_compras_recebidas_opos_nf
   --|-------------------------------------------------------
   function fnc_compras_recebidas_opos_nf(p_emp  pp_ordens.empresa%type
                                      ,p_fil  pp_ordens.filial%type
                                      ,p_opos pp_ordens.ordem%type
                                      ,p_id ce_notas.id%type) return number is
      cursor cr is
         select round(sum((v.recebido +
                          (v.recebido * nvl(aliq_ipi,
                                             0) / 100)) * perc_opos / 100),
                      2) recebido
           from (select (i.qtd - nvl((select sum(dev.qtd_dev)
                                       from ce_itdev_nf dev
                                      where dev.seq_item = i.id),
                                     0)) * i.valor_unit -
                        nvl(i.vl_desconto,
                            0) + nvl(i.vl_despesa,
                                     0) + nvl(i.vl_frete,
                                              0) +
                        nvl(i.vl_despesa,
                            0) + nvl(i.vl_acrescimo,
                                     0) recebido
                       ,i.aliq_ipi
                       ,iop.perc perc_opos
                   from ce_itens_nf     i
                       ,co_itens_ord_op iop
                  where i.empresa = iop.empresa
                    and i.filial = iop.filial
                    and i.ordem = iop.ordem
                    and i.item_req = iop.item_req
                    and iop.opos = p_opos
                    and iop.empresa = p_emp
                    and iop.filial = p_fil
                    and i.id_ce_nota = p_id
                 union all
                 select (i.qtd - nvl((select sum(dev.qtd_dev)
                                       from ce_itdev_nf dev
                                      where dev.seq_item = i.id),
                                     0)) * i.valor_unit -
                        nvl(i.vl_desconto,
                            0) + nvl(i.vl_despesa,
                                     0) + nvl(i.vl_frete,
                                              0) +
                        nvl(i.vl_despesa,
                            0) + nvl(i.vl_acrescimo,
                                     0) recebido
                       ,i.aliq_ipi
                       ,100 perc_opos
                   from ce_itens_nf        i
                       ,co_req_compra_item rci
                       ,co_req_compra      rc
                  where i.id_reqcpraitem = rci.id
                    and rc.id = rci.id_req_compra
                    and rc.ordem = p_opos
                    and i.empresa = p_emp
                    and i.filial = p_fil
                    and i.id_ce_nota = p_id) v;
   
      v_ret number(15,
                   2);
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
   end;
   --/--------------------------------------------------------------------------------------
   function fnc_compras_pendentes_prop(p_emp  pp_ordens.empresa%type
                                      ,p_fil  pp_ordens.filial%type
                                      ,p_prop pp_contratos.proposta%type)
      return number is
      cursor cr is
         select sum(nvl(pendente,
                        0))
           from --/solicitações pendentes
                (select sum(case
                               when saldo > 0 then
                                saldo * ultimo_preco
                               else
                                0
                            end) pendente
                   from (select ((ir.qtde_req - nvl(ir.qtd_cancel,
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
                               ,pp_ordens    po
                               ,pp_contratos pc
                          where ir.empresa = p_emp
                            and ir.filial = p_fil
                            and po.empresa = ir.empresa
                            and po.filial = ir.filial
                            and po.ordem = ir.opos
                            and pc.empresa = po.empresa
                            and pc.contrato = po.contrato
                            and pc.proposta = p_prop
                            and ir.qtde_req > nvl((select sum(s.qtde)
                                                    from co_solcot s
                                                   where s.empresa = ir.empresa
                                                     and s.filial = ir.filial
                                                     and s.num_req = ir.num_req
                                                     and s.item_req = ir.item_req),
                                                  0)) v
                 union all --\ cotações pendentes
                 select round(sum((qtde_sol_cot_opos / qtde_sol_cot) * qtde_neg *
                                  preco),
                              2) pendente_opos
                   from (select ic.num_req cotacao
                               ,ic.item_req item_cot
                               ,ic.qtde_neg
                               ,(select sum(sc2.qtde)
                                   from co_solcot    sc2
                                       ,co_itens_req ir
                                       ,pp_ordens    po2
                                       ,pp_contratos pc2
                                  where sc2.empresa = i.empresa
                                    and sc2.filial = i.filial
                                    and sc2.num_cot = i.num_cot
                                    and sc2.item_cot = i.item_cot
                                    and ir.empresa = sc2.empresa
                                    and ir.filial = sc2.filial
                                    and ir.num_req = sc2.num_req
                                    and ir.item_req = sc2.item_req
                                    and po2.empresa = ir.empresa
                                    and po2.filial = ir.filial
                                    and po2.ordem = ir.opos
                                    and pc2.empresa = po2.empresa
                                    and pc2.contrato = po2.contrato
                                    and pc2.proposta = p_prop) qtde_sol_cot_opos
                               ,(select sum(sc2.qtde)
                                   from co_solcot sc2
                                  where sc2.empresa = i.empresa
                                    and sc2.filial = i.filial
                                    and sc2.num_cot = i.num_cot
                                    and sc2.item_cot = i.item_cot) qtde_sol_cot
                               ,ic.preco
                           from co_itens     i
                               ,co_itens_cot ic
                          where ic.empresa = i.empresa
                            and ic.filial = i.filial
                            and ic.num_req = i.num_cot
                            and ic.item_req = i.item_cot
                            and ic.escolha = 1
                            and exists (select 1
                                   from co_solcot    sc
                                       ,co_itens_req ir
                                       ,pp_ordens    po
                                       ,pp_contratos pc
                                  where sc.empresa = i.empresa
                                    and sc.filial = i.filial
                                    and sc.num_cot = i.num_cot
                                    and sc.item_cot = i.item_cot
                                    and ir.empresa = sc.empresa
                                    and ir.filial = sc.filial
                                    and ir.num_req = sc.num_req
                                    and ir.item_req = sc.item_req
                                    and po.empresa = ir.empresa
                                    and po.filial = ir.filial
                                    and po.ordem = ir.opos
                                    and pc.empresa = po.empresa
                                    and pc.contrato = po.contrato
                                    and pc.proposta = p_prop
                                    and ir.empresa = p_emp
                                    and ir.filial = p_fil
                                 
                                 )
                            and not exists
                          (select 1
                                   from co_itens_ord io
                                  where io.num_req = i.num_cot
                                    and io.item_req = i.item_cot
                                    and io.empresa = i.empresa
                                    and io. filial = i.filial)
                            and i.empresa = p_emp
                            and i.filial = p_fil) v2
                 union all --\ ordens de compra pendentes
                 select sum(co_ordens_utl.saldo_ordem(io.empresa,
                                                      io.filial,
                                                      io.ordem,
                                                      io.item_req) * io.preco *
                            iop.perc / 100) pendente
                   from co_itens_ord    io
                       ,co_itens_ord_op iop
                       ,co_ordens       o
                       ,pp_ordens       po
                       ,pp_contratos    pc
                  where iop.empresa = io.empresa
                    and iop.filial = io.filial
                    and iop.ordem = io.ordem
                    and iop.item_req = io.item_req
                    and o.empresa = io.empresa
                    and o.filial = io.filial
                    and o.ordem = io.ordem
                       
                    and po.empresa = iop.empresa
                    and po.filial = iop.filial
                    and po.ordem = iop.opos
                    and pc.empresa = po.empresa
                    and pc.contrato = po.contrato
                    and pc.proposta = p_prop
                    and (substr(iop.opos,
                                '1') != '9' or
                        o.dt_ordem >= trunc(sysdate,
                                             'rr'))
                    and iop.empresa = p_emp
                    and iop.filial = p_fil
                    and io.qtd - nvl(io.qtd_can,
                                     0) > 0
                    and o.status != 'C'
                    and (io.qtd - nvl(io.qtd_can,
                                      0)) >
                        nvl((select sum(io.qtd)
                              from ce_itens_nf it
                             where it.empresa = io.empresa
                               and it.filial = io.filial
                               and it.ordem = io.ordem
                               and it.item_req = io.item_req
                               and it.qtd > nvl((select sum(itd.qtd_dev)
                                                  from ce_itdev_nf itd
                                                 where itd.seq_item = it.id),
                                                0)),
                            0));
   
      v_ret number(15,
                   2);
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
   end;

   --|-------------------------------------------------------
   --| fnc_compras_recebidas_prop
   --|-------------------------------------------------------
   function fnc_compras_recebidas_prop(p_emp  pp_ordens.empresa%type
                                      ,p_fil  pp_ordens.filial%type
                                      ,p_prop pp_contratos.proposta%type)
      return number is
      cursor cr is
         select round(sum((v.recebido +
                          (v.recebido * nvl(aliq_ipi,
                                             0) / 100)) * perc_opos / 100),
                      2) recebido
           from (select (i.qtd - nvl((select sum(dev.qtd_dev)
                                       from ce_itdev_nf dev
                                      where dev.seq_item = i.id),
                                     0)) * i.valor_unit -
                        nvl(i.vl_desconto,
                            0) + nvl(i.vl_despesa,
                                     0) + nvl(i.vl_frete,
                                              0) +
                        nvl(i.vl_despesa,
                            0) + nvl(i.vl_acrescimo,
                                     0) recebido
                       ,i.aliq_ipi
                       ,iop.perc perc_opos
                   from ce_itens_nf     i
                       ,co_itens_ord_op iop
                       ,pp_ordens       po
                       ,pp_contratos    pc
                  where i.empresa = iop.empresa
                    and i.filial = iop.filial
                    and i.ordem = iop.ordem
                    and i.item_req = iop.item_req
                    and po.empresa = iop.empresa
                    and po.filial = iop.filial
                    and po.ordem = iop.opos
                    and pc.empresa = po.empresa
                    and pc.contrato = po.contrato
                    and pc.proposta = p_prop
                       
                    and iop.empresa = p_emp
                    and iop.filial = p_fil) v;
   
      v_ret number(15,
                   2);
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
   end;
   --|-------------------------------------------------------
   --|-------------------------------------------------------
   --| PROCEDURES
   --|-------------------------------------------------------
   --|-------------------------------------------------------

   --|-------------------------------------------------------
   --| compras realizadas para opos
   --|-------------------------------------------------------
   procedure gera_compras_opos(p_emp in ce_notas.empresa%type
                              ,p_fil in ce_notas.filial%type
                              ,p_dt  in date) is
      cursor cr is
         select cd_firmas_utl.nome(pc.firma) nome_cli
               ,pc.firma cliente
               ,pc.contrato
               ,iop.opos
               ,n.num_nota
               ,n.dt_entrada
               ,n.cod_fornec
               ,cd_firmas_utl.nome(n.cod_fornec) razao_social
               ,it.produto
               ,it.uni_ven unidade
               ,it.descricao
               ,sum(it.qtd) qtd
               ,sum(it.valor_unit * it.qtd) / sum(it.qtd) valor_unit
               ,
                
                sum(nvl(it.vl_icms,
                        0)) vl_icms
               ,sum(nvl(it.vl_ipi,
                        0)) vl_ipi
               ,sum(nvl(round((((it.qtd * it.valor_unit) +
                              nvl(it.vl_ipi,
                                    0)) * iop.perc / 100),
                              2),
                        0)) vlr_total
               ,co_ordens_utl.fnc_perc_opnf_prd(n.empresa,
                                                n.filial,
                                                n.num_nota,
                                                n.sr_nota,
                                                n.cod_fornec,
                                                n.parte,
                                                iop.opos,
                                                it.produto) perc_op_af
               ,io.ordem numero_af
               ,ce_produtos_utl.cod_conta(1,
                                          it.produto) cta_contabil
         
           from ce_itens_nf     it
               ,ce_notas        n
               ,co_itens_ord    io
               ,co_itens_ord_op iop
               ,pp_ordens       po
               ,pp_contratos    pc
               ,pp_ordens       po2
          where it.empresa = n.empresa
            and it.filial = n.filial
            and it.num_nota = n.num_nota
            and it.cod_fornec = n.cod_fornec
            and it.parte = n.parte
               
            and io.empresa = it.empresa
            and io.filial = it.filial
            and io.ordem = it.ordem
            and io.item_req = it.item_req
               
            and iop.empresa = io.empresa
            and iop.filial = io.filial
            and iop.ordem = io.ordem
            and iop.item_req = io.item_req
            and trunc(n.dt_entrada) between first_day(p_dt) and last_day(p_dt)
            and po.empresa = iop.empresa
            and po.filial = iop.filial
            and po.ordem = iop.opos
            and pc.empresa = po.empresa
            and pc.contrato = po.contrato
            and po2.empresa = po.empresa
            and po2.filial = po.filial
            and po2.ordem = decode(po.opos_fat,
                                   null,
                                   decode(po.ordem01,
                                          null,
                                          po.ordem,
                                          po.ordem01),
                                   po.opos_fat)
            and po2.contrato = po.contrato
            and n.empresa = p_emp
            and n.filial = p_fil
          group by pc.firma
                  ,pc.contrato
                  ,iop.opos
                  ,n.empresa
                  ,n.filial
                  ,n.sr_nota
                  ,n.parte
                  ,n.num_nota
                  ,n.dt_entrada
                  ,n.cod_fornec
                  ,it.produto
                  ,it.uni_ven
                  ,it.descricao
                  ,io.ordem
         
         union all
         select cd_firmas_utl.nome(pc.firma) nome_cli
               ,pc.firma cliente
               ,pc.contrato
               ,cr.ordem opos
               ,n.num_nota
               ,n.dt_entrada
               ,n.cod_fornec
               ,cd_firmas_utl.nome(n.cod_fornec) razao_social
               ,it.produto
               ,it.uni_ven unidade
               ,it.descricao
               ,sum(nvl(it.qtd,
                        0)) qtd
               ,sum(it.valor_unit * it.qtd) / sum(it.qtd) valor_unit
               ,sum(nvl(it.vl_icms,
                        0)) vl_icms
               ,sum(nvl(it.vl_ipi,
                        0)) vl_ipi
               ,sum(nvl(round(((it.qtd * it.valor_unit) +
                              nvl(it.vl_ipi,
                                   0)),
                              2),
                        0)) vlr_total
               ,100 perc_op_af
               ,cr.id numero_af
               ,ce_produtos_utl.cod_conta(1,
                                          it.produto) cta_contabil
         
           from ce_itens_nf        it
               ,ce_notas           n
               ,co_req_compra_item ioc
               ,co_req_compra      cr
               ,pp_ordens          po
               ,pp_contratos       pc
               ,pp_ordens          po2
          where it.empresa = n.empresa
            and it.filial = n.filial
            and it.num_nota = n.num_nota
            and it.cod_fornec = n.cod_fornec
            and it.parte = n.parte
               
            and ioc.id = it.id_reqcpraitem
            and cr.id = ioc.id_req_compra
               
            and trunc(n.dt_entrada) between first_day(p_dt) and last_day(p_dt)
            and po.empresa = cr.empresa
            and po.filial = cr.filial
            and po.ordem = cr.ordem
            and pc.empresa = po.empresa
            and pc.contrato = po.contrato
            and po2.empresa = po.empresa
            and po2.filial = po.filial
            and po2.contrato = po.contrato
            and po2.ordem = decode(po.opos_fat,
                                   null,
                                   decode(po.ordem01,
                                          null,
                                          po.ordem,
                                          po.ordem01),
                                   po.opos_fat)
            and n.empresa = p_emp
            and n.filial = p_fil
          group by pc.firma
                  ,pc.contrato
                  ,cr.ordem
                  ,n.num_nota
                  ,n.dt_entrada
                  ,n.cod_fornec
                  ,it.produto
                  ,it.uni_ven
                  ,it.descricao
                  ,cr.id
          order by produto
         /*order by 1
         ,2
         ,3
         ,4*/
         ;
   
   begin
      delete from ct_compras_op where dt_refer = last_day(p_dt);
      commit;
   
      for reg in cr loop
      
         insert into ct_compras_op
            (id
            ,dt_refer
            ,cliente
            ,contrato
            ,opos
            ,num_nota
            ,dt_entrada
            ,cod_fornec
            ,produto
            ,descricao
            ,qtd
            ,valor_unit
            ,vl_icms
            ,vl_ipi
            ,vlr_total
            ,perc_op_af
            ,numero_af
            ,cta_contabil
            ,unidade
            ,usu_incl
            ,dt_incl)
         values
            (ct_compras_op_seq.nextval
            ,last_day(p_dt)
            ,reg.cliente
            ,reg.contrato
            ,reg.opos
            ,reg.num_nota
            ,reg.dt_entrada
            ,reg.cod_fornec
            ,reg.produto
            ,reg.descricao
            ,reg.qtd
            ,reg.valor_unit
            ,reg.vl_icms
            ,reg.vl_ipi
            ,reg.vlr_total
            ,reg.perc_op_af
            ,reg.numero_af
            ,reg.cta_contabil
            ,reg.unidade
            ,user
            ,sysdate);
      end loop;
      commit;
   end;
   --|--------------------------------------------------------------
   --| Orcado X Realizado
   --|--------------------------------------------------------------
   procedure gera_orcado_realizado_opos(p_emp  pp_ordens.empresa%type
                                       ,p_fil  pp_ordens.filial%type
                                       ,p_opos pp_ordens.ordem%type) is
   
      v_custo_orcado_mp  number(15,
                                2);
      v_custo_orcado_mod number(15,
                                2);
      v_compras_pendente number(15,
                                2);
      v_compras_recebida number(15,
                                2);
      v_saldo            number(15,
                                2);
      v_proposta         varchar2(30);
      v_cliente          number(9);
      v_nome_cliente     varchar2(200);
   
   begin
      delete tct_orcado_realizado_opos;
      commit;
   
      v_custo_orcado_mp  := oc_util.fnc_custo_total_material_opos(p_emp,
                                                                  p_fil,
                                                                  p_opos);
      v_custo_orcado_mod := oc_util.fnc_custo_total_mod_opos(p_emp,
                                                             p_fil,
                                                             p_opos);
      v_compras_pendente := fnc_compras_pendentes_opos(p_emp,
                                                       p_fil,
                                                       p_opos);
      v_compras_recebida := fnc_compras_recebidas_opos(p_emp,
                                                       p_fil,
                                                       p_opos);
      v_proposta         := pp_util.get_proposta_opos(p_emp,
                                                      p_fil,
                                                      p_opos);
      v_cliente          := pp_util.codigo_cliente_op(p_emp,
                                                      p_fil,
                                                      p_opos);
      v_nome_cliente     := pp_util.cliente_op(p_emp,
                                               p_fil,
                                               p_opos);
   
      v_saldo := nvl(v_custo_orcado_mp,
                     0) - nvl(v_compras_pendente,
                              0) - nvl(v_compras_recebida,
                                       0);
   
      insert into tct_orcado_realizado_opos
         (empresa
         ,filial
         ,opos
         ,custo_orcado_mp
         ,custo_orcado_mod
         ,compras_pendente
         ,compras_recebida
         ,saldo
         ,proposta
         ,cliente
         ,nome_cliente)
      values
         (p_emp
         ,p_fil
         ,p_opos
         ,nvl(v_custo_orcado_mp,
              0)
         ,nvl(v_custo_orcado_mod,
              0)
         ,nvl(v_compras_pendente,
              0)
         ,nvl(v_compras_recebida,
              0)
         ,nvl(v_saldo,
              0)
         ,v_proposta
         ,v_cliente
         ,v_nome_cliente);
   
      commit;
   
   end;
   --|--------------------------------------------------------------
   --| Orcado X Realizado OP/OS - por solicitação de compra
   --|--------------------------------------------------------------
   procedure gera_orcado_realizado_opos_sol(p_emp pp_ordens.empresa%type
                                           ,p_fil pp_ordens.filial%type
                                           ,p_req co_requis.num_req%type) is
   
      cursor cr is
         select distinct a.opos
           from co_itens_req a
          where a.empresa = p_emp
            and a.filial = p_fil
            and a.num_req = p_req;
   
      v_custo_orcado_mp  number(15,
                                2);
      v_custo_orcado_mod number(15,
                                2);
      v_compras_pendente number(15,
                                2);
      v_compras_recebida number(15,
                                2);
      v_saldo            number(15,
                                2);
      v_proposta         varchar2(30);
      v_cliente          number(9);
      v_nome_cliente     varchar2(200);
   begin
      delete tct_orcado_realizado_opos;
      commit;
      for reg in cr loop
      
         v_custo_orcado_mp  := oc_util.fnc_custo_total_material_opos(p_emp,
                                                                     p_fil,
                                                                     reg.opos);
         v_custo_orcado_mod := oc_util.fnc_custo_total_mod_opos(p_emp,
                                                                p_fil,
                                                                reg.opos);
         v_compras_pendente := fnc_compras_pendentes_opos(p_emp,
                                                          p_fil,
                                                          reg.opos);
         v_compras_recebida := fnc_compras_recebidas_opos(p_emp,
                                                          p_fil,
                                                          reg.opos);
         v_proposta         := pp_util.get_proposta_opos(p_emp,
                                                         p_fil,
                                                         reg.opos);
         v_cliente          := pp_util.codigo_cliente_op(p_emp,
                                                         p_fil,
                                                         reg.opos);
         v_nome_cliente     := pp_util.cliente_op(p_emp,
                                                  p_fil,
                                                  reg.opos);
      
         v_saldo := nvl(v_custo_orcado_mp,
                        0) - nvl(v_compras_pendente,
                                 0) - nvl(v_compras_recebida,
                                          0);
      
         insert into tct_orcado_realizado_opos
            (empresa
            ,filial
            ,opos
            ,custo_orcado_mp
            ,custo_orcado_mod
            ,compras_pendente
            ,compras_recebida
            ,saldo
            ,proposta
            ,cliente
            ,nome_cliente)
         values
            (p_emp
            ,p_fil
            ,reg.opos
            ,nvl(v_custo_orcado_mp,
                 0)
            ,nvl(v_custo_orcado_mod,
                 0)
            ,nvl(v_compras_pendente,
                 0)
            ,nvl(v_compras_recebida,
                 0)
            ,nvl(v_saldo,
                 0)
            ,v_proposta
            ,v_cliente
            ,v_nome_cliente);
      end loop;
      commit;
   
   end;

   --|--------------------------------------------------------------
   --| Orcado X Realizado  - PROPOSTA
   --|--------------------------------------------------------------
   procedure gera_orcado_realizado_prop(p_emp  pp_ordens.empresa%type
                                       ,p_fil  pp_ordens.filial%type
                                       ,p_prop pp_contratos.proposta%type) is
   
      v_custo_orcado_mp  number(15,
                                2);
      v_custo_orcado_mod number(15,
                                2);
      v_compras_pendente number(15,
                                2);
      v_compras_recebida number(15,
                                2);
      v_saldo            number(15,
                                2);
      v_cliente          number(9);
      v_nome_cliente     varchar2(200);
   
   begin
      delete tct_orcado_realizado_opos;
      commit;
   
      v_custo_orcado_mp  := oc_util.fnc_custo_total_material_prop(p_emp,
                                                                  p_fil,
                                                                  p_prop);
      v_custo_orcado_mod := oc_util.fnc_custo_total_mod_prop(p_emp,
                                                             p_fil,
                                                             p_prop);
      v_compras_pendente := fnc_compras_pendentes_prop(p_emp,
                                                       p_fil,
                                                       p_prop);
      v_compras_recebida := fnc_compras_recebidas_prop(p_emp,
                                                       p_fil,
                                                       p_prop);
      v_cliente          := pp_util.codigo_cliente_prop(p_emp,
                                                        p_fil,
                                                        p_prop);
      v_nome_cliente     := pp_util.cliente_prop(p_emp,
                                                 p_fil,
                                                 p_prop);
   
      v_saldo := nvl(v_custo_orcado_mp,
                     0) - nvl(v_compras_pendente,
                              0) - nvl(v_compras_recebida,
                                       0);
   
      insert into tct_orcado_realizado_prop
         (empresa
         ,filial
         ,proposta
         ,custo_orcado_mp
         ,custo_orcado_mod
         ,compras_pendente
         ,compras_recebida
         ,saldo
         ,cliente
         ,nome_cliente)
      values
         (p_emp
         ,p_fil
         ,p_prop
         ,nvl(v_custo_orcado_mp,
              0)
         ,nvl(v_custo_orcado_mod,
              0)
         ,nvl(v_compras_pendente,
              0)
         ,nvl(v_compras_recebida,
              0)
         ,nvl(v_saldo,
              0)
         ,v_cliente
         ,v_nome_cliente);
   
      commit;
   
   end;

   --|--------------------------------------------------------------
   --| Orcado X Realizado PROPOSTA - por solicitação de compra
   --|--------------------------------------------------------------
   procedure gera_orcado_realizado_prop_sol(p_emp pp_ordens.empresa%type
                                           ,p_fil pp_ordens.filial%type
                                           ,p_req co_requis.num_req%type) is
   
      cursor cr is
         select distinct pc.proposta
           from co_itens_req a
               ,pp_ordens    po
               ,pp_contratos pc
          where a.empresa = p_emp
            and a.filial = p_fil
            and a.num_req = p_req
            and po.empresa = a.empresa
            and po.filial = a.filial
            and po.ordem = a.opos
            and pc.empresa = po.empresa
            and pc.contrato = po.contrato;
   
      v_custo_orcado_mp  number(15,
                                2);
      v_custo_orcado_mod number(15,
                                2);
      v_compras_pendente number(15,
                                2);
      v_compras_recebida number(15,
                                2);
      v_saldo            number(15,
                                2);
      v_proposta         varchar2(30);
      v_cliente          number(9);
      v_nome_cliente     varchar2(200);
   begin
      delete tct_orcado_realizado_prop;
      commit;
      for reg in cr loop
      
         v_custo_orcado_mp  := oc_util.fnc_custo_total_material_prop(p_emp,
                                                                     p_fil,
                                                                     reg.proposta);
         v_custo_orcado_mod := oc_util.fnc_custo_total_mod_prop(p_emp,
                                                                p_fil,
                                                                reg.proposta);
         v_compras_pendente := fnc_compras_pendentes_prop(p_emp,
                                                          p_fil,
                                                          reg.proposta);
         v_compras_recebida := fnc_compras_recebidas_prop(p_emp,
                                                          p_fil,
                                                          reg.proposta);
         v_cliente          := pp_util.codigo_cliente_prop(p_emp,
                                                           p_fil,
                                                           reg.proposta);
         v_nome_cliente     := pp_util.cliente_prop(p_emp,
                                                    p_fil,
                                                    reg.proposta);
      
         v_saldo := nvl(v_custo_orcado_mp,
                        0) - nvl(v_compras_pendente,
                                 0) - nvl(v_compras_recebida,
                                          0);
      
         insert into tct_orcado_realizado_prop
            (empresa
            ,filial
            ,proposta
            ,custo_orcado_mp
            ,custo_orcado_mod
            ,compras_pendente
            ,compras_recebida
            ,saldo
            ,cliente
            ,nome_cliente)
         values
            (p_emp
            ,p_fil
            ,reg.proposta
            ,nvl(v_custo_orcado_mp,
                 0)
            ,nvl(v_custo_orcado_mod,
                 0)
            ,nvl(v_compras_pendente,
                 0)
            ,nvl(v_compras_recebida,
                 0)
            ,nvl(v_saldo,
                 0)
            ,v_cliente
            ,v_nome_cliente);
      end loop;
      commit;
   
   end;
end ct_util;
/
