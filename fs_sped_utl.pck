create or replace package fs_sped_utl is

   --------------------------------------------------------------------------------------
   --|| fs_sped_utl : Remessa de do arquivo - Especificacao
   --------------------------------------------------------------------------------------

   subtype tnum is number;
   subtype tvalor2 is number(14,
                             2);
   subtype tvalor4 is number(16,
                             4);
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
   subtype tnum2 is number(2);
   subtype tnum4 is number(4);
   subtype tcurs is pls_integer;
   subtype tint is pls_integer;
   subtype tid is number(9);

   type trec_imp is record(
       aliquota   number
      ,base_calc  number(18, 2)
      ,base_sub   number(18, 2)
      ,valor_00   number(18, 2)
      ,valor_10   number(18, 2)
      ,valor_20   number(18, 2)
      ,valor_30   number(18, 2)
      ,valor_40   number(18, 2)
      ,valor_41   number(18, 2)
      ,valor_50   number(18, 2)
      ,valor_51   number(18, 2)
      ,valor_60   number(18, 2)
      ,valor_70   number(18, 2)
      ,valor_90   number(18, 2)
      ,vl_st      number(18, 2)
      ,vlr_dipi   number(18, 2)
      ,vlr_contab number(18, 2));
   --/
   function fb_fone(p_firma cd_firmas.firma%type
                   ,p_tipo  cd_fones.tipo_fone%type) return varchar2;
   --
   function fb_ident_prod(p_emp ce_produtos.empresa%type
                         ,p_prd ce_produtos.produto%type)
      return fs_ident_item.genero%type;
   --
   function fb_gen_prod(p_emp ce_produtos.empresa%type
                       ,p_prd ce_produtos.produto%type)
      return fs_genero_mercadoria.cod_gen%type;
   --
   function fb_cod_lst_prod(p_emp ce_produtos.empresa%type
                           ,p_prd ce_produtos.produto%type)
      return fs_lista_serv.codigo%type;
   --
   function fb_situacao_docto(p_cfo ft_cfo.cod_cfo%type
                             ,p_sit in ft_notas.status%type)
      return fs_situacao_doc.codigo%type;
   --
   function fb_cd_doctos(p_doc fn_tipos_doc.tipo_doc%type)
      return fn_tipos_doc.cd_doctosac%type;
   --
   function fb_ind_pgto(p_cond ft_condpag.cod_condpag%type)
      return ft_condpag.a_vista%type;
   --
   function fb_ind_frt(p_sit ft_notas.tp_frete%type) return varchar2;
   --
   function fb_cod_inf(p_emp   ft_notas.empresa%type
                      ,p_prd   ce_produtos.produto%type
                      ,p_cfo   ft_cfo.cod_cfo%type
                      ,p_uf_nt ce_notas.uf_nota%type) return varchar2;
   --
   function fb_ind_tit(p_tp fn_tipos_tit.tipo_tit%type) return varchar2;
   --
   function fb_calcula_tributos(p_imp       in fs_itens_livro.tip_imposto%type
                               ,p_emp       in cd_empresas.empresa%type
                               ,p_fil       in cd_filiais.filial%type
                               ,p_firma     in cd_firmas.firma%type
                               ,p_tip_livro in fs_itens_livro.tip_livro%type
                               ,p_num_docto in fs_itens_livro.num_docto%type
                               ,p_ser_docto in fs_itens_livro.ser_docto%type
                               ,p_tip_docto in fs_itens_livro.tip_docto%type
                               ,p_nat_oper  in fs_itens_livro.nat_oper%type
                               ,p_dt        in date
                               ,p_recval    out trec_imp) return number;

   --
   function fb_sit_tributaria(p_tp ce_itens_nf.cod_tribut%type) return varchar2;
   --
   function fb_conta_frete(p_emp cd_empresas.empresa%type) return varchar2;
   --
   function fb_aliq_pis return ft_prgen.aliq_pis%type;

   function fb_aliq_cofins return ft_prgen.aliq_cofins%type;
   --
   function fb_cod_apuracao(p_uf   cd_uf.uf%type
                           ,p_apur tnum1
                           ,p_util tnum1) return tstr8;

   function fb_split_texto(p_texto tstr1000
                          ,p_sep   tstr10
                          ,p_pos   tnum4) return tstr1000;
   --/----------------------------------------------------------
   function fb_produto_sped(emp cd_filiais.empresa%type
                           ,fil cd_filiais.filial%type
                           ,prod ce_produtos.produto%type
                           ,p_ini date
                           ,p_fim date
                           ) return char;
   --------------------------------------------------------------------------------------
   --------------------------------------------------------------------------------------
   procedure processa(p_emp   in cd_empresas.empresa%type
                     ,p_fil   in cd_filiais.filial%type
                     ,p_firma in cd_firmas.firma%type
                     ,p_cod   in fs_versoes_ac.codigo%type
                     ,p_fin   in fs_finalid_ac.codigo%type
                     ,p_din   in date
                     ,p_dfi   in date
                     ,p_seq   in number
                     ,p_aplic in fs_versoes_ac.aplicacao%type);

   ----------------------------------------------------------------------------------------------------------------------------------------

   procedure lcm_op(p_emp pp_desenho.empresa%type
                   ,p_fil pp_desenho.filial%type
                   ,p_ano tnum4
                   ,p_mes tnum2
                   ,p_ord pp_ordens.ordem%type
                   ,p_des pp_desenho.desenho%type
                   ,p_ver pp_desenho_ver.versao%type);

--------------------------------------------------------------------------------------
end fs_sped_utl;
/
create or replace package body fs_sped_utl is

   --------------------------------------------------------------------------------------
   --|| fs_sped_utl : Remessa de do arquivo - Corpo do Pacote
   --------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------
   --/ FUNCOES
   -----------------------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------
   function fb_fone(p_firma cd_firmas.firma%type
                   ,p_tipo  cd_fones.tipo_fone%type) return varchar2 is
      cursor crfone is
         select replace(replace(replace(replace(trim(ddd) || trim(fone),
                                                '-',
                                                ''),
                                        ')',
                                        ''),
                                '.',
                                ''),
                        '(',
                        '') fone
           from cd_fones
          where firma = p_firma
            and tipo_fone like p_tipo;
   
      v_ret varchar2(20);
   begin
   
      v_ret := null;
   
      if p_tipo = 'FONE' then
         v_ret := replace(replace(replace(replace(replace(cd_firmas_utl.fone(p_firma),
                                                          '-',
                                                          ''),
                                                  ')',
                                                  ''),
                                          '.',
                                          ''),
                                  '(',
                                  ''),
                          ' ',
                          '');
      else
         open crfone;
         fetch crfone
            into v_ret;
         close crfone;
      end if;
   
      return v_ret;
   end;

   -----------------------------------------------------------------------------------------------------------------
   function fb_ident_prod(p_emp ce_produtos.empresa%type
                         ,p_prd ce_produtos.produto%type)
      return fs_ident_item.genero%type is
      cursor cr is
         select genero
           from fs_ident_prd
          where produto = p_prd
            and empresa = p_emp;
   
      cursor cr2(p_gr ce_produtos.grupo%type) is
         select genero
           from fs_ident_grp
          where empresa = p_emp
            and grupo = p_gr;
   
      v_ret fs_ident_item.genero%type;
      n_Niv number(4);
      v_grupo ce_produtos.grupo%type;
      v_gr_niv number(4);
      
   begin
      v_ret := null;
      open cr;
      fetch cr into v_ret;
      close cr;
      if v_ret is null then
          -- Niveis do grupo
          v_grupo := ce_produtos_utl.Grupo(p_emp, p_prd);
          n_Niv := Lib_Cniv.Nivel(v_grupo);
          --| Para todos os niveis do grupo, comecando com o menor
          For n In Reverse 1 .. n_Niv Loop
             -- Acha o codigo neste nivel
             v_gr_niv := Lib_Cniv.Cod_Nivel(v_Grupo, n);
             
             Open Cr2(v_gr_niv);
             Fetch Cr2 Into v_ret;
             Close Cr2;

             Exit When v_ret Is Not Null;
          End Loop;
      end if;

   
      return v_ret;
   end;
   -----------------------------------------------------------------------------------------------------------------
   function fb_gen_prod(p_emp ce_produtos.empresa%type
                       ,p_prd ce_produtos.produto%type)
      return fs_genero_mercadoria.cod_gen%type is
      cursor cr is
         select cod_gen
           from ce_produtos a
               ,ft_clafis   b
          where a.empresa = p_emp
            and a.produto = p_prd
            and b.cod_clafis = a.cod_clafis;
   
      v_ret fs_genero_mercadoria.cod_gen%type;
   
   begin
      v_ret := null;
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   end;
   --------------------------------------------------------------------------------------
   function fb_cod_lst_prod(p_emp ce_produtos.empresa%type
                           ,p_prd ce_produtos.produto%type)
      return fs_lista_serv.codigo%type is
      cursor cr is
         select codigo
           from fs_lista_serv_prd
          where produto = p_prd
            and empresa = p_emp;
   
      cursor cr2 is
         select codigo
           from fs_lista_serv_grp
          where empresa = p_emp
            and lib_cniv.sub_nivel(grupo,
                                   ce_produtos_utl.cod_grupo(p_emp,
                                                             p_prd)) = 'S';
   
      v_ret fs_lista_serv.codigo%type;
   
   begin
      v_ret := null;
      open cr;
      fetch cr
         into v_ret;
      if cr%notfound then
      
         open cr2;
         fetch cr2
            into v_ret;
         close cr2;
      
      end if;
      close cr;
   
      return v_ret;
   end;
   --------------------------------------------------------------------------------------
   function fb_cd_doctos(p_doc in fn_tipos_doc.tipo_doc%type)
      return fn_tipos_doc.cd_doctosac%type is
      cursor cr is
         select cd_doctosac from fn_tipos_doc where tipo_doc = p_doc;
   
      v_ret fn_tipos_doc.cd_doctosac%type;
   
   begin
      v_ret := null;
      --/
      open cr;
      fetch cr
         into v_ret;
      if cr%notfound then
         v_ret := p_doc;
      end if;
      close cr;
      --/
      return v_ret;
   end;

   --/
   --------------------------------------------------------------------------------------
   function fb_situacao_docto(p_cfo in ft_cfo.cod_cfo%type
                             ,p_sit in ft_notas.status%type)
      return fs_situacao_doc.codigo%type is
   
      cursor cr is
         select a.codigo
           from fs_situacao_doc      a
               ,fs_situacao_doc_cfop b
          where a.codigo = b.codigo
            and b.cfop = p_cfo;
   
      cursor cr2(p_base ft_cfo.cod_cfo%type) is
         select a.codigo
           from fs_situacao_doc      a
               ,fs_situacao_doc_cfop b
          where a.codigo = b.codigo
            and b.cfop like p_base
            and b.base = 'S';
   
      v_ret fs_situacao_doc.codigo%type;
   
   begin
      /*
      4.1.2. Tabela Situac?o do Documento
      Codigo  Descric?o
      00  Documento regular
      01  Documento regular extemporaneo
      02  Documento cancelado
      03  Documento cancelado extemporaneo
      04  NFe denegada
      05  Nfe - Numerac?o inutilizada
      06  Documento Fiscal Complementar
      07  Documento Fiscal Complementar extemporaneo.
      08  Documento Fiscal emitido com base em Regime Especial ou Norma Especifica
      */
      if p_sit = 'C' then
         v_ret := '02';
      else
         open cr;
         fetch cr
            into v_ret;
         if cr%notfound then
            open cr2(substr(p_cfo,
                            1,
                            4) || '%');
            fetch cr2
               into v_ret;
            close cr2;
         end if;
         close cr;
      end if;
   
      if v_ret is null then
         v_ret := '00';
      end if;
   
      return v_ret;
   end;
   --/
   --------------------------------------------------------------------------------------
   function fb_ind_pgto(p_cond ft_condpag.cod_condpag%type)
      return ft_condpag.a_vista%type is
      /*
        0. A vista;
        1. A prazo;
        9. Sem pagamento.
      */
      cursor cr is
         select a_vista from ft_condpag where cod_condpag = p_cond;
   
      v_ret varchar2(1);
      v_aux varchar2(1);
   begin
   
      v_ret := '9';
   
      open cr;
      fetch cr
         into v_aux;
      close cr;
   
      if v_aux = 'N' then
         v_ret := '1';
      elsif v_aux = 'S' then
         v_ret := '0';
      end if;
   
      return v_ret;
   
   end;
   --/
   --------------------------------------------------------------------------------------
   function fb_ind_frt(p_sit ft_notas.tp_frete%type) return varchar2 is
      /*
        0. Por conta de terceiros;
        1. Por conta do emitente;
        2. Por conta do destinatario;
        9. Sem frete
      */
   
      v_ret varchar2(1);
   
   begin
      if p_sit in ('R',
                   'A',
                   'D') then
         v_ret := '2';
      elsif p_sit = 'N' then
         v_ret := '9';
      elsif p_sit = 'E' then
         v_ret := '1';
      else
         v_ret := '9';
      end if;
      --/
      return v_ret;
      --/
   end;
   --------------------------------------------------------------------------------------
   function fb_cod_inf(p_emp   ft_notas.empresa%type
                      ,p_prd   ce_produtos.produto%type
                      ,p_cfo   ft_cfo.cod_cfo%type
                      ,p_uf_nt ce_notas.uf_nota%type) return varchar2 is
      cursor cr is
         select to_char(a.cod_msg)
           from ft_icms_msg a
               ,ft_icms_ctl b
          where a.cod_icms = a.cod_icms
            and b.produto = p_prd
            and b.empresa = p_emp;
   
      v_ret varchar2(10);
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   end;
   --------------------------------------------------------------------------------------
   function fb_ind_tit(p_tp fn_tipos_tit.tipo_tit%type) return varchar2 is
      /*
        00- Duplicata;
        01- Cheque;
        02- Promissoria;
        03- Recibo;
        99- Outros (descrever)
      */
      v_ret varchar2(2);
   begin
   
      if p_tp = 1 then
         v_ret := '00';
      elsif p_tp in (7,
                     43,
                     49) then
         v_ret := '01';
      elsif p_tp in (2) then
         v_ret := '02';
      elsif p_tp in (5) then
         v_ret := '03';
      else
         v_ret := '99';
      end if;
   
      return v_ret;
   
   end;
   -------------------------------------------------------------------------------------
   function fb_calcula_tributos(p_imp       in fs_itens_livro.tip_imposto%type
                               ,p_emp       in cd_empresas.empresa%type
                               ,p_fil       in cd_filiais.filial%type
                               ,p_firma     in cd_firmas.firma%type
                               ,p_tip_livro in fs_itens_livro.tip_livro%type
                               ,p_num_docto in fs_itens_livro.num_docto%type
                               ,p_ser_docto in fs_itens_livro.ser_docto%type
                               ,p_tip_docto in fs_itens_livro.tip_docto%type
                               ,p_nat_oper  in fs_itens_livro.nat_oper%type
                               ,p_dt        in date
                               ,p_recval    out trec_imp) return number is
      v_recval trec_imp;
      cursor cr is
         select *
           from fs_itens_livro a
          where a.empresa = p_emp
            and a.filial = p_fil
            and a.firma = p_firma
            and a.tip_livro = p_tip_livro
            and a.num_docto = p_num_docto
            and a.ser_docto = p_ser_docto
            and a.tip_docto = p_tip_docto
            and a.nat_oper = p_nat_oper
            and a.dt_entsai = p_dt
            and a.tip_imposto = p_imp;
   
   begin
      p_recval := v_recval;
      return 0;
      /*
      Exception
        when others then
           return 1;
      */
   end;
   --------------------------------------------------------------------------------------
   function fb_sit_tributaria(p_tp ce_itens_nf.cod_tribut%type) return varchar2 is
      v_ret ce_itens_nf.cod_tribut%type;
   begin
      --implementar aqui
      v_ret := p_tp;
      --/
      return v_ret;
   end;

   --------------------------------------------------------------------------------------
   function fb_conta_frete(p_emp cd_empresas.empresa%type) return varchar2 is
      cursor cr is
         select conta_frete from fs_ent_ac70 where empresa = p_emp;
   
      v_ret cg_plano.cod_conta%type;
      --/
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
      --/
      return v_ret;
   end;
   --------------------------------------------------------------------------------------

   function fb_aliq_pis return ft_prgen.aliq_pis%type is
      cursor cr is
         select aliq_pis from ft_prgen;
   
      v_ret ft_prgen.aliq_pis%type;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      if nvl(v_ret,
             0) = 0 then
         v_ret := 1.65;
      end if;
   
      return v_ret;
   
   end;
   --------------------------------------------------------------------------------------

   function fb_aliq_cofins return ft_prgen.aliq_cofins%type is
      cursor cr is
         select aliq_cofins from ft_prgen;
   
      v_ret ft_prgen.aliq_cofins%type;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      if nvl(v_ret,
             0) = 0 then
         v_ret := 7.6;
      end if;
   
      return v_ret;
   
   end;
   --/----------------------------------------------------------
   function fb_produto_sped(emp cd_filiais.empresa%type
                           ,fil cd_filiais.filial%type
                           ,prod ce_produtos.produto%type
                           ,p_ini date
                           ,p_fim date
                           ) return char is
   cursor cr is
    select 'S'
      from ce_movest m
     where m.empresa = emp
       and m.filial = fil
       and m.produto = prod
       and m.dt_mov between p_ini and p_fim
       and rownum = 1;
       
   v_ret char(1) := 'N';
   begin
     --/ verifica se tem saldo maior que zero     
      if round(CE_SALDO_UTL.SALDO_FISICO(emp,
                                             fil,
                                             prod,
                                             p_fim),
                   3) > 0 then
                   v_ret := 'S';
       end if;
               
     --/ verifica se tem saldo inicial maior que zero                   
     if v_ret = 'N' then
        if round(CE_SALDO_UTL.SALDO_FISICO(emp,
                                             fil,
                                             prod,
                                             p_ini-1),
                   3) > 0 then
            v_ret := 'S';
         end if;
     end if;
     --/ verifica se teve movimento no periodo
     if v_ret = 'N' then
       open cr;
       fetch cr into v_ret;
        close cr;
     end if;
     return v_ret;
   end;
     
   --------------------------------------------------------------------------------------
   function fb_cod_apuracao(p_uf   cd_uf.uf%type
                           ,p_apur tnum1
                           ,p_util tnum1) return tstr8 is
      /*
      Regras de formac?o do Codigo de Ajuste da Apurac?o do ICMS:
      O Codigo do Ajuste da Apurac?o (Oito caracteres) identificara a unidade da federac?o criadora do codigo,
        a identificac?o do campo a ser ajustado na apurac?o do ICMS e codigo da descric?o da ocorrencia,
        e obedecera a seguinte estrutura:
      1. Os dois primeiros caracteres (UF) referem-se a unidade da federac?o do estabelecimento;
      2. O caracter seguinte refere-se a apurac?o propria ou da substituic?o tributaria, onde:
      0 - ICMS e
      1 - ICMS ST.
      3. O quarto caracter refere-se a UTILIZAC?O e identificara o campo a ser ajustado:
      0 - Outros debitos;
      1 - Estorno de creditos;
      2 - Outros creditos;
      3 - Estorno de debitos;
      4 - Deduc?es do imposto apurado.
      4. Os quatro caracteres seguintes, SEQUENCIA, iniciando-se por 0001 devera ser referente a identificac?o
         do tipo de ajuste deixando sempre um codigo generico para a possibilidade de outras ocorrencias n?o previstas.
      UF  Apurac?o  Utilizac?o  Sequencia
      AC  0   0. Outros Debitos   0001
      AC  1   1. Estorno de credito   0001
      AC  0   2. Outros creditos  0001 (motivo a)
      AC  0   2. Outros creditos  0002 (motivo b) apurac?o da Substituic?o Tributaria
      AC  1   2. Outros creditos  0001 (motivo c)
      AC  1   3. Estorno de debito  0001
      AC  0   4. Deduc?es   0001
      Ex.: Codigo SC110001- Codigo criado pelo estado de Santa Catarina e
                            refere-se a apurac?o da Substituic?o Tributaria, Estorno de creditos, e descric?o de ajuste 0001.
      Obs.: Caso a UF n?o disponibilize a Tabela de Ajuste referida acima, o
             contribuinte podera utilizar a tabela abaixo, inserindo como campo SEQUENCIA a express?o 9999,
             para efetuar os ajustes necessarios a apurac?o do tributo, utilizando obrigatoriamente o
             campo descric?o complementar do ajuste para descrever o motivo do ajuste.
      Codigo  Descric?o
      XX009999  Outros debitos para ajuste de apurac?o ICMS para a UF XX;
      XX109999  Outros debitos para ajuste de apurac?o ICMS ST para a UF XX;
      XX019999  Estorno de creditos para ajuste de apurac?o ICMS para a UF XX;
      XX119999  Estorno de creditos para ajuste de apurac?o ICMS ST para a UF XX;
      XX029999  Outros creditos para ajuste de apurac?o ICMS para a UF XX;
      XX129999  Outros creditos para ajuste de apurac?o ICMS ST para a UF XX;
      XX039999  Estorno de debitos para ajuste de apurac?o ICMS para a UF XX;
      XX139999  Estorno de debitos para ajuste de apurac?o ICMS ST para a UF XX;
      XX049999  Deduc?es do imposto apurado na apurac?o ICMS para a UF XX;
      XX149999  Deduc?es do imposto apurado na apurac?o ICMS ST para a UF XX.
      */
   
      v_ret tstr8;
      v_seq varchar2(4) := '9999';
   begin
   
      v_ret := p_uf || p_apur || p_util || v_seq;
   
      return v_ret;
   
   end;

   --------------------------------------------------------------------------------------
   --------------------------------------------------------------------------------------
   -- PROCEDIMENTOS
   --------------------------------------------------------------------------------------
   --------------------------------------------------------------------------------------
   procedure processa(p_emp   in cd_empresas.empresa%type
                     ,p_fil   in cd_filiais.filial%type
                     ,p_firma in cd_firmas.firma%type
                     ,p_cod   in fs_versoes_ac.codigo%type
                     ,p_fin   in fs_finalid_ac.codigo%type
                     ,p_din   in date
                     ,p_dfi   in date
                     ,p_seq   in number
                     ,p_aplic in fs_versoes_ac.aplicacao%type)
   /*
      || gera arquivo
      */
    is
   
      v_comando varchar2(1000);
      v_err     varchar2(100);
   begin
   
      if p_aplic = 'EFD' then
         v_comando := 'begin fs_sped_efd.fs_sped_' || rtrim(p_cod) ||
                      '(:p1, :p2, :p3, :p4, :p5, :p6, :p7, :p8, :p9); end;';
      elsif p_aplic = 'ECD' then
         v_comando := 'begin fs_sped_ecd.fs_cotepe_' || rtrim(p_cod) ||
                      '(:p1, :p2, :p3, :p4, :p5, :p6, :p7, :p8, :p9); end;';
      end if;
   
      execute immediate v_comando
         using p_emp, p_fil, p_firma, p_cod, p_fin, trunc(p_din), trunc(p_dfi), p_seq, p_aplic;
   
   exception
   
      when others then
         rollback;
         v_err := p_aplic || '-' || substr(sqlerrm,
                                           1,
                                           90);
         raise_application_error(-20001,
                                 v_err);
      
   end;

   ----------------------------------------------------------------------------------------------------------------------------------------
   procedure lcm_op(p_emp pp_desenho.empresa%type
                   ,p_fil pp_desenho.filial%type
                   ,p_ano tnum4
                   ,p_mes tnum2
                   ,p_ord pp_ordens.ordem%type
                   ,p_des pp_desenho.desenho%type
                   ,p_ver pp_desenho_ver.versao%type)
   /*
      || Gera tabela temporaria para lista de componentes e materiais por op
      */
    is
   
      cursor cr0(p_ini date
                ,p_fim date) is
         select e.ordem
               ,p.desenho
               ,v.versao
               ,e.qtde quantidade
               ,p.descricao
               ,v.id_desenhover
           from pp_desenho     p
               ,pp_desenho_est e
               ,pp_desenho_ver v
         
          where p.empresa = e.empresa
            and p.filial = e.filial
            and p.id_desenho = v.id_desenho
            and e.id_desenhover = v.id_desenhover
            and e.empresa = p_emp
            and e.filial = p_fil
            and v.versao = (select max(v2.versao)
                              from pp_desenho_est ed2
                                  ,pp_desenho_ver v2
                             where ed2.empresa = e.empresa --/ 19/11/2007 incluido para pegar somente a maior versao
                               and ed2.filial = e.filial
                               and ed2.id_desenhover = v2.id_desenhover
                               and v2.id_desenho = p.id_desenho
                               and ed2.ordem = e.ordem)
            and (p_des is null or p.desenho = p_des)
            and (p_ver is null or v.versao = p_ver)
            and (p_ord is null or e.ordem = p_ord)
            and e.ordem in
                (select o.ordem
                   from vce_produto_elab o
                  where e.ordem = o.ordem
                    and e.empresa = o.empresa
                    and e.filial = o.filial
                    and o.data_elab between p_ini and p_fim);
   
      --     Order By 1,2;
   
      cursor cr1(pc_des    pp_desenho.desenho%type
                ,pc_ver    pp_desenho_ver.versao%type
                ,pc_id_ver pp_desenho_ver.id_desenhover%type) is
      /*
          select
              rpad(' ',level*3)||' '|| desenho   desenho2,
              sys_connect_by_path(desenho||'*'||versao|| '*'||lpad(posicao,3,'0') , '/')  path ,
               posicao,
               tp_posicao tp,
               descricao ,
               quantidade,
               pos_produto,
               pos_desenho,
               pos_versao ,
               case
                 when pos_produto is not null then
                  substr(ce_produtos_utl.descricao(empresa, pos_produto),1,100)
                else
                  null
                end descr_prod
      
          from pp_desenho_pos p
          start with p.desenho||p.versao = pc_des||pv_ver
            and p.empresa  = p_emp
            and p.filial   = p_fil
          connect by prior p.pos_desenho = p.desenho
            and p.versao = (select max(p2.versao)
                        from pp_desenho_pos p2
                        where p2.empresa =p.empresa
                         and p2.filial  = p.filial
                         and p2.desenho = p.desenho);
      */
         select p.*
               ,
                
                d.desenho
               ,v.versao
           from pp_desenho_pos p
               ,pp_desenho_ver v
               ,pp_desenho     d
          where p.empresa = p_emp
            and d.filial = p_fil
            and
               
                (pc_des is null or d.desenho = pc_des)
            and (pc_ver is null or v.versao = pc_ver)
            and (pc_id_ver is null or v.id_desenhover = pc_id_ver)
            and
               
                v.id_desenhover = p.id_desenhover
            and d.id_desenho = v.id_desenho
          order by d.desenho
                  ,v.versao
                  ,p.posicao;
   
      cursor cr2(pc_des    pp_desenho.desenho%type
                ,pc_ver    pp_desenho_ver.versao%type
                ,pc_id_ver pp_desenho_ver.id_desenhover%type) is
         select d.descricao
           from pp_desenho     d
               ,pp_desenho_ver v
          where d.empresa = p_emp
            and d.filial = p_fil
            and (pc_des is null or d.desenho = pc_des)
            and (pc_ver is null or v.versao = pc_ver)
            and (pc_id_ver is null or v.id_desenhover = pc_id_ver)
            and v.id_desenho = d.id_desenho;
   
      cursor cr3(pc_pro ce_produtos.produto%type) is
         select descricao
           from ce_produtos
          where empresa = p_emp
            and produto = pc_pro;
   
      cursor cr4 is
         select *
           from t_lcm4
          where processou = 'N'
          order by ordem
                  ,nivel
            for update;
   
      v_descricao   pp_desenho.descricao%type;
      v_cont        number;
      v_nivel       number;
      v_nivel2      t_lcm.nivel%type;
      v_cont_nivel  number;
      v_desenho_ant pp_desenho.desenho%type;
      v_idx         number;
      v_msg         varchar2(1000);
      v_ini         date;
      v_fim         date;
   begin
   
      --| Limpar Tabelas
      delete t_lcm_op;
      delete t_lcm4;
      v_ini := to_date('01/' || p_mes || '/' || p_ano,
                       'dd/mm/rrrr');
      v_fim := last_day(v_ini);
      --| Para todos os itens do desenho Chamado
      v_nivel := 0;
      v_idx   := 0;
      for reg0 in cr0(v_ini,
                      v_fim) loop
         v_idx := v_idx + 1;
         v_msg := 'LCM_OP_TIT: inicio cursor cr2';
      
         open cr2(reg0.desenho,
                  reg0.versao,
                  reg0.id_desenhover);
         fetch cr2
            into v_descricao;
         close cr2;
      
         v_msg := 'LCM_OP: insert t_lcm_op ';
         -- Item da Lista
      
         insert into t_lcm_op
            (ordem
            ,nivel
            ,posicao
            ,desenho
            ,produto
            ,descricao
            ,desc_compl
            ,quantidade
            ,comprimento
            ,largura
            ,peso_unit
            ,peso_total
            ,unidade
            ,nivel2
            ,versao
            ,desenho_01
            ,versao_01)
         values
            (reg0.ordem
            ,substr(trim(to_char(1000 + v_idx)),
                    -3) || '0000'
            ,0
            ,reg0.desenho
            ,null
            ,substr(reg0.descricao,
                    1,
                    50)
            ,substr(v_descricao,
                    1,
                    50)
            ,reg0.quantidade
            ,null
            ,null
            ,null
            ,null
            ,'CJ'
            ,0
            ,reg0.versao
            , --reg.versao
             null
            , --reg0.desenho,
             null --reg.versao
             );
         v_msg := 'LCM_OP:  cursor cr1 ';
         for reg in cr1(reg0.desenho,
                        reg0.versao,
                        reg0.id_desenhover) loop
            if reg0.desenho <> v_desenho_ant or
               v_desenho_ant is null then
               v_desenho_ant := reg0.desenho;
               v_nivel       := 1;
            else
               v_nivel := v_nivel + 1;
            end if;
         
            --| Descricao do Desenho/Material
            v_descricao := null;
            v_msg       := 'LCM_OP:  descricao do desenho/material';
         
            if reg.tp_posicao = 'D' then
               open cr2(null,
                        null,
                        reg.id_desenhover);
               fetch cr2
                  into v_descricao;
               close cr2;
            else
               open cr3(reg.pos_produto);
               fetch cr3
                  into v_descricao;
               close cr3;
            end if;
         
            v_msg := 'LCM_OP:  item da lista';
            -- Item da Lista
            insert into t_lcm_op
               (ordem
               ,nivel
               ,posicao
               ,desenho
               ,produto
               ,descricao
               ,desc_compl
               ,quantidade
               ,comprimento
               ,largura
               ,peso_unit
               ,peso_total
               ,unidade
               ,nivel2
               ,versao
               ,desenho_01
               ,versao_01
               ,peso_acabado_unit
               ,peso_acabado_total
               ,peso_unit_ac
               ,peso_total_ac
               ,peso_acabado_unit_ac
               ,peso_acabado_total_ac)
            values
               (reg0.ordem
               ,substr(trim(to_char(1000 + v_idx)),
                       -3) || substr(trim(to_char(10000 + v_nivel)),
                                     -4) || '-'
               ,reg.posicao
               ,reg.desenho
               ,reg.pos_produto
               ,substr(reg.descricao,
                       1,
                       50)
               ,substr(v_descricao,
                       1,
                       50)
               ,(reg.quantidade * reg0.quantidade)
               ,reg.comprimento
               ,reg.largura
               ,
                --reg.PESO_ACABADO_UNIT,
                (reg.peso_total / reg.quantidade)
               ,(reg.peso_total) * (reg0.quantidade)
               ,reg.unid_pos
               ,1
               ,reg.versao
               , --reg.VERSAO
                reg0.desenho
               ,reg0.versao
               ,(reg.peso_acabado_total / reg.quantidade)
               ,(reg.peso_acabado_total) * (reg0.quantidade)
               ,(reg.peso_total_ac / reg.quantidade)
               ,(reg.peso_total_ac) * (reg0.quantidade)
               ,(reg.peso_acabado_total_ac / reg.quantidade)
               ,(reg.peso_acabado_total_ac) * (reg0.quantidade)
                
                );
         
            -- Desenho Temporario
            v_msg := 'LCM_OP:  desenho temporario';
            if reg.tp_posicao = 'D' then
               insert into t_lcm4
               values
                  (reg.desenho
                  ,reg.versao
                  ,'N'
                  ,substr(trim(to_char(1000 + v_idx)),
                          -3) || substr(trim(to_char(10000 + v_nivel)),
                                        -4) || '-'
                  ,reg0.ordem
                  ,reg0.quantidade
                  ,reg.id_desenhover);
            end if;
         
         end loop;
      end loop;
   
      
   exception
      when others then
         raise_application_error(-20100,
                                 'fs_sped_utl.lcm_op:' ||
                                 substr(sqlerrm,
                                        1,
                                        80));
   end;
   --|-------------------------------------------------------
   function fb_split_texto(p_texto tstr1000
                          ,p_sep   tstr10
                          ,p_pos   tnum4) return tstr1000 is
      v_ret   varchar2(1000);
      v_aux   varchar2(1000);
      v_i     number(4);
      v_conta number(4) := 0;
      v_fim   number(4);
      
   begin
      v_aux := p_texto;
      loop
      
         if v_conta = p_pos then
            exit;
         end if;
         v_fim :=  nvl(instr(v_aux,
                                 p_sep) + 1,0);
         v_aux   := substr(v_aux,
                          v_fim);
         v_conta := v_conta + 1;
      
      end loop;
      v_ret := substr(v_aux,
                      1,
                      instr(v_aux,
                            p_sep) - 1);
   
      return v_ret;
   
   end;
   --------------------------------------------------------------------------------------
end fs_sped_utl;
/
