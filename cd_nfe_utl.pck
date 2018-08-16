create or replace package cd_nfe_utl is

   --------------------------------------------------------------------------------
   --|| CD_nfe_UTL : Utilitarios para Nota Fiscal Eletronica
   --------------------------------------------------------------------------------

   --------------------------------------------------------------------------------
   function fone(cod in cd_firmas.firma%type) return cd_fones.fone%type;
   --------------------------------------------------------------------------------
   function fnc_enq_ipi_pref(p_tipo ft_enq_ipi.tipo%type)
      return ft_enq_ipi.codigo%type;
   --------------------------------------------------------------------------------
   function fnc_cest(p_ncm fs_cest.ncm_sh%type) return fs_cest.cd%type;
   --------------------------------------------------------------------------------
   procedure xml(pp_emp ft_notas.empresa%type
                ,pp_fil ft_notas.filial%type
                ,pp_nro ft_notas.num_nota%type
                ,pp_ser ft_notas.sr_nota%type
                ,pp_id  ft_notas.id%type
                ,pp_amb char);

   --------------------------------------------------------------------------------
   function modulo11(pc_chave varchar2) return char;

   --------------------------------------------------------------------------------
   function chave_nfe(p_firma         cd_firmas.firma%type
                     ,p_num_nota      ce_notas.num_nota%type
                     ,p_sr_nota       ce_notas.sr_nota%type
                     ,p_emis          date
                     ,p_tipo_nota     char
                     ,p_forma_emissao ft_num_nota.forma_emis_nfe%type)
      return varchar2;

end cd_nfe_utl;
/
create or replace package body cd_nfe_utl is

   --------------------------------------------------------------------------------
   --|| CD_nfe_UTL : Utilitarios para Nota Fiscal Eletronica
   --------------------------------------------------------------------------------
   procedure gerar_assinatura(p_nro number, p_chave_completa varchar2);
   
   /*
   return nro da linha gerada
   */
   function gera_cst_icms_isento(p_cst ft_itens_nf.cod_tribut%type, 
                                  p_orig ft_itens_nf.cod_origem%type ,
                                  p_nro number ) return number is
   v_cst_icms  varchar2(4);
   v_linha     varchar2(32000);
   v_nro_linha number;
   begin
            v_nro_linha := p_nro; 
            if p_cst IN (41,50) then
              v_cst_icms := '40';
            else
              v_cst_icms := substr(p_cst + 100,
                                           -2);
            end if;
                                  
            v_linha := '<ICMS' || v_cst_icms || '>';
            v_nro_linha := v_nro_linha + 1;
            insert into t_nfe
            values
               (v_nro_linha
               ,v_linha);
         
            v_linha := '<orig>' || nvl(p_orig,0) || '</orig>';
            v_nro_linha := v_nro_linha + 1;
            insert into t_nfe
            values
               (v_nro_linha
               ,v_linha);
         
            v_linha := '<CST>' || substr(p_cst + 100,
                                         -2) || '</CST>';
            v_nro_linha := v_nro_linha + 1;
            insert into t_nfe
            values
               (v_nro_linha
               ,v_linha);
               
            v_linha := '</ICMS' || v_cst_icms || '>';
            v_nro_linha := v_nro_linha + 1;
            insert into t_nfe
            values
               (v_nro_linha
               ,v_linha);
                              
       return v_nro_linha;
   end;
   
   /*
   return nro da linha gerada
   */   
   function gera_cst_icms_normal(p_id          number,
                                  p_vl_bicms    number,
                                  p_aliq_icms   number,
                                  p_vl_icms     number,
                                  p_cst         ft_itens_nf.cod_tribut%type, 
                                  p_orig        ft_itens_nf.cod_origem%type ,
                                  p_nro         number ) return number is
   v_cst_icms  varchar2(4);
   v_linha     varchar2(32000);
   v_nro_linha number;
   v_perc_red_base number;
   begin
            v_nro_linha := p_nro; 
            v_cst_icms := substr(p_cst + 100,
                                           -2);
                                  
            v_linha := '<ICMS' || v_cst_icms || '>';

                                                     
            v_nro_linha := v_nro_linha + 1;
            insert into t_nfe
            values
               (v_nro_linha
               ,v_linha);
         
            v_linha := '<orig>' || nvl(p_orig,0) || '</orig>';
            v_nro_linha := v_nro_linha + 1;
            insert into t_nfe
            values
               (v_nro_linha
               ,v_linha);
         
            v_linha := '<CST>' || substr(p_cst + 100,
                                         -2) || '</CST>';
            v_nro_linha := v_nro_linha + 1;
            insert into t_nfe
            values
               (v_nro_linha
               ,v_linha);     
               
         v_linha := '<modBC>0</modBC>';
         v_nro_linha := v_nro_linha + 1;
         insert into t_nfe
         values
            (v_nro_linha
            ,v_linha);
            
         if p_cst = 20 then
            begin
               v_perc_red_base := 0;
               select round(100 - a.vl_bicms / a.pruni_sst * 100,
                            2)
                 into v_perc_red_base
                 from ft_itens_nf a
                where a.num_nota = p_id; --rgi.id;
            exception
               when others then
                  null;
            end;
               
            --v_linha := '<pRedBC>' || trim( replace( to_char( rgi.pruni_sst, '9999999999990D00'),',','.' ) ) || '</pRedBC>';
            v_linha := '<pRedBC>' || trim(replace(to_char(v_perc_red_base,
                                                          '9999999999990D00'),
                                                  ',',
                                                  '.')) || '</pRedBC>';
            v_nro_linha := v_nro_linha + 1;
            insert into t_nfe
            values
               (v_nro_linha
               ,v_linha);
         end if;
            
         v_linha := '<vBC>' || trim(replace(to_char(nvl(p_vl_bicms,
                                                        0),
                                                    '9999999999990D00'),
                                            ',',
                                            '.')) || '</vBC>';
         v_nro_linha := v_nro_linha + 1;
         insert into t_nfe
         values
            (v_nro_linha
            ,v_linha);
            
         v_linha := '<pICMS>' || trim(replace(to_char(nvl(p_aliq_icms,
                                                          0),
                                                      '9999999999990D00'),
                                              ',',
                                              '.')) || '</pICMS>';
         v_nro_linha := v_nro_linha + 1;
         insert into t_nfe
         values
            (v_nro_linha
            ,v_linha);
            
         v_linha := '<vICMS>' || trim(replace(to_char(nvl(p_vl_icms,
                                                          0),
                                                      '9999999999990D00'),
                                              ',',
                                              '.')) || '</vICMS>';
         v_nro_linha := v_nro_linha + 1;
         insert into t_nfe
         values
            (v_nro_linha
            ,v_linha); 
            
          v_linha := '</ICMS' || v_cst_icms || '>';
          v_nro_linha := v_nro_linha + 1;
          insert into t_nfe
          values
             (v_nro_linha
             ,v_linha);
                             
       return v_nro_linha;                          
   end;
      
   --------------------------------------------------------------------------------
   function fone(cod in cd_firmas.firma%type) return cd_fones.fone%type
   /*
      || Retorna telefone
      */
    is
   
      v_campo cd_fones.fone%type;
      cursor cr is
         select trim(ddd) || trim(replace(replace(replace(replace(fone,
                                                                  '-',
                                                                  ''),
                                                          '/',
                                                          ''),
                                                  ' ',
                                                  ''),
                                          '.',
                                          ''))
           from cd_fones
          where firma = cod
          order by firma
                  ,indice;
   
   begin
   
      open cr;
      fetch cr
         into v_campo;
      if cr%notfound then
         v_campo := ' ';
      end if;
      close cr;
      return lpad(v_campo,
                  10,
                  '0');
   
   exception
   
      when others then
         return null;
      
   end;
   --------------------------------------------------------------------------------
   function fnc_enq_ipi_pref(p_tipo ft_enq_ipi.tipo%type)
      return ft_enq_ipi.codigo%type is
      cursor cr is
         select 1
               ,a.codigo
           from ft_enq_ipi a
          where a.tipo = 'N'
            and a.preferencial = 'S'
         union all
         select 2
               ,a.codigo
           from ft_enq_ipi a
          where a.tipo = 'N'
            and a.preferencial = 'N'
          order by 1;
      --|variaveis
      v_seq number(9);
      v_ret ft_enq_ipi.codigo%type;
   
   begin
      open cr;
      fetch cr
         into v_seq
             ,v_ret;
      close cr;
   
      return nvl(v_ret,
                 '999');
   
   end;
   --------------------------------------------------------------------------------
   function fnc_cest(p_ncm fs_cest.ncm_sh%type) return fs_cest.cd%type is
      cursor cr is
         select a.cd
           from fs_cest a
          where (substr(a.ncm_sh,
                        1,
                        instr(a.ncm_sh,
                              ',') - 1) = p_ncm or
                reverse(substr(reverse(a.ncm_sh),
                                1,
                                instr(reverse(a.ncm_sh),
                                      ',') - 1)) = p_ncm or a.ncm_sh = p_ncm or
                a.ncm_sh like '%,' || p_ncm || ',%');
      --|variaveis
      v_ret fs_cest.cd%type;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;
   --------------------------------------------------------------------------------
   procedure xml_20(pp_emp ft_notas.empresa%type
                   ,pp_fil ft_notas.filial%type
                   ,pp_nro ft_notas.num_nota%type
                   ,pp_ser ft_notas.sr_nota%type
                   ,pp_id  ft_notas.id%type
                   ,pp_amb char)
   
    is
   
      cursor cr_i is
         select a.*
           from ft_itens_nf a
               ,ft_notas    b
          where b.empresa = pp_emp
            and b.filial = pp_fil
            and b.num_nota = pp_nro
            and b.sr_nota = pp_ser
            and b.parte = 0
            and a.id_ft_nota = b.id;
   
      cursor cr_ir is
         select distinct a.fil_origem
                        ,a.doc_origem
                        ,a.ser_origem
           from ft_itens_nf a
               ,ft_notas    b
          where b.empresa = pp_emp
            and b.filial = pp_fil
            and b.num_nota = pp_nro
            and b.sr_nota = pp_ser
            and b.parte = 0
            and a.id_ft_nota = b.id
            and a.doc_origem is not null;
   
      cursor cr_p is
         select a.*
           from ft_parc_nf a
               ,ft_notas   b
          where b.empresa = pp_emp
            and b.filial = pp_fil
            and b.num_nota = pp_nro
            and b.sr_nota = pp_ser
            and b.parte = 0
            and a.id_ft_nota = b.id
          order by dt_vence;
   
      cursor cr_ptem is
         select 'S'
           from ft_parc_nf a
               ,ft_notas   b
          where b.empresa = pp_emp
            and b.filial = pp_fil
            and b.num_nota = pp_nro
            and b.sr_nota = pp_ser
            and b.parte = 0
            and a.id_ft_nota = b.id;
   
      cursor cr_m is
         select *
           from ft_msgs_nf
          where empresa = pp_emp
            and filial = pp_fil
            and num_nota = pp_nro
            and sr_nota = pp_ser
            and parte = 0;
   
      rg_nf      ft_notas%rowtype;
      rg_emi     cd_firmas%rowtype;
      rg_tra     cd_firmas%rowtype;
      v_uf_ibge  cd_uf.cd_ibge%type;
      v_linha    varchar2(4000);
      v_desc_cfo ft_cfo.descricao%type;
      v_avista   ft_condpag.a_vista%type;
      v_natureza ft_cfo.natureza%type;
      v_mun_emi  cd_cidades.ibge%type;
      v_cid_emi  cd_cidades.cidade%type;
      v_finalid  char(1);
      v_tipo_imp char(1);
      rg_opr     ft_oper%rowtype;
      v_pai_emi  cd_paises.cod_siscomex%type;
      v_pais_emi cd_paises.nome%type;
      rg_des     cd_firmas%rowtype;
      v_mun_des  cd_cidades.ibge%type;
      v_cid_des  cd_cidades.cidade%type;
      v_pai_des  cd_paises.cod_siscomex%type;
      v_pais_des cd_paises.nome%type;
      v_item     number(9);
      v_tp_frete char(1);
      v_chave    varchar2(43);
      v_cnf      varchar2(9);
      v_ordem    number(9) := 0;
      v_atl_crec ft_cfo.atl_crec%type;
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
   
      v_versao sc_param.valor%type;
      v_crt    fs_param.crt%type;
      v_cnae   fs_param.cnae%type;
      v_tpemis char(1);
      v_indtot char(1);
   
      vqtditens         number;
      vfrete_rateado    number(15,
                               2);
      vfrete_item       number(15,
                               2);
      v_verproc         varchar2(100);
      v_x509cert        varchar2(32000);
      v_signature_value varchar2(32000);
      v_chave_nfe       varchar2(200);
      v_tipo_nf         varchar2(30);
      v_finalidade_nfe  number(1);
      v_cab_ref_nf      number(1);
      v_cab_ref_nfe     number(1);
      v_conta_ref       number(4);
      v_perc_red_base   number;
      v_temparc         varchar2(1);
   begin
   
      -- versao atual do xml (2.0)
      select valor
        into v_versao
        from sc_param
       where codigo = 'VERSAO_XML_' || pp_emp;
   
      v_verproc := '2.2.19';
   
      -- limpa tabela temporaria
      delete t_nfe;
   
      -- codigo do regime tributario e cnae (2.0)
      select crt
            ,replace(replace(cnae,
                             '.',
                             ''),
                     '-',
                     '')
        into v_crt
            ,v_cnae
        from fs_param
       where empresa = pp_emp;
   
      -- limpa tabela temporaria
      delete t_nfe;
   
      -- dados da nota fiscal
      select *
        into rg_nf
        from ft_notas
       where empresa = pp_emp
         and filial = pp_fil
         and num_nota = pp_nro
         and sr_nota = pp_ser
         and parte = 0;
   
      -- tipo da emissao 
      v_tpemis := rg_nf.forma_emissao;
   
      -- emitente
      select *
        into rg_emi
        from cd_firmas
       where empresa = pp_emp
         and filial = pp_fil;
   
      -- uf conforme ibge
      select a.cd_ibge ibge
        into v_uf_ibge
        from cd_uf a
       where uf = rg_emi.uf
         and pais = rg_emi.pais;
   
      -- descricao do cfop
      select descricao
            ,atl_crec
        into v_desc_cfo
            ,v_atl_crec
        from ft_cfo
       where cod_cfo = rg_nf.cod_cfo;
   
      -- condicao de pagamento
      select decode(a_vista,
                    'S',
                    '0',
                    '1')
        into v_avista
        from ft_condpag
       where cod_condpag = rg_nf.cod_condpag;
   
      -- tipo documento fiscal
      select decode(natureza,
                    'E',
                    '0',
                    '1')
        into v_natureza
        from ft_cfo
       where cod_cfo = rg_nf.cod_cfo;
   
      -- cidade do emitente
      select ibge
            ,cidade
        into v_mun_emi
            ,v_cid_emi
        from cd_cidades
       where cod_cidade = rg_emi.cod_cidade;
   
      -- tipo da impressao
      select substr(valor,
                    1,
                    1)
        into v_tipo_imp
        from sc_param
       where codigo = 'TPIMP-' || rg_emi.empresa;
   
      -- operacao
      select *
        into rg_opr
        from ft_oper
       where empresa = rg_nf.empresa
         and cod_oper = rg_nf.cod_oper;
   
      -- nf origem
      v_finalid := '1';
      if rg_opr.nf_origem = 'S' or
         rg_opr.rm_origem = 'S' then
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
   
      -- pais
      select a.cod_siscomex pais_bacen
            ,nome
        into v_pai_emi
            ,v_pais_emi
        from cd_paises a
       where pais = rg_emi.pais;
   
      -- destinatario
      select * into rg_des from cd_firmas where firma = rg_nf.firma;
   
      -- cidade do destinatario
      select ibge
            ,cidade
        into v_mun_des
            ,v_cid_des
        from cd_cidades
       where cod_cidade = rg_nf.ent_cidade;
   
      -- pais destinatario
      select a.cod_siscomex pais_bacen
            ,nome
        into v_pai_des
            ,v_pais_des
        from cd_paises a
       where pais = rg_nf.ent_pais;
   
      -- frete
      if rg_nf.tp_frete = 'E' then
         v_tp_frete := '0';
      else
         v_tp_frete := '1';
      end if;
   
      -- transportadora
      if rg_nf.cod_transp is not null then
         select * into rg_tra from cd_firmas where firma = rg_nf.cod_transp;
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
      /*
      v_linha := '<nfeProc versao="2.00" xmlns="http://www.portalfiscal.inf.br/nfe">';
      v_ordem := nvl(v_ordem,0) + 1;
      insert into t_nfe values( v_ordem, v_linha );
        */
      v_linha := '<NFe xmlns="http://www.portalfiscal.inf.br/nfe">';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_chave := v_uf_ibge;
      v_chave := v_chave || to_char(rg_nf.dt_emissao,
                                    'RRMM');
      v_chave := v_chave || replace(replace(replace(replace(rg_emi.cgc_cpf,
                                                            '-',
                                                            ''),
                                                    '.',
                                                    ''),
                                            '-',
                                            ''),
                                    '/',
                                    '');
      v_chave := v_chave || '55';
      v_chave := v_chave || lpad(rg_nf.sr_nota,
                                 3,
                                 '0');
      v_chave := v_chave || lpad(rg_nf.num_nota,
                                 9,
                                 '0');
   
      if v_versao = '1.0' then
         v_chave := v_chave || v_cnf;
         v_linha := '<infNFe Id="NFe' || v_chave || modulo11(v_chave) ||
                    '" versao="1.10">';
      elsif v_versao = '2.0' then
         v_chave := v_chave || v_tpemis || substr(v_cnf,
                                                  -8);
         v_linha := '<infNFe Id="NFe' || v_chave || modulo11(v_chave) ||
                    '" versao="2.00">';
      end if;
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<ide>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<cUF>' || v_uf_ibge || '</cUF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if v_versao = '1.0' then
         v_linha := '<cNF>' || v_cnf || '</cNF>';
      elsif v_versao = '2.0' then
         v_linha := '<cNF>' || substr(v_cnf,
                                      -8) || '</cNF>';
      end if;
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<natOp>' || v_desc_cfo || '</natOp>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<indPag>' || v_avista || '</indPag>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<mod>55</mod>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<serie>' || trim(to_char(rg_nf.sr_nota)) || '</serie>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<nNF>' || pp_nro || '</nNF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<dEmi>' || to_char(rg_nf.dt_emissao,
                                     'rrrr-mm-dd') || '</dEmi>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if substr(rg_nf.cod_cfo,
                1,
                1) <> '7' then
         v_linha := '<dSaiEnt>' || to_char(rg_nf.dt_entsai,
                                           'rrrr-mm-dd') || '</dSaiEnt>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
         if v_versao = '2.0' then
            v_linha := '<hSaiEnt>' || to_char(rg_nf.dt_emissao,
                                              'hh:mi:ss') || '</hSaiEnt>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         end if;
      end if;
   
      v_linha := '<tpNF>' || v_natureza || '</tpNF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<cMunFG>' || v_mun_emi || '</cMunFG>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if v_finalid = '2' then
         --v_linha := '<refNFe>';
         --v_ordem := v_ordem + 1;
         --insert into t_nfe values( v_ordem, v_linha );
      
         -- v_linha := '<refNF>';
         -- v_ordem := v_ordem + 1;
         -- insert into t_nfe values( v_ordem, v_linha );
         v_cab_ref_nf  := 0;
         v_cab_ref_nfe := 0;
         for ite in cr_ir loop
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
                where empresa = rg_nf.empresa
                  and filial = ite.fil_origem
                  and cod_fornec = rg_nf.firma
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
                   where empresa = rg_nf.empresa
                     and filial = ite.fil_origem
                     and num_nota = ite.doc_origem
                     and sr_nota = ite.ser_origem
                     and parte = 0;
                  select firma
                    into v_firma_ori
                    from cd_firmas
                   where empresa = rg_nf.empresa
                     and filial = rg_nf.filial;
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
                  and pais = rg_emi.pais;
            
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
   
      v_linha := '<tpImp>' || v_tipo_imp || '</tpImp>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      -- tipo da emissao 
      v_tpemis := rg_nf.forma_emissao;
   
      v_linha := '<tpEmis>' || v_tpemis || '</tpEmis>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<cDV>' || modulo11(v_chave) || '</cDV>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|<tpAmb>1</tpAmb>
      v_linha := '<tpAmb>' || pp_amb || '</tpAmb>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|<finNFe>1</finNFe>   
      v_linha := '<finNFe>' || rg_nf.finalidade_nfe || '</finNFe>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --| <procEmi>3</procEmi>
      v_linha := '<procEmi>3</procEmi>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|<verProc></verProc>
      v_linha := '<verProc>' || v_verproc || '</verProc>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|</ide>
      v_linha := '</ide>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<emit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if rg_emi.natureza = 'J' then
         v_linha := '<CNPJ>' || replace(replace(replace(replace(rg_emi.cgc_cpf,
                                                                '-',
                                                                ''),
                                                        '.',
                                                        ''),
                                                '-',
                                                ''),
                                        '/',
                                        '') || '</CNPJ>';
      else
         v_linha := '<CPF>' || replace(replace(replace(replace(rg_emi.cgc_cpf,
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
   
      v_linha := '<xNome>' || rg_emi.nome || '</xNome>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<xFant>' || rg_emi.reduzido || '</xFant>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<enderEmit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<xLgr>' || rg_emi.endereco || '</xLgr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<nro>' || nvl(rg_emi.numero,
                                '0') || '</nro>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if ltrim(rtrim(rg_emi.complemento)) is not null then
         v_linha := '<xCpl>' || ltrim(rtrim(rg_emi.complemento)) || '</xCpl>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      if rg_emi.bairro is not null then
         v_linha := '<xBairro>' || rg_emi.bairro || '</xBairro>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      v_linha := '<cMun>' || v_mun_emi || '</cMun>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<xMun>' || v_cid_emi || '</xMun>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<UF>' || rg_emi.uf || '</UF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<CEP>' || replace(replace(rg_emi.cep,
                                            '-',
                                            ''),
                                    '.',
                                    '') || '</CEP>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<cPais>' || v_pai_emi || '</cPais>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<xPais>' || v_pais_emi || '</xPais>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<fone>' || cd_nfe_utl.fone(rg_emi.firma) || '</fone>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '</enderEmit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<IE>' || replace(replace(replace(rg_emi.iest,
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
   
      if v_versao = '2.0' then
         v_linha := '<IM>' || rg_emi.imun || '</IM>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      if v_versao = '2.0' then
         v_linha := '<CNAE>' || v_cnae || '</CNAE>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      if v_versao = '2.0' then
         v_linha := '<CRT>' || v_crt || '</CRT>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      v_linha := '</emit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<dest>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if rg_des.natureza = 'J' then
         v_linha := '<CNPJ>' || replace(replace(replace(replace(rg_des.cgc_cpf,
                                                                '-',
                                                                ''),
                                                        '.',
                                                        ''),
                                                '-',
                                                ''),
                                        '/',
                                        '') || '</CNPJ>';
      else
         v_linha := '<CPF>' || replace(replace(replace(replace(rg_des.cgc_cpf,
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
   
      v_linha := '<xNome>' || rg_des.nome || '</xNome>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<enderDest>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<xLgr>' || rg_des.endereco || '</xLgr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<nro>' || nvl(rg_des.numero,
                                0) || '</nro>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if ltrim(rtrim(rg_des.complemento)) is not null then
         v_linha := '<xCpl>' || ltrim(rtrim(rg_des.complemento)) || '</xCpl>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      if rg_des.bairro is not null then
         v_linha := '<xBairro>' || rg_des.bairro || '</xBairro>';
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
   
      v_linha := '<UF>' || rg_nf.ent_uf || '</UF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<CEP>' || replace(replace(rg_nf.ent_cep,
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
   
      v_linha := '<fone>' || cd_nfe_utl.fone(rg_nf.firma) || '</fone>';
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
   
      if rg_des.natureza = 'J' then
         v_linha := '<IE>' || replace(replace(replace(nvl(rg_des.iest,
                                                          rg_des.ipro),
                                                      '.',
                                                      ''),
                                              '-',
                                              ''),
                                      '/',
                                      '') || '</IE>';
      else
         v_linha := '<IE>' || replace(replace(replace(rg_des.ipro,
                                                      '.',
                                                      ''),
                                              '-',
                                              ''),
                                      '/',
                                      '') || '</IE>';
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
      
         for rgi in cr_i loop
         
            if nvl(rg_nf.vl_frete,
                   0) > 0 then
               vfrete_item := rg_nf.vl_frete / vqtditens;
            else
               vfrete_item := 0;
            end if;
         
            vfrete_rateado := vfrete_rateado + vfrete_item;
         
            v_item := v_item + 1;
         
            if nvl(rg_nf.vl_frete,
                   0) > 0 then
               if v_item = vqtditens then
                  if vfrete_rateado > rg_nf.vl_frete then
                     vfrete_item := vfrete_item -
                                    (vfrete_rateado - rg_nf.vl_frete);
                  elsif vfrete_rateado < rg_nf.vl_frete then
                     vfrete_item := vfrete_item +
                                    (rg_nf.vl_frete - vfrete_rateado);
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
         
            v_linha := '<cEAN />';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            v_linha   := '<xProd>' || ltrim(rtrim(substr(rgi.descricao,
                                                         1,
                                                         100))) || '</xProd>';
            v_detalhe := ltrim(rtrim(substr(rgi.descricao,
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
         
            select (ltrim(rtrim(sigla))) into v_sigla from ce_unid where unidade = rgi.uni_ven;
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
         
            if v_versao = '1.0' then
               v_linha := '<vUnCom>' || trim(replace(to_char(rgi.pruni_sst,
                                                             '9999999999990D0000'),
                                                     ',',
                                                     '.')) || '</vUnCom>';
            elsif v_versao = '2.0' then
               v_linha := '<vUnCom>' || trim(replace(to_char(rgi.pruni_sst,
                                                             '9999999999990D00000000'),
                                                     ',',
                                                     '.')) || '</vUnCom>';
            end if;
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
         
            if v_versao = '1.0' then
               v_linha := '<vUnTrib>' || trim(replace(to_char(rgi.pruni_sst,
                                                              '9999999999990D0000'),
                                                      ',',
                                                      '.')) || '</vUnTrib>';
            elsif v_versao = '2.0' then
               v_linha := '<vUnTrib>' || trim(replace(to_char(rgi.pruni_sst,
                                                              '9999999999990D00000000'),
                                                      ',',
                                                      '.')) || '</vUnTrib>';
            end if;
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            -- rateio do frete por item (2.0)
            if v_versao = '2.0' and
               vfrete_item > 0 then
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
         
            if v_versao = '2.0' then
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
            end if;
         
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
         
            if rgi.cod_tribut_ipi is not null then
               --in( 1, 2, 3, 4, 5, 51, 52, 53, 54, 55 ) then
            
               v_linha := '<cEnq>' || rgi.cod_tribut_ipi || '</cEnq>';
            else
               v_linha := '<cEnq>999</cEnq>';
            
            end if;
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            if rgi.cod_tribut_ipi not in (50) /*(1,
                                                                                                                                      2,
                                                                                                                                      3,
                                                                                                                                      4,
                                                                                                                                      5,
                                                                                                                                      51,
                                                                                                                                      52,
                                                                                                                                      53,
                                                                                                                                      54,
                                                                                                                                      55)*/
             then
            
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
            
            elsif rgi.cod_tribut_ipi in (50) then
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
         
            --v_detalhe := null;
            /*
            declare
              v_atestado    pp_lotes.atestado%type;
              v_lote        ft_itens_nf.lote%type;
              v_ano         ft_itens_nf.ano%type;
            
            begin
            
              if rgi.lote is not null then
                  select l.boletim, l.atestado, l.categoria, p.prof, p.unidade
                    into v_boletim, v_atestado , v_categoria, v_vc, v_unidade
                    from pp_lotes    l,
                       ce_produtos p
                   where p.empresa  = l.empresa
                     and p.produto  = l.produto
                     and l.empresa  = rgi.empresa
                     and l.filial   = rgi.fil_lote
                     and l.producao = rgi.producao
                     and l.produto  = rgi.produto
                     and l.lote     = rgi.lote
                     and l.ano      = rgi.ano;
                  v_detalhe := ltrim( 'Lote Nro: ' || rgi.lote || '/' || rgi.ano || ' - ' || v_categoria || '  - BA Nro: ' || rtrim( v_boletim ) || '  - TC Nro: ' || v_atestado|| '/' || rgi.ano || '  - Sacas: ' || to_char( rgi.qtd ) );
            
             elsif rgi.doc_origem is not null then
            
              begin
                select lote, ano
                into v_lote, v_ano
                from ft_itens_nf
                 where seq_item = rgi.seq_origem;
                if v_lote is not null then
                v_detalhe := 'Lote Nro: ' || v_lote || '/' || v_ano;
                else
                v_detalhe := '';
                end if;
              exception
                when others then
                null;
              end;
              end if;
            
            end;
                */
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
      
         for rgi in cr_i loop
         
            --  if nvl( rg_nf.vl_frete, 0 ) > 0 then
            --    vfrete_item := rg_nf.vl_frete / vqtditens;
            --  else
            vfrete_item    := 0;
            vfrete_rateado := 0;
            --  end if;
         
            v_item := v_item + 1;
         
            if nvl(rg_nf.vl_frete,
                   0) > 0 then
               if v_item = vqtditens then
                  if vfrete_rateado > rg_nf.vl_frete then
                     vfrete_item := vfrete_item -
                                    (vfrete_rateado - rg_nf.vl_frete);
                  elsif vfrete_rateado < rg_nf.vl_frete then
                     vfrete_item := vfrete_item +
                                    (rg_nf.vl_frete - vfrete_rateado);
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
         
            v_linha := '<cEAN />';
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
         
            if v_versao = '1.0' then
               v_linha := '<vUnCom>' || /*trim( replace( to_char( rgi.pruni_sst, '9999999999990D0000'    ),',','.' ) )*/
                          0 || '</vUnCom>';
            elsif v_versao = '2.0' then
               v_linha := '<vUnCom>' || /*trim( replace( to_char( rgi.pruni_sst, '9999999999990D00000000'),',','.' ) )*/
                          0 || '</vUnCom>';
            end if;
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
         
            v_linha := '<cEANTrib />';
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
         
            v_linha := '<qTrib>' || /*trim( replace( to_char( rgi.qtd_val, '9999999999990D0000'),',','.' ) )*/
                       0 || '</qTrib>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            if v_versao = '1.0' then
               v_linha := '<vUnTrib>' || /*trim( replace( to_char( rgi.pruni_sst, '9999999999990D0000'    ),',','.' ) )*/
                          0 || '</vUnTrib>';
            elsif v_versao = '2.0' then
               v_linha := '<vUnTrib>' || /*trim( replace( to_char( rgi.pruni_sst, '9999999999990D00000000'),',','.' ) )*/
                          0 || '</vUnTrib>';
            end if;
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            -- rateio do frete por item (2.0)
            if v_versao = '2.0' and
               vfrete_item > 0 then
               v_linha := '<vFrete>' || /*trim( replace( to_char( vfrete_item, '9999999999990D00'),',','.' ) )*/
                          0 || '</vFrete>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            end if;
         
            if v_versao = '2.0' then
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
            end if;
         
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
            
               v_linha := '<CST>' || /*substr( rgi.cod_tribut_ipi + 100, -2 )*/
                          52 || '</CST>';
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
            
               v_linha := '<CST>' || /*substr( rgi.cod_tribut_pis + 100, -2 )*/
                          0 || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            
               v_linha := '<vBC>' || /*trim( replace( to_char( nvl( rgi.vl_bpis, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</vBC>';
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
            
               v_linha := '<CST>' || /*substr( rgi.cod_tribut_pis + 100, -2 )*/
                          0 || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            
               v_linha := '<vQBCPROD>' || /* trim( replace( to_char( nvl( rgi.vl_bpis, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</vQBCPROD>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            
               v_linha := '<pVALIQPROD>' || /*trim( replace( to_char( nvl( rgi.aliq_pis, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</pVALIQPROD>';
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
            
               v_linha := '<CST>' || /*substr( rgi.cod_tribut_pis + 100, -2 )*/
                          '07' || '</CST>';
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
            
               v_linha := '<CST>' || /*substr( rgi.cod_tribut_pis + 100, -2 )*/
                          0 || '</CST>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            
               v_linha := '<vBC>' || /*trim( replace( to_char( nvl( rgi.vl_bpis, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</vBC>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            
               v_linha := '<vPIS>' || /*trim( replace( to_char( nvl( rgi.aliq_pis, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</vPIS>';
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
            
               v_linha := '<vAliqProd>' || /*trim( replace( to_char( nvl( rgi.aliq_pis, 0 ), '9999999999990D00'),',','.' ) )*/
                          0 || '</vAliqProd>';
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
         
            --v_detalhe := null;
            /*
             declare
               v_atestado    pp_lotes.atestado%type;
               v_lote        ft_itens_nf.lote%type;
               v_ano         ft_itens_nf.ano%type;
            
             begin
            
               if rgi.lote is not null then
               select l.boletim, l.atestado, l.categoria, p.prof, p.unidade
                 into v_boletim, v_atestado , v_categoria, v_vc, v_unidade
                 from pp_lotes    l,
                    ce_produtos p
                where p.empresa  = l.empresa
                  and p.produto  = l.produto
                  and l.empresa  = rgi.empresa
                  and l.filial   = rgi.fil_lote
                  and l.producao = rgi.producao
                  and l.produto  = rgi.produto
                  and l.lote     = rgi.lote
                  and l.ano      = rgi.ano;
               v_detalhe := ltrim( 'Lote Nro: ' || rgi.lote || '/' || rgi.ano || ' - ' || v_categoria || '  - BA Nro: ' || rtrim( v_boletim ) || '  - TC Nro: ' || v_atestado|| '/' || rgi.ano || '  - Sacas: ' || to_char( rgi.qtd ) );
               elsif rgi.doc_origem is not null then
               begin
                 select lote, ano
                 into v_lote, v_ano
                 from ft_itens_nf
                  where seq_item = rgi.seq_origem;
                 if v_lote is not null then
                 v_detalhe := 'Lote Nro: ' || v_lote || '/' || v_ano;
                 else
                 v_detalhe := '';
                 end if;
               exception
                 when others then
                 null;
               end;
               end if;
            
             end;
            */
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
      --| CARLOS FIM DO LOOP DO PRODUTO
   
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
   
      v_linha := '<vBC>' || trim(replace(to_char(nvl(rg_nf.vl_bicms,
                                                     0),
                                                 '9999999999990D00'),
                                         ',',
                                         '.')) || '</vBC>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vICMS>' || trim(replace(to_char(nvl(rg_nf.vl_icms,
                                                       0),
                                                   '9999999999990D00'),
                                           ',',
                                           '.')) || '</vICMS>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vBCST>' || trim(replace(to_char(nvl(rg_nf.vl_bicms_sub,
                                                       0),
                                                   '9999999999990D00'),
                                           ',',
                                           '.')) || '</vBCST>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vST>' || trim(replace(to_char(nvl(rg_nf.vl_icms_sub,
                                                     0),
                                                 '9999999999990D00'),
                                         ',',
                                         '.')) || '</vST>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      /*if rg_opr.complemento = 'N' then*/
      v_linha := '<vProd>' || trim(replace(to_char(nvl(rg_nf.vl_produtos,
                                                       0),
                                                   '9999999999990D00'),
                                           ',',
                                           '.')) || '</vProd>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*  else
        v_linha := '<vProd>' || 0 || '</vProd>';
        v_ordem := v_ordem + 1;
        insert into t_nfe values( v_ordem, v_linha );
      end if;*/
   
      v_linha := '<vFrete>' || trim(replace(to_char(nvl(rg_nf.vl_frete,
                                                        0),
                                                    '9999999999990D00'),
                                            ',',
                                            '.')) || '</vFrete>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vSeg>' || trim(replace(to_char(nvl(rg_nf.vl_seguro,
                                                      0),
                                                  '9999999999990D00'),
                                          ',',
                                          '.')) || '</vSeg>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vDesc>' || trim(replace(to_char(nvl(rg_nf.vl_desconto,
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
   
      v_linha := '<vIPI>' || trim(replace(to_char(nvl(rg_nf.vl_ipi,
                                                      0),
                                                  '9999999999990D00'),
                                          ',',
                                          '.')) || '</vIPI>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vPIS>' || trim(replace(to_char(nvl(rg_nf.vl_pis,
                                                      0),
                                                  '9999999999990D00'),
                                          ',',
                                          '.')) || '</vPIS>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vCOFINS>' || trim(replace(to_char(nvl(rg_nf.vl_cofins,
                                                         0),
                                                     '9999999999990D00'),
                                             ',',
                                             '.')) || '</vCOFINS>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vOutro>' || trim(replace(to_char(nvl(rg_nf.vl_outros,
                                                        0),
                                                    '9999999999990D00'),
                                            ',',
                                            '.')) || '</vOutro>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vNF>' || trim(replace(to_char(nvl(rg_nf.vl_total,
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
   
      if rg_nf.cod_transp is not null then
      
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
   
      if rg_nf.placa_veic is not null and
         rg_nf.placa_uf is not null then
         v_linha := '<veicTransp>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      
         v_linha := '<placa>' || upper(replace(replace(rg_nf.placa_veic,
                                                       '-',
                                                       ''),
                                               ' ',
                                               '')) || '</placa>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      
         v_linha := '<UF>' || rg_nf.placa_uf || '</UF>';
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
   
      v_linha := '<qVol>' || nvl(rg_nf.vol_qtd,
                                 1) || '</qVol>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if rg_nf.vol_especie is not null then
         v_linha := '<esp>' || rg_nf.vol_especie || '</esp>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      if rg_nf.vol_marca is not null then
         v_linha := '<marca>' || rg_nf.vol_marca || '</marca>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      if rg_nf.vol_numero is not null then
         v_linha := '<nVol>' || rg_nf.vol_numero || '</nVol>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      v_linha := '<pesoL>' || trim(replace(to_char(nvl(rg_nf.peso_liquido,
                                                       0),
                                                   '9999999999990D000'),
                                           ',',
                                           '.')) || '</pesoL>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<pesoB>' || trim(replace(to_char(nvl(rg_nf.peso_bruto,
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
   
      if v_atl_crec = 'S' then
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
      
         v_linha := '<nFat>' || rg_nf.num_nota || '</nFat>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      
         v_linha := '<vOrig>' || trim(replace(to_char(nvl(rg_nf.vl_total,
                                                          0),
                                                      '9999999999990D00'),
                                              ',',
                                              '.')) || '</vOrig>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      
         v_linha := '<vLiq>' || trim(replace(to_char(nvl(rg_nf.vl_total,
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
         for rgi in cr_p loop
         
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
      for rgi in cr_m loop
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
   
      --parte final do arquivo
      /*
      v_linha := '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">';
      v_ordem := v_ordem + 1;
      insert into t_nfe values (v_ordem ,v_linha);
      
      v_linha := '<SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>';
      v_ordem := v_ordem + 1;
      insert into t_nfe values (v_ordem ,v_linha);
      
      v_linha := '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>';
      v_ordem := v_ordem + 1;
      insert into t_nfe values (v_ordem ,v_linha);
      
      v_linha := '<Reference URI="#NFe35111208236786000152550010000005491070000030">';
      v_ordem := v_ordem + 1;
      insert into t_nfe values (v_ordem ,v_linha);
      
      v_linha := '<Transforms>';
      v_ordem := v_ordem + 1;
      insert into t_nfe values (v_ordem ,v_linha);
      
      v_linha := '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>';
      v_ordem := v_ordem + 1;
      insert into t_nfe values (v_ordem ,v_linha);
      
      v_linha := '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>';
      v_ordem := v_ordem + 1;
      insert into t_nfe values (v_ordem ,v_linha);
      
      v_linha := '</Transforms>';
      v_ordem := v_ordem + 1;
      insert into t_nfe values (v_ordem ,v_linha);
      
      v_linha := '<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>';
      v_ordem := v_ordem + 1;
      insert into t_nfe values (v_ordem ,v_linha);
      
      v_linha := '<DigestValue>pIh73IJTQ4z/9fFUNjHoKffvxsY=</DigestValue>';
      v_ordem := v_ordem + 1;
      insert into t_nfe values (v_ordem ,v_linha);
      
      v_linha := '</Reference>';
      v_ordem := v_ordem + 1;
      insert into t_nfe values (v_ordem ,v_linha);
      --/
      v_linha := '</SignedInfo>';
      v_ordem := v_ordem + 1;
      insert into t_nfe values (v_ordem ,v_linha);
      --/
      v_x509Cert := 'MIIGnDCCBYSgAwIBAgIQerxlNFZvKOjsFHvkfwFstjANBgkqhkiG9w0BAQUFADB4MQswCQYDVQQG'||
                    ' EwJCUjETMBEGA1UEChMKSUNQLUJyYXNpbDE2MDQGA1UECxMtU2VjcmV0YXJpYSBkYSBSZWNlaXRh'||
                    ' IEZlZGVyYWwgZG8gQnJhc2lsIC0gUkZCMRwwGgYDVQQDExNBQyBDZXJ0aXNpZ24gUkZCIEczMB4X'||
                    ' DTExMDgxNTAwMDAwMFoXDTEyMDgxMzIzNTk1OVowgfgxCzAJBgNVBAYTAkJSMQswCQYDVQQIEwJT'||
                    ' UDEUMBIGA1UEBxQLU0VSVEFPWklOSE8xEzARBgNVBAoUCklDUC1CcmFzaWwxNjA0BgNVBAsULVNl'||
                    ' Y3JldGFyaWEgZGEgUmVjZWl0YSBGZWRlcmFsIGRvIEJyYXNpbCAtIFJGQjEWMBQGA1UECxQNUkZC'||
                    ' IGUtQ05QSiBBMTEiMCAGA1UECxQZQXV0ZW50aWNhZG8gcG9yIEFSIE1hY3NlZzE9MDsGA1UEAxM0'||
                    ' U0VSTUFTQSBFUVVJUEFNRU5UT1MgSU5EVVNUUklBSVMgTFREQTowODIzNjc4NjAwMDE1MjCBnzAN'||
                    ' BgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAwgG4xbKfzNSZcXvJEZiKjq3gWHJJFrZj/yQ/ZlyMg40Q'||
                    ' dQabK59/Whog41W+14vzwB6SmrcbbljoHvEDBQW5AT4IxYNrCNR4I1UW1tPX+r1XQ+NwTZrtx9SV'||
                    ' 54Mlww7vTIjBLQNCZRd1wD+g3E/hNy4ocwc0uAwXEnbkNBAbvsECAwEAAaOCAyMwggMfMIG4BgNV'||
                    ' HREEgbAwga2gPQYFYEwBAwSgNAQyMTUwNjE5NDY1NTA5NDI4NzgzNDAwMDAwMDAwMDAwMDAwMDAw'||
                    ' MDM3ODE2NjUyU1NQU1CgJAYFYEwBAwKgGwQZR0lMQkVSVE8gREUgUEFVTEEgU0FOVE9ST6AZBgVg'||
                    ' TAEDA6AQBA4wODIzNjc4NjAwMDE1MqAXBgVgTAEDB6AOBAwwMDAwMDAwMDAwMDCBEm5mZUBzZXJt'||
                    ' YXNhLmNvbS5icjAJBgNVHRMEAjAAMB8GA1UdIwQYMBaAFPyAa9VN0fx42GxkL2FLOKeC8NydMA4G'||
                    ' A1UdDwEB/wQEAwIF4DCCARAGA1UdHwSCAQcwggEDMFegVaBThlFodHRwOi8vaWNwLWJyYXNpbC5j'||
                    ' ZXJ0aXNpZ24uY29tLmJyL3JlcG9zaXRvcmlvL2xjci9BQ0NlcnRpc2lnblJGQkczL0xhdGVzdENS'||
                    ' TC5jcmwwVqBUoFKGUGh0dHA6Ly9pY3AtYnJhc2lsLm91dHJhbGNyLmNvbS5ici9yZXBvc2l0b3Jp'||
                    ' by9sY3IvQUNDZXJ0aXNpZ25SRkJHMy9MYXRlc3RDUkwuY3JsMFCgTqBMhkpodHRwOi8vcmVwb3Np'||
                    ' dG9yaW8uaWNwYnJhc2lsLmdvdi5ici9sY3IvUkZCL0FDQ2VydGlzaWduUkZCRzMvTGF0ZXN0Q1JM'||
                    ' LmNybDBVBgNVHSAETjBMMEoGBmBMAQIBDDBAMD4GCCsGAQUFBwIBFjJodHRwOi8vaWNwLWJyYXNp'||
                    ' bC5jZXJ0aXNpZ24uY29tLmJyL3JlcG9zaXRvcmlvL2RwYzAdBgNVHSUEFjAUBggrBgEFBQcDAgYI'||
                    ' KwYBBQUHAwQwgZsGCCsGAQUFBwEBBIGOMIGLMF8GCCsGAQUFBzAChlNodHRwOi8vaWNwLWJyYXNp'||
                    ' bC5jZXJ0aXNpZ24uY29tLmJyL3JlcG9zaXRvcmlvL2NlcnRpZmljYWRvcy9BQ19DZXJ0aXNpZ25f'||
                    ' UkZCX0czLnA3YzAoBggrBgEFBQcwAYYcaHR0cDovL29jc3AuY2VydGlzaWduLmNvbS5icjANBgkq'||
                    ' hkiG9w0BAQUFAAOCAQEAEQmhyiMQZ8kUjvLuGt1YGCsVpq6WxD/r2Eo7fvb/h5EZke85F8dLD1tv'||
                    ' zFW8EjyoXCcjRetKXEjPAxanUgxl8I7ywUe4pnK4Xmnd6tIEQ2djTQPHxbV70DbFzsZaRqh1Uw7g'||
                    ' nMhMfKwSi7QMi9JjCIqBa+jdgEmHArqOc8+bTSG/t5qRgEmJMpphjnyVuVmvU6Mz+ZNpyDzNWL3S'||
                    ' F0C5QdpRZbVSfP/214SgcJqsdjpQEusLkNs6+za9DvdTkY92Sro9tXRbh7gFi2QzOXh538HLuJVV'||
                    ' IJ0A7hFK1z3A+U6EXmg3kQ5NKxVZ4N5SBINj03oCX8XDiSLwzeoAvkMTsA==';
      v_signature_value := 'oW4QFLlHYJVaCOnkzccj2kM5+Ty94cESuGlGB+7m8S13jwJysqAVwPUkJIJLi8GxwCaNt8CSzi8M'||
                           ' p9sw0D+tLA7wwqNSrbkuWZ+wvZDOcAp59nulMX/+bHsJV82suP4bqWctcFaW9Je654hbNVzAF6vr'||
                           ' AyVHtib9LuSKOxFSido=';
      v_linha := '<SignatureValue>'|| v_signature_value||'</SignatureValue>'||
                 '<KeyInfo><X509Data><X509Certificate>'|| v_x509Cert ||'</X509Certificate></X509Data></KeyInfo>';
      v_ordem := v_ordem + 1;
      insert into t_nfe values (v_ordem ,v_linha);
      --/
      v_linha := '</Signature>';
      v_ordem := v_ordem + 1;
      insert into t_nfe values (v_ordem ,v_linha);
      */
      --/ fim
   
      v_linha := '</NFe>';
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
   procedure xml_31(pp_emp ft_notas.empresa%type
                   ,pp_fil ft_notas.filial%type
                   ,pp_nro ft_notas.num_nota%type
                   ,pp_ser ft_notas.sr_nota%type
                   ,pp_id  ft_notas.id%type
                   ,pp_amb char)
   
    is
   
      cursor cr_i is
         select a.*
           from ft_itens_nf a
               ,ft_notas    b
          where /*b.empresa = pp_emp
                     and b.filial = pp_fil
                     and b.num_nota = pp_nro
                     and b.sr_nota = pp_ser
                     and b.parte = 0
                     and */
          a.id_ft_nota = b.id
          and b.id = pp_id;
   
      cursor cr_ir is
         select distinct a.fil_origem
                        ,a.doc_origem
                        ,a.ser_origem
           from ft_itens_nf a
               ,ft_notas    b
          where /*b.empresa = pp_emp
                     and b.filial = pp_fil
                     and b.num_nota = pp_nro
                     and b.sr_nota = pp_ser
                     and b.parte = 0
                     and */
          a.id_ft_nota = b.id
          and b.id = pp_id
          and a.doc_origem is not null;
   
      cursor cr_p is
         select a.*
           from ft_parc_nf a
               ,ft_notas   b
          where /*b.empresa = pp_emp
                     and b.filial = pp_fil
                     and b.num_nota = pp_nro
                     and b.sr_nota = pp_ser
                     and b.parte = 0
                     and */
          a.id_ft_nota = b.id
          and b.id = pp_id
          order by dt_vence;
   
      cursor cr_ptem is
         select 'S'
           from ft_parc_nf a
               ,ft_notas   b
          where /*b.empresa = pp_emp
                     and b.filial = pp_fil
                     and b.num_nota = pp_nro
                     and b.sr_nota = pp_ser
                     and b.parte = 0
                     and */
          a.id_ft_nota = b.id
          and b.id = pp_id;
   
      cursor cr_m is
         select * from ft_msgs_nf a where a.id_ft_nota = pp_id; /*empresa = pp_emp
               and filial = pp_fil
               and num_nota = pp_nro
               and sr_nota = pp_ser
               and parte = 0
               */
   
      cursor cr_ref(p_id ce_itens_nf.id%type) is
         select n.chave_nfe
           from ce_notas    n
               ,ce_itens_nf i
          where i.id = p_id
            and n.id = i.id_ce_nota;
   
      v_ref    number(10);
      v_nf_ref ce_notas.chave_nfe%type;
   
      rg_nf      ft_notas%rowtype;
      rg_emi     cd_firmas%rowtype;
      rg_tra     cd_firmas%rowtype;
      v_uf_ibge  cd_uf.cd_ibge%type;
      v_linha    varchar2(4000);
      v_desc_cfo ft_cfo.descricao%type;
      v_avista   ft_condpag.a_vista%type;
      v_natureza ft_cfo.natureza%type;
      v_mun_emi  cd_cidades.ibge%type;
      v_cid_emi  cd_cidades.cidade%type;
      v_finalid  char(1);
      v_tipo_imp char(1);
      rg_opr     ft_oper%rowtype;
      v_pai_emi  cd_paises.cod_siscomex%type;
      v_pais_emi cd_paises.nome%type;
      rg_des     cd_firmas%rowtype;
      v_mun_des  cd_cidades.ibge%type;
      v_cid_des  cd_cidades.cidade%type;
      v_pai_des  cd_paises.cod_siscomex%type;
      v_pais_des cd_paises.nome%type;
      v_item     number(9);
      v_tp_frete char(1);
      v_chave    varchar2(43);
      v_cnf      varchar2(9);
      v_ordem    number(9) := 0;
      v_atl_crec ft_cfo.atl_crec%type;
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
   
      v_versao sc_param.valor%type;
      v_crt    fs_param.crt%type;
      v_cnae   fs_param.cnae%type;
      v_tpemis char(1);
      v_indtot char(1);
   
      vqtditens         number;
      vfrete_rateado    number(15,
                               2);
      vfrete_item       number(15,
                               2);
      v_verproc         varchar2(100);
      v_x509cert        varchar2(32000);
      v_signature_value varchar2(32000);
      v_chave_nfe       varchar2(200);
      v_tipo_nf         varchar2(30);
      v_finalidade_nfe  number(1);
      v_cab_ref_nf      number(1);
      v_cab_ref_nfe     number(1);
      v_conta_ref       number(4);
      v_perc_red_base   number;
      v_iddest          number(1);
      v_temparc         varchar2(1);
   begin
   
      -- versao atual do xml (3.1)
      /*
      Select valor
        Into v_versao
        From sc_param
       Where codigo = 'VERSAO_XML_' || pp_emp;
      */
      v_versao  := '3.10';
      v_verproc := '3.10.37';
   
      -- limpa tabela temporaria
      delete t_nfe;
   
      -- codigo do regime tributario e cnae (2.0)
      select crt
            ,replace(replace(cnae,
                             '.',
                             ''),
                     '-',
                     '')
        into v_crt
            ,v_cnae
        from fs_param
       where empresa = pp_emp;
   
      -- limpa tabela temporaria
      delete t_nfe;
   
      -- dados da nota fiscal
      select *
        into rg_nf
        from ft_notas
       where empresa = pp_emp
         and filial = pp_fil
         and num_nota = pp_nro
         and sr_nota = pp_ser
         and parte = 0;
   
      -- tipo da emissao 
      v_tpemis := rg_nf.forma_emissao;
   
      -- emitente
      select *
        into rg_emi
        from cd_firmas
       where empresa = pp_emp
         and filial = pp_fil;
   
      -- uf conforme ibge
      select a.cd_ibge ibge
        into v_uf_ibge
        from cd_uf a
       where uf = rg_emi.uf
         and pais = rg_emi.pais;
   
      -- descricao do cfop
      select descricao
            ,atl_crec
        into v_desc_cfo
            ,v_atl_crec
        from ft_cfo
       where cod_cfo = rg_nf.cod_cfo;
   
      -- condicao de pagamento
      select decode(a_vista,
                    'S',
                    '0',
                    '1')
        into v_avista
        from ft_condpag
       where cod_condpag = rg_nf.cod_condpag;
   
      -- tipo documento fiscal
      select decode(natureza,
                    'E',
                    '0',
                    '1')
        into v_natureza
        from ft_cfo
       where cod_cfo = rg_nf.cod_cfo;
   
      -- cidade do emitente
      select ibge
            ,cidade
        into v_mun_emi
            ,v_cid_emi
        from cd_cidades
       where cod_cidade = rg_emi.cod_cidade;
   
      -- tipo da impressao
      select substr(valor,
                    1,
                    1)
        into v_tipo_imp
        from sc_param
       where codigo = 'TPIMP-' || rg_emi.empresa;
   
      -- operacao
      select *
        into rg_opr
        from ft_oper
       where empresa = rg_nf.empresa
         and cod_oper = rg_nf.cod_oper;
   
      -- nf origem
      v_finalid := '1';
      if rg_opr.nf_origem = 'S' or
         rg_opr.rm_origem = 'S' then
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
   
      -- pais
      select a.cod_siscomex pais_bacen
            ,nome
        into v_pai_emi
            ,v_pais_emi
        from cd_paises a
       where pais = rg_emi.pais;
   
      -- destinatario
      select * into rg_des from cd_firmas where firma = rg_nf.firma;
   
      -- cidade do destinatario
      select ibge
            ,cidade
        into v_mun_des
            ,v_cid_des
        from cd_cidades
       where cod_cidade = rg_nf.ent_cidade;
   
      -- pais destinatario
      select a.cod_siscomex pais_bacen
            ,nome
        into v_pai_des
            ,v_pais_des
        from cd_paises a
       where pais = rg_nf.ent_pais;
   
      -- frete
      if rg_nf.tp_frete = 'E' then
         v_tp_frete := '0';
      else
         v_tp_frete := '1';
      end if;
   
      -- transportadora
      if rg_nf.cod_transp is not null then
         select * into rg_tra from cd_firmas where firma = rg_nf.cod_transp;
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
      /*
      v_linha := '<nfeProc versao="2.00" xmlns="http://www.portalfiscal.inf.br/nfe">';
      v_ordem := nvl(v_ordem,0) + 1;
      insert into t_nfe values( v_ordem, v_linha );
        */
      v_linha := '<NFe xmlns="http://www.portalfiscal.inf.br/nfe">';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_chave := v_uf_ibge;
      v_chave := v_chave || to_char(rg_nf.dt_emissao,
                                    'RRMM');
      v_chave := v_chave || replace(replace(replace(replace(rg_emi.cgc_cpf,
                                                            '-',
                                                            ''),
                                                    '.',
                                                    ''),
                                            '-',
                                            ''),
                                    '/',
                                    '');
      v_chave := v_chave || '55';
      v_chave := v_chave || lpad(rg_nf.sr_nota,
                                 3,
                                 '0');
      v_chave := v_chave || lpad(rg_nf.num_nota,
                                 9,
                                 '0');
   
      v_chave := v_chave || v_tpemis || substr(v_cnf,
                                               -8);
      v_linha := '<infNFe Id="NFe' || v_chave || modulo11(v_chave) ||
                 '" versao="3.10">';
   
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<ide>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<cUF>' || v_uf_ibge || '</cUF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<cNF>' || substr(v_cnf,
                                   -8) || '</cNF>';
   
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<natOp>' || v_desc_cfo || '</natOp>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<indPag>' || v_avista || '</indPag>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<mod>55</mod>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<serie>' || trim(to_char(rg_nf.sr_nota)) || '</serie>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<nNF>' || pp_nro || '</nNF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<dhEmi>' || to_char(rg_nf.dt_emissao,
                                      'rrrr-mm-dd') || 'T' ||
                 to_char(sysdate,
                         'hh24:mi') || ':00-03:00' || '</dhEmi>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if substr(rg_nf.cod_cfo,
                1,
                1) <> '7' then
         v_linha := '<dhSaiEnt>' || to_char(rg_nf.dt_entsai,
                                            'rrrr-mm-dd') || 'T' ||
                    to_char(sysdate,
                            'hh24:mi') || ':00-03:00' || '</dhSaiEnt>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      
      end if;
   
      v_linha := '<tpNF>' || v_natureza || '</tpNF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|<idDest>2</idDest>
      /*
       informar o identificador de local de destino da operação:
       1 - Operação interna;
       2 - Operação interestadual;
       3 - Operação com exterior.     
      */
      if substr(rg_nf.cod_cfo,
                1,
                1) in (1,
                       5) then
         v_iddest := 1;
      elsif substr(rg_nf.cod_cfo,
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
   
      --|-----------------------------------------------
      v_linha := '<cMunFG>' || v_mun_emi || '</cMunFG>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if v_finalid = '2' then
         --v_linha := '<refNFe>';
         --v_ordem := v_ordem + 1;
         --insert into t_nfe values( v_ordem, v_linha );
      
         -- v_linha := '<refNF>';
         -- v_ordem := v_ordem + 1;
         -- insert into t_nfe values( v_ordem, v_linha );
         v_cab_ref_nf  := 0;
         v_cab_ref_nfe := 0;
         for ite in cr_ir loop
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
                where empresa = rg_nf.empresa
                  and filial = ite.fil_origem
                  and cod_fornec = rg_nf.firma
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
                   where empresa = rg_nf.empresa
                     and filial = ite.fil_origem
                     and num_nota = ite.doc_origem
                     and sr_nota = ite.ser_origem
                     and parte = 0;
                  select firma
                    into v_firma_ori
                    from cd_firmas
                   where empresa = rg_nf.empresa
                     and filial = rg_nf.filial;
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
                  and pais = rg_emi.pais;
            
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
   
      v_linha := '<tpImp>' || v_tipo_imp || '</tpImp>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      -- tipo da emissao 
   
      v_linha := '<tpEmis>' || v_tpemis || '</tpEmis>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<cDV>' || modulo11(v_chave) || '</cDV>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|<tpAmb>1</tpAmb>
      v_linha := '<tpAmb>' || pp_amb || '</tpAmb>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|<finNFe>1</finNFe>   
      /*
      nformar o código da finalidade de emissão da NF-e: 
      1 - NF-e normal;
      2 - NF-e complementar;
      3 - NF-e de ajuste;
      4 - Devolução(novo domínio) [23-12-13]
      */
      v_linha := '<finNFe>' || rg_nf.finalidade_nfe || '</finNFe>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --| <indFinal>1</indFinal>
      /*
       informar o indicador de operação com Consumidor final:
       0 - Não;
       1 - Consumidor final;
       (campo novo) [23-12-13]     
      */
   
      v_linha := '<indFinal>' || rg_nf.ind_final || '</indFinal>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --| <indPres>9</indPres>
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
   
      --| <procEmi>3</procEmi>
      v_linha := '<procEmi>3</procEmi>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|<indFinal>0</indFinal>
      v_linha := '<indFinal>0</indFinal>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|<indPres>0</indPres>
      /*
      Se foi uma operação presencial, preencher com ¿1¿;
      Se foi uma venda por internet, preencher com ¿2¿;
      Se foi uma venda por teleatendimento, preencher com ¿3¿;
      Se foi uma venda não presencial numa situação não 
      identificada anteriormente, preencher com ¿9¿.
      */
      v_linha := '<indPres>' || 9 || '</indPres>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|<verProc>3.10.37</verProc>
      v_linha := '<verProc>' || v_verproc || '</verProc>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|nfe referenciada
      v_ordem := v_ordem + 1;
      v_ref   := 0;
   
      for rgi in cr_i loop
      
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
   
      v_linha := '<emit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if rg_emi.natureza = 'J' then
         v_linha := '<CNPJ>' || replace(replace(replace(replace(rg_emi.cgc_cpf,
                                                                '-',
                                                                ''),
                                                        '.',
                                                        ''),
                                                '-',
                                                ''),
                                        '/',
                                        '') || '</CNPJ>';
      else
         v_linha := '<CPF>' || replace(replace(replace(replace(rg_emi.cgc_cpf,
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
   
      v_linha := '<xNome>' || rg_emi.nome || '</xNome>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<xFant>' || rg_emi.reduzido || '</xFant>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<enderEmit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<xLgr>' || rg_emi.endereco || '</xLgr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<nro>' || nvl(rg_emi.numero,
                                '0') || '</nro>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if ltrim(rtrim(rg_emi.complemento)) is not null then
         v_linha := '<xCpl>' || ltrim(rtrim(rg_emi.complemento)) || '</xCpl>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      if rg_emi.bairro is not null then
         v_linha := '<xBairro>' || rg_emi.bairro || '</xBairro>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      v_linha := '<cMun>' || v_mun_emi || '</cMun>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<xMun>' || v_cid_emi || '</xMun>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<UF>' || rg_emi.uf || '</UF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<CEP>' || replace(replace(rg_emi.cep,
                                            '-',
                                            ''),
                                    '.',
                                    '') || '</CEP>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<cPais>' || v_pai_emi || '</cPais>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<xPais>' || v_pais_emi || '</xPais>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<fone>' || cd_nfe_utl.fone(rg_emi.firma) || '</fone>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '</enderEmit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<IE>' || replace(replace(replace(rg_emi.iest,
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
   
      v_linha := '<IM>' || rg_emi.imun || '</IM>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<CNAE>' || v_cnae || '</CNAE>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<CRT>' || v_crt || '</CRT>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '</emit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<dest>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if rg_des.natureza = 'J' then
         v_linha := '<CNPJ>' || replace(replace(replace(replace(rg_des.cgc_cpf,
                                                                '-',
                                                                ''),
                                                        '.',
                                                        ''),
                                                '-',
                                                ''),
                                        '/',
                                        '') || '</CNPJ>';
      else
         v_linha := '<CPF>' || replace(replace(replace(replace(rg_des.cgc_cpf,
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
   
      v_linha := '<xNome>' || rg_des.nome || '</xNome>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<enderDest>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<xLgr>' || rg_des.endereco || '</xLgr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<nro>' || nvl(rg_des.numero,
                                0) || '</nro>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if ltrim(rtrim(rg_des.complemento)) is not null then
         v_linha := '<xCpl>' || ltrim(rtrim(rg_des.complemento)) || '</xCpl>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      if rg_des.bairro is not null then
         v_linha := '<xBairro>' || rg_des.bairro || '</xBairro>';
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
   
      v_linha := '<UF>' || rg_nf.ent_uf || '</UF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<CEP>' || replace(replace(rg_nf.ent_cep,
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
   
      v_linha := '<fone>' || cd_nfe_utl.fone(rg_nf.firma) || '</fone>';
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
      if rg_des.iest is null or
         upper(rg_des.iest) = upper('ISENTO') or
         upper(rg_des.iest) = upper('ISENTA') then
         v_linha := '<indIEDest>9</indIEDest>';
      else
         if rg_des.natureza = 'J' then
            v_linha := '<IE>' || replace(replace(replace(nvl(rg_des.iest,
                                                             rg_des.ipro),
                                                         '.',
                                                         ''),
                                                 '-',
                                                 ''),
                                         '/',
                                         '') || '</IE>';
         else
            v_linha := '<IE>' || replace(replace(replace(nvl(rg_des.ipro,
                                                             rg_des.iest),
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
      
         for rgi in cr_i loop
         
            if nvl(rg_nf.vl_frete,
                   0) > 0 then
               vfrete_item := rg_nf.vl_frete / vqtditens;
            else
               vfrete_item := 0;
            end if;
         
            vfrete_rateado := vfrete_rateado + vfrete_item;
         
            v_item := v_item + 1;
         
            if nvl(rg_nf.vl_frete,
                   0) > 0 then
               if v_item = vqtditens then
                  if vfrete_rateado > rg_nf.vl_frete then
                     vfrete_item := vfrete_item -
                                    (vfrete_rateado - rg_nf.vl_frete);
                  elsif vfrete_rateado < rg_nf.vl_frete then
                     vfrete_item := vfrete_item +
                                    (rg_nf.vl_frete - vfrete_rateado);
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
         
            v_linha := '<cEAN />';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            v_linha   := '<xProd>' || ltrim(rtrim(substr(rgi.descricao,
                                                         1,
                                                         100))) || '</xProd>';
            v_detalhe := ltrim(rtrim(substr(rgi.descricao,
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
                                                        '9999999999990D000000'),
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
         
            v_linha := '<cEANTrib />';
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
                                                         '9999999999990D000000'),
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
            if nvl(rgi.vl_desconto,
                   0) > 0 then
            
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
            if nvl(rgi.vl_outras,
                   0) > 0 then
            
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
            if substr(rgi.cod_cfo,
                      1,
                      5) = '5.662' then
               v_linha := '<comb>';
               v_linha := v_linha || ' <cProdANP>620502001</cProdANP> ' ||
                          ' <UFCons>SP</UFCons> ' || '</comb>';
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
         
            if rgi.cod_tribut_ipi not in (50,
                                          0,
                                          01) then
            
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
            
            else
               -- rgi.cod_tribut_ipi in (50) then
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
      
         for rgi in cr_i loop
         
            --  if nvl( rg_nf.vl_frete, 0 ) > 0 then
            --    vfrete_item := rg_nf.vl_frete / vqtditens;
            --  else
            vfrete_item    := 0;
            vfrete_rateado := 0;
            --  end if;
         
            v_item := v_item + 1;
         
            if nvl(rg_nf.vl_frete,
                   0) > 0 then
               if v_item = vqtditens then
                  if vfrete_rateado > rg_nf.vl_frete then
                     vfrete_item := vfrete_item -
                                    (vfrete_rateado - rg_nf.vl_frete);
                  elsif vfrete_rateado < rg_nf.vl_frete then
                     vfrete_item := vfrete_item +
                                    (rg_nf.vl_frete - vfrete_rateado);
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
         
            v_linha := '<cEAN />';
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
         
            v_linha := '<cEANTrib />';
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
   
      v_linha := '<vBC>' || trim(replace(to_char(nvl(rg_nf.vl_bicms,
                                                     0),
                                                 '9999999999990D00'),
                                         ',',
                                         '.')) || '</vBC>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vICMS>' || trim(replace(to_char(nvl(rg_nf.vl_icms,
                                                       0),
                                                   '9999999999990D00'),
                                           ',',
                                           '.')) || '</vICMS>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vBCST>' || trim(replace(to_char(nvl(rg_nf.vl_bicms_sub,
                                                       0),
                                                   '9999999999990D00'),
                                           ',',
                                           '.')) || '</vBCST>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vST>' || trim(replace(to_char(nvl(rg_nf.vl_icms_sub,
                                                     0),
                                                 '9999999999990D00'),
                                         ',',
                                         '.')) || '</vST>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      /*if rg_opr.complemento = 'N' then*/
      v_linha := '<vProd>' || trim(replace(to_char(nvl(rg_nf.vl_produtos,
                                                       0),
                                                   '9999999999990D00'),
                                           ',',
                                           '.')) || '</vProd>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vFrete>' || trim(replace(to_char(nvl(rg_nf.vl_frete,
                                                        0),
                                                    '9999999999990D00'),
                                            ',',
                                            '.')) || '</vFrete>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vSeg>' || trim(replace(to_char(nvl(rg_nf.vl_seguro,
                                                      0),
                                                  '9999999999990D00'),
                                          ',',
                                          '.')) || '</vSeg>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vDesc>' || trim(replace(to_char(nvl(rg_nf.vl_desconto,
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
   
      v_linha := '<vIPI>' || trim(replace(to_char(nvl(rg_nf.vl_ipi,
                                                      0),
                                                  '9999999999990D00'),
                                          ',',
                                          '.')) || '</vIPI>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vPIS>' || trim(replace(to_char(nvl(rg_nf.vl_pis,
                                                      0),
                                                  '9999999999990D00'),
                                          ',',
                                          '.')) || '</vPIS>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vCOFINS>' || trim(replace(to_char(nvl(rg_nf.vl_cofins,
                                                         0),
                                                     '9999999999990D00'),
                                             ',',
                                             '.')) || '</vCOFINS>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vOutro>' || trim(replace(to_char(nvl(rg_nf.vl_outros,
                                                        0),
                                                    '9999999999990D00'),
                                            ',',
                                            '.')) || '</vOutro>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<vNF>' || trim(replace(to_char(nvl(rg_nf.vl_total,
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
   
      if rg_nf.cod_transp is not null then
      
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
   
      if rg_nf.placa_veic is not null and
         rg_nf.placa_uf is not null then
         v_linha := '<veicTransp>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      
         v_linha := '<placa>' || upper(replace(replace(rg_nf.placa_veic,
                                                       '-',
                                                       ''),
                                               ' ',
                                               '')) || '</placa>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      
         v_linha := '<UF>' || rg_nf.placa_uf || '</UF>';
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
   
      v_linha := '<qVol>' || nvl(rg_nf.vol_qtd,
                                 1) || '</qVol>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if rg_nf.vol_especie is not null then
         v_linha := '<esp>' || rg_nf.vol_especie || '</esp>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      if rg_nf.vol_marca is not null then
         v_linha := '<marca>' || rg_nf.vol_marca || '</marca>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      if rg_nf.vol_numero is not null then
         v_linha := '<nVol>' || rg_nf.vol_numero || '</nVol>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      v_linha := '<pesoL>' || trim(replace(to_char(nvl(rg_nf.peso_liquido,
                                                       0),
                                                   '9999999999990D000'),
                                           ',',
                                           '.')) || '</pesoL>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<pesoB>' || trim(replace(to_char(nvl(rg_nf.peso_bruto,
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
      open cr_ptem;
      fetch cr_ptem
         into v_temparc;
      close cr_ptem;
   
      if v_atl_crec = 'S' and
         v_temparc = 'S' then
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
      
         v_linha := '<nFat>' || rg_nf.num_nota || '</nFat>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      
         v_linha := '<vOrig>' || trim(replace(to_char(nvl(rg_nf.vl_total,
                                                          0),
                                                      '9999999999990D00'),
                                              ',',
                                              '.')) || '</vOrig>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      
         v_linha := '<vLiq>' || trim(replace(to_char(nvl(rg_nf.vl_total,
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
         for rgi in cr_p loop
         
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
      for rgi in cr_m loop
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
   procedure xml_40(pp_emp ft_notas.empresa%type
                   ,pp_fil ft_notas.filial%type
                   ,pp_nro ft_notas.num_nota%type
                   ,pp_ser ft_notas.sr_nota%type
                   ,pp_id  ft_notas.id%type
                   ,pp_amb char)
   
    is
   
      cursor cr_i is
         select a.*
           from ft_itens_nf a
               ,ft_notas    b
          where a.id_ft_nota = b.id
            and b.id = pp_id;
   
      cursor cr_ir is
         select distinct a.fil_origem
                        ,a.doc_origem
                        ,a.ser_origem
           from ft_itens_nf a
               ,ft_notas    b
          where a.id_ft_nota = b.id
            and b.id = pp_id
            and a.doc_origem is not null;
   
      cursor cr_p is
         select a.*
           from ft_parc_nf a
               ,ft_notas   b
          where a.id_ft_nota = b.id
            and b.id = pp_id
          order by dt_vence;
   
      cursor cr_ptem is
         select 'S'
           from ft_parc_nf a
               ,ft_notas   b
          where a.id_ft_nota = b.id
            and b.id = pp_id;
   
      cursor cr_m is
         select * from ft_msgs_nf a where a.id_ft_nota = pp_id;
   
      cursor cr_ref(p_id ce_itens_nf.id%type) is
         select n.chave_nfe
           from ce_notas    n
               ,ce_itens_nf i
          where i.id = p_id
            and n.id = i.id_ce_nota;
   
      v_ref    number(10);
      v_nf_ref ce_notas.chave_nfe%type;
   
      rg_nf      ft_notas%rowtype;
      rg_emi     cd_firmas%rowtype;
      rg_tra     cd_firmas%rowtype;
      v_uf_ibge  cd_uf.cd_ibge%type;
      v_linha    varchar2(4000);
      v_desc_cfo ft_cfo.descricao%type;
      v_avista   ft_condpag.a_vista%type;
      v_natureza ft_cfo.natureza%type;
      v_mun_emi  cd_cidades.ibge%type;
      v_cid_emi  cd_cidades.cidade%type;
      v_finalid  char(1);
      v_tipo_imp char(1);
      rg_opr     ft_oper%rowtype;
      v_pai_emi  cd_paises.cod_siscomex%type;
      v_pais_emi cd_paises.nome%type;
      rg_des     cd_firmas%rowtype;
      v_mun_des  cd_cidades.ibge%type;
      v_cid_des  cd_cidades.cidade%type;
      v_pai_des  cd_paises.cod_siscomex%type;
      v_pais_des cd_paises.nome%type;
      v_item     number(9);
      v_tp_frete char(1);
      v_chave    varchar2(43);
      v_cnf      varchar2(9);
      v_ordem    number(9) := 0;
      v_atl_crec ft_cfo.atl_crec%type;
      v_msg      varchar2(4000);
      v_detalhe  varchar2(4000);
      --v_boletim     pp_lotes.boletim%type;
      --v_categoria   pp_lotes.categoria%type;
      --v_vc          ce_produtos.prof%type;
      v_unidade      ce_produtos.unidade%type;
      v_sigla        varchar2(2);
      v_nbm          ft_clafis.cod_nbm%type;
      v_uf_ori       varchar2(2);
      v_dt_ori       varchar2(4);
      v_firma_ori    cd_firmas.firma%type;
      v_uf_ibge_ori  cd_uf.cd_ibge%type;
      v_natureza_ori cd_firmas.natureza%type;
      v_cgc_cpf_ori  cd_firmas.cgc_cpf%type;
   
      v_versao sc_param.valor%type;
      v_crt    fs_param.crt%type;
      v_cnae   fs_param.cnae%type;
      v_tpemis char(1);
      v_indtot char(1);
   
      vqtditens         number;
      vfrete_rateado    number(15,
                               2);
      vfrete_item       number(15,
                               2);
      v_verproc         varchar2(100);
      v_x509cert        varchar2(32000);
      v_signature_value varchar2(32000);
      v_chave_nfe       varchar2(200);
      v_tipo_nf         varchar2(30);
      v_finalidade_nfe  number(1);
      v_cab_ref_nf      number(1);
      v_cab_ref_nfe     number(1);
      v_conta_ref       number(4);
      v_perc_red_base   number;
      v_iddest          number(1);
      v_temparc         varchar2(1);
      v_indpag          varchar2(10);
      v_tpag            varchar2(10);
      g_chave_completa  varchar2(240);
      v_cst_icms        varchar2(2);
   begin
   
      -- versao atual do xml (3.1)
      /*
      Select valor
        Into v_versao
        From sc_param
       Where codigo = 'VERSAO_XML_' || pp_emp;
      */
   
      v_versao  := '4.00';
      v_verproc := '4.00_b017';
   
      -- limpa tabela temporaria
      delete t_nfe;
   
      -- codigo do regime tributario e cnae (2.0)
      select crt
            ,replace(replace(cnae,
                             '.',
                             ''),
                     '-',
                     '')
        into v_crt
            ,v_cnae
        from fs_param
       where empresa = pp_emp;
   
      -- limpa tabela temporaria
      delete t_nfe;
   
      -- dados da nota fiscal
      select * into rg_nf from ft_notas where id = pp_id;
   
      -- emitente
      select *
        into rg_emi
        from cd_firmas
       where empresa = pp_emp
         and filial = pp_fil;
   
      -- uf conforme ibge
      select a.cd_ibge ibge
        into v_uf_ibge
        from cd_uf a
       where uf = rg_emi.uf
         and pais = rg_emi.pais;
   
      -- descricao do cfop
      select descricao
            ,atl_crec
        into v_desc_cfo
            ,v_atl_crec
        from ft_cfo
       where cod_cfo = rg_nf.cod_cfo;
   
      -- condicao de pagamento
      select decode(a_vista,
                    'S',
                    '0',
                    '1')
        into v_avista
        from ft_condpag
       where cod_condpag = rg_nf.cod_condpag;
   
      -- tipo documento fiscal
      select decode(natureza,
                    'E',
                    '0',
                    '1')
        into v_natureza
        from ft_cfo
       where cod_cfo = rg_nf.cod_cfo;
   
      -- cidade do emitente
      select ibge
            ,cidade
        into v_mun_emi
            ,v_cid_emi
        from cd_cidades
       where cod_cidade = rg_emi.cod_cidade;
   
      -- tipo da impressao
      select substr(valor,
                    1,
                    1)
        into v_tipo_imp
        from sc_param
       where codigo = 'TPIMP-' || rg_emi.empresa;
   
      -- operacao
      select *
        into rg_opr
        from ft_oper
       where empresa = rg_nf.empresa
         and cod_oper = rg_nf.cod_oper;
   
      -- nf origem
      v_finalid := '1';
      if rg_opr.nf_origem = 'S' or
         rg_opr.rm_origem = 'S' then
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
   
      -- pais
      select a.cod_siscomex pais_bacen
            ,nome
        into v_pai_emi
            ,v_pais_emi
        from cd_paises a
       where pais = rg_emi.pais;
   
      -- destinatario
      select * into rg_des from cd_firmas where firma = rg_nf.firma;
   
      -- cidade do destinatario
      select ibge
            ,cidade
        into v_mun_des
            ,v_cid_des
        from cd_cidades
       where cod_cidade = rg_nf.ent_cidade;
   
      -- pais destinatario
      select a.cod_siscomex pais_bacen
            ,nome
        into v_pai_des
            ,v_pais_des
        from cd_paises a
       where pais = rg_nf.ent_pais;
   
      -- frete
      if rg_nf.tp_frete = 'E' then
         v_tp_frete := '0';
      else
         v_tp_frete := '1';
      end if;
   
      -- transportadora
      if rg_nf.cod_transp is not null then
         select * into rg_tra from cd_firmas where firma = rg_nf.cod_transp;
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
   
      v_chave := v_uf_ibge;
      v_chave := v_chave || to_char(rg_nf.dt_emissao,
                                    'RRMM');
      v_chave := v_chave || replace(replace(replace(replace(rg_emi.cgc_cpf,
                                                            '-',
                                                            ''),
                                                    '.',
                                                    ''),
                                            '-',
                                            ''),
                                    '/',
                                    '');
      v_chave := v_chave || '55';
      v_chave := v_chave || lpad(rg_nf.sr_nota,
                                 3,
                                 '0');
      v_chave := v_chave || lpad(rg_nf.num_nota,
                                 9,
                                 '0');
      -- tipo da emissao 
      v_tpemis := rg_nf.forma_emissao;
   
      v_chave := v_chave || v_tpemis || substr(v_cnf,
                                               -8);
      --<infNFe Id="NFe35180708236786000152550010000065751693900092" versao="4.00"> -8);
      g_chave_completa := 'NFe' || v_chave || modulo11(v_chave) ;
                 
      v_linha := '<infNFe Id="'|| g_chave_completa ||'" versao="' || v_versao|| '">';
      --v_linha := '<Versao>' || v_versao || '</Versao> ';
   
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<ide>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<cUF>' || v_uf_ibge || '</cUF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<cNF>' || substr(v_cnf,
                                   -8) || '</cNF>';
   
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<natOp>' || v_desc_cfo || '</natOp>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<mod>55</mod>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<serie>' || trim(to_char(rg_nf.sr_nota)) || '</serie>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<nNF>' || pp_nro || '</nNF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<dhEmi>' || to_char(rg_nf.dt_emissao,
                                      'rrrr-mm-dd') || 'T' ||
                 to_char(sysdate,
                         'hh24:mi') || ':00-03:00' || '</dhEmi>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if substr(rg_nf.cod_cfo,
                1,
                1) <> '7' then
         v_linha := '<dhSaiEnt>' || to_char(rg_nf.dt_entsai,
                                            'rrrr-mm-dd') || 'T' ||
                    to_char(sysdate,
                            'hh24:mi') || ':00-03:00' || '</dhSaiEnt>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      
      end if;
   
      v_linha := '<tpNF>' || v_natureza || '</tpNF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|<idDest>2</idDest>
      /*
       informar o identificador de local de destino da operação:
       1 - Operação interna;
       2 - Operação interestadual;
       3 - Operação com exterior.     
      */
      if substr(rg_nf.cod_cfo,
                1,
                1) in (1,
                       5) then
         v_iddest := 1;
      elsif substr(rg_nf.cod_cfo,
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
   
      --|-----------------------------------------------
      v_linha := '<cMunFG>' || v_mun_emi || '</cMunFG>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if v_finalid = '2' then
         v_cab_ref_nf  := 0;
         v_cab_ref_nfe := 0;
         for ite in cr_ir loop
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
                where empresa = rg_nf.empresa
                  and filial = ite.fil_origem
                  and cod_fornec = rg_nf.firma
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
                   where empresa = rg_nf.empresa
                     and filial = ite.fil_origem
                     and num_nota = ite.doc_origem
                     and sr_nota = ite.ser_origem
                     and parte = 0;
                  select firma
                    into v_firma_ori
                    from cd_firmas
                   where empresa = rg_nf.empresa
                     and filial = rg_nf.filial;
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
                  and pais = rg_emi.pais;
            
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
   
      v_linha := '<tpImp>' || v_tipo_imp || '</tpImp>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      -- tipo da emissao 
      v_linha := '<tpEmis>' || v_tpemis || '</tpEmis>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<cDV>' || modulo11(v_chave) || '</cDV>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|<tpAmb>1</tpAmb>
      v_linha := '<tpAmb>' || pp_amb || '</tpAmb>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|<finNFe>1</finNFe>   
      /*
      nformar o código da finalidade de emissão da NF-e: 
      1 - NF-e normal;
      2 - NF-e complementar;
      3 - NF-e de ajuste;
      4 - Devolução(novo domínio) [23-12-13]
      */
      v_linha := '<finNFe>' || rg_nf.finalidade_nfe || '</finNFe>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --| <indFinal>1</indFinal>
      /*
       informar o indicador de operação com Consumidor final:
       0 - Não;
       1 - Consumidor final;
       (campo novo) [23-12-13]     
      */
   
      v_linha := '<indFinal>' || rg_nf.ind_final || '</indFinal>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --| <indPres>9</indPres>
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
   
      --| <procEmi>3</procEmi>
      /*
      Identificador do processo de emissão da NF-e: 
      0 - emissão de NF-e com aplicativo do contribuinte; 
      1 - emissão de NF-e avulsa pelo Fisco; 
      2 - emissão de NF-e avulsa, pelo contribuinte com seu certificado digital, através do site do Fisco; 
      3 - emissão NF-e pelo contribuinte com aplicativo fornecido pelo Fisco      
      */
      v_linha := '<procEmi>0</procEmi>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|<verProc>3.0</verProc>
      v_linha := '<verProc>' || v_verproc || '</verProc>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      --|nfe referenciada
      v_ordem := v_ordem + 1;
      v_ref   := 0;
   
      for rgi in cr_i loop
      
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
   
      v_linha := '<emit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if rg_emi.natureza = 'J' then
         v_linha := '<CNPJ>' || replace(replace(replace(replace(rg_emi.cgc_cpf,
                                                                '-',
                                                                ''),
                                                        '.',
                                                        ''),
                                                '-',
                                                ''),
                                        '/',
                                        '') || '</CNPJ>';
      else
         v_linha := '<CPF>' || replace(replace(replace(replace(rg_emi.cgc_cpf,
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
   
      v_linha := '<xNome>' || rg_emi.nome || '</xNome>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<xFant>' || rg_emi.reduzido || '</xFant>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<enderEmit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<xLgr>' || rg_emi.endereco || '</xLgr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<nro>' || nvl(rg_emi.numero,
                                '0') || '</nro>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if ltrim(rtrim(rg_emi.complemento)) is not null then
         v_linha := '<xCpl>' || ltrim(rtrim(rg_emi.complemento)) || '</xCpl>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      if rg_emi.bairro is not null then
         v_linha := '<xBairro>' || rg_emi.bairro || '</xBairro>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      v_linha := '<cMun>' || v_mun_emi || '</cMun>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<xMun>' || v_cid_emi || '</xMun>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<UF>' || rg_emi.uf || '</UF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<CEP>' || replace(replace(rg_emi.cep,
                                            '-',
                                            ''),
                                    '.',
                                    '') || '</CEP>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<cPais>' || v_pai_emi || '</cPais>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<xPais>' || v_pais_emi || '</xPais>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<fone>' || cd_nfe_utl.fone(rg_emi.firma) || '</fone>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '</enderEmit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<IE>' || replace(replace(replace(rg_emi.iest,
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
   
      v_linha := '<IM>' || rg_emi.imun || '</IM>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<CNAE>' || v_cnae || '</CNAE>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<CRT>' || v_crt || '</CRT>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '</emit>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<dest>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if rg_des.natureza = 'J' then
         v_linha := '<CNPJ>' || replace(replace(replace(replace(rg_des.cgc_cpf,
                                                                '-',
                                                                ''),
                                                        '.',
                                                        ''),
                                                '-',
                                                ''),
                                        '/',
                                        '') || '</CNPJ>';
      else
         v_linha := '<CPF>' || replace(replace(replace(replace(rg_des.cgc_cpf,
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
   
      v_linha := '<xNome>' || rg_des.nome || '</xNome>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<enderDest>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<xLgr>' || rg_des.endereco || '</xLgr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<nro>' || nvl(rg_des.numero,
                                0) || '</nro>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if ltrim(rtrim(rg_des.complemento)) is not null then
         v_linha := '<xCpl>' || ltrim(rtrim(rg_des.complemento)) || '</xCpl>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      if rg_des.bairro is not null then
         v_linha := '<xBairro>' || rg_des.bairro || '</xBairro>';
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
   
      v_linha := '<UF>' || rg_nf.ent_uf || '</UF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<CEP>' || replace(replace(rg_nf.ent_cep,
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
   
      v_linha := '<fone>' || cd_nfe_utl.fone(rg_nf.firma) || '</fone>';
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
      if rg_des.iest is null or
         upper(rg_des.iest) = upper('ISENTO') or
         upper(rg_des.iest) = upper('ISENTA') then
         v_linha := '<indIEDest>9</indIEDest>';
      else
         -- indIEDest
         --1 (Contribuinte de ICMS), 
         --2 (Contribuinte Isento de Inscrição)
         v_linha := '<indIEDest>' || 1 || '</indIEDest>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      
         if rg_des.natureza = 'J' then
         
            v_linha := '<IE>' || replace(replace(replace(nvl(rg_des.iest,
                                                             rg_des.ipro),
                                                         '.',
                                                         ''),
                                                 '-',
                                                 ''),
                                         '/',
                                         '') || '</IE>';
         else
            v_linha := '<IE>' || replace(replace(replace(nvl(rg_des.ipro,
                                                             rg_des.iest),
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
      
         for rgi in cr_i loop
         
            if nvl(rg_nf.vl_frete,
                   0) > 0 then
               vfrete_item := rg_nf.vl_frete / vqtditens;
            else
               vfrete_item := 0;
            end if;
         
            vfrete_rateado := vfrete_rateado + vfrete_item;
         
            v_item := v_item + 1;
         
            if nvl(rg_nf.vl_frete,
                   0) > 0 then
               if v_item = vqtditens then
                  if vfrete_rateado > rg_nf.vl_frete then
                     vfrete_item := vfrete_item -
                                    (vfrete_rateado - rg_nf.vl_frete);
                  elsif vfrete_rateado < rg_nf.vl_frete then
                     vfrete_item := vfrete_item +
                                    (rg_nf.vl_frete - vfrete_rateado);
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
         
            select ltrim(rtrim(sigla)) into v_sigla from ce_unid where unidade = rgi.uni_ven;
            --    v_linha := '<uCom>' || rgi.uni_ven || '</uCom>';
            /*
            if rgi.produto = 33455 then
            raise_application_error(-20200,v_sigla|| ' - '|| length(v_sigla) );
            end if;
            */
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
         
            select ltrim(rtrim(sigla)) into v_sigla from ce_unid where unidade = rgi.uni_val;
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
            if nvl(rgi.vl_desconto,
                   0) > 0 then
            
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
            if nvl(rgi.vl_outras,
                   0) > 0 then
            
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
            if substr(rgi.cod_cfo,
                      1,
                      5) = '5.662' then
               v_linha := '<comb>';
               v_linha := v_linha || ' <cProdANP>620502001</cProdANP> ' ||
                          ' <UFCons>SP</UFCons> ' || '</comb>';
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
           
            if rgi.cod_tribut in(40, 41,50) then
               v_ordem := gera_cst_icms_isento(rgi.cod_tribut,rgi.cod_origem,v_ordem);
              --v_cst_icms := '40';
            
              --v_cst_icms := substr(rgi.cod_tribut + 100,
               --                            -2);
            --end if;
            /*                     
            v_linha := '<ICMS' || v_cst_icms || '>';

                                                     
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         
            v_linha := '<orig>' || nvl(rgi.cod_origem,0) || '</orig>';
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
         */
            else
            --if rgi.cod_tribut <> 40 then
               v_ordem := gera_cst_icms_normal(rgi.id,       
                                    rgi.vl_bicms ,
                                    rgi.aliq_icms,
                                    rgi.vl_icms  ,
                                    rgi.cod_tribut,
                                    rgi.cod_origem,
                                    v_ordem);
               
               /*
               
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
                  */
            end if;
         /*
            v_linha := '</ICMS' ||v_cst_icms || '>';
            v_ordem := v_ordem + 1;
            insert into t_nfe
            values
               (v_ordem
               ,v_linha);
         */
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
         
            if rgi.cod_tribut_ipi not in (50,
                                          0,
                                          01) then
            
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
            
            else
               -- rgi.cod_tribut_ipi in (50) then
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
            
               --*
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
            /*    
            --<impostoDevol>
            v_linha := '</impostoDevol>';
             v_ordem := v_ordem + 1;
                        insert into t_nfe
                        values
                           (v_ordem
                           ,v_linha);
            <pDevol/>
            <IPIDevol>
            <vIPIDevol/>
            </IPIDevol>
            </impostoDevol> 
            */
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
      
         for rgi in cr_i loop
         
            --  if nvl( rg_nf.vl_frete, 0 ) > 0 then
            --    vfrete_item := rg_nf.vl_frete / vqtditens;
            --  else
            vfrete_item    := 0;
            vfrete_rateado := 0;
            --  end if;
         
            v_item := v_item + 1;
         
            if nvl(rg_nf.vl_frete,
                   0) > 0 then
               if v_item = vqtditens then
                  if vfrete_rateado > rg_nf.vl_frete then
                     vfrete_item := vfrete_item -
                                    (vfrete_rateado - rg_nf.vl_frete);
                  elsif vfrete_rateado < rg_nf.vl_frete then
                     vfrete_item := vfrete_item +
                                    (rg_nf.vl_frete - vfrete_rateado);
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
         
            select ltrim(rtrim(sigla)) into v_sigla from ce_unid where unidade = rgi.uni_ven;
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
         
            select ltrim(rtrim(sigla)) into v_sigla from ce_unid where unidade = rgi.uni_val;
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
            
               v_linha := '<vAliqProd>' ||
                          0 || '</vAliqProd>';
               v_ordem := v_ordem + 1;
               insert into t_nfe
               values
                  (v_ordem
                  ,v_linha);
            
               v_linha := '<vCOFINS>' || 
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
               v_linha := '<infAdProd>' || 
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
   
      /*
      <vBC>10475.00</vBC>
      */
      v_linha := '<vBC>' || trim(replace(to_char(nvl(rg_nf.vl_bicms,
                                                     0),
                                                 '9999999999990D00'),
                                         ',',
                                         '.')) || '</vBC>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      <vICMS>1885.50</vICMS>
      */
      v_linha := '<vICMS>' || trim(replace(to_char(nvl(rg_nf.vl_icms,
                                                       0),
                                                   '9999999999990D00'),
                                           ',',
                                           '.')) || '</vICMS>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      /*
      <vICMSDeson>0.00</vICMSDeson>
      */
      v_linha := '<vICMSDeson>0.00</vICMSDeson>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*         
      <vFCPUFDest>0.00</vFCPUFDest>
      */
      v_linha := '<vFCPUFDest>0.00</vFCPUFDest>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*               
      <vICMSUFDest>0.00</vICMSUFDest>
      */
      v_linha := '<vICMSUFDest>0.00</vICMSUFDest>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*               
      <vICMSUFRemet>0.00</vICMSUFRemet>
      */
      v_linha := '<vICMSUFRemet>0.00</vICMSUFRemet>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*               
      <vFCP>0.00</vFCP>
      */
      v_linha := '<vFCP>0.00</vFCP>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*              
      <vBCST>0.00</vBCST>
      */
      v_linha := '<vBCST>' || trim(replace(to_char(nvl(rg_nf.vl_bicms_sub,
                                                       0),
                                                   '9999999999990D00'),
                                           ',',
                                           '.')) || '</vBCST>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*         
      <vST>0.00</vST>
      */
      v_linha := '<vST>' || trim(replace(to_char(nvl(rg_nf.vl_icms_sub,
                                                     0),
                                                 '9999999999990D00'),
                                         ',',
                                         '.')) || '</vST>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      /*
      <vFCPST>0.00</vFCPST>               
      */
      v_linha := '<vFCPST>0.00</vFCPST>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      /*
      <vFCPSTRet>0.00</vFCPSTRet>
      */
      v_linha := '<vFCPSTRet>0.00</vFCPSTRet>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      <vProd>10475.00</vProd>               
      */
      /*if rg_opr.complemento = 'N' then*/
      v_linha := '<vProd>' || trim(replace(to_char(nvl(rg_nf.vl_produtos,
                                                       0),
                                                   '9999999999990D00'),
                                           ',',
                                           '.')) || '</vProd>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      <vFrete>0.00</vFrete>
      */
      v_linha := '<vFrete>' || trim(replace(to_char(nvl(rg_nf.vl_frete,
                                                        0),
                                                    '9999999999990D00'),
                                            ',',
                                            '.')) || '</vFrete>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      /*
      <vSeg>0.00</vSeg>
      */
      v_linha := '<vSeg>' || trim(replace(to_char(nvl(rg_nf.vl_seguro,
                                                      0),
                                                  '9999999999990D00'),
                                          ',',
                                          '.')) || '</vSeg>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      <vDesc>0.00</vDesc>
      */
      v_linha := '<vDesc>' || trim(replace(to_char(nvl(rg_nf.vl_desconto,
                                                       0),
                                                   '9999999999990D00'),
                                           ',',
                                           '.')) || '</vDesc>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      <vII>0.00</vII>
      */
      v_linha := '<vII>0.00</vII>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      <vIPI>0.00</vIPI>
      */
      v_linha := '<vIPI>' || trim(replace(to_char(nvl(rg_nf.vl_ipi,
                                                      0),
                                                  '9999999999990D00'),
                                          ',',
                                          '.')) || '</vIPI>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      <vIPIDevol>0.00</vIPIDevol>
      */
      v_linha := '<vIPIDevol>' || trim(replace(to_char(nvl(rg_nf.vl_ipi,
                                                           0),
                                                       '9999999999990D00'),
                                               ',',
                                               '.')) || '</vIPIDevol>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      <vPIS>172.84</vPIS>
      */
      v_linha := '<vPIS>' || trim(replace(to_char(nvl(rg_nf.vl_pis,
                                                      0),
                                                  '9999999999990D00'),
                                          ',',
                                          '.')) || '</vPIS>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      <vCOFINS>796.10</vCOFINS>   
      */
      v_linha := '<vCOFINS>' || trim(replace(to_char(nvl(rg_nf.vl_cofins,
                                                         0),
                                                     '9999999999990D00'),
                                             ',',
                                             '.')) || '</vCOFINS>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      <vOutro>0.00</vOutro>
      */
      v_linha := '<vOutro>' || trim(replace(to_char(nvl(rg_nf.vl_outros,
                                                        0),
                                                    '9999999999990D00'),
                                            ',',
                                            '.')) || '</vOutro>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      <vNF>10475.00</vNF>
      */
      v_linha := '<vNF>' || trim(replace(to_char(nvl(rg_nf.vl_total,
                                                     0),
                                                 '9999999999990D00'),
                                         ',',
                                         '.')) || '</vNF>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      /*
      <vTotTrib>0.00</vTotTrib>
      */
      v_linha := '<vTotTrib>0.00</vTotTrib>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      /*
      </ICMSTot>
      */
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
   
      if rg_nf.cod_transp is not null then
      
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
   
      if rg_nf.placa_veic is not null and
         rg_nf.placa_uf is not null then
         v_linha := '<veicTransp>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      
         v_linha := '<placa>' || upper(replace(replace(rg_nf.placa_veic,
                                                       '-',
                                                       ''),
                                               ' ',
                                               '')) || '</placa>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      
         v_linha := '<UF>' || rg_nf.placa_uf || '</UF>';
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
      /*
      v_linha := '<volItem>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
       */
      v_linha := '<qVol>' || nvl(rg_nf.vol_qtd,
                                 1) || '</qVol>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      if rg_nf.vol_especie is not null then
         v_linha := '<esp>' || rg_nf.vol_especie || '</esp>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      if rg_nf.vol_marca is not null then
         v_linha := '<marca>' || rg_nf.vol_marca || '</marca>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      if rg_nf.vol_numero is not null then
         v_linha := '<nVol>' || rg_nf.vol_numero || '</nVol>';
         v_ordem := v_ordem + 1;
         insert into t_nfe
         values
            (v_ordem
            ,v_linha);
      end if;
   
      v_linha := '<pesoL>' || trim(replace(to_char(nvl(rg_nf.peso_liquido,
                                                       0),
                                                   '9999999999990D000'),
                                           ',',
                                           '.')) || '</pesoL>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_linha := '<pesoB>' || trim(replace(to_char(nvl(rg_nf.peso_bruto,
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
      open cr_ptem;
      fetch cr_ptem
         into v_temparc;
      close cr_ptem;
   
      --02/0/2018 if v_atl_crec = 'S' and v_temparc = 'S' then
      /*
      <cobr>      
      */
      v_linha := '<cobr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      <fat>      
      */
      v_linha := '<fat>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      <nFat>6601</nFat>
      */
      v_linha := '<nFat>' || rg_nf.num_nota || '</nFat>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      <vOrig>21906.80</vOrig>
      */
      v_linha := '<vOrig>' || trim(replace(to_char(nvl(rg_nf.vl_total,
                                                       0),
                                                   '9999999999990D00'),
                                           ',',
                                           '.')) || '</vOrig>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      <vLiq>21906.80</vLiq>
      */
      v_linha := '<vLiq>' || trim(replace(to_char(nvl(rg_nf.vl_total,
                                                      0),
                                                  '9999999999990D00'),
                                          ',',
                                          '.')) || '</vLiq>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      </fat>
      */
      v_linha := '</fat>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_item := 0;
      --02/0/2018 
      if v_atl_crec = 'S' and
         v_temparc = 'S' then
        /*
        <dup>
        */
        v_linha := '<dup>';
        v_ordem := v_ordem + 1;
        insert into t_nfe
        values
           (v_ordem
           ,v_linha);
                  
         for rgi in cr_p loop
         
            v_item := v_item + 1;
            /*
            <nDup>001</nDup>         
            */
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
         
         end loop;
         /*
         '</dup>'         
        */
        v_linha := '</dup>';
        v_ordem := v_ordem + 1;
        insert into t_nfe
        values
          (v_ordem
          ,v_linha);
      end if;

        
      /*
      '</cobr>'         
      */
      v_linha := '</cobr>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
        (v_ordem
        ,v_linha);  
         
      /*
      <pag> Grupo obrigatório para NF-e e NFC-e.
            Para as notas com finalidade de Ajuste ou Devolução 
            o campo Forma de Pagamento deve ser preenchido com '90=Sem pagamento'.
      */
      v_linha := '<pag>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*                
      <detPag>
      */
      v_linha := '<detPag>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*                
      <indPag>1</indPag>
      0-Pagamento à Vista
      1-Pagamento à Prazo
      */
      if nvl(v_item,
             0) > 0 then
         v_indpag := '1';
      else
         v_indpag := '0';
      end if;
   
      v_linha := '<indPag>' || v_indpag || '</indPag>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*               
      <tPag>99</tPag>
      01-Dinheiro;
      02-Cheque;
      03-Cartão de Crédito;
      04-Cartão de Débito;
      05-Crédito Loja;
      10-Vale Alimentação;
      11-Vale Refeição;
      12-Vale Presente;
      13-Vale Combustível;
      15-Boleto bancário;
      90-Sem pagamento;
      99-Outros.
      */
   
      if nvl(v_item,
             0) > 0 then
         v_tpag := '99';
      else
         v_tpag := '90';
      end if;
      v_linha := '<tPag>' || v_tpag || '</tPag>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*                 
      <vPag>10475.00</vPag>
      */
   
      v_linha := '<vPag>' || 0 || '</vPag>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*
      </detPag>
      */
      v_linha := '</detPag>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
      /*                
      </pag>
      */
      v_linha := '</pag>';
      v_ordem := v_ordem + 1;
      insert into t_nfe
      values
         (v_ordem
         ,v_linha);
   
      v_msg := null;
      for rgi in cr_m loop
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
   
      --/ assinatura: somente para importar no sistema do fisco
   
      v_ordem := v_ordem + 1;
      --gerar_assinatura(v_ordem, g_chave_completa);
   
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

   procedure xml(pp_emp ft_notas.empresa%type
                ,pp_fil ft_notas.filial%type
                ,pp_nro ft_notas.num_nota%type
                ,pp_ser ft_notas.sr_nota%type
                ,pp_id  ft_notas.id%type
                ,pp_amb char)
   
    is
      v_versao varchar2(20);
   begin
      /*
      if user = 'GESTAO2' then
         v_versao := '4.0';
      else
         v_versao := '3.1'; --'4.0';
      end if;
      */
      v_versao := '4.0';
      if v_versao = '3.1' then
         xml_31(pp_emp,
                pp_fil,
                pp_nro,
                pp_ser,
                pp_id,
                pp_amb);
      elsif v_versao = '4.0' then
         xml_40(pp_emp,
                pp_fil,
                pp_nro,
                pp_ser,
                pp_id,
                pp_amb);
      else
         xml_20(pp_emp,
                pp_fil,
                pp_nro,
                pp_ser,
                pp_id,
                pp_amb);
      end if;
   end;
   --------------------------------------------------------------------------------
   function modulo11(pc_chave varchar2) return char
   
    is
      v_dv   number;
      v_soma number;
      v_mult number;
   
   begin
   
      v_soma := 0;
      v_mult := 2;
      for i in reverse 1 .. length(pc_chave) loop
         v_soma := v_soma + (substr(pc_chave,
                                    i,
                                    1) * v_mult);
         v_mult := v_mult + 1;
         if v_mult > 9 then
            v_mult := 2;
         end if;
      end loop;
   
      v_dv := 11 - mod(v_soma,
                       11);
      if v_dv >= 10 then
         return '0';
      else
         return to_char(v_dv);
      end if;
   
   end;

   --------------------------------------------------------------------------------
   function chave_nfe(p_firma         cd_firmas.firma%type
                     ,p_num_nota      ce_notas.num_nota%type
                     ,p_sr_nota       ce_notas.sr_nota%type
                     ,p_emis          date
                     ,p_tipo_nota     char
                     ,p_forma_emissao ft_num_nota.forma_emis_nfe%type)
      return varchar2 is
      /*
      Chave de Acesso da NF-e
      A partir da vers?o 2.00 do leiaute da NF-e, o campo
      tpEmis (forma de emiss?o da NF-e) passou a compor a chave de acesso da seguinte forma:
      
      |==========|================|=================|========|=======|===============|========================|================|====|
      |CodigodaUF| AAMM_daemiss?o | CNPJ_doEmitente | Modelo | Serie | Numeroda_NF-e | forma_deemiss?oda_NF-e | CodigoNumerico | DV |
      |   02     |      04        |     14          | 02     | 03    |  09           | 01                     |    08          | 01 |
      |==========|================|=================|========|=======|===============|========================|================|====|
      
      O tamanho do campo
      cNF- codigo numerico da NF-e foi reduzido para oito posic?es
      para n?o alterar o tamanho da chave de acesso da NF-e de 44
      posic?es que passa ser composta pelos seguintes campos que se encontram dispersos na NF-e :
      
      cUF    - Codigo da UF do emitente do Documento Fiscal
      AAMM   - Ano e Mes de emiss?o da NF-e
      CNPJ   - CNPJ do emitente
      mod    - Modelo do Documento Fiscal
      serie  - Serie do Documento Fiscal
      nNF    - Numero do Documento Fiscal
      tpEmis ? forma de emiss?o da NF-e
      cNF    - Codigo Numerico que comp?e a Chave de Acesso
      cDV    - Digito Verificador da Chave de Acesso
               O Digito Verificador (DV) ira garantir a integridade da chave de acesso, protegendo-aprincipalmente contra digitac?es erradas.
               CALCULO DO DIGITO VERIFICADOR DA CHAVE DE ACESSO DA NF-e
               O digito verificador da chave de acesso da NF-e e baseado em um calculo domodulo 11. O modulo 11 de um numero
               e calculado multiplicando-se cada algarismo pelasequencia de multiplicadores 2,3,4,5,6,7,8,9,2,3, ...
               posicionados da direita para a esquerda.A somatoria dos resultados das ponderac?es dos algarismos
               e dividida por 11 e oDV (digito verificador) sera a diferenca entre o divisor (11) e o resto da divis?o:
               DV = 11 - (resto da divis?o)
               Quando o resto da divis?o for 0 (zero) ou 1 (um), o DV devera ser igual a 0 (zero).
               (a) Chave de Acesso : 3512060823678600015 25500100 00008441 09611070  dv=7
               (b) peso            : 4329876543298765432 98765432 98765432 98765432
               Exemplo: consideremos que a chave de acesso tem a seguinte sequencia de caracteres:Somatoria das ponderac?es = 653
               Dividindo a somatoria das ponderac?es por 11 teremos, 653 /11 = 59
               restando 4.Como o digito verificador DV = 11 - (resto da divis?o), portando 11 - 4 = 7
               Neste caso o DV da chave de acesso da NF-e e igual a "7",
               valor este que devera compor achave de acesso totalizando a uma sequencia de 44 caracteres.
      */
      /*
      cUF - Código da UF do emitente do Documento Fiscal;
      AAMM - Ano e Mês de emissão da NF-e;
      CNPJ - CNPJ do emitente;
      mod - Modelo do Documento Fiscal;
      serie - Série do Documento Fiscal;
      nNF - Número do Documento Fiscal;
      tpEmis – forma de emissão da NF-e;
      cNF - Código Numérico que compõe a Chave de Acesso;
      cDV - Dígito Verificador da Chave de Acesso.
      
      */
      vt_dig      dbms_sql.number_table;
      v_nome_base varchar2(50) :=   --'3512060823678600015255001000000844109611070';
       '3512070823678600015255001000000859109611070';
      --v_cont         number(6) := 0;
      --/
      v_cuf        varchar2(2);
      v_aamm       varchar2(4);
      v_cnpj       varchar2(14);
      v_mod        varchar2(2);
      v_serie      varchar2(3);
      v_numero     varchar2(9);
      v_forma_emis varchar2(1);
      v_codigo     varchar2(8);
      v_dv         varchar2(1);
      --/
      v_ret   varchar2(100);
      v_mod11 varchar2(1);
   
   begin
   
      v_cuf        := lpad(cd_firmas_utl.uf_ibge(p_firma),
                           2,
                           '0');
      v_aamm       := to_char(p_emis,
                              'rrmm');
      v_cnpj       := lib_util.somente_numero(cd_firmas_utl.cgc_cpf(p_firma));
      v_mod        := lpad(p_tipo_nota,
                           2,
                           '0');
      v_serie      := lpad(p_sr_nota,
                           3,
                           '0');
      v_numero     := lpad(p_num_nota,
                           9,
                           '0');
      v_forma_emis := p_forma_emissao;
      v_codigo     := lpad(p_num_nota,
                           8,
                           '0');
   
      --/ monta nome base
      v_nome_base := v_cuf || v_aamm || v_cnpj || v_mod || v_serie || v_numero ||
                     v_forma_emis || v_codigo;
   
      --/ calcula digito verificador
      v_mod11 := modulo11(v_nome_base);
   
      --/monta chave
      v_ret := v_nome_base || v_mod11;
   
      v_ret := v_ret || '-nfe.xml';
   
      return v_ret;
   
   end;

   --------------------------------------------------------------------------------------
   function criar_arquivo_ini return varchar2 is
      v_ret varchar2(32000);
   begin
      v_ret := '
[Identificacao]
    NaturezaOperacao=VENDA PRODUCAO DO ESTAB.
    Modelo=55
    Serie=1
    Codigo=18
    Numero=18
    Serie=1
    Emissao=24/03/2009
    Saida=24/03/2009
    Tipo=1
    FormaPag=0
    Finalidade=0
[Emitente]
    CNPJ=
    IE=
    Razao=
    Fantasia=
    Fone=
    CEP=
    Logradouro=
    Numero=
    Complemento=
    Bairro=
    CidadeCod=
    Cidade=
    UF=
    *PaisCod=
    *Pais=
[Destinatario]
    CNPJ=
    IE=
    *ISUF=
    NomeRazao=
    Fone=
    CEP=
    Logradouro=
    Numero=
    Complemento=
    Bairro=
    CidadeCod=
    Cidade=
    UF=
    *PaisCod=
    *Pais=
[Produto001]
    CFOP=
    Codigo=
    Descricao=
    *EAN=
    *NCM=
    Unidade=
    Quantidade=
    ValorUnitario=
    ValorTotal=
    *ValorDesconto=
    *NumeroDI=
    *DataRegistroDI=
    *LocalDesembaraco=
    *UFDesembaraco=
    *DataDesembaraco=
    *CodigoExportador=
    *[LADI001001]
        *NumeroAdicao=
        *CodigoFrabricante=
        *DescontoADI
    [ICMS001]
        CST=00
        *Origem=
        *Modalidade=
        *ValorBase=
        *Aliquota=
        *Valor=
        *ModalidadeST=
        *PercentualMargemST=
        *PercentualReducaoST=
        *ValorBaseST=
        *AliquotaST=
        *ValorST=
        *PercentualReducao=
    *[IPI001]
        *CST=
        *ClasseEnquadramento=
        *CNPJProdutor=
        *CodigoSeloIPI=
        *QuantidadeSelos=
        *CodigoEnquadramento=
        *ValorBase=
        *Quantidade=
        *ValorUnidade=
        *Aliquota=
        *Valor
    *[II001]
        *ValorBase=
        *ValorDespAduaneiras=
        *ValorII=
        *ValorIOF=
    *[PIS001]
        *CST=
        *ValorBase=
        *Aliquota=
        *Valor=
        *Quantidade=
        *TipoCalculo=
    *[PISST001]
        *ValorBase=
        *AliquotaPerc=
        *Quantidade=
        *AliquotaValor=
        *ValorPISST=
    *[COFINS001]
        *CST=
        *ValorBase=
        *Aliquota=
        *Valor=
        *TipoCalculo=
        *Quantidade=
    *[COFINSST001]
        *ValorBase=
        *AliquotaPerc=
        *Quantidade=
        *AliquotaValor=
        *ValorCOFINSST=
[Total]
    BaseICMS=
    ValorICMS=
    ValorProduto=
    *BaseICMSSubstituicao=
    *ValorICMSSubstituicao=
    *ValorFrete=
    *ValorSeguro=
    *ValorDesconto=
    *ValorII=
    *ValorIPI=
    *ValorPIS=
    *ValorCOFINS=
    *ValorOutrasDespesas=
    ValorNota=
*[Transportador]
    *FretePorConta=
    *CnpjCpf=
    *NomeRazao=
    *IE=
    *Endereco=
    *Cidade=
    *UF=
    *ValorServico=
    *ValorBase=
    *Aliquota=
    *Valor=
    *CFOP=
    *CidadeCod=
    *Placa=
    *UFPlaca=
    *RNTC=
*[Volume001]
    *Quantidade=
    *Especie=
    *Marca=
    *Numeracao=
    *PesoLiquido=
    *PesoBruto=
*[Fatura]
    *Numero=
    *ValorOriginal=
    *ValorDesconto=
    *ValorLiquido=
    *[Duplicata001]
        *Numero=
        *DataVencimento=
        *Valor=
*[DadosAdicionais]
    *Complemento=
*[InfAdic001]
    *Campo=
    *Texto=
';
      return null;
   end;

   procedure gerar_assinatura(p_nro number, p_chave_completa varchar2) is
   
      v_assinatura varchar2(32000) := '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/><SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/><Reference URI="#'||p_chave_completa||'"><Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/><Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/></Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/><DigestValue>W4Y4or8W6yPpuKkX+9pHVF1esQk=</DigestValue></Reference></SignedInfo><SignatureValue>MFg+z/79/AIajNc4W0HJG5ls2F6jQoZuripbXi8n8LQMrWVi7b9p3i9Yf629AOJWe2DGC+oHWHun
CH463xlHvlryjU8bPZ9H5kkdcTeWnCiK12T4xrVlh+S31tacp1CZxcruF1e3YKmcFvN6flQef0Sj
PLo/TPv+1WKCDUH6K7aecaeqNNy5I91CJFzZuf2rZGeuF4hReaK6JPTRROoeoX1wIDnLEIuXwlZP
zR3hq1MgQrOgiy5l6wUZoJ+0qoBgOcZ7lBzULTnM9kYKrFjmUkZPEQ1qY/XV3eyuF/Hd6dojz80M
cNIQI0je5AizUi3d76Lf53pkiDMu+6tDYWRBDQ==</SignatureValue><KeyInfo><X509Data><X509Certificate>MIIIGTCCBgGgAwIBAgIIFQFtz+YKXfEwDQYJKoZIhvcNAQELBQAwcTELMAkGA1UEBhMCQlIxEzAR
BgNVBAoTCklDUC1CcmFzaWwxNjA0BgNVBAsTLVNlY3JldGFyaWEgZGEgUmVjZWl0YSBGZWRlcmFs
IGRvIEJyYXNpbCAtIFJGQjEVMBMGA1UEAxMMQUMgVkFMSUQgUkZCMB4XDTE4MDgwMjE0NTYzMloX
DTE5MDgwMjE0NTYzMlowgfMxCzAJBgNVBAYTAkJSMQswCQYDVQQIEwJTUDEUMBIGA1UEBxMLU0VS
VEFPWklOSE8xEzARBgNVBAoTCklDUC1CcmFzaWwxNjA0BgNVBAsTLVNlY3JldGFyaWEgZGEgUmVj
ZWl0YSBGZWRlcmFsIGRvIEJyYXNpbCAtIFJGQjEWMBQGA1UECxMNUkZCIGUtQ05QSiBBMTEdMBsG
A1UECxMUQVIgVFVBTEFORyBDT1dPUktJTkcxPTA7BgNVBAMTNFNFUk1BU0EgRVFVSVBBTUVOVE9T
IElORFVTVFJJQUlTIExUREE6MDgyMzY3ODYwMDAxNTIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
ggEKAoIBAQC//1XiHlOTFe67Ay/QeMQMR2W4QF/zwQt9Ydxo0CDn7bIQLwxs5PVPad/80I1lrvGr
HP7rKVjMv/SqI+HSM4F/JQiQDiockINsTe6YO5LSyJNSFFQsJso+1V5sH+D7rsUpHKh365ljWSJL
MWJnh/xGuW1GKw8To2ZPzkpKqGAYhRcS2gX3viE8SN3Wj8q5BJlO15SDovWzUoDXsYxZdanIQa2G
KPeLKJzf7xFkaQsFSU21jRCUc0fXS45FdF6SJ95t7tBpQqBDeJ8nwQfBP3i0rRFlqkSRgtM8g+HK
revnfl1ffPf1+XExbtxk+IwULcieDUGJszBNf4KaXSobDjx9AgMBAAGjggMwMIIDLDCBmgYIKwYB
BQUHAQEEgY0wgYowVQYIKwYBBQUHMAKGSWh0dHA6Ly9pY3AtYnJhc2lsLnZhbGlkY2VydGlmaWNh
ZG9yYS5jb20uYnIvYWMtdmFsaWRyZmIvYWMtdmFsaWRyZmJ2Mi5wN2IwMQYIKwYBBQUHMAGGJWh0
dHA6Ly9vY3NwLnZhbGlkY2VydGlmaWNhZG9yYS5jb20uYnIwCQYDVR0TBAIwADAfBgNVHSMEGDAW
gBRHuQhZ2EL2kvz3fBV8JoBKRZF+nzBuBgNVHSAEZzBlMGMGBmBMAQIBJTBZMFcGCCsGAQUFBwIB
FktodHRwOi8vaWNwLWJyYXNpbC52YWxpZGNlcnRpZmljYWRvcmEuY29tLmJyL2FjLXZhbGlkcmZi
L2RwYy1hYy12YWxpZHJmYi5wZGYwggEBBgNVHR8EgfkwgfYwU6BRoE+GTWh0dHA6Ly9pY3AtYnJh
c2lsLnZhbGlkY2VydGlmaWNhZG9yYS5jb20uYnIvYWMtdmFsaWRyZmIvbGNyLWFjLXZhbGlkcmZi
djIuY3JsMFSgUqBQhk5odHRwOi8vaWNwLWJyYXNpbDIudmFsaWRjZXJ0aWZpY2Fkb3JhLmNvbS5i
ci9hYy12YWxpZHJmYi9sY3ItYWMtdmFsaWRyZmJ2Mi5jcmwwSaBHoEWGQ2h0dHA6Ly9yZXBvc2l0
b3Jpby5pY3BicmFzaWwuZ292LmJyL2xjci9WQUxJRC9sY3ItYWMtdmFsaWRyZmJ2Mi5jcmwwDgYD
VR0PAQH/BAQDAgXgMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcDBDCBvAYDVR0RBIG0MIGx
gRt3YWduZXIuc2lsdmFAc2VybWFzYS5jb20uYnKgOAYFYEwBAwSgLwQtMTUwNjE5NDY1NTA5NDI4
NzgzNDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwoCQGBWBMAQMCoBsEGUdJTEJFUlRPIERFIFBB
VUxBIFNBTlRPUk+gGQYFYEwBAwOgEAQOMDgyMzY3ODYwMDAxNTKgFwYFYEwBAwegDgQMMDAwMDAw
MDAwMDAwMA0GCSqGSIb3DQEBCwUAA4ICAQBwJVmbG9H0wqFgt+slY+llT9m0x2xVZMIeF/ypV5ww
H0OFbiXMxbOeu/Wi+2WdyXodpbpFK8WcxuZfzthex1FeGyd+Dp3NoUfNs9QpI/vDFaPisbJh+KTu
ka5+jazqHcIAaDXQO3t1QP0n/bN+iHju8MMMyqyJYjcL0/PlRo0dQ3l0BdR8FAPf/SveNW0WbSsB
i9JNMgcoZJVgBDpxcTqY/xMDzjaMre/3I4EF0D1gsjsiEipemHnFmlp/rUvuuCSLXX9oWuvozoJ5
vhC3zCIv8P6Xde1SR8vCYBOZ5AfKDcLcaGSu8GjTSvWxuK03fg3geOMedOpqAxo6+JMT92BRtuEh
XzieBZNTDV6j5nFSRIDl8Z99xYL1PcTYV+O3vVR3lUkR376FzLlo9qAEs9z0nCrkcwmFxi7Im1C+
dXa9ya+ZzD5oPoDDQnQsumQrLUYgRl+JZYe0erSMaiyEQ6GZ6lQhU3KRRO6p+8+54jqH03RYgySS
oCpuDTwJ6Sy16dU5Z72hZzKMTmIe3pQpGMxdKHq1XCxdkeeQJN4TqcamtCMUv94QoRfQsElbV6G5
64fA6+W9EOMVzcMA7jkWrtOlwFChOT1Ns4DWXrw6MwyuUr5J/F6BOo7GSBpT+yvBN0o6qajwHdf+
dlVlHMd1P/NjRz/HbvQQSBZW9IErl7BRZg==</X509Certificate></X509Data></KeyInfo></Signature>';
   begin
      insert into t_nfe
      values
         (p_nro
         ,v_assinatura);
   end;
end cd_nfe_utl;
/
