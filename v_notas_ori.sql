create or replace view v_notas_ori as
select empresa
      ,filial
      ,num_nota
      ,sr_nota
      ,parte
      ,ft_notas_utl.cod_oper(empresa,
                             filial,
                             num_nota,
                             sr_nota,
                             parte) cod_oper
      ,substr(ft_notas_utl.descricao_oper(empresa,
                                          filial,
                                          num_nota,
                                          sr_nota
                                          ),
              1,
              50) operacao
      ,firma
      ,dt_emissao
      ,producao
      ,periodo
      ,substr(cd_firmas_utl.nome(firma),
              1,
              50) nome, 
     /*
      ,ft_ori.saldo_nf(empresa,
                       filial,
                       num_nota,
                       sr_nota,
                       parte,
                       'V') saldo_valor,
   */                       
(                       
         select sum(it.qtd * it.pruni_sst + nvl(it.vl_ipi,0))
           from ft_itens_nf it
          where it.id_ft_nota = nt.id
        ) - 
      (                       
         select sum(it.qtd * it.pruni_sst + nvl(it.vl_ipi,0))
           from ft_itens_nf it
          where it.empresa = nt.empresa
            and it.fil_origem = nt.filial
            and it.doc_origem = nt.num_nota
            and it.ser_origem = nt.sr_nota
            and it.parte = nt.parte
        ) saldo_valor                      
     ,ft_ori.saldo_nf(empresa,
                       filial,
                       num_nota,
                       sr_nota,
                       parte,
                       'Q') saldo_qtd
  from ft_notas nt
 where status <> 'C'
   --and num_nota = 3937
  /* and ft_ori.saldo_nf(empresa,
                       filial,
                       num_nota,
                       sr_nota,
                       parte,
                       'V') > 0*/
  and (                       
         select sum(it.qtd * it.pruni_sst + nvl(it.vl_ipi,0))
           from ft_itens_nf it
          where it.id_ft_nota = nt.id
        ) - 
      (                       
         select sum(it.qtd * it.pruni_sst + nvl(it.vl_ipi,0))
           from ft_itens_nf it
          where it.empresa = nt.empresa
            and it.fil_origem = nt.filial
            and it.doc_origem = nt.num_nota
            and it.ser_origem = nt.sr_nota
            and it.parte = nt.parte
        ) > 0 
       -- and nt.num_nota = 1131
          
       
