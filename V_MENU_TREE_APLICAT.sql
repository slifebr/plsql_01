CREATE OR REPLACE VIEW V_MENU_TREE_APLICAT AS
SELECT -1 INITIAL_STATE,
              2 DEPTH,
              nome LABEL,
              --'img/pasta_fechada' icone,
              i.descricao icone,
              0 data,
              a.aplicativo,
              0 sistema,
              0 modulo,
              0 funcao,
              null cmd1,
              null cd,
              null rotina
         FROM cd_aplicat a
            , cd_imagens i
        WHERE i.imagem(+)= a.imagem
          And (user In ( 'GESTAO','SMSA','DESENV') or (EXISTS (SELECT 1
                                            FROM cd_acessos b
                                           WHERE a.aplicativo = b.aplicativo
                                             AND b.usuario    = user)
                               AND NOT EXISTS (SELECT 1
                                                 FROM cd_acessos b
                                                WHERE a.aplicativo = b.aplicativo
                                                  AND b.usuario  IN (select GRANTED_ROLE from dba_role_privs where  grantee = user)))) --dba_role_privs where grantee = user))))
UNION ALL
      SELECT -1 INITIAL_STATE,
              2 DEPTH,
              nome LABEL,
              'img/pasta_fechada' icone,
              0 data,
              a.aplicativo,
              0 sistema,
              0 modulo,
              0 funcao,
              null cmd1,
              null cd,
              null rotina
         FROM cd_aplicat a
        WHERE user  Not In ( 'GESTAO','SMSA','DESENV')
          AND not EXISTS (SELECT 1
                            FROM cd_acessos b
                           WHERE a.aplicativo = b.aplicativo
                             AND b.usuario    = user)
          AND EXISTS (SELECT 1
                        FROM cd_acessos b
                       WHERE a.aplicativo = b.aplicativo
                         AND b.usuario    IN (select GRANTED_ROLE from dba_role_privs
                         where  grantee = user))
;
