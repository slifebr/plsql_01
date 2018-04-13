Select 0 origem,
      empresa,
      conta,
      Data,
      to_number(Null) seq_mov,
      (A.SALDO_FINAL_EXT) valor,
      CASE WHEN A.SALDO_FINAL_EXT > 0 THEN
                    'E'
                 ELSE
                  'S'
          END  OPERACAO,
      'SALDO INICIAL: '||TO_CHAR(Data,'DD/MM/RRRR') HISTORICO,
      Null  DOCUMENTO, 
      Null CONCILIADO,
      0 NUM_LINHA
From FN_SALDOS A
Where  empresa = 1
  AND conta = '40071-8' 
  And A.DATA = (Select MAX(A2.DATA)
                  From FN_SALDOS A2
                  Where A2.EMPRESA = A.EMPRESA
                     And A2.CONTA = A.CONTA
                     And A2.DATA < '01/03/2018')
Union             
SELECT 1 origem,
       empresa,
       conta,
       data,
       seq_mov,
       case when operacao = 'E' then
                        valor
                else
                          valor * -1
                 end valor,
       operacao,
       historico,
       documento,
       conciliado,
        NUM_LINHA
  FROM fn_razao
 WHERE (empresa = 1 AND conta = '40071-8' AND
       data BETWEEN '01/03/2018' AND '31/03/2018')
       
 ORDER BY ORIGEM, 
          empresa,
          conta,
          data,
          num_linha,
          seq_mov
