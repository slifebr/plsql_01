-- Create table
create table FT_TRANSPORTE
(
  id                         NUMBER(9),
  id_ft_nota                 NUMBER(9),
  modalidade_frete           VARCHAR2(1),
  cod_transp                 NUMBER(9),
  cpf_cnpj                   VARCHAR2(18),
  motorista                  VARCHAR2(100),
  inscricao_estadual         VARCHAR2(18),
  endereco                   VARCHAR2(600),
  nome_municipio             VARCHAR2(60),
  uf                         VARCHAR2(2),
  valor_servico              NUMBER(18,6),
  base_calculo_retencao_icms NUMBER(18,6),
  aliquota_retencao_icms     NUMBER(18,6),
  valor_icms_retido          NUMBER(18,6),
  cfop                       NUMBER(9),
  municipio_icms             NUMBER(9),
  placa_veiculo              VARCHAR2(10),
  uf_veiculo                 VARCHAR2(2),
  rntc_veiculo               VARCHAR2(20),
  cpf_motorista              VARCHAR2(18),
  isento_icms                VARCHAR2(1) default 'N'
)
tablespace GESTAO_SIS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 800K
    next 800K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
-- Add comments to the columns 
comment on column FT_TRANSPORTE.modalidade_frete
  is 'modFrete:
0 = Contratação do Frete por conta do Remetente (CIF);
1 = Contratação do Frete por conta do Destinatário (FOB);
2 = Contratação do Frete por conta de Terceiros;
3 = Transporte Próprio por conta do Remetente;
4 = Transporte Próprio por conta do Destinatário;
9 = Sem Ocorrência de Transporte.';
comment on column FT_TRANSPORTE.cpf_cnpj
  is 'Informar o CNPJ ou o CPF do  Transportador, preenchendo os  zeros nao significativos';
comment on column FT_TRANSPORTE.municipio_icms
  is 'Informar o municipio de  ocorrencia do fato gerador do  ICMS do transporte. Utilizar a  Tabela do IBGE (Anexo VII -  Tabela de UF, Municipio e  Pais)';
comment on column FT_TRANSPORTE.rntc_veiculo
  is 'Registro Nacional de  Transportador de Carga  (ANTT)';
-- Create/Recreate indexes 
create index FT_TRANSPORTE_FK01 on FT_TRANSPORTE (ID_FT_NOTA)
  tablespace GESTAO_SIS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 800K
    next 800K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
create index FT_TRANSPORTE_FK02 on FT_TRANSPORTE (COD_TRANSP)
  tablespace GESTAO_SIS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 800K
    next 800K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table FT_TRANSPORTE
  add constraint FT_TRANSPORTE_PK primary key (ID)
  using index 
  tablespace GESTAO_SIS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 800K
    next 800K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
alter table FT_TRANSPORTE
  add constraint FT_TRANSPORTE_FK01 foreign key (ID_FT_NOTA)
  references FT_NOTAS (ID);
alter table FT_TRANSPORTE
  add constraint FT_TRANSPORTE_FK02 foreign key (COD_TRANSP)
  references CD_FIRMAS (FIRMA);
-- Create/Recreate check constraints 
alter table FT_TRANSPORTE
  add constraint FT_TRANSPORTE_NN01
  check ("ID" IS NOT NULL);
alter table FT_TRANSPORTE
  add constraint FT_TRANSPORTE_NN02
  check ("ID_FT_NOTA" IS NOT NULL);
alter table FT_TRANSPORTE
  add constraint FT_TRANSPORTE_NN03
  check (COD_TRANSP IS NOT NULL);
-- Grant/Revoke object privileges 
grant select, insert, update, delete on FT_TRANSPORTE to GESTAO_OPR;
grant select on FT_TRANSPORTE to GESTAO_USR;

-- Create table
create table FT_TRANSPORTE_REBOQUE
(
  id               NUMBER(9),
  id_ft_transporte NUMBER(9),
  item             NUMBER(1),
  placa_reboque    VARCHAR2(8),
  uf_reboque       VARCHAR2(2),
  rntc_reboque     VARCHAR2(20),
  vagao_reboque    VARCHAR2(20),
  balsa_reboque    VARCHAR2(20)
)
tablespace GESTAO_SIS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 800K
    next 800K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table FT_TRANSPORTE_REBOQUE
  add constraint FT_TRANSPORTE_REBOQUE_PK primary key (ID)
  using index 
  tablespace GESTAO_SIS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 800K
    next 800K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
alter table FT_TRANSPORTE_REBOQUE
  add constraint FT_TRANSPORTE_REBOQUE_FK01 foreign key (ID_FT_TRANSPORTE)
  references FT_TRANSPORTE (ID);
-- Create/Recreate check constraints 
alter table FT_TRANSPORTE_REBOQUE
  add constraint FT_TRANSPORTE_REBOQUE_NN01
  check ("ID" IS NOT NULL);
alter table FT_TRANSPORTE_REBOQUE
  add constraint FT_TRANSPORTE_REBOQUE_NN02
  check ("ID_FT_TRANSPORTE" IS NOT NULL);
-- Grant/Revoke object privileges 
grant select, insert, update, delete on FT_TRANSPORTE_REBOQUE to GESTAO_OPR;
grant select on FT_TRANSPORTE_REBOQUE to GESTAO_USR;

-- Create table
create table FT_TRANSPORTE_VOLUME
(
  id                          NUMBER(9),
  id_ft_transporte            NUMBER(9),
  qtde_vol_transportados      NUMBER(18,6),
  especie_vol_transportados   VARCHAR2(60),
  marca_vol_transportados     VARCHAR2(60),
  numeracao_vol_transportados VARCHAR2(60),
  peso_liquido                NUMBER(18,6),
  peso_bruto                  NUMBER(18,6),
  numero_lacres               VARCHAR2(60)
)
tablespace GESTAO_SIS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 800K
    next 800K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table FT_TRANSPORTE_VOLUME
  add constraint FT_TRANSPORTE_VOLUME_PK primary key (ID)
  using index 
  tablespace GESTAO_SIS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 800K
    next 800K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
alter table FT_TRANSPORTE_VOLUME
  add constraint FT_TRANSPORTE_VOLUME_FK01 foreign key (ID_FT_TRANSPORTE)
  references FT_TRANSPORTE (ID);
-- Create/Recreate check constraints 
alter table FT_TRANSPORTE_VOLUME
  add constraint FT_TRANSPORTE_VOLUME_NN01
  check ("ID" IS NOT NULL);
alter table FT_TRANSPORTE_VOLUME
  add constraint FT_TRANSPORTE_VOLUME_NN02
  check ("ID_FT_TRANSPORTE" IS NOT NULL);
-- Grant/Revoke object privileges 
grant select, insert, update, delete on FT_TRANSPORTE_VOLUME to GESTAO_OPR;
grant select on FT_TRANSPORTE_VOLUME to GESTAO_USR;

-- Create sequence 
create sequence FT_TRANSPORTE_SEQ
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
nocache;
grant select on FT_TRANSPORTE_SEQ to GESTAO_USR;
grant select on FT_TRANSPORTE_SEQ to GESTAO_OPR;

-- Create sequence 
create sequence FT_TRANSPORTE_VOLUME_SEQ
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
nocache;
grant select on FT_TRANSPORTE_VOLUME_SEQ to GESTAO_USR;
grant select on FT_TRANSPORTE_VOLUME_SEQ to GESTAO_OPR;

-- Create sequence 
create sequence FT_TRANSPORTE_REBOQUE_SEQ
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
nocache;
grant select on FT_TRANSPORTE_REBOQUE_SEQ to GESTAO_USR;
grant select on FT_TRANSPORTE_REBOQUE_SEQ to GESTAO_OPR;
