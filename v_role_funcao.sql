CREATE OR REPLACE VIEW V_ROLE_FUNCAO AS
Select l.empresa
      ,l.usuario
      ,fu.rotina
      ,fu.descricao
      ,fu.nome
      ,UPPER(fu.cmd1) programa
      ,decode(l.c01,
              1,
              fu.c01,
              Null) c01
      ,decode(l.c02,
              1,
              fu.c02,
              Null) c02
      ,decode(l.c03,
              1,
              fu.c03,
              Null) c03
      ,decode(l.c04,
              1,
              fu.c04,
              Null) c04
      ,decode(l.c05,
              1,
              fu.c05,
              Null) c05
      ,decode(l.c06,
              1,
              fu.c06,
              Null) c06
      ,decode(l.c07,
              1,
              fu.c07,
              Null) c07
      ,decode(l.c08,
              1,
              fu.c08,
              Null) c08
      ,decode(l.c09,
              1,
              fu.c09,
              Null) c09
      ,decode(l.c10,
              1,
              fu.c10,
              Null) c10
      ,decode(l.c11,
              1,
              fu.c11,
              Null) c11
      ,decode(l.c12,
              1,
              fu.c12,
              Null) c12
      ,decode(l.c13,
              1,
              fu.c13,
              Null) c13
      ,decode(l.c14,
              1,
              fu.c14,
              Null) c14
      ,decode(l.c15,
              1,
              fu.c15,
              Null) c15
      ,decode(l.c16,
              1,
              fu.c16,
              Null) c16
      ,decode(l.c17,
              1,
              fu.c17,
              Null) c17
      ,decode(l.c18,
              1,
              fu.c18,
              Null) c18
      ,decode(l.c19,
              1,
              fu.c19,
              Null) c19
      ,decode(l.c20,
              1,
              fu.c20,
              Null) c20
  From cd_libera  l
      ,cd_funcoes fu
 Where fu.rotina = l.rotina
/*union
Select u.empresa
      ,u.usuario usuario
      ,fu.rotina
      ,fu.descricao
      ,UPPER(fu.cmd1) programa
      ,decode(FU.c01,
              NULL,
              Null,
              fu.c01
              ) c01
      ,decode(FU.c02,
              NULL,
              Null,
              fu.c02
              ) c02
      ,decode(FU.c03,
              NULL,
              Null,
              fu.c03
              ) c03
      ,decode(FU.c04,
              NULL,
              Null,
              fu.c04
              ) c04
      ,decode(FU.c05,
              NULL,
              Null,
              fu.c05
              ) c05
      ,decode(FU.c06,
              NULL,
              Null,
              fu.c06
              ) c06
      ,decode(FU.c07,
              NULL,
              Null,
              fu.c07
              ) c07
      ,decode(FU.c08,
              NULL,
              Null,
              fu.c08
              ) c08
      ,decode(FU.c09,
              NULL,
              Null,
              fu.c09
              ) c09
      ,decode(FU.c10,
              NULL,
              Null,
              fu.c10
              ) c10
      ,decode(FU.c11,
              NULL,
              Null,
              fu.c11
              ) c11
      ,decode(FU.c12,
              NULL,
              Null,
              fu.c12
              ) c12
      ,decode(FU.c13,
              NULL,
              Null,
              fu.c13
              ) c13
      ,decode(FU.c14,
              NULL,
              Null,
              fu.c14
              ) c14
      ,decode(FU.c15,
              NULL,
              Null,
              fu.c15
              ) c15
      ,decode(FU.c16,
              NULL,
              Null,
              fu.c16
              ) c16
      ,decode(FU.c17,
              NULL,
              Null,
              fu.c17
              ) c17
      ,decode(FU.c18,
              NULL,
              Null,
              fu.c18
              ) c18
      ,decode(FU.c19,
              NULL,
              Null,
              fu.c19
              ) c19
      ,decode(FU.c20,
              NULL,
              Null,
              fu.c20
              ) c20
  From cd_funcoes fu
  , (SELECT 0 EMPRESA, V.USUARIO, V.GRUPO
          FROM v_role_usuario V
         WHERE GRUPO = USER || '_ADM') u*/;
