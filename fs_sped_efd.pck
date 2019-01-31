create or replace package fs_sped_efd is
  --------------------------------------------------------------------------------------
  --|| fs_sped_ver : Procedimentos por vers?o do cotepe
  --|| Escriturac?o Fiscal Digital
  --------------------------------------------------------------------------------------

  subtype tnum is number;
  subtype tvalor2 is number(14, 2);
  subtype tvalor4 is number(16, 4);
  subtype tchar is varchar2(1);
  subtype tstr0 is varchar2(1024);
  subtype tstr is varchar2(32767);
  subtype tstr2 is varchar2(2);
  subtype tstr4 is varchar2(4);
  subtype tstr1 is varchar2(1);
  subtype tstr8 is varchar2(8);
  subtype tstr10 is varchar2(10);

  subtype tstr100 is varchar2(100);
  subtype tstr1000 is varchar2(1000);
  subtype tnum1 is number(1);
  subtype tnum4 is number(4);
  subtype tcurs is pls_integer;
  subtype tint is pls_integer;
  subtype tid is number(9);
  -----------------------------------------------------------------------------------------------------------------
  type trec_gera is record(
    ordem     number(4),
    bloco     varchar2(6),
    registro  varchar2(6),
    num_linha number(9),
    linha     varchar2(4000));
  -----------------------------------------------------------------------------------------------------------------

  function fl_total_reg(p_dt date, p_bl fs_arq_sped.bloco%type) return number;

  -----------------------------------------------------------------------------------------------------------------
  function fl_max_linha(p_dt date, p_reg fs_arq_sped.registro%type)
    return number;

  -----------------------------------------------------------------------------------------------------------------

  -- versao 001
  procedure fs_sped_001(p_emp   in cd_empresas.empresa%type,
                        p_fil   in cd_filiais.filial%type,
                        p_firma in cd_firmas.firma%type,
                        p_cod   in fs_versoes_ac.codigo%type,
                        p_fin   in fs_finalid_ac.codigo%type,
                        p_inic  in date,
                        p_final in date,
                        p_seq   in number,
                        p_aplic in fs_versoes_ac.aplicacao%type);
end;
/
create or replace package body fs_sped_efd is
  --/ variaveis  Globais
  vg_emp   cd_empresas.empresa%type;
  vg_fil   cd_filiais.filial%type;
  vg_firma cd_firmas.firma%type;
  vg_cod   fs_versoes_ac.codigo%type;
  vg_fin   fs_finalid_ac.codigo%type;
  vg_inic  date;
  vg_final date;
  vg_seq   number;
  vg_aplic fs_versoes_ac.aplicacao%type;

  vg_num_linha number;
  vg_linha     varchar2(4000);
  vg_ordem     number(10);
  vg_bloco     varchar2(6);
  vg_registro  varchar2(6);
  vg_crlf      varchar2(10) := null; --chr(13) || chr(10); -- carriage return line feed
  vg_sep       varchar2(10) := '|'; -- delimitador de inicio e fim de cada campo
  --/
  vg_cgc       cd_firmas.cgc_cpf%type;
  vg_cpf       varchar2(11);
  vg_ie        cd_firmas.iest%type;
  vg_iest      cd_firmas.iest%type;
  vg_empresa   cd_firmas.nome%type;
  vg_cidade    cd_cidades.cidade%type;
  vg_uf        cd_firmas.uf%type;
  vg_ufst      cd_firmas.uf%type;
  vg_fax       cd_fones.fone%type;
  vg_ende      cd_firmas.endereco%type;
  vg_complemen cd_firmas.complemento%type;
  vg_bairro    cd_firmas.bairro%type;
  vg_contador  cd_firmas.nome%type;
  vg_fone      varchar2(20); --cd_fones.fone%type;
  vg_ibge      cd_cidades.ibge%type;
  vg_im        cd_firmas.imun%type;
  vg_suframa   cd_firmas.cod_suframa%type;
  vg_fantasia  cd_firmas.reduzido%type;
  vg_email     cd_firmas.email%type;
  vg_perfil    char(1);
  vg_ativ      number(1);
  --v_ativ
  vg_nro     char(5);
  vg_cep     char(8);
  vg_fiscal  char(28);
  vg_canc    char(1);
  vg_ind_mov number(1);
  vg_msg     varchar2(500);
  vg_ver     fs_versoes_ac.versao%type;
  vg_param   fs_ent_ac70%rowtype;
  vg_conta_k number(9) := 0;
  -----------------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------------
  --/ funcoes Publicas
  -----------------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------------
  function fl_total_reg(p_dt date, p_bl fs_arq_sped.bloco%type) return number is
    cursor cr is
      select count(bloco)
        from fs_arq_sped
       where (p_bl is null or bloco = p_bl)
         and dt_ref = p_dt;
  
    v_ret number;
  
  begin
  
    v_ret := 0;
  
    open cr;
    fetch cr
      into v_ret;
    close cr;
  
    return v_ret;
  end;
  -----------------------------------------------------------------------------------------------------------------
  function fl_max_linha(p_dt date, p_reg fs_arq_sped.registro%type)
    return number is
    cursor cr is
      select max(num_linha)
        from fs_arq_sped
       where registro = p_reg
         and dt_ref = p_dt;
  
    v_ret number;
  
  begin
  
    v_ret := 0;
  
    open cr;
    fetch cr
      into v_ret;
    close cr;
  
    return nvl(v_ret, 0);
  end;
  -----------------------------------------------------------------------------------------------------------------
  --|
  -----------------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------------
  --/ procedures internas
  -----------------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------------

  procedure pl_gera_linha is
    vn_id number(9);
  
  begin
    vg_num_linha := vg_num_linha + 1;
  
    select fs_arq_sped_seq.nextval into vn_id from dual;
  
    insert into fs_arq_sped
      (id,
       ordem,
       bloco,
       registro,
       dt_ref,
       seq_envio,
       num_linha,
       linha,
       dt_sis,
       usuario,
       aplicacao)
    values
      (vn_id,
       vg_ordem,
       vg_bloco,
       vg_registro,
       vg_inic,
       vg_seq,
       vg_num_linha,
       vg_linha,
       sysdate,
       user,
       'EFD');
    vg_linha := null;
    /*
    exception
       when others then
          raise_application_error(-20100,
                                  'fs_sped_001-PL_GERA_LINHA: ' ||
                                  substr(vg_linha,
                                         1,
                                         50) || ' # ' ||
                                  substr(sqlerrm,
                                         1,
                                         50));
    */
  end; -- fim da pl_gera_linha
  --/
  -----------------------------------------------------------------------------------------------------------------
  --REGISTRO 0000
  -----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0000 is
    --/ BLOCO 0
    /* lay-out
    BLOCO 0: ABERTURA, IDENTIFICAC?O E REFERENCIAS
    REGISTRO 0000: ABERTURA DO ARQUIVO DIGITAL E IDENTIFICAC?O DA ENTIDADE
    
    N?  Campo     Descric?o                                               Tipo  Tam Dec
    01  REG       Texto fixo contendo "0000".                                   C     004   -
    02  COD_VER     Codigo da vers?o do leiaute conforme a tabela indicada no Ato Cotepe.     N     003   -
    03  COD_FIN     Codigo da finalidade do arquivo:                                N     001   -
        0. Remessa do arquivo original;
        1. Remessa do arquivo substituto.
    04  DT_INI    Data inicial das informac?es contidas no arquivo.                     N     008   -
    05  DT_FIN    Data final das informac?es contidas no arquivo.                     N     008   -
    06  NOME      Nome empresarial da entidade.                                 C     -   -
    07  CNPJ      Numero de inscric?o da entidade no CNPJ.                          N     014   -
    08  CPF       Numero de inscric?o da entidade no CPF.                           N     011
    09  UF      Sigla da unidade da federac?o da entidade.                        C     002   -
    10  IE      Inscric?o Estadual da entidade.                                 C     -   -
    11  COD_MUN     Codigo do municipio do domicilio fiscal da entidade, conforme a tabela IBGE   N     007   -
    12  IM      Inscric?o Municipal da entidade.                              C     -   -
    13  SUFRAMA     Inscric?o da entidade na Suframa                              C     009   -
    14  IND_PERFIL  Perfil de apresentac?o do arquivo fiscal;                         C     001   -
        A - Perfil A;  ????????verificar
        B - Perfil B.;
        C - Perfil C.
    15  IND_ATIV  Indicador de tipo de atividade:                                 N     001   -
        0. Industrial ou equiparado a industrial;
        1. Outros.
    */
  
    --/ abertura do arquivo digital e identificac?o da entidade
  begin
    -----------------------------------------------------------------------------------------------------------------
    --        DADOS DA EMPRESA
    -----------------------------------------------------------------------------------------------------------------
    select lpad(replace(replace(replace(f.cgc_cpf, '.', ''), '/', ''),
                        '-',
                        ''),
                14,
                '0') cnpj,
           replace(replace(replace(f.iest, '.', ''), '/', ''), '-', '') inscr,
           rtrim(ltrim(e.nome)) nome_empresa,
           f.uf,
           rtrim(ltrim(f.endereco)) ender,
           rtrim(ltrim(f.complemento)) complemento,
           rtrim(ltrim(f.bairro)) bairro,
           lpad(replace(replace(replace(f.cep, '-', ''), '.', ''), '/'),
                8,
                '0') cep,
           fs_sped_utl.fb_fone(f.firma, 'FONE') fone_firma,
           c.ibge,
           f.cod_suframa,
           f.imun,
           f.reduzido nome_fantazia,
           f.email,
           0 ind_ativ,
           'A' ind_perfil
      into vg_cgc,
           vg_ie,
           vg_empresa,
           vg_uf,
           vg_ende,
           vg_complemen,
           vg_bairro,
           vg_cep,
           vg_fone,
           vg_ibge,
           vg_suframa,
           vg_im,
           vg_fantasia,
           vg_email,
           vg_ativ,
           vg_perfil
      from cd_firmas f, cd_empresas e, cd_cidades c
     where f.empresa = vg_emp
       and f.filial = vg_fil
       and e.empresa = f.empresa
       and f.cod_cidade = c.cod_cidade
       and f.firma = vg_firma
       ;
  
    --/
    vg_registro := '0000';
    --vg_perfil    := 'A';
    --vg_ativ      := 0;
    --/
    if vg_ibge is not null then
      vg_ibge := lpad(vg_ibge, 7, '0');
    end if;
    --/
    --| Grava o header do arquivo
    vg_linha := vg_sep || vg_registro || vg_sep;
    vg_linha := vg_linha || vg_cod || vg_sep;
    vg_linha := vg_linha || vg_fin || vg_sep;
    vg_linha := vg_linha || to_char(vg_inic, 'DDMMRRRR') || vg_sep;
    vg_linha := vg_linha || to_char(vg_final, 'DDMMRRRR') || vg_sep;
    vg_linha := vg_linha || vg_empresa || vg_sep;
    vg_linha := vg_linha || vg_cgc || vg_sep;
    vg_linha := vg_linha || vg_cpf || vg_sep; -- n?o tem dados
    vg_linha := vg_linha || vg_uf || vg_sep;
    vg_linha := vg_linha || vg_ie || vg_sep;
    vg_linha := vg_linha || vg_ibge || vg_sep;
    vg_linha := vg_linha || vg_im || vg_sep;
    vg_linha := vg_linha || vg_suframa || vg_sep;
    vg_linha := vg_linha || vg_perfil || vg_sep;
    vg_linha := vg_linha || vg_ativ || vg_sep || vg_crlf;
  
    pl_gera_linha;
  end;
  /*
  |0000|1|1|01012008|31012008|Jose Silva  Irm?os Ltda.|60001556000157||SP|01238578455|5030807|1423514||A|1|
    BLOCO 0: ABERTURA, IDENTIFICAC?O E REFERENCIAS
    REGISTRO 0000: ABERTURA DO ARQUIVO DIGITAL E IDENTIFICAC?O DA ENTIDADE
  
    N?  Campo     Descric?o                                               Tipo  Tam Dec
    01  REG       Texto fixo contendo "0000".                                   C     004   -
    02  COD_VER     Codigo da vers?o do leiaute conforme a tabela indicada no Ato Cotepe.     N     003   -
    03  COD_FIN     Codigo da finalidade do arquivo:                                N     001   -
        0. Remessa do arquivo original;
        1. Remessa do arquivo substituto.
    04  DT_INI    Data inicial das informac?es contidas no arquivo.                     N     008   -
    05  DT_FIN    Data final das informac?es contidas no arquivo.                     N     008   -
    06  NOME      Nome empresarial da entidade.                                 C     -   -
    07  CNPJ      Numero de inscric?o da entidade no CNPJ.                          N     014   -
    08  CPF       Numero de inscric?o da entidade no CPF.                           N     011
    09  UF      Sigla da unidade da federac?o da entidade.                        C     002   -
    10  IE      Inscric?o Estadual da entidade.                                 C     -   -
    11  COD_MUN     Codigo do municipio do domicilio fiscal da entidade, conforme a tabela IBGE   N     007   -
    12  IM      Inscric?o Municipal da entidade.                              C     -   -
    13  SUFRAMA     Inscric?o da entidade na Suframa                              C     009   -
    14  IND_PERFIL  Perfil de apresentac?o do arquivo fiscal;                         C     001   -
        A - Perfil A;  ????????verificar
        B - Perfil B.;
        C - Perfil C.
    15  IND_ATIV  Indicador de tipo de atividade:                                 N     001   -
        0. Industrial ou equiparado a industrial;
        1. Outros.
  */

  -----------------------------------------------------------------------------------------------------------------
  --REGISTRO 0001
  -----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0001 is
    /*
    REGISTRO 0001: ABERTURA DO BLOCO 0
    N?  Campo Descric?o Ti p o  Tam Dec
    01  REG   Texto fixo contendo "0001".   C   004   -
    02  IND_MOV   Indicador de movimento:    N  001   -
        0- Bloco com dados informados;
        1- Bloco sem dados informados.
    */
  
  begin
    --/ abertura do bloco 0
    vg_registro := '0001';
  
    vg_ind_mov := 0; --/
  
    vg_linha := vg_sep || vg_registro || vg_sep;
    vg_linha := vg_linha || vg_ind_mov || vg_sep || vg_crlf;
  
    pl_gera_linha;
  end;
  -------------------------------------------------------------------------------------------------------------------
  --REGISTRO 0005
  -------------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0005 is
    /*
    REGISTRO 0005: DADOS COMPLEMENTARES DA ENTIDADE
    N?    Campo     Descric?o                           Ti p o  Tam Dec
    01  REG       Texto fixo contendo "0005"                C   004   -
    02  FANTASIA  Nome de fantasia associado ao nome empresarial.   C   -   -
    03  CEP       Codigo de Enderecamento Postal.               N   008   -
    04  END       Logradouro e endereco do imovel.            C   -   -
    05  NUM       Numero do imovel.                       C   -   -
    06  COMPL     Dados complementares do endereco.             C   -   -
    07  BAIRRO    Bairro em que o imovel esta situado.          C   -   -
    08  FONE      Numero do telefone.                       C   -   -
    09  FAX       Numero do fax.                        C   -   -
    10  EMAIL     Endereco do correio eletronico.               C   -   -
    Observac?es: Registro obrigatorio
    Nivel hierarquico - 2
    Ocorrencia - um (por arquivo)
    */
  
    --/ abertura do bloco 0
  begin
    vg_registro := '0005';
    vg_fax      := fs_sped_utl.fb_fone(vg_firma, 'FAX');
  
    vg_linha := vg_sep || vg_registro || vg_sep;
    vg_linha := vg_linha || vg_fantasia || vg_sep;
    vg_linha := vg_linha || vg_cep || vg_sep;
    vg_linha := vg_linha || vg_ende || vg_sep;
    vg_linha := vg_linha || vg_sep; -- numero
    vg_linha := vg_linha || vg_complemen || vg_sep;
    vg_linha := vg_linha || vg_bairro || vg_sep;
    vg_linha := vg_linha || vg_fone || vg_sep;
    vg_linha := vg_linha || vg_fax || vg_sep;
    vg_linha := vg_linha || vg_email || vg_sep || vg_crlf;
  
    pl_gera_linha;
  
  end;
  -------------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0015
  -------------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0015 is
    /*
    REGISTRO 0015: DADOS DO CONTRIBUINTE SUBSTITUTO
    N?    Campo   Descric?o                                         Tipo  Tam Dec
    01  REG     Texto fixo contendo "0015"                              C     004   -
    02  UF_ST   Sigla da unidade da federac?o                             C     002   -
    03  IE_ST   Inscric?o Estadual de contribuinte substituto na unidade da federac?o   C     -   -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
    */
  begin
    vg_registro := '0015';
    if vg_ufst is not null then
      vg_linha := vg_sep || vg_registro || vg_sep;
      vg_linha := vg_linha || vg_ufst || vg_sep;
      vg_linha := vg_linha || vg_iest || vg_sep || vg_crlf;
    
      pl_gera_linha;
    end if;
  end;

  -------------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0100: DADOS DO CONTABILISTA
  -------------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0100 is
    /*
    REGISTRO 0100: DADOS DO CONTABILISTA
    N?    Campo   Descric?o                                             Tipo  Tam Dec
    01  REG     Texto fixo contendo "0100".                                   C     004   -
    02  NOME    Nome do contabilista.                                       C     -   -
    03  CPF     Numero de inscric?o do contabilista no CPF.                         N     011   -
    04  CRC     Numero de inscric?o do contabilista no Conselho Regional de Contabilidade.  C     011   -
    05  CNPJ    Numero de inscric?o do escritorio de contabilidade no CNPJ, se houver.      N     014   -
    06  CEP     Codigo de Enderecamento Postal.                                 N     008   -
    07  END     Logradouro e endereco do imovel.                              C     -   -
    08  NUM     Numero do imovel.                                         C     -   -
    09  COMPL   Dados complementares do endereco.                               C     -   -
    10  BAIRRO  Bairro em que o imovel esta situado.                            C     -   -
    11  FONE    Numero do telefone.                                         C     -   -
    12  FAX     Numero do fax.                                          C     -   -
    13  EMAIL   Endereco do correio eletronico.                                 C     -   -
    14  COD_MUN   Codigo do municipio, conforme tabela IBGE.                        N     007   -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - um (por arquivo)
    */
    cursor cr1 is
      select contador, crc, firma from fs_param where empresa = vg_emp;
    --/
    cursor cr2(pl_firma cd_firmas.firma%type) is
      select lpad(replace(replace(replace(f.cgc_cpf, '.', ''), '/', ''),
                          '-',
                          ''),
                  11,
                  '0') cpf,
             replace(replace(replace(f.iest, '.', ''), '/', ''), '-', '') inscr,
             rtrim(ltrim(f.nome)) nome,
             f.uf,
             rtrim(ltrim(f.endereco)) ender,
             rtrim(ltrim(f.complemento)) complemento,
             rtrim(ltrim(f.bairro)) bairro,
             lpad(replace(replace(replace(f.cep, '-', ''), '.', ''), '/'),
                  8,
                  '0') cep,
             --replace( replace( replace( replace( cd_firmas_utl.fone(f.firma), '-', '' ), ')', '' ), '.', '' ), '(', '' ) FONE,
             fs_sped_utl.fb_fone(f.firma, 'FONE') fone,
             c.ibge,
             f.imun,
             f.email
        from cd_firmas f, cd_cidades c
       where f.cod_cidade = c.cod_cidade
         and f.firma = pl_firma;
  
    -- variaveis
    v_firma_cont fs_param.firma%type;
    v_crc        fs_param.crc%type;
    v_cpf        varchar2(11);
    v_cnpj       varchar2(14);
    v_cidade     cd_cidades.cidade%type;
    v_uf         cd_firmas.uf%type;
    v_fax        varchar2(20);
    v_fone       varchar2(20);
    v_ende       cd_firmas.endereco%type;
    v_complemen  cd_firmas.complemento%type;
    v_bairro     cd_firmas.bairro%type;
    v_contador   cd_firmas.nome%type;
    v_ibge       varchar2(7);
    v_im         cd_firmas.imun%type;
    v_email      cd_firmas.email%type;
    v_num        number(4);
    v_cep        varchar2(8);
  
  begin
  
    --/
    open cr1;
    fetch cr1
      into v_contador, v_crc, v_firma_cont;
    close cr1;
    --/
    if v_firma_cont is not null then
      open cr2(v_firma_cont);
      fetch cr2
        into v_cpf,
             vg_ie,
             v_contador,
             v_uf,
             v_ende,
             v_complemen,
             v_bairro,
             v_cep,
             v_fone,
             v_ibge,
             v_im,
             v_email;
      close cr2;
    
      v_fax := fs_sped_utl.fb_fone(vg_firma, 'FAX%');
      if v_ibge is not null then
        v_ibge := lpad(v_ibge, 7, '0');
      end if;
    
    end if;
    vg_registro := '0100';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || v_contador || vg_sep;
    vg_linha    := vg_linha || v_cpf || vg_sep;
    vg_linha    := vg_linha || v_crc || vg_sep;
    vg_linha    := vg_linha || v_cnpj || vg_sep;
    vg_linha    := vg_linha || v_cep || vg_sep;
    vg_linha    := vg_linha || v_ende || vg_sep;
    vg_linha    := vg_linha || v_num || vg_sep; -- nulo
    vg_linha    := vg_linha || v_complemen || vg_sep;
    vg_linha    := vg_linha || v_bairro || vg_sep;
    vg_linha    := vg_linha || v_fone || vg_sep;
    vg_linha    := vg_linha || v_fax || vg_sep;
    vg_linha    := vg_linha || v_email || vg_sep;
    vg_linha    := vg_linha || v_ibge || vg_sep || vg_crlf;
  
    pl_gera_linha;
  end;

  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0175  declarac?o do processo pl_registro_0175  para chamada pelo pl_registro_0150
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0175(p_cod cd_firmas.firma%type);
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0150
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0150 is
    /*
    REGISTRO 0150: TABELA DE CADASTRO DO PARTICIPANTE
    N?    Campo     Descric?o                                           Tipo  Tam Dec
    01  REG       Texto fixo contendo "0150".                                 C     004   -
    02  COD_PART  Codigo de identificac?o do participante no arquivo.                 C     -   -
    03  NOME      Nome pessoal ou empresarial do participante.                    C     -   -
    04  COD_PAIS  Codigo do pais do participante, conforme a tabela indicada no item 3.2.1  N     005   -
    05  CNPJ      CNPJ do participante.                                     N     014   -
    06  CPF       CPF do participante.                                    N     011   -
    07  IE      Inscric?o Estadual do participante.                           C   -   -
    08  COD_MUN     Codigo do municipio, conforme a tabela IBGE                       N     007   -
    09  SUFRAMA     Numero de inscric?o do participante na Suframa.                   C   009   -
    10  END       Logradouro e endereco do imovel                               C   -   -
    11  NUM       Numero do imovel                                        C     -   -
    12  COMPL     Dados complementares do endereco                            C   -   -
    13  BAIRRO    Bairro em que o imovel esta situado                           C   -   -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
    
    */
    cursor cr2 is
      select distinct nome,
                      codigo_part,
                      cnpj,
                      cpf,
                      inscr,
                      uf,
                      ender,
                      complemento,
                      numero_end,
                      bairro,
                      cep,
                      fone,
                      ibge,
                      imun,
                      email,
                      suframa,
                      nome_fantazia,
                      cod_pais,
                      pais
        from (select 'E' tipo,
                     rtrim(ltrim(f.nome)) nome,
                     f.firma codigo_part,
                     case
                       when f.natureza = 'F' or f.cgc_cpf is null then
                        null
                       else
                        lpad(replace(replace(replace(f.cgc_cpf, '.', ''),
                                             '/',
                                             ''),
                                     '-',
                                     ''),
                             14,
                             '0')
                     end cnpj,
                     case
                       when f.natureza = 'J' or f.cgc_cpf is null then
                        null
                       else
                        lpad(replace(replace(replace(f.cgc_cpf, '.', ''),
                                             '/',
                                             ''),
                                     '-',
                                     ''),
                             11,
                             '0')
                     end cpf,
                     case
                       when f.iest is not null then
                        replace(replace(replace(f.iest, '.', ''), '/', ''),
                                '-',
                                '')
                       else
                        null
                     end inscr,
                     f.uf,
                     rtrim(ltrim(f.endereco)) ender,
                     rtrim(ltrim(f.complemento)) complemento,
                     f.numero numero_end,
                     rtrim(ltrim(f.bairro)) bairro,
                     lpad(replace(replace(replace(f.cep, '-', ''), '.', ''),
                                  '/'),
                          8,
                          '0') cep,
                     --replace( replace( replace( replace( cd_firmas_utl.fone(f.firma), '-', '' ), ')', '' ), '.', '' ), '(', '' ) FONE,
                     fs_sped_utl.fb_fone(f.firma, 'FONE') fone,
                     lpad(c.ibge, 7, '0') ibge,
                     f.imun,
                     f.email,
                     case
                       when f.cod_suframa is not null then
                        lpad(cod_suframa, 9, '0')
                       else
                        null
                     end suframa,
                     f.reduzido nome_fantazia,
                     lpad(p.cod_siscomex, 5, '0') cod_pais,
                     p.pais pais
                from cd_firmas  f,
                     cd_cidades c,
                     ce_notas   n,
                     cd_uf      u,
                     cd_paises  p
               where f.cod_cidade = c.cod_cidade
                 and f.firma = n.cod_fornec
                 and n.dt_entrada between vg_inic and vg_final
                 and u.uf = c.uf
                 and p.pais = f.pais
                 and p.pais = u.pais
              union
              select 'S' tipo,
                     rtrim(ltrim(f.nome)) nome,
                     f.firma codigo_part,
                     case
                       when f.natureza = 'F' or f.cgc_cpf is null then
                        null
                       else
                        lpad(replace(replace(replace(f.cgc_cpf, '.', ''),
                                             '/',
                                             ''),
                                     '-',
                                     ''),
                             14,
                             '0')
                     end cnpj,
                     case
                       when f.natureza = 'J' or f.cgc_cpf is null then
                        null
                       else
                        lpad(replace(replace(replace(f.cgc_cpf, '.', ''),
                                             '/',
                                             ''),
                                     '-',
                                     ''),
                             11,
                             '0')
                     end cpf,
                     case
                       when f.iest is not null then
                        replace(replace(replace(f.iest, '.', ''), '/', ''),
                                '-',
                                '')
                       else
                        null
                     end inscr,
                     f.uf,
                     rtrim(ltrim(f.endereco)) ender,
                     rtrim(ltrim(f.complemento)) complemento,
                     f.numero numero_end,
                     rtrim(ltrim(f.bairro)) bairro,
                     lpad(replace(replace(replace(f.cep, '-', ''), '.', ''),
                                  '/'),
                          8,
                          '0') cep,
                     --replace( replace( replace( replace( cd_firmas_utl.fone(f.firma), '-', '' ), ')', '' ), '.', '' ), '(', '' ) FONE,
                     fs_sped_utl.fb_fone(f.firma, 'FONE') fone,
                     lpad(c.ibge, 7, '0') ibge,
                     f.imun,
                     f.email,
                     case
                       when f.cod_suframa is not null then
                        lpad(cod_suframa, 9, '0')
                       else
                        null
                     end suframa,
                     f.reduzido nome_fantazia,
                     lpad(p.cod_siscomex, 5, '0') cod_pais,
                     p.pais pais
              
                from cd_firmas  f,
                     cd_cidades c,
                     ft_notas   n,
                     cd_uf      u,
                     cd_paises  p
               where f.cod_cidade = c.cod_cidade
                 and f.firma = n.firma
                 and c.cod_cidade = n.ent_cidade
                 and p.pais = n.ent_pais
                 and u.uf = n.ent_uf
                 and n.dt_entsai between vg_inic and vg_final
                 and u.uf = c.uf
                 and p.pais = f.pais
                 and p.pais = u.pais);
  
  begin
    for reg in cr2 loop
    
      vg_registro := '0150';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || reg.codigo_part || vg_sep;
      vg_linha    := vg_linha || reg.nome || vg_sep;
      vg_linha    := vg_linha || reg.cod_pais || vg_sep;
      vg_linha    := vg_linha || reg.cnpj || vg_sep;
      vg_linha    := vg_linha || reg.cpf || vg_sep;
      vg_linha    := vg_linha || reg.inscr || vg_sep;
      vg_linha    := vg_linha || reg.ibge || vg_sep;
      vg_linha    := vg_linha || reg.suframa || vg_sep;
      vg_linha    := vg_linha || reg.ender || vg_sep;
      vg_linha    := vg_linha || reg.numero_end || vg_sep;
      vg_linha    := vg_linha || reg.complemento || vg_sep;
      vg_linha    := vg_linha || reg.bairro || vg_sep || vg_crlf;
    
      pl_gera_linha;
    
      pl_registro_0175(reg.codigo_part); -- verifica alterac?es cadastrais
    end loop;
  end;
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0175
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0175(p_cod cd_firmas.firma%type) is
    /*
    REGISTRO 0175: ALTERAC?O DA TABELA DE CADASTRO DE PARTICIPANTE
    N?    Campo   Descric?o                           Tipo  Tam Dec
    01  REG   Texto fixo contendo "0175"                C     004   -
    02  DT_ALT  Data de alterac?o do cadastro               N     008   -
    03  NR_CAMPO  Numero do campo alterado (Somente campos 03 a 13)   C   002   -
    04  CONT_ANT  Conteudo anterior do campo                  C     -   -
    
    Observac?es: Os dados informados neste registro ser?o validos ate as 24:00 horas do dia anterior a data de alterac?o.
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    null; --/ rotinas de alterac?es cadastrais , ver modo de guardar log dos dados anteriores a alterac?o no cadastro de entidades
  end;
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0190
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0190 is
    /*
    REGISTRO 0190: IDENTIFICAC?O DAS UNIDADES DE MEDIDA
    N?    Campo   Descric?o               Tipo  Tam Dec
    01  REG     Texto fixo contendo "0190"    C     004   -
    02  UNID    Codigo da unidade de medida     C     -   -
    03  DESCR   Descric?o da unidade de medida  C     -   -
    Observac?es:
    Nivel hierarquico: 2
    Ocorrencia: Varios por arquivo
    */
    cursor cr is
      select rpad(unidade, 4, ' ') unidade, descricao, sigla
        from ce_unid
       order by descricao;
  begin
    for reg in cr loop
      vg_registro := '0190';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || reg.unidade || vg_sep;
      vg_linha    := vg_linha || reg.descricao || vg_sep || vg_crlf;
    
      pl_gera_linha;
    
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0205 declarac?o do processo para chamada pelo pl_registro_0200
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0205(p_emp ce_produtos.empresa%type,
                             p_prd ce_produtos.produto%type);
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0200 - tabela de identificação do item
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0200 is
    /* importante para o Bloco-K
    REGISTRO 0200: TABELA DE IDENTIFICAC?O DO ITEM (PRODUTO E SERVICOS)
    N?    Campo       Descric?o                                       Tipo  Tam Dec
    01  REG         Texto fixo contendo "0200"                            C     004   -
    02  COD_ITEM    Codigo do item                                    C     -   -
    03  DESCR_ITEM    Descric?o do item                                   C     -   -
    04  COD_BARRA     Representac?o alfanumerico do codigo de barra do produto, se houver   C     -   -
    05  COD_ANT_ITEM  Codigo anterior do item com relac?o a ultima informac?o apresentada. C    -   -
    06  UNID_INV    Unidade de medida utilizada na quantificac?o de estoques.         C     -   -
    07  TIPO_ITEM     Tipo do item - Atividades Industriais, Comerciais e Servicos:       N     2     -
        00 - Mercadoria para Revenda;
        01 - Materia-Prima;
        03 - Produto em Processo;
        04 - Produto Acabado;
        05 - Subproduto;
        06 - Produto Intermediario;
        07 - Material de Uso e Consumo;
        08 - Ativo Imobilizado;
        09 - Servicos;
        10 - Outros insumos;
        99 - Outras
    08  COD_NCM       Codigo da Nomenclatura Comum do Mercosul                    C     008   -
    09  EX_IPI      Codigo EX, conforme a TIPI                                         C    003   -
    10  COD_GEN       Codigo do genero do item, conforme a Tabela 4.2.1               N     002   -
    11  COD_LST       Codigo do servico conforme lista do Anexo I da Lei            N     004   -
    Observac?es:
    1. O Codigo do Item devera ser preenchido com as informac?es utilizadas na ultima ocorrencia do periodo.
    2. O campo COD_NCM e obrigatorio para empresas industriais e equiparadas a industrial,
       dos itens correspondentes a atividade fim, ou quando, gerarem creditos e debitos de IPI.
       As demais empresas que realizarem operac?es de exportac?o tambem est?o obrigadas a informar
       o codigo NCM dos produtos exportados.
    3. O campo COD_GEN e obrigatorio a todos os contribuintes somente na aquisic?o de produtos primarios.
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
    
    Exemplo (codigo do item com alterac?o de descric?o):
    |0200|Codigo11|Cerveja gelada garrafa 600 ml||Codigo11|Cx|00|||||CRLF
    |0205|Cerveja gelada|01012005|15012008|CRLF
    |0200|Codigo5|Silencioso para veiculo XX||Codigo5|Un|00|||||CRLF
    |0205|Silencioso para veiculo|01102007|15112007|CRLF
    */
    cursor cr is
      select produto,
             descricao,
             null cod_barra,
             null cod_anter,
             unidade,
             fs_sped_utl.fb_ident_prod(empresa, produto) ident,
             replace(ce_produtos_utl.cod_nbm(empresa, produto), '.', '') cod_nbm,
             null ex_ipi,
             fs_sped_utl.fb_gen_prod(empresa, produto) cod_gen,
             fs_sped_utl.fb_cod_lst_prod(empresa, produto) cod_lst,
             empresa
        from ce_produtos a
       where situacao = 'A'
         and a.estoque = 'S'
         and a.empresa = vg_emp
         and fs_sped_utl.fb_produto_sped(vg_emp, vg_fil,a.produto,vg_inic,vg_final) ='S'
      --and produto = 27199
      union all
      select o.produto,
             o.descricao,
             o.cod_barra cod_barra,
             o.cod_anter cod_anter,
             o.unidade unidade,
             fs_sped_utl.fb_ident_prod(o.empresa, o.produto) ident,
             replace(ce_produtos_utl.cod_nbm(o.empresa, o.produto), '.', '') cod_nbm,
             null ex_ipi,
             fs_sped_utl.fb_gen_prod(o.empresa, o.produto) cod_gen,
             fs_sped_utl.fb_cod_lst_prod(o.empresa, o.produto) cod_lst,
             o.empresa
        from vce_produto_elab o
       where o.empresa = vg_emp
         and o.filial = vg_fil
         and o.data_elab between vg_inic and vg_final
         order by 1;
  
    --order by descricao;
  begin
    delete TMP_SPED_BLOCO_0200;
    commit;
    for reg in cr loop
      vg_registro := '0200';
      vg_msg      := vg_registro || ' - ' || reg.produto;
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || reg.produto || vg_sep;
      vg_linha    := vg_linha || ltrim(rtrim(reg.descricao)) || vg_sep;
      vg_linha    := vg_linha || '' || vg_sep; --reg.cod_barra || vg_sep;
      vg_linha    := vg_linha || reg.cod_anter || vg_sep;
      vg_linha    := vg_linha || reg.unidade || vg_sep;
      vg_linha    := vg_linha || reg.ident || vg_sep;
      vg_linha    := vg_linha || reg.cod_nbm || vg_sep;
      vg_linha    := vg_linha || reg.ex_ipi || vg_sep;
      vg_linha    := vg_linha || reg.cod_gen || vg_sep;
      vg_linha    := vg_linha || reg.cod_lst || vg_sep;
      vg_linha    := vg_linha || null || vg_sep; --aliq_icms
      vg_linha    := vg_linha || null || vg_sep || vg_crlf; -- cest
    
      pl_gera_linha;
      insert into TMP_SPED_BLOCO_0200
        (COD_ITEM,
         DESCR_ITEM,
         COD_BARRA,
         COD_ANT_ITEM,
         UNID_INV,
         TIPO_ITEM,
         COD_NCM,
         EX_IPI,
         COD_GEN,
         COD_LST,
         ALIQ_ICMS,
         CEST)
      values
        (reg.produto,
         ltrim(rtrim(reg.descricao)),
         null,
         reg.cod_anter,
         reg.unidade,
         reg.ident,
         reg.cod_nbm,
         reg.ex_ipi,
         reg.cod_gen,
         reg.cod_lst,
         null,
         null
         
         );
      pl_registro_0205(reg.empresa, reg.produto); -- verifica alterac?es cadastrais
    end loop;
    commit;
  end;
  ----------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0205
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0205(p_emp ce_produtos.empresa%type,
                             p_prd ce_produtos.produto%type) is
    /*
    REGISTRO 0205:  ALTERAC?O DO ITEM
    N?    Campo         Descric?o                           Tipo  Tam Dec
    01  REG           Texto fixo contendo "0205"                C     004   -
    02  DESCR_ANT_ITEM  Descric?o anterior do item                C     -   -
    03  DT_INI        Data inicial de utilizac?o da descric?o do item   N     008   -
    04  DT_FIM        Data final de utilizac?o da descric?o do item     N     008   -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    null; -- n?o sera permitido alterac?es no cadastro de produtos que possam refletir no cotepe
  end;
  ----------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0206
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0206 is
    /*
    REGISTRO 0206: CODIGO DE PRODUTO CONFORME TABELA ANP (COMBUSTIVEIS)
    N?    Campo     Descric?o                                 Tipo  Tam Dec
    01  REG       Texto fixo contendo "0206"                      C     004   -
    02  COD_COMB  Codigo do combustivel, conforme tabela publicada pela ANP   C     -   -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
  begin
    null; --checar se sera necessario gerar
  end;
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0210 - consumo específico padronizado
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0210 is
    /*
    importante para o Bloco-K
    Apresenta a lista de materiais padrão de todos os produtos acabados 
    e semiacabados da empresa.
    */
  begin
    null;
  end;
  ----------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0220 - movimentações internas entre mercadorias
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0220 is
    /*
    REGISTRO 0220: FATORES DE CONVERS?O DE UNIDADES
    N?    Campo     Descric?o                                 tipo  tam dec
    01  REG       Texto fixo contendo "0220"                      C     004   -
    02  UNID_CONV   Unidade comercial a ser convertida na unidade de estoque,   C     -   -
                      referida no registro 0200.
    03  FAT_CONV  Fator de convers?o: fator utilizado para converter          N     6   -
                      (multiplicar) a unidade a ser convertida na unidade
                      adotada no inventario.
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
     */
    cursor cr is
      select rpad(unidade, 4, ' ') unidade, 1 fator
        from ce_unid
       order by descricao;
  begin
    for reg in cr loop
      vg_registro := '0220';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || reg.unidade || vg_sep;
      vg_linha    := vg_linha || reg.fator || vg_sep || vg_crlf;
    
      pl_gera_linha;
    
    end loop;
  end;
  ----------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0400
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0400 is
    /*
    REGISTRO 0400: TABELA DE NATUREZA DA OPERAC?O/PRESTAC?O
    N?    Campo     Descric?o                       Tipo  Tam Dec
    01  REG     Texto fixo contendo "0400"            C   004   -
    02  COD_NAT   Codigo da natureza da operac?o/prestac?o    C   -   -
    03  DESCR_NAT Descric?o da natureza da operac?o/prestac?o C   -   -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
     */
    cursor cr is
      select cod_cfo nat, c.descricao from ft_cfo c order by 1;
  
  begin
    /*
    for reg in cr loop
      vg_registro := '0400';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || reg.nat || vg_sep;
      vg_linha    := vg_linha || reg.descricao || vg_sep || vg_crlf;
      --21/01/2019  tem que ser cfo base -não gerar ate mudar
    --pl_gera_linha;
    
    end loop;
    */
    NULL;
  end;
  ----------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0450
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0450 is
    /*
    REGISTRO 0450: TABELA DE INFORMAC?O COMPLEMENTAR DO DOCUMENTO FISCAL
    N?    Campo   Descric?o                               Tipo  Tam Dec
    01  REG     Texto fixo contendo "0450"                    C     004   -
    02  COD_INF   Codigo da informac?o complementar do documento fiscal.  C     -   -
    03  TXT     Texto livre da informac?o complementar existente      C     -   -
          no documento fiscal, inclusive especie de normas legais,
          poder normativo, numero, capitulac?o, data e demais referencias
          pertinentes com indicac?o referentes ao tributo.
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
    */
    cursor cr is
      select cod_msg,
             decode(mensagem,
                    null,
                    tit_msg,
                    ltrim(rtrim(replace(mensagem, chr(10), ' ')))) mensagem --ltrim(rtrim(mensagem)))
        from ft_msgs
       order by 1;
  begin
  
    for reg in cr loop
    
      vg_registro := '0450';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || reg.cod_msg || vg_sep;
      vg_linha    := vg_linha || reg.mensagem || vg_sep || vg_crlf;
    
      pl_gera_linha;
    
    end loop;
  
  end;
  ----------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0460
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0460 is
    /*
    REGISTRO 0460: TABELA DE OBSERVAC?ES DO LANCAMENTO FISCAL
    N?    Campo   Descric?o                               Tipo  Tam Dec
    01  REG     Texto fixo contendo "0460"                    C     004   -
    02  COD_OBS   Codigo da Observac?o do lancamento fiscal.          C     -   -
    03  TXT     Descric?o da observac?o vinculada ao lancamento fiscal  C     -   -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
     */
    --/ verificar se tem alguma tabela de observacoes de nota fiscais
    cursor cr is
      select null cod, null txt from dual;
  begin
  
    for reg in cr loop
      vg_registro := '0460';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || reg.cod || vg_sep;
      vg_linha    := vg_linha || reg.txt || vg_sep || vg_crlf;
    
    --pl_gera_linha;
    
    end loop;
  
  end;
  ----------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO 0990
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_0990 is
    /*
    REGISTRO 0990: ENCERRAMENTO DO BLOCO 0
    N?    Campo     Descric?o                   Tipo  Tam Dec
    01  REG       Texto fixo contendo "0990"        C     004   -
    02  QTD_LIN_0   Quantidade total de linhas do Bloco 0   N     -   -
    Observac?es: Registro obrigatorio
    Nivel hierarquico - 1
    Ocorrencia - um (por arquivo)
    */
    v_aux number;
  begin
    v_aux := fl_total_reg(vg_inic, '0');
  
    vg_registro := '0990';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || v_aux || vg_sep || vg_crlf;
  
    pl_gera_linha;
  
  end;
  --*************************************************************************************************************
  --*************************************************************************************************************
  --                                          BLOCO - C
  --                          DOCUMENTOS FISCAIS I - MERCADORIAS (ICMS/IPI)
  --*************************************************************************************************************
  --*************************************************************************************************************
  ----------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO C001
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_c001 is
    /*
    REGISTRO C001: ABERTURA DO BLOCO C
    N?    Campo   Descric?o             Tipo  Tam Dec
    01  REG     Texto fixo contendo "C001"  C     004   -
    02  IND_MOV   Indicador de movimento:       C     001   -
      0. Bloco com dados informados;
      1. Bloco sem dados informados
    Observac?es: Registro obrigatorio
    Nivel hierarquico - 1
    Ocorrencia - um (por arquivo)
    */
  begin
  
    vg_registro := 'C001';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || '0' || vg_sep || vg_crlf;
  
    pl_gera_linha;
  end;
  ----------------------------------------------------------------------------------------------------------------
  -- declarac?es de nivel inferior utilizados a partir do registro C100
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_c110(pl_emp      ft_notas.empresa%type,
                             pl_fil      ft_notas.filial%type,
                             pl_nota     ft_notas.num_nota%type,
                             pl_sr       ft_notas.sr_nota%type,
                             pl_sub      tnum1,
                             pl_par      ft_notas.parte%type,
                             pl_ind_oper tnum1,
                             pl_ind_emit tnum1,
                             pl_cod_part cd_firmas.firma%type,
                             pl_cod_mod  tstr2,
                             pl_dt_doc   tstr10);

  procedure pl_registro_c111(p_cod ft_icms_msg.cod_msg%type); -- somente declarac?o
  procedure pl_registro_c112;
  procedure pl_registro_c113(p_ind_oper tnum1,
                             p_ind_emit tnum1,
                             p_cod_part cd_firmas.firma%type,
                             p_cod_mod  tstr2,
                             p_ser      ft_notas.sr_nota%type,
                             p_sub      tnum1,
                             p_num_doc  ft_notas.num_nota%type,
                             p_dt_doc   tstr10);
  procedure pl_registro_c114;
  procedure pl_registro_c115(pl_emp      ft_notas.empresa%type,
                             pl_fil      ft_notas.filial%type,
                             pl_cod_part cd_firmas.firma%type,
                             pl_sr       ft_notas.sr_nota%type,
                             pl_nota     ft_notas.num_nota%type,
                             pl_par      ft_notas.parte%type);

  procedure pl_registro_c120(p_ped ft_pedidos.num_pedido%type,
                             p_pis tvalor2,
                             p_cof tvalor2);

  procedure pl_registro_c130(p_vl_serv_nt  number,
                             p_vl_bc_issqn number,
                             p_vl_issqn    number,
                             p_vl_bc_irrf  number,
                             p_vl_irrf     number,
                             p_vl_bc_prev  number,
                             p_vl_prev     number);
  procedure pl_registro_c140(pl_emp      ft_notas.empresa%type,
                             pl_fil      ft_notas.filial%type,
                             pl_cod_part cd_firmas.firma%type,
                             pl_sr       ft_notas.sr_nota%type,
                             pl_nota     ft_notas.num_nota%type,
                             pl_par      ft_notas.parte%type,
                             pl_ind_emit tnum1);

  procedure pl_registro_c141(p_parc ce_parc_nf.parcela%type,
                             p_dt   tstr10,
                             p_vl   tvalor2);
  procedure pl_registro_c150;
  procedure pl_registro_c160(pl_cod_part cd_firmas.firma%type,
                             pl_placa    ft_notas.placa_veic%type,
                             pl_qtd      ft_notas.vol_qtd%type,
                             pl_pbrt     ft_notas.peso_bruto%type,
                             pl_pliq     ft_notas.peso_liquido%type);
  procedure pl_registro_c165;
  procedure pl_registro_c170(pl_emp      ft_notas.empresa%type,
                             pl_fil      ft_notas.filial%type,
                             pl_cod_part cd_firmas.firma%type,
                             pl_sr       ft_notas.sr_nota%type,
                             pl_nota     ft_notas.num_nota%type,
                             pl_par      ft_notas.parte%type,
                             pl_ind_emit tnum1);

  procedure pl_registro_c171;
  procedure pl_registro_c172(pl_vl_bc_issqn number,
                             pl_aliq_issqn  number,
                             pl_vl_issqn    number);
  procedure pl_registro_c173;
  procedure pl_registro_c174;
  procedure pl_registro_c175;
  procedure pl_registro_c176;
  procedure pl_registro_c177;
  procedure pl_registro_c178;
  procedure pl_registro_c179;
  procedure pl_registro_c190(p_imp       in fs_itens_livro.tip_imposto%type,
                             p_emp       in cd_empresas.empresa%type,
                             p_fil       in cd_filiais.filial%type,
                             p_firma     in cd_firmas.firma%type,
                             p_tip_livro in fs_itens_livro.tip_livro%type,
                             p_num_docto in fs_itens_livro.num_docto%type,
                             p_ser_docto in fs_itens_livro.ser_docto%type,
                             p_tip_docto in fs_itens_livro.tip_docto%type,
                             p_nat_oper  in fs_itens_livro.nat_oper%type,
                             p_dt        in date);
  procedure pl_registro_c195;
  procedure pl_registro_c197;
  procedure pl_registro_c310;
  procedure pl_registro_c320;
  procedure pl_registro_c321;
  procedure pl_registro_c405;
  procedure pl_registro_c410;
  procedure pl_registro_c420;
  procedure pl_registro_c460;
  procedure pl_registro_c490;
  procedure pl_registro_c425;
  procedure pl_registro_c470;
  procedure pl_registro_c510(pl_num_item     tnum4,
                             pl_cod_item     tid,
                             pl_cod_class    tstr10,
                             pl_qtd          tvalor2,
                             pl_unid         ce_itens_nf.uni_ven%type,
                             pl_vl_item      tvalor2,
                             pl_vl_desc      tvalor2,
                             pl_cst_icms     ce_itens_nf.cod_tribut%type,
                             pl_cfop         ce_notas.cod_cfo%type,
                             pl_vl_bc_icms   tvalor2,
                             pl_aliq_icms    number,
                             pl_vl_icms      tvalor2,
                             pl_vl_bc_icms_s tvalor2,
                             pl_aliq_st      tvalor2,
                             pl_vl_icms_st   tvalor2,
                             pl_ind_rec      tstr1,
                             pl_cod_part     ce_notas.cod_fornec%type,
                             pl_vl_pis       tvalor2,
                             pl_vl_cofins    tvalor2,
                             pl_conta        cg_plano.cod_conta%type,
                             pl_num          ce_notas.num_nota%type,
                             pl_ser          ce_notas.sr_nota%type);
  procedure pl_registro_c520;
  procedure pl_registro_c590(p_cst_icms      ce_itens_nf.cod_tribut%type,
                             p_cfop          ce_itens_nf.cod_cfo%type,
                             p_aliq_icms     ce_itens_nf.aliq_icms%type,
                             p_vl_opr        tvalor2,
                             p_vl_bc_icms    tvalor2,
                             p_vl_icms       tvalor2,
                             p_vl_bc_icms_st tvalor2,
                             p_vl_icms_st    tvalor2,
                             p_vl_red_bc     tvalor2,
                             p_cod_obs       tstr10);
  procedure pl_registro_c601;
  procedure pl_registro_c610;
  procedure pl_registro_c620;
  procedure pl_registro_c690;
  procedure pl_registro_c790;

  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO C100
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_c100 is
    /*
    REGISTRO C100: NOTA FISCAL (CODIGO 01), NOTA FISCAL AVULSA (CODIGO 1B), NOTA FISCAL DE PRODUTOR (CODIGO 04) E NFE (CODIGO 55)
    N?    Campo       Descric?o                                     Tipo  Tam Dec
    01  REG       Texto fixo contendo "C100"                          C     004   -
    02  IND_OPER      Indicador do tipo de operac?o:                        C     001   -
                  0. Entrada;
                  1. Saida
    03  IND_EMIT      Indicador do emitente do documento fiscal:                  C     001   -
                  0- Emiss?o propria;
                  1- Terceiros
    04  COD_PART      Codigo do participante (campo 02 do Registro 0150):           C     -   -
                  - do emitente do documento ou do remetente das mercadorias,
                    no caso de entradas;
                  - do adquirente, no caso de saidas
    05  COD_MOD     Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1     C     002   -
    06  COD_SIT     Codigo da situac?o do documento fiscal, conforme a Tabela 4.1.2 N     002   -
    07  SER       Serie do documento fiscal                             N     002   -
    08  NUM_DOC     Numero do documento fiscal                          N     -   -
    09  CHV_NFE     Chave da Nota Fiscal Eletronica                         N     044   -
    10  DT_DOC      Data da emiss?o do documento fiscal                     N     008   -
    11  DT_E_S      Data da entrada ou da saida                           N     008   -
    12  VL_DOC      Valor total do documento fiscal                         N     -   02
    13  IND_PGTO      Indicador do tipo de pagamento:                       C     001   -
                  0. A vista;
                  1. A prazo;
                  9. Sem pagamento.
    14  VL_DESC     Valor total do desconto                             N     -   02
    15  VL_ABAT_NT    Abatimento n?o tributado e n?o comercial                  N     -   02
                  Ex. desconto ICMS nas remessas para ZFM.
    16  VL_MERC     Valor das mercadorias constantes no documento fiscal          N     -   02
    17  IND_FRT     Indicador do tipo do frete:                           C     001   -
                  0. Por conta de terceiros;
                  1. Por conta do emitente;
                  2. Por conta do destinatario;
                  9. Sem frete
    18  VL_FRT      Valor do frete indicado no documento fiscal                 N     -   02
    19  VL_SEG      Valor do seguro indicado no documento fiscal              N     -   02
    20  VL_OUT_DA   Valor de outras despesas acessorias                     N     -   02
    21  VL_BC_ICMS    Valor da base de calculo do ICMS                      N     -   02
    22  VL_ICMS     Valor do ICMS                                     N     -   02
    23  VL_BC_ICMS_ST Valor da base de calculo do ICMS substituic?o tributaria      N     -   02
    24  VL_ICMS_ST    Valor do ICMS retido por substituic?o tributaria            N     -   02
    25  VL_IPI      Valor total do IPI                                N     -   02
    26  VL_PIS      Valor total do PIS                                N     -   02
    27  VL_COFINS   Valor total da COFINS                               N     -   02
    28  VL_PIS_ST   Valor total do PIS retido por substituic?o tributaria         N     -   02
    29  VL_COFINS_ST  Valor total da COFINS retido por substituic?o tributaria        N     -   02
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
    */
  
    cursor cr is
    
      select '0' ind_oper, --entrada
             '1' ind_emit, --terceiros
             to_char(n.dt_entrada, 'ddmmrrrr') dt_e_s,
             n.num_nota num_doc,
             n.cod_fornec cod_part,
             n.tipo_doc tipo_doc,
             fs_sped_utl.fb_cd_doctos(n.tipo_doc) cod_mod,
             fs_sped_utl.fb_situacao_docto(n.cod_cfo, n.situacao_nf) cod_sit,
             n.sr_nota ser,
             null chv_nfe,
             to_char(n.dt_emissao, 'ddmmrrrr') dt_doc,
             n.vlr_nota vl_doc,
             fs_sped_utl.fb_ind_pgto(n.cod_condpag) ind_pgto,
             sum(nvl(i.vl_desconto, 0)) vl_desc,
             0 vl_abat_nt,
             sum(i.valor_unit - nvl(i.vl_desconto, 0)) vl_merc,
             fs_sped_utl.fb_ind_frt(n.situacao_frete) ind_frt,
             sum(nvl(i.vl_frete, 0)) vl_frt,
             0 vl_seg,
             (nvl(n.vlr_despesa, 0)) vl_out_da,
             sum(nvl(i.vl_bicms, 0)) vl_bc_icms,
             sum(nvl(i.vl_icms, 0)) vl_icms,
             sum(nvl(0, 0)) vl_bc_icms_st, -- verificar
             sum(nvl(0, 0)) vl_icms_st, --verificar
             sum(nvl(i.vl_ipi, 0)) vl_ipi,
             (nvl(n.vlr_pis_ret, 0)) vl_pis,
             (nvl(n.vl_cofins, 0)) vl_cofins,
             sum(nvl(0, 0)) vl_pis_st, -- verificar
             sum(nvl(0, 0)) vl_cofins_st,
             'R' origem,
             n.empresa,
             n.filial,
             n.parte,
             (n.vlr_nota - nvl(vlr_deduz, 0)) vl_base_serv,
             nvl(vlr_ir, 0) vl_irrf,
             nvl(n.vlr_iss, 0) vl_issqn,
             0 vl_base_prev,
             0 vl_prev,
             null placa,
             to_number(null) qtd_vol,
             to_number(null) peso_brt,
             to_number(null) peso_liq,
             'E' natureza,
             n.cod_cfo cod_cfo,
             n.dt_emissao dt_ref,
             0 num_pedido,
             n.uf_nota uf
        from ce_notas n, ce_itens_nf i
       where i.empresa = n.empresa
         and i.filial = n.filial
         and i.num_nota = n.num_nota
         and i.sr_nota = n.sr_nota
         and i.cod_fornec = n.cod_fornec
         and i.parte = n.parte
         and n.empresa = vg_emp
         and n.filial = vg_fil
         and n.tipo_doc = 3 -- somente notas fiscais
         and n.dt_entrada between vg_inic and vg_final
         and n.cod_cfo not in (select cod_cfo
                                 from fs_cfos_sintegra
                                where ((registro = 50 and tipo_reg = 'T') --or
                                      --(registro = 70 and tipo_reg = 'O')
                                      ))
       group by n.cod_fornec,
                n.tipo_doc,
                n.cod_cfo,
                n.situacao_nf,
                n.situacao_frete,
                n.sr_nota,
                n.num_nota,
                n.dt_emissao,
                n.dt_entrada,
                n.vlr_nota,
                n.cod_condpag,
                n.vlr_despesa,
                n.vlr_pis_ret,
                n.vl_cofins,
                n.empresa,
                n.filial,
                n.parte,
                (n.vlr_nota - nvl(vlr_deduz, 0)),
                nvl(vlr_ir, 0),
                nvl(n.vlr_iss, 0),
                n.uf_nota
      
      union
      select '0' ind_oper, --entrada
             '1' ind_emit, --terceiros
             to_char(n.dt_entrada, 'ddmmrrrr') dt_e_s,
             n.num_nota num_doc,
             n.cod_fornec cod_part,
             n.tipo_doc tipo_doc,
             fs_sped_utl.fb_cd_doctos(n.tipo_doc) cod_mod,
             fs_sped_utl.fb_situacao_docto(n.cod_cfo, n.situacao_nf) cod_sit,
             n.sr_nota ser,
             null chv_nfe,
             to_char(n.dt_emissao, 'ddmmrrrr') dt_doc,
             n.vlr_nota vl_doc,
             fs_sped_utl.fb_ind_pgto(n.cod_condpag) ind_pgto,
             0 vl_desc,
             0 vl_abat_nt,
             n.vlr_nota vl_merc,
             fs_sped_utl.fb_ind_frt(n.situacao_frete) ind_frt,
             0 vl_frt,
             0 vl_seg,
             (nvl(n.vlr_despesa, 0)) vl_out_da,
             (nvl(n.vlr_bicms, 0)) vl_bc_icms,
             (nvl(n.vlr_icms, 0)) vl_icms,
             0 vl_bc_icms_st, -- verificar
             0 vl_icms_st, --verificar
             0 vl_ipi,
             (nvl(n.vlr_pis_ret, 0)) vl_pis,
             (nvl(n.vl_cofins, 0)) vl_cofins,
             0 vl_pis_st, -- verificar
             0 vl_cofins_st,
             'R' origem,
             n.empresa,
             n.filial,
             n.parte,
             (n.vlr_nota - nvl(vlr_deduz, 0)) vl_base_serv,
             nvl(vlr_ir, 0) vl_irrf,
             nvl(n.vlr_iss, 0) vl_issqn,
             0 vl_base_prev,
             0 vl_prev,
             null placa,
             to_number(null) qtd_vol,
             to_number(null) peso_brt,
             to_number(null) peso_liq,
             'E' natureza,
             n.cod_cfo cod_cfo,
             n.dt_emissao dt_ref,
             0 num_pedido,
             n.uf_nota uf
        from ce_notas n
       where not exists
       (select 1
                from ce_itens_nf i
               where i.empresa = n.empresa
                 and i.filial = n.filial
                 and i.num_nota = n.num_nota
                 and i.sr_nota = n.sr_nota
                 and i.cod_fornec = n.cod_fornec
                 and i.parte = n.parte)
         and n.empresa = vg_emp
         and n.filial = vg_fil
         and n.tipo_doc = 3 -- somente notas fiscais
         and n.dt_entrada between vg_inic and vg_final
         and n.cod_cfo not in
             (select cod_cfo
                from fs_cfos_sintegra
               where (registro = 50 and tipo_reg = 'T'))
            
         and n.cod_cfo not in
             (select cod_cfo from fs_cfos_sintegra where registro = 70
              
              )
      
      union
      select case
               when o.natureza = 'E' then
                '0'
               else
                '1'
             end ind_oper, --entrada
             '0' ind_emit, --terceiros
             to_char(n.dt_entsai, 'ddmmrrrr') dt_e_s,
             n.num_nota num_doc,
             n.firma cod_part,
             3 tipo_doc,
             fs_sped_utl.fb_cd_doctos(3) cod_mod,
             fs_sped_utl.fb_situacao_docto(n.cod_cfo, n.status) cod_sit,
             n.sr_nota ser,
             null chv_nfe,
             to_char(n.dt_emissao, 'ddmmrrrr') dt_doc,
             n.vl_total vl_doc,
             fs_sped_utl.fb_ind_pgto(n.cod_condpag) ind_pgto,
             nvl(n.vl_desconto, 0) vl_desc,
             0 vl_abat_nt,
             n.vl_produtos vl_merc,
             fs_sped_utl.fb_ind_frt(n.tp_frete) ind_frt,
             nvl(n.vl_frete, 0) vl_frt,
             0 vl_seg,
             (nvl(n.vl_outros, 0)) vl_out_da,
             sum(nvl(i.vl_bicms, 0)) vl_bc_icms,
             sum(nvl(i.vl_icms, 0)) vl_icms,
             sum(nvl(0, 0)) vl_bc_icms_st, -- verificar
             sum(nvl(0, 0)) vl_icms_st, --verificar
             sum(nvl(i.vl_ipi, 0)) vl_ipi,
             (nvl(n.vl_pis, 0)) vl_pis,
             (nvl(n.vl_cofins, 0)) vl_cofins,
             sum(nvl(0, 0)) vl_pis_st, -- verificar
             sum(nvl(0, 0)) vl_cofins_st,
             'f' origem,
             n.empresa,
             n.filial,
             n.parte,
             (n.vl_total - nvl(vlr_deduz, 0)) vl_base_serv,
             0 vl_irrf,
             nvl(n.vl_iss, 0) vl_issqn,
             0 vl_base_prev,
             0 vl_prev,
             n.placa_veic placa,
             n.vol_qtd qtd_vol,
             n.peso_bruto peso_brt,
             n.peso_liquido peso_liq,
             o.natureza,
             n.cod_cfo cod_cfo,
             n.dt_entsai dt_ref,
             n.num_pedido num_pedido,
             n.ent_uf uf
        from ft_oper o, ft_notas n, ft_itens_nf i
       where o.cod_oper = n.cod_oper
         and o.empresa = n.empresa
         and i.empresa = n.empresa
         and i.filial = n.filial
         and i.num_nota = n.num_nota
         and i.sr_nota = n.sr_nota
         and i.parte = n.parte
         and n.empresa = vg_emp
         and n.filial = vg_fil
         and n.dt_entsai between vg_inic and vg_final
      
       group by o.natureza,
                n.firma,
                n.cod_cfo,
                n.status,
                n.tp_frete,
                n.sr_nota,
                n.num_nota,
                n.dt_emissao,
                n.dt_entsai,
                n.vl_total,
                n.vl_produtos,
                n.cod_condpag,
                n.vl_frete,
                n.vl_desconto,
                n.vl_outros,
                n.vl_pis,
                n.vl_cofins,
                n.empresa,
                n.filial,
                n.parte,
                (n.vl_total - nvl(vlr_deduz, 0)),
                nvl(n.vl_iss, 0),
                n.placa_veic,
                n.vol_qtd,
                n.peso_bruto,
                n.peso_liquido,
                o.natureza,
                n.num_pedido,
                n.ent_uf
       order by 1, 3, 4;
  
    v_sub tnum1;
  
  begin
  
    vg_msg := 'C100';
  
    for reg in cr loop
      vg_msg      := 'C100';
      vg_registro := 'C100';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || reg.ind_oper || vg_sep;
      vg_linha    := vg_linha || reg.ind_emit || vg_sep;
      vg_linha    := vg_linha || reg.cod_part || vg_sep;
      vg_linha    := vg_linha || reg.cod_mod || vg_sep;
      vg_linha    := vg_linha || reg.cod_sit || vg_sep;
      vg_linha    := vg_linha || reg.ser || vg_sep;
      --      vg_msg := 'a';
      vg_linha := vg_linha || reg.num_doc || vg_sep;
      vg_linha := vg_linha || reg.chv_nfe || vg_sep;
      vg_linha := vg_linha || reg.dt_doc || vg_sep;
      vg_linha := vg_linha || reg.dt_e_s || vg_sep;
      vg_linha := vg_linha || reg.vl_doc || vg_sep;
      vg_linha := vg_linha || reg.ind_pgto || vg_sep;
      vg_linha := vg_linha || reg.vl_desc || vg_sep;
      vg_linha := vg_linha || reg.vl_abat_nt || vg_sep;
      vg_linha := vg_linha || reg.vl_merc || vg_sep;
      vg_linha := vg_linha || reg.ind_frt || vg_sep;
      vg_linha := vg_linha || reg.vl_frt || vg_sep;
      vg_linha := vg_linha || reg.vl_seg || vg_sep;
      vg_linha := vg_linha || reg.vl_out_da || vg_sep;
      vg_linha := vg_linha || reg.vl_bc_icms || vg_sep;
      vg_linha := vg_linha || reg.vl_icms || vg_sep;
      vg_linha := vg_linha || reg.vl_bc_icms_st || vg_sep;
      vg_linha := vg_linha || reg.vl_icms_st || vg_sep;
      vg_linha := vg_linha || reg.vl_ipi || vg_sep;
      vg_linha := vg_linha || reg.vl_pis || vg_sep;
      vg_linha := vg_linha || reg.vl_cofins || vg_sep;
      vg_linha := vg_linha || reg.vl_pis_st || vg_sep;
      vg_linha := vg_linha || reg.vl_cofins_st || vg_sep || vg_crlf;
    
      --/
      pl_gera_linha;
      --/
      if reg.origem = 'F' then
        vg_msg := 'C110';
        pl_registro_c110(reg.empresa,
                         reg.filial,
                         reg.num_doc,
                         reg.ser,
                         v_sub,
                         reg.parte,
                         reg.ind_oper,
                         reg.ind_emit,
                         reg.cod_part,
                         reg.cod_mod,
                         reg.dt_doc);
      
      end if;
      --/
      if nvl(reg.num_pedido, 0) > 0 and reg.uf = 'EX' then
        --/ IMPORTAC?O
        vg_msg := 'C120';
      
        pl_registro_c120(reg.num_pedido, reg.vl_pis, reg.vl_cofins);
      
      end if;
      --/
      --/ se for servico e tiver iss ou imposto renda
      if nvl(reg.vl_issqn, 0) + nvl(reg.vl_irrf, 0) > 0 then
        vg_msg := 'C130';
        pl_registro_c130(reg.vl_doc,
                         reg.vl_base_serv,
                         reg.vl_issqn,
                         reg.vl_doc,
                         reg.vl_irrf,
                         reg.vl_base_prev,
                         reg.vl_prev);
      end if;
      --/
      vg_msg := 'C140';
      pl_registro_c140(reg.empresa,
                       reg.filial,
                       reg.cod_part,
                       reg.ser,
                       reg.num_doc,
                       reg.parte,
                       reg.ind_emit);
      --/
      vg_msg := 'C150';
      pl_registro_c150;
      --/
      vg_msg := 'C160';
      if (nvl(reg.qtd_vol, 0) > 0 or nvl(reg.peso_brt, 0) > 0) then
        pl_registro_c160(reg.cod_part,
                         reg.placa,
                         reg.qtd_vol,
                         reg.peso_brt,
                         reg.peso_liq);
      end if;
      --/
      vg_msg := 'C165';
      pl_registro_c165;
      --/
      vg_msg := 'C170';
      pl_registro_c170(reg.empresa,
                       reg.filial,
                       reg.cod_part,
                       reg.ser,
                       reg.num_doc,
                       reg.parte,
                       reg.ind_emit);
      --/
      vg_msg := 'C190'; --substituic?o tributaria
      pl_registro_c190('ICMS',
                       reg.empresa,
                       reg.filial,
                       reg.cod_part,
                       reg.natureza,
                       reg.num_doc,
                       reg.ser,
                       reg.tipo_doc,
                       reg.cod_cfo,
                       reg.dt_ref);
      --/
      vg_msg := 'C195';
      pl_registro_c195;
      --/
    
    end loop;
  
  end;
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO C110
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_c110(pl_emp      ft_notas.empresa%type,
                             pl_fil      ft_notas.filial%type,
                             pl_nota     ft_notas.num_nota%type,
                             pl_sr       ft_notas.sr_nota%type,
                             pl_sub      tnum1,
                             pl_par      ft_notas.parte%type,
                             pl_ind_oper tnum1,
                             pl_ind_emit tnum1,
                             pl_cod_part cd_firmas.firma%type,
                             pl_cod_mod  tstr2,
                             pl_dt_doc   tstr10) is
    /*
    REGISTRO C110: INFORMAC?O COMPLEMENTAR DA NOTA FISCAL (CODIGO 01; 1B e 55)
    N?    Campo     Descric?o                                                 Tipo  Tam Dec
    01  REG       Texto fixo contendo "C110"                                      C     004   -
    02  COD_INF     Codigo da informac?o complementar do documento fiscal (campo 02 do Registro 0450)   C     -   -
    03  TXT_COMPL   Descric?o complementar do codigo de referencia.                         C     -   -
    Observac?es: Campo 03: utilizado para complementar informac?es e ou observac?es cujo codigo e
                           de informac?o generica.
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
    cursor cr is
      select distinct to_char(a.cod_msg) cod_inf
        from ft_icms_msg a, ft_icms_ctl b, ft_itens_nf c, ft_notas d
       where a.cod_icms = b.cod_icms
         and b.produto = c.produto
         and b.empresa = c.empresa
         and b.cod_cfo = c.cod_cfo
         and b.uf_destino = d.ent_uf
         and d.empresa = c.empresa
         and d.filial = c.filial
         and d.num_nota = c.num_nota
         and d.sr_nota = c.sr_nota
         and d.parte = c.parte
         and c.empresa = pl_emp
         and c.filial = pl_fil
         and c.num_nota = pl_nota
         and c.sr_nota = pl_sr;
  
    v_txt varchar2(1000);
  
  begin
    for reg in cr loop
      vg_registro := 'C110';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || reg.cod_inf || vg_sep;
      vg_linha    := vg_linha || v_txt || vg_sep || vg_crlf;
      --/
      pl_gera_linha;
      --/
      pl_registro_c111(reg.cod_inf); -- verificar
      --/
      pl_registro_c112; -- verificar
    --/
    end loop;
    --/
    vg_msg := 'C113';
    pl_registro_c113(pl_ind_oper,
                     pl_ind_emit,
                     pl_cod_part,
                     pl_cod_mod,
                     pl_sr,
                     pl_sub,
                     pl_nota,
                     pl_dt_doc);
  
    --/
    vg_msg := 'C114';
    pl_registro_c114; -- somente a chamada n?o esta implementada
  
    --/ verificar se nao eh somente para transportadoras
    vg_msg := 'C115';
    pl_registro_c115(pl_emp, pl_fil, pl_cod_part, pl_sr, pl_nota, pl_par);
  
  end;
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO C111
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_c111(p_cod ft_icms_msg.cod_msg%type) is
    /*
    REGISTRO C111: PROCESSO REFERENCIADO
    N?    Campo     Descric?o                       Tipo  Tam Dec
    01  REG       Texto fixo contendo "C111"            C     004   -
    02  NUM_PROC  Identificac?o do processo ou ato concessorio  C     -   -
    03  IND_PROC  Indicador da origem do processo:          C     001   -
        0. Sefaz;
        1. Justica Federal;
        2. Justica Estadual;
        3. Secex/RFB;
        9. Outros.
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    --verificar como gerar esta informac?o
    vg_registro := 'C111';
  end;
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO C112
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_c112 is
    /*
    REGISTRO C112: DOCUMENTO DE ARRECADAC?O REFERENCIADO
    N?    Campo   Descric?o                           Tipo  Tam Dec
    01  REG   Texto fixo contendo "C112"                C     004   -
    02  COD_DA  Codigo do modelo do documento de arrecadac?o:   C     001   -
              0. documento estadual de arrecadac?o
              1. GNRE
    03  UF      Unidade federada beneficiaria do recolhimento     C     002   -
    04  NUM_DA  Numero do documento de arrecadac?o            C     -   -
    05  COD_AUT Codigo completo da autenticac?o bancaria        C     -   -
    06  VL_DA   Valor do total do documento de arrecadac?o      N     -   02
              (principal, atualizac?o monetaria, juros e multa)
    07  DT_VCTO Data de vencimento do documento de arrecadac?o    N     008   -
    08  DT_PGTO Data de pagamento do documento de arrecadac?o,    N     008   -
              ou data do vencimento, no caso de ICMS antecipado
              a recolher.
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
     */
  begin
    --verificar como gerar esta informac?o
    vg_registro := 'C112';
  end;
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO C113
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_c113(p_ind_oper tnum1,
                             p_ind_emit tnum1,
                             p_cod_part cd_firmas.firma%type,
                             p_cod_mod  tstr2,
                             p_ser      ft_notas.sr_nota%type,
                             p_sub      tnum1,
                             p_num_doc  ft_notas.num_nota%type,
                             p_dt_doc   tstr10) is
    /*
    REGISTRO C113: DOCUMENTO FISCAL REFERENCIADO
    N?    Campo   Descric?o                             Tipo  Tam Dec
    01  REG   Texto fixo contendo "C113"                  C     004   -
    02  IND_OPER  Indicador do tipo de operac?o:                C     001   -
              0. Entrada/aquisic?o;
              1. Saida/prestac?o
    03  IND_EMIT  Indicador do emitente do titulo:                C     001   -
              0. Emiss?o propria;
              1. Terceiros
    04  COD_PART  Codigo do participante emitente                 C     -   -
              (campo 02 do Registro 0150)
              do documento referenciado.
    05  COD_MOD Codigo do documento fiscal, conforme a Tabela 4.1.1   C     002   -
    06  SER   Serie do documento fiscal                     C     -   -
    07  SUB   Subserie do documento fiscal                  N     -   -
    08  NUM_DOC Numero do documento fiscal                  N     -   -
    09  DT_DOC  Data da emiss?o do documento fiscal.            N     008   -
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C113';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || p_ind_oper || vg_sep;
    vg_linha    := vg_linha || p_ind_emit || vg_sep;
    vg_linha    := vg_linha || p_cod_part || vg_sep;
    vg_linha    := vg_linha || p_ser || vg_sep;
    vg_linha    := vg_linha || p_sub || vg_sep;
    vg_linha    := vg_linha || p_num_doc || vg_sep;
    vg_linha    := vg_linha || p_dt_doc || vg_sep || vg_crlf;
    --/
    pl_gera_linha;
    --/
  end;
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO C114
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_c114 is
    /*
    REGISTRO C114: CUPOM FISCAL REFERENCIADO
    N?    Campo     Descric?o                     Tipo  Tam Dec
    01  REG       Texto fixo contendo "C114"          C     004   -
    02  COD_MOD     Codigo do modelo do documento fiscal,
                      conforme a tabela indicada no item 4.1.1  C     002   -
    03  ECF_FAB     Numero de serie de fabricac?o do ECF    C     -   -
    04  ECF_CX    Numero do caixa atribuido ao ECF      N     -   -
    05  NUM_DOC     Numero do documento fiscal          N     -    -
    06  DT_DOC    Data da emiss?o do documento fiscal     N     008   -
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    null;
  end;
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO C115  *** verificar se n?o e somente para empresas transportadoras
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_c115(pl_emp      ft_notas.empresa%type,
                             pl_fil      ft_notas.filial%type,
                             pl_cod_part cd_firmas.firma%type,
                             pl_sr       ft_notas.sr_nota%type,
                             pl_nota     ft_notas.num_nota%type,
                             pl_par      ft_notas.parte%type) is
    /*
    REGISTRO C115: LOCAL DA COLETA E ENTREGA (CODIGO 01, 1B E 04)
    N?  Campo         Descric?o                               Tipo  Tam Dec
    01  REG         Texto fixo contendo "C115"                    C     004   -
    02  IND_CARGA     Indicador do tipo de transporte da carga coletada:      N     001   -
                  0. Rodoviario;
                  1. Ferroviario;
                  2. Rodo-Ferroviario;
                  3. Aquaviario;
                  4. Dutoviario;
                  5. Aereo;
                  9. Outros.
    03  CNPJ_COL    Numero do CNPJ do contribuinte do local de coleta       N     014   -
    04  IE_COL      Inscric?o Estadual do contribuinte do local de coleta   C     -   -
    05  CPF_COL       CPF do contribuinte do local de coleta das mercadorias. N     011   -
    06  COD_MUN_COL   Codigo do Municipio do local de coleta            N     007   -
    07  CNPJ_ENTG     Numero do CNPJ do contribuinte do local de entrega    N     014   -
    08  IE_ENTG       Inscric?o Estadual do contribuinte do local de entrega  C     -   -
    09  CPF_ENTG    Cpf do contribuinte do local de entrega             N     011   -
    10  COD_MUN_ENTG  Codigo do Municipio do local de entrega           N     007   -
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
    cursor cr is
      select '0' ind_carga,
             
             n.ent_ender,
             n.ent_compl,
             n.ent_bairro,
             n.ent_cidade,
             n.ent_uf,
             n.ent_pais,
             replace(n.ent_cep, '-', '') ent_cep,
             f.natureza,
             replace(f.iest, '.', '') ie,
             n.ent_cidade cod_mun, -- mudar para funcao que traz codigo ibge
             case
               when f.natureza = 'J' then
                lpad(replace(replace(replace(f.cgc_cpf, '.', ''), '/', ''),
                             '-',
                             ''),
                     14,
                     '0')
               else
                lpad(replace(replace(replace(f.cgc_cpf, '.', ''), '/', ''),
                             '-',
                             ''),
                     11,
                     '0')
             end cnpj_cpf
        from cd_firmas f, ft_notas n
       where f.firma = n.firma
         and n.empresa = pl_emp
         and n.filial = pl_fil
         and n.num_nota = pl_nota
         and n.sr_nota = pl_sr
         and n.parte = pl_par;
  
    v_cnpj varchar2(14);
  
    v_cpf varchar2(11);
  begin
  
    return;
    /*
    vg_registro  := 'C115';
    for reg in cr loop
       if reg.natureza = 'J' then
         v_cnpj := reg.cnpj_cpf;
         v_cpf := null;
       else
         v_cnpj := null;
         v_cpf  := reg.cnpj_cpf;
       end if;
      vg_linha := vg_sep   || vg_registro    || vg_sep;
      vg_linha := vg_linha || null          || vg_sep;     --coleta
      vg_linha := vg_linha || null          || vg_sep;
      vg_linha := vg_linha || null          || vg_sep;
      vg_linha := vg_linha || v_cnpj        || vg_sep;
      vg_linha := vg_linha || reg.ie        || vg_sep;
      vg_linha := vg_linha || v_cpf         || vg_sep;
      vg_linha := vg_linha || reg.cod_mun     || vg_sep || vg_crlf;
      --/
      pl_gera_linha;
      --/
    end loop;
    */
  end;
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO C120   OPERAC?ES DE IMPORTAC?O
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_c120(p_ped ft_pedidos.num_pedido%type,
                             p_pis tvalor2,
                             p_cof tvalor2) is
    /*
    REGISTRO C120: OPERAC?ES DE IMPORTAC?O (CODIGO 01)
    N?    Campo       Descric?o                     Tipo  Tam Dec
    01  REG         Texto fixo contendo "C120"          C     004   -
    02  COD_DOC_IMP   Documento de importac?o:            C     001   -
                  0. Declarac?o de Importac?o;
                  1. Declarac?o Simplificada de Importac?o.
    03  NUM_DOC__IMP  Numero do documento de Importac?o.      C     -   -
    04  PIS_IMP       Valor pago de PIS na importac?o         N     -   02
    05  COFINS_IMP    Valor pago de COFINS na importac?o      N     -   02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
    cursor cr is
      select nro_di, dt_di, tipo_di
        from ft_pedidos a
       where empresa = vg_emp
         and filial = vg_fil
         and num_pedido = p_ped
         and nro_di is not null;
  
    v_nro_di  ft_pedidos.nro_di%type;
    v_dt_di   date;
    v_tipo_di ft_pedidos.tipo_di%type;
  
  begin
    open cr;
    fetch cr
      into v_nro_di, v_dt_di, v_tipo_di;
    close cr;
  
    if v_nro_di is not null then
    
      vg_registro := 'C120';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || v_tipo_di || vg_sep;
      vg_linha    := vg_linha || v_nro_di || vg_sep;
      vg_linha    := vg_linha || p_pis || vg_sep;
      vg_linha    := vg_linha || p_cof || vg_sep || vg_crlf;
      --
      pl_gera_linha;
      --
    end if;
  end;
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO C130   ISSQN, IRRF E PREVIDENCIA SOCIAL
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_c130(p_vl_serv_nt  number,
                             p_vl_bc_issqn number,
                             p_vl_issqn    number,
                             p_vl_bc_irrf  number,
                             p_vl_irrf     number,
                             p_vl_bc_prev  number,
                             p_vl_prev     number) is
    /*
    REGISTRO C130: ISSQN, IRRF E PREVIDENCIA SOCIAL
    N?    Campo       Descric?o                   Tipo  Tam Dec
    01  REG         Texto fixo contendo "C130"        C     004   -
    02  VL_SERV_NT    Valor dos servicos sob n?o-incidencia   N     -   02
                  ou n?o-tributados pelo ICMS
    03  VL_BC_ISSQN   Valor da base de calculo do ISSQN     N     -   02
    04  VL_ISSQN    Valor do ISSQN                N     -   02
    05  VL_BC_IRRF    Valor da base de calculo do         N     -   02
                  Imposto de Renda Retido na Fonte
    06  VL_IRRF       Valor do Imposto de Renda -         N     -   02
                  Retido na Fonte
    07  VL_BC_PREV    Valor da base de calculo de retenc?o    N     -   02
                  da Previdencia Social
    08  VL_PREV       Valor destacado para retenc?o da    N     -   02
                  Previdencia Social
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
  begin
  
    vg_registro := 'C130';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || p_vl_serv_nt || vg_sep;
    vg_linha    := vg_linha || p_vl_bc_issqn || vg_sep;
    vg_linha    := vg_linha || p_vl_issqn || vg_sep;
    vg_linha    := vg_linha || p_vl_bc_irrf || vg_sep;
    vg_linha    := vg_linha || p_vl_irrf || vg_sep;
    vg_linha    := vg_linha || p_vl_bc_prev || vg_sep;
    vg_linha    := vg_linha || p_vl_prev || vg_sep || vg_crlf;
    --
    pl_gera_linha;
    --
  
  end;
  ----------------------------------------------------------------------------------------------------------------
  -- REGISTRO C140  FATURA (CODIGO 01)
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_c140(pl_emp      ft_notas.empresa%type,
                             pl_fil      ft_notas.filial%type,
                             pl_cod_part cd_firmas.firma%type,
                             pl_sr       ft_notas.sr_nota%type,
                             pl_nota     ft_notas.num_nota%type,
                             pl_par      ft_notas.parte%type,
                             pl_ind_emit tnum1) is
    /*
    REGISTRO C140: FATURA (CODIGO 01)
    N?    Campo       Descric?o                             Tipo  Tam Dec
    01  REG         Texto fixo contendo "C140"                  C     004   -
    02  IND_EMIT    Indicador do emitente do titulo:              C     001   -
                  0- Emiss?o propria;
                  1- Terceiros
    03  IND_TIT       Indicador do tipo de titulo de credito:
                  00- Duplicata;
                  01- Cheque;
                  02- Promissoria;
                  03- Recibo;
                  99- Outros (descrever)                      C     002   -
    04  DESC_TIT    Descric?o complementar do titulo de credito         C     -   -
    05  NUM_TIT       Numero ou codigo identificador do titulo de credito   C     -   -
    06  QTD_PARC    Quantidade de parcelas a receber/pagar          N     -   -
    07  VL_TIT      Valor original do titulo de credito             N     -   02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
    -- emitente 0
    cursor cr0 is
      select a.tipo_tit,
             a.descricao desc_tit,
             b.num_nota,
             to_char(b.dt_vence, 'ddmmrrrr') dt_vence,
             b.valor vl_parc,
             sum(sum(b.valor)) over() tot_fat,
             count(count(b.num_nota)) over() qtd_parc
        from fn_tipos_tit a, ft_parc_nf b, ft_notas c
       where a.tipo_tit = c.tipo_tit
         and b.empresa = c.empresa
         and b.filial = c.filial
         and b.num_nota = c.num_nota
         and b.sr_nota = c.sr_nota
         and b.parte = c.parte
         and c.empresa = pl_emp
         and c.filial = pl_fil
         and c.sr_nota = pl_sr
         and c.parte = pl_par
         and c.num_nota = pl_nota
       group by a.tipo_tit, b.dt_vence, a.descricao, b.num_nota, b.valor;
  
    -- emitente 1
    cursor cr1 is
      select a.tipo_tit,
             a.descricao desc_tit,
             b.num_nota,
             to_char(b.dt_vencto, 'ddmmrrrr') dt_vence,
             b.parcela,
             b.vlr_parcela vl_parc,
             sum(sum(b.vlr_parcela)) over() tot_fat,
             count(count(b.num_nota)) over() qtd_parc
        from fn_tipos_tit a, ce_parc_nf b, ce_notas c
       where a.tipo_tit = c.tipo_tit
         and b.empresa = c.empresa
         and b.filial = c.filial
         and b.num_nota = c.num_nota
         and b.sr_nota = c.sr_nota
         and b.cod_fornec = c.cod_fornec
         and b.parte = c.parte
         and c.empresa = pl_emp
         and c.filial = pl_fil
         and c.cod_fornec = pl_cod_part
         and c.sr_nota = pl_sr
         and c.parte = pl_par
         and c.num_nota = pl_nota
       group by a.tipo_tit,
                a.descricao,
                b.num_nota,
                b.parcela,
                b.dt_vencto,
                b.vlr_parcela;
  
    v_ind_tit tstr2;
    v_parc    number(3) := 0;
  
  begin
    vg_registro := 'C140';
  
    if pl_ind_emit = 0 then
      -- emitente
      for reg in cr0 loop
        if v_parc = 0 then
          v_ind_tit := fs_sped_utl.fb_ind_tit(reg.tipo_tit);
          vg_linha  := vg_sep || vg_registro || vg_sep;
          vg_linha  := vg_linha || pl_ind_emit || vg_sep;
          vg_linha  := vg_linha || v_ind_tit || vg_sep;
          vg_linha  := vg_linha || reg.desc_tit || vg_sep;
          vg_linha  := vg_linha || pl_nota || vg_sep;
          vg_linha  := vg_linha || reg.qtd_parc || vg_sep;
          vg_linha  := vg_linha || reg.tot_fat || vg_sep || vg_crlf;
          --/
          pl_gera_linha;
          --/
        end if;
      
        v_parc := v_parc + 1;
      
        pl_registro_c141(v_parc, reg.dt_vence, reg.vl_parc);
      
      end loop;
    else
      for reg in cr1 loop
        if v_parc = 0 then
          v_ind_tit := fs_sped_utl.fb_ind_tit(reg.tipo_tit);
          vg_linha  := vg_sep || vg_registro || vg_sep;
          vg_linha  := vg_linha || pl_ind_emit || vg_sep;
          vg_linha  := vg_linha || v_ind_tit || vg_sep;
          vg_linha  := vg_linha || reg.desc_tit || vg_sep;
          vg_linha  := vg_linha || pl_nota || vg_sep;
          vg_linha  := vg_linha || reg.qtd_parc || vg_sep;
          vg_linha  := vg_linha || reg.tot_fat || vg_sep || vg_crlf;
          --/
          pl_gera_linha;
          --/
        end if;
      
        v_parc := reg.parcela;
      
        pl_registro_c141(v_parc, reg.dt_vence, reg.vl_parc);
        --/
      end loop;
    end if;
  end;
  ----------------------------------------------------------------------------------------------------------------
  --REGISTRO C141: VENCIMENTO DA FATURA (CODIGO 01)
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_c141(p_parc ce_parc_nf.parcela%type,
                             p_dt   tstr10,
                             p_vl   tvalor2) is
    /*
    REGISTRO C141: VENCIMENTO DA FATURA (CODIGO 01)
    N?     Campo    Descric?o               Tipo  Tam Dec
    01  REG     Texto fixo contendo "C141"      C   004   -
    02  NUM_PARC  Numero da parcela a receber/pagar   N   -   -
    03  DT_VCTO   Data de vencimento da parcela     N   008   -
    04  VL_PARC   Valor da parcela a receber/pagar    N   -   02
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C141';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || p_parc || vg_sep;
    vg_linha    := vg_linha || p_dt || vg_sep;
    vg_linha    := vg_linha || p_vl || vg_sep || vg_crlf;
    --/
    pl_gera_linha;
    --/
  end;
  ----------------------------------------------------------------------------------------------------------------
  --REGISTRO C150: COMPLEMENTO DO DOCUMENTO - DADOS ADICIONAIS (CODIGO 01)
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_c150 is
    /*
    REGISTRO C150: COMPLEMENTO DO DOCUMENTO - DADOS ADICIONAIS (CODIGO 01)
    N?    Campo   Descric?o                           Tipo  Tam Dec
    01  REG     Texto fixo contendo "C150"                C     004   -
    02  VL_FCP  Valor do ICMS resultante da aliquota adicional
              dos itens incluidos no Fundo de Combate a Pobreza   N     -   02
    03  IND_F0  Indicador de nota fiscal destinada a participante
              do Programa Fome Zero:
              0- N?o;
              1- Sim                              C     001   -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'C150';
    --vg_linha := vg_sep     || vg_registro    || vg_sep;
    --pl_gera_linha;
    --/
  end;
  ----------------------------------------------------------------------------------------------------------------
  --REGISTRO C160: VOLUMES TRANSPORTADOS (CODIGO 01 E 04) - EXCETO COMBUSTIVEIS.
  ----------------------------------------------------------------------------------------------------------------
  procedure pl_registro_c160(pl_cod_part cd_firmas.firma%type,
                             pl_placa    ft_notas.placa_veic%type,
                             pl_qtd      ft_notas.vol_qtd%type,
                             pl_pbrt     ft_notas.peso_bruto%type,
                             pl_pliq     ft_notas.peso_liquido%type) is
    /*
    REGISTRO C160: VOLUMES TRANSPORTADOS (CODIGO 01 E 04) - EXCETO COMBUSTIVEIS.
    N?    Campo     Descric?o                           Tipo  Tam Dec
    01  REG       Texto fixo contendo "C160"                C     004   -
    02  COD_PART  Codigo do participante (campo 02 do Registro 0150):
                - transportador, se houver                C     -   -
    03  VEIC_ID     Placa de identificac?o do veiculo automotor       C     -   -
    04  QTD_VOL     Quantidade de volumes transportados           N     -   -
    05  PESO_BRT  Peso bruto dos volumes transportados (em Kg)    N     -   -
    06  PESO_LIQ  Peso liquido dos volumes transportados (em Kg)    N     -   -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'C160';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || pl_cod_part || vg_sep;
    vg_linha    := vg_linha || pl_placa || vg_sep;
    vg_linha    := vg_linha || pl_qtd || vg_sep;
    vg_linha    := vg_linha || pl_pbrt || vg_sep;
    vg_linha    := vg_linha || pl_pliq || vg_sep || vg_crlf;
    pl_gera_linha;
    --/
  end;
  --/---------------------------------------------------------------------------------------------------------
  --REGISTRO C165: OPERAC?ES COM COMBUSTIVEIS(CODIGO 01; 55)
  --/---------------------------------------------------------------------------------------------------------
  procedure pl_registro_c165 is
    /*
    N?    Campo     Descric?o                     Tipo  Tam Dec
    01  REG       Texto fixo contendo "C165"          C     004   -
    02  COD_PART  Codigo do participante (campo 02 do Registro 0150): - transportador, se houver  C   - -
    03  VEIC_ID     Placa de identificac?o do veiculo   C   - -
    04  COD_AUT     Codigo da autorizac?o fornecido pela SEFAZ (combustiveis)   C   - -
    05  NR_PASSE  Numero do Passe Fiscal  C   - -
    06  HORA      Hora da saida das mercadorias   N   006   -
    07  TEMPER    Temperatura em graus Celsius utilizada para quantificac?o do volume de combustivel  N   - 01
    08  QTD_VOL     Quantidade de volumes transportados   N   - -
    09  PESO_BRT  Peso bruto dos volumes transportados (em Kg)  N   - -
    10  PESO_LIQ  Peso liquido dos volumes transportados (em Kg)  N   - -
    11  NOM_MOT     Nome do motorista   C   - -
    12  CPF       CPF do motorista  C   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C165';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    --pl_gera_linha;
  end;
  --/---------------------------------------------------------------------------------------------------------
  -- REGISTRO C170: ITENS DO DOCUMENTO (CODIGO 01, 1B, 04 e 55)
  --/---------------------------------------------------------------------------------------------------------
  procedure pl_registro_c170(pl_emp      ft_notas.empresa%type,
                             pl_fil      ft_notas.filial%type,
                             pl_cod_part cd_firmas.firma%type,
                             pl_sr       ft_notas.sr_nota%type,
                             pl_nota     ft_notas.num_nota%type,
                             pl_par      ft_notas.parte%type,
                             pl_ind_emit tnum1) is
    /*
    N?    Campo         Descric?o                                     Tipo  Tam Dec
    01  REG           Texto fixo contendo "C170"                          C     004   -
    02  NUM_ITEM      Numero sequencial do item no documento fiscal               N     -   -
    03  COD_ITEM      Codigo do item (campo 02 do Registro 0200)                C     -   -
    04  DESCR_COMPL     Descric?o complementar do item como adotado no documento fiscal   C     -   -
    05  QTD           Quantidade do item                                N     -   03
    06  UNID          Unidade do item(Campo 02 do registro 0190)                C     -   -
    07  VL_ITEM         Valor total do item                                 N     -   02
    08  VL_DESC         Valor do desconto comercial                           N     -   02
    09  IND_MOV         Movimentac?o fisica do ITEM/PRODUTO: 0. SIM 1. N?O          C     001   -
    10  CST_ICMS      Codigo da Situac?o Tributaria referente ao ICMS,            N     003   -
                    conforme a Tabela indicada no item 4.3.1
    11  CFOP          Codigo Fiscal de Operac?o e Prestac?o                     N     004   -
    12  COD_NAT       Codigo da natureza da operac?o (campo 02 do Registro 0400)      C     -   -
    13  VL_BC_ICMS      Valor da base de calculo do ICMS                      N     -   02
    14  ALIQ_ICMS       Aliquota do ICMS                                  N     -   02
    15  VL_ICMS         Valor do ICMS creditado/debitado                      N     -   02
    16  VL_BC_ICMS_ST     Valor da base de calculo referente a substituic?o tributaria    N     -   02
    17  ALIQ_ST         Aliquota do ICMS da substituic?o tributaria na unidade da       N     -   02
                    federac?o de destino
    18  VL_ICMS_ST      Valor do ICMS referente a substituic?o tributaria             N     -   02
    19  IND_APUR      Indicador de periodo de apurac?o do IPI:
                    0 - Mensal;
                    1 - Decendial                                     C     001   -
    20  CST_IPI         Codigo da Situac?o Tributaria referente ao IPI, conforme a
                    Tabela indicada no item 4.3.2.                        C     002   -
    21  COD_ENQ         Codigo de enquadramento legal do IPI, conforme tabela
                    indicada no item 4.5.3.                             C     003   -
    22  VL_BC_IPI     Valor da base de calculo do IPI                         N     -   02
    23  ALIQ_IPI      Aliquota do IPI                                   N     -   02
    24  VL_IPI        Valor do IPI creditado/debitado                         N     -   02
    25  CST_PIS         Codigo da Situac?o Tributaria referente ao PIS, conforme tabela
                    indicada no item 4.3.4.                             N       02
    26  VL_BC_PIS     Valor da base de calculo do PIS                         N       02
    27  ALIQ_PIS      Aliquota do PIS (em percentual)                         N     -   02
    28  QUANT_BC_PIS    Quantidade - Base de calculo PIS                      N       03
    29  ALIQ_PIS      Aliquota do PIS (em reais)                          N       04
    30  VL_PIS        Valor do PIS                                    N     -   02
    31  CST_COFINS      Codigo da Situac?o Tributaria referente ao COFINS, conforme
                    tabela indicada no item 4.3.5.                        N       02
    32  VL_BC_COFINS    Valor da base de calculo da COFINS                      N       02
    33  ALIQ_COFINS     Aliquota do COFINS (em percentual)                      N     -   02
    34  QUANT_BC_COFINS   Quantidade - Base de calculo COFINS                     N       03
    35  ALIQ_COFINS     Aliquota da COFINS (em reais)                         N       04
    36  VL_COFINS       Valor da COFINS                                   N     -   02
    37  COD_CTA         Codigo da conta analitica contabil debitada/creditada         C     -   -
    Observac?es:
    Nivel hierarquico - 3
     Ocorrencia - 1:N
     */
    cursor cr is
      select rownum num_item,
             it.produto cod_item,
             it.descricao descr_compl,
             it.qtd qtd,
             it.uni_est unid,
             (it. valor_unit * it.qtd) vl_item,
             n.vl_desconto vl_desc,
             n.vl_total vl_nota,
             0 ind_mov,
             fs_sped_utl.fb_sit_tributaria(it.cod_tribut) cst_icms,
             it.cod_cfo cfop,
             it.cod_cfo cod_nat,
             it.vl_bicms vl_bc_icms,
             it.aliq_icms aliq_icms,
             it.vl_icms vl_icms,
             it.vl_bicms_sub vl_bc_icms_st,
             0 aliq_st,
             it.vl_icms_sub vl_icms_st,
             0 ind_apur,
             0 cst_ipi,
             0 cod_enq,
             it.vl_bipi vl_bc_ipi,
             it.aliq_ipi aliq_ipi,
             it.vl_ipi vl_ipi,
             0 cst_pis,
             n.vl_produtos vl_bc_pis,
             n.vl_produtos quant_bc_pis,
             round(case
                     when nvl(n.vl_pis, 0) > 0 then
                      (n.vl_pis / n.vl_produtos * 100)
                     else
                      0
                   end,
                   2) aliq_pis,
             
             n.vl_pis vl_pis,
             0 cst_cofins,
             n.vl_produtos vl_bc_cofins,
             n.vl_produtos quant_bc_cofins,
             round(case
                     when nvl(n.vl_cofins, 0) > 0 then
                      (n.vl_cofins / n.vl_produtos * 100)
                     else
                      0
                   end,
                   1) aliq_cofins,
             vl_cofins,
             ce_produtos_utl.cod_conta(it.empresa, it.produto) cod_cta,
             it.vl_biss vl_bc_issqn,
             it.aliq_iss aliq_issqn,
             it.vl_iss vl_issqn
      
        from ft_notas n, ft_itens_nf it
       where it.empresa = n.empresa
         and it.filial = n.filial
         and it.num_nota = n.num_nota
         and it.sr_nota = n.sr_nota
         and it.parte = n.parte
         and pl_ind_emit = 0
         and n.empresa = pl_emp
         and n.filial = pl_fil
         and n.sr_nota = pl_sr
         and n.num_nota = pl_nota
         and n.parte = pl_par
      union all
      select rownum num_item,
             it.produto cod_item,
             it.descricao descr_compl,
             it.qtd qtd,
             it.uni_ven unid,
             (it.valor_unit * it.qtd) vl_item,
             it.vl_desconto vl_desc,
             n.vlr_nota vl_nota,
             0 ind_mov,
             fs_sped_utl.fb_sit_tributaria(it.cod_tribut) cst_icms,
             it.cod_cfo cfop,
             it.cod_cfo cod_nat,
             it.vl_bicms vl_bc_icms,
             it.aliq_icms aliq_icms,
             it.vl_icms vl_icms,
             
             case
               when it.cod_tribut = 20 then
                it.vl_bicms
               else
                0
             end vl_bc_icms_st,
             case
               when it.cod_tribut = 20 then
                it.aliq_icms
               else
                0
             end aliq_st,
             case
               when it.cod_tribut = 20 then
                it.vl_icms
               else
                0
             end vl_icms_st,
             
             0 ind_apur,
             0 cst_ipi,
             0 cod_enq,
             it.vl_bipi vl_bc_ipi,
             it.aliq_ipi aliq_ipi,
             it.vl_ipi vl_ipi,
             0 cst_pis,
             (it. valor_unit * it.qtd) vl_bc_pis,
             (it. valor_unit * it.qtd) quant_bc_pis,
             
             round(case
                     when nvl(n.vl_pis, 0) > 0 then
                      fs_sped_utl.fb_aliq_pis
                     else
                      0
                   end,
                   2) aliq_pis,
             
             --(it. valor_unit * it.qtd) * 0.0165 vl_pis,
             nvl(n.vl_pis, 0) vl_pis,
             0 cst_cofins,
             (it. valor_unit * it.qtd) vl_bc_cofins,
             (it. valor_unit * it.qtd) quant_bc_cofins,
             
             round(case
                     when nvl(n.vl_cofins, 0) > 0 then
                      fs_sped_utl.fb_aliq_cofins
                     else
                      0
                   end,
                   1) aliq_cofins,
             
             --(it. valor_unit * it.qtd) * 0.076 vl_cofins,
             nvl(n.vl_cofins, 0) vl_cofins,
             ce_produtos_utl.cod_conta(it.empresa, it.produto) cod_cta,
             0 vl_bc_issqn,
             0 aliq_issqn,
             n.vlr_iss vl_issqn
      
        from ce_notas n, ce_itens_nf it
       where it.empresa = n.empresa
         and it.filial = n.filial
         and it.num_nota = n.num_nota
         and it.sr_nota = n.sr_nota
         and it.parte = n.parte
         and it.cod_fornec = n.cod_fornec
         and pl_ind_emit = 1
         and n.cod_fornec = pl_cod_part
         and n.empresa = pl_emp
         and n.filial = pl_fil
         and n.sr_nota = pl_sr
         and n.num_nota = pl_nota
         and n.parte = pl_par;
  
    --/
    v_vl_bc_issqn number;
    v_aliq_issqn  number;
    v_vl_issqn    number;
    v_aliq_pis    number;
    v_aliq_cof    number;
  
    --/
  begin
    for reg in cr loop
    
      vg_registro := 'C170';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || reg.num_item || vg_sep;
      vg_linha    := vg_linha || reg.cod_item || vg_sep;
      vg_linha    := vg_linha || reg.descr_compl || vg_sep;
      vg_linha    := vg_linha || reg.qtd || vg_sep;
      vg_linha    := vg_linha || reg.unid || vg_sep;
      vg_linha    := vg_linha || reg.vl_item || vg_sep;
      vg_linha    := vg_linha || reg.vl_desc || vg_sep;
      vg_linha    := vg_linha || reg.ind_mov || vg_sep;
      vg_linha    := vg_linha || reg.cst_icms || vg_sep;
      vg_linha    := vg_linha || reg.cfop || vg_sep;
      vg_linha    := vg_linha || reg.cod_nat || vg_sep;
      vg_linha    := vg_linha || reg.vl_bc_icms || vg_sep;
      vg_linha    := vg_linha || reg.aliq_icms || vg_sep;
      vg_linha    := vg_linha || reg.vl_icms || vg_sep;
      vg_linha    := vg_linha || reg.vl_bc_icms_st || vg_sep;
      vg_linha    := vg_linha || reg.aliq_st || vg_sep;
      vg_linha    := vg_linha || reg.vl_icms_st || vg_sep;
      vg_linha    := vg_linha || reg.ind_apur || vg_sep;
      vg_linha    := vg_linha || reg.cst_ipi || vg_sep;
      vg_linha    := vg_linha || reg.cod_enq || vg_sep;
      vg_linha    := vg_linha || reg.vl_bc_ipi || vg_sep;
      vg_linha    := vg_linha || reg.aliq_ipi || vg_sep;
      vg_linha    := vg_linha || reg.vl_ipi || vg_sep;
      vg_linha    := vg_linha || reg.cst_pis || vg_sep;
      vg_linha    := vg_linha || reg.vl_bc_pis || vg_sep;
      vg_linha    := vg_linha || reg.aliq_pis || vg_sep;
      vg_linha    := vg_linha || reg.quant_bc_pis || vg_sep;
      vg_linha    := vg_linha || reg.aliq_pis || vg_sep;
      vg_linha    := vg_linha || reg.vl_pis || vg_sep;
      vg_linha    := vg_linha || reg.cst_cofins || vg_sep;
      vg_linha    := vg_linha || reg.vl_bc_cofins || vg_sep;
      vg_linha    := vg_linha || reg.aliq_cofins || vg_sep;
      vg_linha    := vg_linha || reg.quant_bc_cofins || vg_sep;
      vg_linha    := vg_linha || reg.aliq_cofins || vg_sep;
      vg_linha    := vg_linha || reg.vl_cofins || vg_sep;
      vg_linha    := vg_linha || reg.cod_cta || vg_sep || vg_crlf;
      --/
      pl_gera_linha;
      --/
      pl_registro_c171;
      --/
      if nvl(reg.vl_issqn, 0) > 0 then
      
        if nvl(reg.vl_bc_issqn, 0) > 0 then
          v_vl_bc_issqn := reg.vl_bc_issqn;
          v_aliq_issqn  := reg.aliq_issqn;
          v_vl_issqn    := reg.vl_issqn;
        else
          v_aliq_issqn  := (reg.vl_issqn / reg.vl_nota) * 100; --(reg.vl_item / reg.vl_nota) * 100;
          v_vl_bc_issqn := reg.vl_item;
          v_vl_issqn    := (reg.vl_item * v_aliq_issqn / 100); --reg.vl_issqn;
        
        end if;
      
        pl_registro_c172(v_vl_bc_issqn, v_aliq_issqn, v_vl_issqn);
      
      end if;
      --/
      pl_registro_c173;
      --/
      pl_registro_c174;
      --/
      pl_registro_c175;
      --/
      pl_registro_c176;
      --/
      pl_registro_c177;
      --/
      pl_registro_c178;
      --/
      pl_registro_c179;
      --/
    end loop;
  end;

  --/REGISTRO C171: ARMAZENAMENTO DE COMBUSTIVEIS (codigo 01, 55)
  procedure pl_registro_c171 is
    /*
    N?    Campo     Descric?o                     Tipo  Tam Dec
    01  REG       Texto fixo contendo "C171"          C     004   -
    02  NUM_TANQUE  Tanque onde foi armazenado o combustivel  C     - -
    03  QTDE      Quantidade ou volume armazenado         N     - -
    Observac?es: Somente na aquisic?o dos combustiveis.
    Nivel hierarquico - 4
    Ocorrencia - 1:N
     */
  begin
    vg_registro := 'C171';
    -- VERIFCAR SE EXISTE NECESSIDADE DE SER GERADO
  end;

  --/REGISTRO C172: OPERAC?ES COM ISSQN (CODIGO 01)
  procedure pl_registro_c172(pl_vl_bc_issqn number,
                             pl_aliq_issqn  number,
                             pl_vl_issqn    number) is
    /*
    N?  Campo Descric?o Tipo                        Tam Dec
    01  REG         Texto fixo contendo "C172"        C     004   -
    02  VL_BC_ISSQN   Valor da base de calculo do ISSQN     N     -   02
    03  ALIQ_ISSQN    Aliquota do ISSQN               N     -   02
    04  VL_ISSQN    Valor do ISSQN                N     -   02
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'C172';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || pl_vl_bc_issqn || vg_sep;
    vg_linha    := vg_linha || pl_aliq_issqn || vg_sep;
    vg_linha    := vg_linha || pl_vl_issqn || vg_sep || vg_crlf;
  
    pl_gera_linha;
  end;

  --/REGISTRO C173: OPERAC?ES COM MEDICAMENTOS (CODIGO 01, 55)
  procedure pl_registro_c173 is
    /*
    N?    Campo     Descric?o                         Tipo  Tam Dec
    01  REG   Texto fixo contendo "C173"                  C     004   -
    02  LOTE_MED  Numero do lote de fabricac?o do medicamento     C     -   -
    03  QTD_ITEM  Quantidade de item por lote               N     -   -
    04  DT_FAB    Data de fabricac?o do medicamento           N     008   -
    05  DT_VAL    Data de expirac?o da validade do medicamento  N     008   -
    06  IND_MED     Indicador de tipo de referencia             C     001   -
                      da base de calculo do ICMS (ST)
                      do produto farmaceutico:
        0-Base de calculo referente ao preco tabelado ou preco maximo sugerido;
        1- Base calculo - Margem de valor agregado;
        2- Base de calculo referente a Lista Negativa;
        3- Base de calculo referente a Lista Positiva;
        4- Base de calculo referente a Lista Neutra
    07  TP_PROD     Tipo de produto:                      C     1   -
        0- Similar;
        1- Generico;
        2- Etico ou de marca;
    08  VL_TAB_MAX  Valor do tabelado ou valor do maximo        N     - 02
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C173';
    -- / sem implementac?o
  end;

  --/REGISTRO C174: OPERAC?ES COM ARMAS DE FOGO (CODIGO 01)
  procedure pl_registro_c174 is
    /*
    N?    Campo       Descric?o                         Tipo  Tam Dec
    01  REG         Texto fixo contendo "C174"              C     004   -
    02  IND_ARM       Indicador do tipo da arma de fogo:            C      001  -
          0- Uso permitido;
          1- Uso restrito
    03  NUM_ARM       Numerac?o de serie de fabricac?o da arma      C      -     -
    04  DESCR_COMPL   Descric?o da arma, compreendendo: numero do     C     -   -
                         cano, calibre, marca, capacidade de cartuchos,
                         tipo de funcionamento, quantidade de canos,
                         comprimento, tipo de alma, quantidade e
                         sentido das raias e demais elementos
                         que permitam sua perfeita identificac?o
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C174';
    -- / sem implementac?o
  end;

  --/REGISTRO C175: OPERAC?ES COM VEICULOS NOVOS (CODIGO 01, 55)
  procedure pl_registro_c175 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C175"  C   004   -
    02  IND_VEIC_OPER   Indicador do tipo de operac?o com veiculo:
        0- Venda para concessionaria;
        1- Faturamento direto;
        2- Venda direta;
        3- Venda da concessionaria;
        9- Outros   C   001   -
    03  CNPJ  CNPJ da Concessionaria, nos casos de Venda direta.  N   014   -
    04  UF  Sigla da unidade da federac?o da Concessionaria   C   002   -
    05  CHASSI_VEIC   Chassi do veiculo   C   - -
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C175';
    -- / sem implementac?o
  end;

  --/REGISTRO C176: RESSARCIMENTO DE ICMS EM OPERAC?ES COM SUBSTITUIC?O TRIBUTARIA (CODIGO 01,55)
  procedure pl_registro_c176 is
    /*
    N?    Campo Descric?o Tipo  Tam Dec
    01  REG       Texto fixo contendo "C176"  C   004   -
    02  COD_MOD_ULT_E Codigo do modelo do documento fiscal relativa a ultima entrada  C   002   -
    03  NUM_DOC_ULT_E Numero do documento fiscal relativa a ultima entrada  N   - -
    04  SER_ULT_E   Serie do documento fiscal relativa a ultima entrada - C   - -
    05  DT_ULT_E      Data relativa a ultima entrada da mercadoria  N   008   -
    06  COD_PART_ULT_E  Codigo do participante (do emitente do documento relativa a ultima entrada)   C   - -
    07  QUANT_ULT_E   Quantidade do item relativa a ultima entrada  N   - 03
    08  VL_UNIT_ULT_E Valor unitario da mercadoria constante na NF relativa a ultima entrada inclusive despesas acessorias. N   - 03
    09  VL_UNIT_BC_ST Valor unitario da base de calculo do imposto pa-go por substituic?o.  N   - 03
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'C176';
    -- / sem implementac?o
  end;

  --/REGISTRO C177: OPERAC?ES COM PRODUTOS SUJEITOS A SELO DE CONTROLE IPI
  procedure pl_registro_c177 is
    /*
    N?    Campo       Descric?o Tipo  Tam Dec
    01  REG         Texto fixo contendo "C177"  C   004   -
    02  COD_SELO_IPI  Codigo do selo de controle do IPI, conforme Tabela 4.5.2  C   006   -
    03  QT_SELO_IPI   Quantidade de selo de controle do IPI aplicada  N   012   -
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'C177';
    -- / sem implementac?o
  end;

  --/REGISTRO C178: OPERAC?ES COM PRODUTOS SUJEITOS A TRIBUTACAO DE IPI POR UNIDADE OU QUANTIDADE DE PRODUTO.
  procedure pl_registro_c178 is
    /*
    N?    Campo     Descric?o Tipo  Tam Dec
    01  REG       Texto fixo contendo "C178"  C   004   -
    02  CL_ENQ    Codigo da classe de enquadramento do IPI, conforme Tabela 4.5.1.  C   005   -
    03  VL_UNID     Valor por unidade padr?o de tributac?o  N   - 02
    04  QUANT_PAD   Quantidade total de produtos na unidade padr?o de tributac?o  N   - 03
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'C178';
    -- / sem implementac?o
  end;

  --/REGISTRO C179: INFORMAC?ES COMPLEMENTARES ST (CODIGO 01)
  procedure pl_registro_c179 is
    /*
    N?    Campo         Descric?o Tipo  Tam Dec
    01  REG           Texto fixo contendo "C179"  C   004   -
    02  BC_ST_ORIG_DEST   Valor da base de calculo ST na origem/destino em operac?es interestaduais.  N   - 02
    03  ICMS_ST_REP     Valor do ICMS-ST a repassar/deduzir em operac?es interestaduais   N   - 02
    04  ICMS_ST_COMPL     Valor do ICMS-ST a complementar a UF de destino   N   - 02
    05  BC_RET        Valor da BC de retenc?o em remessa promovida por Substituido intermediario  N   - 02
    06  ICMS_RET      Valor da parcela do imposto retido em remessa promovida por substituido intermediario N'  - 02
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'C179';
    -- / sem implementac?o
  end;

  --/REGISTRO C190: REGISTRO ANALITICO DO DOCUMENTO (CODIGO 01, 1B, 04 E 55)
  procedure pl_registro_c190(p_imp       in fs_itens_livro.tip_imposto%type,
                             p_emp       in cd_empresas.empresa%type,
                             p_fil       in cd_filiais.filial%type,
                             p_firma     in cd_firmas.firma%type,
                             p_tip_livro in fs_itens_livro.tip_livro%type,
                             p_num_docto in fs_itens_livro.num_docto%type,
                             p_ser_docto in fs_itens_livro.ser_docto%type,
                             p_tip_docto in fs_itens_livro.tip_docto%type,
                             p_nat_oper  in fs_itens_livro.nat_oper%type,
                             p_dt        in date) is
    /*
    N?    Campo       Descric?o                                           Tipo  Tam Dec
    01  REG         Texto fixo contendo "C190"                                C     004   -
    02  CST_ICMS    Codigo da Situac?o Tributaria, conforme a Tabela indicada no item 4.3.1   N     003   -
    03  CFOP  Codigo  Fiscal de Operac?o e Prestac?o do agrupamento de itens              C     004   -
    04  ALIQ_ICMS     Aliquota do ICMS                                        N     -   02
    05  VL_OPR      Valor da operac?o correspondente a combinac?o de CST_ICMS, CFOP,
                  e aliquota do ICMS, incluidas as despesas acessorias (frete,
                  seguros e outras despesas acessorias) e IPI                     N     -   02
    06  VL_BC_ICMS    Parcela correspondente ao "Valor da base de calculo do ICMS"
                  referente a combinac?o de CST_ICMS, CFOP e aliquota do ICMS.          N     -   02
    07  VL_ICMS       Parcela correspondente ao "Valor do ICMS" referente a
                  combinac?o de CST_ICMS, CFOP e aliquota do ICMS.                  N     -   02
    08  VL_BC_ICMS_ST   Parcela correspondente ao "Valor da base de calculo do ICMS"
                  da substituic?o tributaria referente a combinac?o de
                  CST_ICMS, CFOP e aliquota do ICMS.                            N     -   02
    09  VL_ICMS_ST    Parcela correspondente ao valor creditado/debitado do ICMS
                  da substituic?o tributaria, referente a combinac?o de
                  CST_ICMS, CFOP, e aliquota do ICMS.                           N     -   02
    10  VL_RED_BC     Valor n?o tributado em func?o da reduc?o da base de calculo
                  do ICMS, referente a combinac?o de CST_ICMS, CFOP e aliquota do ICMS.   N     -   02
    11  VL_IPI      Parcela correspondente ao "Valor do IPI" referente a
                  combinac?o CST_ICMS, CFOP e aliquota do ICMS.                   N     -   02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
    cursor cr is
      select a.nat_oper cfop,
             aliquota   aliq_icms,
             base_calc  vl_bc_icms,
             base_sub   vl_bc_icms_st,
             valor_00   vl_icms,
             valor_10   vl_icms_st,
             valor_20   vl_red_bc,
             valor_30,
             valor_40,
             valor_41,
             valor_50,
             valor_51,
             valor_60,
             valor_70,
             valor_90,
             vl_st,
             vl_ipi     vl_ipi,
             dt_entsai,
             vlr_dipi,
             vlr_contab vl_opr
        from fs_itens_livro a
       where a.empresa = p_emp
         and a.filial = p_fil
         and a.firma = p_firma
         and a.tip_livro = p_tip_livro
         and a.num_docto = p_num_docto
         and a.ser_docto = p_ser_docto
         and a.tip_docto = p_tip_docto
            --and a.nat_oper    = p_nat_oper
         and a.dt_entsai = p_dt
         and a.tip_imposto = p_imp;
  
    v_cst_icms number(2);
  
  begin
    vg_registro := 'C190';
    for reg in cr loop
    
      if nvl(reg.vl_icms, 0) > 0 then
        v_cst_icms := 0;
      elsif nvl(reg.vl_icms_st, 0) > 0 then
        v_cst_icms := 10;
      elsif nvl(reg.vl_red_bc, 0) > 0 then
        v_cst_icms := 20;
      elsif nvl(reg.valor_30, 0) > 0 then
        v_cst_icms := 30;
      elsif nvl(reg.valor_40, 0) > 0 then
        v_cst_icms := 40;
      elsif nvl(reg.valor_41, 0) > 0 then
        v_cst_icms := 41;
      elsif nvl(reg.valor_50, 0) > 0 then
        v_cst_icms := 50;
      elsif nvl(reg.valor_51, 0) > 0 then
        v_cst_icms := 51;
      elsif nvl(reg.valor_60, 0) > 0 then
        v_cst_icms := 60;
      elsif nvl(reg.valor_70, 0) > 0 then
        v_cst_icms := 70;
      elsif nvl(reg.valor_90, 0) > 0 then
        v_cst_icms := 90;
      end if;
    
      vg_linha := vg_sep || vg_registro || vg_sep;
      vg_linha := vg_linha || v_cst_icms || vg_sep;
      vg_linha := vg_linha || reg.cfop || vg_sep;
      vg_linha := vg_linha || reg.aliq_icms || vg_sep;
      vg_linha := vg_linha || reg.vl_opr || vg_sep;
      vg_linha := vg_linha || reg.vl_bc_icms || vg_sep;
      vg_linha := vg_linha || reg.vl_icms || vg_sep;
      vg_linha := vg_linha || reg.vl_bc_icms_st || vg_sep;
      vg_linha := vg_linha || reg.vl_icms_st || vg_sep;
      vg_linha := vg_linha || reg.vl_red_bc || vg_sep;
      vg_linha := vg_linha || reg.vl_ipi || vg_sep || vg_crlf;
    
      pl_gera_linha;
    
    end loop;
  
  end;

  --/REGISTRO C195: OBSERVACOES DO LANCAMENTO FISCAL(CODIGO 01, 1B E 55)
  procedure pl_registro_c195 is
    /*
    N?    Campo     Descric?o Tipo  Tam Dec
    01  REG       Texto fixo contendo "C195"  C   004   -
    02  COD_OBS     Codigo da observac?o do lancamento fiscal (campo 02 do Registro 0460)   C   - -
    03  TXT_COM-PL  Descric?o complementar do codigo de observac?o.   C   - -
    Observac?es: Campo 03: utilizado para complementar observac?es cujo codigo referente e de informac?o generica.
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C190';
    --/sem implementac?o
    pl_registro_c197;
  end;

  --/REGISTRO C197: OUTRAS OBRIGAC?ES TRIBUTARIAS, AJUSTES E INFORMAC?ES DE VALORES PROVENIENTES DE DOCUMENTO FISCAL.
  procedure pl_registro_c197 is
    /*
    N?    Campo         Descric?o Tipo  Tam Dec
    01  REG           Texto fixo contendo "C197"  C   004   -
    02  COD_AJ        Codigo do ajustes/beneficio/incentivo, conforme tabela
                    indicada no item 5.3.   C   010   -
    03  DESCR_COM-PL_AJ   Descric?o complementar do ajuste da apurac?o, nos casos em que
                    o codigo da tabela for "9999"   C   - -
    04  COD_ITEM      Codigo do item (campo 02 do Registro 0200)  C   - -
    05  VL_BC_ICMS      Base de calculo do imposto  N   - 04
    06  ALIQ_ICMS       Aliquota do ICMS  N   - 02
    07  VL_ICMS         Valor do imposto  N   - 02
    08  VL_OUTROS       Outros valores  N   - 02
    Observac?es: Os dados que gerarem credito ou debito (ou seja, aqueles que n?o s?o simplesmente informativos)
             ser?o somados na apurac?o assim como os registros C190.
    Campo -3 - COD_ITEM so devera ser informado se o ajuste/beneficio for relacionado ao produto.
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C197';
    --/sem implementac?o
  end;

  --/REGISTRO C300: RESUMO DIARIO DAS NOTAS FISCAIS DE VENDA A CONSUMIDOR (CODIGO 02)
  procedure pl_registro_c300 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C300"  C   004   -
    02  COD_MOD   Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1   C   002   -
    03  SER   Serie do documento fiscal   C   - -
    04  SUB   Subserie do documento fiscal  C   - -
    05  NUM_DOC_INI   Numero do documento fiscal inicial  N   - -
    06  NUM_DOC_FIN   Numero do documento fiscal final  N   - -
    07  DT_DOC  Data da emiss?o dos documentos fiscais  N   008   -
    08  VL_DOC  Valor total dos documentos  N   - 02
    09  VL_PIS  Valor total do PIS  N   - 02
    10  VL_COFINS   Valor total da COFINS   N   - 02
    11  C OD_CTA  da conta analitica contabil   C   - -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
    */
  begin
    vg_registro := 'C300';
    --/sem implementac?o
    pl_registro_c310;
    pl_registro_c320;
  
  end;

  --/REGISTRO C310: DOCUMENTOS CANCELADOS DE NOTAS FISCAIS DE VENDA A CONSUMIDOR (CODIGO 02)
  procedure pl_registro_c310 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C310"  C   004   -
    02  NUM_DOC_CANC  Numero do documento fiscal cancelado  N   - -
    Observac?es: O numero do documento cancelado devera constar do intervalo informado.
    Nivel hierarquico - 3
    Ocorrencia - varios (por arquivo)
    */
  begin
    vg_registro := 'C310';
    --/sem implementac?o
  end;

  --/REGISTRO C320: REGISTRO ANALITICO DO RESUMO DIARIO DAS NOTAS FISCAIS DE VENDA A CONSUMIDOR (CODIGO 02)
  procedure pl_registro_c320 is
    /*
    N?    Campo     Descric?o                                             Tipo  Tam Dec
    01  REG       Texto fixo contendo "C320"                                  C     004   -
    02  CST_ICMS  Codigo da Situac?o Tributaria, conforme a Tabela indicada no item 4.3.1 N     003   -
    03  CFOP      Codigo Fiscal de Operac?o e Prestac?o                             N     004   -
    04  ALIQ_ICMS   Aliquota do ICMS                                          N     005   02
    05  VL_OPR    Valor total acumulado das operac?es correspondentes a combinac?o de CST_ICMS,
                  CFOP e aliquota do ICMS, incluidas as despesas acessorias e acrescimos.     N     -   02
    06  VL_BC_ICMS  Valor acumulado da base de calculo do ICMS, referente a combinac?o de
                  CST_ICMS, CFOP, e aliquota do ICMS.                             N     -   02
    07  VL_ICMS     Valor acumulado do ICMS, referente a combinac?o de CST_ICMS, CFOP
                e aliquota do ICMS.                                         N      -     02
    08  VL_RED_BC   Valor n?o tributado em func?o da reduc?o da base de calculo do ICMS, referente
                a combinac?o de CST_ICMS, CFOP, e aliquota do ICMS.                 N     -   02
    09  COD_OBS     Codigo da observac?o do lancamento fiscal (campo 02 do Registro 0460)     C     -   -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - varios (por arquivo)
    */
  begin
    vg_registro := 'C320';
    --/sem implementac?o
    pl_registro_c321;
  end;

  --/REGISTRO C321: ITENS DO RESUMO DIARIO DOS DOCUMENTOS (CODIGO 02)
  procedure pl_registro_c321 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C321"  C   004   -
    02  COD_ITEM  Codigo do item (campo 02 do Registro 0200)  C   - -
    03  QTD   Quantidade acumulada do item  N   - 03
    04  UNID  Unidade do item (Campo 02 do registro 0190)   C   - -
    05  VL_ITEM   Valor acumulado do item   N   - 02
    06  VL_DESC   Valor do desconto acumulado   N   - 02
    07  VL_BC_ICMS  Valor acumulado da base de calculo do ICMS  N   - 02
    08  VL_ICMS   Valor acumulado do ICMS debitado  N   - 02
    09  VL_PIS  Valor acumulado do PIS  N   - 02
    10  VL_COFINS   Valor acumulado da COFINS   N   - 02
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C321';
    --/sem implementac?o
  end;

  --/REGISTRO C400 - EQUIPAMENTO ECF (CODIGO 02 E 2D)
  procedure pl_registro_c400 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C400"  C   004   -
    02  COD_MOD   Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1   C   002   -
    03  ECF_MOD   Modelo do equipamento   C   - -
    04  ECF_FAB   Numero de serie de fabricac?o do ECF  C   - -
    05  ECF_CX  Numero do caixa atribuido ao ECF  N   - -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C400';
    --/sem implementac?o
    pl_registro_c405;
  end;

  --/REGISTRO C405 - REDUC?O Z (CODIGO 02 E 2D)
  procedure pl_registro_c405 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C405"  C   004   -
    02  DT_DOC  Data da Reduc?o Z   N   008   -
    03  CRO   Posic?o do Contador de Reinicio de Operac?o N   - -
    04  CRZ   Posic?o do Contador de Reduc?o Z  N   - -
    05  NUM_COO_FIN   Numero do Contador de Ordem de Operac?o do ultimo documento emitido no dia. (Numero do COO na Reduc?o Z)  N   - -
    06  GT_FIN  Valor do Grande Total final   N   - 02
    07  VL_BRT  Valor da venda bruta  N   - 02
    Observac?es: Obrigatorio
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C405';
    --/sem implementac?o
    pl_registro_c410;
    pl_registro_c420;
    pl_registro_c460;
    pl_registro_c490;
  end;

  --/REGISTRO C410: PIS E COFINS TOTALIZADOS NO DIA (CODIGO 02 E 2D)
  procedure pl_registro_c410 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C410"  C   004   -
    02  VL_PIS  Valor total do PIS  N   - 02
    03  VL_COFINS   Valor total da COFINS   N   - 02
    Observac?es: Obrigatorio
    Nivel hierarquico - 4
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'C410';
    --/sem implementac?o
  end;

  --/REGISTRO C420: REGISTRO DOS TOTALIZADORES PARCIAIS DA REDUC?O Z (COD 02 E 2D)
  procedure pl_registro_c420 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C420"  C   004   -
    02  COD_TOT_PAR   Codigo do totalizador, conforme Tabela 4.4.6  C   005   -
    03  VLR_ACUM_TOT  Valor acumulado no totalizador, relativo a respectiva Reduc?o Z.  N   - 02
    04  NR_TOT  Numero do totalizador quando ocorrer mais de uma situac?o com a mesma carga tributaria efetiva.   N   002   -
    05  DESCR_NR_TOT  Descric?o da situac?o tributaria relativa ao totalizador parcial, quando houver mais de um com a mesma carga tributaria efetiva.  C   - -
    Observac?es: Obrigatorio
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C420';
    --/sem implementac?o
    pl_registro_c425;
  end;

  --/REGISTRO C425: RESUMO DE ITENS DO MOVIMENTO DIARIO (CODIGO 02 E 2D)
  procedure pl_registro_c425 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C425"  C   004   -
    02  COD_ITEM  Codigo do item (campo 02 do Registro 0200)  C   - -
    03  QTD   Quantidade acumulada do item  N   - 03
    04  UNID  Unidade do item (Campo 02 do registro 0190)   C   - -
    05  VL_ITEM   Valor acumulado do item   N   - 02
    06  VL_PIS  Valor do PIS  N   - 02
    07  VL_COFINS   Valor da COFINS   N   - 02
    Observac?es: Para UF que solicitarem resumos diarios
    Nivel hierarquico - 5
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C425';
    --/sem implementac?o
  end;

  --/REGISTRO C460: DOCUMENTO FISCAL EMITIDO POR ECF (CODIGO 02 E 2D)
  procedure pl_registro_c460 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C460"  C   004   -
    02  COD_MOD   Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1   C   002   -
    03  COD_SIT   Codigo da situac?o do documento fiscal, conforme a Tabela 4.1.2   N   002   -
    04  NUM_DOC   Numero do documento fiscal (CCF ou COO)   N   - -
    05  DT_DOC  Data da emiss?o do documento fiscal   N   008   -
    06  VL_DOC  Valor total do documento fiscal   N   - 02
    07  VL_PIS  Valor do PIS  N   - 02
    08  VL_COFINS   Valor da COFINS   N   - 02
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C460';
    --/sem implementac?o
    pl_registro_c470;
  end;

  --/REGISTRO C470: ITENS DO DOCUMENTO FISCAL EMITIDO POR ECF (CODIGO 02 E 2D)
  procedure pl_registro_c470 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C470"  C   004   -
    02  COD_ITEM  Codigo do item (campo 02 do Registro 0200)  C   - -
    03  QTD   Quantidade do item  N   - 03
    04  QTD_CANC  Quantidade cancelada, no caso de cancelamento parcial de item   N   - 03
    05  UNID  Unidade do item (Campo 02 do registro 0190)   C   - -
    06  VL_ITEM   Valor do item   N   - 02
    07  CST_ICMS  Codigo da Situac?o Tributaria, conforme a Tabela indicada no item 4.3.1.  N   003   -
    08  CFOP  Codigo Fiscal de Operac?o e Prestac?o   N   004   -
    09  ALIQ_ICMS   Aliquota do ICMS  N   - 02
    10  VL_PIS  Valor do PIS  N   - 02
    11  VL_COFINS   Valor da COFINS   N   - 02
    Observac?es:
    Nivel hierarquico - 5
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C470';
    --/sem implementac?o
  end;

  --/REGISTRO C490: REGISTRO ANALITICO DO MOVIMENTO DIARIO (CODIGO 02 E 2D)
  procedure pl_registro_c490 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C490"  C   004   -
    02  CST_ICMS  Codigo da Situac?o Tributaria, conforme a Tabela indicada no item 4.3.1   N   003   -
    03  CFOP  Codigo Fiscal de Operac?o e Prestac?o N   004   -
    04  ALIQ_ICMS   Aliquota do ICMS  N   - 02
    05  VL_OPR  Valor da operac?o correspondente a combinac?o de CST_ICMS, CFOP, e aliquota do ICMS, incluidas as despesas acessorias e acrescimos  N   - 02
    06  VL_BC_ICMS  Valor acumulado da base de calculo do ICMS, referente a combinac?o de CST_ICMS, CFOP, e aliquota do ICMS. N   - 02
    07  VL_ICMS   Valor acumulado do ICMS, referente a combinac?o de CST_ICMS, CFOP e aliquota do ICMS. N   - 02
    08  COD_OBS   Codigo da observac?o do lancamento fiscal (campo 02 do  C   - -
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C490';
    --/sem implementac?o
  end;

  --/REGISTRO C495: RESUMO MENSAL DE ITENS DO ECF POR ESTABELECIMENTO (CODIGO 02, 2D, E 2E)
  procedure pl_registro_c495 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C495"  C   004   -
    02  ALIQ_ICMS   Aliquota do ICMS  N   - 02
    03  COD_ITEM  Codigo do item (campo 02 do Registro 0200)  C   - -
    04  QTD   Quantidade acumulada do item  N   - 03
    05  QTD_CANC  Quantidade cancelada acumulada, no caso de cancelamento parcial de item   N   - 03
    06  UNID  Unidade do item (Campo 02 do registro 0190)   C   - -
    07  VL_ITEM   Valor acumulado do item   N   - 02
    08  VL_DESC   Valor acumulado dos descontos   N   - 02
    09  VL_CANC   Valor acumulado dos cancelamentos   N   - 02
    10  VL_ACMO   Valor acumulado dos acrescimos  N   - 02
    11  VL_BC_ICMS  Valor acumulado da base de calculo do ICMS  N   - 02
    12  VL_ICMS   Valor acumulado do ICMS   N   - 02
    13  VL_ISEN   Valor das saidas isentas do ICMS  N   - 02
    14  VL_NT   Valor das saidas sob n?o-incidencia ou n?o-tributadas pelo ICMS   N   - 02
    15  VL_ICMS_ST  Valor das saidas de mercadorias adquiridas com substituic?o tributaria do ICMS  N   - 02
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - V
    */
  begin
    vg_registro := 'C495';
    --/sem implementac?o
  end;

  --/REGISTRO C500: NOTA FISCAL/CONTA DE ENERGIA ELETRICA (CODIGO 06) E NOTA FISCAL CONSUMO FORNECIMENTO DE GAS (CODIGO 28)
  procedure pl_registro_c500 is
    /*
    N?    Campo       Descric?o                                                   Tipo  Tam Dec
    01  REG         Texto fixo contendo "C500"                                        C     004   -
    02  IND_OPER    Indicador do tipo de operac?o: 0- Entrada; 1- Saida                         C     001   -
    03  IND_EMIT    Indicador do emitente do documento fiscal:
        0- Emiss?o propria;
        1- Terceiros                                                            C     001   -
    04  COD_PART    Codigo do participante (campo 02 do Registro 0150):
        - do adquirente, no caso das saidas;
        - do fornecedor no caso de entradas                                             C     -   -
    05  COD_MOD       Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1                   C     002   -
    06  COD_SIT       Codigo da situac?o do documento fiscal, conforme a Tabela 4.1.2                 N     002   -
    07  SER   Serie do documento fiscal                                                 C     -   -
    08  SUB   Subserie do documento fiscal                                              N     -   -
    09  COD_CONS    Codigo de classe de consumo de energia eletrica, conforme a
                    Tabela 4.4.5 ou Codigo da classe de consumo de gas canalizado conforme Tabela 4.4.3.  N     002   -
    10  NUM_DOC       Numero do documento fiscal                                        N     -   -
    11  DT_DOC      Data da emiss?o do documento fiscal                                   N     008   -
    12  DT_E_S      Data da entrada ou da saida                                         N     008   -
    13  VL_DOC      Valor total do documento fiscal                                       N     -   02
    14  VL_DESC       Valor total do desconto                                           N     -   02
    15  VL_FORN       Valor total fornecido/consumido                                       N     -   02
    16  VL_SERV_NT    Valor total dos servicos n?o-tributados pelo ICMS                           N     -   02
    17  VL_TERC       Valor total cobrado em nome de terceiros                                N     -   02
    18  VL_DA       Valor total de despesas acessorias indicadas no documento fiscal                N     -   02
    19  VL_BC_ICMS    Valor acumulado da base de calculo do ICMS                              N     -   02
    20  VL_ICMS       Valor acumulado do ICMS                                           N     -   02
    21  VL_BC_ICMS_ST Valor acumulado da base de calculo do ICMS substituic?o tributaria              N     -   02
    22  VL_ICMS_ST    Valor acumulado do ICMS retido por substituic?o tributaria                    N     -   02
    23  COD_INF       Codigo da informac?o complementar do documento fiscal (campo 02 do Registro 0450)     C     -   -
    24  VL_PIS      Valor do PIS                                                  N     -   02
    25  VL_COFINS     Valor da COFINS                                                 N     -   02
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
    */
    cursor cr is
      select '0' ind_oper, --entrada
             '1' ind_emit, --terceiros
             to_char(n.dt_entrada, 'ddmmrrrr') dt_e_s,
             n.num_nota num_doc,
             n.cod_fornec cod_part,
             n.tipo_doc tipo_doc,
             fs_sped_utl.fb_cd_doctos(n.tipo_doc) cod_mod,
             fs_sped_utl.fb_situacao_docto(n.cod_cfo, n.situacao_nf) cod_sit,
             n.sr_nota ser,
             null sub_ser,
             to_char(n.dt_emissao, 'ddmmrrrr') dt_doc,
             n.vlr_nota vl_doc,
             0 vl_desc,
             n.vlr_nota vl_merc,
             (nvl(n.vlr_despesa, 0)) vl_da,
             (nvl(n.vlr_bicms, 0)) vl_bc_icms,
             (nvl(n.vlr_icms, 0)) vl_icms,
             0 vl_bc_icms_s, -- verificar
             0 vl_icms_st, --verificar
             0 vl_ipi,
             (nvl(n.vlr_pis_ret, 0)) vl_pis,
             (nvl(n.vl_cofins, 0)) vl_cofins,
             0 vl_pis_st, -- verificar
             0 vl_cofins_st,
             n.cod_cfo cod_cfo,
             n.dt_emissao dt_ref,
             0 vl_serv_nt,
             i.qtd * i.valor_unit vl_forn,
             0 vl_terc,
             null cod_inf,
             i.produto cod_item,
             i.descricao descricao,
             i.aliq_icms aliq_icms,
             --i.unid_ven                                   unid           ,
             'KWH' unid,
             '1' ind_rec,
             ce_produtos_utl.cod_conta(i.empresa, i.produto) cod_conta,
             fs_sped_utl.fb_sit_tributaria(i.cod_tribut) cst_icms,
             i.qtd qtd,
             rownum num_item
        from ce_notas n, ce_itens_nf i
       where i.empresa = n.empresa
         and i.filial = n.filial
         and i.num_nota = n.num_nota
         and i.sr_nota = n.sr_nota
         and i.cod_fornec = n.cod_fornec
         and i.parte = n.parte
         and n.empresa = vg_emp
         and n.filial = vg_fil
         and n.tipo_doc = 3 -- somente notas fiscais
         and n.dt_entrada between vg_inic and vg_final
         and n.cod_cfo in
             (select cod_cfo
                from fs_cfos_sintegra
               where ((registro = 50 and tipo_reg = 'T')));
  
  begin
  
    for reg in cr loop
      --/
      vg_registro := 'C500';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || reg.ind_oper || vg_sep;
      vg_linha    := vg_linha || reg.ind_emit || vg_sep;
      vg_linha    := vg_linha || reg.cod_part || vg_sep;
      vg_linha    := vg_linha || reg.cod_mod || vg_sep;
      vg_linha    := vg_linha || reg.cod_sit || vg_sep;
      vg_linha    := vg_linha || reg.ser || vg_sep;
      vg_linha    := vg_linha || reg.sub_ser || vg_sep;
      vg_linha    := vg_linha || vg_param.fx_cons_en || vg_sep;
      vg_linha    := vg_linha || reg.num_doc || vg_sep;
      vg_linha    := vg_linha || reg.dt_doc || vg_sep;
      vg_linha    := vg_linha || reg.dt_e_s || vg_sep;
      vg_linha    := vg_linha || reg.vl_doc || vg_sep;
      vg_linha    := vg_linha || reg.vl_desc || vg_sep;
      vg_linha    := vg_linha || reg.vl_forn || vg_sep;
      vg_linha    := vg_linha || reg.vl_serv_nt || vg_sep;
      vg_linha    := vg_linha || reg.vl_terc || vg_sep;
      vg_linha    := vg_linha || reg.vl_da || vg_sep;
      vg_linha    := vg_linha || reg.vl_bc_icms || vg_sep;
      vg_linha    := vg_linha || reg.vl_icms || vg_sep;
      vg_linha    := vg_linha || reg.vl_bc_icms_s || vg_sep;
      vg_linha    := vg_linha || reg.vl_icms_st || vg_sep;
      vg_linha    := vg_linha || reg.cod_inf || vg_sep;
      vg_linha    := vg_linha || reg.vl_pis || vg_sep;
      vg_linha    := vg_linha || reg.vl_cofins || vg_sep || vg_crlf;
    
      pl_gera_linha;
    
      --/ chama registros filho
      pl_registro_c510('1', --reg.num_item   ,
                       reg.cod_item,
                       '0601', --reg.cod_class   ,
                       reg.qtd,
                       reg.unid,
                       reg.vl_doc,
                       reg.vl_desc,
                       reg.cst_icms,
                       reg.cod_cfo,
                       reg.vl_bc_icms,
                       reg.aliq_icms,
                       reg.vl_icms,
                       reg.vl_bc_icms_s,
                       0, --reg.aliq_st     ,
                       reg.vl_icms_st,
                       reg.ind_rec,
                       reg.cod_part,
                       reg.vl_pis,
                       reg.vl_cofins,
                       reg.cod_conta,
                       reg.num_doc,
                       reg.ser);
    
      pl_registro_c520;
    
      pl_registro_c590(reg.cst_icms,
                       reg.cod_cfo,
                       reg.aliq_icms,
                       reg.vl_doc,
                       reg.vl_bc_icms,
                       reg.vl_icms,
                       reg.vl_bc_icms_s,
                       reg.vl_icms_st,
                       0,
                       null);
    end loop;
  end;

  --/REGISTRO C510: ITENS DO DOCUMENTO NOTA FISCAL/CONTA ENERGIA ELETRICA (CODIGO 06) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS (CODIGO 28)
  procedure pl_registro_c510(pl_num_item     tnum4,
                             pl_cod_item     tid,
                             pl_cod_class    tstr10,
                             pl_qtd          tvalor2,
                             pl_unid         ce_itens_nf.uni_ven%type,
                             pl_vl_item      tvalor2,
                             pl_vl_desc      tvalor2,
                             pl_cst_icms     ce_itens_nf.cod_tribut%type,
                             pl_cfop         ce_notas.cod_cfo%type,
                             pl_vl_bc_icms   tvalor2,
                             pl_aliq_icms    number,
                             pl_vl_icms      tvalor2,
                             pl_vl_bc_icms_s tvalor2,
                             pl_aliq_st      tvalor2,
                             pl_vl_icms_st   tvalor2,
                             pl_ind_rec      tstr1,
                             pl_cod_part     ce_notas.cod_fornec%type,
                             pl_vl_pis       tvalor2,
                             pl_vl_cofins    tvalor2,
                             pl_conta        cg_plano.cod_conta%type,
                             pl_num          ce_notas.num_nota%type,
                             pl_ser          ce_notas.sr_nota%type)
  
   is
    /*
    N?    Campo       Descric?o                                                       Tipo  Tam Dec
    01  REG         Texto fixo contendo "C510"                                            C     004   -
    02  NUM_ITEM    Numero sequencial do item no documento fiscal                                 N     -   -
    03  COD_ITEM    Codigo do item (campo 02 do Registro 0200)                                  C     -   -
    04  COD_CLASS     Codigo de classificac?o do item de energia eletrica, conforme a Tabela 4.4.1            N     004   -
        06. Energia Eletrica  - tabela 4.4.1
        0601  Energia Eletrica - Consumo
        0602  Energia Eletrica - Demanda
        0603  Energia Eletrica -Servicos (Vistoria de unidade consumidora, Aferic?o de Medidor, Ligac?o, Religac?o, Troca de medidor, etc.)
        0604  Energia Eletrica - Encargos Emergenciais
        0605  Tarifa de Uso dos Sistemas de Distribuic?o de Energia Eletrica - TUSD - Consumidor Cativo
        0606  Tarifa de Uso dos Sistemas de Distribuic?o de Energia Eletrica - TUSD - Consumidor Livre
        0607  Encargos de Conex?o
        0608  Tarifa de Uso dos Sistemas de Transmiss?o de Energia Eletrica - TUST - Consumidor Cativo
        0609  Tarifa de Uso dos Sistemas de Transmiss?o de Energia Eletrica - TUST - Consumidor Livre
        0610  Subvenc?o economica para consumidores da subclasse "baixa renda"
        0699  Energia Eletrica - Outros
    05  QTD         Quantidade do item                                                  N     -   03
    06  UNID        Unidade do item (Campo 02 do registro 0190)                                 C     -   -
    07  VL_ITEM       Valor do item                                                       N     -   -
    08  VL_DESC       Valor total do desconto                                               N     -   02
    09  CST_ICMS    Codigo da Situac?o Tributaria, conforme a Tabela indicada no item 4.3.1 -             N     003   -
    10  CFOP  Codigo  Fiscal de Operac?o e Prestac?o                                          N     004   -
    11  VL_BC_ICMS    Valor da base de calculo do ICMS                                        N     -   02
    12  ALIQ_ICMS     Aliquota do ICMS                                                    N     -   02
    13  VL_ICMS       Valor do ICMS creditado/debitado                                        N     -   02
    14  VL_BC_ICMS_ST   Valor da base de calculo referente a substituic?o tributaria                      N     -   02
    15  ALIQ_ST       Aliquota do ICMS da substituic?o tributaria na unidade da federac?o de destino          N     -   02
    16  VL_ICMS_ST    Valor do ICMS referente a substituic?o tributaria                               N     -   02
    17  IND_REC       Indicador do tipo de receita:
        0- Receita propria;
        1- Receita de terceiros                                                         C     001   -
    18  COD_PART    Codigo do participante receptor da receita, terceiro da operac?o (campo 02 do Registro 0150)  C
    19  VL_PIS      Valor do PIS                                                      N     -   02
    20  VL_COFINS     Valor da COFINS                                                     N     -   02
    21  COD_CTA       Codigo da conta analitica contabil debitada/creditada                           C     -   -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  
    /*
    cursor cr is
        select
            rownum                                       num_item    ,
            i.produto                                    cod_item    ,
            '0601'                                       cod_class   ,  -- consumo  (0699) outros
            i.qtd                                        qtd         ,
            --i.uni_ven                                unid        ,
            'KWH'                                  unid        ,
            i.qtd  * i.valor_unit                 vl_item   ,
            0                                            vl_desc     ,
            i.cod_tribut                                 cst_icms    ,
            i.cod_cfo                                    cfop        ,
            (nvl(i.VL_BICMS      ,0))             vl_bc_icms    ,
            i.aliq_icms                                  aliq_icms      ,
            i.vl_icms                                    vl_icms        ,
            null                            vl_bc_icms_s  , -- verificar
            null                                         aliq_st        ,
            null                                         vl_icms_st     ,
            '1'                                          ind_rec        ,
            i.cod_fornec                                 cod_part       ,
            i.vl_pis                                     vl_pis         ,
            i.vl_cofins                                  vl_cofins      ,
            ''                                            cod_conta
        from ce_notas      n,
             ce_itens_nf   i
        where
             i.empresa    = n.empresa
         and i.filial     = n.filial
         and i.num_nota   = n.num_nota
         and i.sr_nota    = n.sr_nota
         and i.cod_fornec = n.cod_fornec
         and i.parte      = n.parte
            and n.empresa    = p_emp
           and n.filial     = p_fil
            and n.num_nota   = pl_num
            and n.sr_nota    = pl_ser
            and n.cod_fornec = pl_cod_part
            and n.parte      = 0
           and n.dt_entrada between p_inic and p_final;
      */
  begin
    --for reg in cr loop
  
    vg_registro := 'C510';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || pl_num_item || vg_sep;
    vg_linha    := vg_linha || pl_cod_item || vg_sep;
    vg_linha    := vg_linha || pl_cod_class || vg_sep;
    vg_linha    := vg_linha || pl_qtd || vg_sep;
    vg_linha    := vg_linha || pl_unid || vg_sep;
    vg_linha    := vg_linha || pl_vl_item || vg_sep;
    vg_linha    := vg_linha || pl_vl_desc || vg_sep;
    vg_linha    := vg_linha || pl_cst_icms || vg_sep;
    vg_linha    := vg_linha || pl_cfop || vg_sep;
    vg_linha    := vg_linha || pl_vl_bc_icms || vg_sep;
    vg_linha    := vg_linha || pl_aliq_icms || vg_sep;
    vg_linha    := vg_linha || pl_vl_icms || vg_sep;
    vg_linha    := vg_linha || pl_vl_bc_icms_s || vg_sep;
    vg_linha    := vg_linha || pl_aliq_st || vg_sep;
    vg_linha    := vg_linha || pl_vl_icms_st || vg_sep;
    vg_linha    := vg_linha || pl_ind_rec || vg_sep;
    vg_linha    := vg_linha || pl_cod_part || vg_sep;
    vg_linha    := vg_linha || pl_vl_pis || vg_sep;
    vg_linha    := vg_linha || pl_vl_cofins || vg_sep;
    vg_linha    := vg_linha || pl_conta || vg_sep || vg_crlf;
  
    pl_gera_linha;
  
    --end loop;
  
  end;

  --/REGISTRO C520: COMPLEMENTO DO DOCUMENTO - DADOS ADICIONAIS (CODIGO 06)
  procedure pl_registro_c520 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C520"  C   004   -
    02  VL_FCP  Valor do ICMS resultante da aliquota adicional dos itens in-cluidos no Fundo de Combate a Pobreza   N   - 02
    03  IND_F0  Indicador de nota fiscal recebida/destinada de/a participante do Programa Fome Zero:
      0- N?o;
      1- Sim  C   001   -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'C520';
    --/sem implementac?o
  end;

  --/REGISTRO C590: REGISTRO ANALITICO DO DOCUMENTO - NOTA FISCAL/CONTA DE ENERGIA ELETRICA (CODIGO 06)
  -- E NOTA FISCAL CONSUMO FORNECIMENTO DE GAS (CODIGO 28)
  procedure pl_registro_c590(p_cst_icms      ce_itens_nf.cod_tribut%type,
                             p_cfop          ce_itens_nf.cod_cfo%type,
                             p_aliq_icms     ce_itens_nf.aliq_icms%type,
                             p_vl_opr        tvalor2,
                             p_vl_bc_icms    tvalor2,
                             p_vl_icms       tvalor2,
                             p_vl_bc_icms_st tvalor2,
                             p_vl_icms_st    tvalor2,
                             p_vl_red_bc     tvalor2,
                             p_cod_obs       tstr10) is
    /*
    N?    Campo       Descric?o                                                   Tipo  Tam Dec
    01  REG         Texto fixo contendo "C590"                                        C   004   -
    02  CST_ICMS    Codigo da Situac?o Tributaria, conforme a Tabela indicada no item 4.3.1.          N   003   -
    03  CFOP        Codigo Fiscal de Operac?o e Prestac?o do agrupamento de itens                   C   004   -
    04  ALIQ_ICMS     Aliquota do ICMS  N   - 02
    05  VL_OPR      Valor da operac?o correspondente a combinac?o de CST_ICMS, CFOP, e aliquota do ICMS.  N   - 02
    06  VL_BC_ICMS    Parcela correspondente ao "Valor da base de calculo do ICMS" referente a combinac?o de
                  CST_ICMS, CFOP e aliquota do ICMS.                                    N   - 02
    07  VL_ICMS       Parcela correspondente ao "Valor do ICMS" referente a combinac?o de CST_ICMS, CFOP e
                  aliquota do ICMS.                                               N   - 02
    08  VL_BC_ICMS_ST   Parcela correspondente ao "Valor da base de calculo do ICMS" da substituic?o t
                  ributaria referente a combinac?o de CST_ICMS, CFOP e aliquota do ICMS.            N   - 02
    09  VL_ICMS_ST    Parcela correspondente ao valor creditado/debitado do ICMS da substituic?o tributaria,
                  referente a combinac?o de CST_ICMS, CFOP, e aliquota do ICMS.                 N   - 02
    10  VL_RED_BC     Valor n?o tributado em func?o da reduc?o da base de calculo do ICMS, referente a
                  combinac?o de CST_ICMS, CFOP e aliquota do ICMS.                          N   - 02
    11  COD_OBS       Codigo da observac?o do lancamento fiscal ((campo 02 do Registro 0460)            C   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C590';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || p_cst_icms || vg_sep;
    vg_linha    := vg_linha || p_cfop || vg_sep;
    vg_linha    := vg_linha || p_aliq_icms || vg_sep;
    vg_linha    := vg_linha || p_vl_opr || vg_sep;
    vg_linha    := vg_linha || p_vl_bc_icms || vg_sep;
    vg_linha    := vg_linha || p_vl_icms || vg_sep;
    vg_linha    := vg_linha || p_vl_bc_icms_st || vg_sep;
    vg_linha    := vg_linha || p_vl_icms_st || vg_sep;
    vg_linha    := vg_linha || p_vl_red_bc || vg_sep;
    vg_linha    := vg_linha || p_cod_obs || vg_sep || vg_crlf;
  
    pl_gera_linha;
    --/sem implementac?o
  end;

  --/REGISTRO C600: CONSOLIDAC?O DIARIA DE NOTAS FISCAIS/CONTAS DE ENERGIA ELETRICA (CODIGO 06),
  --/               NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA (CODIGO 27) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS (CODIGO 28)
  --/               (EMPRESAS N?O OBRIGADAS AO CONVENIO ICMS 115/03)
  procedure pl_registro_c600 is
    /*
    N?    Campo       Descric?o                                                 Tipo  Tam Dec
    01  REG         Texto fixo contendo "C600"                                      C     004   -
    02  COD_MOD       Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1                 C     002   -
    03  COD_MUN       Codigo do municipio dos pontos de consumo, conforme a tabela IBGE             N     007   -
    04  SER         Serie do documento fiscal                                         C     -   -
    05  SUB         Subserie do documento fiscal                                      N     -   -
    06  COD_CONS    Codigo de classe de consumo de energia eletrica, conforme a Tabela 4.4.5,
                  ou Codigo de Consumo de Fornecimento D'agua - Tabela 4.4.2 ou
                  Codigo da classe de consumo de gas canalizado conforme Tabela 4.4.3.            N     002   -
    07  QTD_CONS    Quantidade de documentos consolidados neste registro                      N     -   -
    08  QTD_CANC    Quantidade de documentos cancelados                                 N     -   -
    09  DT_DOC      Data dos documentos consolidados                                  N     008   -
    10  VL_DOC      Valor total dos documentos                                      N     -   02
    11  VL_DESC       Valor acumulado dos descontos                                     N     -   02
    12  CONS        Consumo total acumulado, em kWh (Codigo 06)                             N     -   -
    13  VL_FORN       Valor acumulado do fornecimento                                     N     -   02
    14  VL_SERV_NT    Valor acumulado dos servicos n?o-tributados ICMS                        N     -   02
    15  VL_TERC       Valores cobrados em nome de terceiros                                 N     -   02
    16  VL_DA       Valor acumulado das despesas acessorias                               N     -   02
    17  VL_BC_ICMS    Valor acumulado da base de calculo do ICMS                            N     -   02
    18  VL_ICMS       Valor acumulado do ICMS                                         N     -   02
    19  VL_BC_ICMS_ST Valor acumulado da base de calculo do ICMS substituic?o tributaria            N     -   02
    20  VL_ICMS_ST    Valor acumulado do ICMS retido por substituic?o tributaria                  N     -   02
    21  VL_PIS      Valor acumulado do PIS                                          N     -   02
    22  VL_COFINS     Valor acumulado COFINS                                          N     -   02
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
    */
  begin
    vg_registro := 'C600';
    --/sem implementac?o
    pl_registro_c601;
    pl_registro_c610;
    pl_registro_c620;
    pl_registro_c690;
  end;

  --/REGISTRO C601: DOCUMENTOS CANCELADOS - CONSOLIDAC?O DIARIA DE NOTAS FISCAIS/CONTAS DE ENERGIA ELETRICA (CODIGO 06),
  --/               NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA (CODIGO 27) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS (CODIGO 28)
  procedure pl_registro_c601 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C601"  C   004   -
    02  NUM_DOC_CANC  Numero do documento fiscal cancelado  N   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C601';
    --/sem implementac?o
  end;

  --/REGISTRO C610: ITENS DO DOCUMENTO CONSOLIDADO (CODIGO 06), NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA (CODIGO 27)
  --/               E NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS (CODIGO 28) (EMPRESAS N?O OBRIGADAS AO CONVENIO ICMS 115/03)
  procedure pl_registro_c610 is
    /*
    N?    Campo       Descric?o Tipo  Tam Dec
    01  REG         Texto fixo contendo "C610"  C   004   -
    02  COD_CLASS     Codigo de classificac?o do item de energia eletrica, conforme Tabela 4.4.1  C   004   -
    03  COD_ITEM    Codigo do item (campo 02 do Registro 0200)  C   - -
    04  QTD         Quantidade acumulada do item  N   - 03
    05  UNID        Unidade do item (Campo 02 do registro 0190)   C   - -
    06  VL_ITEM       Valor acumulado do item   N   - 02
    07  VL_DESC       Valor acumulado dos descontos   N   - 02
    08  CST_ICMS    Codigo da Situac?o Tributaria, conforme a Tabela indicada no item 4.3.1   N   003   -
    09  CFOP  Codigo  Fiscal de Operac?o e Prestac?o preponderante  N   004   -
    10  ALIQ_ICMS     Aliquota do ICMS  N   - 02
    11  VL_BC_ICMS    Valor acumulado da base de calculo do ICMS  N   - 02
    12  VL_ICMS       Valor acumulado do ICMS debitado  N   - 02
    13  VL_BC_ICMS_ST Valor da base de calculo do ICMS substituic?o tributaria  N   - 02
    14  VL_ICMS_ST    Valor do ICMS retido por substituic?o tributaria  N   - 02
    15  VL_PIS      Valor do PIS  N   - 02
    16  VL_COFINS     Valor da COFINS   N   - 02
    17  COD_CTA       Codigo da conta analitica contabil debitada/creditada C   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C610';
    --/sem implementac?o
  end;

  --/REGISTRO C620: COMPLEMENTO DO DOCUMENTO - DADOS ADICIONAIS (CODIGO 06)
  procedure pl_registro_c620 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C620"  C   004   -
    02  VL_FCP  Valor do ICMS resultante da aliquota adicional dos itens incluidos no Fundo de Combate a Pobreza  N   - 02
    03  IND_F0  Indicador de nota fiscal recebida/destinada de/a participante do Programa Fome Zero:
    0- N?o;
    1- Sim  C   001   -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'C620';
    --/sem implementac?o
  end;

  --/REGISTRO C690: REGISTRO ANALITICO DOS DOCUMENTOS (NOTAS FISCAIS/CONTAS DE ENERGIA ELETRICA (CODIGO 06),
  --/NOTA FISCAL/CONTA DE FORNECIMENTO D'AGUA (CODIGO 27) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS (CODIGO 28)
  procedure pl_registro_c690 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C690"  C   004   -
    02  CST_ICMS  Codigo da Situac?o Tributaria, conforme a tabela indicada no item 4.3.1   N   003   -
    03  CFOP  Codigo Fiscal de Operac?o e Prestac?o, conforme a tabela indicada no item 4.2.2   N   004   -
    04  ALIQ_ICMS   Aliquota do ICMS  N   - 2
    05  VL_OPR  Valor da operac?o correspondente a combinac?o de CST_ICMS, CFOP, e aliquota do ICMS.  N   - 2
    06  VL_BC_ICMS  Parcela correspondente ao "Valor da base de calculo do ICMS" referente a combinac?o CST_ICMS, CFOP e aliquota do ICMS   N   - 2
    07  VL_ICMS   Parcela correspondente ao "Valor do ICMS" referente a combinac?o CST_ICMS, CFOP e aliquota do ICMS  N   - 2
    08  VL_RED_BC   Valor n?o tributado em func?o da reduc?o da base de calculo do ICMS, referente a combinac?o de CST_ICMS, CFOP e aliquota do ICMS.   N   - 02
    09  VL_BC_ICMS_ST Valor da base de calculo do ICMS substituic?o tributaria  N   - 02
    10  VL_ICMS_ST  Valor do ICMS retido por substituic?o tributaria  N   - 02
    11  COD_OBS   Codigo da observac?o do lancamento fiscal (campo 02 do Registro 0460) C   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C690';
    --/sem implementac?o
  end;

  --/REGISTRO C700: CONSOLIDAC?O DOS DOCUMENTOS NF/CONTA ENERGIA ELETRICA (CODIGO 06),
  --/EMITIDAS EM VIA UNICA (EMPRESAS OBRIGADAS AO CONVENIO ICMS 115/03)
  procedure pl_registro_c700 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C700"  C   004   -
    02  COD_MOD   Codigo do modelo d documento fiscal, conforme a Tabela 4.1.1  C   002
    03  SER   Serie do documento fiscal   C   - -
    04  NRO_ORD_INI   Numero de ordem inicial   N   - -
    05  NRO_ORD_FIN   Numero de ordem final   N   - -
    06  DT_DOC_INI  Data de emiss?o inicial dos documentos  N   008   -
    07  DT_DOC_FIN  Data de emiss?o final dos documentos  N   008   -
    08  NOM_VOL   Nome do Volume do arquivo Mestre de Documento Fiscal  C   015   -
    09  CHV_COD_DIG   Chave de codificac?o digital do arquivo Mestre de Documento Fiscal  C   032   -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'C700';
    --/sem implementac?o
    pl_registro_c790;
  end;

  --/REGISTRO C790: REGISTRO ANALITICO DOS DOCUMENTOS (COD 06)
  procedure pl_registro_c790 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C790"  C   004   -
    02  CST_ICMS  Codigo da Situac?o Tributaria, conforme a tabela indicada no item 4.3.1 N   003   -
    03  CFOP  Codigo Fiscal de Operac?o e Prestac?o, conforme a tabela indicada no item 4.2.2   N   004   -
    04  ALIQ_ICMS   Aliquota do ICMS  N   - 02
    05  VL_OPR  Valor da operac?o correspondente a combinac?o de CST_ICMS, CFOP, e aliquota do ICMS.  N   - 02
    06  VL_BC_ICMS  Parcela correspondente ao "Valor da base de calculo do ICMS" referente a combinac?o CST_ICMS, CFOP, e aliquota do ICMS  N   - 02
    07  VL_ICMS   Parcela correspondente ao "Valor do ICMS" referente a combinac?o CST_ICMS, CFOP e aliquota do ICMS  N   - 02
    08  VL_BC_ICMS_ST Valor da base de calculo do ICMS substituic?o tributaria  N   - 02
    09  VL_ICMS_ST  Valor do ICMS retido por substituic?o tributaria  N   - 02
    10  VL_RED_BC   Valor n?o tributado em func?o da reduc?o da base de calculo do ICMS, referente a combinac?o de CST_ICMS, CFOP e aliquota do ICMS..  N   - 02
    11  COD_OBS   Codigo da observac?o do lancamento fiscal (campo 02 do Registro 0460) C   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'C790';
    --/sem implementac?o
  end;

  --/REGISTRO C990: ENCERRAMENTO DO BLOCO C
  procedure pl_registro_c990 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "C990"  C   004   -
    02  QTD_LIN_C   Quantidade total de linhas do Bloco C   N   - -
    Observac?es: Registro obrigatorio
    Nivel hierarquico - 1
    Ocorrencia - um (por arquivo)
    */
    v_aux number;
  begin
    v_aux := fl_total_reg(vg_inic, 'C');
  
    vg_registro := 'C990';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || v_aux || vg_sep || vg_crlf;
  
    pl_gera_linha;
  
  end;

  --*************************************************************************************************************
  --*************************************************************************************************************
  --                                          BLOCO D:
  --                           DOCUMENTOS FISCAIS II - SERVICOS (ICMS)
  --*************************************************************************************************************
  --*************************************************************************************************************
  procedure pl_registro_d110;
  procedure pl_registro_d120;
  procedure pl_registro_d130;
  procedure pl_registro_d140;
  procedure pl_registro_d150;
  procedure pl_registro_d160;
  procedure pl_registro_d161;
  procedure pl_registro_d170;
  procedure pl_registro_d180;
  procedure pl_registro_d190;
  procedure pl_registro_d301;
  procedure pl_registro_d310;
  procedure pl_registro_d350;
  procedure pl_registro_d355;
  procedure pl_registro_d360;
  procedure pl_registro_d365;
  procedure pl_registro_d370;
  procedure pl_registro_d390;
  procedure pl_registro_d410;
  procedure pl_registro_d411;
  procedure pl_registro_d420;
  procedure pl_registro_d510;
  procedure pl_registro_d520;
  procedure pl_registro_d530;
  procedure pl_registro_d590;
  procedure pl_registro_d610;
  procedure pl_registro_d620;
  procedure pl_registro_d690;
  procedure pl_registro_d696;
  /*
    pl_registro_d365;
    pl_registro_d370;
    pl_registro_d390;
  */

  --/REGISTRO D001: ABERTURA DO BLOCO D
  procedure pl_registro_d001 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D001"  C   004   -
    02  IND_MOV   Indicador de movimento:
      0- Bloco com dados informados;
      1- Bloco sem dados informados   C   001   -
    Observac?es: Registro obrigatorio
    Nivel hierarquico - 1
    Ocorrencia - um (por arquivo)
    */
  begin
    vg_registro := 'D001';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || '0' || vg_sep || vg_crlf;
    pl_gera_linha;
  end;

  --/REGISTRO D100: NOTA FISCAL DE SERVICO DE TRANSPORTE (CODIGO 07) E CONHECIMENTOS
  --/DE TRANSPORTE RODOVIARIO DE CARGAS (CODIGO 08), AQUAVIARIO DE CARGAS (CODIGO 09),
  --/AEREO (CODIGO 10), FERROVIARIO DE CARGAS (CODIGO 11) E MULTIMODAL DE CARGAS (CODIGO 26)
  procedure pl_registro_d100 is
    /*
    N?    Campo       Descric?o Tipo  Tam Dec
    01  REG         Texto fixo contendo "D100"  C   004   -
    02  IND_OPER    Indicador do tipo de operac?o:
                  0- Aquisic?o;
                  1- Prestac?o  C   001   -
    03  IND_EMIT    Indicador do emitente do documento fiscal:
                  0- Emiss?o propria;
                  1- Terceiros  C   001   -
    04  COD_PART    Codigo do participante (campo 02 do Registro 0150):
                  - do prestador de servico, no caso de aquisic?o de servico;
                  - do tomador do servico, no caso de prestac?o de servicos. -  C   - -
    05  COD_MOD       Codigo do modelo do documento fiscal, conforme a Ta- bela 4.1.1 C   002   -
    06  COD_SIT       Codigo da situac?o do documento fiscal, conforme a Tabela 4.1.2 N   002   -
    07  SER         Serie do documento fiscal   C   - -
    08  SUB         Subserie do documento fiscal  N   - -
    09  NUM_DOC       Numero do documento fiscal  N   - -
    10  DT_DOC      Data da emiss?o do documento fiscal   N   008   -
    11  DT_A_P      Data da aquisic?o ou da prestac?o do servico  N   008   -
    12  VL_DOC      Valor total do documento fiscal   N   - 02
    13  VL_DESC       Valor total do desconto   N   - 02
    14  IND_FRT       Indicador do tipo do frete:
                0- Por conta de terceiros;
                1- Por conta do emitente;
                2- Por conta do destinatario;
                9- Sem frete  C   001   -
    15  VL_SERV       Valor total da prestac?o de servico   N   - 02
    16  VL_BC_ICMS    Valor da base de calculo do ICMS  N   - 02
    17  VL_ICMS       Valor do ICMS   N   - 02
    18  VL_NT       Valor n?o-tributado   N   - 02
    19  COD_INF       Codigo da informac?o complementar do documento fiscal (campo 02 do Registro 0450)   C   - -
    20  VL_PIS      Valor do PIS  N   - 02
    21  VL_COFINS     Valor da COFINS   N   - 02
    22  COD_CTA       Codigo da conta analitica contabil debitada/creditada C   - -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
    */
  
    cursor cr is
      select '0' ind_oper, --entrada
             '1' ind_emit, --terceiros
             to_char(n.dt_entrada, 'ddmmrrrr') dt_e_s,
             n.num_nota num_doc,
             n.cod_fornec cod_part,
             n.tipo_doc tipo_doc,
             fs_sped_utl.fb_cd_doctos(n.tipo_doc) cod_mod,
             fs_sped_utl.fb_situacao_docto(n.cod_cfo, n.situacao_nf) cod_sit,
             n.sr_nota ser,
             null sub_ser,
             to_char(n.dt_emissao, 'ddmmrrrr') dt_doc,
             n.vlr_nota vl_doc,
             0 vl_desc,
             n.vlr_nota vl_merc,
             n.vlr_servico vl_serv_nt,
             (nvl(n.vlr_despesa, 0)) vl_da,
             (nvl(n.vlr_bicms, 0)) vl_bc_icms,
             (nvl(n.vlr_icms, 0)) vl_icms,
             (nvl(n.vlr_pis_ret, 0)) vl_pis,
             (nvl(n.vl_cofins, 0)) vl_cofins,
             n.cod_cfo cod_cfo,
             n.dt_emissao dt_ref,
             null cod_inf,
             '1' ind_rec,
             fs_sped_utl.fb_conta_frete(n.empresa) cod_conta,
             fs_sped_utl.fb_ind_frt(n.situacao_frete) ind_frt,
             rownum num_item
        from ce_notas n
       where n.empresa = vg_emp
         and n.filial = vg_fil
            --and n.tipo_doc   = 3 -- somente notas fiscais
         and n.dt_entrada between vg_inic and vg_final
         and n.cod_cfo in
             (select cod_cfo from fs_cfos_sintegra where registro = 70);
  
  begin
  
    for reg in cr loop
      --/
      vg_registro := 'D100';
      vg_linha    := vg_sep || vg_registro || vg_sep; --01  REG
      vg_linha    := vg_linha || reg.ind_oper || vg_sep; --02   IND_OPER
      vg_linha    := vg_linha || reg.ind_emit || vg_sep; --03   IND_EMIT
      vg_linha    := vg_linha || reg.cod_part || vg_sep; --04   COD_PART
      vg_linha    := vg_linha || reg.cod_mod || vg_sep; --05   COD_MOD
      vg_linha    := vg_linha || reg.cod_sit || vg_sep; --06   COD_SIT
      vg_linha    := vg_linha || reg.ser || vg_sep; --07   SER
      vg_linha    := vg_linha || reg.sub_ser || vg_sep; --08   SUB
      vg_linha    := vg_linha || reg.num_doc || vg_sep; --09   NUM_DOC
      vg_linha    := vg_linha || reg.dt_doc || vg_sep; --10  DT_DOC
      vg_linha    := vg_linha || reg.dt_e_s || vg_sep; --11  DT_A_P
      vg_linha    := vg_linha || reg.vl_doc || vg_sep; --12  VL_DOC
      vg_linha    := vg_linha || reg.vl_desc || vg_sep; --13   VL_DESC
      vg_linha    := vg_linha || reg.ind_frt || vg_sep; --14   IND_FRT
      vg_linha    := vg_linha || reg.vl_serv_nt || vg_sep; --15   VL_SERV
      vg_linha    := vg_linha || reg.vl_bc_icms || vg_sep; --16   VL_BC_ICMS
      vg_linha    := vg_linha || reg.vl_icms || vg_sep; --17   VL_ICMS
      vg_linha    := vg_linha || reg.vl_doc || vg_sep; --18   VL_NT
      vg_linha    := vg_linha || reg.cod_inf || vg_sep; --19   COD_INF
      vg_linha    := vg_linha || reg.vl_pis || vg_sep; --20  VL_PIS
      vg_linha    := vg_linha || reg.vl_cofins || vg_sep; --21   VL_COFINS
      vg_linha    := vg_linha || reg.cod_conta || vg_sep || vg_crlf; --22  COD_CTA
    
      --/
      pl_gera_linha;
      --/
      pl_registro_d110;
      pl_registro_d120;
      pl_registro_d130;
      pl_registro_d140;
      pl_registro_d150;
      pl_registro_d160;
      pl_registro_d170;
      pl_registro_d180;
      pl_registro_d190;
      --/
    end loop;
  end;

  --/REGISTRO D110: ITENS do documento - NOTA FISCAL DE SERVICOS DE TRANSPORTE (CODIGO 07)
  procedure pl_registro_d110 is
    /*
    N?  Campo       Descric?o Tipo  Tam Dec
    01  REG       Texto fixo contendo "D110"  C   004   -
    02  NUM_ITEM  Numero sequencial do item no documento fiscal   N   - -
    03  COD_ITEM  Codigo do item (campo 02 do Registro 0200)  C   - -
    04  VL_SERV     Valor do servico  N   - 02
    05  VL_OUT    Outros valores  N   - 02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D110';
  end;

  --/REGISTRO D120: COMPLEMENTO DA NOTA FISCAL DE SERVICOS DE TRANSPORTE (CODIGO 07)
  procedure pl_registro_d120 is
    /*
    N?    Campo       Descric?o Tipo  Tam Dec
    01  REG         Texto fixo contendo "D120"  C   004   -
    02  COD_MUN_ORIG  Codigo do municipio de origem do servico, conforme a tabela IBGE  N   007   -
    03  COD_MUN_DEST  Codigo do municipio de destino, conforme a tabela IB-GE   N   007   -
    04  VEIC_ID       Placa de identificac?o do veiculo   C   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'D120';
  
  end;

  --/REGISTRO D130: COMPLEMENTO DO CONHECIMENTO RODOVIARIO DE CARGAS (CODIGO 08)
  procedure pl_registro_d130 is
    /*
    N?    Campo       Descric?o Tipo  Tam Dec
    01  REG       Texto fixo contendo "D130"  C   004   -
    02  COD_PART_CONSG  Codigo do participante (campo 02 do Registro 0150):
                  - consignatario, se houver  C   014   -
    03  COD_PART_RED  Codigo do participante (campo 02 do Registro 0150):
                  - redespachante, se houver  C   014   -
    04  IND_FRT_RED   Indicador do tipo do frete da operac?o de redespacho:
                  0 - Sem redespacho;
                  1 - Por conta do emitente;
                  2 - Por conta do destinatario;
                  9 - Outros.   C   001   -
    05  COD_MUN_ORIG  Codigo do municipio de origem do servico, conforme a tabela IBGE  N   007   -
    06  COD_MUN_DEST  Codigo do municipio de destino, conforme a tabela IBGE  N   007   -
    07  VEIC_ID     Placa de identificac?o do veiculo   C   - -
    08  VL_LIQ_FRT    Valor liquido do frete  N   - 02
    09  VL_SEC_CAT    Soma de valores de Sec/Cat (servicos de coleta/custo adicional de transporte)   N   - 02
    10  VL_DESP     Soma de valores de despacho   N   - 02
    11  VL_PEDG     Soma dos valores de pedagio   N   - 02
    12  VL_OUT      Outros valores  N   - 02
    13  VL_FRT      Valor total do frete  N   - 02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'D130';
    --FAZER
  end;

  --/REGISTRO D140: COMPLEMENTO DO CONHECIMENTO AQUAVIARIO DE CARGAS (CODIGO 09)
  procedure pl_registro_d140 is
    /*
    N?    Campo         Descric?o Tipo  Tam Dec
    01  REG         Texto fixo contendo "D140"  C   004   -
    02  COD_PART_CONSG    Codigo do participante (campo 02 do Registro 0150): - consignatario, se houver  C   014   -
    03  COD_MUN_ORIG    Codigo do municipio de origem do servico, conforme a tabela IBGE  N   007   -
    04  COD_MUN_DEST    Codigo do municipio de destino, conforme a tabela IBGE  N   007   -
    05  IND_VEIC        Indicador do tipo do veiculo transportador: 0- Embarcac?o; 1- Empurrador/rebocador  C   001   -
    06  VEIC_ID       Identificac?o da embarcac?o (IRIM ou Registro CPP)  C   - -
    07  IND_NAV       Indicador do tipo da navegac?o: 0- Interior; 1- Cabotagem   C   001   -
    08  VIAGEM        Numero da viagem  N   - -
    09  VL_FRT_LIQ      Valor liquido do frete  N   - 02
    10  VL_DESP_PORT    Valor das despesas portuarias   N   - 02
    11  VL_DESP_CAR_DESC  Valor das despesas com carga e descarga   N   - 02
    12  VL_OUT        Outros valores  N   - 02
    13  VL_FRT_BRT      Valor bruto do frete  N   - 02
    14  VL_FRT_MM     Valor adicional do frete para renovac?o da Marinha Mercante   N   - 02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'D140';
  end;

  --/REGISTRO D150: COMPLEMENTO DO CONHECIMENTO AEREO (CODIGO 10)
  procedure pl_registro_d150 is
    /*
    N?    Campo       Descric?o Tipo  Tam Dec
    01  REG         Texto fixo contendo "D150"  C   004   -
    02  COD_MUN_ORIG  Codigo do municipio de origem do servico, conforme a tabela IBGE  N   007   -
    03  COD_MUN_DEST  Codigo do municipio de destino, conforme a tabela IB-GE   N   007   -
    04  VEIC_ID       Identificac?o da aeronave (DAC)   C   - -
    05  VIAGEM      Numero do voo.  N   - -
    06  IND_TFA       Indicador do tipo de tarifa aplicada:
                  0- Exp.;
                  1- Enc.;
                  2- C.I.;
                  9- Outra  C   001   -
    07  VL_PESO_TX    Peso taxado   N   - 02
    08  VL_TX_TERR    Valor da taxa terrestre   N   - 02
    09  VL_TX_RED     Valor da taxa de redespacho   N   - 02
    10  VL_OUT      Outros valores  N   - 02
    11  VL_TX_ADV   Valor da taxa "ad valorem"  N   - 02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'D150';
  end;

  --/REGISTRO D160: CARGA TRANSPORTADA (CODIGO 07, 08, 09, 10, 11 E 26)
  procedure pl_registro_d160 is
    /*
    N?    Campo       Descric?o Tipo  Tam Dec
    01  REG         Texto fixo contendo "D160"  C   004   -
    02  CNPJ_CPF_REM  CNPJ ou CPF do remetente das mercadorias que constam na nota fiscal.  C   014   -
    03  UF_REM      Sigla da unidade da federac?o do remetente das mercadorias que constam na nota fiscal.  C   002   -
    04  IE_REM      Inscric?o Estadual do remetente das mercadorias que constam na nota fiscal.   C   - -
    05  CNPJ_CPF_DEST   CNPJ ou CPF do destinatario das mercadorias que constam na nota fiscal.   C   014   -
    06  UF_DEST       Sigla da unidade da federac?o do .destinatario das mercadorias que constam na nota fiscal.  C   002   -
    07  IE_DEST       Inscric?o Estadual do destinatario das mercadorias que constam na nota fiscal.  C   - -
    08  COD_MOD       Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1   C   002   -
    09  SER         Serie do documento fiscal   C   - -
    10  NUM_DOC       Numero do documento fiscal  N   - -
    11  DT_DOC      Data da emiss?o do documento fiscal   N   008   -
    12  CHV_NFE       Chave da Nota Fiscal Eletronica   N   044   -
    13  VL_DOC      Valor total do documento fiscal   N   - 02
    14  VL_MERC       Valor das mercadorias constantes no documento fiscal  N   - 02
    15  QTD_VOL       Quantidade de volumes transportados   N   - -
    16  PESO_BRT    Peso bruto dos volumes transportados (em Kg)  N   - -
    17  PESO_LIQ    Peso liquido dos volumes transportados (em Kg)  N   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D160';
    --FAZER
    pl_registro_d161;
  end;

  --/REGISTRO D161: LOCAL DA COLETA E ENTREGA (CODIGO 07, 08, 09, 10, 11 E 26)
  procedure pl_registro_d161 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D161"  C   004   -
    02  IND_CARGA   Indicador do tipo de transporte da carga coletada: 0 - Rodoviario;
    1 - Ferroviario;
    2 - Aquaviario;
    3 - Dutoviario;
    4 - Aereo;
    9 - Outros.   N   001   -
    03  CNPJ_COL  Numero do CNPJ do contribuinte do local de coleta   N   014   -
    04  IE_COL  Inscric?o Estadual do contribuinte do local de coleta   C   - -
    05  COD_MUN_COL   Codigo do Municipio do local de coleta, conforme Tabela IBGE  N   007   -
    07  CNPJ_ENTG   Numero do CNPJ do contribuinte do local de entrega  N   014   -
    08  IE_ENTG   Inscric?o Estadual do contribuinte do local de entrega  C   - -
    09  COD_MUN_ENTG  Codigo do Municipio do local de entrega, conforme Tabela IBGE   N   007   -
    Observac?es: Este registro so sera preenchido quando o local de coleta e/ou entrega for diferente do endereco do emitente e/ou destinatario.
    Nivel hierarquico - 4
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'D161';
    --FAZER
  end;

  --/REGISTRO D170: COMPLEMENTO DO CONHECIMENTO MULTIMODAL DE CARGAS (CODIGO 26)
  procedure pl_registro_d170 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG Texto fixo contendo "D170"  C   004   -
    02  COD_PART_CONSG  Codigo do participante (campo 02 do Registro 0150):
    - consignatario, se houver  C   014   -
    03  COD_PART_RED  Codigo do participante (campo 02 do Registro 0150):
    - redespachante, se houver  C   014   -
    04  COD_MUN_ORIG  Codigo do municipio de origem do servico, conforme a tabela IBGE  N   007   -
    05  COD_MUN_DEST  Codigo do municipio de destino, conforme a tabela IBGE -  N   007   -
    06  OTM Registro do operador de transporte multimodal   C   - -
    07  IND_NAT_FRT Indicador da natureza do frete:
    0- Negociavel;
    1- N?o negociavel   C   001   -
    08  VL_LIQ_FRT  Valor liquido do frete  N   - 02
    09  VL_GRIS Valor do gris (gerenciamento de risco)  N   - 02
    10  VL_PDG  Somatorio dos valores de pedagio  N   - 02
    11  VL_OUT  Outros valores  N   - 02
    12  VL_FRT  Valor total do frete  N   - 02
    13  VEIC_ID Placa de identificac?o do veiculo   C   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'D170';
  end;

  --/REGISTRO D180: MODAIS (CODIGO 26)
  procedure pl_registro_d180 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D180"  C   004   -
    02  NUM_SEQ   Numero de ordem sequencial do modal   N   - -
    03  IND_EMIT  Indicador do emitente do documento fiscal:
    0- Emiss?o propria;
    1- Terceiros  C   001   -
    04  CNPJ_EMIT   CNPJ do participante emitente do modal  N   014   -
    05  UF_EMIT   Sigla da unidade da federac?o do participante emitente do modal   C   002   -
    06  IE_EMIT   Inscric?o Estadual do participante emitente do modal  C   - -
    07  COD_MUN_ORIG  Codigo do municipio de origem do servico, conforme a tabela IBGE  N   007   -
    08  CNPJ_CPF_TOM  CNPJ/CPF do participante tomador do servico   N   014   -
    09  UF_TOM  Sigla da unidade da federac?o do participante tomador do servico  C   002   -
    10  IE_TOM  Inscric?o Estadual do participante tomador do servico   C   - -
    11  COD_MUN_DEST  Codigo do municipio de destino, conforme a tabela IB-GE(Preencher com 9999999, se Exterior)   N   007   -
    12  COD_MOD   Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1   C   002   -
    13  SER   Serie do documento fiscal   C   - -
    14  SUB   Subserie do documento fiscal  N   - -
    15  NUM_DOC   Numero do documento fiscal  N   - -
    16  DT_DOC  Data da emiss?o do documento fiscal   N   008   -
    17  VL_DOC  Valor total do documento fiscal   N   - 02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D180';
  end;

  --/REGISTRO D190: REGISTRO ANALITICO DOS DOCUMENTOS (CODIGO 07, 08, 09, 10, 11 E 26)
  procedure pl_registro_d190 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D190"  C   004   -
    02  CST_ICMS  Codigo da Situac?o Tributaria, conforme a tabela indicada no item 4.3.1 N   003   -
    03  CFOP  Codigo Fiscal de Operac?o e Prestac?o, conforme a tabela indicada no item 4.2.2 N   004   -
    04  ALIQ_ICMS   Aliquota do ICMS  N   - 02
    05  VL_OPR  Valor da operac?o correspondente a combinac?o de CST_ICMS, CFOP, e aliquota do ICMS.  N   - 02
    06  VL_BC_ICMS  Parcela correspondente ao "Valor da base de calculo do ICMS" referente a combinac?o CST_ICMS, CFOP, e aliquota do ICMS  N   - 02
    07  VL_ICMS   Parcela correspondente ao "Valor do ICMS" referente a combinac?o CST_ICMS, CFOP e aliquota do ICMS  N   - 02
    08  VL_RED_BC   Valor n?o tributado em func?o da reduc?o da base de calculo do ICMS, referente a combinac?o de CST_ICMS, CFOP e aliquota do ICMS. N   - 02
    09  COD_OBS   Codigo da observac?o do lancamento fiscal (campo 02 do Registro 0460) C   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'D190';
    --FAZER
  end;

  --/REGISTRO D300: REGISTRO ANALITICO DOS BILHETES CONSOLIDADOS DE PASSAGEM RODOVIARIO (CODIGO 13),
  --/DE PASSAGEM AQUAVIARIO (CODIGO 14), DE PASSAGEM E NOTA DE BAGAGEM (CODIGO 15) E DE PASSAGEM FERROVIARIO (CODIGO 16)
  procedure pl_registro_d300 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D300"  C   004   -
    02  COD_MOD   Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1   C   002   -
    03  SER   Serie do documento fiscal   C   - -
    04  SUB   Subserie do documento fiscal  N   - -
    05  NUM_DOC_INI   Numero do primeiro documento fiscal emitido (mesmo modelo, serie e subserie)  N   - -
    06  NUM_DOC_FIN Numero do ultimo documento fiscal emitido (mesmo modelo, serie e subserie)  N   - -
    07  CST_ICMS  Codigo da Situac?o Tributaria, conforme a Tabela indicada no item 4.3.1 N   003   -
    08  CFOP  Codigo Fiscal de Operac?o e Prestac?o preponderante   N   004   -
    09  ALIQ_ICMS   Aliquota do ICMS  N   - 02
    10  DT_DOC  Data da emiss?o dos documentos fiscais  N   008   -
    11  VL_OPR  Valor total acumulado das operac?es correspondentes a combinac?o de CST_ICMS, CFOP e aliquota do ICMS, incluidas as despesas acessorias e acrescimos. N   - 02
    12  VL_DESC   Valor total dos descontos   N   - 02
    13  VL_SERV   Valor total da prestac?o de servico   N   - 02
    14  VL_SEG  Valor de seguro   N   - 02
    15  VL_OUT DESP   Valor de outras despesas  N   - 02
    16  VL_BC_ICMS  Valor total da base de calculo do ICMS  N   - 02
    17  VL_ICMS   Valor total do ICMS   N   - 02
    18  VL_RED_BC   Valor n?o tributado em func?o da reduc?o da base de calculo do ICMS, referente a combinac?o de CST_ICMS, CFOP e aliquota do ICMS  N   - 02
    19  COD_OBS   Codigo da observac?o do lancamento fiscal (campo 02 do Registro 0460)   C   - -
    20  COD_CTA   Codigo da conta analitica contabil debitada/creditada C   - -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
    */
  begin
    vg_registro := 'D300';
  end;

  --/REGISTRO D301: DOCUMENTOS CANCELADOS DOS BILHETES DE PASSAGEM RODOVIARIO (CODIGO 13), DE PASSAGEM AQUAVIARIO (CODIGO 14),
  --/DE PASSAGEM E NOTA DE BAGAGEM (CODIGO 15) E DE PASSAGEM FERROVIARIO (CODIGO 16)
  procedure pl_registro_d301 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D301"  C   004   -
    02  NUM_DOC_CANC  Numero do documento fiscal cancelado  N   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - varios (por arquivo)
    */
  begin
    vg_registro := 'D301';
  end;

  --/REGISTRO D310: COMPLEMENTO DOS BILHETES (CODIGO 13, 14, 15 E 16)
  procedure pl_registro_d310 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D310"  C   004   -
    02  COD_MUN_ORIG  Codigo do municipio de origem do servico, conforme a tabela IBGE  N   007   -
    03  VL_SERV   Valor total da prestac?o de servico   N   - 02
    04  VL_BC_ICMS  Valor total da base de calculo do ICMS  N   - 02
    05  VL_ICMS   Valor total do ICMS   N   - 02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D310';
  end;

  --/REGISTRO D350 - EQUIPAMENTO ECF (CODIGOS 2E, 13, 14, 15 e 16)
  procedure pl_registro_d350 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D350"  C   004   -
    02  COD_MOD   Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1   C   002   -
    03  ECF_MOD   Modelo do equipamento   C   - -
    04  ECF_FAB   Numero de serie de fabricac?o do ECF  C   - -
    05  ECF_CX  Numero do caixa atribuido ao ECF  N   - -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D350';
    pl_registro_d355;
  end;

  --/REGISTRO D355 - REDUC?O Z (CODIGOS 2E, 13, 14, 15 e 16)
  procedure pl_registro_d355 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D355"  C   004   -
    02  DT_DOC  Data da Reduc?o Z   N   008   -
    03  CRO   Posic?o do Contador de Reinicio de Operac?o   N   - -
    04  CRZ   Posic?o do Contador de Reduc?o Z  N   - -
    05  NUM_COO_FIN   Numero do Contador de Ordem de Operac?o do ultimo documento emitido no dia. (Numero do COO na Reduc?o Z)  N   - -
    06  GT_FIN  Valor do Grande Total final   N   - 02
    07  VL_BRT  Valor da venda bruta  N   - 02
    Observac?es: Obrigatorio
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D355';
    pl_registro_d360;
    pl_registro_d365;
    pl_registro_d370;
    pl_registro_d390;
  end;

  --/REGISTRO D360: PIS E COFINS TOTALIZADOS NO DIA (CODIGOS 2E, 13, 14, 15 e 16)
  procedure pl_registro_d360 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D360"  C   004   -
    02  VL_PIS  Valor total do PIS  N   - 02
    03  VL_COFINS   Valor total da COFINS   N   - 02
    Observac?es: Obrigatorio
    Nivel hierarquico - 4
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'D360';
  end;

  --/REGISTRO D365: REGISTRO DOS TOTALIZADORES PARCIAIS DA REDUC?O Z (CODIGOS 2E, 13, 14, 15 e 16)
  procedure pl_registro_d365 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG Texto fixo contendo "D365"  C   004   -
    02  COD_TOT_PAR Codigo do totalizador, conforme Tabela 4.4.6  C   005   -
    03  VLR_ACUM_TOT  Valor acumulado no totalizador, relativo a respectiva Reduc?o Z.  N   - 02
    04  NR_TOT  Numero do totalizador quando ocorrer mais de uma situac?o com a mesma carga tributaria efetiva.   N   002   -
    05  DESCR_NR_TOT  Descric?o da situac?o tributaria relativa ao totalizador parcial, quando houver mais de um com a mesma carga tributaria efetiva.  C   - -
    Observac?es: Obrigatorio
    Nivel hierarquico - 4
    Ocorrencia - varios (por arquivo)
    */
  begin
    vg_registro := 'D365';
  end;

  --/REGISTRO D370: COMPLEMENTO DOS DOCUMENTOS INFORMADOS (CODIGO 13, 14, 15, 16 E 2E)
  procedure pl_registro_d370 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D370"  C   004   -
    02  COD_MUN_ORI GCodigo do municipio de origem do servico, conforme a tabela IBGE   N   007   -
    03  VL_SERV   Valor total da prestac?o de servico   N   - 02
    04  QTD_BILH  Quantidade de bilhetes emitidos   N   - -
    05  VL_BC_ICMS  Valor total da base de calculo do ICMS  N   - 02
    06  VL_ICMS   Valor total do ICMS   N   - 02
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D370';
  end;

  --/REGISTRO D390: REGISTRO ANALITICO DO MOVIMENTO DIARIO (CODIGOS 13, 14, 15, 16 E 2E)
  procedure pl_registro_d390 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D390"  C   004   -
    02  CST_ICMS  Codigo da Situac?o Tributaria, conforme a Tabela indicada no item 4.3.1.  N   003   -
    03  CFOP  Codigo Fiscal de Operac?o e Prestac?o   N   004   -
    04  ALIQ_ICMS   Aliquota do ICMS  N   - 02
    05  VL_OPR  Valor da operac?o correspondente a combinac?o de CST_ICMS, CFOP, e aliquota do ICMS, incluidas as despesas acessorias e acrescimos  N   - 02
    06  VL_BC_ISSQN   Valor da base de calculo do ISSQN   N   - 02
    07  ALIQ_ISSQN  Aliquota do ISSQN   N   - 02
    08  VL_ISSQN  Valor do ISSQN  N   - 02
    09  VL_BC_ICMS  Base de calculo do ICMS acumulada relativa a aliquota informada   N   - 02
    10  VL_ICMS   Valor do ICMS acumulado relativo a aliquota informada   N   - 02
    11  COD_OBS   Codigo da observac?o do lancamento fiscal (campo 02 do Registro 0460) C   - -
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D390';
  end;

  --/REGISTRO D400: RESUMO DE MOVIMENTO DIARIO (CODIGO 18)
  procedure pl_registro_d400 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D400"  C   004   -
    02  COD_PART  Codigo do participante (campo 02 do Registro 0150): - agencia, filial ou posto  C   - -
    03  COD_MOD   Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1 C   002   -
    04  COD_SIT   Codigo da situac?o do documento fiscal, conforme a Tabela 4.1.2 N   002   -
    05  SER   Serie do documento fiscal   C   - -
    06  SUB   Subserie do documento fiscal  N   - -
    07  NUM_DOC   Numero do documento fiscal resumo.  N   - -
    08  DT_DOC  Data da emiss?o do documento fiscal   N   008   -
    09  VL_DOC  Valor total do documento fiscal   N   - 02
    10  VL_DESC   Valor acumulado dos descontos   N   - 02
    11  VL_SERV   Valor acumulado da prestac?o de servico   N   - 02
    12  VL_BC_ICMS  Valor total da base de calculo do ICMS  N   - 02
    13  VL_ICMS   Valor total do ICMS   N   - 02
    14  VL_PIS  Valor do PIS  N   - 02
    15  VL_COFINS   Valor da COFINS   N   - 02
    16  COD_CTA   Codigo da conta analitica contabil debitada/creditada C   - -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
    */
  begin
    vg_registro := 'D400';
  
    pl_registro_d410;
  end;

  --/REGISTRO D410: DOCUMENTOS INFORMADOS (CODIGOS 13, 14, 15 E 16)
  procedure pl_registro_d410 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D410"  C   004   -
    02  COD_MOD   Codigo do modelo do documento fiscal , conforme a Tabela 4.1.1  C   002   -
    03  SER   Serie do documento fiscal   C   - -
    04  SUB   Subserie do documento fiscal  N   - -
    05  NUM_DOC_INI   Numero do documento fiscal inicial (mesmo modelo, serie e subserie)   N   - -
    06  NUM_DOC_FIN   Numero do documento fiscal final(mesmo modelo, serie e subserie)  N   - -
    07  DT_DOC  Data da emiss?o dos documentos fiscais  N   008   -
    08  CST_ICMS  Codigo da Situac?o Tributaria, conforme a Tabela indicada no item 4.3.1   N   003   -
    09  CFOP  Codigo Fiscal de Operac?o e Prestac?o   N   004   -
    10  ALIQ_ICMS   Aliquota do ICMS  N   - 02
    11  VL_OPR  Valor total acumulado das operac?es correspondentes a combinac?o de CST_ICMS, CFOP e aliquota do ICMS, incluidas as despesas acessorias e acrescimos.   N   - 02
    12  VL_DESC   Valor acumulado dos descontos   N   - 02
    13  VL_SERV   Valor acumulado da prestac?o de servico   N   - 02
    14  VL_BC_ICMS  Valor acumulado da base de calculo do ICMS  N   - 02
    15  VL_ICMS   Valor acumulado do ICMS   N   - 02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D410';
    pl_registro_d411;
  end;

  --/REGISTRO D411: DOCUMENTOS CANCELADOS DOS DOCUMENTOS INFORMADOS (CODIGOS 13, 14, 15 E 16)
  procedure pl_registro_d411 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D411"  C   004   -
    02  NUM_DOC_CANC  Numero do documento fiscal cancelado  N   - -
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - varios (por arquivo)
    */
  begin
    vg_registro := 'D411';
  end;

  --/REGISTRO D420: COMPLEMENTO DOS DOCUMENTOS INFORMADOS(CODIGOS 13, 14, 15 E 16)
  procedure pl_registro_d420 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D420"  C   004   -
    02  COD_MUN_ORIG  Codigo do municipio de origem do servico, conforme a tabela IBGE  N   007   -
    03  VL_SERV   Valor total da prestac?o de servico   N   - 02
    04  VL_BC_ICMS  Valor total da base de calculo do ICMS  N   - 02
    05  VL_ICMS   Valor total do ICMS   N   - 02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D420';
  end;

  --/REGISTRO D500: NOTA FISCAL DE SERVICO DE COMUNICAC?O (CODIGO 21) E NOTA FISCAL DE SERVICO DE TELECOMUNICAC?O (CODIGO 22)
  procedure pl_registro_d500 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D500"  C   004   -
    02  IND_OPER  Indicador do tipo de operac?o: 0- Aquisic?o; 1- Prestac?o   C   001   -
    03  IND_EMIT  Indicador do emitente do documento fiscal:
      0- Emiss?o propria;
      1- Terceiros  C   001   -
    04  COD_PART  Codigo do participante (campo 02 do Registro 0150):
        - do prestador do servico, no caso de aquisic?o;
        - do tomador do servico, no caso de prestac?o.  C   - -
    05  COD_MOD   Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1   C   002   -
    06  COD_SIT   Codigo da situac?o do documento fiscal, conforme a Tabela 4.1.2   N   002   -
    07  SER   Serie do documento fiscal   C   - -
    08  SUB   Subserie do documento fiscal  N   - -
    09  NUM_DOC   Numero do documento fiscal  N   - -
    10  DT_DOC  Data da emiss?o do documento fiscal   N   008   -
    11  DT_A_P  Data da entrada (aquisic?o) ou da saida (prestac?o do servico)  N   008   -
    12  VL_DOC  Valor total do documento fiscal   N   - 02
    13  VL_DESC   Valor total do desconto   N   - 02
    14  VL_SERV   Valor da prestac?o de servicos  N   - 02
    15  VL_SERV_NT  Valor total dos servicos n?o-tributados pelo ICMS   N   - 02
    16  VL_TERC   Valores cobrados em nome de terceiros   N   - 02
    17  VL_DA   Valor de outras despesas indicadas no documento fiscal  N   - 02
    18  VL_BC_ICMS  Valor da base de calculo do ICMS  N   - 02
    19  VL_ICMS   Valor do ICMS   N   - 02
    20  COD_INF   Codigo da informac?o complementar (campo 02 do Registro 0450)   C   - -
    21  VL_PIS  Valor do PIS  N   - 02
    22  VL_COFINS   Valor da COFINS   N   - 02
    23  COD_CTA   da conta analitica contabil   C   - -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
    */
  begin
    vg_registro := 'D500';
    pl_registro_d510;
    pl_registro_d520;
    pl_registro_d530;
    pl_registro_d590;
  end;

  --/REGISTRO D510: ITENS DO DOCUMENTO - NOTA FISCAL DE SERVICO DE COMUNICAC?O (CODIGO 21) E SERVICO DE TELECOMUNICAC?O (CODIGO 22)
  procedure pl_registro_d510 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D510"  C   004   -
    02  NUM_ITEM  Numero sequencial do item no documento fiscal   N   - -
    03  COD_ITEM  Codigo do item (campo 02 do Registro 0200)  C   - -
    04  COD_CLASS   Codigo de classificac?o do item do servico de comunicac?o ou de telecomunicac?o, conforme a Tabela 4.4.1  N   004   -
    05  QTD   Quantidade do item  N   - 03
    06  UNID  Unidade do item (Campo 02 do registro 0190)   C   - -
    07  VL_ITEM   Valor do item   N   - 02
    08  VL_DESC   Valor total do desconto   N   - 02
    09  CST_ICMS  Codigo da Situac?o Tributaria, conforme a Tabela indicada no item 4.3.1   N   003   -
    10  CFOP  Codigo Fiscal de Operac?o e Prestac?o   N   004   -
    11  VL_BC_ICMS  Valor da base de calculo do ICMS  N   - 02
    12  ALIQ_ICMS   Aliquota do ICMS  N   - 02
    13  VL_ICMS   Valor do ICMS creditado/debitado  N   - 02
    14  VL_BC_ICMS_ST Valor da base de calculo do ICMS substituic?o tributaria  N   - 02
    15  VL_ICMS_ST  Valor do ICMS retido por substituic?o tributaria  N   - 02
    16  IND_REC   Indicador do tipo de receita:
    0- Receita propria - servicos prestados;
    1- Receita propria - cobranca de debitos;
    2- Receita propria - venda de mercadorias;
    3- Receita propria - venda de servico pre-pago;
    4- Outras receitas proprias;
    5- Receitas de terceiros (co-faturamento);
    9- Outras receitas de terceiros   C   001   -
    17  COD_PART  Codigo do participante (campo 02 do Registro 0150) receptor da receita, terceiro da operac?o, se houver.  C   - -
    18  VL_PIS  Valor do PIS  N   - 02
    19  VL_COFINS   Valor da COFINS   N   - 02
    20  COD_CTA   Codigo da conta analitica contabil debitada/creditada C   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D510';
  end;

  --/REGISTRO D520: COMPLEMENTO DO DOCUMENTO - DADOS ADICIONAIS (CODIGO 21 E 22)
  procedure pl_registro_d520 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D520"  C   004   -
    02  VL_FCP  Valor do ICMS resultante da aliquota adicional dos itens incluidos no Fundo de Combate a Pobreza  N   - 02
    03  IND_F0  Indicador de nota fiscal recebida/destinada de/a partici-pante do Programa Fome Zero:
    0- N?o;
    1- Sim  C   001   -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'D520';
  end;

  --/REGISTRO D530: TERMINAL FATURADO
  procedure pl_registro_d530 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG Texto fixo contendo "D530"  C   004   -
    02  IND_SERV  Indicador do tipo de servico prestado:
    0- Telefonia;
    1- Comunicac?o de dados;
    2- TV por assinatura;
    3- Provimento de acesso a Internet;
    4- Multimidia;
    9- Outros   C   001   -
    03  DT_INI_SERV Data em que se iniciou a prestac?o do servico   N   008   -
    04  DT_FIN_SERV Data em que se encerrou a prestac?o do servico  N   008   -
    05  PER_FISCAL  Periodo fiscal da prestac?o do servico (MMAAAA)   N   006   -
    06  COD_AREA  Codigo de area do terminal faturado, proprio da prestadora  C   - -
    07  TERMINAL  Identificac?o do terminal faturado  N   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D530';
  end;

  --/REGISTRO D590: REGISTRO ANALITICO DO DOCUMENTO (CODIGO 21 E 22)
  procedure pl_registro_d590 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D590"  C   004   -
    02  CST_ICMS  Codigo da Situac?o Tributaria, conforme a tabela indicada no item 4.3.1   N   003   -
    03  CFOP  Codigo Fiscal de Operac?o e Prestac?o, conforme a tabela indicada no item 4.2.2   N   004   -
    04  ALIQ_ICMS   Aliquota do ICMS  N   - 02
    05  VL_OPR  Valor da operac?o correspondente a combinac?o de CST_ICMS, CFOP, e aliquota do ICMS, incluidas as despesas acessorias e acrescimos  N   - 02
    06  VL_BC_ICMS  Parcela correspondente ao "Valor da base de calculo do ICMS" referente a combinac?o CST_ICMS, CFOP, e aliquota do ICMS  N   - 02
    07  VL_ICMS   Parcela correspondente ao "Valor do ICMS" referente a combinac?o CST_ICMS, CFOP, e aliquota do ICMS   N   - 02
    08  VL_BC_ICMS_ST Parcela correspondente ao "Valor da base de calculo do ICMS" da substituic?o tributaria referente a combinac?o de CST_ICMS, CFOP e aliquota do ICMS.  N   - 02
    09  VL_ICMS_ST  Parcela correspondente ao valor creditado/debitado do ICMS da substituic?o tributaria, referente a combinac?o de CST_ICMS, CFOP, e aliquota do ICMS.  N   - 02
    10  VL_RED_BC   Valor n?o tributado em func?o da reduc?o da base de cal-culo do ICMS, referente a combinac?o de CST_ICMS, CFOP e aliquota do ICMS.  N   - 02
    11  COD_OBS   Codigo da observac?o (campo 02 do Registro 0460)  C   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D590';
  end;

  --/REGISTRO D600: CONSOLIDAC?O DA PRESTAC?O DE SERVICOS - NOTAS DE SERVICO DE COMUNICAC?O (CODIGO 21) E DE SERVICO DE TELECOMUNICAC?O (CODIGO 22)
  procedure pl_registro_d600 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D600"  C   004   -
    02  COD_MOD   Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1   C   002   -
    03  COD_MUN   Codigo do municipio dos terminais faturados, conforme a tabela IBGE   N   007   -
    04  SER   Serie do documento fiscal   C   - -
    05  SUB   Subserie do documento fiscal  N   - -
    06  COD_CONS  Codigo de classe de consumo dos servicos de comunicac?o ou de telecomunicac?o, conforme a Tabela 4.4.4  N   002   -
    07  QTD_CONS  Quantidade de documentos consolidados neste registro  N   - -
    08  DT_DOC  Data dos documentos consolidados  N   008   -
    09  VL_DOC  Valor total acumulado dos documentos fiscais  N   - 02
    10  VL_DESC   Valor acumulado dos descontos   N   - 02
    11  VL_SERV   Valor acumulado das prestac?es de servicos tributados pelo ICMS   N   - 02
    12  VL_SERV_NT  Valor acumulado dos servicos n?o-tributados pelo ICMS   N   - 02
    13  VL_TERC   Valores cobrados em nome de terceiros   N   - 02
    14  VL_DA   Valor acumulado das despesas acessorias   N   - 02
    15  VL_BC_ICMS  Valor acumulado da base de calculo do ICMS  N   - 02
    16  VL_ICMS   Valor acumulado do ICMS   N   - 02
    17  VL_PIS  Valor do PIS  N   - 02
    18  VL_COFINS   Valor da COFINS   N   - 02
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
    */
  begin
    vg_registro := 'D600';
    pl_registro_d610;
    pl_registro_d620;
    pl_registro_d690;
  end;

  --/REGISTRO D610: ITENS DO DOCUMENTO CONSOLIDADO (CODIGO 21 E 22)
  procedure pl_registro_d610 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D610"  C   004   -
    02  COD_CLASS   Codigo de classificac?o do item do servico de comunicac?o ou de telecomunicac?o, conforme a Tabela 4.4.1  N   004   -
    03  COD_ITEM  Codigo do item (campo 02 do Registro 0200)  C   - -
    04  QTD   Quantidade acumulada do item  N   - 03
    05  UNID  Unidade do item (Campo 02 do registro 0190)   C   - -
    06  VL_ITEM   Valor acumulado do item   N   - -
    07  VL_DESC   Valor acumulado dos descontos   N   - 02
    08  CST_ICMS  Codigo da Situac?o Tributaria, conforme a Tabela indicada no item 4.3.1   N   003   -
    09  CFOP  Codigo Fiscal de Operac?o e Prestac?o preponderante   N   004   -
    10  ALIQ_ICMS   Aliquota do ICMS  N   006   02
    11  VL_BC_ICMS  Valor acumulado da base de calculo do ICMS  N   - 02
    12  VL_ICMS   Valor acumulado do ICMS debitado  N   - 02
    13  VL_BC_ICMS_ST Valor da base de calculo do ICMS substituic?o tributaria  N   - 02
    14  VL_ICMS_ST  Valor do ICMS retido por substituic?o tributaria  N   - 02
    15  VL_RED_BC   Valor n?o tributado em func?o da reduc?o da base de calculo do ICMS, referente a combinac?o de CST_ICMS, CFOP e aliquota do ICMS.   N   - 02
    16  VL_PIS  Valor acumulado do PIS  N   - 02
    17  VL_COFINS   Valor acumulado da COFINS   N   - 02
    18  COD_CTA   Codigo da conta analitica contabil debitada/creditada C   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D510';
  end;

  --/REGISTRO D620: COMPLEMENTO DO DOCUMENTO - DADOS ADICIONAIS (CODIGO 21 E 22)
  procedure pl_registro_d620 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D620"  C   004   -
    02  VL_FCP  Valor do ICMS resultante da aliquota adicional dos itens incluidos no Fundo de Combate a Pobreza  N   - 02
    03  IND_F0  Indicador de nota fiscal recebida/destinada de/a participante do Programa Fome Zero:
    0- N?o;
    1- Sim  C   001   -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
  begin
    vg_registro := 'D620';
  end;

  --/REGISTRO D690: REGISTRO ANALITICO DOS DOCUMENTOS (CODIGOS 21 e 22)
  procedure pl_registro_d690 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D690"  C   004   -
    02  CST_ICMS  Codigo da Situac?o Tributaria, conforme a tabela indicada no item 4.3.1   N   003   -
    03  CFOP  Codigo Fiscal de Operac?o e Prestac?o, conforme a tabela indicada no item 4.2.2   N   004   -
    04  ALIQ_ICMS   Aliquota do ICMS  N   - 02
    05  VL_OPR  Valor da operac?o correspondente a combinac?o de CST_ICMS, CFOP, e aliquota do ICMS, incluidas as despesas acessorias e acrescimos  N   - 02
    06  VL_BC_ICMS  Parcela correspondente ao "Valor da base de calculo do ICMS" referente a combinac?o CST_ICMS, CFOP, e aliquota do ICMS  N   - 02
    07  VL_ICMS   Parcela correspondente ao "Valor do ICMS" referente a combinac?o CST_ICMS, CFOP, e aliquota do ICMS   N   - 02
    08  VL_BC_ICMS_ST Parcela correspondente ao "Valor da base de calculo do ICMS" da substituic?o tributaria referente a combinac?o de CST_ICMS, CFOP e aliquota do ICMS.  N   - 02
    09  VL_ICMS_ST  Parcela correspondente ao valor creditado/debitado do ICMS da substituic?o tributaria, referente a combinac?o de CST_ICMS, CFOP, e aliquota do ICMS.  N   - 02
    10  VL_RED_BC   Valor n?o tributado em func?o da reduc?o da base de calculo do ICMS, referente a combinac?o de CST_ICMS, CFOP e aliquota do ICMS.   N   - 02
    11  COD_OBS   Codigo da observac?o do lancamento fiscal (campo 02 do Registro 0460) C   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D690';
  end;

  --/REGISTRO D695: CONSOLIDAC?O DA PRESTAC?O DE SERVICOS - NOTAS DE SERVICO DE COMUNICAC?O (CODIGO 21) E DE SERVICO DE TELECOMUNICAC?O (CODIGO 22)
  procedure pl_registro_d695 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D695"  C   004   -
    02  COD_MOD   Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1   C   002   -
    03  SER   Serie do documento fiscal   C   - -
    04  NRO_ORD_INI   Numero de ordem inicial   N   - -
    05  NRO_ORD_FIN   Numero de ordem final   N   - -
    06  DT_DOC_INI  Data de emiss?o inicial dos documentos  N   008   -
    07  DT_DOC_FIN  Data de emiss?o final dos documentos  N   008   -
    08  NOM_VOL   Nome do Volume do arquivo Mestre de Documento Fiscal  C   015   -
    09  CHV_COD_DIG   Chave de codificac?o digital do arquivo Mestre de Documento Fiscal  C   032   -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - Varios (por arquivo)
    */
  begin
    vg_registro := 'D695';
    pl_registro_d696;
  end;

  --/REGISTRO D696: REGISTRO ANALITICO DOS DOCUMENTOS (CODIGO 21 E 22)
  procedure pl_registro_d696 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D696"  C   004   -
    02  CST_ICMS  Codigo da Situac?o Tributaria, conforme a tabela indicada no item 4.3.1   N   003   -
    03  CFOP  Codigo Fiscal de Operac?o e Prestac?o, conforme a Tabela indicada no item 4.2.2   N   004   -
    04  ALIQ_ICMS   Aliquota do ICMS  N   - 02
    05  VL_OPR  Valor da operac?o correspondente a combinac?o de CST_ICMS, CFOP, e aliquota do ICMS, incluidas as despesas acessorias e acrescimos  N   - 02
    06  VL_BC_ICMS  Parcela correspondente ao "Valor da base de calculo do ICMS" referente a combinac?o CST_ICMS, CFOP, e aliquota do ICMS  N   - 02
    07  VL_ICMS   Parcela correspondente ao "Valor do ICMS" referente a combinac?o CST_ICMS, CFOP, e aliquota do ICMS   N   - 02
    08  VL_BC_ICMS_ST Valor da base de calculo do ICMS substituic?o tributaria  N   - 02
    09  VL_ICMS_ST  Valor do ICMS retido por substituic?o tributaria  N   - 02
    10  VL_RED_BC   Valor n?o tributado em func?o da reduc?o da base de calculo do ICMS, referente a combinac?o de CST_ICMS, CFOP e aliquota do ICMS. N   - 02
    11  COD_OBS   Codigo da observac?o do lancamento fiscal (campo 02 do Registro 0460) C   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'D696';
  end;

  --/REGISTRO D990: ENCERRAMENTO DO BLOCO D
  procedure pl_registro_d990 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "D990"  C   004   -
    02  QTD_LIN_D   Quantidade total de linhas do Bloco D   N   - -
    Observac?es: Registro obrigatorio
    Nivel hierarquico - 1
    Ocorrencia - um (por arquivo)
    */
    v_aux number(9);
  begin
  
    vg_registro := 'D990';
    v_aux       := fl_total_reg(vg_inic, 'D');
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || v_aux || vg_sep || vg_crlf;
  
    pl_gera_linha;
  end;

  --*************************************************************************************************************
  --*************************************************************************************************************
  --                                          BLOCO E:
  --                                  APURAC?O DO ICMS E DO IPI
  --*************************************************************************************************************
  --*************************************************************************************************************

  procedure pl_registro_e110;
  procedure pl_registro_e111;
  procedure pl_registro_e115;
  procedure pl_registro_e116;
  procedure pl_registro_e112;
  procedure pl_registro_e113;
  procedure pl_registro_e220;
  procedure pl_registro_e250;
  procedure pl_registro_e230;
  procedure pl_registro_e240;
  procedure pl_registro_e510;
  procedure pl_registro_e520;
  procedure pl_registro_e530;

  --/REGISTRO E001: ABERTURA DO BLOCO E
  procedure pl_registro_e001 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "E001"  C   004   -
    02  IND_MOV   Indicador de movimento:
      0- Bloco com dados informados;
      1- Bloco sem dados informados   C   001   -
    Observac?es: Registro obrigatorio
    Nivel hierarquico - 1
    Ocorrencia - um (por arquivo)
    */
  begin
    vg_registro := 'E001';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || '1' || vg_sep || vg_crlf;
  
    pl_gera_linha;
  end;

  --/REGISTRO E100: PERIODO DA APURAC?O DO ICMS
  procedure pl_registro_e100 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "E100"  C   004   -
    02  DT_INI  Data inicial a que a apurac?o se refere   N   008   -
    03  DT_FIN  Data final a que a apurac?o se refere N   008   -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'E100';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || to_char(vg_inic, 'ddmmrrrr') || vg_sep;
    vg_linha    := vg_linha || to_char(vg_final, 'ddmmrrrr') || vg_sep ||
                   vg_crlf;
  
    pl_gera_linha;
  
    pl_registro_e110;
  end;

  --/REGISTRO E110: APURAC?O DO ICMS - OPERAC?ES PROPRIAS
  procedure pl_registro_e110 is
    /*
    N?    Campo               Descric?o                                               Tipo  Tam Dec
    01  REG               Texto fixo contendo "E110"                                    C     004   -
    02  VL_TOT_DEBITOS          Valor total dos debitos por "Saidas e prestac?es com debito do imposto"       N     -   02
    03  VL_AJ_DEBITOS         Valor total dos ajustes a debito decorrentes do documento fiscal.           N     -   02
    04  VL_TOT_AJ_DEBITOS       Valor total de "Ajustes a debito"                                 N     -   02
    05  VL_ESTORNOS_CRED        Valor total de Ajustes "Estornos de creditos"                         N     -   02
    06  VL_TOT_CREDITOS       Valor total dos creditos por "Entradas e aquisic?es com credito do imposto"     N     -   02
    07  VL_AJ_CREDITOS          Valor total dos ajustes a credito decorrentes do documento fiscal.          N     -   02
    08  VL_TOT_AJ_CREDI-TOS     Valor total de "Ajustes a credito"                                N     -   02
    09  VL_ESTORNOS_DEB       Valor total de Ajustes "Estornos de Debitos"                        N     -   02
    10  VL_SLD_CRE-DOR_ANT      Valor total de "Saldo credor do periodo anterior"                       N     -   02
    11  VL_SLD_APURADO          Valor total de "Saldo devedor (02+03+04+05-06-07-08-09-10) antes das deduc?es"  N     -   02
    12  VL_TOT_DED            Valor total de "Deduc?es"                                       N     -   02
    13  VL_ICMS_RECOLHER        Valor total de "ICMS a recolher (11-12)                             N     -   02
    14  VL_SLD_CRE-DOR_TRANSPORTAR  Valor total de "Saldo credor a transportar para o periodo seguinte"           N     -   02
    15  DEB_ESP             Valores recolhidos ou a recolher, extra-apurac?o.                       N     -   02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - um (por periodo)
    */
    cursor cr is
      select nvl(db_saidas, 0) vl_tot_deb,
             nvl(db_outros, 0) vl_aj_debitos,
             0 vl_tot_aj_debitos,
             a.db_estorno_cr vl_estornos_cred,
             a.cr_entrada vl_tot_creditos,
             a.cr_outros vl_aj_creditos,
             0 vl_tot_aj_creditos,
             a.cr_estorno_db vl_estorno_deb,
             a.saldo_cr vl_sld_credor_ant,
             (nvl(db_saidas, 0) + nvl(db_outros, 0) + nvl(db_estorno_cr, 0) -
             nvl(a.cr_entrada, 0) - nvl(a.cr_outros, 0) -
             nvl(a.saldo_cr, 0)) vl_sld_apurado,
             nvl(a.deducoes, 0) vl_tot_ded,
             0 deb_esp
        from fs_apura_icms a
       where a.data_ate = vg_final
         and a.empresa = vg_emp
         and a.filial = vg_fil;
  
    vl_tot_deb         number(15, 2);
    vl_aj_debitos      number(15, 2);
    vl_tot_aj_debitos  number(15, 2);
    vl_estornos_cred   number(15, 2);
    vl_tot_creditos    number(15, 2);
    vl_aj_creditos     number(15, 2);
    vl_tot_aj_creditos number(15, 2);
    vl_estorno_deb     number(15, 2);
    vl_sld_credor_ant  number(15, 2);
    vl_sld_apurado     number(15, 2);
    vl_tot_ded         number(15, 2);
    vl_deb_esp         number(15, 2);
    vl_icms_recolher   number(15, 2);
    vl_sld_credor_tra  number(15, 2);
  
  begin
  
    open cr;
    fetch cr
      into vl_tot_deb,
           vl_aj_debitos,
           vl_tot_aj_debitos,
           vl_estornos_cred,
           vl_tot_creditos,
           vl_aj_creditos,
           vl_tot_aj_creditos,
           vl_estorno_deb,
           vl_sld_credor_ant,
           vl_sld_apurado,
           vl_tot_ded,
           vl_deb_esp;
    close cr;
  
    --/ feitos estes ajustes para n?o informar valores extras que exigem mudanca no processo de apurac?o do icms
  
    vl_tot_deb       := nvl(vl_tot_deb, 0) + nvl(vl_aj_debitos, 0) +
                        nvl(vl_estornos_cred, 0);
    vl_aj_debitos    := 0;
    vl_estornos_cred := 0;
    vl_tot_creditos  := nvl(vl_tot_creditos, 0) + nvl(vl_aj_creditos, 0) +
                        nvl(vl_estorno_deb, 0);
    vl_aj_creditos   := 0;
    vl_estorno_deb   := 0;
  
    --/ fim dos ajustes
  
    vl_icms_recolher := nvl(vl_sld_apurado, 0) - nvl(vl_tot_ded, 0);
  
    if vl_icms_recolher < 0 then
      vl_sld_credor_tra := abs(vl_icms_recolher);
      vl_icms_recolher  := 0;
    else
      vl_sld_credor_tra := 0;
    end if;
  
    vg_registro := 'E110';
  
    vg_linha := vg_sep || vg_registro || vg_sep;
    vg_linha := vg_linha || vl_tot_deb || vg_sep;
    vg_linha := vg_linha || vl_aj_debitos || vg_sep;
    vg_linha := vg_linha || vl_tot_aj_debitos || vg_sep;
    vg_linha := vg_linha || vl_estornos_cred || vg_sep;
    vg_linha := vg_linha || vl_tot_creditos || vg_sep;
    vg_linha := vg_linha || vl_aj_creditos || vg_sep;
    vg_linha := vg_linha || vl_tot_aj_debitos || vg_sep;
    vg_linha := vg_linha || vl_estorno_deb || vg_sep;
    vg_linha := vg_linha || vl_sld_credor_ant || vg_sep;
    vg_linha := vg_linha || vl_sld_apurado || vg_sep;
    vg_linha := vg_linha || vl_tot_ded || vg_sep;
    vg_linha := vg_linha || vl_icms_recolher || vg_sep;
    vg_linha := vg_linha || vl_sld_credor_tra || vg_sep;
    vg_linha := vg_linha || vl_deb_esp || vg_sep || vg_crlf;
  
    --|E110|3887738,23|0|0|0|6733745,09|0|0|0|29090915,36|-31936922,22|0|0|31936922,22|0|
  
    pl_gera_linha;
  
    pl_registro_e111;
    pl_registro_e115;
    pl_registro_e116;
  end;

  --/REGISTRO E111: AJUSTE/BENEFICIO/INCENTIVO DA APURAC?O DO ICMS
  procedure pl_registro_e111 is
    /*
    N?    Campo         Descric?o Tipo  Tam Dec
    01  REG           Texto fixo contendo "E111"  C   004   -
    02  COD_AJ_APUR     Codigo do ajuste da apurac?o e deduc?o, conforme a Tabela indicada no item 5.1.1.   C   008   -
    03  DESCR_COM-PL_AJ   Descric?o complementar do ajuste da apurac?o.   C   - -
    04  VL_AJ_APUR      Valor do ajuste da apurac?o N   - 02
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'E111';
    pl_registro_e112;
    pl_registro_e113;
  end;

  --/REGISTRO E112: INFORMAC?ES ADICIONAIS DOS AJUSTES DA APURAC?O DO ICMS
  procedure pl_registro_e112 is
    /*
    N?    Campo     Descric?o                                   Tipo  Tam Dec
    01  REG       Texto fixo contendo "E112"                        C     004   -
    02  NUM_DA    Numero do documento de arrecadac?o estadual, se houver      C     - 02
    03  NUM_PROC  Numero do processo ao qual o ajuste esta vinculado, se houver   C     - -
    04  IND_PROC  Indicador da origem do processo:
        0- Sefaz;
        1- Justica Federal;
        2- Justica Estadual;
        9- Outros                                             C     001   -
    05  PROC      Descric?o resumida do processo que embasou o lancamento -   C     - -
    06  COD_OBS     Codigo de referencia a observac?o (campo 02 do Registro 0460) C     - -
    Observac?es:
    Nivel hierarquico - 5
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'E112';
  end;

  --/REGISTRO E113: INFORMAC?ES ADICIONAIS DOS AJUSTES DA APURAC?O DO ICMS - IDENTIFICAC?O DOS DOCUMENTOS FISCAIS
  procedure pl_registro_e113 is
    /*
    N?    Campo     Descric?o                                             Tipo  Tam Dec
    01  REG       Texto fixo contendo "E113"                                  C     004   -
    02  COD_PART  Codigo do participante (campo 02 do Registro 0150):
                - do emitente do documento ou do remetente das mercadorias, no caso de entradas;
                - do adquirente, no caso de saidas                              C     -   -
    03  COD_MOD     Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1             C     002   -
    04  SER       Serie do documento fiscal                                     C     -   -
    05  SUB       Subserie do documento fiscal                                  N     -   -
    06  NUM_DOC     Numero do documento fiscal                                  N     -   -
    07  DT_DOC    Data da emiss?o do documento fiscal                             N     008   -
    08  CHV_NFE     Chave da Nota Fiscal Eletronica                                 N     44  -
    09  COD_ITEM  Codigo do item (campo 02 do Registro 0200)                        C     -   -
    10  VL_AJ_ITEM  Valor do ajuste para a operac?o/item                            N     -   02
    Observac?es:
    Nivel hierarquico - 5
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'E113';
  end;

  --/REGISTRO E115: INFORMAC?ES ADICIONAIS DA APURAC?O - VALORES DECLAR ATORIOS.
  procedure pl_registro_e115 is
    /*
    N?    Campo Descric?o                                                   Tipo  Tam Dec
    01  REG         Texto fixo contendo "E115"                                  C     004   -
    02  COD_INF_ADIC  Codigo da informac?o adicional conforme Tabela a ser definida pelas SEFAZ,
                         conforme tabela definida no item 5.2.                                          N     -   -
    03  VL_INF_ADIC   Valor referente a informac?o adicional                          N     -   02
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'E115';
  end;

  --/REGISTRO E116: OBRIGAC?ES DO ICMS A RECOLHER - OPERAC?ES PROPRIAS
  procedure pl_registro_e116 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "E116"  C   004   -
    02  COD_OR  Codigo da obrigac?o a recolher, conforme a Tabela 5.4   N   003   -
    03  VL_OR   Valor da obrigac?o a recolher   N   - 02
    04  DT_VCTO   Data de vencimento da obrigac?o   N   008   -
    05  COD_REC   Codigo de receita referente a obrigac?o, proprio da unidade da federac?o, conforme legislac?o estadual,   C   - -
    06  NUM_PROC  Numero do processo ou auto de infrac?o ao qual a obrigac?o esta vinculada, se houver.   C   - -
    07  IND_PROC  Indicador da origem do processo:
        0- Sefaz;
        1- Justica Federal;
        2- Justica Estadual;
        9- Outros   C   001   -
    08  PROC  Descric?o resumida do processo que embasou o lancamento C   - -
    09  TXT_COMPL   Descric?o complementar das obrigac?es a recolher. C   - -
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'E116';
  end;

  --/REGISTRO E200: PERIODO DA APURAC?O DO ICMS - SUBSTITUIC?O TRIBUTARIA
  procedure pl_registro_e200 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "E200"  C   004   -
    02  DT_INI  Data inicial a que a apurac?o se refere   N   008   -
    03  DT_FIN  Data final a que a apurac?o se refere N   008   -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'E200';
  end;

  --/REGISTRO E210: APURAC?O DO ICMS - SUBSTITUIC?O TRIBUTARIA
  procedure pl_registro_e210 is
    /*
    N?  Campo                 Descric?o                                                       Tipo  Tam Dec
    01  REG                 Texto fixo contendo "E210"                                            C     004   -
    02  UF                Sigla da unidade da federac?o a que se refere a apurac?o do ICMS ST                 C     002   -
    03  IND_MOV_ST            Indicador de movimento:
        0 - Sem operac?es com ST
        1 - Com operac?es de ST                                                                 C     001   -
    04  VL_SLD_CRED_ANT_ST      Valor do "Saldo credor de periodo anterior - Substituic?o Tributaria"               N     -   02
    05  VL_DEVOL_ST           Valor total do ICMS ST de devoluc?o de mercadorias                              N     -   02
    06  VL_RESSARC_ST           Valor total do ICMS ST de ressarcimentos                                    N     -   02
    07  VL_OUT_CRED_ST        Valor total de Ajustes "Outros creditos ST"                                   N     -   02
    08  VL_AJ_CREDITOS_ST       Valor total dos ajustes a credito de ICMS ST, provenientes de ajustes do documento fiscal.  N     -   02
    09  VL_RETENCAO_ST        Valor Total do ICMS retido por Substituic?o Tr i b u t a r i a                      N     -   02
    10  VL_OUT_DEB_ST           Valor Total dos ajustes "Outros debitos ST"                                   N     -   02
    11  VL_AJ_DEBITOS_ST        Valor total dos ajustes a debito de ICMS ST, provenientes de ajustes do documento fiscal.   N     -   02
    12  VL_SLD_DEV_ANT_ST       Valor total de "Saldo devedor antes das deduc?es" = [(09+10+11) - (04+05+06+07+08)].      N     -   02
    13  VL_DEDUC?ES_ST        Valor total dos ajustes "Deduc?es ST"                                       N     -   02
    14  VL_ICMS_RECOL_ST        Imposto a recolher ST (12 - 13)                                           N     -   02
    15  VL_SLD_CRED_ST_TRANPORTAR   S-Saldo credor de ST a transportar para o periodo seguinte [(04+05+06+07+08).- (09+10+11)]. N     -   02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - um (por periodo)
    */
  begin
    vg_registro := 'E210';
  
    pl_registro_e220;
    pl_registro_e250;
  end;

  --/REGISTRO E220: AJUSTE/BENEFICIO/INCENTIVO DA APURAC?O DO ICMS SUBSTITUIC?O TRIBUTARIA
  procedure pl_registro_e220 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "E220"  C   004   -
    02  COD_AJ_APUR   Codigo do ajuste da apurac?o e deduc?o, conforme a Tabela indicada no item 5.1.1  C   008   -
    03  DESCR_COMPL_AJ  Descric?o complementar do ajuste da apurac?o  C   - -
    04  VL_AJ_APUR  Valor do ajuste da apurac?o N   - 02
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'E220';
  
    pl_registro_e230;
    pl_registro_e240;
  
  end;

  --/REGISTRO E230: INFORMAC?ES ADICIONAIS DOS AJUSTES DA APURAC?O DO ICMS SUBSTITUIC?O TRIBUTARIA
  procedure pl_registro_e230 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "E230"  C   004   -
    02  NUM_DA  Numero do documento de arrecadac?o estadual, se houver  C   - 02
    03  NUM_PROC  Numero do processo ao qual o ajuste esta vinculado, se houver   C   - -
    04  IND_PROC  Indicador da origem do processo:
        0- Sefaz;
        1- Justica Federal;
        2- Justica Estadual;
        9- Outros   N   001   -
    05  PROC  Descric?o resumida do processo que embasou o lancamento C   - -
    06  COD_OBS   Codigo de referencia a observac?o (campo 02 do Registro 0460) C   - -
    Observac?es:
    Nivel hierarquico - 5
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'E230';
  end;

  --/REGISTRO E240: INFORMAC?ES ADICIONAIS DOS AJUSTES DA APURAC?O DO ICMS SUBSTITUIC?O TRIBUTARIA - IDENTIFICAC?O DOS DOCUMENTOS FISCAIS
  procedure pl_registro_e240 is
    /*
    N?  Campo Descric?o Ti po Tam Dec
    01  REG   Texto fixo contendo "E240"  C   004   -
    02  COD_PART  Codigo do participante (campo 02 do Registro 0150):
        - do emitente do documento ou do remetente das mercadorias, no caso de entradas;
        - do adquirente, no caso de saidas  C   - -
    03  COD_MOD   Codigo do modelo do documento fiscal, conforme a Tabela 4.1.1   C   002   -
    04  SER   Serie do documento fiscal   C   - -
    05  SUB   Subserie do documento fiscal  N   - -
    06  NUM_DOC   Numero do documento fiscal  N   - -
    07  DT_DOC  Data da emiss?o do documento fiscal   N   008   -
    08  CHV_NFE   Chave da Nota Fiscal Eletronica   N   44  -
    09  COD_ITEM  Codigo do item (campo 02 do Registro 0200)  C   - -
    10  VL_AJ_ITEM  Valor do ajuste para a operac?o/item  N   - 02
    Observac?es:
    Nivel hierarquico - 5
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'E240';
  end;

  --/REGISTRO E250: OBRIGAC?ES DO ICMS A RECOLHER - SUBSTITUIC?O TRIBUTARIA
  procedure pl_registro_e250 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "E250"  C   004   -
    02  COD_OR  Codigo da obrigac?o a recolher, conforme a Tabela 5.4   N   003   -
    03  VL_OR   Valor da obrigac?o ICMS ST a recolher   N   - 02
    04  DT_VCTO   Data de vencimento da obrigac?o   N   008   -
    05  COD_REC   Codigo de receita referente a obrigac?o, proprio da unidade da federac?o  C   - -
    06  NUM_PROC  Numero do processo ou auto de infrac?o ao qual a obrigac?o esta vinculada, se houver  C   - -
    07  IND_PROC  Indicador da origem do processo:
        0- Sefaz;
        1- Justica Federal;
        2- Justica Estadual;
        9- Outros   C   001   -
    08  PROC  Descric?o resumida do processo que embasou o lancamento   C   - -
    09  COD_OBS   Codigo de referencia a observac?o (campo 02 do Registro 0460) C   - -
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
  begin
    vg_registro := 'E250';
  end;

  --/REGISTRO E500: PERIODO DE APURAC?O DO IPI
  procedure pl_registro_e500 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "E500"  C   004   -
    02  IND_APUR  Indicador de periodo de apurac?o do IPI:
        0 - Mensal;
        1 - Decendial   C   1   -
    03  DT_INI  Data inicial a que a apurac?o se refere   N   008   -
    04  DT_FIN  Data final a que a apurac?o se refere N   008   -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - um ou varios (por periodo)
    */
  begin
    vg_registro := 'E500';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || '0' || vg_sep;
    vg_linha    := vg_linha || to_char(vg_inic, 'ddmmrrrr') || vg_sep;
    vg_linha    := vg_linha || to_char(vg_final, 'ddmmrrrr') || vg_sep ||
                   vg_crlf;
  
    pl_gera_linha;
  
    pl_registro_e510;
    pl_registro_e520;
  
  end;

  --/REGISTRO E510: CONSOLIDAC?O DOS VALORES DO IPI
  procedure pl_registro_e510 is
    /*
    N?    Campo       Descric?o                                           Tipo  Tam Dec
    01  REG         Texto fixo contendo "E510"                                C   004   -
    02  CFOP        Codigo Fiscal de Operac?o e Prestac?o do agrupamento de itens           C   004   -
    03  CST_IPI       Codigo da Situac?o Tributaria referente ao IPI, conforme a
                  Tabela indicada no item 4.3.2.                              C   002   -
    04  VL_CONT_IPI   Parcela correspondente ao "Valor Contabil" referente ao CFOP e ao
                  Codigo de Tributac?o do IPI                                 N   - 02
    05  VL_BC_IPI     Parcela correspondente ao "Valor da base de calculo do IPI"
                  referente ao CFOP e ao Codigo de Tributac?o do IPI,
                  para operac?es tributadas                                   N   - 02
    06  VL_IPI      Parcela correspondente ao "Valor do IPI" referente ao CFOP e ao
                  Codigo de Tributac?o do IPI, para operac?es tributadas              N   - 02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
    cursor cr is
      select '00' cst_ipi,
             a.nat_oper cfop,
             a.tip_livro,
             sum(nvl(base_calc, 0)) vl_bc_ipi,
             sum(nvl(valor_00, 0)) vl_00,
             sum(nvl(valor_40, 0)) vl_40,
             sum(nvl(valor_50, 0)) vl_50,
             sum(nvl(valor_90, 0)) vl_90,
             sum(nvl(vl_ipi, 0)) vl_ipi,
             sum(nvl(vlr_dipi, 0)) vl_dipi,
             --sum(nvl(vlr_contab,0) - nvl(valor_40,0) - nvl(valor_50,0) - nvl(valor_90,0) -nvl(vl_ipi,0))   vl_ctbl ,
             sum(nvl(vlr_contab, 0) - nvl(valor_40, 0) - nvl(valor_50, 0) -
                 nvl(vl_ipi, 0)) vl_ctbl,
             sum(nvl(vlr_contab, 0)) vl_ctbl_g
        from fs_itens_livro a
       where a.empresa = 1
         and a.filial = 1
         and a.dt_entsai between vg_inic and vg_final
         and a.tip_imposto = 'IPI'
         and nvl(valor_00, 0) > 0
       group by a.nat_oper, a.tip_livro
      union
      select '40' cst_ipi,
             a.nat_oper cfop,
             a.tip_livro,
             sum(nvl(base_calc, 0)) vl_bc_ipi,
             sum(nvl(valor_00, 0)) vl_00,
             sum(nvl(valor_40, 0)) vl_40,
             sum(nvl(valor_50, 0)) vl_50,
             sum(nvl(valor_90, 0)) vl_90,
             sum(nvl(vl_ipi, 0)) vl_ipi,
             sum(nvl(vlr_dipi, 0)) vl_dipi,
             sum(nvl(vlr_contab, 0)) vl_ctbl,
             sum(nvl(vlr_contab, 0)) vl_ctbl_g
        from fs_itens_livro a
       where a.empresa = 1
         and a.filial = 1
         and a.dt_entsai between vg_inic and vg_final
         and a.tip_imposto = 'IPI'
         and nvl(valor_40, 0) > 0
       group by a.nat_oper, a.tip_livro
      union
      select '50' cst_ipi,
             a.nat_oper cfop,
             a.tip_livro,
             sum(nvl(base_calc, 0)) vl_bc_ipi,
             sum(nvl(valor_00, 0)) vl_00,
             sum(nvl(valor_40, 0)) vl_40,
             sum(nvl(valor_50, 0)) vl_50,
             sum(nvl(valor_90, 0)) vl_90,
             sum(nvl(vl_ipi, 0)) vl_ipi,
             sum(nvl(vlr_dipi, 0)) vl_dipi,
             sum(nvl(vlr_contab, 0)) vl_ctbl,
             sum(nvl(vlr_contab, 0)) vl_ctbl_g
        from fs_itens_livro a
       where a.empresa = 1
         and a.filial = 1
         and a.dt_entsai between vg_inic and vg_final
         and a.tip_imposto = 'IPI'
         and nvl(valor_50, 0) > 0
       group by a.nat_oper, a.tip_livro
       order by 1, 2, 3;
  
  begin
    vg_registro := 'E510';
    for reg in cr loop
      vg_linha := vg_sep || vg_registro || vg_sep;
      vg_linha := vg_linha || reg.cfop || vg_sep;
      vg_linha := vg_linha || reg.cst_ipi || vg_sep;
      vg_linha := vg_linha || reg.vl_ctbl || vg_sep;
      vg_linha := vg_linha || reg.vl_bc_ipi || vg_sep;
      vg_linha := vg_linha || reg.vl_00 || vg_sep || vg_crlf;
    
      pl_gera_linha;
    
    end loop;
  
  end;

  --/REGISTRO E520: APURAC?O DO IPI
  procedure pl_registro_e520 is
    /*
    N?    Campo       Descric?o                                             Tipo  Tam Dec
    01  REG         Texto fixo contendo "E520"                                  C   004   -
    02  VL_SD_ANT_IPI   Saldo credor do IPI transferido do periodo anterior                   N   - 02
    03  VL_DEB_IPI    Valor total dos debitos por "Saidas com debito do imposto"              N   - 02
    04  VL_CRED_IPI   Valor total dos creditos por "Entradas e aquisic?es com credito do imposto"   N   - 02
    05  VL_OD_IPI     Valor de "Outros debitos" do IPI (inclusive estornos de credito)          N   - 02
    06  VL_OC_IPI     Valor de "Outros creditos" do IPI (inclusive estornos de debitos)         N   - 02
    07  VL_SC_IPI     Valor do saldo credor do IPI a transportar para o periodo seguinte        N   - 02
    08  VL_SD_IPI     Valor do saldo devedor do IPI a recolher                          N   - 02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:1
    */
    cursor cr is
      select a.saldo_cr vl_sd_ant_ipi,
             (nvl(a.db_saidas_nac, 0) + nvl(a.db_outros, 0) +
             nvl(a.db_estorno_cr, 0) + nvl(a.db_ressarc_cr, 0)) vl_deb_ipi,
             (nvl(a.cr_entradas_nac, 0) + nvl(a.cr_entradas_ext, 0) +
             nvl(a.cr_saidas_ext, 0) + nvl(a.cr_outros, 0) +
             nvl(a.cr_estorno_db, 0)
             
             ) vl_cred_ipi,
             
             0 vl_od_ipi,
             0 vl_oc_ipi,
             (nvl(a.db_saidas_nac, 0) + nvl(a.db_outros, 0) +
             nvl(a.db_estorno_cr, 0) + nvl(a.db_ressarc_cr, 0)) debito_total,
             (nvl(a.cr_entradas_nac, 0) + nvl(a.cr_entradas_ext, 0) +
             nvl(a.cr_saidas_ext, 0) + nvl(a.cr_outros, 0) +
             nvl(a.cr_estorno_db, 0) + nvl(a.saldo_cr, 0)) credito_total
        from fs_apura_ipi a
       where a.data_ate = vg_final
         and a.empresa = vg_emp
         and a.filial = vg_fil; --'31/10/2007'
  
    vl_sd_ant_ipi number(15, 2);
    vl_deb_ipi    number(15, 2);
    vl_cred_ipi   number(15, 2);
    vl_od_ipi     number(15, 2);
    vl_oc_ipi     number(15, 2);
    vl_sc_ipi     number(15, 2);
    vl_sd_ipi     number(15, 2);
    vl_cred_total number(15, 2);
    vl_debt_total number(15, 2);
  begin
    open cr;
    fetch cr
      into vl_sd_ant_ipi,
           vl_deb_ipi,
           vl_cred_ipi,
           vl_od_ipi,
           vl_oc_ipi,
           vl_debt_total,
           vl_cred_total;
    close cr;
    --/
    if nvl(vl_cred_total, 0) > nvl(vl_debt_total, 0) then
      vl_sc_ipi := nvl(vl_cred_total, 0) - nvl(vl_debt_total, 0);
      vl_sd_ipi := 0;
    else
      vl_sd_ipi := nvl(vl_cred_total, 0) - nvl(vl_debt_total, 0);
      vl_sc_ipi := 0;
    end if;
    --/
    vg_registro := 'E520';
  
    vg_linha := vg_sep || vg_registro || vg_sep;
    vg_linha := vg_linha || vl_sd_ant_ipi || vg_sep;
    vg_linha := vg_linha || vl_deb_ipi || vg_sep;
    vg_linha := vg_linha || vl_cred_ipi || vg_sep;
    vg_linha := vg_linha || vl_od_ipi || vg_sep;
    vg_linha := vg_linha || vl_oc_ipi || vg_sep;
    vg_linha := vg_linha || vl_sc_ipi || vg_sep;
    vg_linha := vg_linha || vl_sd_ipi || vg_sep || vg_crlf;
    --/
    pl_gera_linha;
    --/
  
    pl_registro_e530;
  end;

  --/REGISTRO E530: AJUSTES DA APURAC?O DO IPI
  procedure pl_registro_e530 is
    /*
    N?    Campo   Descric?o                                                     Tipo  Tam Dec
    01  REG     Texto fixo contendo "E530"                                          C     004   -
    02  IND_AJ  Indicador do tipo de ajuste: 0- Ajuste a debito; 1- Ajuste a credito              C     001   -
    03  VL_AJ   Valor do ajuste                                                   N     -   02
    04  COD_AJ  Codigo do ajuste da apurac?o, conforme a Tabela indicada no item 4.5.4.             C     003
    05  IND_DOC   Indicador da origem do documento vinculado ao ajuste: 0 - Processo Judicial;
        1 - Processo Administrativo;
        2 - PER/DCOMP; 9 - Outros.                                                C     001   -
    06  NUM_DOC   Numero do documento / processo / declarac?o ao qual o ajuste esta vinculado, se houver  C     -   -
    07  DESCR_AJ Descric?o resumida do ajuste.                                          C     -   -
    Observac?es:
    Nivel hierarquico - 4
    Ocorrencia - 1:N (por periodo)
    */
  begin
    vg_registro := 'E530';
  end;

  --/REGISTRO E990: ENCERRAMENTO DO BLOCO E
  procedure pl_registro_e990 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "E990"  C   004   -
    02  QTD_LIN_E   Quantidade total de linhas do Bloco E   N   - -
    Observac?es: Registro obrigatorio
    Nivel hierarquico - 1
    Ocorrencia - um (por arquivo)
    */
    v_aux number(9);
  begin
  
    vg_registro := 'E990';
    v_aux       := fl_total_reg(vg_inic, 'E');
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || v_aux || vg_sep || vg_crlf;
  
    pl_gera_linha;
  end;

  --*************************************************************************************************************
  --*************************************************************************************************************
  --                                          BLOCO H:
  --                                      INVENTARIO FISICO
  --*************************************************************************************************************
  --*************************************************************************************************************
  procedure pl_registro_h010;
  procedure pl_registro_h030(p_op  pp_ordens.ordem%type,
                             p_ini tstr8,
                             p_fim tstr8);

  --/REGISTRO H001: ABERTURA DO BLOCO H
  procedure pl_registro_h001 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "H001"  C   004   -
    02  IND_MOV   Indicador de movimento:
        0- Bloco com dados informados;
        1- Bloco sem dados informados   C   001   -
    Observac?es: Registro obrigatorio
    Nivel hierarquico - 1
    Ocorrencia - um (por arquivo)
    */
  begin
    vg_registro := 'H001';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || '0' || vg_sep || vg_crlf;
  
    pl_gera_linha;
  end;

  --/REGISTRO H005: TOTAIS DO INVENTARIO
  procedure pl_registro_h005 is
    /*
    N?    Campo   Descric?o             Tipo  Tam Dec
    01  REG     Texto fixo contendo "H005"  C   004   -
    02  DT_INV  Data do inventario        N   008   -
    03  VL_INV  Valor total do estoque      N   - 02
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - um (por data)
    */
    cursor cr is
      select sum(round(round(a.saldo_fisico, 3) * round(a.custo_medio, 6),
                       2)) total_inventario
        from ce_saldo a
       where a.dt_saldo = (select max(a2.dt_saldo)
                             from ce_saldo a2
                            where a2.empresa = a.empresa
                              and a2.filial = a.filial
                              and a2.produto = a.produto
                              and a2.dt_saldo <= vg_final)
         and a.saldo_fisico > 0
         and a.empresa = vg_emp
         and a.filial = vg_fil
         and a.dt_saldo <= vg_final;
  
    v_vl number(15, 2);
  
  begin
    open cr;
    fetch cr
      into v_vl;
    close cr;
  
    vg_registro := 'H005';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || to_char(vg_final, 'ddmmrrrr') || vg_sep;
    vg_linha    := vg_linha || v_vl || vg_sep || vg_crlf;
    --/
    pl_gera_linha;
    --/
  
    pl_registro_h010;
  end;

  --/REGISTRO H010: INVENTARIO
  procedure pl_registro_h010 is
    /*
    N?    Campo     Descric?o                                   Tipo  Tam Dec
    01  REG       Texto fixo contendo "H010"                        C     004   -
    02  COD_ITEM  Codigo do item (campo 02 do Registro 0200)              C     -   -
    03  UNID      Unidade do item (Campo 02 do registro 0190)               C     -   -
    04  QTD       Quantidade do item                              N     -   03
    05  VL_UNIT     Valor unitario do item                            N     -   06
    06  VL_ITEM     valor do item                                   N     -   02
    07  IND_PROP  Indicador de propriedade/posse do item:
        0- Item de propriedade do informante e em seu poder;
        1- Item de propriedade do informante em posse de terceiros;
        2- Item de propriedade de terceiros em posse do informante -          C     001   -
    08  COD_PART  Codigo do participante (campo 02 do Registro 0150):
        - proprietario/possuidor que n?o seja o informante do arquivo         C     014   -
    09  COD_OBS     Codigo de referencia a observac?o (campo 02 do Registro 0460) C     -   -
    10  COD_CTA     Codigo da conta analitica contabil debitada/creditada       C     -   -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
    cursor cr is
      select a.produto cod_item,
             ce_produtos_utl.unidade(a.empresa, a.produto) unid,
             round(a.saldo_fisico, 3) qtd,
             round(a.custo_medio, 6) vl_unit,
             round(round(a.saldo_fisico, 3) * round(a.custo_medio, 6), 2) vl_item,
             0 ind_prop,
             null cod_part,
             null cod_obs,
             ce_produtos_utl.cod_conta(a.empresa, a.produto) cod_cta
        from ce_saldo a
       where a.dt_saldo = (select max(a2.dt_saldo)
                             from ce_saldo a2
                            where a2.empresa = a.empresa
                              and a2.filial = a.filial
                              and a2.produto = a.produto
                              and a2.dt_saldo <= vg_final)
         and a.saldo_fisico > 0
         and a.empresa = 1
         and a.filial = 1
         and a.dt_saldo <= vg_final;
  
  begin
    for reg in cr loop
      vg_msg      := 'H010: ' || reg.cod_item;
      vg_registro := 'H010';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || reg.cod_item || vg_sep;
      vg_linha    := vg_linha || reg.unid || vg_sep;
      vg_linha    := vg_linha || reg.qtd || vg_sep;
      vg_linha    := vg_linha || reg.vl_unit || vg_sep;
      vg_linha    := vg_linha || reg.vl_item || vg_sep;
      vg_linha    := vg_linha || reg.ind_prop || vg_sep;
      vg_linha    := vg_linha || reg.cod_part || vg_sep;
      vg_linha    := vg_linha || reg.cod_obs || vg_sep;
      vg_linha    := vg_linha || reg.cod_cta || vg_sep || vg_crlf;
    
      pl_gera_linha;
    
    end loop;
  
  end;

  --/REGISTRO H020: PRODUTOS ELABORADOS
  procedure pl_registro_h020 is
    /*
    N?    Campo     Descric?o                             Tipo  Tam Dec
    01  REG       Texto fixo contendo "H020"                  C     004   -
    02  COD_ITEM  Codigo do item (campo 02 do Registro 0200) -
                Somente produtos acabados ou em processo.         C     -   -
    03  UNID      Unidade do item (Campo 02 do registro 0190)       C     -   -
    Observac?es: Dever?o ser informados todos os produtos elaborados
            durante o ano, inclusive aqueles que n?o inventariados.
    Nivel hierarquico - 2
    Ocorrencia - 1:N
    */
    cursor cr is
      select distinct o.produto cod_item,
                      o.unidade unidade,
                      o.ordem,
                      to_char(o.criacao, 'ddmmrrrr') dt_ini,
                      to_char(o.data_entrega, 'ddmmrrrr') dt_fim
        from vce_produto_elab o
       where (o.empresa, o.filial, o.ordem) in
             (select a.empresa, a.filial, a.ordem
                from cs_saldo_custo a
               where o.empresa = vg_emp
                 and o.filial = vg_fil
                 and o.ordem = a.ordem
                 and o.empresa = a.empresa
                 and o.filial = a.filial
                 and a.ano = to_number(to_char(vg_inic, 'RRRR')))
       order by 1;
  
  begin
    -- carrega a estrutura de todos os produto elaborados no ano
    vg_msg := 'H020-1';
    fs_sped_utl.lcm_op(vg_emp,
                       vg_fil,
                       to_number(to_char(vg_inic, 'RRRR')),
                       to_number(to_char(vg_inic, 'MM')),
                       null,
                       null,
                       null);
    vg_msg := 'H020-2';
  
    for reg in cr loop
      vg_msg      := 'H020:' || reg.ordem || '-' || reg.cod_item;
      vg_registro := 'H020';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || reg.cod_item || vg_sep;
      vg_linha    := vg_linha || reg.unidade || vg_sep || vg_crlf;
    
      pl_gera_linha;
    
      vg_msg := 'H0203:' || reg.ordem || '-' || reg.cod_item;
      pl_registro_h030(reg.ordem, reg.dt_ini, reg.dt_fim);
    
    end loop;
  
  end;

  --/REGISTRO H030: MERCADORIA COMPONENTE/RELAC?O INSUMO/PRODUTO
  procedure pl_registro_h030(p_op  pp_ordens.ordem%type,
                             p_ini tstr8,
                             p_fim tstr8) is
    /*
    N?    Campo     Descric?o                                 Tipo  Tam Dec
    01  REG       Texto fixo contendo "H030"                      C     004   -
    02  COD_ITEM  Codigo do item componente (insumos)                 C     -   -
    03  QTD       Quantidade do item componente no item composto          N     -   05
    04  UNID      Unidade do item componente (Campo 02 do registro 0190)    C     -   -
    05  PERDA     Percentual de perda do insumo/produto intermediario       N     -   05
    06  DT_INI    Data de inicio de vigencia da formula de composic?o       N     008   -
    07  DT_FIN    Data final de vigencia da formula de composic?o         N     008   -
    Observac?es: Campo 03- Este campo devera ser preenchido com a quantidade bruta
                           de insumo empregada por unidade do item composto.
                           Entende-se por quantidade bruta a quantidade total,
                           incluidas as perdas normais decorrentes do processo produtivo.
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
    cursor cr is
      select produto,
             unidade,
             sum(case
                   when d.unidade = 'KG' then --AND SUBSTR(D.DESENHO,1,2) NOT IN ('50', '55')  THEN
                    (decode(nvl(peso_total, 0), 0, 1, peso_total))
                   when d.unidade in ('M', 'MT') then --AND SUBSTR(D.DESENHO,1,2) NOT IN ('50', '55') then
                    ((nvl(comprimento, 0) / 1000) * quantidade)
                   when d.unidade = 'M2' then --AND SUBSTR(D.DESENHO,1,2) NOT IN ('50', '55') then
                    (nvl(comprimento, 0) / 1000) * (nvl(largura, 0) / 1000) *
                    quantidade
                   else
                    (quantidade)
                 end) qtde_total
             
            ,
             sum(case
                   when d.unidade = 'KG' then --AND SUBSTR(D.DESENHO,1,2) NOT IN ('50', '55')  THEN
                    (decode(nvl(peso_acabado_total, 0), 0, 1, peso_acabado_total))
                   when d.unidade in ('M', 'MT') then --AND SUBSTR(D.DESENHO,1,2) NOT IN ('50', '55') then
                    ((nvl(comprimento, 0) / 1000) * quantidade)
                   when d.unidade = 'M2' then --AND SUBSTR(D.DESENHO,1,2) NOT IN ('50', '55') then
                    (nvl(comprimento, 0) / 1000) * (nvl(largura, 0) / 1000) *
                    quantidade
                   else
                    (quantidade)
                 end) qtde_acabado
        from t_lcm_op d
       where produto is not null
         and ordem = p_op
       group by produto, unidade;
  
    v_dt_fim tstr8;
    v_perda  number;
  
  begin
    -- carrega a lista de legenda da op
    --     pp_rel.LCM_OP(1,1,p_op,null,null);
    --
    vg_registro := 'H030';
  
    vg_msg := 'H030';
  
    for reg in cr loop
    
      v_perda := 0;
    
      if nvl(reg.qtde_acabado, 0) > 0 then
      
        v_perda := reg.qtde_total - reg.qtde_acabado;
      
        if v_perda < 0 then
          v_perda := 0;
        end if;
      
      end if;
    
      v_dt_fim := null; -- p_fim
    
      vg_linha := vg_sep || vg_registro || vg_sep;
      vg_linha := vg_linha || reg.produto || vg_sep;
      vg_linha := vg_linha || reg.qtde_total || vg_sep;
      vg_linha := vg_linha || reg.unidade || vg_sep;
      vg_linha := vg_linha || v_perda || vg_sep;
      vg_linha := vg_linha || p_ini || vg_sep;
      vg_linha := vg_linha || v_dt_fim || vg_sep || vg_crlf;
    
      pl_gera_linha;
    
    end loop;
  end;

  --/REGISTRO H990: ENCERRAMENTO DO BLOCO H
  procedure pl_registro_h990 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "H990"  C   004   -
    02  QTD_LIN_H   Quantidade total de linhas do Bloco H   N   - -
    Observac?es: Registro obrigatorio
    Nivel hierarquico - 1
    Ocorrencia - um (por arquivo)
    */
    v_aux number(9);
  begin
  
    vg_registro := 'H990';
    v_aux       := fl_total_reg(vg_inic, 'H');
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || v_aux || vg_sep || vg_crlf;
  
    pl_gera_linha;
  
  end;

  --*************************************************************************************************************
  --*************************************************************************************************************
  --                                          BLOCO 1:
  --                                      OUTRAS INFORMAC?ES
  --*************************************************************************************************************
  --*************************************************************************************************************

  procedure pl_registro_1105(p_num    ft_notas.num_nota%type,
                             p_natexp tnum1,
                             p_id     fs_dec_sintegra_nf.id_fsdecnf%type);
  procedure pl_registro_1110(p_id     fs_dec_sintegra_nf.id_fsdecnf%type,
                             p_it     fs_dec_sintegra_nf_item.id_fsdecnfit%type,
                             p_codmod tstr2,
                             p_dt     tstr8);
  procedure pl_registro_1210;
  procedure pl_registro_1310;
  procedure pl_registro_1320;

  --/REGISTRO 1001: ABERTURA DO BLOCO 1
  procedure pl_registro_1001 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "1001"  C   004   -
    02  IND_MOV   Indicador de movimento:
        0- Bloco com dados informados;
        1- Bloco sem dados informados   N   001   -
    Observac?es:Registro obrigatorio
    Nivel hierarquico - 1
    Ocorrencia - um (por arquivo)
    */
    v_aux varchar2(1);
  begin
    v_aux       := '1';
    vg_registro := '1001';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || v_aux || vg_sep || vg_crlf;
  
    pl_gera_linha;
  
  end;

  --/REGISTRO 1100: REGISTRO DE INFORMAC?ES SOBRE EXPORTAC?O
  procedure pl_registro_1100 is
    /*
    N?    Campo     Descric?o                                               Tipo  Tam Dec
    01  REG       Texto fixo contendo "1100"                                    C     004   -
    02  IND_DOC     Informe o tipo de documento:
                0 - Declarac?o de Exportac?o;
                1 - Declarac?o Simplificada de Exportac?o.                          N   001   -
    03  NRO_DE    Numero da declarac?o                                        N   011   -
    04  DT_DE     Data da declarac?o (DDMMAAAA)                                   N   008   -
    05  NAT_EXP     Preencher com: 0 - Exportac?o Direta 1 - Exportac?o Indireta              N   001   -
    06  NRO_RE    N? do registro de Exportac?o                                    N   012   -
    07  DT_RE     Data do Registro de Exportac?o (DDMMAAAA)                           N   008   -
    08  CHC_EMB     N? do conhecimento de embarque                                  N   016   -
    09  DT_CHC    Data do conhecimento de embarque (DDMMAAAA)                           N   008   -
    10  DT_AVB    Data da averbac?o da Declarac?o de exportac?o (ddmmaaaa)                N   008   -
    11  TP_CHC    Informac?o do tipo de conhecimento de transporte
                    (Preencher conforme tabela de tipo de documento de carga do SISCOMEX - anexa)   N   002   -
    12  PAIS      Codigo do pais de destino da mercadoria (Preencher                    N   004   -
    Observac?es: Registro a ser preenchido no mes em que se concluir a exportac?o direta ou indireta.
    Nivel hierarquico - 2
    Ocorrencia - 1:N
    */
    cursor cr is
      select lpad(a.dec_exp, 11, '0') nro_de,
             to_char(a.dt_dec_exp, 'ddmmrrrr') dt_de,
             a.nat_exp -- 0 direta , 1 indireta
            ,
             a.ind_doc,
             a.con_emb chc_emb,
             to_char(a.dt_con_emb, 'ddmmrrrr') dt_chc,
             a.tp_con_emb tp_chc,
             a.pais_exp pais,
             a.com_exp,
             to_char(a.dt_com_exp, 'ddmmrrrr') dt_com_exp,
             to_char(a.dt_averbacao, 'ddmmrrrr') dt_avb,
             lpad(b.reg_exp, 12, '0') nro_re,
             to_char(b.dt_reg_exp, 'ddmmrrrr') dt_re,
             b.num_docto,
             to_char(b.dt_emissao, 'ddmmrrrr') dt_emissao,
             b.relacionamento,
             b.id_fsdecnf
        from fs_dec_sintegra a, fs_dec_sintegra_nf b
       where b.id_fsdec = a.id_fsdec
         and b.dt_reg_exp between vg_inic and vg_final
       order by b.dt_reg_exp, a.dec_exp;
  
  begin
    for reg in cr loop
      vg_registro := '1100';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || reg.ind_doc || vg_sep;
      vg_linha    := vg_linha || reg.nro_de || vg_sep;
      vg_linha    := vg_linha || reg.dt_de || vg_sep;
      vg_linha    := vg_linha || reg.nat_exp || vg_sep;
      vg_linha    := vg_linha || reg.nro_re || vg_sep;
      vg_linha    := vg_linha || reg.dt_re || vg_sep;
      vg_linha    := vg_linha || reg.chc_emb || vg_sep;
      vg_linha    := vg_linha || reg.dt_chc || vg_sep;
      vg_linha    := vg_linha || reg.dt_avb || vg_sep;
      vg_linha    := vg_linha || reg.tp_chc || vg_sep;
      vg_linha    := vg_linha || reg.pais || vg_sep || vg_crlf;
    
      pl_gera_linha;
    
      pl_registro_1105(reg.num_docto, reg.nat_exp, reg.id_fsdecnf);
    
    end loop;
  
  end;

  --/REGISTRO 1105: DOCUMENTOS FISCAIS DE EXPORTAC?O
  procedure pl_registro_1105(p_num    ft_notas.num_nota%type,
                             p_natexp tnum1,
                             p_id     fs_dec_sintegra_nf.id_fsdecnf%type) is
    /*
    N?    Campo     Descric?o                                   Tipo  Tam Dec
    01  REG       Texto fixo contendo "1105"                        C     004   -
    02  COD_MOD     Codigo do modelo da NF, conforme tabela 4.1.1             C     002   -
    03  SERIE     Serie da Nota Fiscal                            C     003   -
    04  NUM_DOC     Numero de Nota Fiscal de Exportac?o emitida pelo Ex-portador  N     006   -
    05  CHV_NFE     Chave da Nota Fiscal Eletronica                       N     044   -
    06  DT_DOC    Data da emiss?o da NF de exportac?o                   N     008   -
    07  COD_ITEM  Codigo do item (campo 02 do Registro 0200)              C     -   -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
    cursor cr is
      select to_char(b.dt_emissao, 'ddmmrrrr') dt_doc,
             b.sr_nota serie,
             a.produto cod_item,
             c.id_fsdecnfit
        from fs_dec_sintegra_nf_item c, ft_itens_nf a, ft_notas b
       where c.seq_item(+) = a.seq_item
         and c.parte(+) = a.parte
         and c.sr_nota(+) = a.sr_nota
         and c.num_nota(+) = a.num_nota
         and c.empresa(+) = a.empresa
         and c.filial(+) = a.filial
         and b.empresa = vg_emp
         and b.filial = vg_fil
         and b.num_nota = p_num
         and a.empresa = b.empresa
         and a.filial = b.filial
         and a.num_nota = b.num_nota
         and a.sr_nota = b.sr_nota
         and a.parte = b.parte
         and b.parte = 0;
  
    v_cod_mod varchar2(2);
  begin
  
    v_cod_mod := fs_sped_utl.fb_cd_doctos(3); -- 3 Nota fiscal
  
    for reg in cr loop
    
      vg_registro := '1105';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || v_cod_mod || vg_sep;
      vg_linha    := vg_linha || reg.serie || vg_sep;
      vg_linha    := vg_linha || p_num || vg_sep;
      vg_linha    := vg_linha || null || vg_sep;
      vg_linha    := vg_linha || reg.dt_doc || vg_sep;
      vg_linha    := vg_linha || reg.cod_item || vg_sep || vg_crlf;
    
      pl_gera_linha;
    
      if p_natexp = 1 then
        pl_registro_1110(p_id, reg.id_fsdecnfit, v_cod_mod, reg.dt_doc);
      end if;
    
    end loop;
  end;

  --/REGISTRO 1110: OPERAC?ES DE EXPORTAC?O INDIRETA DE PRODUTOS N?O INDUSTRIALIZADOS PELO ESTABELECIMENTO EMITENTE.
  procedure pl_registro_1110(p_id     fs_dec_sintegra_nf.id_fsdecnf%type,
                             p_it     fs_dec_sintegra_nf_item.id_fsdecnfit%type,
                             p_codmod tstr2,
                             p_dt     tstr8) is
    /*
    N?    Campo   Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "1110"  C   004   -
    02  COD_PART  Codigo do participante-Fornecedor da Mercadoria destinada a exportac?o (campo 02 do Registro 0150)  C   - -
    03  COD_MOD Codigo do documento fiscal, conforme a Tabela 4.1.1   C   002
    04  SER   Serie do documento fiscal recebido com fins especificos de exportac?o.  C   - -
    05  NUM_DOC Numero do documento fiscal recebido com fins especificos de exportac?o.   N   - -
    06  DT_DOC  Data da emiss?o do documento fiscal recebido com fins especificos de exportac?o   N   008   -
    07  CHV_NFE Chave da Nota Fiscal Eletronica   N   044   -
    08  NR_MEMO Numero do Memorando de Exportac?o   N
    09  QTD   Quantidade do item efetivamente exportado.  N   - 03
    10  UNID    Unidade do item (Campo 02 do registro 0190) C   - -
    Observac?es: Registro so sera preenchido se for exportac?o indireta. Campo 04 -
                 NAT_EXP do registro 1100 for igual a "1"
    Nivel hierarquico - 4
    Ocorrencia - 1:N
    */
    cursor cr is
      select fornec   cod_part,
             sr_nota  ser,
             num_nota num_doc,
             qtd      qtd,
             und      unid
        from fs_dec_sintegra_nf_item a
       where a.id_fsdecnf = p_id
         and a.id_fsdecnfit = p_it;
  
  begin
    for reg in cr loop
      vg_registro := '1110';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || reg.cod_part || vg_sep;
      vg_linha    := vg_linha || p_codmod || vg_sep;
      vg_linha    := vg_linha || reg.ser || vg_sep;
      vg_linha    := vg_linha || reg.num_doc || vg_sep;
      vg_linha    := vg_linha || p_dt || vg_sep;
      vg_linha    := vg_linha || null || vg_sep;
      vg_linha    := vg_linha || null || vg_sep;
      vg_linha    := vg_linha || reg.qtd || vg_sep;
      vg_linha    := vg_linha || reg.unid || vg_sep || vg_crlf;
    
      pl_gera_linha;
    end loop;
  end;

  --/REGISTRO 1200: CONTROLE DE CREDITOS FISCAIS
  procedure pl_registro_1200 is
    /*
    N?    Campo       Descric?o Tipo  Tam Dec
    01  REG         Texto fixo contendo "1200"  C   004   -
    02  COD_AJ_APUR   Codigo de ajuste, conforme informado na Tabela indicada no item 5.1.1.  C   008   -
    03  SLD_CRED    Saldo de creditos fiscais de periodos anteriores  N   - 02
    04  CRED_APR    Total de credito apropriado no mes  N   - 02
    05  CRED_RECEB    Total de creditos recebidos por transferencia   N   - 02
    06  SLD_CRED_FIM  Saldo de credito fiscal acumulado a transportar para o periodo seguinte N   - 02
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - 1:N
    */
  
    cursor cr is
      select *
        from (select nvl(db_saidas, 0) vl_tot_deb,
                     nvl(db_outros, 0) vl_aj_debitos,
                     a.db_estorno_cr vl_estornos_cred,
                     a.cr_entrada vl_tot_creditos,
                     a.cr_outros vl_aj_creditos,
                     a.cr_estorno_db vl_estorno_deb,
                     a.saldo_cr vl_sld_credor_ant,
                     nvl(db_saidas, 0) + nvl(db_outros, 0) +
                     nvl(a.db_estorno_cr, 0) vl_debito_mes,
                     nvl(a.cr_entrada, 0) + nvl(a.cr_outros, 0) +
                     nvl(a.cr_estorno_db, 0) vl_credito_mes,
                     
                     (nvl(db_saidas, 0) + nvl(db_outros, 0) +
                     nvl(db_estorno_cr, 0) - nvl(a.cr_entrada, 0) -
                     nvl(a.cr_outros, 0) - nvl(a.cr_estorno_db, 0) -
                     nvl(a.saldo_cr, 0)) vl_sld_apurado,
                     nvl(a.deducoes, 0) vl_tot_ded
                from fs_apura_icms a
               where a.data_ate = vg_final
                 and a.empresa = vg_emp
                 and a.filial = vg_fil)
       where vl_sld_apurado < 0;
  
    vl_tot_deb         number(15, 2);
    vl_outros          number(15, 2);
    vl_tot_aj_debitos  number(15, 2);
    vl_estornos_cred   number(15, 2);
    vl_tot_creditos    number(15, 2);
    vl_aj_creditos     number(15, 2);
    vl_tot_aj_creditos number(15, 2);
    vl_estorno_deb     number(15, 2);
    vl_sld_credor_ant  number(15, 2);
    vl_sld_apurado     number(15, 2);
    vl_tot_ded         number(15, 2);
    vl_deb_esp         number(15, 2);
    vl_icms_recolher   number(15, 2);
    vl_sld_credor_tra  number(12, 2);
    vl_cred_receb      number(12, 2);
    vl_debito_mes      number(12, 2);
    vl_credito_mes     number(12, 2);
    v_cod_aj_apur      tstr8;
  
    /*
      UF  Apurac?o  Utilizac?o  Sequencia
      AC  0   0. Outros Debitos   0001
      AC  1   1. Estorno de credito   0001
      AC  0   2. Outros creditos  0001 (motivo a)
      AC  0   2. Outros creditos  0002 (motivo b) apurac?o da Substituic?o Tributaria
      AC  1   2. Outros creditos  0001 (motivo c)
      AC  1   3. Estorno de debito  0001
      AC  0   4. Deduc?es   0001
      Ex.: Codigo SC110001- Codigo criado pelo estado de Santa Catarina e
    
    */
  
  begin
    open cr;
    fetch cr
      into vl_tot_deb,
           vl_outros,
           vl_estornos_cred,
           vl_tot_creditos,
           vl_aj_creditos,
           vl_estorno_deb,
           vl_sld_credor_ant,
           vl_debito_mes,
           vl_credito_mes,
           vl_sld_apurado,
           vl_tot_ded;
    close cr;
  
    --/ outros debitos
    v_cod_aj_apur := fs_sped_utl.fb_cod_apuracao('SP', 0, 0);
  
    vg_registro := '1200';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || v_cod_aj_apur || vg_sep;
    vg_linha    := vg_linha || vl_sld_credor_ant || vg_sep;
    vg_linha    := vg_linha || vl_credito_mes || vg_sep;
    vg_linha    := vg_linha || vl_cred_receb || vg_sep;
    vg_linha    := vg_linha || vl_sld_apurado || vg_sep || vg_crlf;
  
    --/ verificar se vai gerar mesmo este registro ou sometne qdo for realizado ajustes conforme codigo.
    --/ eh necessario informar um codigo de ajuste
    --/ do jeito que traz, ja eh informado no -REGISTRO E110: APURAC?O DO ICMS - OPERAC?ES PROPRIAS
  
    --pl_gera_linha;
  
    --/
    pl_registro_1210;
    --/
  end;

  --/REGISTRO 1210: UTILIZAC?O DE CREDITOS FISCAIS
  procedure pl_registro_1210 is
    /*
    N?    Campo       Descric?o Tipo  Tam Dec
    01  REG         Texto fixo contendo "1210"  C   004   -
    02  TIPO_UTIL     Tipo de utilizac?o do credito: 0 - Deduc?o do ICMS normal;
        1 - Compensac?o de auto de infrac?o;
        2 - Transferencia de credito;
        3 - Restituic?o de credito em moeda;
        4 - Deduc?o do ICMS Substituic?o Tributaria apurado no mes (Substituto);
        5 - Compensac?o com documento de arrecadac?o -(Substituic?o Tributaria);
        9 - Outros.   N   001   -
    03  NR_DOC      Numero do documento utilizado na baixa de creditos  C   - -
    04  VL_CRED_UTIL  Total de credito utilizado  N   - 02
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := '1210';
  end;

  --/REGISTRO 1300: MOVIMENTAC?O DE COMBUSTIVEIS
  procedure pl_registro_1300 is
    /*
    N?    Campo       Descric?o Tipo  Tam Dec
    01  REG       Texto fixo contendo "1300"  C   004   -
    02  COD_ITEM      Codigo do Produto, constante do registro 0200   C   - -
    03  DATA        Data do fechamento da movimentac?o  N   008   -
    04  NR_INTERV   Numero da intervenc?o   N   - -
    05  ESTQ_ABERT    Estoque no inicio do dia  N   - -
    06  VOL_ENTR      Volume Total das Entradas   N   - -
    07  VOL_DISP      Volume Disponivel(05 + 06)  N   - -
    08  VOL_SAIDAS    Volume Total das Saidas(Somatorio dos registros de Volume de Vendas)  N   - -
    09  VAL_SAIDAS    Valor das Vendas (08 x Preco na Bomba)  N   - -
    10  ESTQ_ESCR   Estoque Escritural(07 - 08)   N   - -
    11  VAL_AJ_PER-DA Valor da Perda  N   - -
    12  VAL_AJ_GA-NHO Valor do ganho  N   - -
    13  ESTQ_FECHA    Estoque de Fechamento (Somatorio dos registros da   N   - -
    Observac?es:
    Nivel hierarquico - 2
    Ocorrencia - 1:N
    */
  begin
    vg_registro := '1300';
  
    pl_registro_1310;
    pl_registro_1320;
  end;

  --/REGISTRO 1310: VOLUME DE VENDAS
  procedure pl_registro_1310 is
    /*
    N?    Campo     Descric?o Tipo  Tam Dec
    01  REG       Texto fixo contendo "1310"  C   004   -
    02  NUM_TANQUE  Tanque onde foi armazenado o combustivel  C   - -
    03  BOMBA     Bomba Ligada ao Tanque  C   - -
    04  BICO      Bico Ligado a Bomba   N   - -
    05  FECHA     Valor aferido no fechamento   N   - -
    06  ABERT     Valor aferido na abertura   N   - -
    07  AFERI     Aferic?es da Bomba  N   - -
    Observac?es: O volume das vendas corresponde a: Fechamento menos Abertura menos Aferic?es.
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := '1310';
  end;

  --/REGISTRO 1320: CONCILIAC?O DE ESTOQUES
  procedure pl_registro_1320 is
    /*
    N?    Campo     Descric?o Tipo  Tam Dec
    01  REG       Texto fixo contendo "1320"  C   004   -
    02  NUM_TANQUE  Tanque onde foi armazenado o combustivel  C   - -
    03  FECH_FISICO   Volume aferido no tanque  N   - -
    Observac?es:
    Nivel hierarquico - 3
    Ocorrencia - 1:N
    */
  begin
    vg_registro := '1320';
  end;

  --/REGISTRO 1400: INFORMAC?O SOBRE VALORES AGREGADOS
  procedure pl_registro_1400 is
    /*
    N?    Campo     Descric?o Tipo  Tam Dec
    01  REG       Texto fixo contendo "1400"  C   004   -
    02  COD_ITEM  Codigo do item (campo 02 do Registro 0200)  C   - -
    03  MUN       Codigo do Municipio de origem   N   008   -
    04  VALOR     Valor mensal correspondente ao municipio  N   - 2
    Observac?es: Registro utilizado para subsidiar calculos de indices de participac?o de municipios.
    Nivel hierarquico - 2
    Ocorrencia - 1:N
    */
  begin
    vg_registro := '1400';
  end;

  --/REGISTRO 1990: ENCERRAMENTO DO BLOCO 1
  procedure pl_registro_1990 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "1990"  C   004   -
    02  QTD_LIN_1   Quantidade total de linhas do Bloco 1   N   - -
    Observac?es: Registro obrigatorio
    Nivel hierarquico - 1
    Ocorrencia - um (por arquivo)
    */
  
    v_aux number(9);
  begin
  
    vg_registro := '1990';
    v_aux       := fl_total_reg(vg_inic, '1');
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || v_aux || vg_sep || vg_crlf;
  
    pl_gera_linha;
  end;
  --*************************************************************************************************************
  --*************************************************************************************************************
  --                                          BLOCO - K
  --                                       Registro da Produção
  --*************************************************************************************************************
  --*************************************************************************************************************
  ----------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------
  --/REGISTRO K001: ABERTURA DO BLOCO k   
  procedure pl_registro_k001 is
    /*
    Nº Campo   Descricao                  Tipo Tam   Dec Obrig 
    01 REG     Texto fixo contendo "K001" C    004    -    O 
    02 IND_MOV Indicador de movimento:    C    001*   -    O
               0- Bloco com dados informados; 
               1- Bloco sem dados informados 
    */
  begin
    vg_conta_k := 0;
    vg_registro := 'K001';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || '0' || vg_sep || vg_crlf;
  
    pl_gera_linha;
    vg_conta_k := vg_conta_k + 1;
  end;
  --/REGISTRO K100: Período de Apuração do ICMS/IPI
  procedure pl_registro_k100 is
    /*
     =======================================================================      
     Este registro tem o objetivo de informar o período de apuração do 
     ICMS ou do IPI, prevalecendo os períodos mais curtos. 
     Contribuintes com mais de um período de apuração no mês declaram 
     um registro K100 para cada período no mesmo arquivo. 
     Não podem ser informados dois ou mais registros com os mesmos campos 
     DT_INI e DT_FIN.
     =======================================================================
     Nº Campo   Descricao                  Tipo Tam   Dec Obrig
     01 REG     Texto fixo contendo "K100"  C    4     -    O 
     02 DT_INI   Data inicial a que a apuração se refere N 8 - O 
     03 DT_FIN Data final a que a apuração se refere N 8 - O
    */
  begin
    vg_registro := 'K100';
    vg_linha    := vg_sep || vg_registro || vg_sep;
  
    vg_linha := vg_linha || to_char(vg_inic, 'DDMMRRRR') || vg_sep;
    vg_linha := vg_linha || to_char(vg_final, 'DDMMRRRR') || vg_sep;
    vg_linha := vg_linha || vg_sep || vg_crlf;
  
    pl_gera_linha;
    vg_conta_k := vg_conta_k + 1;
  end;
  --/REGISTRO K200: Estoque Escriturado
  procedure pl_registro_k200(p_dt_ref date) is
    /*
    =======================================================================
    Este registro tem o objetivo de informar o estoque final escriturado 
    do período de apuração informado no Registro K100, por tipo de estoque 
    e por participante, nos casos em que couber, das mercadorias de tipos 
    00 ¿ Mercadoria para revenda, 
    01 ¿ Matéria-Prima, 
    02 - Embalagem, 
    03 ¿ Produtos em Processo, 
    04 ¿ Produto Acabado, 
    05 ¿ Subproduto, 
    06 ¿ Produto Intermediário e 
    10 ¿ Outros Insumos 
    ¿ campo TIPO_ITEM do Registro 0200.
    A quantidade em estoque deve ser expressa, obrigatoriamente, na unidade 
    de medida de controle de estoque constante no campo 06 do registro 0200 ¿UNID_INV.
    A chave deste registro são os campos: DT_EST, COD_ITEM, IND_EST e COD_PART 
    (este, quando houver).
    O estoque escriturado informado no Registro K200 deve refletir a quantidade 
    existente na data final do período de apuração informado no Registro K100, 
    estoque este derivado dos apontamentos de estoque inicial / entrada / produção 
    /consumo / saída / movimentação interna. 
    Considerando isso, o estoque escriturado informado no K200 é resultante da 
    seguinte fórmula:
    Estoque final = estoque inicial + 
                    entradas/produção/movimentação interna ¿ 
                    Saída / consumo /movimentação interna.
    =======================================================================
    
     Nº Campo   Descricao                                  Tipo Tam   Dec Obrig
    01 REG Texto fixo contendo "K200"                      C 4 - O 
    02 DT_EST Data do estoque final                        N 8 - O 
    03 COD_ITEM Código do item (campo 02 do Registro 0200) C 60 - O 
    04 QTD Quantidade em estoque                           N - 3 O 
    05 IND_EST Indicador do tipo de estoque:               C 1 - O
            0 = Estoque de propriedade do informante e em seu poder; 
            1 = Estoque de propriedade do informante e em posse de terceiros; 
            2 = Estoque de propriedade de terceiros e em posse do informante 
    06 COD_PART Código do participante                     C 60 - OC
               (campo 02 do Registro 0150): - 
               proprietário/possuidor que não seja o 
               informante do arquivo 
    */
    cursor cr is
    /*
      SELECT A.GRUPO,
             B.DESCRICAO DESCR_GRUPO,
             '0' IND_EST -- Estoque de propriedade do informante e em seu poder; 
            ,
             A.PRODUTO,
             A.DESCRICAO
             --  ,TRUNC(P_REFER) REFER
            ,
             round(CE_SALDO_UTL.SALDO_FISICO(A.EMPRESA,
                                             1,
                                             A.PRODUTO,
                                             p_dt_ref),
                   3) SALDO_ATUAL
      
        FROM CE_PRODUTOS A, CE_GRUPOS B
       WHERE A.EMPRESA = 1
         AND A.ESTOQUE = 'S'
         AND B.EMPRESA = A.EMPRESA
         AND B.GRUPO = A.GRUPO
         AND round(CE_SALDO_UTL.SALDO_FISICO(A.EMPRESA,
                                             1,
                                             A.PRODUTO,
                                             p_dt_ref),
                   3) > 0;
      */
      select a.cod_item, 
             round(CE_SALDO_UTL.SALDO_FISICO(vg_emp,
                                             1,
                                             a.cod_item,
                                             p_dt_ref),
                   3) SALDO_ATUAL
        from TMP_SPED_BLOCO_0200 a
        order by to_number(a.cod_item) ;

  begin
    for reg in cr loop
      vg_registro := 'K200';
      vg_linha    := vg_sep || vg_registro || vg_sep;
      vg_linha    := vg_linha || to_char(p_dt_ref, 'DDMMRRRR') || vg_sep;
      vg_linha    := vg_linha || reg.cod_item || vg_sep;
      vg_linha    := vg_linha || reg.saldo_atual || vg_sep || vg_crlf;
    
      pl_gera_linha;
      vg_conta_k := vg_conta_k + 1;
    end loop;
  end;
  --/REGISTRO K210: Desmontagem de mercadorias ¿ Item de Origem
  /*
    Este registro tem como objetivo apresentar a desmontagem das mercadorias, 
    sendo apresentado o recurso original que foi desmontado. 
    A desmontagem é um processo que ocorre na separação das mercadorias em partes 
    que vão compor o estoque, sem que tenha ocorrido a industrialização. 
    No sistema BERP este registro será preenchido através do processo 
    Transferência Simples de Recurso quando for selecionado o campo desmontagem, 
    o registro K210 será preenchido com o recurso que possui a quantidade negativa.

    Campo 01 (REG) - Texto fixo contendo "K210".
    Será preenchido com o texto "K210".

    Campo 02 (DT_INI_OS) - Data de início da ordem de serviço.
    Este campo não será preenchido pelo sistema.

    Campo 03 (DT_FIN_OS) - Data de conclusão da ordem de serviço.
    Este campo não será preenchido pelo sistema..

    Campo 04 (COD_DOC_OS) - Código da ordem de serviço.
    Este campo não será preenchido pelo sistema..

    Campo 05 (COD_ITEM_ORI) - Código do Item de Origem.
    No sistema este campo será preenchido com Recurso que foi realizada a saída 
    do estoque informado no processo de Transferência Simples de Recurso 
    quando for selecionado o campo desmontagem.

    Campo 06 (QTD_ITEM_ORI) - Quantidade do Item de Origem.
    No sistema este campo será preenchido com a Quantidade que foi realizada a 
    saída do estoque informado no processo de Transferência Simples de Recurso 
    quando for selecionado o campo desmontagem.
  */
  procedure pl_registro_k210 is
  begin
    null;
  end;
  --/REGISTRO K215: Desmontagem de mercadorias ¿ Item de Destino
  procedure pl_registro_k215 is
  begin
    null;
  end;
  --/REGISTRO K220: movimentações internas entre mercadorias
  procedure pl_registro_k220 is
    /*
    =======================================================================    
    Apresenta todas as movimentações internas entre mercadorias no período 
    que não se enquadram nas movimentações de produção efetuada pela empresa 
    (K230), movimentações de consumo de material na produção efetuada pela 
    empresa (K235), movimentações de produção efetuada por terceiros (K250), 
    movimentações de consumo de material na produção efetuada por terceiros (K255).
      
    Este registro tem o objetivo de informar a movimentação interna entre 
    mercadorias de tipos: 
    00 ¿ Mercadoria para revenda; 
    01 ¿ Matéria-Prima; 
    02 ¿ Embalagem; 
    03 ¿ Produtos em Processo; 
    04 ¿ Produto Acabado; 
    05 ¿ Subproduto e 
    10 ¿ Outros Insumos 
    ¿ campo TIPO_ITEM do Registro 0200; 
    que não se enquadre nas movimentações internas já informadas
    nos Registros K230 ¿ Itens Produzidos e K235 ¿ Insumos Consumidos: 
    produção acabada e consumo no processo produtivo, respectivamente.
    Exemplo: reclassificação de um produto em outro código em função do 
    cliente a que se destina.
    A quantidade movimentada deve ser expressa, obrigatoriamente, na 
    unidade de medida do item de origem, constante no campo 06 do 
    registro 0200: UNID_INV. .
    A chave deste registro são os campos: 
    DT_MOV, COD_ITEM_ORI e COD_ITEM_DEST.
    
    ======================================================================= 
    Nº Campo             Descricao                      Tipo Tam   Dec Obrig
    01 REG               Texto fixo contendo "K220" C 4 - O 
    02 DT_MOV            Data da movimentação interna N 8 - O 
    03 COD_ITEM_ORI      Codigo do item de origem (campo 02 do Registro 0200) C 60 - O 
    04 COD_ITEM_DEST     Codigo do item de destino (campo 02 do Registro 0200) C 60 - O 
    05 QTD               Quantidade movimentada N - 3 O            
    */
  begin
    null;
  end;

  --/REGISTRO K230: Itens Produzidos
  procedure pl_registro_k230 is
    /*
    =======================================================================      
    Este registro tem o objetivo de informar a produção acabada de produto 
    em processo (tipo 03 ¿ campo TIPO_ITEM do registro 0200) 
    e produto acabado (tipo 04 ¿ campo TIPO_ITEM do registro 0200). 
    O produto resultante é classificado como tipo 03 ¿ produto em processo, 
    quando não estiver pronto para ser comercializado, mas estiver pronto 
    para ser consumido em outra fase de produção. O produto resultante é 
    classificado como tipo 04 ¿ produto acabado, quando estiver pronto 
    para ser comercializado.
    
    Deverá existir mesmo que a quantidade de produção acabada seja igual 
    a zero, nas situações em que exista o consumo de item componente/insumo 
    no registro filho K235. Nessa situação a produção ficou em elaboração. 
    Essa produção em elaboração não é quantificada, uma vez que a matéria 
    não é mais um insumo e nem é ainda um produto resultante.
    
    Quando a informação for por período de apuração (K100), o K230 somente deve 
    ser informado caso ocorra produção no período, com o respectivo consumo de 
    insumos no K235 para se ter essa produção, uma vez que não se teria como 
    vincular a quantidade consumida de insumos com a quantidade produzida do 
    produto resultante envolvendo mais de um período de apuração. Somente 
    podemos ter produção igual a zero no K230 quando a informação for por ordem 
    de produção e quando essa OP não for concluída até a data final do período 
    de apuração do K100 e quando houver o apontamento de consumo de insumos no K235.
    
    A quantidade de produção acabada deve ser expressa, obrigatoriamente, na unidade 
    de medida de controle de estoque constante no campo 06 do registro 0200: UNID_INV.
    Quando houver identificação da ordem de produção, a chave deste registro são os 
    campos: COD_DOC_OP e COD_ITEM.
    Nos casos em que a ordem de produção não for identificada, o campo chave passa 
    a ser COD_ITEM.
    =======================================================================   
    Nº Campo             Descricao                      Tipo Tam   Dec Obrig
    01 REG               Texto fixo contendo "K230" C 4 - O 
    02 DT_INI_OP         Data de início da ordem de produção N 8 - OC 
    03 DT_FIN_OP         Data de conclusão da ordem de produção N 8 - OC 
    04 COD_DOC_OP        Codigo de identificação da ordem de produção C 30 - OC 
    05 COD_ITEM          Codigo do item produzido (campo 02 do Registro 0200) C 60 - O 
    06 QTD_ENC           Quantidade de produção acabada N - 3 O        
    */
  begin
    null;
  end;

  --/REGISTRO K235: Insumos Consumidos
  procedure pl_registro_k235 is
    /*
    ======================================================================= 
    Este registro tem o objetivo de informar o consumo de mercadoria no 
    processo produtivo, vinculado ao produto resultante informado no campo 
    COD_ITEM do Registro K230 ¿ Itens Produzidos.
    Este registro é obrigatório quando existir o registro pai K230 e:
    a)a informação da quantidade produzida (K230) for por período de apuração(K100); ou
    b) a ordem de produção (K230) se iniciar e concluir no período de apuração (K100); ou
    c) a ordem de produção (K230) se iniciar no período de apuração (K100) e não for 
       concluída no mesmo período.
    A quantidade consumida deve ser expressa, obrigatoriamente, na unidade de medida 
    de controle de estoque constante no campo 06 do registro 0200: UNID_INV.
    A chave deste registro são os campos DT_SAÍDA e COD_ITEM.  
          
    =======================================================================   
    Nº Campo             Descricao                      Tipo Tam   Dec Obrig      
    01 REG Texto fixo contendo "K235"                   C 4 - O 
    02 DT_SAÍDA Data de saída do estoque para           N 8 - O 
                alocação ao produto
    03 COD_ITEM Código do item componente/insumo        C 60 - O 
               (campo 02 do Registro 0200) 
    04 QTD Quantidade consumida do item                 N - 3 O 
    05 COD_INS_SUBST Código do insumo que foi substituído, C 60 - OC
                     caso ocorra a substituição 
                     (campo 02 do Registro 0210) 
    */
  begin
    null;
  end;

  --/REGISTRO K250: Industrialização Efetuada por Terceiros - Itens Produzidos
  procedure pl_registro_k250 is
    /*
    =======================================================================  
    Este registro tem o objetivo de informar os produtos que foram 
    industrializados por terceiros e sua quantidade.
    A quantidade produzida deve ser expressa, obrigatoriamente, na unidade 
    de medida de controle de estoque constante no campo 06 do 
    registro 0200: UNID_INV.
    A chave deste registro são os campos DT_PROD e COD_ITEM.       
    =======================================================================   
    Nº Campo             Descricao                      Tipo Tam   Dec Obrig 
    01 REG               Texto fixo contendo "K250"     C 4 - O 
    02 DT_PROD           Data do reconhecimento da      N 8 - O 
                         produção ocorrida no terceiro
    03 COD_ITEM          Codigo do item produzido       C 60 - O 
                        (campo 02 do Registro 0200)
    04 QTD               Quantidade produzida           N - 3 O
    */
  begin
    null;
  end;
  --/REGISTRO K255: Industrialização em Terceiros - Insumos Consumidos
  procedure pl_registro_k255 is
    /*
    =======================================================================   
    Este registro tem o objetivo de informar a quantidade de consumo do 
    insumo que foi remetido para ser industrializado em terceiro, vinculado 
    ao produto resultante informado no campo COD_ITEM do Registro K250. 
    É obrigatório caso exista o registro pai K250.
    A quantidade consumida deve ser expressa, obrigatoriamente, na unidade 
    de medida de controle de estoque constante no campo 06 do registro 
    0200: UNID_INV.
    A chave deste registro são os campos DT_CONS e COD_ITEM deste Registro.      
    =======================================================================   
    Nº Campo             Descricao                      Tipo Tam   Dec Obrig 
    01 REG               Texto fixo contendo "K255"       C 4 - O 
    02 DT_CONS           Data do reconhecimento do        N 8 - O 
                         consumo do insumo referente 
                         ao produto informado no campo 
                         04 do Registro K250 
    03 COD_ITEM          Codigo do insumo                 C 60 - O 
                         (campo 02 do Registro 0200)
    04 QTD               Quantidade de consumo do insumo. N - 3 O 
    05 COD_INS_SUBST     Código do insumo que foi         C 60 - OC
                         substituído, caso ocorra a 
                         substituição 
                         (campo 02 do Registro 0210) 
    */
  begin
    null;
  end;

  --/REGISTRO K260: Reprocessamento/Reparo de Produto/Insumo
  procedure pl_registro_k260 is
  begin
    null;
  end;
  --/REGISTRO K265: Reprocessamento/Reparo ¿ Mercadorias Consumidas e/ou Retornadas
  procedure pl_registro_k265 is
  begin
    null;
  end;
  --/REGISTRO K270: Correção de Apontamento dos Registros K210, K220, K230, K250 e K260
  procedure pl_registro_k270 is
  begin
    null;
  end;
  --/REGISTRO K275: Correção  de  Apontamento  e  Retorno  de  Insumos  dos  Registros  K215,  K220,  K235, K255 e K265
  procedure pl_registro_k275 is
  begin
    null;
  end;
  --/REGISTRO K280: Correção de Apontamento ¿ Estoque Escriturado
  procedure pl_registro_k280 is
  begin
    null;
  end;
  --/REGISTRO K290: Produção Conjunta ¿ Ordem de Produção
  procedure pl_registro_k290 is
  begin
    null;
  end;
  --/REGISTRO K291: Produção Conjunta ¿ Itens Produzidos
  procedure pl_registro_k291 is
  begin
    null;
  end;
  --/REGISTRO K292: Produção Conjunta ¿ Insumos Consumidos
  procedure pl_registro_k292 is
  begin
    null;
  end;
  --/REGISTRO K300: Produção Conjunta ¿ Industrialização Efetuada por Terceiros
  procedure pl_registro_k300 is
  begin
    null;
  end;
  --/REGISTRO K301: Produção Conjunta ¿ Industrialização Efetuada por Terceiros ¿ Itens Produzidos
  procedure pl_registro_k301 is
  begin
    null;
  end;
  --/REGISTRO K302: Produção Conjunta ¿ Industrialização Efetuada por Terceiros ¿ Insumos Consumidos
  procedure pl_registro_k302 is
  begin
    null;
  end;
  --/REGISTRO K990: Encerramento do Bloco K
  procedure pl_registro_k990 is
    /*
    =======================================================================  
    Este registro destina-se a identificar o encerramento do bloco K e a 
    informar a quantidade de linhas (registros) existentes no bloco.       
    =======================================================================   
    Nº Campo             Descricao                      Tipo Tam   Dec Obrig 
    01 REG               Texto fixo contendo "K990"     C 004 - O 
    02 QTD_LIN_K         Quantidade total de K          N - - O
                         linhas do Bloco 
    */
  begin
    vg_conta_k  := vg_conta_k + 1;
    vg_registro := 'K990';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || vg_conta_k || vg_sep || vg_crlf;
    pl_gera_linha;
  
  end;
  --*************************************************************************************************************
  --*************************************************************************************************************
  --                                          BLOCO 9:
  --                         CONTROLE E ENCERRAMENTO DO ARQUIVO DIGITAL
  --*************************************************************************************************************
  --*************************************************************************************************************

  --/REGISTRO 9001: ABERTURA DO BLOCO 9
  procedure pl_registro_9001 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "9001".   C   004   -
    02  IND_MOV   Indicador de movimento:
      0- Bloco com dados informados;
      1- Bloco sem dados informados.  N   001   -
    Observac?es: Registro obrigatorio
    Nivel hierarquico - 1
    Ocorrencia - um (por arquivo)
    */
  begin
    vg_registro := '9001';
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || '0' || vg_sep || vg_crlf;
  
    pl_gera_linha;
  
  end;

  --/REGISTRO 9900: REGISTROS DO ARQUIVO
  procedure pl_registro_9900 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "9900".   C   004   -
    02  REG_BLC   Registro que sera totalizado no proximo campo.  C   004   -
    03  QTD_REG_BLC   Total de registros do tipo informado no campo anterior.   N   - -
    Observac?es: Registro obrigatorio
    Nivel hierarquico - 2
    Ocorrencia - varios (por arquivo)
    */
    cursor cr is
      select ordem, registro, count(registro) qtde
        from fs_arq_sped a
       where a.dt_ref = vg_inic
         and bloco != '9'
       group by ordem, registro
       order by 1;
  
  begin
    vg_registro := '9900';
    for reg in cr loop
      vg_linha := vg_sep || vg_registro || vg_sep;
      vg_linha := vg_linha || reg.registro || vg_sep;
      vg_linha := vg_linha || reg.qtde || vg_sep || vg_crlf;
    
      pl_gera_linha;
    
    end loop;
  
  end;

  --/REGISTRO 9990: ENCERRAMENTO DO BLOCO 9
  procedure pl_registro_9990 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "9990".   C   004   -
    02  QTD_LIN_9   Quantidade total de linhas do Bloco 9.  N   - -
    Observac?es: Registro obrigatorio
    Nivel hierarquico - 1
    Ocorrencia - um (por arquivo)
    */
    v_aux number(9);
  begin
  
    vg_registro := '9990';
    v_aux       := fl_total_reg(vg_inic, '9'); --+ 1 ;
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || v_aux || vg_sep || vg_crlf;
  
    pl_gera_linha;
  
  end;

  --/REGISTRO 9999: ENCERRAMENTO DO ARQUIVO DIGITAL
  procedure pl_registro_9999 is
    /*
    N?  Campo Descric?o Tipo  Tam Dec
    01  REG   Texto fixo contendo "9999".   C   004   -
    02  QTD_LIN   Quantidade total de linhas do arquivo digital.  N   - -
    Observac?es: Registro obrigatorio
    Nivel hierarquico - 0
    Ocorrencia - um (por arquivo)
    */
    v_aux number(9);
  begin
  
    vg_registro := '9999';
    v_aux       := fl_total_reg(vg_inic, null);
    vg_linha    := vg_sep || vg_registro || vg_sep;
    vg_linha    := vg_linha || v_aux || vg_sep || vg_crlf;
  
    pl_gera_linha;
  
  end;
  --------------------------------------------------------------------------------------
  --|| SPED-EFD ICMS/IPI - Versao 3.0.1
  --------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------
  procedure fs_sped_001(p_emp   in cd_empresas.empresa%type,
                        p_fil   in cd_filiais.filial%type,
                        p_firma in cd_firmas.firma%type,
                        p_cod   in fs_versoes_ac.codigo%type,
                        p_fin   in fs_finalid_ac.codigo%type,
                        p_inic  in date,
                        p_final in date,
                        p_seq   in number,
                        p_aplic in fs_versoes_ac.aplicacao%type) is
  
    --/ cursores globais
  
    cursor cr is
      select ordem, bloco, registro from t_registro_cot order by ordem;
  
    cursor crver is
      select versao
        from fs_versoes_ac
       where codigo = p_cod
         and aplicacao = p_aplic;
  
    cursor crparam is
      select * from fs_ent_ac70;
  
    ----------------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------
    --                            BLOCO PRINCIPAL
    --                          SOMENTE NIVEIS 0/1/2
    --                          SOMENTE NIVEIS 0/1/2
    --                          SOMENTE NIVEIS 0/1/2
    --                          SOMENTE NIVEIS 0/1/2
    ----------------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------
  
  begin
    --/inicializar  variaveis
    vg_num_linha := 0;
    vg_emp       := p_emp;
    vg_fil       := p_fil;
    vg_firma     := p_firma;
    vg_cod       := p_cod;
    vg_fin       := p_fin;
    vg_inic      := p_inic;
    vg_final     := p_final;
    vg_seq       := p_seq;
    vg_aplic     := p_aplic;
  
    --/
    --/apaga geração anterior
    delete from fs_arq_sped a
     where dt_ref BETWEEN p_inic AND p_final
       and (bloco, registro) in
           (select bloco, registro from t_registro_cot)
       and a.aplicacao = 'EFD';
  
    commit;
    --/
    open crparam;
    fetch crparam
      into vg_param;
    close crparam;
  
    vg_perfil := vg_param.perfil;
    vg_ativ   := vg_param.ativ;
  
    --/
    --/
    open crver;
    fetch crver
      into vg_ver;
    close crver;
    --/
    for reg in cr loop
      --/
      vg_ordem := reg.ordem;
      vg_bloco := reg.bloco;
      --------------------------------
      -- bloco 0
      --------------------------------
      if reg.bloco = '0' then
      
        if reg.registro = '0000' then
          --/
          pl_registro_0000;
          --/
        elsif reg.registro = '0001' then
          --/
          pl_registro_0001;
          --/
        elsif reg.registro = '0005' then
          --/
          pl_registro_0005;
          --/
        elsif reg.registro = '0015' then
          --/
          pl_registro_0015;
          --/
        elsif reg.registro = '0100' then
          --/
          pl_registro_0100;
          --/
        elsif reg.registro = '0150' then
          --/
          pl_registro_0150;
          --/
        elsif reg.registro = '0190' then
          --/
          pl_registro_0190;
          --/
        elsif reg.registro = '0200' then
          --/
          pl_registro_0200;
          --/
        elsif reg.registro = '0206' then
          --/
          pl_registro_0206;
          --/
        elsif reg.registro = '0220' then
          --/
          pl_registro_0220;
          --/
        elsif reg.registro = '0400' then
          --/
          pl_registro_0400;
          --/
        elsif reg.registro = '0450' then
          --/
          pl_registro_0450;
          --/
        elsif reg.registro = '0460' then
          --/
          pl_registro_0460;
          --/
        elsif reg.registro = '0990' then
          --/
          pl_registro_0990;
          --/
        end if;
        --------------------------------
        -- bloco C
        --------------------------------
      elsif reg.bloco = 'C' then
        vg_bloco := 'C';
        --/
        if reg.registro = 'C001' then
          --/
          pl_registro_c001;
          --/
        elsif reg.registro = 'C100' then
          --/
          pl_registro_c100;
          --/
        elsif reg.registro = 'C300' then
          --/
          pl_registro_c300;
          --/
        elsif reg.registro = 'C400' then
          --/
          pl_registro_c400;
          --/
        elsif reg.registro = 'C495' then
          --/
          pl_registro_c495;
          --/
        elsif reg.registro = 'C500' then
          --/
          pl_registro_c500;
          --/
        elsif reg.registro = 'C600' then
          --/
          pl_registro_c600;
          --/
        elsif reg.registro = 'C700' then
          --/
          pl_registro_c700;
          --/
        elsif reg.registro = 'C990' then
          --/
          pl_registro_c990;
          --/
        end if;
        --------------------------------
        -- bloco D
        --------------------------------
      elsif reg.bloco = 'D' then
      
        vg_bloco := 'D';
        --/
        if reg.registro = 'D001' then
          --/
          pl_registro_d001;
          --/
        elsif reg.registro = 'D100' then
          --/
          pl_registro_d100;
          --/
        elsif reg.registro = 'D300' then
          --/
          pl_registro_d300;
          --/
        elsif reg.registro = 'D350' then
          --/
          pl_registro_d350;
          --/
        elsif reg.registro = 'D400' then
          --/
          pl_registro_d400;
          --/
        elsif reg.registro = 'D500' then
          --/
          pl_registro_d500;
          --/
        elsif reg.registro = 'D600' then
          --/
          pl_registro_d600;
          --/
        elsif reg.registro = 'D695' then
          --/
          pl_registro_d695;
          --/
        elsif reg.registro = 'D990' then
          --/
          pl_registro_d990;
          --/
        end if;
        --------------------------------
        -- bloco E
        --------------------------------
      elsif reg.bloco = 'E' then
        --/
        vg_bloco := 'E';
        if reg.registro = 'E001' then
          --/
          pl_registro_e001;
          --/
        elsif reg.registro = 'E100' then
          --/
          pl_registro_e100;
          --/
        elsif reg.registro = 'E200' then
          --/
          pl_registro_e200;
          --/
        elsif reg.registro = 'E500' then
          --/
          pl_registro_e500;
          --/
        elsif reg.registro = 'E990' then
          --/
          pl_registro_e990;
          --/
        end if;
      
        --------------------------------
        -- bloco H
        --------------------------------
      elsif reg.bloco = 'H' then
        --/
        vg_bloco := 'H';
        if reg.registro = 'H001' then
          --/
          pl_registro_h001;
          --/
        elsif reg.registro = 'H005' then
          --/
          pl_registro_h005;
          --/
        elsif reg.registro = 'H020' then
          --/
          pl_registro_h020;
          --/
        elsif reg.registro = 'H990' then
          --/
          pl_registro_h990;
          --/
        end if;
        --------------------------------
        -- bloco k
        -------------------------------- 
      elsif reg.bloco = 'K' then
        vg_bloco := 'K';
        if reg.registro = 'K001' then
          --/
          pl_registro_k001;
          --/
        elsif reg.registro = 'K100' then
          --/
          pl_registro_k100;
          --/
        elsif reg.registro = 'K200' then
          --/
          pl_registro_k200(vg_final);
          --/
        elsif reg.registro = 'K220' then
          --/
          pl_registro_k220;
          --/
        elsif reg.registro = 'K230' then
          --/
          pl_registro_k230;
          --/
        elsif reg.registro = 'K235' then
          --/
          pl_registro_k235;
          --/
        elsif reg.registro = 'K250' then
          --/
          pl_registro_k250;
          --/
        elsif reg.registro = 'K255' then
          --/
          pl_registro_k255;
          --/
        elsif reg.registro = 'K990' then
          --/
          pl_registro_k990;
          --/
        end if;
        --------------------------------
        -- bloco 1
        --------------------------------
      elsif reg.bloco = '1' then
        --/
        vg_bloco := '1';
        if reg.registro = '1001' then
          --/
          pl_registro_1001;
          --/
        elsif reg.registro = '1100' then
          --/
          pl_registro_1100;
          --/
        elsif reg.registro = '1200' then
          --/
          pl_registro_1200;
          --/
        elsif reg.registro = '1300' then
          --/
          pl_registro_1300;
          --/
        elsif reg.registro = '1400' then
          --/
          pl_registro_1400;
          --/
        elsif reg.registro = '1990' then
          --/
          pl_registro_1990;
          --/
        end if;
        --------------------------------
        -- bloco 9
        --------------------------------
      elsif reg.bloco = '9' then
        --/
        vg_bloco := '9';
        if reg.registro = '9001' then
          --/
          pl_registro_9001;
          --/
        elsif reg.registro = '9900' then
          --/
          pl_registro_9900;
          --/
        elsif reg.registro = '9990' then
          --/
          pl_registro_9990;
          --/
        elsif reg.registro = '9999' then
          --/
          pl_registro_9999;
          --/
        end if;
      
      end if;
      --------------------------------
    --   FIM
    --------------------------------
    end loop;
    /*
    exception
       when others then
          vg_msg := vg_msg || ' * ' || substr(sqlerrm,
                                              1,
                                              100);
          raise_application_error(-20100,
                                  'Bloco:' || vg_bloco || ' - ' || vg_msg);
    */
  end;
end;
/
