CREATE OR REPLACE Package Pkg_Nfe Is
   Type Tp_Estruct_Xml_Nfe Is Record( --LNFE_ESTR_ID_NEXT
      Level              Integer,
      Lnfe_Id            Infe_Leiaute_Xml.Lnfe_Id%Type,
      Lnfe_Id_Pai        Infe_Leiaute_Xml.Lnfe_Id_Pai%Type,
      Lnfe_Estr_Id       Infe_Leiaute_Xml.Lnfe_Estr_Id%Type,
      Lnfe_Estr_Id_Next  Infe_Leiaute_Xml.Lnfe_Estr_Id_Next%Type,
      Lnfe_Seq           Infe_Leiaute_Xml.Lnfe_Seq%Type,
      Lnfe_Status        Infe_Leiaute_Xml.Lnfe_Status%Type,
      Lnfe_Tag_Xml       Infe_Leiaute_Xml.Lnfe_Tag_Xml%Type,
      Lnfe_Tag_Desc      Infe_Leiaute_Xml.Lnfe_Tag_Desc%Type,
      Lnfe_Atributo_Tag  Infe_Leiaute_Xml.Lnfe_Atributo_Tag%Type,
      Lnfe_Valor_Default Infe_Leiaute_Xml.Lnfe_Valor_Default%Type,
      Lnfe_Coluna        Infe_Leiaute_Xml.Lnfe_Coluna%Type,
      Lnfe_Tam_Max       Infe_Leiaute_Xml.Lnfe_Tam_Max%Type,
      Lnfe_Tam_Ele       Infe_Leiaute_Xml.Lnfe_Tam_Ele%Type,
      Lnfe_Tipo          Infe_Leiaute_Xml.Lnfe_Tipo%Type,
      Lnfe_Dec           Infe_Leiaute_Xml.Lnfe_Dec%Type,
      Lnfe_Obrg          Infe_Leiaute_Xml.Lnfe_Obrg%Type,
      Lnfe_Obs           Infe_Leiaute_Xml.Lnfe_Obs%Type,
      Lnfe_Usr_Inc       Infe_Leiaute_Xml.Lnfe_Usr_Inc%Type,
      Lnfe_Usr_Dt_Inc    Infe_Leiaute_Xml.Lnfe_Usr_Dt_Inc%Type,
      Lnfe_Usr_Atlz      Infe_Leiaute_Xml.Lnfe_Usr_Atlz%Type,
      Lnfe_Usr_Dt_Atlz   Infe_Leiaute_Xml.Lnfe_Usr_Dt_Atlz%Type,
      Lnfe_Car_Direita   Infe_Leiaute_Xml.Lnfe_Car_Direita%Type,
      Lnfe_Car_Esquerda  Infe_Leiaute_Xml.Lnfe_Car_Esquerda%Type,
      Conteudo           Varchar2(500),
      Ind_Fecha_Tag      Integer,
      Ind_Conteudo       Integer,
      Col_Select         Varchar2(300));

   Type Tb_Xml_Struct Is Table Of Tp_Estruct_Xml_Nfe Index By Binary_Integer;

   --/menssagem retorno
   Type Ty_Controle_Rec Is Record(
      Txt_Ret Varchar2(1000),
      V$errm  Varchar2(10000),
      Tip_Ret Varchar2(1),
      Raise_  Boolean);

   Rec_Xml_Header Tb_Xml_Struct;
   Rec_Xml_Detail Tb_Xml_Struct;
   Rec_Tag_Header Tb_Xml_Struct;
   Rec_Tag_Detail Tb_Xml_Struct;
   -- rec_tag_close    tb_xml_struct;
   V$_Rot_Glb Varchar2(30) := 'pkg_infe_send';
   V$_Prog    Varchar2(30);

   V$_Lnfe_Id      Infe_Leiaute_Xml.Lnfe_Id%Type;
   V$_Lnfe_Id_Pai  Infe_Leiaute_Xml.Lnfe_Id_Pai%Type;
   V$_Lnfe_Tag_Xml Infe_Leiaute_Xml.Lnfe_Tag_Xml%Type;
   V$_Lnfe_Tipo    Infe_Leiaute_Xml.Lnfe_Tipo%Type;
   V$_Conteudo     Infe_Leiaute_Xml.Lnfe_Tipo%Type;
   V$ctrl          Integer := 0;

   --   vp               estruct_xml_nfe%rowtype;

   --/------by rfs 10-mar-2010 ----------------------------------------------------
   Procedure Prc_Req_Danfe(p_Gera_Arq In Varchar2 Default 'N',
                           p_Retcode  In Varchar2,
                           p_Mensagem In Varchar2,
                           p_Nome_Arq In Varchar2);

   Function Xml_Fnc_Format(p_Lnfe_Tipo         Infe_Leiaute_Xml.Lnfe_Tipo%Type,
                           p_Lnfe_Dec          Infe_Leiaute_Xml.Lnfe_Dec%Type,
                           p_Lnfe_Tam_Max      Infe_Leiaute_Xml.Lnfe_Tam_Max%Type,
                           p_Lnfe_Car_Direita  Infe_Leiaute_Xml.Lnfe_Car_Direita%Type,
                           p_Lnfe_Car_Esquerda Infe_Leiaute_Xml.Lnfe_Car_Esquerda%Type,
                           p_Dado              Varchar2) Return Varchar2;
End Pkg_Nfe;
/
CREATE OR REPLACE PACKAGE BODY pkg_nfe
IS
/*
*-------------------------------------------------------------------------------------------------*
*                                                           *
*-------------------------------------------------------------------------------------------------*
* Cliente  :                                                              *
* Modulo   : Pacote para geracao de XML para requisic?o de emiss?o de Nota Fiscal Eletronica      *
* Tipo     : -                                                                                    *
* Transacao: **                                                                                   *
* Programa : pkg_infe_send                                                                        *
* Descricao: Requisitar para Conector emiss?o de               NFe                                *
*-------------------------------------------------------------------------------------------------*
* Nome       | Data       | Descricao                                               (Historico)   *
*-------------------------------------------------------------------------------------------------*
* RobertoF.S | 12.03.2010 | Codificacao Inicial                                                   *
*            |            |                                                                       *
*-------------------------------------------------------------------------------------------------*
*/
       --/Funcao para montar o corpo do XML 'by RFS'
       FUNCTION XML_fnc_mount(p_xml IN out tb_xml_struct, p_value IN VARCHAR2, p_idx IN INTEGER,
                              rec_tag_open IN OUT tb_xml_struct, sc OUT ty_controle_rec)
          RETURN VARCHAR2
       IS
          v_ret    VARCHAR2 (32000) := '';
          v_attr   VARCHAR2 (32000) := '';

       BEGIN v$_prog := 'XML_fnc_mount';
          --/Verifica se e primeiro registro da estrutura XML
          IF p_xml.PRIOR(p_idx-1) IS NOT NULL THEN
          --    IF rec_tag_open.EXISTS (rec_tag_open.FIRST) THEN
                  IF  TO_NUMBER(NVL(p_xml(p_idx-1).LEVEL,p_xml(p_idx).LEVEL)) > TO_NUMBER(p_xml(p_idx).LEVEL) THEN
                      FOR I IN REVERSE p_xml.FIRST .. p_idx-1
                      LOOP
                          v$ctrl := v$ctrl+1;
                          dbms_output.put_line(v$ctrl||'  '||to_char(sysdate,'hh24:mi:ss'));
                         -- dbms_output.put_line('p_xml.FIRST .. p_idx-1  '||to_char(p_xml.FIRST)||' .. '||to_char(p_idx-1));
                          --/Se a Tag for de menor Level fecha as Tags Abertas ate o nivel atual
                          IF TO_NUMBER(p_xml(I).LEVEL) >= TO_NUMBER(p_xml(p_idx).LEVEL) AND p_xml(I).lnfe_tipo = 'T'
                             AND p_xml(I).ind_fecha_tag = 0
                          THEN
                              v_ret := v_ret || '</' || p_xml(I).lnfe_tag_xml || '>'; --|| --CHR (13) || CHR (10);
                              p_xml(I).ind_fecha_tag := 1;
                          END IF;
                          --/Sai do loop quando a TAG chegar no mesmo Level
                          IF TO_NUMBER(p_xml(I).LEVEL) = TO_NUMBER(p_xml(p_idx).LEVEL) AND p_xml(I).lnfe_tipo = 'T'
                          THEN
                             IF rec_tag_open.EXISTS (rec_tag_open.FIRST) THEN
                                 IF TO_NUMBER(p_xml(p_idx).LEVEL) <= TO_NUMBER(rec_tag_open(rec_tag_open.FIRST).LEVEL) THEN
                                    rec_tag_open.DELETE;
                                 ELSE
                                    rec_tag_open.DELETE(rec_tag_open.LAST);
                                 END IF;
                             END IF;
                             EXIT;
                          END IF;
                      END LOOP;
                  END IF;
           --   END IF;
          END IF;

          --/Se for TAG abre a TAG e inclui atrubuto se houver
          IF p_xml(p_idx).lnfe_tipo = 'T' THEN
              p_xml(p_idx).ind_fecha_tag := 2;
              rec_tag_open(p_idx) := p_xml(p_idx);
          ELSIF p_xml(p_idx).lnfe_tipo = 'TF' THEN
              v_ret := v_ret || '<' || p_xml(p_idx).lnfe_tag_xml || p_xml(p_idx).lnfe_atributo_tag || '/>'; --|| CHR (13) || CHR (10);
              p_xml(p_idx).ind_fecha_tag := 0;
          --/Se n?o for Tag e tiver conteudo escreve TAG
          ELSIF NVL(p_value, p_xml(p_idx).lnfe_valor_default) IS NOT NULL AND
                p_xml(p_idx).lnfe_tipo IN ('N','C','D') THEN
                IF rec_tag_open.COUNT > 0 THEN
                    FOR t IN rec_tag_open.FIRST .. rec_tag_open.LAST
                    LOOP
                       IF rec_tag_open.EXISTS (t) then
                           v_ret := v_ret || '<' || rec_tag_open(t).lnfe_tag_xml || rec_tag_open(t).lnfe_atributo_tag || '>'; --|| CHR (13) || CHR (10);
                           p_xml(t).ind_fecha_tag := 0;
                       END IF;
                    END LOOP;
                    rec_tag_open.DELETE;
                END IF;

                v_ret := v_ret || '<' || p_xml(p_idx).lnfe_tag_xml || p_xml(p_idx).lnfe_atributo_tag || '>' ||
                         NVL(p_value, p_xml(p_idx).lnfe_valor_default) || '</' ||p_xml(p_idx).lnfe_tag_xml|| '>';--||
          END IF;

          RETURN v_ret;
       v$_prog := 'PRC_GERA_XML_NFE';
       EXCEPTION
       WHEN OTHERS THEN
           sc.txt_ret   := 'Erro ao montar conteudo XML. Entre em contato com o administrador do sistema.';
           sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_    := TRUE;
       END XML_fnc_mount;
       --/
       --/

       --/Funcao para fechar Tags abertas do corpo do XML 'by RFS'
       FUNCTION XML_close (p_xml IN out tb_xml_struct,  sc OUT ty_controle_rec)
          RETURN VARCHAR2
       IS
          v_ret    VARCHAR2 (32000) := '';
          v_attr   VARCHAR2 (32000) := '';

       BEGIN v$_prog := 'XML_close';
              FOR I IN REVERSE p_xml.FIRST .. p_xml.LAST
              LOOP
                  IF p_xml(I).lnfe_tipo = 'T'  AND p_xml(I).ind_fecha_tag = 0
                  THEN
                      v_ret := v_ret || '</' || p_xml(I).lnfe_tag_xml || '>'; --|| CHR (13) || CHR (10);
                      p_xml(I).ind_fecha_tag := 1; --/Indica fechamento da tag
                  END IF;
              END LOOP;

          RETURN v_ret;
       v$_prog := 'PRC_GERA_XML_NFE';
       EXCEPTION
       WHEN OTHERS THEN
           sc.txt_ret   := 'Erro ao fechar conteudo XML. Entre em contato com o administrador do sistema.';
           sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_    := TRUE;
       END XML_close;
       --/

       --/Funcao para gerar o cabecario do XML 'by RFS'
       FUNCTION XML_fnc_gera_tag_h (p_attr_value IN VARCHAR2 DEFAULT NULL, p_attr_tag  IN VARCHAR2 DEFAULT NULL,  sc OUT ty_controle_rec)
          RETURN VARCHAR2
       IS
          v_ret    VARCHAR2 (32000) := '';
          v_attr   VARCHAR2 (32000) := '';

       BEGIN v$_prog := 'XML_fnc_gera_tag_h';
          IF p_attr_value IS NOT NULL
          THEN
             v_attr := ' encoding="' || p_attr_value || '"';
          END IF;

          v_ret := v_ret || '<?xml version="1.0"' || v_attr || '?>';--|| --CHR (13) || CHR (10);

          RETURN v_ret;
       v$_prog := 'PRC_GERA_XML_NFE';
       EXCEPTION
       WHEN OTHERS THEN
           sc.txt_ret   := 'Erro ao formatar cabecalho do XML. Entre em contato com o administrador do sistema.';
           sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_    := TRUE;
       END XML_fnc_gera_tag_h;
       --/

       --/Funcao para formatar conteudo XML 'by RFS'
       FUNCTION XML_fnc_format (P_lnfe_tipo         infe_leiaute_xml.lnfe_tipo%TYPE,
                                P_lnfe_dec          infe_leiaute_xml.lnfe_dec%TYPE,
                                P_lnfe_tam_max      infe_leiaute_xml.lnfe_tam_max%TYPE,
                                P_lnfe_car_direita  infe_leiaute_xml.lnfe_car_direita%TYPE,
                                P_lnfe_car_esquerda infe_leiaute_xml.lnfe_car_esquerda%TYPE,
                                P_dado VARCHAR2
        )
          RETURN VARCHAR2
       IS
          vp_return VARCHAR2(200);
          vp_mask   VARCHAR2(200);

       BEGIN  v$_prog := 'FNC_FORMAT';

           vp_return  := P_dado;

           --/Formata numero
           IF P_lnfe_tipo = 'N' AND NVL(P_lnfe_dec,0) > 0 THEN
              SELECT DECODE(P_lnfe_dec,1,'''9999999999999990D0''',
                                                  2,'''9999999999999990D00''',
                                                  3,'''9999999999999990D000''',
                                                  4,'''9999999999999990D0000''')
              INTO vp_mask FROM DUAL;
               EXECUTE IMMEDIATE 'SELECT  TRIM(TO_CHAR(:1,'||vp_mask||'))  FROM DUAL '
               INTO vp_return
               USING P_dado;
           END IF;

           --/Formata Caracter
           IF P_lnfe_tipo = 'C' THEN
               vp_return := TRIM(SUBSTR(vp_return,1,P_lnfe_tam_max));
           END IF;

           --/Adiciona caracter a direita
           IF P_lnfe_car_direita IS NOT NULL THEN
               vp_return := RPAD(vp_return, P_lnfe_tam_max, P_lnfe_car_direita);
           END IF;

           --/Adiciona caracter a esquerda
           IF P_lnfe_car_esquerda IS NOT NULL THEN NULL;
               vp_return := LPAD(vp_return, P_lnfe_tam_max, P_lnfe_car_esquerda);
           END IF;

           RETURN TRANSLATE(UPPER(TRIM(VP_return)),
                                  '??AaAaAaCcEeEeEeIiIiOoOo??OoUuUuUu??"!#$%?]}?'`[{?~^/?<>',
                                  'AaAaAaAaCcEeEeEeIiIiOoOoOoOoUuUuUunN........))o..((a...o()');
       v$_prog := 'PRC_GERA_XML_NFE';
       EXCEPTION
       WHEN OTHERS THEN
           NULL;
       END XML_fnc_format;
       --/
       --/Funcao para montar o corpo do XML 'by RFS'
       FUNCTION XML_fnc_conteudo_tag (p_xml IN out tb_xml_struct, p_idx IN INTEGER,  sc OUT ty_controle_rec)
          RETURN BOOLEAN
       IS
       BEGIN v$_prog := 'XML_fnc_conteudo_tag';
           IF ((p_xml (p_idx).LNFE_TIPO IN ('C','N','D','K')) OR
              (p_xml (p_idx).LNFE_TIPO IN ('T') AND  p_xml (p_idx).LNFE_ATRIBUTO_TAG IS NOT NULL))
           THEN
              p_xml (p_idx).ind_conteudo := 1;
              RETURN TRUE;
           ELSE
              p_xml (p_idx).ind_conteudo := 0;
              RETURN FALSE;
           END IF;
       v$_prog := 'PRC_GERA_XML_NFE';
       END XML_fnc_conteudo_tag;

       --/Procedimento para armazenar string XML em tempo de execuc?o 'by RFS'
       PROCEDURE XML_armazena_blob (p_str IN VARCHAR2, p_lob IN OUT BLOB, sc OUT ty_controle_rec)
       IS
          rawchar     RAW (1);
          rawbuffer   RAW (32767);
          itamanho    NUMBER;
          v_blob      BLOB  := p_lob;
       BEGIN v$_prog := 'ARMAZENA_BLOB';
          rawbuffer := UTL_RAW.cast_to_raw (NVL(p_str, ' '));
          itamanho  := UTL_RAW.LENGTH (rawbuffer);
          DBMS_LOB.writeappend (v_blob, itamanho, rawbuffer);
          p_lob := v_blob;
       v$_prog := 'PRC_GERA_XML_NFE';
       EXCEPTION
       WHEN OTHERS THEN
           sc.txt_ret   := 'Erro ao armaxenar conteudo XML em BLOB. Entre em contato com o administrador do sistema.';
           sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_    := TRUE;
       END XML_armazena_blob;

   --/Procedimento atualizar status de controle de envio NF-e 'by RFS'
   PROCEDURE prc_atlz_st_controle (
      p_id_control IN      a02_in_req_nfe_HEADER.id_controle%TYPE,
      sc           OUT    ty_controle_rec
   )  --a02_in_req_nfe_HEADER a where a.ID_CONTROLE
   IS --Cursor de retorno do da estrutura do XML por estrutura
   BEGIN
       FOR cur_ctrl IN (select * from vw_infe_atlz_controle)
       LOOP
           UPDATE infe_req_control y
              SET y.chave_acesso_nfe   = cur_ctrl.chave_acesso_nfe,
                  y.codigo_situacao    = cur_ctrl.codigo_situacao,
                  y.descricao_situacao = cur_ctrl.descricao_situacao,
                  y.protocolo          = cur_ctrl.protocolo,
                  y.xml_out            = cur_ctrl.XML_RETORNO,
                  y.st_proc            = cur_ctrl.st_proc
            WHERE y.chave_origem || y.acao = y.chave_origem || y.acao;
       END LOOP;
       COMMIT;
   END prc_atlz_st_controle;
   --/

   --/Procedimento para geracao de XML para emiss?o de DNAFE (NF-e) 'by RFS'
   PROCEDURE prc_gera_xml_nfe (
      p_id_control IN      a02_in_req_nfe_HEADER.id_controle%TYPE,
      p_rec_xml_header       tb_xml_struct,
      P_col_header           VARCHAR2,
      p_rec_xml_detail       tb_xml_struct,
      P_col_detail           VARCHAR2,
      p_xml        IN OUT    VARCHAR2,
      sc           OUT    ty_controle_rec
   )  --a02_in_req_nfe_HEADER a where a.ID_CONTROLE
   IS --Cursor de retorno do da estrutura do XML por estrutura
      CURSOR cur_estruct_xml (P_estruct IN Infe_leiaute_xml.lnfe_estr_id%TYPE)
      IS
            SELECT  LEVEL             ,
                    LNFE_ID           ,
                    LNFE_ID_PAI       ,
                    LNFE_ESTR_ID      ,
                    LNFE_ESTR_ID_NEXT ,
                    LNFE_SEQ          ,
                    LNFE_STATUS       ,
                    LNFE_TAG_XML      ,
                    LNFE_TAG_DESC     ,
                    LNFE_ATRIBUTO_TAG ,
                    LNFE_VALOR_DEFAULT,
                    LNFE_COLUNA       ,
                    LNFE_TAM_MAX      ,
                    LNFE_TAM_ELE      ,
                    LNFE_TIPO         ,
                    LNFE_DEC          ,
                    LNFE_OBRG         ,
                    LNFE_OBS          ,
                    LNFE_USR_INC      ,
                    LNFE_USR_DT_INC   ,
                    LNFE_USR_ATLZ     ,
                    LNFE_USR_DT_ATLZ  ,
                    LNFE_CAR_DIREITA  ,
                    LNFE_CAR_ESQUERDA ,
                    ' ' conteudo      ,
                    0 ind_fecha_tag   ,
                    DECODE(LNFE_TIPO,'C',1,'N',1,'D',1,'K',1,
                       CASE
                          WHEN LNFE_TIPO = 'T' AND  LNFE_ATRIBUTO_TAG IS NOT NULL THEN
                           1
                          ELSE
                           0
                       END ) ind_conteudo ,
                    DECODE(  DECODE(LNFE_TIPO,'C',1,'N',1,'D',1,'K',1,
                               CASE
                                  WHEN LNFE_TIPO = 'T' AND  LNFE_ATRIBUTO_TAG IS NOT NULL THEN
                                   1
                                  ELSE
                                   0
                               END ), 1, 'pkg_nfe.xml_fnc_format('''||lnfe_tipo||''','||lnfe_dec||','||lnfe_tam_max||','||
                                                                              NVL2(lnfe_car_direita  ,''||lnfe_car_direita||'','NULL' )||','||
                                                                              NVL2(lnfe_car_esquerda ,''||lnfe_car_esquerda||'','NULL' )||','||
                                                                              'a.'||LNFE_COLUNA||') '||  LNFE_COLUNA ||
                               ', ')  col_select
              FROM Infe_leiaute_xml a
              WHERE a.LNFE_STATUS   > 0 --/somente ativo
                AND lnfe_estr_id    = P_estruct --/Estrutura ID
                AND EXISTS (SELECT 0 --/Verifica se o campo PAI esta ativo
                              FROM infe_leiaute_xml b
                             WHERE ((b.lnfe_id   = a.lnfe_id_pai) OR (b.lnfe_id_pai = 1))
                               AND lnfe_status > 0)
           CONNECT BY PRIOR lnfe_id = lnfe_id_pai
             START WITH lnfe_id_pai = 1
             ORDER SIBLINGS BY lnfe_id_pai,  lnfe_seq;    --lnfe_id;


       v_string     VARCHAR2 (32767);       --/Armazenar String XML
       v_blob       BLOB;                   --/Armazenar String BLOB XML para manipulac?o
       v_rot        VARCHAR2(40) := 'PRC_GERA_XML_NFE';

       --/Variaveis para cursor dinamico
       vp_$cur_header   INTEGER;
       vp_$cur_detail   INTEGER;
       vp_$col_header   INTEGER := 0;
       vp_$col_detail   INTEGER := 0;
       vp_$temp         NUMBER;
       vp_$query        VARCHAR2(32767);
       vp_$return       BOOLEAN := FALSE;
       vp_$level        INTEGER;

--*****************************************
--   B  E  G  I  N    "N  F  E"
--*****************************************
   BEGIN v$_prog := 'PRC_GERA_XML_NFE';

      --/Monta curdor dinamico do Header
      vp_$query := 'SELECT '||p_col_header||'0 END FROM VW_infe_req_header a where a.ID_CONTROLE = '||NVL(TO_CHAR(p_id_control),'a.ID_CONTROLE');
     PCK_INFE_UTIL.prc_debug_sql_dinamico(NULL,vp_$query, 'CC','INFE'||'.'||v$_rot_glb||'.'||v_rot);
      BEGIN
          vp_$cur_header := DBMS_SQL.open_cursor;
          DBMS_SQL.parse (vp_$cur_header, vp_$query, DBMS_SQL.native);
      EXCEPTION
      WHEN OTHERS THEN
          PCK_INFE_UTIL.prc_debug_sql_dinamico(NULL,vp_$query, 'CC','INFE'||'.'||v$_rot_glb||'.'||v_rot);
          sc.txt_ret   := 'Erro ao carregar cursor dinamico Header. Entre em contato com o administrador do sistema.';
          sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_    := TRUE;
          GOTO gera_erro;
      END;
      vp_$col_header := 0;

      BEGIN
          --/DBMS_SQL.DEFINE_COLUMN - Cursor Dinamico
          FOR i IN rec_xml_header.FIRST .. rec_xml_header.LAST
          LOOP
              IF  rec_xml_header (i).ind_conteudo = 1 THEN  --  XML_fnc_conteudo_tag (rec_xml_header, i,sc) THEN
                  vp_$col_header := vp_$col_header+1;
                  DBMS_SQL.define_column (vp_$cur_header, vp_$col_header, rec_xml_header (i).conteudo, rec_xml_header (i).lnfe_tam_max);
              END IF;
          END LOOP;
          vp_$temp := DBMS_SQL.EXECUTE (vp_$cur_header);
      EXCEPTION
      WHEN OTHERS THEN
          PCK_INFE_UTIL.prc_debug_sql_dinamico(NULL,vp_$query, 'CC','INFE'||'.'||v$_rot_glb||'.'||v_rot);
          sc.txt_ret   := 'Erro ao setar colunas cursor dinamico Header. Entre em contato com o administrador do sistema.';
          sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_    := TRUE;
          GOTO gera_erro;
      END;

      LOOP
          IF DBMS_SQL.fetch_rows (vp_$cur_header) = 0 THEN
             IF vp_$return = FALSE THEN
                dbms_output.put_line('Header Registro N?o Encontrado!');
             END IF;
                dbms_output.put_line('Header Saindo ...');
             EXIT;
          ELSE
             v_string       := NULL;
             vp_$return     := TRUE;
             vp_$col_header := 0;

             --/DBMS_SQL.COLUMN_VALUE - Cursor Dinamico
             FOR i IN rec_xml_header.FIRST .. rec_xml_header.LAST
             LOOP
                 BEGIN
                     IF rec_xml_header (i).ind_conteudo = 1 THEN  --  XML_fnc_conteudo_tag (rec_xml_header, i,sc) THEN
                         vp_$col_header := vp_$col_header+1;
                         DBMS_SQL.column_value (vp_$cur_header, vp_$col_header, rec_xml_header (i).conteudo);
                       --  rec_xml_header (i).conteudo := fnc_format (rec_xml_header, i,sc);
                         IF sc.raise_ THEN GOTO gera_erro; END IF;
                     END IF;
                 EXCEPTION
                 WHEN OTHERS THEN
                     sc.txt_ret   := 'Erro ao definir colunas cursor dinamico Header. Entre em contato com o administrador do sistema.';
                     sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_  := TRUE;
                     GOTO gera_erro;
                 END;

                 v$_lnfe_id       := rec_xml_header(i).lnfe_id     ;
                 v$_lnfe_id_pai   := rec_xml_header(i).lnfe_id_pai ;
                 v$_lnfe_tag_xml  := rec_xml_header(i).lnfe_tag_xml;
                 v$_lnfe_tipo     := rec_xml_header(i).lnfe_tipo   ;

                 BEGIN
                     --/escreve XML HEADER
                     IF rec_xml_header(i).lnfe_estr_id_next >= rec_xml_header(i).lnfe_estr_id THEN
                         v_string := v_string || XML_fnc_mount (rec_xml_header, rec_xml_header(I).conteudo,i,rec_tag_header,sc);
                         IF sc.raise_ THEN GOTO gera_erro; END IF;
                     END IF;
                 EXCEPTION
                 WHEN OTHERS THEN
                     sc.txt_ret   := 'Erro ao escrever Header XML. Entre em contato com o administrador do sistema.';
                     sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_  := TRUE;
                     GOTO gera_erro;
                 END;

                  --************ D E T A I L ************--
                  --/Verifica se a proxima tag e proxima estrutura de DETAIL
                 IF rec_xml_header(i).lnfe_estr_id_next > rec_xml_header(i).lnfe_estr_id THEN
                      --/Monta curdor dinamico do Detail

                      vp_$query := 'SELECT '||p_col_detail||'0 END FROM VW_infe_req_detail a where a.id_req_header = '||rec_xml_header(I).conteudo|| 'order by a.id ';

                      --/Inicio processo de carga de dados nas variaveis dinamicas
                     BEGIN
                          vp_$cur_detail := DBMS_SQL.open_cursor;
                          DBMS_SQL.parse (vp_$cur_detail, vp_$query, DBMS_SQL.native);
                      EXCEPTION
                      WHEN OTHERS THEN
                          PCK_INFE_UTIL.prc_debug_sql_dinamico(NULL,vp_$query, 'CC','INFE'||'.'||v$_rot_glb||'.'||v_rot);
                          sc.txt_ret   := 'Erro ao carregar cursor dinamico Detail. Entre em contato com o administrador do sistema.';
                          sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_    := TRUE;
                          GOTO gera_erro;
                      END;
                      vp_$col_detail := 0;

                      BEGIN
                          --/DBMS_SQL.DEFINE_COLUMN - Cursor Dinamico
                          FOR j IN rec_xml_detail.FIRST .. rec_xml_detail.LAST
                          LOOP
                              IF rec_xml_detail (j).ind_conteudo = 1 THEN  --  XML_fnc_conteudo_tag (rec_xml_detail, j,sc) THEN
                                  vp_$col_detail := vp_$col_detail+1;
                                  DBMS_SQL.define_column (vp_$cur_detail, vp_$col_detail, rec_xml_detail (j).conteudo, rec_xml_detail (j).lnfe_tam_max);
                              END IF;
                          END LOOP;
                          vp_$temp := DBMS_SQL.EXECUTE (vp_$cur_detail);
                      EXCEPTION
                      WHEN OTHERS THEN
                          PCK_INFE_UTIL.prc_debug_sql_dinamico(NULL,vp_$query, 'CC','INFE'||'.'||v$_rot_glb||'.'||v_rot);
                          sc.txt_ret   := 'Erro ao setar colunas cursor dinamico Detail. Entre em contato com o administrador do sistema.';
                          sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_    := TRUE;
                          GOTO gera_erro;
                      END;

                      LOOP
                         IF DBMS_SQL.fetch_rows (vp_$cur_detail) = 0 THEN
                            IF vp_$return = FALSE THEN
                               dbms_output.put_line('Detail Registro N?o Encontrado!');
                            END IF;
                               dbms_output.put_line('Detail Saindo ...');
                            EXIT;
                         ELSE
                            vp_$return := TRUE;
                            vp_$col_detail := 0;
                            --/DBMS_SQL.COLUMN_VALUE - Cursor Dinamico
                            FOR j IN rec_xml_detail.FIRST .. rec_xml_detail.LAST
                            LOOP

                                BEGIN
                                    IF rec_xml_detail (j).ind_conteudo = 1 THEN  --   XML_fnc_conteudo_tag (rec_xml_detail, j,sc) THEN
                                        vp_$col_detail := vp_$col_detail+1;
                                        DBMS_SQL.column_value (vp_$cur_detail, vp_$col_detail, rec_xml_detail (j).conteudo);
                                       -- rec_xml_detail (j).conteudo := fnc_format (rec_xml_detail, j,sc);
                                        IF sc.raise_ THEN GOTO gera_erro; END IF;
                                    END IF;
                                EXCEPTION
                                WHEN OTHERS THEN
                                    sc.txt_ret   := 'Erro ao definir colunas cursor dinamico Detail. Entre em contato com o administrador do sistema.';
                                    sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_  := TRUE;
                                    GOTO gera_erro;
                                END;

                                BEGIN
                                    --/Identifica a sequencia do item da NF (Atributo de Tag)
                                    IF rec_xml_detail.FIRST = j THEN
                                        vp_$level                     := rec_xml_header(I).LEVEL;
                                        rec_xml_header(I).LEVEL       := rec_xml_DETAIL(j).LEVEL;
                                        v_string := v_string || XML_fnc_mount (rec_xml_header, NULL,I,rec_tag_header,sc);
                                        rec_xml_header(I).LEVEL       :=  vp_$level;
                                        IF sc.raise_ THEN GOTO gera_erro; END IF;
                                        rec_xml_detail(j).lnfe_atributo_tag :=  ' nItem="'||rec_xml_detail (j).conteudo||'"';
                                    END IF;
                                EXCEPTION
                                WHEN OTHERS THEN
                                    sc.txt_ret   := 'Erro ao Identifica a sequencia do item da NF Detail. Entre em contato com o administrador do sistema.';
                                    sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_  := TRUE;
                                    GOTO gera_erro;
                                END;

                                BEGIN
                                    --/escreve XML DETAIL
                                    v_string := v_string || XML_fnc_mount (rec_xml_detail, rec_xml_detail (j).conteudo, j,rec_tag_detail,sc);
                                    IF sc.raise_ THEN GOTO gera_erro; END IF;
                                EXCEPTION
                                WHEN OTHERS THEN
                                    sc.txt_ret   := 'Erro ao escrever Detail XML. Entre em contato com o administrador do sistema.';
                                    sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_  := TRUE;
                                    GOTO gera_erro;
                                END;

                            END LOOP;

                            BEGIN
                                v_string := v_string || XML_close (rec_xml_detail,sc);
                                IF sc.raise_ THEN GOTO gera_erro; END IF;
                            EXCEPTION
                            WHEN OTHERS THEN
                                sc.txt_ret   := 'Erro ao fechar estrutura XML Detail. Entre em contato com o administrador do sistema.';
                                sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_  := TRUE;
                                GOTO gera_erro;
                            END;
                         END IF;
                      END LOOP;

                      DBMS_SQL.close_cursor (vp_$cur_detail);

                  END IF;
             END LOOP;

             BEGIN
                 v_string := v_string || XML_close (rec_xml_header,sc);
                 IF sc.raise_ THEN GOTO gera_erro; END IF;
             EXCEPTION
             WHEN OTHERS THEN
                 sc.txt_ret   := 'Erro ao fechar estrutura XML Header. Entre em contato com o administrador do sistema.';
                 sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_  := TRUE;
                 GOTO gera_erro;
             END;

          END IF;

          BEGIN
              v_string := v_string || XML_close (rec_xml_header,sc);
              p_xml := v_string;
              IF sc.raise_ THEN GOTO gera_erro; END IF;
          EXCEPTION
          WHEN OTHERS THEN
              sc.txt_ret   := 'Erro ao fechar estrutura XML. Entre em contato com o administrador do sistema.';
              sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_  := TRUE;
              GOTO gera_erro;
          END;
      END LOOP;
      DBMS_SQL.close_cursor (vp_$cur_header);

      v$_prog := 'PRC_REQ_DANFE';
      <<gera_erro>>

      p_xml := v_string;
      rec_xml_header.DELETE;
      rec_xml_detail.DELETE;
      rec_tag_header.DELETE;


   END prc_gera_xml_nfe;

   --/Procedimento para requisitar emiss?o de DNAFE (NF-e) para o Conector Synchro 'by RFS'
   PROCEDURE prc_req_danfe (
      p_gera_arq   IN      VARCHAR2 DEFAULT 'N',
      p_retcode    IN      VARCHAR2,
      p_mensagem   IN      VARCHAR2,
      p_nome_arq   IN      VARCHAR2
   )
   IS

      --Cursor de retorno do da estrutura do XML por estrutura
      CURSOR cur_estruct_xml (P_estruct IN Infe_leiaute_xml.lnfe_estr_id%TYPE)
      IS
            SELECT  LEVEL             ,
                    LNFE_ID           ,
                    LNFE_ID_PAI       ,
                    LNFE_ESTR_ID      ,
                    LNFE_ESTR_ID_NEXT ,
                    LNFE_SEQ          ,
                    LNFE_STATUS       ,
                    LNFE_TAG_XML      ,
                    LNFE_TAG_DESC     ,
                    LNFE_ATRIBUTO_TAG ,
                    LNFE_VALOR_DEFAULT,
                    LNFE_COLUNA       ,
                    LNFE_TAM_MAX      ,
                    LNFE_TAM_ELE      ,
                    LNFE_TIPO         ,
                    LNFE_DEC          ,
                    LNFE_OBRG         ,
                    LNFE_OBS          ,
                    LNFE_USR_INC      ,
                    LNFE_USR_DT_INC   ,
                    LNFE_USR_ATLZ     ,
                    LNFE_USR_DT_ATLZ  ,
                    LNFE_CAR_DIREITA  ,
                    LNFE_CAR_ESQUERDA ,
                    ' ' conteudo      ,
                    0 ind_fecha_tag   ,
                    DECODE(LNFE_TIPO,'C',1,'N',1,'D',1,'K',1,
                       CASE
                          WHEN LNFE_TIPO = 'T' AND  LNFE_ATRIBUTO_TAG IS NOT NULL THEN
                           1
                          ELSE
                           0
                       END ) ind_conteudo ,
                    DECODE(  DECODE(LNFE_TIPO,'C',1,'N',1,'D',1,'K',1,
                               CASE
                                  WHEN LNFE_TIPO = 'T' AND  LNFE_ATRIBUTO_TAG IS NOT NULL THEN
                                   1
                                  ELSE
                                   0
                               END ), 1, 'pkg_nfe.xml_fnc_format('''||lnfe_tipo||''','||lnfe_dec||','||lnfe_tam_max||','||
                                                                              NVL2(lnfe_car_direita  ,''||lnfe_car_direita||'','NULL' )||','||
                                                                              NVL2(lnfe_car_esquerda ,''||lnfe_car_esquerda||'','NULL' )||','||
                                                                              'a.'||LNFE_COLUNA||') '||  LNFE_COLUNA ||
                               ', ')  col_select
              FROM Infe_leiaute_xml a
              WHERE a.LNFE_STATUS   > 0 --/somente ativo
                AND lnfe_estr_id    = P_estruct --/Estrutura ID
                AND EXISTS (SELECT 0 --/Verifica se o campo PAI esta ativo
                              FROM infe_leiaute_xml b
                             WHERE ((b.lnfe_id   = a.lnfe_id_pai) OR (b.lnfe_id_pai = 1))
                               AND lnfe_status > 0)
           CONNECT BY PRIOR lnfe_id = lnfe_id_pai
             START WITH lnfe_id_pai = 1
             ORDER SIBLINGS BY lnfe_id_pai,  lnfe_seq;    --lnfe_id;


   v$xml     VARCHAR2(32767);
   TYPE xml_vt IS TABLE OF VARCHAR (5000)INDEX BY BINARY_INTEGER;
   v$xml_vt  xml_vt;
   v$xml_qt  INTEGER;
   v$max_c   INTEGER := TO_NUMBER(pck_infe_util.fnc_parametro (1, NULL, NULL, 'E'));
   vp_id_seq INTEGER;
   sc        ty_controle_rec;
   idx          NUMBER := 1;            --/Indice de controle PL/Table
   v_col_header VARCHAR2(32767) := ' '; --/Colunas do Header para sql Dinamico
   v_col_detail VARCHAR2(32767) := ' '; --/Colunas do Detail para sql Dinamico

   BEGIN v$_prog := 'PRC_REQ_DANFE';

       idx := 1;
       BEGIN
           FOR cur_xml IN cur_estruct_xml (1)
           LOOP --/ popular  PL/SQL
               rec_xml_header (idx) := cur_xml;
               v_col_header := v_col_header||rec_xml_header (idx).col_select;
               idx := idx + 1; --/ incremento index
           END LOOP;
           --/Carrega etrutura DETAIL do XML
           FOR cur_xml IN cur_estruct_xml (2)
           LOOP --/ popular  PL/SQL
               rec_xml_detail (idx) := cur_xml;
               v_col_detail := v_col_detail||rec_xml_detail (idx).col_select;
               idx := idx + 1; --/ incremento index
           END LOOP;
       EXCEPTION
       WHEN OTHERS THEN
           sc.txt_ret   := 'Erro ao carregar estrutura (Header / Detail) XML. Entre em contato com o administrador do sistema.';
           sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_    := TRUE;
           --GOTO gera_erro;
       END;

       --/Altera casa decimal para ponto(.)
       EXECUTE IMMEDIATE 'alter session set NLS_NUMERIC_CHARACTERS=''.,''';

     --  prc_atlz_st_controle (null,sc);

       FOR cur_CTRL IN ( SELECT a.ID                  ,a.PRIORIDADE          ,
                                a.CHAVE_ORIGEM        ,a.PSSW_ID             ,
                                a.STATUS              ,a.ACAO                ,
                                a.SISTEMA_ORIGEM      ,a.TIPO_ENVIO          ,
                                a.IMPRESSORA          ,a.COPIAS              ,
                                a.DH_ENVIO_CONECTOR   ,a.TENTATIVAS_RESPOSTA ,
                                a.DH_RETORNO_CONECTOR ,a.CHAVE_ACESSO_NFE    ,
                                a.PROTOCOLO           ,a.CODIGO_SITUACAO     ,
                                a.DESCRICAO_SITUACAO  ,a.DT_EXPIRA           ,
                                a.DT_INCL             ,a.DT_ATLZ             ,
                                NULL DH_RECEBIMENTO   ,NULL ENVIADO_DFE
                          FROM infe_req_control a
                         WHERE --A.CODIGO_SITUACAO IS NULL
                         1=1
                            AND EXISTS (
                                  SELECT '*'
                                    FROM a02_in_req_nfe_HEADER b
                                   WHERE b.id_controle = a.id
                                     AND EXISTS (SELECT '*'
                                                   FROM a02_in_req_nfe_detail c
                                                  WHERE b.id = c.id_req_header))
         /*   and a.ID = 31*/           ORDER BY a.ID
       )
       LOOP
           BEGIN
               v$xml := NULL;

               pkg_nfe.prc_gera_xml_nfe (cur_CTRL.ID, rec_xml_header, v_col_header, rec_xml_detail, v_col_detail, v$xml, sc);

               IF sc.raise_ THEN GOTO next_nfe; END IF;

               --/Verifica a quantidade de arquivos XML para gerar
              /* v$xml_qt := CEIL(LENGTH (v$xml) / v$max_c);

               --/Divide o arquivo XML
               FOR i IN 0 .. v$xml_qt-1
               LOOP
                   v$xml_vt(i) := SUBSTR(v$xml,(i*v$max_c),v$max_c-1);
               END LOOP; */
           EXCEPTION
           WHEN OTHERS THEN
               sc.txt_ret   := 'Erro na geracao do arquivo XML. Entre em contato com o administrador do sistema.';
               sc.v$errm    := SQLERRM;  sc.tip_ret   := 'E';  sc.raise_  := TRUE;
               GOTO next_nfe;
            END;
           sc.txt_ret   := 'Sucesso no na requisic?o de emiss?o de NF-e (DANFE). Sistema Origem: ('||cur_CTRL.SISTEMA_ORIGEM||') Chave Origem: ('||cur_CTRL.CHAVE_ORIGEM||').';
           sc.v$errm    := null;  sc.tip_ret   := 'S';  sc.raise_  := FALSE;

           <<next_nfe>>

                BEGIN
                    UPDATE infe_req_control y
                       SET y.st_proc            = 1,
                           y.xml_in             = v$xml
                     WHERE y.chave_origem || y.acao = y.chave_origem || y.acao;

                     COMMIT;
                END;
            v$xml_vt.DELETE;

            COMMIT;
       END LOOP;

   END prc_req_danfe;

END pkg_nfe;
/
