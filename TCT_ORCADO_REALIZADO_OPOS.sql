-- Create table
create global temporary table TCT_ORCADO_REALIZADO_OPOS
( empresa           number(9),
  filial            number(9),
  opos              varchar2(20),
  custo_orcado_mp   number(15,2),
  custo_orcado_mod  number(15,2),
  compras_pendente  number(15,2),
  compras_recebida  number(15,2),
  saldo             number(15,2)
)
on commit preserve rows;
-- Grant/Revoke object privileges 
grant select, insert, update, delete on TCT_ORCADO_REALIZADO_OPOS to GESTAO_OPR;
grant select on TCT_ORCADO_REALIZADO_OPOS to GESTAO_USR;
