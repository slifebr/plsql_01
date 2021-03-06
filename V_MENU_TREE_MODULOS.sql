CREATE OR REPLACE VIEW V_MENU_TREE_MODULOS AS
SELECT -1 INITIAL_STATE,
       4 DEPTH,
       a.nome  label,
       'img/pasta_fechada'       icone,
       0 DATA,
       a.aplicativo,
       a.sistema,
       a.modulo,
       0 funcao,
       null cmd1,
       null cd,
              null rotina
   FROM cd_modulos a
        WHERE (user In ( 'GESTAO','SMSA','DESENV') or ( EXISTS (SELECT 1
                                           FROM cd_acessos b
                                          WHERE a.aplicativo = b.aplicativo
                                            AND a.sistema    = b.sistema
                                            AND a.modulo     = b.modulo
                                            AND b.usuario    = user)
                              AND NOT EXISTS (SELECT 1
                                               FROM cd_acessos b
                                              WHERE a.aplicativo = b.aplicativo
                                                AND a.sistema    = b.sistema
                                                AND a.modulo     = b.modulo
                                                AND b.usuario  IN (select GRANTED_ROLE from dba_role_privs where  grantee = USER))))-- dba_role_privs where grantee = user))))
UNION ALL
SELECT -1 INITIAL_STATE,
        4 DEPTH,
        a.nome  label,
        'img/pasta_fechada'       icone,
        0 DATA,
        a.aplicativo,
        a.sistema,
        a.modulo,
        0 funcao,
        null cmd1,
        null cd,
              null rotina
         FROM cd_modulos a
        WHERE user  Not In ( 'GESTAO','SMSA','DESENV')
        AND not EXISTS (SELECT 1
                            FROM cd_acessos b
                           WHERE a.aplicativo = b.aplicativo
                             AND a.sistema    = b.sistema
                             AND a.modulo     = b.modulo
                             AND b.usuario    = user)
          AND EXISTS (SELECT 1
                        FROM cd_acessos b
                       WHERE a.aplicativo = b.aplicativo
                         AND a.sistema    = b.sistema
                         AND a.modulo     = b.modulo
                         AND b.usuario    IN (select GRANTED_ROLE from dba_role_privs where  grantee = USER))
;
