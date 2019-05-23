CREATE OR REPLACE VIEW V_MENU_TREE AS
select v."INITIAL_STATE",v."DEPTH",v."LABEL",v."ICONE",v."DATA",v."APLICATIVO",v."SISTEMA",v."MODULO",v."FUNCAO",v."CMD1",v."CD"
     ,rotina
     , lpad(v.aplicativo,2,'0')||lpad(v.sistema,4,'0')||lpad(v.modulo,6,'0')||lpad(v.funcao,8,'0') ordem
     --01 0100 101010 10102
from (
SELECT 1 INITIAL_STATE,
           1 DEPTH,
           'SGN' LABEL,
           'img/pasta_fechada'       icone,
           0  data,
           0 aplicativo,
           0 sistema,
           0 modulo,
           0 funcao,
           null cmd1,
           null cd,
           null rotina
FROM dual
UNION ALL
  SELECT INITIAL_STATE,
          DEPTH,
          LABEL,
          ICONE,
          DATA,
          APLICATIVO,
          SISTEMA,
          MODULO,
          FUNCAO,
          cmd1,
          cd,
          rotina
     FROM V_MENU_TREE_APLICAT
UNION ALL
  SELECT INITIAL_STATE,
          DEPTH,
          LABEL,
          ICONE,
          DATA,
          APLICATIVO,
          SISTEMA,
          MODULO,
          FUNCAO,
          cmd1,
          cd,
          rotina
     FROM V_MENU_TREE_SISTEMAS
UNION ALL
  SELECT INITIAL_STATE,
          DEPTH,
          LABEL,
          ICONE,
          DATA,
          APLICATIVO,
          SISTEMA,
          MODULO,
          FUNCAO,
          cmd1,
          cd,
          rotina
     FROM V_MENU_TREE_MODULOS
UNION ALL
  SELECT INITIAL_STATE,
          DEPTH,
          LABEL,
          ICONE,
          DATA,
          APLICATIVO,
          SISTEMA,
          MODULO,
          FUNCAO,
          cmd1,
          cd,
          rotina
     FROM V_MENU_TREE_FUNCOES
     )v
;
