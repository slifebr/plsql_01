-- Create table
create global temporary table TCT_ORCADO_REALIZADO_PROP
(
  empresa          NUMBER(9),
  filial           NUMBER(9),
  PROPOSTA         VARCHAR2(20),
  custo_orcado_mp  NUMBER(15,2),
  custo_orcado_mod NUMBER(15,2),
  compras_pendente NUMBER(15,2),
  compras_recebida NUMBER(15,2),
  saldo            NUMBER(15,2),
  cliente          NUMBER(9),
  nome_cliente     VARCHAR2(200)
)
on commit preserve rows;
-- Grant/Revoke object privileges 
grant select, insert, update, delete on TCT_ORCADO_REALIZADO_PROP to GESTAO_OPR;
grant select on TCT_ORCADO_REALIZADO_PROP to GESTAO_USR;
