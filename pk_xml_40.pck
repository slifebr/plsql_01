create or replace package pk_nfe_v40 is
   procedure gera_xml(pp_emp ft_notas.empresa%type
                   ,pp_fil ft_notas.filial%type
                   ,pp_nro ft_notas.num_nota%type
                   ,pp_ser ft_notas.sr_nota%type
                   ,pp_id  ft_notas.id%type
                   ,pp_amb char);
end;
/
create or replace package body pk_nfe_v40 is

      cursor cr_i(ppg_id number) is
               select a.*
                 from ft_itens_nf a
                     ,ft_notas    b
                where a.id_ft_nota = b.id
                  and b.id = ppg_id;

      cursor cr_ir(ppg_id number) is
         select distinct a.fil_origem
                        ,a.doc_origem
                        ,a.ser_origem
           from ft_itens_nf a
               ,ft_notas    b
          where a.id_ft_nota = b.id
            and b.id = ppg_id
            and a.doc_origem is not null;

      cursor cr_p (ppg_id number) is
         select a.*
           from ft_parc_nf a
               ,ft_notas   b
          where a.id_ft_nota = b.id
            and b.id = ppg_id
          order by dt_vence;

      cursor cr_ptem (ppg_id number) is
         select 'S'
           from ft_parc_nf a
               ,ft_notas   b
          where a.id_ft_nota = b.id
            and b.id = ppg_id
          ;

      cursor cr_m(ppg_id number) is
         select *
           from ft_msgs_nf a
          where a.id_ft_nota = ppg_id;

      cursor cr_ref(p_id ce_itens_nf.id%type) is
         select n.chave_nfe
           from ce_notas    n
               ,ce_itens_nf i
          where i.id = p_id
            and n.id = i.id_ce_nota;

      v_ref                    number(10);
      v_nf_ref                 ce_notas.chave_nfe%type;
      g_uf_ibge                cd_uf.cd_ibge%type;
      g_rg_nf                  ft_notas%rowtype;
      g_rg_emi                 cd_firmas%rowtype;
      g_rg_opr                 ft_oper%rowtype;
      g_atl_crec               ft_cfo.atl_crec%type;
      g_crt                    fs_param.crt%type;
      g_cnae                   fs_param.cnae%type; 
      g_rg_des                 cd_firmas%rowtype;
                
      rg_tra                   cd_firmas%rowtype;
      
      v_linha    varchar2(4000);
      



      v_mun_des  cd_cidades.ibge%type;
      v_cid_des  cd_cidades.cidade%type;
      v_pai_des  cd_paises.cod_siscomex%type;
      v_pais_des cd_paises.nome%type;
      v_item     number(9);
      v_tp_frete char(1);
      v_chave    varchar2(43);
      v_cnf      varchar2(9);
      v_ordem    number(9) := 0;
      
      v_msg      varchar2(4000);
      v_detalhe  varchar2(4000);
      --v_boletim     pp_lotes.boletim%type;
      --v_categoria   pp_lotes.categoria%type;
      --v_vc          ce_produtos.prof%type;
      v_unidade      ce_produtos.unidade%type;
      v_sigla        ce_unid.sigla%type;
      v_nbm          ft_clafis.cod_nbm%type;
      v_uf_ori       varchar2(2);
      v_dt_ori       varchar2(4);
      v_firma_ori    cd_firmas.firma%type;
      v_uf_ibge_ori  cd_uf.cd_ibge%type;
      v_natureza_ori cd_firmas.natureza%type;
      v_cgc_cpf_ori  cd_firmas.cgc_cpf%type;

      

     

      vqtditens         number;
      vfrete_rateado    number(15,
                               2);
      vfrete_item       number(15,
                               2);
      --v_versao sc_param.valor%type;                               
      --v_verproc         varchar2(100);
      --v_crt    fs_param.crt%type;
      --v_cnae   fs_param.cnae%type;
      --v_tpemis char(1);
      --v_indtot char(1);      
            
      v_x509cert        varchar2(32000);
      v_signature_value varchar2(32000);
      v_chave_nfe       varchar2(200);
      v_tipo_nf         varchar2(30);
      v_finalidade_nfe  number(1);
      v_cab_ref_nf      number(1);
      v_cab_ref_nfe     number(1);

      v_perc_red_base   number;
      v_iddest          number(1);
      v_temparc         varchar2(1);
 
   procedure gera_xml_010_ide (pp_emp ft_notas.empresa%type
                             ,pp_fil ft_notas.filial%type
                             ,pp_nro ft_notas.num_nota%type
                             ,pp_ser ft_notas.sr_nota%type
                             ,pp_id  ft_notas.id%type
                             ,pp_amb char);   
                             
   procedure gera_xml_020_emit (pp_emp ft_notas.empresa%type
                             ,pp_fil ft_notas.filial%type
                             ,pp_nro ft_notas.num_nota%type
                             ,pp_ser ft_notas.sr_nota%type
                             ,pp_id  ft_notas.id%type
                             ,pp_amb char);  
                             
   procedure gera_xml_030_dest (pp_emp ft_notas.empresa%type
                             ,pp_fil ft_notas.filial%type
                             ,pp_nro ft_notas.num_nota%type
                             ,pp_ser ft_notas.sr_nota%type
                             ,pp_id  ft_notas.id%type
                             ,pp_amb char);  
   --------------------------------------------------------------------------------
   procedure gera_xml_040_retirada  (pp_emp ft_notas.empresa%type
                                   ,pp_fil ft_notas.filial%type
                                   ,pp_nro ft_notas.num_nota%type
                                   ,pp_ser ft_notas.sr_nota%type
                                   ,pp_id  ft_notas.id%type
                                   ,pp_amb char);                             
   --------------------------------------------------------------------------------
   procedure gera_xml_050_entrega  (pp_emp ft_notas.empresa%type
                                   ,pp_fil ft_notas.filial%type
                                   ,pp_nro ft_notas.num_nota%type
                                   ,pp_ser ft_notas.sr_nota%type
                                   ,pp_id  ft_notas.id%type
                                   ,pp_amb char);
   --------------------------------------------------------------------------------
   procedure gera_xml_060_autxml  (pp_emp ft_notas.empresa%type
                                   ,pp_fil ft_notas.filial%type
                                   ,pp_nro ft_notas.num_nota%type
                                   ,pp_ser ft_notas.sr_nota%type
                                   ,pp_id  ft_notas.id%type
                                   ,pp_amb char);                                                                                           
   --------------------------------------------------------------------------------
   --------------------------------------------------------------------------------
   procedure gera_xml_000_inicio  (pp_emp ft_notas.empresa%type
                             ,pp_fil ft_notas.filial%type
                             ,pp_nro ft_notas.num_nota%type
                             ,pp_ser ft_notas.sr_nota%type
                             ,pp_id  ft_notas.id%type
                             ,pp_amb char)

    is
    v_versao                 varchar2(50);
    v_verproc                varchar2(50);  
    v_tpemis                 char(1);
    v_indtot                 char(1);

   
    

    v_avista                 ft_condpag.a_vista%type;



    rg_opr                   ft_oper%rowtype;   
    v_conta_ref              number(4);     
    begin

      -- versao atual do xml (3.1)
      
      Select valor
        Into v_versao
        From sc_param
       Where codigo = 'VERSAO_XML_' || pp_emp;

     -- v_versao  := '4.00';
     
     -- v_verproc := 'SGN-1.00';
      Select valor
         into v_verproc
        From sc_param a
       Where codigo = 'verProc';     

      -- limpa tabela temporaria
      delete t_nfe;

      -- codigo do regime tributario e cnae (2.0)
      select crt
            ,replace(replace(cnae,
                             '.',
                             ''),
                     '-',
                     '')
        into g_crt
            ,g_cnae
        from fs_param
       where empresa = pp_emp;

      -- limpa tabela temporaria
      delete t_nfe;

      -- dados da nota fiscal
      select *
        into g_rg_nf
        from ft_notas
       where empresa = pp_emp
         and filial = pp_fil
         and num_nota = pp_nro
         and sr_nota = pp_ser
         and parte = 0;
      
      -- emitente
      select *
        into g_rg_emi
        from cd_firmas
       where empresa = pp_emp
         and filial = pp_fil;
      -- tipo da emissao
      v_tpemis := g_rg_nf.forma_emissao;




      -- condicao de pagamento
      select decode(a_vista,
                    'S',
                    '0',
                    '1')
        into v_avista
        from ft_condpag
       where cod_condpag = g_rg_nf.cod_condpag;

      




      -- operacao
      select *
        into g_rg_opr
        from ft_oper
       where empresa = g_rg_nf.empresa
         and cod_oper = g_rg_nf.cod_oper;


      



      -- destinatario
      select * into g_rg_des from cd_firmas where firma = g_rg_nf.firma;

      -- cidade do destinatario
      select ibge
            ,cidade
        into v_mun_des
            ,v_cid_des
        from cd_cidades
       where cod_cidade = g_rg_nf.ent_cidade;

      -- pais destinatario
      select a.cod_siscomex pais_bacen
            ,nome
        into v_pai_des
            ,v_pais_des
        from cd_paises a
       where pais = g_rg_nf.ent_pais;

      -- frete
      if g_rg_nf.tp_frete = 'E' then
         v_tp_frete := '0';
      else
         v_tp_frete := '1';
      end if;

      -- transportadora
      if g_rg_nf.cod_transp is not null then
         select * into rg_tra from cd_firmas where firma = g_rg_nf.cod_transp;
      end if;

      select lpad(cd_nfe_seq.nextval,
                  9,
                  '0')
        into v_cnf
        from dual;

      v_linha := '<?xml version="1.0" encoding="UTF-8"?>';
      v_ordem := nvl(v_ordem,
                     0) + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<NFe xmlns="http://www.portalfiscal.inf.br/nfe">';
      v_ordem := nvl(v_ordem,
                     0) + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      g_uf_ibge := cd_firmas_utl.uf_ibge(g_rg_nf.firma);
      v_chave := g_uf_ibge;
      v_chave := v_chave || to_char(g_rg_nf.dt_emissao,
                                    'RRMM');
                                    
      v_chave := v_chave || cd_firmas_utl.cnpj_cpf_sem_masc(g_rg_nf.firma);
      v_chave := v_chave || '55';
      v_chave := v_chave || lpad(g_rg_nf.sr_nota,
                                 3,
                                 '0');
      v_chave := v_chave || lpad(g_rg_nf.num_nota,
                                 9,
                                 '0');
      v_chave := v_chave || v_tpemis || substr(v_cnf,
                                               -8);
      --<infNFe Id="NFe35180708236786000152550010000065751693900092" versao="4.00">                                                   -8);
      v_linha := '<infNFe Id="NFe' || v_chave || cd_nfe_utl.modulo11(v_chave) ||
                 '" versao="'||v_versao||'">';
       --v_linha := '<Versao>' || v_versao || '</Versao> ';

      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      --/-------------------------------------------------
      gera_xml_010_ide ( pp_emp 
                        ,pp_fil 
                        ,pp_nro 
                        ,pp_ser 
                        ,pp_id  
                        ,pp_amb );

      --/-------------------------------------------------
      
      gera_xml_020_emit( pp_emp 
                        ,pp_fil 
                        ,pp_nro 
                        ,pp_ser 
                        ,pp_id  
                        ,pp_amb );
      --/-------------------------------------------------
      
      gera_xml_030_dest( pp_emp 
                        ,pp_fil 
                        ,pp_nro 
                        ,pp_ser 
                        ,pp_id  
                        ,pp_amb );
      --/-------------------------------------------------
 end;
 
 procedure gera_xml_000_lixo (pp_emp ft_notas.empresa%type
                             ,pp_fil ft_notas.filial%type
                             ,pp_nro ft_notas.num_nota%type
                             ,pp_ser ft_notas.sr_nota%type
                             ,pp_id  ft_notas.id%type
                             ,pp_amb char) is
    v_versao                 varchar2(50);
    v_verproc                varchar2(50);  
    v_tpemis                 char(1);
    v_indtot                 char(1);

   
    

    v_avista                 ft_condpag.a_vista%type;



    rg_opr                   ft_oper%rowtype;   
    v_conta_ref              number(4);     
   begin            
      

      select count(a.id)
        into vqtditens
        from ft_itens_nf a
            ,ft_notas    b
       where b.empresa = pp_emp
         and b.filial = pp_fil
         and b.num_nota = pp_nro
         and b.sr_nota = pp_ser
         and b.parte = 0
         and a.id_ft_nota = b.id;

      v_item := 0;

      --|Produto

      -- raise_application_error(-20200,rg_opr.complemento );
      if rg_opr.complemento = 'N' then

         for rgi in cr_i(pp_id ) loop

            if nvl(g_rg_nf.vl_frete,
                   0) > 0 then
               vfrete_item := g_rg_nf.vl_frete / vqtditens;
            else
               vfrete_item := 0;
            end if;

            vfrete_rateado := vfrete_rateado + vfrete_item;

            v_item := v_item + 1;

            if nvl(g_rg_nf.vl_frete,
                   0) > 0 then
               if v_item = vqtditens then
                  if vfrete_rateado > g_rg_nf.vl_frete then
                     vfrete_item := vfrete_item -
                                    (vfrete_rateado - g_rg_nf.vl_frete);
                  elsif vfrete_rateado < g_rg_nf.vl_frete then
                     vfrete_item := vfrete_item +
                                    (g_rg_nf.vl_frete - vfrete_rateado);
                  end if;
               end if;
            end if;

            v_linha := '<det nItem="' || to_char(v_item) || '">';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<prod>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<cProd>' || rgi.produto || '</cProd>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<cEAN/>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha   := '<xProd>' || ltrim(rtrim(substr(lib_util.fnc_trata_string(rgi.descricao),
                                                         1,
                                                         100))) || '</xProd>';
            v_detalhe := ltrim(rtrim(substr(lib_util.fnc_trata_string(rgi.descricao),
                                            101)));

            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            begin
               if rgi.ncm is null then
                  select replace(replace(f.cod_nbm,
                                         '.',
                                         ''),
                                 '-',
                                 '')
                    into v_nbm
                    from ce_produtos p
                        ,ft_clafis   f
                   where f.cod_clafis = p.cod_clafis
                     and p.empresa = rgi.empresa
                     and p.produto = rgi.produto;
               else
                  v_nbm := replace(replace(rgi.ncm,
                                           '.',
                                           ''),
                                   '-',
                                   '');
               end if;
            exception
               when others then
                  v_nbm := null;
            end;
            if v_nbm is not null then
               v_linha := '<NCM>' || trim(v_nbm) || '</NCM>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            end if;

            v_linha := '<CFOP>' || substr(rgi.cod_cfo,
                                          1,
                                          1) ||
                       substr(rgi.cod_cfo,
                              3,
                              3) || '</CFOP>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            select sigla into v_sigla from ce_unid where unidade = rgi.uni_ven;
            --    v_linha := '<uCom>' || rgi.uni_ven || '</uCom>';
            v_linha := '<uCom>' || nvl(v_sigla,
                                       rgi.uni_ven) || '</uCom>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<qCom>' || trim(replace(to_char(rgi.qtd_val,
                                                        '9999999999990D0000'),
                                                ',',
                                                '.')) || '</qCom>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<vUnCom>' || trim(replace(to_char(rgi.pruni_sst,
                                                          '9999999999990D00000000'),
                                                  ',',
                                                  '.')) || '</vUnCom>';

            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<vProd>' ||
                       trim(replace(to_char(rgi.pruni_sst * rgi.qtd_val,
                                            '9999999999990D00'),
                                    ',',
                                    '.')) || '</vProd>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<cEANTrib/>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            select sigla into v_sigla from ce_unid where unidade = rgi.uni_val;
            --    v_linha := '<uTrib>' || rgi.uni_val || '</uTrib>';
            v_linha := '<uTrib>' || nvl(v_sigla,
                                        rgi.uni_val) || '</uTrib>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<qTrib>' || trim(replace(to_char(rgi.qtd_val,
                                                         '9999999999990D0000'),
                                                 ',',
                                                 '.')) || '</qTrib>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<vUnTrib>' || trim(replace(to_char(rgi.pruni_sst,
                                                           '9999999999990D00000000'),
                                                   ',',
                                                   '.')) || '</vUnTrib>';

            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            --| desconto produto
            if nvl(rgi.vl_desconto,0) > 0 then

                v_linha := '<vDesc>' || trim(replace(to_char(rgi.vl_desconto,
                                                               '9999999999990D00000000'),
                                                       ',',
                                                       '.')) || '</vDesc>';

                v_ordem := v_ordem + 1;
                insert into t_nfe
                values
                   (v_ordem
                   ,v_linha);

            end if;

            --| Outras despesas
            if nvl(rgi.vl_outras,0) > 0 then

                v_linha := '<vOutro>' || trim(replace(to_char(rgi.vl_outras,
                                                               '9999999999990D00000000'),
                                                       ',',
                                                       '.')) || '</vOutro>';

                v_ordem := v_ordem + 1;
                insert into t_nfe
                values
                   (v_ordem
                   ,v_linha);

            end if;

            --| frete produto
            if vfrete_item > 0 then
               v_linha := '<vFrete>' || trim(replace(to_char(vfrete_item,
                                                             '9999999999990D00'),
                                                     ',',
                                                     '.')) || '</vFrete>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            end if;

            if rgi.valor_unit = 0 then
               v_indtot := '0';
            else
               v_indtot := '1';
            end if;
            v_linha := '<indTot>' || v_indtot || '</indTot>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            --| combustivel
            if substr(rgi.cod_cfo,1,5) = '5.662' then
                v_linha := '<comb>';
                v_linha := v_linha ||' <cProdANP>620502001</cProdANP> ' ||
                                     ' <UFCons>SP</UFCons> ' ||
                           '</comb>';
                v_ordem := v_ordem + 1;
                insert into t_nfe
                values
                   (v_ordem
                   ,v_linha);
            end if;
            --|

            v_linha := '</prod>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<imposto>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<ICMS>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<ICMS' || substr(rgi.cod_tribut + 100,
                                         -2) || '>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<orig>' || rgi.cod_origem || '</orig>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<CST>' || substr(rgi.cod_tribut + 100,
                                         -2) || '</CST>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            if rgi.cod_tribut <> 40 then
               v_linha := '<modBC>0</modBC>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               if rgi.cod_tribut = 20 then
                  begin
                     v_perc_red_base := 0;
                     select round(100 - a.vl_bicms / a.pruni_sst * 100,
                                  2)
                       into v_perc_red_base
                       from ft_itens_nf a
                      where a.num_nota = rgi.id;
                  exception
                     when others then
                        null;
                  end;

                  --v_linha := '<pRedBC>' || trim( replace( to_char( rgi.pruni_sst, '9999999999990D00'),',','.' ) ) || '</pRedBC>';
                  v_linha := '<pRedBC>' || trim(replace(to_char(v_perc_red_base,
                                                                '9999999999990D00'),
                                                        ',',
                                                        '.')) || '</pRedBC>';
                  v_ordem := v_ordem + 1;
                  insert into t_nfe
                  values
                     (v_ordem
                     ,v_linha);
               end if;

               v_linha := '<vBC>' || trim(replace(to_char(nvl(rgi.vl_bicms,
                                                              0),
                                                          '9999999999990D00'),
                                                  ',',
                                                  '.')) || '</vBC>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<pICMS>' || trim(replace(to_char(nvl(rgi.aliq_icms,
                                                                0),
                                                            '9999999999990D00'),
                                                    ',',
                                                    '.')) || '</pICMS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vICMS>' || trim(replace(to_char(nvl(rgi.vl_icms,
                                                                0),
                                                            '9999999999990D00'),
                                                    ',',
                                                    '.')) || '</vICMS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            end if;

            v_linha := '</ICMS' || substr(rgi.cod_tribut + 100,
                                          -2) || '>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '</ICMS>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<IPI>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            if rgi.cod_enq_ipi is not null then
               --in( 1, 2, 3, 4, 5, 51, 52, 53, 54, 55 ) then
               --/ sera informado 999 pois ainda não foi criado table de enquadramento
               v_linha := '<cEnq>' || rgi.cod_enq_ipi || '</cEnq>';
            else
               v_linha := '<cEnq>999</cEnq>';

            end if;
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            if rgi.cod_tribut_ipi not in (50,0,01) then

               v_linha := '<IPINT>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || substr(rgi.cod_tribut_ipi + 100,
                                            -2) || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</IPINT>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            else -- rgi.cod_tribut_ipi in (50) then
               v_linha := '<IPITrib>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || substr(rgi.cod_tribut_ipi + 100,
                                            -2) || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vBC>' || trim(replace(to_char(nvl(rgi.vl_bipi,
                                                              0),
                                                          '9999999999990D00'),
                                                  ',',
                                                  '.')) || '</vBC>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<pIPI>' || trim(replace(to_char(nvl(rgi.aliq_ipi,
                                                               0),
                                                           '9999999999990D00'),
                                                   ',',
                                                   '.')) || '</pIPI>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vIPI>' || trim(replace(to_char(nvl(rgi.vl_ipi,
                                                               0),
                                                           '9999999999990D00'),
                                                   ',',
                                                   '.')) || '</vIPI>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</IPITrib>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            end if;

            v_linha := '</IPI>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<PIS>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            if rgi.cod_tribut_pis in (1,
                                      2) then
               v_linha := '<PISAliq>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || substr(rgi.cod_tribut_pis + 100,
                                            -2) || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vBC>' || trim(replace(to_char(nvl(rgi.vl_bpis,
                                                              0),
                                                          '9999999999990D00'),
                                                  ',',
                                                  '.')) || '</vBC>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<pPIS>' || trim(replace(to_char(nvl(rgi.aliq_pis,
                                                               0),
                                                           '9999999999990D00'),
                                                   ',',
                                                   '.')) || '</pPIS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vPIS>' || trim(replace(to_char(nvl(rgi.vl_pis,
                                                               0),
                                                           '9999999999990D00'),
                                                   ',',
                                                   '.')) || '</vPIS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</PISAliq>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            elsif rgi.cod_tribut_pis in (3) then
               v_linha := '<PISQtde>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || substr(rgi.cod_tribut_pis + 100,
                                            -2) || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vQBCPROD>' || trim(replace(to_char(nvl(rgi.vl_bpis,
                                                                   0),
                                                               '9999999999990D00'),
                                                       ',',
                                                       '.')) || '</vQBCPROD>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<pVALIQPROD>' ||
                          trim(replace(to_char(nvl(rgi.aliq_pis,
                                                   0),
                                               '9999999999990D00'),
                                       ',',
                                       '.')) || '</pVALIQPROD>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vPIS>' || trim(replace(to_char(nvl(rgi.vl_pis,
                                                               0),
                                                           '9999999999990D00'),
                                                   ',',
                                                   '.')) || '</vPIS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</PISQtde>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            elsif rgi.cod_tribut_pis in (4,
                                         6,
                                         7,
                                         8,
                                         9) then
               v_linha := '<PISNT>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || substr(rgi.cod_tribut_pis + 100,
                                            -2) || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</PISNT>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            elsif rgi.cod_tribut_pis in (99) then
               v_linha := '<PISOutr>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || substr(rgi.cod_tribut_pis + 100,
                                            -2) || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vBC>' || trim(replace(to_char(nvl(rgi.vl_bpis,
                                                              0),
                                                          '9999999999990D00'),
                                                  ',',
                                                  '.')) || '</vBC>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vPIS>' || trim(replace(to_char(nvl(rgi.aliq_pis,
                                                               0),
                                                           '9999999999990D00'),
                                                   ',',
                                                   '.')) || '</vPIS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<qBCProd>' || trim(replace(to_char(nvl(rgi.qtd_val,
                                                                  0),
                                                              '9999999999990D00'),
                                                      ',',
                                                      '.')) || '</qBCProd>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vAliqProd>' || trim(replace(to_char(nvl(rgi.aliq_pis,
                                                                    0),
                                                                '9999999999990D00'),
                                                        ',',
                                                        '.')) || '</vAliqProd>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            v_linha := '<vIPIDevol>'||'0.00'|| '</vIPIDevol>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);


               v_linha := '<vPIS>' || trim(replace(to_char(nvl(rgi.vl_pis,
                                                               0),
                                                           '9999999999990D00'),
                                                   ',',
                                                   '.')) || '</vPIS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</PISAliq>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            end if;
            v_linha := '</PIS>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<COFINS>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            if rgi.cod_tribut_cof in (1,
                                      2) then
               v_linha := '<COFINSAliq>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || substr(rgi.cod_tribut_cof + 100,
                                            -2) || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vBC>' || trim(replace(to_char(nvl(rgi.vl_bcof,
                                                              0),
                                                          '9999999999990D00'),
                                                  ',',
                                                  '.')) || '</vBC>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<pCOFINS>' || trim(replace(to_char(nvl(rgi.aliq_cof,
                                                                  0),
                                                              '9999999999990D00'),
                                                      ',',
                                                      '.')) || '</pCOFINS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vCOFINS>' || trim(replace(to_char(nvl(rgi.vl_cof,
                                                                  0),
                                                              '9999999999990D00'),
                                                      ',',
                                                      '.')) || '</vCOFINS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</COFINSAliq>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            elsif rgi.cod_tribut_cof in (3) then
               v_linha := '<COFINSQtde>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || substr(rgi.cod_tribut_cof + 100,
                                            -2) || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<qBCProd>' || trim(replace(to_char(nvl(rgi.qtd_val,
                                                                  0),
                                                              '9999999999990D00'),
                                                      ',',
                                                      '.')) || '</qBCProd>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vAliqProd>' || trim(replace(to_char(nvl(rgi.aliq_cof,
                                                                    0),
                                                                '9999999999990D00'),
                                                        ',',
                                                        '.')) || '</vAliqProd>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vCOFINS>' || trim(replace(to_char(nvl(rgi.vl_cof,
                                                                  0),
                                                              '9999999999990D00'),
                                                      ',',
                                                      '.')) || '</vCOFINS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</COFINSQtde>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            elsif rgi.cod_tribut_cof in (4,
                                         6,
                                         7,
                                         8,
                                         9) then
               v_linha := '<COFINSNT>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || substr(rgi.cod_tribut_cof + 100,
                                            -2) || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</COFINSNT>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            elsif rgi.cod_tribut_cof in (9) then
               v_linha := '<COFINSOutr>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || substr(rgi.cod_tribut_cof + 100,
                                            -2) || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vBC>' || trim(replace(to_char(nvl(rgi.vl_bcof,
                                                              0),
                                                          '9999999999990D00'),
                                                  ',',
                                                  '.')) || '</vBC>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<pCOFINS>' || trim(replace(to_char(nvl(rgi.aliq_cof,
                                                                  0),
                                                              '9999999999990D00'),
                                                      ',',
                                                      '.')) || '</pCOFINS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<qBCProd>' || trim(replace(to_char(nvl(rgi.qtd_val,
                                                                  0),
                                                              '9999999999990D00'),
                                                      ',',
                                                      '.')) || '</qBCProd>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vAliqProd>' || trim(replace(to_char(nvl(rgi.aliq_cof,
                                                                    0),
                                                                '9999999999990D00'),
                                                        ',',
                                                        '.')) || '</vAliqProd>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vCOFINS>' || trim(replace(to_char(nvl(rgi.vl_cof,
                                                                  0),
                                                              '9999999999990D00'),
                                                      ',',
                                                      '.')) || '</vCOFINS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</COFINSOutr>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            end if;
            v_linha := '</COFINS>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '</imposto>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            if v_detalhe is not null then
               v_linha := '<infAdProd>' || trim(v_detalhe) || '</infAdProd>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            end if;

            v_linha := '</det>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         end loop;

      else
         --| caso contrario

         for rgi in cr_i(pp_id ) loop

            --  if nvl( g_rg_nf.vl_frete, 0 ) > 0 then
            --    vfrete_item := g_rg_nf.vl_frete / vqtditens;
            --  else
            vfrete_item    := 0;
            vfrete_rateado := 0;
            --  end if;

            v_item := v_item + 1;

            if nvl(g_rg_nf.vl_frete,
                   0) > 0 then
               if v_item = vqtditens then
                  if vfrete_rateado > g_rg_nf.vl_frete then
                     vfrete_item := vfrete_item -
                                    (vfrete_rateado - g_rg_nf.vl_frete);
                  elsif vfrete_rateado < g_rg_nf.vl_frete then
                     vfrete_item := vfrete_item +
                                    (g_rg_nf.vl_frete - vfrete_rateado);
                  end if;
               end if;
            end if;

            v_linha := '<det nItem="' || to_char(v_item) || '">';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<prod>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<cProd>' || rgi.produto || '</cProd>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<cEAN/>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<xProd>' || substr(rgi.descricao,
                                           1,
                                           50) || '</xProd>';

            v_detalhe := ltrim(rtrim(substr(rgi.descricao,
                                            51)));

            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            begin
               select replace(f.cod_nbm,
                              '.',
                              '')
                 into v_nbm
                 from ce_produtos p
                     ,ft_clafis   f
                where f.cod_clafis = p.cod_clafis
                  and p.empresa = rgi.empresa
                  and p.produto = rgi.produto;
            exception
               when others then
                  v_nbm := null;
            end;

            if v_nbm is not null then
               v_linha := '<NCM>' || trim(v_nbm) || '</NCM>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            end if;

            v_linha := '<CFOP>' || substr(rgi.cod_cfo,
                                          1,
                                          1) ||
                       substr(rgi.cod_cfo,
                              3,
                              3) || '</CFOP>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            select sigla into v_sigla from ce_unid where unidade = rgi.uni_ven;
            --    v_linha := '<uCom>' || rgi.uni_ven || '</uCom>';
            v_linha := '<uCom>' || 'UN' || '</uCom>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<qCom>' || /*trim( replace( to_char( rgi.qtd_val, '9999999999990D0000'),',','.' ) ) */
                       0 || '</qCom>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<vUnCom>' || /*trim( replace( to_char( rgi.pruni_sst, '9999999999990D00000000'),',','.' ) )*/
                       0 || '</vUnCom>';

            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<vProd>' || /*trim( replace( to_char( rgi.pruni_sst*rgi.qtd_val, '9999999999990D00'),',','.' ) )*/
                       0 || '</vProd>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<cEANTrib/>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            select sigla into v_sigla from ce_unid where unidade = rgi.uni_val;
            --    v_linha := '<uTrib>' || rgi.uni_val || '</uTrib>';
            v_linha := '<uTrib>' || /*nvl( v_sigla, rgi.uni_val )*/
                       'UN' || '</uTrib>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<qTrib>' || 0 || '</qTrib>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<vUnTrib>' || 0 || '</vUnTrib>';

            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            -- rateio do frete por item (2.0)
            if vfrete_item > 0 then
               v_linha := '<vFrete>' || /*trim( replace( to_char( vfrete_item, '9999999999990D00'),',','.' ) )*/
                          0 || '</vFrete>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            end if;

            if rgi.valor_unit = 0 then
               v_indtot := '0';
            else
               v_indtot := '1';
            end if;
            v_linha := '<indTot>' || v_indtot || '</indTot>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '</prod>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<imposto>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<ICMS>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<ICMS' || substr(rgi.cod_tribut + 100,
                                         -2) || '>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<orig>' || rgi.cod_origem || '</orig>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<CST>' || substr(rgi.cod_tribut + 100,
                                         -2) || '</CST>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            if rgi.cod_tribut <> 40 then
               v_linha := '<modBC>3</modBC>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               if rgi.cod_tribut = 20 then
                  v_linha := '<pRedBC>' || trim(replace(to_char(rgi.pruni_sst,
                                                                '9999999999990D00'),
                                                        ',',
                                                        '.')) || '</pRedBC>';
                  v_ordem := v_ordem + 1;
                  insert into t_nfe
                  values
                     (v_ordem
                     ,v_linha);
               end if;

               v_linha := '<vBC>' || trim(replace(to_char(nvl(rgi.vl_bicms,
                                                              0),
                                                          '9999999999990D00'),
                                                  ',',
                                                  '.')) || '</vBC>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<pICMS>' || trim(replace(to_char(nvl(rgi.aliq_icms,
                                                                0),
                                                            '9999999999990D00'),
                                                    ',',
                                                    '.')) || '</pICMS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vICMS>' || trim(replace(to_char(nvl(rgi.vl_icms,
                                                                0),
                                                            '9999999999990D00'),
                                                    ',',
                                                    '.')) || '</vICMS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            end if;

            v_linha := '</ICMS' || substr(rgi.cod_tribut + 100,
                                          -2) || '>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '</ICMS>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<IPI>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<cEnq>999</cEnq>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            if rgi.cod_tribut_ipi in (1,
                                      2,
                                      3,
                                      4,
                                      5,
                                      --50,
                                      51,
                                      52,
                                      53,
                                      54,
                                      55) then
               v_linha := '<IPINT>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || 52 || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</IPINT>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            elsif rgi.cod_tribut_ipi in (50) then
               v_linha := '<IPITrib>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || substr(rgi.cod_tribut_ipi + 100,
                                            -2)
                         /*0*/
                          || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vBC>' || trim(replace(to_char(nvl(rgi.vl_bipi,
                                                              0),
                                                          '9999999999990D00'),
                                                  ',',
                                                  '.'))
                         /*0*/
                          || '</vBC>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<pIPI>' || trim(replace(to_char(nvl(rgi.aliq_ipi,
                                                               0),
                                                           '9999999999990D00'),
                                                   ',',
                                                   '.'))
                         /*0 */
                          || '</pIPI>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vIPI>' || trim(replace(to_char(nvl(rgi.vl_ipi,
                                                               0),
                                                           '9999999999990D00'),
                                                   ',',
                                                   '.'))
                         /*0*/
                          || '</vIPI>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '/<IPITrib>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            end if;

            v_linha := '</IPI>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);


            v_linha := '<PIS>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            if rgi.cod_tribut_pis in (1,
                                      2) then
               v_linha := '<PISAliq>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || 0 || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vBC>' || 0 || '</vBC>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<pPIS>' || /*trim( replace( to_char( nvl( rgi.aliq_pis, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</pPIS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vPIS>' || /*trim( replace( to_char( nvl( rgi.vl_pis, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</vPIS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</PISAliq>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            elsif rgi.cod_tribut_pis in (3) then
               v_linha := '<PISQtde>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || 0 || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vQBCPROD>' || 0 || '</vQBCPROD>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<pVALIQPROD>' || 0 || '</pVALIQPROD>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vPIS>' || 0 || '</vPIS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</PISQtde>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            elsif rgi.cod_tribut_pis in (4,
                                         6,
                                         7,
                                         8,
                                         9) then
               v_linha := '<PISNT>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || '07' || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</PISNT>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            elsif rgi.cod_tribut_pis in (99) then
               v_linha := '<PISOutr>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || 0 || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vBC>' || 0 || '</vBC>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vPIS>' || 0 || '</vPIS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<qBCProd>' || 0 || '</qBCProd>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vAliqProd>' || 0 || '</vAliqProd>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vPIS>' || 0 || '</vPIS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</PISAliq>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            end if;
            v_linha := '</PIS>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<COFINS>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            if rgi.cod_tribut_cof in (1,
                                      2) then
               v_linha := '<COFINSAliq>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || /*substr( rgi.cod_tribut_cof + 100, -2 )*/
                          0 || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vBC>' || /*trim( replace( to_char( nvl( rgi.vl_bcofins, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</vBC>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<pCOFINS>' || /*trim( replace( to_char( nvl( rgi.aliq_cofins, 0 ), '9999999999990D00'),',','.' ) ) */
                          0 || '</pCOFINS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vCOFINS>' || /* trim( replace( to_char( nvl( rgi.vl_cofins, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</vCOFINS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</COFINSAliq>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            elsif rgi.cod_tribut_cof in (3) then
               v_linha := '<COFINSQtde>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || /*substr( rgi.cod_tribut_cof + 100, -2 ) */
                          0 || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<qBCProd>' || /*trim( replace( to_char( nvl( rgi.qtd_val, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</qBCProd>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vAliqProd>' || /* trim( replace( to_char( nvl( rgi.aliq_cofins, 0 ), '9999999999990D00'),',','.' ) ) */
                          0 || '</vAliqProd>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vCOFINS>' || /*trim( replace( to_char( nvl( rgi.vl_cofins, 0 ), '9999999999990D00'),',','.' ) ) */
                          0 || '</vCOFINS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</COFINSQtde>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            elsif rgi.cod_tribut_cof in (4,
                                         6,
                                         7,
                                         8,
                                         9) then
               v_linha := '<COFINSNT>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || /*substr( rgi.cod_tribut_cof + 100, -2 ) */
                          '07' || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</COFINSNT>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            elsif rgi.cod_tribut_cof in (9) then
               v_linha := '<COFINSOutr>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<CST>' || /*substr( rgi.cod_tribut_cof + 100, -2 )*/
                          0 || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vBC>' || /*trim( replace( to_char( nvl( rgi.vl_bcofins, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</vBC>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<pCOFINS>' || /*trim( replace( to_char( nvl( rgi.aliq_cofins, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</pCOFINS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<qBCProd>' || /*trim( replace( to_char( nvl( rgi.qtd_val, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</qBCProd>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vAliqProd>' || /*trim( replace( to_char( nvl( rgi.aliq_cofins, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</vAliqProd>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<vCOFINS>' || /*trim( replace( to_char( nvl( rgi.vl_cofins, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</vCOFINS>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '</COFINSOutr>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            end if;
            v_linha := '</COFINS>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '</imposto>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            if v_detalhe is not null then
               v_linha := '<infAdProd>' || /*trim( v_detalhe )*/
                          null || '</infAdProd>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            end if;

            v_linha := '</det>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

         end loop;
      end if;
      --|  FIM DO LOOP DO PRODUTO

      v_linha := '<total>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<ICMSTot>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<vBC>' || trim(replace(to_char(nvl(g_rg_nf.vl_bicms,
                                                     0),
                                                 '9999999999990D00'),
                                         ',',
                                         '.')) || '</vBC>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<vICMS>' || trim(replace(to_char(nvl(g_rg_nf.vl_icms,
                                                       0),
                                                   '9999999999990D00'),
                                           ',',
                                           '.')) || '</vICMS>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);


      v_linha := '<vICMSDeson>0.00</vICMSDeson>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<vFCPUFDest>0.00</vFCPUFDest>';
      v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
      v_linha := '<vICMSUFDest>0.00</vICMSUFDest>';
      v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

      v_linha := '<vICMSUFRemet>0.00</vICMSUFRemet>';
      v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

      v_linha := '<vFCP>0.00</vFCP>';
      v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

      v_linha := '<vBCST>' || trim(replace(to_char(nvl(g_rg_nf.vl_bicms_sub,
                                                       0),
                                                   '9999999999990D00'),
                                           ',',
                                           '.')) || '</vBCST>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<vST>' || trim(replace(to_char(nvl(g_rg_nf.vl_icms_sub,
                                                     0),
                                                 '9999999999990D00'),
                                         ',',
                                         '.')) || '</vST>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);



      v_linha := '<vFCPST>0.00</vFCPST>';
      v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

      v_linha := '<vFCPSTRet>0.00</vFCPSTRet>';
      v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
--<vST>0.00</vST>



      /*if rg_opr.complemento = 'N' then*/
      v_linha := '<vProd>' || trim(replace(to_char(nvl(g_rg_nf.vl_produtos,
                                                       0),
                                                   '9999999999990D00'),
                                           ',',
                                           '.')) || '</vProd>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<vFrete>' || trim(replace(to_char(nvl(g_rg_nf.vl_frete,
                                                        0),
                                                    '9999999999990D00'),
                                            ',',
                                            '.')) || '</vFrete>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<vSeg>' || trim(replace(to_char(nvl(g_rg_nf.vl_seguro,
                                                      0),
                                                  '9999999999990D00'),
                                          ',',
                                          '.')) || '</vSeg>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<vDesc>' || trim(replace(to_char(nvl(g_rg_nf.vl_desconto,
                                                       0),
                                                   '9999999999990D00'),
                                           ',',
                                           '.')) || '</vDesc>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<vII>0.00</vII>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<vIPI>' || trim(replace(to_char(nvl(g_rg_nf.vl_ipi,
                                                      0),
                                                  '9999999999990D00'),
                                          ',',
                                          '.')) || '</vIPI>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<vPIS>' || trim(replace(to_char(nvl(g_rg_nf.vl_pis,
                                                      0),
                                                  '9999999999990D00'),
                                          ',',
                                          '.')) || '</vPIS>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<vCOFINS>' || trim(replace(to_char(nvl(g_rg_nf.vl_cofins,
                                                         0),
                                                     '9999999999990D00'),
                                             ',',
                                             '.')) || '</vCOFINS>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<vOutro>' || trim(replace(to_char(nvl(g_rg_nf.vl_outros,
                                                        0),
                                                    '9999999999990D00'),
                                            ',',
                                            '.')) || '</vOutro>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<vNF>' || trim(replace(to_char(nvl(g_rg_nf.vl_total,
                                                     0),
                                                 '9999999999990D00'),
                                         ',',
                                         '.')) || '</vNF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '</ICMSTot>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '</total>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<transp>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<modFrete>' || v_tp_frete || '</modFrete>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      if g_rg_nf.cod_transp is not null then

         v_linha := '<transporta>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         if rg_tra.natureza = 'J' then
            v_linha := '<CNPJ>' || replace(replace(replace(replace(rg_tra.cgc_cpf,
                                                                   '-',
                                                                   ''),
                                                           '.',
                                                           ''),
                                                   '-',
                                                   ''),
                                           '/',
                                           '') || '</CNPJ>';
         else
            v_linha := '<CPF>' || replace(replace(replace(replace(rg_tra.cgc_cpf,
                                                                  '-',
                                                                  ''),
                                                          '.',
                                                          ''),
                                                  '-',
                                                  ''),
                                          '/',
                                          '') || '</CPF>';
         end if;
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         v_linha := '<xNome>' || trim(rg_tra.nome) || '</xNome>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         if rg_tra.iest is not null then
            v_linha := '<IE>' || trim(replace(replace(replace(rg_tra.iest,
                                                              '.',
                                                              ''),
                                                      '-',
                                                      ''),
                                              '/',
                                              '')) || '</IE>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         end if;

         v_linha := '<xEnder>' || rg_tra.endereco || '</xEnder>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         v_linha := '<xMun>' || trim(cd_firmas_utl.cidade(rg_tra.firma)) ||
                    '</xMun>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         v_linha := '<UF>' || rg_tra.uf || '</UF>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         v_linha := '</transporta>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

      end if;

      if g_rg_nf.placa_veic is not null and
         g_rg_nf.placa_uf is not null then
         v_linha := '<veicTransp>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         v_linha := '<placa>' || upper(replace(replace(g_rg_nf.placa_veic,
                                                       '-',
                                                       ''),
                                               ' ',
                                               '')) || '</placa>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         v_linha := '<UF>' || g_rg_nf.placa_uf || '</UF>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         v_linha := '<RNTC>000000000</RNTC>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         v_linha := '</veicTransp>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;

      v_linha := '<vol>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<qVol>' || nvl(g_rg_nf.vol_qtd,
                                 1) || '</qVol>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      if g_rg_nf.vol_especie is not null then
         v_linha := '<esp>' || g_rg_nf.vol_especie || '</esp>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;

      if g_rg_nf.vol_marca is not null then
         v_linha := '<marca>' || g_rg_nf.vol_marca || '</marca>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;

      if g_rg_nf.vol_numero is not null then
         v_linha := '<nVol>' || g_rg_nf.vol_numero || '</nVol>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;

      v_linha := '<pesoL>' || trim(replace(to_char(nvl(g_rg_nf.peso_liquido,
                                                       0),
                                                   '9999999999990D000'),
                                           ',',
                                           '.')) || '</pesoL>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<pesoB>' || trim(replace(to_char(nvl(g_rg_nf.peso_bruto,
                                                       0),
                                                   '9999999999990D000'),
                                           ',',
                                           '.')) || '</pesoB>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '</vol>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '</transp>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_temparc := 'N';
      open cr_ptem(pp_id );
      fetch cr_ptem into v_temparc;
      close cr_ptem;

      if g_atl_crec = 'S' and v_temparc = 'S' then
         v_linha := '<cobr>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         v_linha := '<fat>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         v_linha := '<nFat>' || g_rg_nf.num_nota || '</nFat>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         v_linha := '<vOrig>' || trim(replace(to_char(nvl(g_rg_nf.vl_total,
                                                          0),
                                                      '9999999999990D00'),
                                              ',',
                                              '.')) || '</vOrig>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         v_linha := '<vLiq>' || trim(replace(to_char(nvl(g_rg_nf.vl_total,
                                                         0),
                                                     '9999999999990D00'),
                                             ',',
                                             '.')) || '</vLiq>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         v_linha := '</fat>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

         v_item := 0;
         for rgi in cr_p(pp_id ) loop

            v_item := v_item + 1;

            v_linha := '<dup>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<nDup>' || to_char(rgi.num_nota) || '/' ||
                       to_char(v_item) || '</nDup>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<dVenc>' || to_char(rgi.dt_vence,
                                            'RRRR-MM-DD') || '</dVenc>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '<vDup>' || trim(replace(to_char(nvl(rgi.valor,
                                                            0),
                                                        '9999999999990D00'),
                                                ',',
                                                '.')) || '</vDup>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            v_linha := '</dup>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         end loop;

         v_linha := '</cobr>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

      end if;

      v_msg := null;
      for rgi in cr_m(pp_id ) loop
         v_msg := substr(v_msg || ' ' || rgi.mensagem,
                         1,
                         4000);
      end loop;
      v_msg := ltrim(v_msg);
      if v_msg is not null then
         v_linha := '<infAdic>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
         v_linha := '<infCpl>' || v_msg || '</infCpl>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
         v_linha := '</infAdic>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;

      v_linha := '</infNFe>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '</NFe>';

      --v_linha := '</Envio>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      if pp_amb = 1 then
         update ft_notas
            set nfe = v_cnf
          where empresa = pp_emp
            and filial = pp_fil
            and num_nota = pp_nro
            and sr_nota = pp_ser
            and parte = 0;
      end if;

      commit;

   end;
   --------------------------------------------------------------------------------
   
   --------------------------------------------------------------------------------
   procedure gera_xml_010_ide  (pp_emp ft_notas.empresa%type
                             ,pp_fil ft_notas.filial%type
                             ,pp_nro ft_notas.num_nota%type
                             ,pp_ser ft_notas.sr_nota%type
                             ,pp_id  ft_notas.id%type
                             ,pp_amb char)

    is
    v_desc_cfo               ft_cfo.descricao%type; 
    v_natureza               ft_cfo.natureza%type;   
    v_tipo_imp               char(1);
    v_finalid                char(1);
    v_conta_ref              number;
    begin
      
      v_linha := '<ide>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<cNF/>
*/
      v_linha := '<cNF>' || substr(v_cnf,
                                   -8) || '</cNF>';

      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<cUF/>
*/
      v_linha := '<cUF>' || g_uf_ibge || '</cUF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

/*
<natOp/>
*/
      select descricao
            ,atl_crec
        into v_desc_cfo
            ,g_atl_crec
        from ft_cfo
       where cod_cfo = g_rg_nf.cod_cfo;

      v_linha := '<natOp>' || v_desc_cfo || '</natOp>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<mod/>
*/
      v_linha := '<mod>55</mod>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

/*
<serie/>
*/
      v_linha := '<serie>' || trim(to_char(g_rg_nf.sr_nota)) || '</serie>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

/*
<nNF/>
*/

      v_linha := '<nNF>' || pp_nro || '</nNF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

/*
<dhEmi/>
*/
      v_linha := '<dhEmi>' || to_char(g_rg_nf.dt_emissao,
                                      'rrrr-mm-dd') || 'T' ||
                 to_char(sysdate,
                         'hh24:mi') || ':00-03:00' || '</dhEmi>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<fusoHorario/>
*/
/*
Preencher com o fuso horário do estado emissor do evento. 
UTC – Universal Coordinated Time, onde pode ser 
-02:00 (Fernando de Noronha), 
-03:00 (Brasília) ou 
-04:00 (Manaus). 
No horário de verão serão -01:00, -02:00 e -03:00 respectivamente. 
*/
      v_linha := '<fusoHorario>' || '-03:00' || '</fusoHorario>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<dhSaiEnt/>
*/
      if substr(g_rg_nf.cod_cfo,
                1,
                1) <> '7' then
         v_linha := '<dhSaiEnt>' || to_char(g_rg_nf.dt_entsai,
                                            'rrrr-mm-dd') || 'T' ||
                    to_char(sysdate,
                            'hh24:mi') || ':00-03:00' || '</dhSaiEnt>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);

      end if;
/*
<tpNf/>
*/
      -- tipo documento fiscal
      select decode(natureza,
                    'E',
                    '0',
                    '1')
        into v_natureza
        from ft_cfo
       where cod_cfo = g_rg_nf.cod_cfo;
       
      v_linha := '<tpNF>' || v_natureza || '</tpNF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<idDest/>
*/
/*
informar o identificador de local de destino da operação:
1 - Operação interna;
2 - Operação interestadual;
3 - Operação com exterior.
*/
      if substr(g_rg_nf.cod_cfo,
                1,
                1) in (1,
                       5) then
         v_iddest := 1;
      elsif substr(g_rg_nf.cod_cfo,
                   1,
                   1) in (2,
                          6) then
         v_iddest := 2;
      else
         v_iddest := 3;
      end if;

      v_linha := '<idDest>' || v_iddest || '</idDest>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<indFinal/>
*/
/*
 informar o indicador de operação com Consumidor final:
 0 - Não;
 1 - Consumidor final;
 (campo novo) [23-12-13]
*/

      v_linha := '<indFinal>' || g_rg_nf.ind_final || '</indFinal>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<indPres/>
*/
/*
 informar o indicador de presença do comprador no estabelecimento comercial no momento da operação:
 0 - Não se aplica (por exemplo, Nota Fiscal complementar ou de ajuste);
 1 - Operação presencial;
 2 - Operação não presencial, pela Internet;
 3 - Operação não presencial, Teleatendimento;
 4 - NFC-e em operação com entrega a domicílio;
 9 - Operação não presencial, outros.
 (campo novo) [23-12-13]
*/
      v_linha := '<indPres>' || '9' || '</indPres>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<cMunFg/>
*/
      v_linha := '<cMunFG>' || cd_firmas_utl.uf(g_rg_emi.firma) || '</cMunFG>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<tpImp/>
*/
      -- tipo da impressao
      select substr(valor,
                    1,
                    1)
        into v_tipo_imp
        from sc_param
       where codigo = 'TPIMP-' || g_rg_emi.empresa; 
       
      v_linha := '<tpImp>' || v_tipo_imp || '</tpImp>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<tpEmis/>
*/
/*
<xs:documentation>Forma de emissão da NF-e
1 - Normal;
2 - Contingência FS
3 - Contingência SCAN
4 - Contingência DPEC
5 - Contingência FSDA
6 - Contingência SVC - AN
7 - Contingência SVC - RS
9 - Contingência off-line NFC-e</xs:documentation>
*/
      v_linha := '<tpEmis>'||g_rg_nf.forma_emissao||'</tpEmis>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<tpAmb/>
*/
      v_linha := '<tpAmb>' || pp_amb || '</tpAmb>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<xJust/>
*/
/*Justificativa de entrada em contingência - Obs: Campo obrigatório apenas quando emissão em contingência*/
-- verificar

/*
<dhCont/>
*/
/*Data e Hora da entrada em Contingência - Formato UTC “AAAA-MM-DDThh:mm:ss*/
-- verificar

/*
<finNFe/>
*/
/*
nformar o código da finalidade de emissão da NF-e:
1 - NF-e normal;
2 - NF-e complementar;
3 - NF-e de ajuste;
4 - Devolução(novo domínio) [23-12-13]
*/
      v_linha := '<finNFe>' || g_rg_nf.finalidade_nfe || '</finNFe>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

/*
<EmailArquivos/>
*/
-- verificar

--**********************************************************


      -- nf origem

      if g_rg_opr.nf_origem = 'S' or
         g_rg_opr.rm_origem = 'S' then
         
         select count(n.id)
           into v_conta_ref
           from ft_itens_nf n
          where n.id_ft_nota = pp_id
            and n.doc_origem is not null;

         if nvl(v_conta_ref,
                0) > 0 then
            v_finalid := '2';
         end if;
      end if;
            
      v_finalid := g_rg_nf.finalidade_nfe;

      if v_finalid = '2' then
         --v_linha := '<refNFe>';
         --v_ordem := v_ordem + 1;
         --insert into t_nfe values( v_ordem, v_linha );

         -- v_linha := '<refNF>';
         -- v_ordem := v_ordem + 1;
         -- insert into t_nfe values( v_ordem, v_linha );
         v_cab_ref_nf  := 0;
         v_cab_ref_nfe := 0;
         for ite in cr_ir(pp_id) loop
            begin
               select uf_nota
                     ,to_char(dt_emissao,
                              'rrmm')
                     ,cod_fornec
                     ,replace(n.chave_nfe,
                              ' ',
                              '') chave
                     ,tipo_doc
                 into v_uf_ori
                     ,v_dt_ori
                     ,v_firma_ori
                     ,v_chave_nfe
                     ,v_tipo_nf
                 from ce_notas n
                where empresa = g_rg_nf.empresa
                  and filial = ite.fil_origem
                  and cod_fornec = g_rg_nf.firma
                  and num_nota = ite.doc_origem
                  and sr_nota = ite.ser_origem
                  and parte = 0;
            exception
               when no_data_found then
                  select ent_uf
                        ,to_char(dt_emissao,
                                 'rrmm')
                        ,replace(n.chave_nfe,
                                 ' ',
                                 '') chave
                        ,decode(n.chave_nfe,
                                null,
                                3,
                                55) tipo_doc
                    into v_uf_ori
                        ,v_dt_ori
                        ,v_chave_nfe
                        ,v_tipo_nf
                    from ft_notas n
                   where empresa = g_rg_nf.empresa
                     and filial = ite.fil_origem
                     and num_nota = ite.doc_origem
                     and sr_nota = ite.ser_origem
                     and parte = 0;
                  select firma
                    into v_firma_ori
                    from cd_firmas
                   where empresa = g_rg_nf.empresa
                     and filial = g_rg_nf.filial;
            end;
            if v_tipo_nf = 55 or
               v_chave_nfe is not null then

               v_linha := '<refNFe>' || v_chave_nfe || '</refNFe>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

            else
               if v_cab_ref_nf = 0 then
                  v_cab_ref_nf := 1;
                  v_linha      := '<refNF>';
                  v_ordem      := v_ordem + 1;
                  insert into t_nfe
                  values
                     (v_ordem
                     ,v_linha);
               end if;

               select cd_ibge
                 into v_uf_ibge_ori
                 from cd_uf
                where uf = v_uf_ori
                  and pais = g_rg_emi.pais;

               select natureza
                     ,cgc_cpf
                 into v_natureza_ori
                     ,v_cgc_cpf_ori
                 from cd_firmas
                where firma = v_firma_ori;

               v_linha := '<cUF>' || v_uf_ibge_ori || '</cUF>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<AAMM>' || v_dt_ori || '</AAMM>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               if v_natureza_ori = 'J' then
                  v_linha := '<CNPJ>' || replace(replace(replace(replace(v_cgc_cpf_ori,
                                                                         '-',
                                                                         ''),
                                                                 '.',
                                                                 ''),
                                                         '-',
                                                         ''),
                                                 '/',
                                                 '') || '</CNPJ>';
               else
                  v_linha := '<CPF>' || replace(replace(replace(replace(v_cgc_cpf_ori,
                                                                        '-',
                                                                        ''),
                                                                '.',
                                                                ''),
                                                        '-',
                                                        ''),
                                                '/',
                                                '') || '</CPF>';
               end if;
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<mod>' || '01' || '</mod>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<serie>' || ite.ser_origem || '</serie>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);

               v_linha := '<nNF>' || ite.doc_origem || '</nNF>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            end if;
         end loop;

         if v_cab_ref_nf > 0 then
            v_linha := '</refNF>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         end if;

      end if;





      v_linha := '<cDV>' || cd_nfe_utl.modulo11(v_chave) || '</cDV>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);




      

      --| <procEmi>3</procEmi>
      /*
      Identificador do processo de emissão da NF-e:
      0 - emissão de NF-e com aplicativo do contribuinte;
      1 - emissão de NF-e avulsa pelo Fisco;
      2 - emissão de NF-e avulsa, pelo contribuinte com seu certificado digital, através do site do Fisco;
      3 - emissão NF-e pelo contribuinte com aplicativo fornecido pelo Fisco
      */
      /*
      v_linha := '<procEmi>0</procEmi>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      */
      /*
      --|<verProc>3.0</verProc>
      v_linha := '<verProc>' || v_verproc || '</verProc>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      */
      --|nfe referenciada
      v_ordem := v_ordem + 1;
      v_ref   := 0;

      for rgi in cr_i(pp_id ) loop

         if v_ref = 0 then
            v_linha := '<NFref>';
         end if;

         v_nf_ref := null;

         open cr_ref(rgi.seq_origem);
         fetch cr_ref
            into v_nf_ref;
         close cr_ref;
         if v_nf_ref is not null then
            v_linha := v_linha || chr(10) || '<refNFe>' || v_nf_ref ||
                       '</refNFe>';
            v_ref   := 1;
         end if;
         --raise_application_error(-20101,v_nf_ref);
      end loop;
      if v_ref > 0 then
         v_linha := v_linha || chr(10) || '</NFref>';
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;

      --|</ide>
      v_linha := '</ide>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

    end;
   --------------------------------------------------------------------------------
   procedure gera_xml_020_emit  (pp_emp ft_notas.empresa%type
                             ,pp_fil ft_notas.filial%type
                             ,pp_nro ft_notas.num_nota%type
                             ,pp_ser ft_notas.sr_nota%type
                             ,pp_id  ft_notas.id%type
                             ,pp_amb char)

    is

    v_cPais_emit             cd_paises.cod_siscomex%type;
    v_xPais_emit             cd_paises.nome%type;   
    v_mun_emi                cd_cidades.ibge%type;
    v_cid_emi                cd_cidades.cidade%type;   
        
    begin
/*
<emit>
*/      
      v_linha := '<emit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);    
           
/*      
<CNPJ_emit/>
*/
      if g_rg_emi.natureza = 'J' then
         v_linha := '<CNPJ_emit>' || replace(replace(replace(replace(g_rg_emi.cgc_cpf,
                                                                '-',
                                                                ''),
                                                        '.',
                                                        ''),
                                                '-',
                                                ''),
                                        '/',
                                        '') || '</CNPJ_emit>';
      else
         v_linha := '<CPF_emit>' || replace(replace(replace(replace(g_rg_emi.cgc_cpf,
                                                               '-',
                                                               ''),
                                                       '.',
                                                       ''),
                                               '-',
                                               ''),
                                       '/',
                                       '') || '</CPF_emit>';
      end if;
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

/*
<xNome/>
*/
      v_linha := '<xNome>' || g_rg_emi.nome || '</xNome>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);


/*
<xFant/>
*/
      v_linha := '<xFant>' || g_rg_emi.reduzido || '</xFant>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<IM/>
*/
      v_linha := '<IM>' || g_rg_emi.imun || '</IM>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

/*
<CNAE/>
*/
      v_linha := '<CNAE>' || g_cnae || '</CNAE>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

/*
<IE/>
*/
      v_linha := '<IE>' || replace(replace(replace(g_rg_emi.iest,
                                                   '.',
                                                   ''),
                                           '-',
                                           ''),
                                   '/',
                                   '') || '</IE>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

/*
<IEST/>
*/
/*
<CRT/>
*/
      v_linha := '<CRT>' || g_crt || '</CRT>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<enderEmit>
*/
      v_linha := '<enderEmit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<xLgr/>
*/
      v_linha := '<xLgr>' || g_rg_emi.endereco || '</xLgr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<nro/>
*/
      v_linha := '<nro>' || nvl(g_rg_emi.numero,
                                '0') || '</nro>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<xCpl/>
*/
      if ltrim(rtrim(g_rg_emi.complemento)) is not null then
         v_linha := '<xCpl>' || ltrim(rtrim(g_rg_emi.complemento)) || '</xCpl>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;

/*
<xBairro/>
*/
      if g_rg_emi.bairro is not null then
         v_linha := '<xBairro>' || g_rg_emi.bairro || '</xBairro>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;

/*
<cMun/>
*/
      -- cidade do emitente
      select ibge
            ,cidade
        into v_mun_emi
            ,v_cid_emi
        from cd_cidades
       where cod_cidade = g_rg_emi.cod_cidade;      

      v_linha := '<cMun>' || v_mun_emi || '</cMun>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<xMun/>
*/
      v_linha := '<xMun>' || v_cid_emi || '</xMun>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<UF/>
*/
      -- uf conforme ibge
      select a.cd_ibge ibge
        into g_uf_ibge
        from cd_uf a
       where uf = g_rg_emi.uf
         and pais = g_rg_emi.pais;    

      v_linha := '<UF>' || g_rg_emi.uf || '</UF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

/*
<CEP/>
*/
      v_linha := '<CEP>' || replace(replace(g_rg_emi.cep,
                                            '-',
                                            ''),
                                    '.',
                                    '') || '</CEP>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<cPais/>
*/
      -- pais emitente
      select a.cod_siscomex pais_bacen
            ,nome
        into v_cPais_emit --cPais
            ,v_xPais_emit --xPais
        from cd_paises a
       where pais = g_rg_emi.pais;
       
      v_linha := '<cPais>' || v_cPais_emit || '</cPais>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<xPais/>
*/
      v_linha := '<xPais>' || v_xPais_emit || '</xPais>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<fone/>
*/
      v_linha := '<fone>' || cd_nfe_utl.fone(g_rg_emi.firma) || '</fone>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<fax/>
*/
/*
<Email/>
*/
      v_linha := '<Email>' || cd_firmas_utl.email_nfe(g_rg_emi.firma) || '</Email>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
</enderEmit>      
*/               
      v_linha := '</enderEmit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
</emit>
*/
      v_linha := '</emit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);                
    end;    
   --------------------------------------------------------------------------------
   procedure gera_xml_030_dest  (pp_emp ft_notas.empresa%type
                             ,pp_fil ft_notas.filial%type
                             ,pp_nro ft_notas.num_nota%type
                             ,pp_ser ft_notas.sr_nota%type
                             ,pp_id  ft_notas.id%type
                             ,pp_amb char)

    is
    begin
/*      
<dest>
*/
      v_linha := '<dest>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<CNPJ_dest/>
*/
      if g_rg_des.natureza = 'J' then
         v_linha := '<CNPJ_dest>' || replace(replace(replace(replace(g_rg_des.cgc_cpf,
                                                                '-',
                                                                ''),
                                                        '.',
                                                        ''),
                                                '-',
                                                ''),
                                        '/',
                                        '') || '</CNPJ_dest>';
      else
         v_linha := '<CPF_dest>' || replace(replace(replace(replace(g_rg_des.cgc_cpf,
                                                               '-',
                                                               ''),
                                                       '.',
                                                       ''),
                                               '-',
                                               ''),
                                       '/',
                                       '') || '</CPF_dest>';
      end if;
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<xNome_dest/>
*/
      v_linha := '<xNome_dest>' || g_rg_des.nome || '</xNome_dest>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
/*
<IE_dest/>
*/

/*
<ISUF/>
<indIEDest/>
<IM_dest/>
<enderDest>
<nro_dest/>
<xCpl_dest/>
<xBairro_dest/>
<xEmail_dest/>
<xLgr_dest/>
<xPais_dest/>
<cMun_dest/>
<xMun_dest/>
<UF_dest/>
<CEP_dest/>
<cPais_dest/>
<fone_dest/>
</enderDest>
      v_linha := '<enderDest>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
</dest>
*/      


      v_linha := '<xLgr>' || g_rg_des.endereco || '</xLgr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<nro>' || nvl(g_rg_des.numero,
                                0) || '</nro>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      if ltrim(rtrim(g_rg_des.complemento)) is not null then
         v_linha := '<xCpl>' || ltrim(rtrim(g_rg_des.complemento)) || '</xCpl>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;

      if g_rg_des.bairro is not null then
         v_linha := '<xBairro>' || g_rg_des.bairro || '</xBairro>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;

      v_linha := '<cMun>' || v_mun_des || '</cMun>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<xMun>' || v_cid_des || '</xMun>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<UF>' || g_rg_nf.ent_uf || '</UF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<CEP>' || replace(replace(g_rg_nf.ent_cep,
                                            '-',
                                            ''),
                                    '.',
                                    '') || '</CEP>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<cPais>' || v_pai_des || '</cPais>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<xPais>' || v_pais_des || '</xPais>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '<fone>' || cd_nfe_utl.fone(g_rg_nf.firma) || '</fone>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '</enderDest>';
      v_ordem := v_ordem + 1;

      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      --| INSCR ESTADUAL DESTINATARIO
      if g_rg_des.iest is null or
         upper(g_rg_des.iest) = upper('ISENTO') or
         upper(g_rg_des.iest) = upper('ISENTA') then
         v_linha := '<indIEDest>9</indIEDest>';
      else
        -- indIEDest
        --1 (Contribuinte de ICMS),
        --2 (Contribuinte Isento de Inscrição)
        v_linha := '<indIEDest>'||1||'</indIEDest>';
        v_ordem := v_ordem + 1;
        insert into t_nfe
        values
           (v_ordem
           ,v_linha);

         if g_rg_des.natureza = 'J' then


            v_linha := '<IE>' || replace(replace(replace(nvl(g_rg_des.iest,
                                                             g_rg_des.ipro),
                                                         '.',
                                                         ''),
                                                 '-',
                                                 ''),
                                         '/',
                                         '') || '</IE>';
         else
            v_linha := '<IE>' || replace(replace(replace(nvl(g_rg_des.ipro,
                                                             g_rg_des.iest),
                                                         '.',
                                                         ''),
                                                 '-',
                                                 ''),
                                         '/',
                                         '') || '</IE>';
         end if;
      end if;

      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

      v_linha := '</dest>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
    end; 
   --------------------------------------------------------------------------------
   procedure gera_xml_040_retirada  (pp_emp ft_notas.empresa%type
                                   ,pp_fil ft_notas.filial%type
                                   ,pp_nro ft_notas.num_nota%type
                                   ,pp_ser ft_notas.sr_nota%type
                                   ,pp_id  ft_notas.id%type
                                   ,pp_amb char)

    is
    begin
/*      
<retirada>
<CNPJ_ret/>
<xLgr_ret/>
<nro_ret/>
<xCpl_ret/>
<xBairro_ret/>
<xMun_ret/>
<cMun_ret/>
<UF_ret/>
</retirada>
*/
    null;
    end;    
   --------------------------------------------------------------------------------
   procedure gera_xml_050_entrega  (pp_emp ft_notas.empresa%type
                                   ,pp_fil ft_notas.filial%type
                                   ,pp_nro ft_notas.num_nota%type
                                   ,pp_ser ft_notas.sr_nota%type
                                   ,pp_id  ft_notas.id%type
                                   ,pp_amb char)

    is
    begin
/*
<entrega>
*/
      v_linha := '<entrega>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

/*
<CNPJ_entr/>
*/
      v_linha := '<CNPJ_entr>'|| replace(replace(replace(g_rg_nf.cnpj_cpf,'.',''),'/',''),'-')||'</CNPJ_entr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
         
/*
<xLgr_entr/>
*/
      v_linha := '<xLgr_entr>'|| g_rg_nf.ent_ender||'</xLgr_entr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
         
/*
<nro_entr/>
*/
      v_linha := '<nro_entr>'|| g_rg_nf.ent_numero||'</nro_entr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
         
/*
<xCpl_entr/>
*/
      v_linha := '<xCpl_entr>'|| g_rg_nf.ent_compl||'</xCpl_entr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
         
/*
<xBairro_entr/>
*/
      v_linha := '<xBairro_entr>'|| g_rg_nf.ent_bairro||'</xBairro_entr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
         
/*
<cMun_entr/>
*/
      v_linha := '<cMun_entr>'|| cd_firmas_utl.cidade_ibge(g_rg_nf.ent_cidade)||'</cMun_entr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);

/*
<xMun_entr/>
*/
      v_linha := '<xMun_entr>'|| cd_firmas_utl.cidade(g_rg_nf.ent_cidade)||'</xMun_entr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
         
/*
<UF_entr/>
*/
      v_linha := '<UF_entr>'|| g_rg_nf.ent_uf||'</UF_entr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
         
/*
</entrega>
*/
      v_linha := '</entrega>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
    end;  
   --------------------------------------------------------------------------------
   procedure gera_xml_060_autxml  (pp_emp ft_notas.empresa%type
                                   ,pp_fil ft_notas.filial%type
                                   ,pp_nro ft_notas.num_nota%type
                                   ,pp_ser ft_notas.sr_nota%type
                                   ,pp_id  ft_notas.id%type
                                   ,pp_amb char)

    is
    begin
/*      
<autXML>
<autXMLItem/>
</autXML>
*/      
      null;
    end;  
   --------------------------------------------------------------------------------
   procedure gera_xml_070_det  (pp_emp ft_notas.empresa%type
                              ,pp_fil ft_notas.filial%type
                              ,pp_nro ft_notas.num_nota%type
                              ,pp_ser ft_notas.sr_nota%type
                              ,pp_id  ft_notas.id%type
                              ,pp_amb char)
    is
    
    v_qtd_itens number;
    v_item number(4); 
    begin
      --|Produto
         
      select count(a.id)
        into v_qtd_itens
        from ft_itens_nf a
            ,ft_notas    b
       where b.empresa = pp_emp
         and b.filial = pp_fil
         and b.num_nota = pp_nro
         and b.sr_nota = pp_ser
         and b.parte = 0
         and a.id_ft_nota = b.id;
   
      v_item := 0;

      if rg_opr.complemento = 'N' then
      
         for rgi in cr_i loop
         
            if nvl(rg_nf.vl_frete,
                   0) > 0 then
               vfrete_item := rg_nf.vl_frete / v_qtd_itens;
            else
               vfrete_item := 0;
            end if;
         
            vfrete_rateado := vfrete_rateado + vfrete_item;
         
            v_item := v_item + 1;
         
            if nvl(rg_nf.vl_frete,
                   0) > 0 then
               if v_item = v_qtd_itens then
                  if vfrete_rateado > rg_nf.vl_frete then
                     vfrete_item := vfrete_item -
                                    (vfrete_rateado - rg_nf.vl_frete);
                  elsif vfrete_rateado < rg_nf.vl_frete then
                     vfrete_item := vfrete_item +
                                    (rg_nf.vl_frete - vfrete_rateado);
                  end if;
               end if;
            end if;
/*      
<det>
*/
            v_linha := '<det nItem="' || to_char(v_item) || '">';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
           
  /*
  <prod>...</prod>
  <imposto>...</imposto>
  <impostoDevol>...</impostoDevol>
  */
  /*
  <prod>
  */           
            v_linha := '<prod>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            v_linha := '<cProd>' || rgi.produto || '</cProd>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            v_linha := '<cEAN/>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            v_linha   := '<xProd>' || ltrim(rtrim(substr(lib_util.fnc_trata_string(rgi.descricao),
                                                         1,
                                                         100))) || '</xProd>';
            v_detalhe := ltrim(rtrim(substr(lib_util.fnc_trata_string(rgi.descricao),
                                            101)));
         
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            begin
               if rgi.ncm is null then
                  select replace(replace(f.cod_nbm,
                                         '.',
                                         ''),
                                 '-',
                                 '')
                    into v_nbm
                    from ce_produtos p
                        ,ft_clafis   f
                   where f.cod_clafis = p.cod_clafis
                     and p.empresa = rgi.empresa
                     and p.produto = rgi.produto;
               else
                  v_nbm := replace(replace(rgi.ncm,
                                           '.',
                                           ''),
                                   '-',
                                   '');
               end if;
            exception
               when others then
                  v_nbm := null;
            end;
            if v_nbm is not null then
               v_linha := '<NCM>' || trim(v_nbm) || '</NCM>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            end if;
         
            v_linha := '<CFOP>' || substr(rgi.cod_cfo,
                                          1,
                                          1) ||
                       substr(rgi.cod_cfo,
                              3,
                              3) || '</CFOP>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            select sigla into v_sigla from ce_unid where unidade = rgi.uni_ven;
            --    v_linha := '<uCom>' || rgi.uni_ven || '</uCom>';
            v_linha := '<uCom>' || nvl(v_sigla,
                                       rgi.uni_ven) || '</uCom>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            v_linha := '<qCom>' || trim(replace(to_char(rgi.qtd_val,
                                                        '9999999999990D0000'),
                                                ',',
                                                '.')) || '</qCom>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            v_linha := '<vUnCom>' || trim(replace(to_char(rgi.pruni_sst,
                                                          '9999999999990D00000000'),
                                                  ',',
                                                  '.')) || '</vUnCom>';
         
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            v_linha := '<vProd>' ||
                       trim(replace(to_char(rgi.pruni_sst * rgi.qtd_val,
                                            '9999999999990D00'),
                                    ',',
                                    '.')) || '</vProd>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            v_linha := '<cEANTrib/>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            select sigla into v_sigla from ce_unid where unidade = rgi.uni_val;
            --    v_linha := '<uTrib>' || rgi.uni_val || '</uTrib>';
            v_linha := '<uTrib>' || nvl(v_sigla,
                                        rgi.uni_val) || '</uTrib>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            v_linha := '<qTrib>' || trim(replace(to_char(rgi.qtd_val,
                                                         '9999999999990D0000'),
                                                 ',',
                                                 '.')) || '</qTrib>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            v_linha := '<vUnTrib>' || trim(replace(to_char(rgi.pruni_sst,
                                                           '9999999999990D00000000'),
                                                   ',',
                                                   '.')) || '</vUnTrib>';
         
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);

            --| desconto produto             
            if nvl(rgi.vl_desconto,0) > 0 then

                v_linha := '<vDesc>' || trim(replace(to_char(rgi.vl_desconto,
                                                               '9999999999990D00000000'),
                                                       ',',
                                                       '.')) || '</vDesc>';
             
                v_ordem := v_ordem + 1;
                insert into t_nfe
                values
                   (v_ordem
                   ,v_linha);
                
            end if;
            
            --| Outras despesas            
            if nvl(rgi.vl_outras,0) > 0 then

                v_linha := '<vOutro>' || trim(replace(to_char(rgi.vl_outras,
                                                               '9999999999990D00000000'),
                                                       ',',
                                                       '.')) || '</vOutro>';
             
                v_ordem := v_ordem + 1;
                insert into t_nfe
                values
                   (v_ordem
                   ,v_linha);
                
            end if;
                        
            --| frete produto   
            if vfrete_item > 0 then
               v_linha := '<vFrete>' || trim(replace(to_char(vfrete_item,
                                                             '9999999999990D00'),
                                                     ',',
                                                     '.')) || '</vFrete>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            end if;
         
            if rgi.valor_unit = 0 then
               v_indtot := '0';
            else
               v_indtot := '1';
            end if;
            v_linha := '<indTot>' || v_indtot || '</indTot>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
        

         
/*
</det>
*/
      v_linha := '</det>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
    end;   
    
   --------------------------------------------------------------------------------
   procedure gera_xml_080_total  (pp_emp ft_notas.empresa%type
                                ,pp_fil ft_notas.filial%type
                                ,pp_nro ft_notas.num_nota%type
                                ,pp_ser ft_notas.sr_nota%type
                                ,pp_id  ft_notas.id%type
                                ,pp_amb char)

    is
    begin
      null;
    end;  
   --------------------------------------------------------------------------------
   procedure gera_xml_090_transp  (pp_emp ft_notas.empresa%type
                                 ,pp_fil ft_notas.filial%type
                                 ,pp_nro ft_notas.num_nota%type
                                 ,pp_ser ft_notas.sr_nota%type
                                 ,pp_id  ft_notas.id%type
                                 ,pp_amb char)

    is
    begin
      null;
    end;  
   --------------------------------------------------------------------------------
   procedure gera_xml_100_cobr  (pp_emp ft_notas.empresa%type
                                   ,pp_fil ft_notas.filial%type
                                   ,pp_nro ft_notas.num_nota%type
                                   ,pp_ser ft_notas.sr_nota%type
                                   ,pp_id  ft_notas.id%type
                                   ,pp_amb char)

    is
    begin
      null;
    end;   
   --------------------------------------------------------------------------------
   procedure gera_xml_110_pag  (pp_emp ft_notas.empresa%type
                                   ,pp_fil ft_notas.filial%type
                                   ,pp_nro ft_notas.num_nota%type
                                   ,pp_ser ft_notas.sr_nota%type
                                   ,pp_id  ft_notas.id%type
                                   ,pp_amb char)

    is
    begin
      null;
    end; 
   --------------------------------------------------------------------------------
   procedure gera_xml_120_infadic  (pp_emp ft_notas.empresa%type
                                   ,pp_fil ft_notas.filial%type
                                   ,pp_nro ft_notas.num_nota%type
                                   ,pp_ser ft_notas.sr_nota%type
                                   ,pp_id  ft_notas.id%type
                                   ,pp_amb char)

    is
    begin
      null;
    end; 
   --------------------------------------------------------------------------------
   procedure gera_xml_130_infsuplem  (pp_emp ft_notas.empresa%type
                                   ,pp_fil ft_notas.filial%type
                                   ,pp_nro ft_notas.num_nota%type
                                   ,pp_ser ft_notas.sr_nota%type
                                   ,pp_id  ft_notas.id%type
                                   ,pp_amb char)

    is
    begin
      null;
    end;       
   --------------------------------------------------------------------------------
   procedure gera_xml_140_exporta  (pp_emp ft_notas.empresa%type
                                   ,pp_fil ft_notas.filial%type
                                   ,pp_nro ft_notas.num_nota%type
                                   ,pp_ser ft_notas.sr_nota%type
                                   ,pp_id  ft_notas.id%type
                                   ,pp_amb char)

    is
    begin
      null;
    end;         
   --------------------------------------------------------------------------------
   procedure gera_xml_150_compra  (pp_emp ft_notas.empresa%type
                                   ,pp_fil ft_notas.filial%type
                                   ,pp_nro ft_notas.num_nota%type
                                   ,pp_ser ft_notas.sr_nota%type
                                   ,pp_id  ft_notas.id%type
                                   ,pp_amb char)

    is
    begin
      null;
    end;    
   --------------------------------------------------------------------------------
   procedure gera_xml_160_cana  (pp_emp ft_notas.empresa%type
                                   ,pp_fil ft_notas.filial%type
                                   ,pp_nro ft_notas.num_nota%type
                                   ,pp_ser ft_notas.sr_nota%type
                                   ,pp_id  ft_notas.id%type
                                   ,pp_amb char)

    is
    begin
      null;
    end;   
   --------------------------------------------------------------------------------
   procedure gera_xml_900_final  (pp_emp ft_notas.empresa%type
                                   ,pp_fil ft_notas.filial%type
                                   ,pp_nro ft_notas.num_nota%type
                                   ,pp_ser ft_notas.sr_nota%type
                                   ,pp_id  ft_notas.id%type
                                   ,pp_amb char)

    is
    begin
      null;
    end;                               
   --------------------------------------------------------------------------------
   procedure gera_xml  (pp_emp ft_notas.empresa%type
                   ,pp_fil ft_notas.filial%type
                   ,pp_nro ft_notas.num_nota%type
                   ,pp_ser ft_notas.sr_nota%type
                   ,pp_id  ft_notas.id%type
                   ,pp_amb char)

    is
    begin
        gera_xml_000_inicio  ( pp_emp 
                            ,pp_fil 
                            ,pp_nro 
                            ,pp_ser 
                            ,pp_id  
                            ,pp_amb );     
      commit;

   end;
end;
/
