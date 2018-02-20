create  table tb_remessa_ind_160218 as
select v.*
, qtde_remessa - qtde_retorno saldo_remessa
, case when qtde_retorno < qtde_remessa then
    trunc(sysdate) - trunc(dt_emissao)
    else
      0
    end dias_remessa
  from (select n.dt_emissao
              ,n.firma
              ,cd_firmas_utl.nome(n.firma) nome
              ,n.num_nota
              ,n.sr_nota
              ,it.produto
              ,it.descricao
              ,it.cod_tribut cst_icms
              ,it.uni_ven unidade
              ,it.qtd qtde_remessa
              ,it.valor_unit
              ,it.qtd * it.valor_unit vl_remessa
              ,ft_ori.valor_retorno_industrializacao(n.id,
                                                     it.id) vl_retorno
              ,ft_ori.qtde_retorno_industrializacao(n.id,
                                                    it.id) qtde_retorno
              ,iped.opos
              , pp_util.op_cliente(iped.opos) cliente
              ,o.cod_oper
              ,o.descricao descr_oper
              ,ped.num_pedido
              ,ped.solicitante
                                                 
             
          from ft_itens_nf it
              ,ft_notas    n
              ,ft_oper     o
              ,ft_itens_ped iped
              ,ft_pedidos ped
         where it.id_ft_nota = n.id
           and o.empresa = n.empresa
           and o.cod_oper = n.cod_oper
           and iped.seq_item = it.seq_pedido
           and ped.empresa = iped.empresa
           and ped.filial = iped.filial
           and ped.num_pedido = iped.num_pedido
           and o.cod_oper = 2110
          -- and ped.solicitante = 'JAGALLAO'
        -- and it.id = 13810
        ) v
--6665
