select lpad(a.id_produto, 13, '0')||  lpad(nvl(a.saldo, 0),6,'0') txt
--codigo,a.descr,  a.saldo --

from (
select a.id_produto, sum(nvl(a.saldo,0)) saldo
  from tb_eucresci_a a

 group by a.id_produto
-- having  sum(nvl(a.saldo,0)) >= 0
 ) a
-- where a.id_produto = 5601069220
   where nvl(saldo, 0) >= 0
--update tb_eucresci_a set origem = 'A'
--38781 - A
--73715 - 34938
