CREATE OR REPLACE VIEW V_MENU_TREE_SISTEMAS AS
SELECT -1 INITIAL_STATE,
              3 DEPTH,
              nome LABEL,
              'img/pasta_fechada'       icone,
              0 DATA,
              a.aplicativo,
              a.sistema,
              0 modulo,
              0 funcao,
              null cmd1,
              null cd,
              null rotina
         FROM cd_sistemas a
        WHERE (user In ( 'GESTAO','SMSA','DESENV') OR (EXISTS (SELECT 1
                                           FROM cd_acessos b
                                          WHERE a.aplicativo = b.aplicativo
                                            AND a.sistema    = b.sistema
                                            AND b.usuario    = user)
                               AND NOT EXISTS (SELECT 1
                                                 FROM cd_acessos b
                                                WHERE a.aplicativo = b.aplicativo
                                                  AND a.sistema   = b.sistema
                                                  AND b.usuario  IN (select GRANTED_ROLE from dba_role_privs where  grantee = USER)))) --dba_role_privs where grantee = user))))
UNION ALL
       SELECT -1 INITIAL_STATE,
              3 DEPTH,
              nome LABEL,
              'img/pasta_fechada'       icone,
              0 DATA,
              a.aplicativo,
              a.sistema,
              0 modulo,
              0 funcao,
              null cmd1,
              null cd,
              null rotina
         FROM cd_sistemas a
        WHERE user  Not In ( 'GESTAO','SMSA','DESENV')
         AND not EXISTS (SELECT 1
                            FROM cd_acessos b
                           WHERE a.aplicativo = b.aplicativo
                             AND a.sistema    = b.sistema
                             AND b.usuario    = user)
          AND EXISTS (SELECT 1
                        FROM cd_acessos b
                       WHERE a.aplicativo = b.aplicativo
                         AND a.sistema    = b.sistema
                         AND b.usuario    IN (select GRANTED_ROLE from dba_role_privs where  grantee = USER))
;
