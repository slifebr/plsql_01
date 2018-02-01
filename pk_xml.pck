create or replace package pk_xml is

   /*
          AUTOR: SERGIO LIMA FEITOSA
          DATA : 12/02/2011
   */
   
   subtype Tnum           is number;
   subtype TChar          is varchar2 (1);
   subtype TStr           is varchar2 (32767);
   subtype TCurs          is pls_integer;
   subtype TInt           is pls_integer;
   subtype TId            is number (10);
      
   gv_objeto              Tstr := $$plsql_unit;
   gv_msg_erro            Tstr;
   gn_id_erro             Tint;   
   
   vg_name_space     varchar2(500) := 'xmlns="http://www.portalfiscal.inf.br/nfe';
   vg_masc_time_zone varchar2(50) := 'YYYY-MM-DD"T"HH24:MI:SS TZH:TZM';
   -------------------------------------------------------------------------------------------
   -- Function and procedure implementations
   procedure gravar_xml_nfe(p_dir     varchar2
                           ,p_arq     varchar2
                           ,p_charset varchar2 default 'AL32UTF8'
                           ,p_dt      date
                           ,p_org     number);
   ------------------------------------------------------------------------------------------
   procedure insertxml(dirname  in varchar2
                      ,filename in varchar2);
   --------------------------------------------------------------------------
   --/ RETORNA IDENTIFICAC?O DA NF
   function id_nfe(p_id xml_nfe.id%type) return varchar2;
   --------------------------------------------------------------------------
   --/ RETORNA IDENTIFICAC?O DA NF
   function digest_value_nfe(p_id xml_nfe.id%type) return varchar2;
   --|-------------------------------------------------------
   procedure sincroniza_xml_nf(p_emp number
                              ,p_fil number
                              ,p_id  xml_nfe.id%type);
   --|--------------------------------------------------------
   procedure exporta_nfe_cenota(p_emp    number
                               ,p_fil    number
                               ,p_id  xml_nfe.id%type
                               ,p_id_nfe number);
   --|--------------------------------------------------------
   function is_xml_nfe(p_id number) return boolean;
   --|--------------------------------------------------------
   function dados_nota_xml_nfe(p_id number) return varchar2;
   --|----------------------------------------------------------------------
   function Emitente_xml_nfe(p_id number) return varchar2;   
   --|--------------------------------------------------------
   function Cnpj_Emitente_xml_nfe(p_id number) return varchar2;
   --|-------------------------------------------------------
   function fl_relacao_produto_fornec(p_forn ce_prod_fornec.cod_fornec%type
                                     ,p_prd  ce_prod_fornec.prod_fornec%type)
      return ce_produtos.produto%type;

   --|-------------------------------------------------------
   function fl_tem_produto_fornec(p_forn ce_prod_fornec.cod_fornec%type
                                 ,p_prd  ce_prod_fornec.prod_fornec%type)
      return boolean;

   --|---------------------------------------------------------------------------
   --| atualiza produtos fornecedor com codigo oficial pelo codigo do prod. do forn.
   --|---------------------------------------------------------------------------

   procedure pr_relacao_produto_fornec(p_forn    ce_prod_fornec.cod_fornec%type
                                      ,p_prd_f   ce_prod_fornec.prod_fornec%type
                                      ,p_emp     ce_produtos.empresa%type
                                      ,p_prd_ofc ce_produtos.produto%type);

   --|---------------------------------------------------------------------------
   --| atualiza produtos fornecedor com codigo oficial pelo id da nfe_detalhe
   --|---------------------------------------------------------------------------                                      
   procedure pr_relacao_produto_fornec_id(p_forn    ce_prod_fornec.cod_fornec%type
                                         ,p_id_det  nfe_detalhe.id%type
                                         ,p_emp     ce_produtos.empresa%type
                                         ,p_prd_ofc ce_produtos.produto%type);
end;
/
create or replace package body pk_xml is
   ----------------------------------------------------------------------------------------
   /*
    Objetivo: Pacote com funcoes e procedimentos para Grava e Ler arquivo XML
    AUTOR: SERGIO LIMA FEITOSA
    DATA : 12/02/2011
   */
  
   ----------------------------------------------------------------------------------------
   --|funcoes locais
   --|--------------

   function is_unid_oficial(p_un nfe_detalhe.unidade_comercial%type)
      return boolean is
      cursor cr is
         select u.unidade from ce_unid u where u.unidade = p_un;
   
      v_ret   boolean;
      v_achou ce_unid.unidade%type;
   
   begin
      v_ret := true;
   
      open cr;
      fetch cr
         into v_achou;
      close cr;
   
      if v_achou is null then
         v_ret := false;
      end if;
   
      return v_ret;
   end;

   /*
   Procedimento :  gravar_xml_nfe
   Objetivo: Carregar um arquivo xml emitidos ou recebidos das Notas Fiscais  para tabela do banco
   AUTOR: SERGIO
   DATA: 12/02/2011
   OCORRENCIAS:
   */
   -- Function and procedure implementations
   procedure gravar_xml_nfe(p_dir     varchar2
                           ,p_arq     varchar2
                           ,p_charset varchar2 default 'AL32UTF8'
                           ,p_dt      date
                           ,p_org     number) is
   
      ------------------------------------------------------------
      -- p_dir = 'XML_DIR'
      -- P_ARQ = 'arq1.xml'
      -- p_charset = 'AL32UTF8'
      -- p_org    - 0 emissao empresa    (ft_notas)
      --          - 1 emissao fornecedor (ce_notas)
      -- exemplo: PK_XML.gravar_xml_nfe('XML_DIR','135100026769006_v1.10-procNFe.xml',Null,Sysdate,0);
      ------------------------------------------------------------
      cursor cr is
         select 1 from xml_nfe where arquivo = p_arq;
   
      --/ VARIAVEIS
      v_charset varchar2(30) := 'AL32UTF8';
      v_achou   number(1) := 0;
      v_xmlfile XMLTYPE;
      v_clob    clob;
      v_BFILE BFILE;
    
   begin
      if p_charset is not null then
         v_charset := p_charset;
      end if;
   
      open cr;
      fetch cr
         into v_achou;
      close cr;
   
      if nvl(v_achou,
             0) = 0 then
         --empty_clob(v_clob);
         v_clob := null;
         v_BFILE := bfilename(upper(p_dir), p_arq);
         -- novo
         /*
         if (dbms_lob.fileexists(v_bfile) = 1) then
            DBMS_LOB.FILEOPEN(v_BFILE, DBMS_LOB.FILE_READONLY);
            DBMS_LOB.LOADFROMFILE(v_CLOB, v_BFILE, DBMS_LOB.GETLENGTH(v_BFILE));
            DBMS_LOB.FILECLOSE(v_BFILE);
          end if; 
          */          
         --|
         --v_xmlfile := XMLTYPE(v_clob, nls_charset_id(v_charset));
                  v_xmlfile := xmltype(v_bfile,
                     nls_charset_id(v_charset));
         /*
         v_xmlfile := xmltype(bfilename(upper(p_dir),
                               p_arq),
                     nls_charset_id(v_charset));
         */
         insert into xml_nfe
            (id
            ,dt
            ,origem
            ,status
            ,xml_arq
            ,usu_sis
            ,dt_sis
            ,usu_sinc
            ,dt_sinc
            ,arquivo)
         values
            (xml_nfe_seq.nextval
            ,trunc(p_dt)
            ,p_org
            ,'N'
            ,v_xmlfile
            ,user
            ,sysdate
            ,null
            ,null
            ,p_arq);
      
      end if;
 exception
      when others then      
         if sqlcode <> -20001 then
--
           gv_msg_erro := fg_get_line_error (ev_local   => gv_objeto
                                            ,ev_msg_usu => 'PK_xml.gravar_xml_nfe'
                                            ,ev_msg_ora => sqlerrm);
--         
           gv_msg_erro := p_arq ||' | '||gv_msg_erro;
           raise_application_error (-20001,gv_msg_erro|| ' ## '|| p_arq);
--
        end if;
--
        raise;      
   end;

   ----------------------------------------------------------------------------------------
   /*
   Procedimento :  InsertXML
   Objetivo: Carregar um arquivo xml para um campo clob no banco
   AUTOR: SERGIO
   DATA: 12/02/2011
   OCORRENCIAS:
   */

   procedure insertxml(dirname  in varchar2
                      ,filename in varchar2) is
      xmlfile bfile;
      myclob  clob;
   
   begin
      insert into xml_t_clob
         (nome_arq
         ,reg_xml)
      values
         (filename
         ,empty_clob())
      returning reg_xml into myclob;
   
      -- get a handle to the xml file on the OS
      xmlfile := bfilename(dirname,
                           filename);
   
      -- open the file
      dbms_lob.fileopen(xmlfile);
   
      -- copy the contents of the file into the empty clob
      dbms_lob.loadfromfile(myclob,
                            xmlfile,
                            dbms_lob.getlength(xmlfile));
   
   end insertxml;
   --------------------------------------------------------------------------
   /*
   Funcao :  ide_uf_nfe
   Objetivo: RETORNA IDENTIFICAC?O DA NF
   AUTOR: SERGIO
   DATA: 12/02/2011
   OCORRENCIAS:
   */
   function id_nfe(p_id xml_nfe.id%type) return varchar2 is
      --/ CURSORES
      cursor cr is
         select extractvalue(value(nnf),
                             '/infNFe/@Id',
                             vg_name_space) id
           from xml_nfe a
               ,table(xmlsequence(extract(xml_arq,
                                          '/nfeProc/NFe/infNFe',
                                          vg_name_space))) nnf
          where a.id = p_id;
   
      --/ VARIAVEIS
      v_ret varchar2(500);
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
      return v_ret;
   exception
      when others then
         v_ret := 'PL_XML.ID_NFE(ERRO): ' ||
                  substr(sqlerrm,
                         1,
                         100);
         return v_ret;
   end;
   --------------------------------------------------------------------------
   /*
   Funcao :  ide_uf_nfe
   Objetivo: RETORNA UF do Emitente
   AUTOR: SERGIO
   DATA: 12/02/2011
   OCORRENCIAS:
   */
   --------------------------------------------------------------------------
   function ide_uf_nfe(p_id xml_nfe.id%type) return varchar2 is
      --/ CURSORES
      cursor cr is
         select extractvalue(value(ide_uf),
                             '/ide/cUF',
                             vg_name_space) id
           from xml_nfe a
               ,table(xmlsequence(extract(xml_arq,
                                          '/nfeProc/NFe/infNFe/ide',
                                          vg_name_space))) ide_uf
          where a.id = p_id;
   
      --/ VARIAVEIS
      v_ret varchar2(500);
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
      return v_ret;
   exception
      when others then
         v_ret := 'PL_XML.ID_NFE(ERRO): ' ||
                  substr(sqlerrm,
                         1,
                         100);
         return v_ret;
   end;
   --------------------------------------------------------------------------
   --/ RETORNA IDENTIFICAC?O DA NF
   function digest_value_nfe(p_id xml_nfe.id%type) return varchar2 is
      --/AUTOR: SERGIO
      --/DATA: 12/02/2011
      --/OCORRENCIAS
      /*
      
      
      */
      --/
      --/ CURSORES
      cursor cr is
         select extractvalue(value(digest),
                             '/Reference/DigestValue',
                             'xmlns="http://www.w3.org/2000/09/xmldsig#"') id
           from xml_nfe a
               ,table(xmlsequence(extract(xml_arq,
                                          '/nfeProc/NFe/Signature/SignedInfo/Reference',
                                          'xmlns="http://www.w3.org/2000/09/xmldsig#"'))) digest
          where a.id = p_id;
   
      --/ VARIAVEIS
      v_ret varchar2(500);
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
      return v_ret;
   exception
      when others then
         v_ret := 'PL_XML.digest_value_nfe(ERRO): ' ||
                  substr(sqlerrm,
                         1,
                         100);
         return v_ret;
   end;

   --|---------------------------------------------------------
   procedure ler_xml_linha is
   
      clobxml    clob;
      vr_clobarq clob;
      domxml     dbms_xmldom.domdocument;
      arquivo    utl_file.file_type;
      eof        boolean := false;
      linha      varchar2(32767);
   
   begin
      --Inicializar o CLOB
      dbms_lob.createtemporary(clobxml,
                               true,
                               dbms_lob.session);
      dbms_lob.open(clobxml,
                    dbms_lob.lob_readwrite);
   
      -- Abrir o arquivo para leitura
      arquivo := utl_file.fopen('/minha/pasta/',
                                'meuXML.xml',
                                'r');
   
      -- Loop de leitura linha a linha
      while not (eof) loop
         begin
            utl_file.get_line(arquivo,
                              linha);
            dbms_lob.writeappend(vr_clobarq,
                                 length(linha),
                                 linha);
         exception
            when no_data_found then
               eof := true;
         end;
      end loop;
   
      utl_file.fclose(arquivo);
   end;

   --|---------------------------------
   procedure ler_xml_dom is
      parse   xmlparser.parser;
      pasta   varchar2(400) := '/minha/pasta/';
      arqxml  varchar2(400) := 'meuXML.xml';
      arqerro varchar2(400) := 'arqErr.log';
      docdom  dbms_xmldom.domdocument;
   
   begin
      -- Instanciar o novo parse
      parse := xmlparser.newparser;
   
      -- Definir as características do parse
      xmlparser.setvalidationmode(parse,
                                  false);
      xmlparser.seterrorlog(parse,
                            pasta || '/' || arqerro);
      xmlparser.setbasedir(parse,
                           pasta);
   
      -- Capturar o arquivo para o parse
      xmlparser.parse(parse,
                      pasta || '/' || arqxml);
   
      -- get document
      docdom := xmlparser.getdocument(parse);
   end;

   procedure gravar_arquivo_xml is
      varclob   clob;
      varstring varchar2(4000);
   
   begin
      -- Abre a instancia do CLOB e o coloca em modo de escrita
      dbms_lob.createtemporary(varclob,
                               true);
      dbms_lob.open(varclob,
                    dbms_lob.lob_readwrite);
   
      -- Variável string para armazenar parte do XML
      varstring := '<?xml version="1.0" encoding="utf-8"?>' || '<root>' ||
                   '<teste>Este é um teste</teste>' || '</root>';
   
      -- Cria um XML simples de testes, pode ser dado quantos APPEND quiser e
      -- ir montando o XML durante sua rotina PL/SQL
      dbms_lob.writeappend(varclob,
                           length(varstring),
                           varstring);
   
      -- Aqui irá de fato gerar o arquivo físico do XML
      dbms_xslprocessor.clob2file(varclob,
                                  '/minha/pasta/',
                                  'teste.xml',
                                  nls_charset_id('UTF8'));
   
      -- Liberar dados do CLOB da memória
      dbms_lob.close(varclob);
      dbms_lob.freetemporary(varclob);
   end;

   --|
   procedure gravar_arquivo_xml_2 is
      varxml   clob;
      vartexto varchar2(4000);
      vardom   dbms_xmldom.domdocument;
   
   begin
      -- Exemplo de um XML para testes
      vartexto := '<?xml version="1.0" encoding="utf-8"?>' || '<raiz>' ||
                  '<texto>Teste de XML' || '<opt>Sem XSLT</opt>' || '</texto>' ||
                  '</raiz>';
   
      -- Inicializar o CLOB
      dbms_lob.createtemporary(varxml,
                               true);
      dbms_lob.open(varxml,
                    dbms_lob.lob_readwrite);
   
      -- Atribir texto (string) ao CLOB
      dbms_lob.writeappend(varxml,
                           length(vartexto),
                           vartexto);
   
      -- Inicia o processamento DOM e faz o parser utilizando XMLType.createXML
      vardom := dbms_xmldom.newdomdocument(xmltype.createxml(varxml));
   
      -- Cria o arquivo XML no disco
      dbms_xmldom.writetofile(vardom,
                              '/minha/pasta/meu_arquivo.xml');
   
      -- Liberar o objeto DOM da memória
      dbms_xmldom.freedocument(vardom);
   
      -- Liberar dados do CLOB da memória
      dbms_lob.close(varxml);
      dbms_lob.freetemporary(varxml);
   end;
   --|-------------------------------------------------------
   --| busca dados do campo xml_arq e gera dados NFe
   --|-------------------------------------------------------

   procedure sincroniza_xml_nf(p_emp number
                              ,p_fil number
                              ,p_id  xml_nfe.id%type) is
      cursor crcab is
         select a.id id_xml
               ,extractvalue(a.xml_arq,
                             '/nfeProc/protNFe/infProt/chNFe',
                             vg_name_space) chave_nfe
               ,extractvalue(a.xml_arq,
                             '/nfeProc/protNFe/infProt/cStat',
                             vg_name_space) status
               ,extractvalue(value(infnfe),
                             '//ide/cNF',
                             vg_name_space) cd_numero
               ,extractvalue(value(infnfe),
                             '//ide/cDV',
                             vg_name_space) digito_ver
               ,extractvalue(value(infnfe),
                             '//ide/nNF',
                             vg_name_space) numero_nf
               ,extractvalue(value(infnfe),
                             '//ide/serie',
                             vg_name_space) serie_nf
               ,extractvalue(value(infnfe),
                             '//ide/mod',
                             vg_name_space) mod_nf
                
               ,extractvalue(value(infnfe),
                             '//ide/natOp',
                             vg_name_space) natop
                
               ,extractvalue(value(infnfe),
                             '//ide/indPag',
                             vg_name_space) indpag
                
               ,cast(to_timestamp_tz(extractvalue(value(infnfe),
                                                  '//ide/dhEmi',
                                                  vg_name_space),
                                     vg_masc_time_zone) as date) emissao_nf
                
               ,cast(to_timestamp_tz(extractvalue(value(infnfe),
                                                  '//ide/dhSaiEnt',
                                                  vg_name_space),
                                     vg_masc_time_zone) as date) saient_nf
                /*
                ,cast(to_timestamp_tz(extractvalue(a.xml_arq,
                               '/nfeProc/protNFe/infProt/dhRecbto',
                                vg_name_space),'YYYY-MM-DD"T"HH24:MI:SS TZH:TZM') as date) dt_recbto_xml_cefaz
                */
               ,extractvalue(value(infnfe),
                             '//ide/tpNF',
                             vg_name_space) tipo_operacao
                
               ,extractvalue(value(infnfe),
                             '//ide/cMunFG',
                             vg_name_space) cmunfg
                
               ,extractvalue(value(infnfe),
                             '//ide/tpImp',
                             vg_name_space) tpimp
                
               ,extractvalue(value(infnfe),
                             '//ide/tpEmis',
                             vg_name_space) tpemis
                
               ,extractvalue(value(infnfe),
                             '//ide/idDest',
                             vg_name_space) ident_destino
               ,extractvalue(value(infnfe),
                             '//ide/finNFe',
                             vg_name_space) finnfe
               ,extractvalue(value(infnfe),
                             '//ide/procEmi',
                             vg_name_space) proc_emiss
               ,extractvalue(value(infnfe),
                             '//ide/verProc',
                             vg_name_space) verproc
               ,extractvalue(value(infnfe),
                             '//ide/tpAmb',
                             vg_name_space) tpamb
                
               ,extractvalue(value(infnfe),
                             '//emit/CNPJ',
                             vg_name_space) cnpj_emit
               ,extractvalue(value(infnfe),
                             '//emit/enderEmit/UF',
                             vg_name_space) uf_emit
               ,extractvalue(value(infnfe),
                             '//infAdic/infAdFisco',
                             vg_name_space) infadfisco
               ,extractvalue(value(infnfe),
                             '//infAdic/infCpl',
                             vg_name_space) infcpl
               ,extractvalue(value(infnfe),
                             '//infAdic/infSuplem',
                             vg_name_space) infsuplem
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vFrete',
                                               vg_name_space),
                                  '.',
                                  ',')) vl_frete_total
                
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vBC',
                                               vg_name_space),
                                  '.',
                                  ',')) vl_bicms_total
                
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vICMS',
                                               vg_name_space),
                                  '.',
                                  ',')) vl_icm_total
                
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vIPI',
                                               vg_name_space),
                                  '.',
                                  ',')) vl_ipi_total
                
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vPIS',
                                               vg_name_space),
                                  '.',
                                  ',')) vl_pis_total
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vCOFINS',
                                               vg_name_space),
                                  '.',
                                  ',')) vl_cofins_total
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vII',
                                               vg_name_space),
                                  '.',
                                  ',')) vii
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vST',
                                               vg_name_space),
                                  '.',
                                  ',')) vst
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vBCST',
                                               vg_name_space),
                                  '.',
                                  ',')) vbcst
                
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vSeg',
                                               vg_name_space),
                                  '.',
                                  ',')) vl_seguro_total
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vDesc',
                                               vg_name_space),
                                  '.',
                                  ',')) vl_desconto_total
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vOutro',
                                               vg_name_space),
                                  '.',
                                  ',')) vl_outro_total
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vIRRF',
                                               vg_name_space),
                                  '.',
                                  ',')) virrf
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vRetPis',
                                               vg_name_space),
                                  '.',
                                  ',')) vretpis
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vRetCofins',
                                               vg_name_space),
                                  '.',
                                  ',')) vretcofins
                
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vRetCSLL',
                                               vg_name_space),
                                  '.',
                                  ',')) vretcsll
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vBCIRRF',
                                               vg_name_space),
                                  '.',
                                  ',')) vbcirrf
                
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vProd',
                                               vg_name_space),
                                  '.',
                                  ',')) vl_prod_total
                
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vServ',
                                               vg_name_space),
                                  '.',
                                  ',')) vserv
                
               ,to_number(replace(extractvalue(value(infnfe),
                                               '//total/ICMSTot/vNF',
                                               vg_name_space),
                                  '.',
                                  ',')) vl_nota_total
               ,extractvalue(value(infnfe),
                             '//total/ICMSTot/indISSRet',
                             vg_name_space) indissret
         
           from xml_nfe a
               ,table(xmlsequence(extract(a.xml_arq,
                                          '/nfeProc/NFe/infNFe',
                                          vg_name_space))) infnfe
               , cd_firmas f
          where a.status = 'N'
            and a.id = p_id
            and f.empresa = p_emp
            and f.filial  = p_fil
            and replace(replace(replace(f.cgc_cpf ,'-',''),'/',''),'.','') = extractvalue(value(infnfe),
                             '//dest/CNPJ',
                             'xmlns="http://www.portalfiscal.inf.br/nfe')
             ;
      --|------------------------------------------------------------------
      -- cursor de detalhes da nota (produto)
      --|------------------------------------------------------------------
      cursor cr_det(p_id xml_nfe.id%type) is
         select a.id id_xml
               ,extractvalue(value(cprod),
                             'det/@nItem',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') item
               ,extractvalue(value(cprod),
                             'det/prod/cProd',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') cd_item
               ,extractvalue(value(cprod),
                             'det/prod/cEAN',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') gtin_ean
               ,extractvalue(value(cprod),
                             'det/prod/xProd',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') ds_item
                --ncm
               ,extractvalue(value(cprod),
                             'det/prod/NCM',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') ncm
                --cfop             
               ,extractvalue(value(cprod),
                             'det/prod/CFOP',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') cfop
                
                --uCom                                                                        
               ,extractvalue(value(cprod),
                             'det/prod/uCom',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') unid_com
                --qCom
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/prod/qCom',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) qtd_com
                --vUnCom valor unitario
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/prod/vUnCom',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) vl_unit_com
                
                --vProd valor produto bruto
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/prod/vProd',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) vl_prod_brt
                
                --vEANTrib = gtin codigo de barra
               ,extractvalue(value(cprod),
                             'det/prod/cEANTrib',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') c_ean_trib
                --uTrib unidade de tributacao
               ,extractvalue(value(cprod),
                             'det/prod/uTrib',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') unid_trib
                --qTrib  qtde tributada
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/prod/qTrib',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) qtd_trib
                
                --vUnTrib  valor unitario tributado
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/prod/vUnTrib',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) vl_unit_trib
                
                --indTot (0 -nao |1- sim) se valor entra no valor total da nota                                          
               ,extractvalue(value(cprod),
                             'det/prod/indTot',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') ind_tot
                
                --infADProd  informacoes adicionais do produto
               ,extractvalue(value(cprod),
                             'det/infADProd',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') ind_ad_prod
                
                --icms 
                --orig origem do produto 
               ,extractvalue(value(cprod),
                             'det/imposto/ICMS/*/orig',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') origem
                
                --cst icms                                          
               ,extractvalue(value(cprod),
                             'det/imposto/ICMS/*/CST',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') cst
                --modBC modalidade da base de calculo
               ,extractvalue(value(cprod),
                             'det/imposto/ICMS/*/modBC',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') mod_bc
                --pRedBC percentual de reducao da base de calculo
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/imposto/ICMS/*/pRedBC',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) perc_red_bc
                --vBC valor base de calculo icms
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/imposto/ICMS/*/vBC',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) vl_base_icms
                --pICMS percentual de icms
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/imposto/ICMS/*/pICMS',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) perc_icms
                --vICMS valor de icms
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/imposto/ICMS/*/vICMS',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) vl_icms
                --ipi              
                --cEnq enquadramento de ipi
               ,extractvalue(value(cprod),
                             'det/imposto/IPI/*/cEnq',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') enquadr_ipi
                
                --CST de ipi
               ,extractvalue(value(cprod),
                             'det/imposto/IPI/*/CST',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') cst_ipi
                
                --pIPI percentual de IPI
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/imposto/IPI/*/pIPI',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) perc_ipi
                --vIPI valor de IPI
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/imposto/IPI/*/vIPI',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) vl_ipi
                --PIS
                --CST pis
               ,extractvalue(value(cprod),
                             'det/imposto/PIS/*/CST',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') cst_pis
                --vBC  valor base de pis
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/imposto/PIS/*/vBC',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) vl_bc_pis
                --pPIS  percentual de pis
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/imposto/PIS/*/pPIS',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) perc_pis
                --vPIS  valor de pis
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/imposto/PIS/*/vPIS',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) vl_pis
                
                --COFINS
                --CST COFINS
               ,extractvalue(value(cprod),
                             'det/imposto/COFINS/*/CST',
                             'xmlns="http://www.portalfiscal.inf.br/nfe') cst_cofins
                --vBC  valor base de COFINS
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/imposto/COFINS/*/vBC',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) vl_bc_cofins
                --pCOFINS  percentual de COFINS
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/imposto/COFINS/*/pCOFINS',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) perc_cofins
                --vCOFINS valor de COFINS
               ,to_number(replace(extractvalue(value(cprod),
                                               'det/imposto/COFINS/*/vCOFINS',
                                               'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                  '.',
                                  ',')) vl_cofins
         
           from xml_nfe a
               ,table(xmlsequence(extract(a.xml_arq,
                                          '/nfeProc/NFe/infNFe/det',
                                          'xmlns="http://www.portalfiscal.inf.br/nfe"'))) cprod
          where extractvalue(value(cprod),
                             'det/prod/cProd',
                             'xmlns="http://www.portalfiscal.inf.br/nfe"') is not null
            and a.id = p_id;
      --|------------------------------------------------------------------
      --| cursor de Fatura e Duplicatas da nota
      --|------------------------------------------------------------------
      cursor cr_fat(p_id xml_nfe.id%type) is
         select det.*
               ,sum(det.valor) over() valor_total
           from (select a.id id_xml
                       ,extractvalue(value(cdup),
                                     'dup/nDup',
                                     'xmlns="http://www.portalfiscal.inf.br/nfe') item
                       ,cast(to_timestamp_tz(extractvalue(value(cdup),
                                                          'dup/dVenc',
                                                          'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                             'yyyy-mm-dd hh24:mi:ss tzh:tzm') as date) dt_vencto
                        
                       ,to_number(replace(extractvalue(value(cdup),
                                                       'dup/vDup',
                                                       'xmlns="http://www.portalfiscal.inf.br/nfe'),
                                          '.',
                                          ',')) valor
                   from xml_nfe a
                       ,table(xmlsequence(extract(a.xml_arq,
                                                  '/nfeProc/NFe/infNFe/cobr/dup',
                                                  'xmlns="http://www.portalfiscal.inf.br/nfe"'))) cdup
                  where a.id = p_id
                    and extractvalue(value(cdup),
                                     'dup/nDup',
                                     'xmlns="http://www.portalfiscal.inf.br/nfe"') is not null) det
          order by dt_vencto;
      --|------------------------------------------------------------------       
      --Cursor da operacao
      --|------------------------------------------------------------------   
      cursor croper is
         select *
           from ft_oper o
          where o.empresa = p_emp
            and o.cod_oper = 888;
      --|------------------------------------------------------------------
      cursor cr_nf(p_nf    ce_notas.num_nota%type
                  ,p_forn  ce_notas.cod_fornec%type
                  ,p_sr    ce_notas.sr_nota%type
                  ,p_chave ce_notas.chave_nfe%type) is
         select n.id
           from ce_notas n
          where n.chave_nfe = p_chave
             or (n.empresa = p_emp and n.filial = p_fil and
                n.cod_fornec = p_forn and n.num_nota = p_nf and
                n.sr_nota = p_nf and n.parte = 0);
   
      --|-------------------------------------------------------------------
      --| variaveis
      v_id         number(9);
      v_cod_fornec number(9);
      reg_oper     ft_oper%rowtype;
      v_cfo        ft_cfo.cod_cfo%type;
      v_uf_empresa cd_firmas.uf%type;
      v_obs        varchar2(32000); --ce_notas.observacao%type;
      v_prod       ce_produtos.produto%type;
      v_id_det     number(9);
      v_erro       varchar2(4000);
   
      v_id_fat     number(9);
      v_numero_dup number(4);
      v_dt_saida   date;
   begin
      open croper;
      fetch croper
         into reg_oper;
      close croper;
   
      v_uf_empresa := cd_firmas_utl.uf(cd_firmas_utl.firma_filial(p_emp,
                                                                  p_fil));
   
      for reg in crcab loop
         v_cod_fornec := cd_firmas_utl.codigo_por_cnpjcpf(reg.cnpj_emit);
      
         if trim(reg.uf_emit) != v_uf_empresa then
            v_cfo := reg_oper.cfo_fe;
         else
            v_cfo := reg_oper.cfo_de;
         end if;
         if trim(reg.infcpl) is not null then
            v_obs := 'Complem.: ' || trim(reg.infcpl);
         end if;
      
         if v_obs is not null and
            trim(reg.infadfisco) is not null then
            v_obs := v_obs || chr(10) || 'Fisco.: ' || reg.infadfisco;
         elsif trim(reg.infadfisco) is not null then
            v_obs := 'Fisco.: ' || reg.infadfisco;
         end if;
      
         if v_obs is not null and
            trim(reg.infsuplem) is not null then
            v_obs := v_obs || chr(10) || 'Suplem.: ' || reg.infsuplem;
         elsif trim(reg.infsuplem) is not null then
            v_obs := 'Suplem.: ' || reg.infsuplem;
         end if;
      
         v_dt_saida := reg.saient_nf;
      
         if v_dt_saida is null then
            v_dt_saida := reg.emissao_nf;
         end if;
      
         v_obs := substr(v_obs,
                         2000);
      
         v_id := null;
      
         open cr_nf(reg.numero_nf,
                    v_cod_fornec,
                    upper(trim(reg.serie_nf)),
                    reg.chave_nfe);
         fetch cr_nf
            into v_id;
         close cr_nf;
      
         if nvl(v_id,
                0) = 0 then
            --| gera cabecalho
            select nfe_cabecalho_seq.nextval into v_id from dual;
         
            v_erro := 'id_xml:' || reg.id_xml;
         
            -- v_dt_emiss := 
            --v_dt_entsai := 
            insert into nfe_cabecalho
               (id
               ,empresa
               ,filial
               ,firma
               ,codigo_numerico
               ,natureza_operacao
               ,indicador_forma_pagamento
               ,codigo_modelo
               ,serie
               ,numero
               ,data_emissao
               ,data_entrada_saida
               ,tipo_operacao
               ,codigo_municipio
               ,formato_impressao_danfe
               ,tipo_emissao
               ,chave_acesso
               ,digito_chave_acesso
               ,ambiente
               ,finalidade_emissao
               ,processo_emissao
               ,versao_processo_emissao
               ,base_calculo_icms
               ,valor_icms
               ,base_calculo_icms_st
               ,valor_icms_st
               ,valor_total_produtos
               ,valor_frete
               ,valor_seguro
               ,valor_desconto
               ,valor_imposto_importacao
               ,valor_ipi
               ,valor_pis
               ,valor_cofins
               ,valor_despesas_acessorias
               ,valor_total
               ,valor_servicos
               ,base_calculo_issqn
               ,valor_issqn
               ,valor_pis_issqn
               ,valor_cofins_issqn
               ,valor_retido_pis
               ,valor_retido_cofins
               ,valor_retido_csll
               ,base_calculo_irrf
               ,valor_retido_irrf
               ,base_calculo_previdencia
               ,valor_retido_previdencia
               ,uf_embarque
               ,local_embarque
               ,nota_empenho
               ,pedido
               ,iss_retido
               ,informacoes_add_fisco
               ,informacoes_compl_contr
               ,informacoes_suplementar
               ,status_nota
               ,usu_incl
               ,dt_incl
               ,usu_alt
               ,dt_alt
               ,num_pedido
               ,cod_oper
               ,base_calculo_ipi)
            values
               (v_id --ID                        NUMBER(9)      
               ,p_emp --empresa                                     EMPRESA                   NUMBER(9)      
               ,p_fil --filial                                      FILIAL                    NUMBER(9)      
               ,v_cod_fornec --firma                                FIRMA                     NUMBER(9)      
               ,reg.cd_numero --codigo_numerico                     CODIGO_NUMERICO           VARCHAR2(8)    
               ,reg.natop --natureza_operacao                       NATUREZA_OPERACAO         VARCHAR2(60)   
               ,reg.indpag --indicador_forma_pagamento              INDICADOR_FORMA_PAGAMENTO VARCHAR2(1)    
               ,reg.mod_nf --codigo_modelo                          CODIGO_MODELO             VARCHAR2(2)    
               ,reg.serie_nf --SERIE                     VARCHAR2(3)    
               ,reg.numero_nf --numero                              NUMERO                    VARCHAR2(9)    
               ,reg.emissao_nf --data_emissao                       DATA_EMISSAO              DATE           
               ,v_dt_saida --data_entrada_saida                DATA_ENTRADA_SAIDA        DATE           
               ,reg.tipo_operacao --                                   TIPO_OPERACAO             VARCHAR2(1)    
               ,reg.cmunfg --codigo_municipio                       CODIGO_MUNICIPIO          NUMBER(9)      
               ,reg.tpimp --formato_impressao_danfe                 FORMATO_IMPRESSAO_DANFE   VARCHAR2(1)    
               ,reg.tpemis --tipo_emissao                           TIPO_EMISSAO              VARCHAR2(1)    
               ,reg.chave_nfe --chave_acesso                        CHAVE_ACESSO              VARCHAR2(44)   
               ,reg.digito_ver --digito_chave_acesso                DIGITO_CHAVE_ACESSO       VARCHAR2(1)    
               ,reg.tpamb --ambiente                                AMBIENTE                  VARCHAR2(1)    
               ,reg.finnfe --finalidade_emissao                     FINALIDADE_EMISSAO        VARCHAR2(1)    
               ,reg.proc_emiss --processo_emissao                   PROCESSO_EMISSAO          VARCHAR2(1)    
               ,reg.verproc --versao_processo_emissao               VERSAO_PROCESSO_EMISSAO   VARCHAR2(10)      
               ,reg.vl_bicms_total --base_calculo_icms              BASE_CALCULO_ICMS         NUMBER(18,6)   
               ,reg.vl_icm_total --valor_icms                       VALOR_ICMS                NUMBER(18,6)   
               ,reg.vbcst --base_calculo_icms_st                    BASE_CALCULO_ICMS_ST      NUMBER(18,6)   
               ,reg.vst --valor_icms_st                             VALOR_ICMS_ST             NUMBER(18,6)   
               ,reg.vl_prod_total --valor_total_produtos            VALOR_TOTAL_PRODUTOS      NUMBER(18,6)   
               ,reg.vl_frete_total --valor_frete                    VALOR_FRETE               NUMBER(18,6)   
               ,reg.vl_seguro_total -- valor_seguro                 VALOR_SEGURO              NUMBER(18,6)   
               ,reg.vl_desconto_total --valor_desconto              VALOR_DESCONTO            NUMBER(18,6)   
               ,reg.vii --valor_imposto_importacao                  VALOR_IMPOSTO_IMPORTACAO  NUMBER(18,6)   
               ,reg.vl_ipi_total --valor_ipi                        VALOR_IPI                 NUMBER(18,6)   
               ,reg.vl_pis_total --valor_pis                        VALOR_PIS                 NUMBER(18,6)   
               ,reg.vl_cofins_total --valor_cofins                  VALOR_COFINS              NUMBER(18,6)   
               ,reg.vl_outro_total --valor_despesas_acessorias      VALOR_DESPESAS_ACESSORIAS NUMBER(18,6)   
               ,reg.vl_nota_total --valor_total                     VALOR_TOTAL               NUMBER(18,6)   
               ,reg.vserv --(vServ) valor_servicos                  VALOR_SERVICOS            NUMBER(18,6)   
               ,null --base_calculo_issqn                           BASE_CALCULO_ISSQN        NUMBER(18,6)   
               ,null --valor_issqn                                  VALOR_ISSQN               NUMBER(18,6)   
               ,null --valor_pis_issqn                              VALOR_PIS_ISSQN           NUMBER(18,6)   
               ,null --valor_cofins_issqn                           VALOR_COFINS_ISSQN        NUMBER(18,6)   
               ,reg.vretpis --valor_retido_pis                      VALOR_RETIDO_PIS          NUMBER(18,6)   
               ,reg.vretcofins --valor_retido_cofins                VALOR_RETIDO_COFINS       NUMBER(18,6)   
               ,reg.vretcsll --valor_retido_csll                    VALOR_RETIDO_CSLL         NUMBER(18,6)   
               ,reg.vbcirrf --base_calculo_irrf                     BASE_CALCULO_IRRF         NUMBER(18,6)   
               ,reg.virrf --valor_retido_irrf                       VALOR_RETIDO_IRRF         NUMBER(18,6)   
               ,null --vBCRetPrev - base_calculo_previdencia        BASE_CALCULO_PREVIDENCIA  NUMBER(18,6)   
               ,null --vRetPrev - valor_retido_previdencia          VALOR_RETIDO_PREVIDENCIA  NUMBER(18,6)   
               ,null --uf_embarque                                  UF_EMBARQUE               VARCHAR2(2)    
               ,null --local_embarque                               LOCAL_EMBARQUE            VARCHAR2(60)   
               ,null --nota_empenho                                 NOTA_EMPENHO              VARCHAR2(17)   
               ,null --reg.xPed --pedido                            PEDIDO                    VARCHAR2(60)   
               ,reg.indissret --iss_retido                          ISS_RETIDO                VARCHAR2(1)    
               ,reg.infadfisco --informacoes_add_fisco              INFORMACOES_ADD_FISCO     VARCHAR2(4000) 
               ,reg.infcpl --informacoes_add_contribuinte           INFORMACOES_COMPL_CONTR   VARCHAR2(4000) 
               ,reg.infsuplem --informacoes_complementares          INFORMACOES_SUPLEMENTAR   VARCHAR2(4000) 
               ,reg.status --status_nota                            STATUS_NOTA               VARCHAR2(10)    
               ,user --usu_incl                                     USU_INCL                  VARCHAR2(30)   
               ,sysdate --dt_incl                                   DT_INCL                   DATE           
               ,null --usu_alt                                      USU_ALT                   VARCHAR2(30)   
               ,null --dt_alt                                       DT_ALT                    DATE           
               ,null --num_pedido                                   NUM_PEDIDO                NUMBER(9)      
               ,null --cod_oper                                     COD_OPER                  NUMBER(9)      
               ,null --base_calculo_ipi                             BASE_CALCULO_IPI          NUMBER(18,6)   
                );
         
            --|------------------------------------
            --| gerar detalhes da nota (produtos)
            --|------------------------------------        
            for reg_det in cr_det(reg.id_xml) loop
               v_prod := null;
               --| Busca RELACAO COM CODIGO SISTEMA
               v_prod := fl_relacao_produto_fornec(v_cod_fornec,
                                                   reg_det.cd_item);
            
               select nfe_detalhe_seq.nextval into v_id_det from dual;
            
               insert into nfe_detalhe
                  (id
                  ,id_lote_produto
                  ,id_nfe_cabecalho
                  ,empresa
                  ,produto
                  ,numero_item
                  ,codigo_produto
                  ,gtin
                  ,nome_produto
                  ,ncm
                  ,ex_tipi
                  ,cfop
                  ,unidade_comercial
                  ,quantidade_comercial
                  ,valor_unitario_comercial
                  ,valor_bruto_produtos
                  ,gtin_unidade_tributavel
                  ,unidade_tributavel
                  ,quantidade_tributavel
                  ,valor_unitario_tributacao
                  ,valor_frete
                  ,valor_seguro
                  ,valor_desconto
                  ,valor_outras_despesas
                  ,entra_total
                  ,origem_mercadoria
                  ,cst_icms
                  ,csosn
                  ,modalidade_bc_icms
                  ,taxa_reducao_bc_icms
                  ,base_calculo_icms
                  ,aliquota_icms
                  ,valor_icms
                  ,motivo_desoneracao_icms
                  ,modalidade_bc_icms_st
                  ,percentual_mva_icms_st
                  ,reducao_bc_icms_st
                  ,base_calculo_icms_st
                  ,aliquota_icms_st
                  ,valor_icms_st
                  ,valor_bc_icms_st_retido
                  ,valor_icms_st_retido
                  ,aliquota_credito_icms_sn
                  ,valor_credito_icms_sn
                  ,enquadramento_ipi
                  ,cnpj_produtor
                  ,codigo_selo_ipi
                  ,quantidade_selo_ipi
                  ,enquadramento_legal_ipi
                  ,cst_ipi
                  ,base_calculo_ipi
                  ,aliquota_ipi
                  ,valor_ipi
                  ,valor_bc_ii
                  ,valor_despesas_aduaneiras
                  ,valor_imposto_importacao
                  ,valor_iof
                  ,cst_pis
                  ,base_calculo_pis
                  ,aliquota_pis
                  ,valor_pis
                  ,cst_cofins
                  ,base_calculo_cofins
                  ,aliquota_cofins
                  ,valor_cofins
                  ,base_calculo_issqn
                  ,aliquota_issqn
                  ,valor_issqn
                  ,municipio_issqn
                  ,item_lista_servicos
                  ,tributacao_issqn
                  ,valor_subtotal
                  ,valor_total
                  ,informacoes_adicionais)
               values
                  (v_id_det
                  ,null
                  , --id_lote_produto,
                   v_id
                  , --id_nfe_cabecalho,
                   p_emp
                  , --empresa,
                   v_prod
                  , --produto,
                   reg_det.item
                  , --numero_item,
                   reg_det.cd_item
                  , --codigo_produto do fornecedor,
                   reg_det.gtin_ean
                  , --gtin,
                   reg_det.ds_item
                  , --nome_produto,
                   reg_det.ncm
                  , --ncm
                   null
                  , --ex_tipi,
                   reg_det.cfop
                  , --cfop,
                   reg_det.unid_com
                  , --unidade_comercial,
                   reg_det.qtd_com
                  , --quantidade_comercial,
                   reg_det.vl_unit_com
                  , --valor_unitario_comercial,
                   reg_det.vl_prod_brt
                  , --valor_bruto_produtos,
                   reg_det.c_ean_trib
                  , --gtin_unidade_tributavel,
                   reg_det.unid_trib
                  , --unidade_tributavel,
                   reg_det.qtd_trib
                  , --quantidade_tributavel,
                   reg_det.vl_unit_trib
                  , --valor_unitario_tributacao,
                   null
                  , --valor_frete,
                   null
                  , --valor_seguro,
                   null
                  , --valor_desconto,
                   null
                  , --valor_outras_despesas,
                   reg_det.ind_tot
                  , --entra_total,
                   reg_det.origem
                  , --origem_mercadoria,
                   reg_det.cst
                  , --cst_icms,
                   null
                  , --csosn,
                   reg_det.mod_bc
                  , --modalidade_bc_icms,
                   reg_det.perc_red_bc
                  , --taxa_reducao_bc_icms,
                   reg_det.vl_base_icms
                  , --base_calculo_icms,
                   reg_det.perc_icms
                  , --aliquota_icms,
                   reg_det.vl_icms
                  , --valor_icms,
                   null
                  , --motivo_desoneracao_icms,
                   null
                  , --modalidade_bc_icms_st,
                   null
                  , --percentual_mva_icms_st,
                   null
                  , --reducao_bc_icms_st,
                   null
                  , --base_calculo_icms_st,
                   null
                  , --aliquota_icms_st,
                   null
                  , --valor_icms_st,
                   null
                  , --valor_bc_icms_st_retido,
                   null
                  , --valor_icms_st_retido,
                   null
                  , --aliquota_credito_icms_sn,
                   null
                  , --valor_credito_icms_sn,
                   
                   reg_det.enquadr_ipi
                  , --enquadramento_ipi,
                   null
                  , --cnpj_produtor,
                   null
                  , --codigo_selo_ipi,
                   null
                  , --quantidade_selo_ipi,
                   null
                  , --enquadramento_legal_ipi,
                   reg_det.cst_ipi
                  , --cst_ipi,
                   reg_det.vl_bc_pis
                  , --base_calculo_ipi,
                   reg_det.perc_ipi
                  , --aliquota_ipi,
                   reg_det.vl_ipi
                  , --valor_ipi,
                   null
                  , --valor_bc_ii,
                   null
                  , --valor_despesas_aduaneiras,
                   null
                  , --valor_imposto_importacao,
                   null
                  , --valor_iof,
                   reg_det.cst_pis
                  , --cst_pis,
                   reg_det.vl_bc_pis
                  , --valor_base_calculo_pis,
                   reg_det.perc_pis
                  , --aliquota_pis,
                   reg_det.vl_pis
                  , --valor_pis,
                   reg_det.cst_cofins
                  , --cst_cofins,
                   reg_det.vl_bc_cofins
                  , --base_calculo_cofins,
                   reg_det.perc_cofins
                  , --aliquota_cofins,
                   reg_det.vl_cofins
                  , --valor_cofins,
                   null
                  , --base_calculo_issqn,
                   null
                  , --aliquota_issqn,
                   null
                  , --valor_issqn,
                   null
                  , --municipio_issqn,
                   null
                  , --item_lista_servicos,
                   null
                  , --tributacao_issqn,
                   null
                  , --valor_subtotal,
                   null
                  , --valor_total,
                   reg_det.ind_ad_prod --informacoes_adicionais
                   );
               --| VeRIFICA SE CODIGO DO PRODUTO DO FORNECEDOR
               --| POSSUI RELACAO COM CODIGO SISTEMA
               if not fl_tem_produto_fornec(v_cod_fornec,
                                            reg_det.cd_item) then
                  insert into ce_prod_fornec
                     (id
                     ,cod_fornec
                     ,empresa
                     ,produto
                     ,prod_fornec
                     ,usu_incl
                     ,dt_incl
                     ,usu_alt
                     ,dt_alt)
                  values
                     (ce_prod_fornec_seq.nextval
                     ,v_cod_fornec
                     ,null
                     ,null
                     ,reg_det.cd_item
                     ,user
                     ,sysdate
                     ,null
                     ,null);
               end if;
            end loop;
            --|------------------------------------
            --| gerar Fatura e Duplicatas
            --|------------------------------------  
            v_id_fat     := null;
            v_numero_dup := 0;
         
            for reg_fat in cr_fat(reg.id_xml) loop
               if v_id_fat is null then
                  select nfe_fatura_seq.nextval into v_id_fat from dual;
               
                  insert into nfe_fatura
                     (id
                     ,id_nfe_cabecalho
                     ,numero
                     ,valor_original
                     ,valor_desconto
                     ,valor_liquido)
                  values
                     (v_id_fat
                     ,v_id
                     ,reg.numero_nf
                     ,reg_fat.valor_total
                     ,0
                     ,reg_fat.valor_total);
               end if;
               v_numero_dup := v_numero_dup + 1;
            
               insert into nfe_duplicata
                  (id
                  ,id_nfe_fatura
                  ,numero
                  ,data_vencimento
                  ,valor)
               values
                  (nfe_duplicata_seq.nextval
                  ,v_id_fat
                  ,v_numero_dup
                  ,trunc(reg_fat.dt_vencto)
                  ,reg_fat.valor);
            
            end loop;
         
            --|fim 
            --commit;
            exporta_nfe_cenota(p_emp,
                               p_fil,
                               p_id,
                               v_id);
         end if; --/ fim v_id > 0       
      end loop;
      commit;
   /*
   exception
      when others then
        if sqlcode <> -20001 then
           gv_msg_erro := fg_get_line_error (ev_local   => gv_objeto 
                                              ,ev_msg_usu => 'sincroniza_xml_nf:' || v_erro 
                                              ,ev_msg_ora => sqlerrm); 
             raise_application_error (-20001,gv_msg_erro);
        end if;
        raise;      
*/
   end;
   --|--------------------------------------------------------
   --| exporta nfe para ce_notas
   --|--------------------------------------------------------
   procedure exporta_nfe_cenota(p_emp    number
                               ,p_fil    number
                               ,p_id  xml_nfe.id%type
                               ,p_id_nfe number) is
      --|Cabecalho da NFe
      cursor cr is
         select * from nfe_cabecalho c where c.id = p_id_nfe;

      --|Emitente : obs - nao está sendo gerado neste momento
      cursor crE is
         select e.razao_social || ' - '|| e.cpf_cnpj 
           from nfe_emitente e
          where e.id_nfe_cabecalho = p_id_nfe;
         
      --|Itens da NFe
      cursor crit is
         select *
           from nfe_detalhe c
          where c.id_nfe_cabecalho = p_id_nfe
          order by c.numero_item;
      --|parcelas nfe
      cursor crparc is
         select d.*
           from nfe_duplicata d
               ,nfe_fatura    f
          where d.id_nfe_fatura = f.id
            and f.id_nfe_cabecalho = p_id_nfe;
   
      --|------------------------------------------------------------------       
      --Cursor da operacao
      --|------------------------------------------------------------------   
      cursor croper is
         select *
           from ft_oper o
          where o.empresa = p_emp
            and o.cod_oper = 888;
   
      v_id     ce_notas.id%type;
      v_emite  varchar2(500);
      v_msg    varchar2(1000);
      
      reg      nfe_cabecalho%rowtype;
      reg_oper ft_oper%rowtype;
   
      v_obs        varchar2(32000);
      v_cfo        ft_cfo.cod_cfo%type;
      v_uf_empresa cd_firmas.uf%type;
      v_uf         cd_firmas.uf%type;
      v_tipo_tit   ce_notas.tipo_tit%type;
      v_tipo_cob   ce_notas.tipo_cob%type;
      --|
      v_prod_ofc   ce_produtos.produto%type;
      v_id_itm     ce_itens_nf.id%type;
      v_local      ce_itens_nf.local%type;
      v_unid       ce_unid.unidade%type;
      v_cod_clafis ft_clafis.cod_clafis%type;
      --|
      v_id_parc ce_parc_nf.id%type;
      v_erro    varchar2(1000);
   
   begin
      v_tipo_tit := 10;
      v_tipo_cob := 8;
   
      open croper;
      fetch croper
         into reg_oper;
      close croper;
   
      open cr;
      fetch cr
         into reg;
      close cr;
   
      v_uf := cd_firmas_utl.uf(reg.firma);
   
      if trim(v_uf) != v_uf_empresa then
         v_cfo := reg_oper.cfo_fe;
      else
         v_cfo := reg_oper.cfo_de;
      end if;
   
      if trim(reg.informacoes_compl_contr) is not null then
         v_obs := 'Compl.: ' || trim(reg.informacoes_compl_contr);
      end if;
   
      if v_obs is not null and
         reg.informacoes_add_fisco is not null then
         v_obs := v_obs || chr(10) || 'Fisco: ' || reg.informacoes_add_fisco;
      elsif reg.informacoes_add_fisco is not null then
         v_obs := 'Fisco: ' || reg.informacoes_add_fisco;
      end if;
   
      if v_obs is not null and
         reg.informacoes_suplementar is not null then
         v_obs := v_obs || chr(10) || 'Contrib: ' ||
                  reg.informacoes_suplementar;
      elsif reg.informacoes_suplementar is not null then
         v_obs := 'Suplem.: ' || reg.informacoes_suplementar;
      end if;
   
      v_obs := substr(v_obs,
                      2000);
   
      if reg.id is not null then
         if reg.firma is null then
           v_emite := null;
           v_emite :=  Emitente_xml_nfe(p_id) ||' - '|| Cnpj_Emitente_xml_nfe(p_id);
           

           /*
            open crE;
            fetch crE into v_emite;
            close crE;
            */
            v_msg := ' Fornecedor não cadastrado==>'||v_emite;
            raise_application_error(-20001,v_msg);
          end if;
          
         select ce_notas_seq.nextval into v_id from dual;
         insert into ce_notas
            (empresa
            ,filial
            ,num_nota
            ,sr_nota
            ,cod_fornec
            ,parte
            ,uf_nota
            ,dt_emissao
            ,dt_saida
            ,dt_entrada
            ,tipo_doc
            ,cod_oper
            ,cod_cfo
            ,cod_condpag
            ,vlr_iss
            ,vlr_ipi
            ,vlr_bipi
            ,vlr_icms
            ,vlr_bicms
            ,vlr_nota
            ,vlr_servico
            ,vlr_adiantamento
            ,vlr_ct_rateado
            ,vlr_despesa
            ,producao
            ,periodo
            ,observacao
            ,historico_serv
            ,dt_digitacao
            ,digitador
            ,situacao_frete
            ,situacao_nf
            ,rotina_origem
            ,vlr_ir
            ,ipi_bsicms
            ,sest
            ,inss
            ,imp_retido
            ,ratear
            ,tipo_tit
            ,moeda
            ,tipo_cob
            ,vl_pis
            ,vl_cofins
            ,vlr_csll_ret
            ,vlr_cofins_ret
            ,vlr_pis_ret
            ,chave_nfe
            ,vlr_desconto
            ,valor_st
            ,vl_frete
            ,vlr_seguro
            ,id
            ,id_nfe_cabecalho)
         values
            (p_emp
            ,p_fil
            ,reg.numero
            ,reg.serie --sr_nota
            ,reg.firma --v_cod_fornec --cod_fornec
            ,0 --parte
            ,v_uf --uf_nota
            ,reg.data_emissao --dt_emissao
            ,reg.data_entrada_saida --dt_saida
            ,trunc(sysdate) --dt_entrada
            ,55 --tipo_doc
            ,reg_oper.cod_oper --cod_oper
            ,v_cfo --cod_cfo
            ,2 --cod_condpag -- 2=informado
            ,null --vlr_iss
            ,reg.valor_ipi --vlr_ipi
            ,null --vlr_bipi
            ,reg.valor_icms --vlr_icms
            ,reg.base_calculo_icms --vlr_bicms
            ,reg.valor_total --vlr_nota
            ,reg.valor_servicos --vlr_servico
            ,null --vlr_adiantamento
            ,null --vlr_ct_rateado
            ,reg.valor_despesas_acessorias --vlr_despesa
            ,to_char(sysdate,
                     'rrrr') --producao
            ,'A' --periodo
            ,v_obs --observacao
            ,null --historico_serv
            ,sysdate --dt_digitacao
            ,user --digitador
            ,'N' --situacao_frete
            ,4 --situacao_nf em recebimento
            ,204 --rotina_origem (recepcao de mercadoria)
            ,reg.valor_retido_irrf --vlr_ir
            ,'N' --ipi_bsicms
            ,null --sest
            ,null --inss
            ,null --imp_retido
            ,'N' --ratear
            ,v_tipo_tit --10 tipo_tit (boleto bancario)
            ,null --moeda
            ,v_tipo_cob -- 8 tipo_cob (Bancaria)
            ,reg.valor_pis --vl_pis
            ,reg.valor_cofins --vl_cofins
            ,reg.valor_retido_csll --vlr_csll_ret
            ,reg.valor_retido_cofins --vlr_cofins_ret
            ,reg.valor_retido_pis --vlr_pis_ret
            ,reg.chave_acesso --chave_nfe
            ,reg.valor_desconto --vlr_desconto
            ,reg.valor_icms_st --valor_st
            ,reg.valor_frete --vl_frete
            ,reg.valor_seguro --vlr_seguro
            ,v_id
            ,p_id_nfe);
         --|----------------
         --| Itens da nota
         --|----------------
         for regit in crit loop
            v_prod_ofc   := 31765; ---| produto oficial temporário
            v_local      := ce_produtos_utl.local_padrao(p_emp,
                                                         p_fil,
                                                         v_prod_ofc);
            v_unid       := upper(regit.unidade_comercial);
            v_cod_clafis := ce_produtos_utl.ncm_to_cod(regit.ncm);
            if v_cod_clafis is null then
               v_cod_clafis := ce_produtos_utl.cod_clafis(p_emp,
                                                          v_prod_ofc);
            end if;
         
            if not is_unid_oficial(v_unid) then
               v_unid := ce_produtos_utl.unidade(p_emp,
                                                 v_prod_ofc);
            end if;
         
            select ce_itens_nf_seq.nextval into v_id_itm from dual;
            v_erro := p_id_nfe || ' - Tribut-pis: ' || regit.cst_pis;
            insert into ce_itens_nf
               (empresa
               ,filial
               ,num_nota
               ,sr_nota
               ,cod_fornec
               ,parte
               ,id
               ,local
               ,produto
               ,uni_ven
               ,qtd
               ,valor_unit
               ,aliq_icms
               ,vl_bicms
               ,vl_icms
               ,aliq_ipi
               ,vl_ipi
               ,vl_desconto
               ,vl_acrescimo
               ,vl_frete
               ,vl_despesa
               ,cod_tribut
               ,seq_mov
               ,cod_cfo
               ,dif_aliq
               ,fil_ordem
               ,ordem
               ,item_req
               ,seq_mov2
               ,qtd_rm
               ,un_rm
               ,vl_dipi
               ,descricao
               ,descr_xml
               ,cod_tribut_ipi
               ,vl_bipi
               ,seq_ori
               ,qtd_pc
               ,largura
               ,comprimento
               ,recnoib
               ,rec_50
               ,nao_incluso
               ,vlr_ipi_50
               ,vl_ipi_50
               ,cod_tribut_pis
               ,cod_tribut_cof
               ,vl_bpis
               ,vl_pis
               ,aliq_pis
               ,vl_bcof
               ,vl_cof
               ,aliq_cof
               ,id_notas
               ,id_reqcpraitem
               ,tipo
               ,id_ce_nota
               ,cod_clafis
               ,id_nfe_detalhe)
            values
               (p_emp
               ,p_fil
               ,reg.numero
               ,reg.serie
               , --sr_nota
                reg.firma
               , --v_cod_fornec --cod_fornec
                0
               , --parte
                v_id_itm
               ,v_local
               ,v_prod_ofc
               ,v_unid
               , --uni_ven,
                regit.quantidade_comercial
               , --qtd,
                regit.valor_unitario_comercial
               , --valor_unit,
                regit.aliquota_icms
               , --aliq_icms,
                regit.base_calculo_icms
               , --vl_bicms,
                regit.valor_icms
               , --vl_icms,
                regit.aliquota_ipi
               , --aliq_ipi,
                regit.valor_ipi
               , --vl_ipi,
                regit.valor_desconto
               , --vl_desconto,
                null
               , --vl_acrescimo,
                regit.valor_frete
               , --vl_frete,
                regit.valor_outras_despesas
               , --vl_despesa,
                regit.cst_icms
               , --cod_tribut,
                null
               , --seq_mov,
                v_cfo
               , --cod_cfo,
                null
               , --dif_aliq,
                null
               , --fil_ordem,
                null
               , --ordem,
                null
               , --item_req,
                null
               , --seq_mov2,
                regit.quantidade_comercial
               , --qtd_rm,
                v_unid
               , --un_rm,
                null
               , --vl_dipi,
                regit.nome_produto
               , --descricao,
                regit.nome_produto
               , --descr_xml
                regit.cst_ipi
               , --cod_tribut_ipi,
                regit.base_calculo_ipi
               , --vl_bipi,
                null
               , --seq_ori,
                1
               , --qtd_pc,
                null
               , --largura,
                null
               , --comprimento,
                null
               , --recnoib,
                'N'
               , --rec_50,
                'N'
               , --nao_incluso,
                null
               , --vlr_ipi_50,
                null
               , --vl_ipi_50,
                regit.cst_pis
               , --cod_tribut_pis,
                regit.cst_cofins
               , --cod_tribut_cof,
                regit.base_calculo_pis
               , --vl_bpis,
                regit.valor_pis
               , --vl_pis,
                regit.aliquota_pis
               , --aliq_pis,
                regit.base_calculo_cofins
               , --vl_bcof,
                regit.valor_cofins
               , --vl_cof,
                regit.aliquota_cofins
               , --aliq_cof,
                null
               , --id_notas,
                null
               , --id_reqcpraitem,
                0
               , --tipo (0)finceiro/estoque (1)financeiro  (2)estoque
                v_id
               , --id_ce_nota,
                v_cod_clafis
               ,regit.id);
         end loop;
         --| Fatura:parcelas na nota
         for regpar in crparc loop
         
            select ce_parc_nf_seq.nextval into v_id_parc from dual;
         
            insert into ce_parc_nf
               (empresa
               ,filial
               ,num_nota
               ,sr_nota
               ,cod_fornec
               ,parte
               ,id
               ,parcela
               ,dt_vencto
               ,vlr_parcela
               ,tipo_tit
               ,id_ce_nota)
            values
               (p_emp
               ,p_fil
               ,reg.numero
               ,reg.serie
               , --sr_nota
                reg.firma
               , --v_cod_fornec --cod_fornec
                0
               , --parte
                v_id_parc
               ,regpar.numero
               ,regpar.data_vencimento
               ,regpar.valor
               ,'N'
               ,v_id);
         
         end loop;
      
      end if;
   /*
   exception
      when others then
        if sqlcode <> -20001 then
           gv_msg_erro := fg_get_line_error (ev_local   => gv_objeto 
                                              ,ev_msg_usu => 'exporta_nfe_nota:' || v_erro || chr(10) 
                                              || v_msg
                                              ,ev_msg_ora => sqlerrm); 
         --/gv_msg_erro := p_arq ||' | '||gv_msg_erro;
             raise_application_error (-20001,gv_msg_erro);
--
        end if;
--
        raise;      
    */      
        
   end;
   
   
   --|--------------------------------------------------------
   --|--------------------------------------------------------
   function is_xml_nfe(p_id number) return boolean is
      cursor cr is
         select extractvalue(a.xml_arq,
                             '//infNFe/@Id',
                             vg_name_space) id_nfe
           from xml_nfe a
          where a.id = p_id;
   
      v_id_nfe varchar2(1000);
      v_ret    boolean;
   begin
      open cr;
      fetch cr
         into v_id_nfe;
      close cr;
   
      if trim(v_id_nfe) is not null then
         v_ret := true;
      else
         v_ret := false;
      end if;
   
      return v_ret;
   end;

   --|--------------------------------------------------------
   function dados_nota_xml_nfe(p_id number) return varchar2 is
      cursor cr is
         select extractvalue(a.xml_arq,
                             '//infNFe/ide/natOp',
                             vg_name_space) nat_op
               ,extractvalue(a.xml_arq,
                             '//ide/nNF',
                             vg_name_space) numero_nf
               ,extractvalue(a.xml_arq,
                             '//infNFe/emit/xNome',
                             vg_name_space) nome
               ,extractvalue(a.xml_arq,
                             '//infNFe/total/ICMSTot/vNF',
                             vg_name_space) valor
           from xml_nfe a
          where a.id = p_id;
   
      v_nat     varchar2(100);
      v_nro     varchar2(100);
      v_nome    varchar2(200);
      v_valor_c varchar2(100);
      --     v_valor_ number(15,2);
   
      v_ret varchar2(1000);
   begin
      open cr;
      fetch cr
         into v_nat
             ,v_nro
             ,v_nome
             ,v_valor_c;
      close cr;
   
      --|-----------------------------------------------------------------------------------
      --| formatar o valor
      --|-----------------------------------------------------------------------------------
      begin
         select to_char(to_number(replace(v_valor_c,
                                          '.',
                                          ',')),
                        '999g999g990d00') vl
           into v_valor_c
           from dual;
      exception
         when others then
            null;
      end;
      --|-------------------------------------------------
      if trim(v_nro) is not null then
         v_ret := 'Fantasia...: ' || trim(v_nome) || chr(10) || 'Numero....: ' ||
                  trim(v_nro) || chr(10) || 'Operação..: ' || trim(v_nat) ||
                  chr(10) || 'Valor NF....: ' || trim(v_valor_c);
      else
         v_ret := null;
      end if;
   
      return v_ret;
   end;
   --|----------------------------------------------------------------------
   function Emitente_xml_nfe(p_id number) return varchar2 is
      cursor cr is
         select extractvalue(a.xml_arq,
                             '//infNFe/emit/xNome',
                             vg_name_space) nome
               
           from xml_nfe a
          where a.id = p_id;
      v_ret varchar2(1000);
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;

      return v_ret;
   end;
   --|----------------------------------------------------------------------
   function Cnpj_Emitente_xml_nfe(p_id number) return varchar2 is
      cursor cr is
         select extractvalue(a.xml_arq,
                             '//dest/CNPJ',
                             vg_name_space) cnpj
               
           from xml_nfe a
          where a.id = p_id;
      v_ret varchar2(1000);
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;

      return v_ret;
   end;
   --|-------------------------------------------------------
   function fl_tem_produto_fornec(p_forn ce_prod_fornec.cod_fornec%type
                                 ,p_prd  ce_prod_fornec.prod_fornec%type)
      return boolean is
      cursor cr is
         select 1
           from ce_prod_fornec f
          where f.cod_fornec = p_forn
            and f.prod_fornec = p_prd;
   
      v_ret   boolean := true;
      v_achou number(9);
   
   begin
      open cr;
      fetch cr
         into v_achou;
      if cr%notfound then
         v_ret := false;
      end if;
      close cr;
   
      return v_ret;
   end;

   --|-------------------------------------------------------
   function fl_relacao_produto_fornec(p_forn ce_prod_fornec.cod_fornec%type
                                     ,p_prd  ce_prod_fornec.prod_fornec%type)
      return ce_produtos.produto%type is
      cursor cr is
         select f.produto
           from ce_prod_fornec f
          where f.cod_fornec = p_forn
            and f.prod_fornec = p_prd;
   
      v_ret ce_produtos.produto%type;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   end;
   --|---------------------------------------------------------------------------
   --| atualiza produtos fornecedor com codigo oficial
   --|---------------------------------------------------------------------------

   procedure pr_relacao_produto_fornec(p_forn    ce_prod_fornec.cod_fornec%type
                                      ,p_prd_f   ce_prod_fornec.prod_fornec%type
                                      ,p_emp     ce_produtos.empresa%type
                                      ,p_prd_ofc ce_produtos.produto%type) is
   
      pragma autonomous_transaction;
   
      cursor cr is
         select f.id
               ,f.produto
           from ce_prod_fornec f
               ,(select p.empresa
                       ,p.produto
                   from ce_produtos p
                  where p.empresa = p_emp
                    and p.produto = p_prd_ofc) p2
          where f.cod_fornec = p_forn
            and f.prod_fornec = p_prd_f
            and p2.empresa(+) = f.empresa
            and p2.produto(+) = f.produto;
   
      v_prd ce_produtos.produto%type;
      v_id  ce_prod_fornec.id%type;
   
   begin
      open cr;
      fetch cr
         into v_id
             ,v_prd;
      close cr;
      if v_prd is null then
         if v_id is null then
            insert into ce_prod_fornec
               (id
               ,cod_fornec
               ,empresa
               ,produto
               ,prod_fornec
               ,usu_incl
               ,dt_incl
               ,usu_alt
               ,dt_alt)
            values
               (ce_prod_fornec_seq.nextval
               ,p_forn
               ,p_emp
               ,p_prd_ofc
               ,p_prd_f
               ,user
               ,sysdate
               ,null
               ,null);
         else
            update ce_prod_fornec f
               set f.empresa = p_emp
                  ,f.produto = p_prd_ofc
                  ,usu_alt   = user
                  ,dt_alt    = sysdate
             where id = v_id;
         end if;
         commit;
      end if;
   end;

   --|---------------------------------------------------------------------------
   --| atualiza produtos fornecedor com codigo oficial pelo id da nfe_detalhe
   --|---------------------------------------------------------------------------    
   procedure pr_relacao_produto_fornec_id(p_forn    ce_prod_fornec.cod_fornec%type
                                         ,p_id_det  nfe_detalhe.id%type
                                         ,p_emp     ce_produtos.empresa%type
                                         ,p_prd_ofc ce_produtos.produto%type) is
   
      pragma autonomous_transaction;
   
      cursor cr is
         select f.id
               ,f.produto
               ,d.codigo_produto
           from ce_prod_fornec f
               ,nfe_detalhe d
               ,(select p.empresa
                       ,p.produto
                   from ce_produtos p
                  where p.empresa = p_emp
                    and p.produto = p_prd_ofc) p2
          where f.cod_fornec = p_forn
            and f.prod_fornec = d.codigo_produto
            and d.id = p_id_det
            and p2.empresa(+) = f.empresa
            and p2.produto(+) = f.produto;
   
      v_prd      ce_produtos.produto%type;
      v_id       ce_prod_fornec.id%type;
      v_cod_prod ce_prod_fornec.prod_fornec%type;
   
      v_erro varchar2(500);
   
   begin
      v_erro := 'ERRO-1:';
      open cr;
      fetch cr
         into v_id
             ,v_prd
             ,v_cod_prod;
      close cr;
   
      v_erro := 'ERRO-2:';
      if v_prd is null then
         if v_id is null then
            v_erro := 'ERRO-3:';
            insert into ce_prod_fornec
               (id
               ,cod_fornec
               ,empresa
               ,produto
               ,prod_fornec
               ,usu_incl
               ,dt_incl
               ,usu_alt
               ,dt_alt)
            values
               (ce_prod_fornec_seq.nextval
               ,p_forn
               ,p_emp
               ,p_prd_ofc
               ,v_cod_prod
               , --p_prd_f,
                user
               ,sysdate
               ,null
               ,null);
         else
            v_erro := 'ERRO-3:' || p_prd_ofc;
            update ce_prod_fornec f
               set f.empresa = p_emp
                  ,f.produto = p_prd_ofc
                  ,usu_alt   = user
                  ,dt_alt    = sysdate
             where id = v_id;
         end if;
         commit;
      end if;
   exception
      when others then
         raise_application_error(-20110,
                                   v_erro);
                                   
   end;

end pk_xml;
/
