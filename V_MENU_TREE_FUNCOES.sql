CREATE OR REPLACE VIEW V_MENU_TREE_FUNCOES AS
SELECT 0 INITIAL_STATE,
              5 DEPTH,
               --nome || ' ' || substr(descricao,instr(descricao,'(',1),10) label,
               descricao label,
               decode(imagem,26,'img/reports','img/formsazul') icone,
              rotina DATA,
              a.aplicativo,
              a.sistema,
              a.modulo,
              a.funcao,
              a.cmd1 ,
              upper(substr(cmd1,instr(replace(cmd1,'/','\'),'\')+1)) cd,
              rotina
         FROM cd_funcoes a
        WHERE (user In ( 'GESTAO','SMSA','DESENV') or (EXISTS (SELECT 1
                                           FROM cd_acessos b
                                          WHERE a.aplicativo = b.aplicativo
                                            AND a.sistema    = b.sistema
                                            AND a.modulo     = b.modulo
                                            and a.funcao     = b.funcao
                                            AND b.usuario    = user)
                              AND NOT EXISTS (SELECT 1
                                               FROM cd_acessos b
                                              WHERE a.aplicativo = b.aplicativo
                                                AND a.sistema    = b.sistema
                                                AND a.modulo     = b.modulo
                                                and a.funcao     = b.funcao
                                                AND b.usuario  IN (select GRANTED_ROLE from dba_role_privs where  grantee = USER )))) --dba_role_privs where grantee = user))))
UNION ALL
       SELECT 0 INITIAL_STATE,
              5 DEPTH,
               --nome || ' ' || substr(descricao,instr(descricao,'(',1),10) label,
               descricao label,
               decode(imagem,26,'img/reports','img/formsazul') icone,
              rotina DATA,
              a.aplicativo,
              a.sistema,
              a.modulo,
              a.funcao,
              a.cmd1 ,
              upper(substr(cmd1,instr(replace(cmd1,'/','\'),'\')+1)) cd,
              rotina
         FROM cd_funcoes a
        WHERE user NOT In ( 'GESTAO','SMSA','DESENV')
          AND NOT EXISTS (SELECT 1
                             FROM cd_acessos b
                            WHERE a.aplicativo = b.aplicativo
                              AND a.sistema    = b.sistema
                              AND a.modulo     = b.modulo
                              and a.funcao     = b.funcao
                              AND b.usuario    = user)
          AND EXISTS (SELECT 1
                        FROM cd_acessos b
                       WHERE a.aplicativo = b.aplicativo
                         AND a.sistema    = b.sistema
                         AND a.modulo     = b.modulo
                         AND a.funcao     = b.funcao
                         AND b.usuario    IN (select GRANTED_ROLE from dba_role_privs where  grantee = USER))
;
