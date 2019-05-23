create or replace view vgs_preco_venda_prod_max as
  select *
    from gs_preco_venda_prod v
   where v.rev = (select max(v2.rev)
                     from gs_preco_venda v2
                    where v2.empresa = v.empresa
                      and v2.nr_pc_seq = v.nr_pc_seq)
                      
                      
grant select  on vgs_preco_venda_prod_max to gestao_opr                    ;
grant select  on vgs_preco_venda_prod_max to gestao_usr;                    
