create or replace view v_usuario_funcao as
select "GRUPO",
       "TIPO",
       "USUARIO",
       "ROTINA",
       "DESCRICAO",
       nome,
       "PROGRAMA",
       upper(substr(programa, instr(replace(programa, '/', '\'), '\') + 1)) cd,
       "C01",
       "C02",
       "C03",
       "C04",
       "C05",
       "C06",
       "C07",
       "C08",
       "C09",
       "C10",
       "C11",
       "C12",
       "C13",
       "C14",
       "C15",
       "C16",
       "C17",
       "C18",
       "C19",
       "C20"
  from (Select u.grupo,
               'G' TIPO,
               u.usuario,
               f.rotina,
               LIB_UTIL.formata_string(f.descricao, 'C') descricao,
               LIB_UTIL.formata_string(f.nome, 'C') nome,
               LIB_UTIL.formata_string(replace(f.programa, '/', '\')) programa,
               f.c01,
               f.c02,
               f.c03,
               f.c04,
               f.c05,
               f.c06,
               f.c07,
               f.c08,
               f.c09,
               f.c10,
               f.c11,
               f.c12,
               f.c13,
               f.c14,
               f.c15,
               f.c16,
               f.c17,
               f.c18,
               f.c19,
               f.c20
          From v_role_usuario u, v_role_funcao f
         Where (f.usuario = u.grupo)
        /*UNION 
        Select u.grupo,
               'G' TIPO,
               u.usuario,
               f.rotina,
               LIB_UTIL.formata_string(f.descricao, 'C') descricao,
               LIB_UTIL.formata_string(replace(f.programa, '/', '\')) programa,
               f.c01,
               f.c02,
               f.c03,
               f.c04,
               f.c05,
               f.c06,
               f.c07,
               f.c08,
               f.c09,
               f.c10,
               f.c11,
               f.c12,
               f.c13,
               f.c14,
               f.c15,
               f.c16,
               f.c17,
               f.c18,
               f.c19,
               f.c20
          From v_role_usuario u, v_role_funcao f
         Where (f.usuario = u.grupo)*/
        Union
        Select u.grupo,
               'U' TIPO,
               u.usuario,
               f.rotina,
               LIB_UTIL.formata_string(f.descricao, 'C') descricao,
               LIB_UTIL.formata_string(f.nome, 'C') nome,
               LIB_UTIL.formata_string(replace(f.programa, '/', '\')) programa,
               f.c01,
               f.c02,
               f.c03,
               f.c04,
               f.c05,
               f.c06,
               f.c07,
               f.c08,
               f.c09,
               f.c10,
               f.c11,
               f.c12,
               f.c13,
               f.c14,
               f.c15,
               f.c16,
               f.c17,
               f.c18,
               f.c19,
               f.c20
          From v_role_usuario u, v_role_funcao f
         Where f.usuario = u.usuario

        );
