CREATE OR REPLACE VIEW VT_APROVA_TEM_PEND AS
Select 'PAG1' ABA
               , 'A' ACAO
            From T_Aprova
           Where (APROVADOR = USER )
           AND ROWNUM = 1
           UNION all
          SELECT 'PAG2' ABA
               , 'A' ACAO
            FROM T_APROVA_COMERCIAL
           WHERE (APROVADOR = USER )
           AND ROWNUM = 1
           UNION all
          SELECT 'PAG3' ABA
               , A.ACAO
            FROM CD_APROVA_USU A
           WHERE (USUARIO = USER )
             AND TIPO = 'FLW'
             AND ROWNUM = 1
           UNION all
          SELECT 'PAG4' ABA
               , A.ACAO
            FROM CD_APROVA_USU A
           WHERE (USUARIO = USER)
             AND TIPO = 'FCF'
             AND ROWNUM = 1
          union all
          SELECT 'PAG5' ABA
               , 'A' ACAO
            FROM T_APROVA_ADM A
           WHERE (A.APROVADOR = USER)
             AND ROWNUM = 1
          union all
          SELECT 'PAG6' ABA
               , 'A' ACAO
            FROM T_OPOS_PENDENTE A
           WHERE ROWNUM = 1
          union all
          SELECT 'PAG7' ABA
               , 'A' ACAO
            FROM T_PEND_ADIANT_AF A
           WHERE ROWNUM = 1;           
