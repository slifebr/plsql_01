CREATE OR REPLACE PACKAGE ft_nf IS

   --||
   --|| FT_NF.PKS : Pacote para geracao de notas fiscais (Especificacao)
   --||

   --/ variaveis globais
   vg_custo_med NUMBER(15,
                       2);
   --/

   TYPE comp_nota_t IS RECORD(
      cod_transp    ft_notas.cod_transp%TYPE,
      motorista     ft_notas.motorista%TYPE,
      cpf_mot       ft_notas.cpf_mot%TYPE,
      placa_veic    ft_notas.placa_veic%TYPE,
      placa_uf      ft_notas.placa_uf%TYPE,
      vol_qtd       ft_notas.vol_qtd%TYPE,
      vol_especie   ft_notas.vol_especie%TYPE,
      vol_marca     ft_notas.vol_marca%TYPE,
      vol_numero    ft_notas.vol_numero%TYPE,
      peso_liquido  ft_notas.peso_liquido%TYPE,
      peso_bruto    ft_notas.peso_bruto%TYPE,
      tp_frete      ft_notas.tp_frete%TYPE,
      vl_frete      ft_notas.vl_frete%TYPE,
      vl_embalagem  ft_notas.vl_embalagem%TYPE,
      vl_seguro     ft_notas.vl_seguro%TYPE,
      local_sai     ce_locest.LOCAL%TYPE,
      local_ent     ce_locest.LOCAL%TYPE,
      obs_titulo    ft_pedidos.obs_titulo%TYPE,
      num_exped     ft_exped.num_exped%TYPE,
      vl_frete_au   ft_notas.vl_frete%TYPE,
      msg_adicional ft_msgs_nf.mensagem%TYPE,
      frete_bicms   ft_notas.frete_bicms%TYPE);

   TYPE resultado_t IS RECORD(
      numero_inicial ft_notas.num_nota%TYPE,
      numero_final   ft_notas.num_nota%TYPE,
      titulo_inicial fn_ctrec.num_titulo%TYPE,
      titulo_final   fn_ctrec.num_titulo%TYPE,
      lote_cont      cg_lancto.lote%TYPE,
      erro_cont      NUMBER,
      livro          BOOLEAN,
      nr_cont        NUMBER,
      nr_livro       NUMBER,
      erro_livro     VARCHAR2(100),
      erro_cont2     NUMBER,
      lote_cont2     cg_lancto.lote%TYPE);

   PROCEDURE grava_reg_nf(nf ft_notas%ROWTYPE);
   PROCEDURE data_saida(dat DATE);
   FUNCTION tipo_nf(emp IN ft_notas.empresa%TYPE,
                    fil IN ft_notas.filial%TYPE,
                    opr IN ft_notas.cod_oper%TYPE) RETURN NUMBER;
   FUNCTION tipo_exped(emp IN ft_exped.empresa%TYPE,
                       fil IN ft_exped.filial%TYPE,
                       num IN ft_exped.num_exped%TYPE) RETURN NUMBER;
   FUNCTION tipo_lote(emp IN ft_pedidos.empresa%TYPE,
                      fil IN ft_pedidos.filial%TYPE,
                      nlt IN ft_pedidos.lote%TYPE) RETURN NUMBER;
                      
   --------------------------------------------------------------------------------
   PROCEDURE crec_nf(emp     IN ft_notas.empresa%TYPE,
                     fil     IN ft_notas.filial%TYPE,
                     num     IN ft_notas.num_nota%TYPE,
                     ser     IN ft_notas.sr_nota%TYPE,
                     reg_ped IN ft_pedidos%ROWTYPE);
   --------------------------------------------------------------------------------
   PROCEDURE transporte_nf( emp  IN ft_notas.empresa%TYPE,
                            fil  IN ft_notas.filial%TYPE,
                            num  IN ft_notas.num_nota%TYPE,
                            ser  IN ft_notas.sr_nota%TYPE);
   --------------------------------------------------------------------------------
                                           
   FUNCTION contab_nf(emp IN ft_notas.empresa%TYPE,
                      fil IN ft_notas.filial%TYPE,
                      num IN ft_notas.num_nota%TYPE,
                      ser IN ft_notas.sr_nota%TYPE,
                      par IN ft_notas.parte%TYPE,
                      aut IN CHAR := 'S') RETURN NUMBER;

   PROCEDURE grava_comp(rt comp_nota_t);
   FUNCTION le_resultado RETURN resultado_t;
   FUNCTION checa_param(emp IN ft_pedidos.empresa%TYPE,
                        fil IN ft_pedidos.filial%TYPE) RETURN NUMBER;
   PROCEDURE cria_nota(emp IN ft_pedidos.empresa%TYPE,
                       fil IN ft_pedidos.filial%TYPE,
                       num IN ft_pedidos.num_pedido%TYPE,
                       dta IN DATE,
                       com IN BOOLEAN := FALSE,
                       tmp IN NUMBER := 0,
                       ger IN BOOLEAN := TRUE);
   PROCEDURE fatura_exped(emp IN ft_exped.empresa%TYPE,
                          fil IN ft_exped.filial%TYPE,
                          num IN ft_exped.num_exped%TYPE,
                          dta IN DATE,
                          com IN BOOLEAN);
   PROCEDURE fatura_lote(emp IN ft_pedidos.empresa%TYPE,
                         fil IN ft_pedidos.filial%TYPE,
                         num IN ft_pedidos.lote%TYPE,
                         dta IN DATE,
                         com IN BOOLEAN);
   PROCEDURE emb_etiq(p_item ft_roman_etiq.seq_rom%TYPE,
                      p_seq  ft_roman_etiq.item_rom_seq%TYPE);
   FUNCTION valor_ipi(emp fs_itens_livro.empresa%TYPE,
                      fil fs_itens_livro.filial%TYPE,
                      tip fs_itens_livro.tip_livro%TYPE,
                      num fs_itens_livro.num_docto%TYPE,
                      ser fs_itens_livro.ser_docto%TYPE,
                      tpd fs_itens_livro.tip_docto%TYPE,
                      fir fs_itens_livro.firma%TYPE,
                      nat fs_itens_livro.nat_oper%TYPE,
                      ali fs_itens_livro.aliquota%TYPE,
                      imp fs_itens_livro.tip_imposto%TYPE) RETURN NUMBER;
   --------------------------------------------------------------------------------
   FUNCTION  monta_descr_prod(p_descr  ft_itens_ped.descricao%type
                             ,p_unid   ft_itens_ped.uni_ven%type
                             ,p_qtd_pc ft_itens_ped.qtd_pc%type
                             ,p_comp   ft_itens_ped.comp%type
                             ,p_larg   ft_itens_ped.larg%type
                             ,p_qtd    ft_itens_ped.qtd_ped%type
                             ) return ft_itens_ped.descricao%type;
END ft_nf;
/
CREATE OR REPLACE PACKAGE BODY ft_nf IS

   --||
   --|| FT_NF.PKB : Pacote para geracao de notas fiscais
   --||

   --------------------------------------------------------------------------------
   /*
   || Variaveis globais
   */

   comp_nota    comp_nota_t;
   resultado    resultado_t;
   g_data_saida DATE;
   g_dev        CHAR(1) := 'N';
   g_dias_mais  NUMBER;

   --------------------------------------------------------------------------------
   /*
   || Rotinas internas
   */
   --------------------------------------------------------------------------------
   FUNCTION prx_dia(p_data DATE,
                    p_d1   ft_condpag.dia1%TYPE,
                    p_d2   ft_condpag.dia1%TYPE,
                    p_d3   ft_condpag.dia1%TYPE) RETURN DATE
   /*
      || Retorna data alterada pelos dias da cond.pagamento
      */
    IS

      v_data DATE;
      v_d    CHAR(1);
      v_n    NUMBER;

   BEGIN

      -- Se todas as dias da cond.pagto sao nulas retorna a propria data
      IF p_d1 IS NULL
         AND p_d2 IS NULL
         AND p_d3 IS NULL THEN
         RETURN p_data;
      END IF;

      -- Se um dos dias ja for da propria data, retorna a mesma
      v_d := to_char(p_data,
                     'D');
      IF (p_d1 IS NOT NULL AND v_d = p_d1)
         OR (p_d2 IS NOT NULL AND v_d = p_d2)
         OR (p_d3 IS NOT NULL AND v_d = p_d3) THEN
         RETURN p_data;
      END IF;
      v_n    := 0;
      v_data := p_data;

      -- Vai incrementado a data (ate 7 vezes) ate achar uma que corresponda
      --
      LOOP
         v_data := v_data + 1;
         v_d    := to_char(v_data,
                           'D');
         IF (p_d1 IS NOT NULL AND v_d = p_d1)
            OR (p_d2 IS NOT NULL AND v_d = p_d2)
            OR (p_d3 IS NOT NULL AND v_d = p_d3) THEN
            v_n := 0;
            EXIT;
         END IF;
         v_n := v_n + 1;
         IF v_n > 7 THEN
            EXIT;
         END IF;
      END LOOP;

      -- Achou uma data
      IF v_n = 0 THEN
         RETURN v_data;
      END IF;

      -- Retorna a mesma
      RETURN p_data;

   END;

   --------------------------------------------------------------------------------
   FUNCTION sub_msgs(v_h ft_msgs_nf.mensagem%TYPE,
                     emp ft_notas.empresa%TYPE,
                     fil ft_notas.filial%TYPE,
                     num ft_notas.num_nota%TYPE,
                     ser ft_notas.sr_nota%TYPE)
      RETURN ft_msgs_nf.mensagem%TYPE
   /*
      || Substituicoes nas mensagens
      */
    IS

      CURSOR cr_nf IS
         SELECT *
           FROM ft_notas
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = num
            AND sr_nota = ser;
      reg_nf  ft_notas%ROWTYPE;
      reg_nfo ft_notas%ROWTYPE;

      CURSOR cr_i IS
         SELECT *
           FROM ft_itens_nf
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = num
            AND sr_nota = ser;
      CURSOR cr_o IS
         SELECT DISTINCT empresa,
                         fil_origem,
                         doc_origem,
                         ser_origem
           FROM ft_itens_nf
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = num
            AND sr_nota = ser
            AND ser_origem IS NOT NULL;

      v_his      VARCHAR2(4000);
      n          NUMBER;
      nh         NUMBER;
      reg_fir    cd_firmas%ROWTYPE;
      v_tot1     NUMBER;
      v_tot2     NUMBER;
      v_desc     NUMBER;
      v_pdes     NUMBER;
      v_nfo      VARCHAR2(4000);
      v_dto      VARCHAR2(4000);
      v_vlo      VARCHAR2(4000);
      v_ico      VARCHAR2(4000);
      v_st       VARCHAR2(4000);
      v_c        VARCHAR2(3);
      v_cid      cd_cidades.cidade%TYPE;
      v_clo      ft_notas.firma%TYPE;
      v_eno      VARCHAR2(4000);
      v_cidade_o cd_cidades.cidade%TYPE;
      v_cnpj_o   cd_firmas.cgc_cpf%TYPE;
      v_iest_o   cd_firmas.iest%TYPE;
      lumavez    BOOLEAN;

   BEGIN

      OPEN cr_nf;
      FETCH cr_nf
         INTO reg_nf;
      IF cr_nf%NOTFOUND THEN
         CLOSE cr_nf;
         RETURN v_h;
      END IF;
      CLOSE cr_nf;

      SELECT *
        INTO reg_fir
        FROM cd_firmas
       WHERE firma = reg_nf.firma;

      v_nfo      := '';
      v_dto      := '';
      v_vlo      := '';
      v_ico      := '';
      v_c        := '';
      v_clo      := NULL;
      v_eno      := '';
      v_cidade_o := '';
      lumavez    := TRUE;
      v_cnpj_o   := NULL;
      v_iest_o   := NULL;

      FOR rgo IN cr_o LOOP
         v_nfo := v_nfo || v_c || to_char(rgo.doc_origem) || '-' ||
                  rgo.ser_origem;
         BEGIN
            SELECT *
              INTO reg_nfo
              FROM ft_notas
             WHERE empresa = rgo.empresa
               AND filial = rgo.fil_origem
               AND num_nota = rgo.doc_origem
               AND sr_nota = rgo.ser_origem;
            v_dto := v_dto || v_c || to_char(reg_nfo.dt_emissao,
                                             'dd/mm/yyyy');
            v_vlo := v_vlo || v_c || to_char(reg_nfo.vl_total);
            v_ico := v_ico || v_c || to_char(reg_nfo.vl_icms);
            IF lumavez THEN
               SELECT cidade
                 INTO v_cidade_o
                 FROM cd_cidades
                WHERE cod_cidade = reg_nfo.ent_cidade;
               SELECT cgc_cpf,
                      iest
                 INTO v_cnpj_o,
                      v_iest_o
                 FROM cd_firmas
                WHERE firma = reg_nfo.firma;
               v_clo   := reg_nfo.firma;
               v_eno   := rtrim(reg_nfo.ent_ender);
               v_eno   := v_eno || ' - ' || rtrim(v_cidade_o);
               v_eno   := v_eno || ' (' || reg_nfo.ent_uf || ')';
               lumavez := FALSE;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
         v_c := ',';
      END LOOP;

      v_st := '';
      v_c  := '';

      FOR rgi IN cr_i LOOP
         IF nvl(rgi.vl_icms_sub,
                0) > 0 THEN
            v_st := v_st || v_c || to_char(rgi.produto) || ' = R$ ' ||
                    ltrim(to_char(rgi.vl_icms_sub,
                                  '999G999G990D00'));
            v_c  := ', ';
         END IF;
      END LOOP;

      IF nvl(reg_nf.vl_desconto,
             0) > 0 THEN
         v_desc := reg_nf.vl_desconto;
         v_pdes := round((reg_nf.vl_desconto /
                         (reg_nf.vl_total + reg_nf.vl_desconto)) * 100,
                         2);
      END IF;

      v_his := v_h;
      n     := instr(v_his,
                     '@');

      WHILE n > 0 LOOP

         IF lib_util.is_numeric(substr(v_his,
                                       n + 1,
                                       2)) = 'S' THEN
            nh := to_number(substr(v_his,
                                   n + 1,
                                   2));
            IF nvl(nh,
                   0) = 1 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || to_char(reg_nf.num_nota) ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 2 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) ||
                        to_char(reg_nf.dt_emissao,
                                'dd/mm/yyyy') ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 3 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) ||
                        ltrim(to_char(reg_nf.vl_total,
                                      '999G999G990D00')) ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 4 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) ||
                        ltrim(to_char(nvl(reg_nf.vl_icms,
                                          0) + nvl(reg_nf.vl_icms_pro,
                                                   0),
                                      '999G999G990D00')) ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 5 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) ||
                        ltrim(to_char(reg_nf.vl_ipi,
                                      '999G999G990D00')) ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 6 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) ||
                        ltrim(to_char(reg_nf.vl_iss,
                                      '999G999G990D00')) ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 7 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || to_char(v_desc) ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 8 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || to_char(v_pdes) ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 9 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || reg_fir.nome ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 10 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || reg_fir.cgc_cpf ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 11 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || reg_fir.iest ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 12 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || reg_fir.endereco ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 13 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || v_nfo ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 14 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || v_dto ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 15 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || v_vlo ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 16 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || v_ico ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 17 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) ||
                        ltrim(to_char(reg_nf.vl_bicms_pro,
                                      '999G999G990D00')) ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 18 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || v_st ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 19 THEN
               IF reg_nf.tp_frete = 'E' THEN
                  v_his := substr(v_his,
                                  1,
                                  n - 1) || 'CIF' ||
                           substr(v_his,
                                  n + 3);
               ELSE
                  v_his := substr(v_his,
                                  1,
                                  n - 1) || 'FOB' ||
                           substr(v_his,
                                  n + 3);
               END IF;
               n := instr(v_his,
                          '@');
            ELSIF nvl(nh,
                      0) = 20 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || reg_nf.ent_ender ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 21 THEN
               BEGIN
                  SELECT cidade
                    INTO v_cid
                    FROM cd_cidades
                   WHERE cod_cidade = reg_nf.ent_cidade;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_cid := '';
               END;
               v_his := substr(v_his,
                               1,
                               n - 1) || v_cid ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 22 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || reg_nf.ent_uf ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 23 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || reg_nf.ent_cep ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 24 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || reg_fir.cod_suframa ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 25 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) ||
                        ltrim(to_char(nvl(reg_nf.vl_icms_pro,
                                          0),
                                      '999G999G990D00')) ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 26 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || ltrim(cd_firmas_utl.nome(v_clo)) ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 27 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || ltrim(v_eno) ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 28 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || ltrim(v_cnpj_o) ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSIF nvl(nh,
                      0) = 29 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || ltrim(v_iest_o) ||
                        substr(v_his,
                               n + 3);
               n     := instr(v_his,
                              '@');
            ELSE
               v_his := substr(v_his,
                               1,
                               n - 1) || substr(v_his,
                                                n + 1);
               n     := instr(v_his,
                              '@');
            END IF;
         ELSE
            v_his := substr(v_his,
                            1,
                            n - 1) || substr(v_his,
                                             n + 1);
            n     := instr(v_his,
                           '@');
         END IF;

      END LOOP;

      v_his := rtrim(v_his);
      LOOP
         EXIT WHEN nvl(length(v_his),
                       0) = 0 OR substr(v_his,
                                        -1,
                                        1) <> chr(10);
         v_his := substr(v_his,
                         1,
                         length(v_his) - 1);
      END LOOP;

      RETURN substr(v_his,
                    1,
                    2000);

   END;

   --------------------------------------------------------------------------------
   FUNCTION chk_terc(emp t_lancto.empresa%TYPE,
                     cta t_lancto.cod_conta%TYPE,
                     ter t_lancto.cod_terceiro%TYPE,
                     ori t_lancto.origem%TYPE) RETURN NUMBER IS

      CURSOR cr_af(emp cg_lancto.empresa%TYPE, ct cg_lancto.cod_conta%TYPE) IS
         SELECT cod_afonte
           FROM cg_contas_af
          WHERE empresa = emp
            AND cod_conta = ct;

      cod_af cg_contas_af.cod_afonte%TYPE;
      tem_af BOOLEAN;
      v_num  NUMBER;

   BEGIN

      OPEN cr_af(emp,
                 cta);
      FETCH cr_af
         INTO cod_af;
      tem_af := cr_af%FOUND;
      CLOSE cr_af;

      IF tem_af THEN
         IF ter IS NULL THEN
            RETURN 4;
         END IF;
      ELSE
         IF ter IS NOT NULL THEN
            RETURN 5;
         END IF;
      END IF;

      RETURN 0;

   END;

   --------------------------------------------------------------------------------
   FUNCTION chk_lancto(v_emp t_lancto.empresa%TYPE,
                       v_lot t_lancto.lote%TYPE,
                       v_dta t_lancto.data%TYPE) RETURN NUMBER
   /*
      || Checa lancamentos do lote
      */
    IS

      v_val NUMBER;
      v_sum NUMBER;

      v_cc    cg_plano.ccusto%TYPE;
      v_ar    cg_plano.aresult%TYPE;
      v_erro  NUMBER;
      v_total NUMBER;

      CURSOR cr IS
         SELECT *
           FROM t_lancto
          WHERE empresa = v_emp
            AND lote = v_lot;
      v_ano VARCHAR2(4);
      v_mes VARCHAR2(2);

      CURSOR cr_sal(e cg_lancto.empresa%TYPE, a NUMBER) IS
         SELECT mes
           FROM cg_exerc
          WHERE empresa = e
            AND ano = a;
      v_fec NUMBER;
      dummy NUMBER;
      v_n   NUMBER;

   BEGIN

      v_ano := to_char(v_dta,
                       'YYYY');
      v_mes := to_char(v_dta,
                       'MM');

      OPEN cr_sal(v_emp,
                  v_ano);
      FETCH cr_sal
         INTO v_fec;
      IF cr_sal%NOTFOUND
         OR v_fec >= v_mes THEN
         CLOSE cr_sal;
         RETURN 5;
      END IF;
      CLOSE cr_sal;

      v_erro  := 0;
      v_total := 0;
      v_n     := 0;

      -- Verifica apropriacoes em c.custo e a.resultados
      FOR reg IN cr LOOP

         SELECT ccusto,
                aresult
           INTO v_cc,
                v_ar
           FROM cg_plano
          WHERE empresa = reg.empresa
            AND cod_conta = reg.cod_conta;
         IF v_cc = 'S' THEN
            SELECT SUM(valor)
              INTO v_sum
              FROM t_lancto_cc
             WHERE empresa = reg.empresa
               AND seq_lancto = reg.seq_lancto;
            IF nvl(v_sum,
                   0) <> reg.valor THEN
               IF nvl(v_sum,
                      0) = 0 THEN
                  v_erro := 1;
               ELSE
                  v_erro := 2;
               END IF;
               EXIT;
            END IF;
         END IF;

         IF v_ar = 'S' THEN
            SELECT SUM(valor)
              INTO v_sum
              FROM t_lancto_ar
             WHERE empresa = reg.empresa
               AND seq_lancto = reg.seq_lancto;
            IF nvl(v_sum,
                   0) <> 0
               AND nvl(v_sum,
                       0) <> reg.valor THEN
               v_erro := 3;
               EXIT;
            END IF;
         END IF;

         IF reg.natureza = 'D' THEN
            v_total := v_total + reg.valor;
         ELSE
            v_total := v_total - reg.valor;
         END IF;

         v_erro := chk_terc(reg.empresa,
                            reg.cod_conta,
                            reg.cod_terceiro,
                            reg.origem);
         EXIT WHEN v_erro > 0;

         v_n := v_n + 1;
      END LOOP;

      IF v_erro > 0 THEN
         RETURN v_erro;
      END IF;
      IF v_total <> 0 THEN
         RETURN 4;
      END IF;
      IF v_n = 0 THEN
         RETURN 7;
      END IF;

      RETURN 0;

   END;

   --------------------------------------------------------------------------------
   FUNCTION custo_pro(reg_oper ft_oper%ROWTYPE,
                      reg      ft_notas%ROWTYPE,
                      rgi      ft_itens_nf%ROWTYPE) RETURN NUMBER
   /*
      || Calcula custo para estoque
      */

    IS

      CURSOR cr_no(sq ft_itens_nf.seq_item%TYPE) IS
         SELECT seq_movest1
           FROM ft_itens_nf
          WHERE seq_item = sq;

      CURSOR cr_mvs(seq ce_movest.seq_mov%TYPE) IS
         SELECT round(vlr_tot_mov / qtde_mov,
                      2) custo
           FROM ce_movest
          WHERE seq_mov = seq
            AND nvl(qtde_mov,
                    0) <> 0;

      CURSOR cr_cst(emp ce_saldo.empresa%TYPE, fil ce_saldo.filial%TYPE, pro ce_saldo.produto%TYPE) IS
         SELECT *
           FROM ce_saldo
          WHERE empresa = emp
            AND filial = fil
            AND produto = pro
          ORDER BY empresa,
                   filial,
                   produto,
                   dt_saldo DESC;
      reg_cst ce_saldo%ROWTYPE;

      v_custo      NUMBER;
      v_seq_movest NUMBER;
      v_aux varchar2(100);
   BEGIN

      --| se for saida pegar o ultimo custo do produto
      IF reg_oper.natureza = 'S' THEN

         --| Se devolucao a fornecedor sai com custo original
         IF reg_oper.devolucao = 'S'
            AND nvl(rgi.seq_origem,
                    0) > 0 THEN
v_aux := 'custo_pro:01';
            SELECT seq_mov
              INTO v_seq_movest
              FROM ce_itens_nf
             WHERE ID = rgi.seq_origem;
v_aux := 'custo_pro:02';
         begin
            SELECT nvl(vlr_tot_mov,
                       0) / nvl(qtde_mov,
                                1)
              INTO v_custo
              FROM ce_movest
             WHERE seq_mov = v_seq_movest
               AND nvl(qtde_mov,
                       0) <> 0;
         exception
           when others then
               v_custo := 0;
         end;
v_aux := 'custo_pro:03';
            --| Saida pelo custo atual
         ELSE

            OPEN cr_cst(rgi.empresa,
                        rgi.filial,
                        rgi.produto);
            FETCH cr_cst
               INTO reg_cst;
            IF cr_cst%NOTFOUND
               OR nvl(reg_cst.saldo_fisico,
                      0) = 0 THEN
               CLOSE cr_cst;
v_aux := 'custo_pro:04';               
               v_custo := ce_unid_utl.fator(rgi.uni_val,
                                            rgi.uni_est) * rgi.valor_unit;
            ELSE
               CLOSE cr_cst;
v_aux := 'custo_pro:05';
               v_custo := round(reg_cst.custo_medio,
                                2);
            END IF;

         END IF;
v_aux := 'custo_pro:06';
         --| Se for entrada (devolucao) buscar o custo que o produto saiu (de ce_movest)
      ELSE
v_aux := 'custo_pro:07';
         OPEN cr_no(rgi.seq_origem);
         FETCH cr_no
            INTO v_seq_movest;
         IF cr_no%FOUND THEN
v_aux := 'custo_pro:08';           
            OPEN cr_mvs(v_seq_movest);
            FETCH cr_mvs
               INTO v_custo;
            CLOSE cr_mvs;
         ELSE
v_aux := 'custo_pro:09';           
            v_custo := ce_unid_utl.fator(rgi.uni_val,
                                         rgi.uni_est) * rgi.valor_unit;
         END IF;
         CLOSE cr_no;
      END IF;
v_aux := 'custo_pro:10';
      RETURN v_custo;
   exception
     when others then
       raise_application_error(-20100,v_aux||'-'||substr(sqlerrm,1,100));
   END;

   --------------------------------------------------------------------------------
   PROCEDURE grava_nf(emp IN ft_pedidos.empresa%TYPE,
                      fil IN ft_pedidos.filial%TYPE,
                      num IN ft_pedidos.num_pedido%TYPE,
                      dta IN DATE,
                      nnf IN OUT ft_notas.num_nota%TYPE,
                      ser IN OUT ft_notas.sr_nota%TYPE,
                      imp IN BOOLEAN)
      /*
      || Grava nota de um pedido
      */
    IS

      CURSOR crp IS
         SELECT *
           FROM t_pedidos
          WHERE empresa = emp
            AND filial = fil
            AND num_pedido = num;

      CURSOR cri IS
         SELECT *
           FROM t_itens_ped
          WHERE empresa = emp
            AND filial = fil
            AND num_pedido = num;

      CURSOR cr_num(t ft_num_nota.tipo_nota%TYPE) IS
         SELECT num_nota,
                sr_nota
           FROM ft_num_nota
          WHERE empresa = emp
            AND filial = fil
            AND tipo_nota = t
            FOR UPDATE OF num_nota;

      CURSOR cr_par IS
         SELECT *
           FROM t_parc_ped
          WHERE empresa = emp
            AND filial = fil
            AND num_pedido = num;

      CURSOR cr_cp(ct ft_condpag.cod_condpag%TYPE) IS
         SELECT dias,
                pc_parcela
           FROM ft_itens_cond
          WHERE cod_condpag = ct;

      CURSOR cr_pnf(e ft_parc_nf.empresa%TYPE, f ft_parc_nf.filial%TYPE, n ft_parc_nf.num_nota%TYPE, s ft_parc_nf.sr_nota%TYPE, p ft_parc_nf.parte%TYPE) IS
         SELECT *
           FROM ft_parc_nf
          WHERE empresa = e
            AND filial = f
            AND num_nota = n
            AND sr_nota = s
            AND parte = p
            FOR UPDATE;
      v_pnf  NUMBER;
      reg_pn ft_parc_nf%ROWTYPE;

      CURSOR curicms(e ft_itens_nf.empresa%TYPE, f ft_itens_nf.filial%TYPE, n ft_itens_nf.num_nota%TYPE, s ft_itens_nf.sr_nota%TYPE, v ft_itens_nf.vl_icms%TYPE) IS
         SELECT seq_item
           FROM ft_itens_nf
          WHERE empresa = e
            AND filial = f
            AND num_nota = n
            AND sr_nota = s
            AND parte = 0
            AND vl_icms >= v;
            
      cursor cr_soma_imp(p_id number) is
        select sum(n.vl_bipi) vl_bipi
             , sum(n.vl_ipi) vl_ipi
          from ft_itens_nf n
          where n.id_ft_nota = p_id;

      nf      ft_notas%ROWTYPE;
      reg     ft_pedidos%ROWTYPE;
      reg_pro ce_produtos%ROWTYPE;
      reg_tri ft_tribut%ROWTYPE;
      reg_opr ft_oper%ROWTYPE;
      reg_in  ft_itens_nf%ROWTYPE;
      reg_rm  ce_itens_nf%ROWTYPE;
      reg_cfo ft_cfo%ROWTYPE;

      v_msg ft_fisco.tab_msg_t;
      t_msg ft_fisco.tab_msg_t;
      i_msg ft_fisco.tab_msg_t;
      v_fis ft_fisco.impostos_t;

      n_msg NUMBER;
      n_ind NUMBER;

      v_num_nota  ft_notas.num_nota%TYPE;
      v_sr_nota   ft_notas.sr_nota%TYPE;
      v_icm       NUMBER;
      v_uf_origem cd_uf.uf%TYPE;
      v_tri       ft_tribut.cod_tribut%TYPE;
      v_red       NUMBER;
      --v_ret number;
      v_ret         VARCHAR2(1000);
      v_cfo2        ft_cfo.cod_cfo%TYPE;
      v_bicms       NUMBER;
      v_bicms_sub   NUMBER;
      v_icms        NUMBER;
      v_icms_sub    NUMBER;
      v_icms_isen   NUMBER;
      v_bipi        NUMBER;
      v_biss        NUMBER;
      v_ipi         NUMBER;
      v_iss         NUMBER;
      v_pcipi       NUMBER;
      v_pciss       NUMBER;
      v_dt_base     DATE;
      v_ct_apres    ft_condpag.ct_apres%TYPE;
      v_avista      ft_condpag.a_vista%TYPE;
      v_parc        NUMBER;
      v_mensagem    ft_msgs.mensagem%TYPE;
      v_ricm        NUMBER;
      v_cod_msg_opr ft_oper.cod_msg%TYPE;
      v_msg_opr     ft_msgs.mensagem%TYPE;
      b_devolucao   BOOLEAN;
      b_devrm       BOOLEAN;
      v_dmax        NUMBER;
      v_tipo_nf     NUMBER;
      najuste       ft_itens_nf.vl_icms%TYPE;
      v_seq_icms    ft_itens_nf.seq_item%TYPE;
      v_des         CHAR;
      v_desconto    NUMBER;
      v_bicms_pro   NUMBER;
      v_icms_pro    NUMBER;

      v_pc_val ft_parc_ped.pc_valor%TYPE;

      CURSOR cr_zf(c cd_cidades.cod_cidade%TYPE) IS
         SELECT 'S'
           FROM ft_cidades_zf
          WHERE cod_cidade = c;
          
          
          
      v_zf          CHAR(1);
      v_suf         VARCHAR2(100);
      v_con         CHAR(1);
      reg_cli       cd_firmas%ROWTYPE;
      v_pruni_sst   NUMBER;
      v_pis         NUMBER;
      v_cofins      NUMBER;
      v_piscof      NUMBER;
      v_dsct        NUMBER;
      v_dia1        ft_condpag.dia1%TYPE;
      v_dia2        ft_condpag.dia2%TYPE;
      v_dia3        ft_condpag.dia3%TYPE;
      v_binss       NUMBER;
      v_inss        NUMBER;
      v_itens       NUMBER;
      v_ccp         NUMBER;
      v_aliq_ccp    ft_prgen.aliq_ccp%TYPE;
      v_vl_min_ccp  ft_prgen.vl_min_ccp%TYPE;
      v_vl_min_irf  ft_prgen.vl_min_irf%TYPE;
      v_vl_min_inss ft_prgen.vl_min_inss%TYPE;
      v_vl_irf      NUMBER;
      v_pc_irf      NUMBER;
      v_comp_icms   ft_oper.comp_icms%TYPE;
      v_comp_ipi    ft_oper.comp_ipi%TYPE;
      v_nat         ft_oper.natureza%TYPE;
      v_pc_icms     ft_icms_ctl.pc_icms%TYPE;
      v_rec50       ft_oper.rec_ipi_50%TYPE;
      --/
      v_base_icms          NUMBER; --05/07/2007
      --/
      v_trib_ipi          ft_tribut_ipi.cod_tribut%type;
      v_trib_pis          ft_tribut_pis.cod_tribut%type;
      v_trib_cof          ft_tribut_cof.cod_tribut%type;
      v_ALIQ_RED_BCIMS    number;
      v_ALIQ_RED_BCIMS_ST number;
      v_vl_pis            number(15,2);
      v_vl_cof            number(15,2);

      V_ID_NOTA   NUMBER(9);
      v_ncm       ft_itens_nf.ncm%type;
      V_ENQ_IPI   ft_enq_ipi.codigo%type;
      v_cest      ft_itens_nf.cest%type;
   BEGIN

      --| Le o parametro de diferenca maxima de impostos
      BEGIN
         SELECT max_difer,
                aliq_pis,
                aliq_cofins,
                aliq_ccp,
                vl_min_ccp,
                vl_min_irf,
                vl_min_inss
           INTO v_dmax,
                v_pis,
                v_cofins,
                v_aliq_ccp,
                v_vl_min_ccp,
                v_vl_min_irf,
                v_vl_min_inss
           FROM ft_prgen;
      exception
        when others then
            raise_application_error(-20101,'FT_NF.GRAVA_NF: Falta informac?es da tabela FT_PRGEN');
      END;

      --| Le o pedido
      OPEN crp;
      FETCH crp
         INTO reg;
      CLOSE crp;

      IF reg.parte IS NULL THEN
         nnf := NULL;
         RETURN;
      END IF;

      --| Le a operacao
      SELECT *
        INTO reg_opr
        FROM ft_oper
       WHERE empresa = emp
         AND cod_oper = reg.cod_oper;

      v_nat := reg_opr.natureza;

      --| Servico
      IF reg_opr.servico = 'S' THEN
         SELECT COUNT(*)
           INTO v_itens
           FROM t_itens_ped
          WHERE empresa = emp
            AND filial = fil
            AND num_pedido = num;
         IF v_itens <> 1 THEN
            raise_application_error(-20100,
                                    'Erro: Disponivel apenas 1 item para Nota Fiscal de Servico');
         END IF;
      END IF;

      --| Le CFO para verificar os procedimento de integracao
      SELECT *
        INTO reg_cfo
        FROM ft_cfo
       WHERE cod_cfo = reg.cod_cfo;

      --| Verifica o tipo de nota fiscal
      v_tipo_nf := tipo_nf(emp,
                           fil,
                           reg_opr.cod_oper);

      IF v_tipo_nf IS NULL THEN
         raise_application_error(-20105,
                                 'Erro : Tipo de nota a gerar n?o encontrado nos parametros');
      END IF;

      --| Le o ultimo numero de nota e pega o proximo
      IF nnf IS NULL
         OR ser IS NULL THEN
         OPEN cr_num(v_tipo_nf);
         FETCH cr_num
            INTO v_num_nota, v_sr_nota;
         IF cr_num%NOTFOUND THEN
            CLOSE cr_num;
            raise_application_error(-20106,
                                    'Registro de controle de numerac?o n?o foi criado para tipo de nota ' ||
                                    to_char(v_tipo_nf) || ' na filial ' ||
                                    to_char(fil));
         END IF;
         v_num_nota := v_num_nota + 1;
      ELSE
         v_num_nota := nnf;
         v_sr_nota  := ser;
      END IF;

      --| Verifica se devolucao de cliente
      IF reg_opr.natureza = 'E'
         AND reg_opr.devolucao = 'S'
         AND reg_opr.nf_origem = 'S' THEN
         b_devolucao := TRUE;
      ELSE
         b_devolucao := FALSE;
      END IF;

      --| Verifica se devolucao a fornecedor (de Rec.Mercadoria)
      IF reg_opr.natureza = 'S'
         AND reg_opr.rm_origem = 'S'
         AND reg_opr.nf_origem = 'S' THEN
         b_devrm := TRUE;
      ELSE
         b_devrm := FALSE;
      END IF;

      -- Mensagem da operacao e verifica complemento ipi e icms

      SELECT cod_msg,
             comp_icms,
             comp_ipi
        INTO v_cod_msg_opr,
             v_comp_icms,
             v_comp_ipi
        FROM ft_oper
       WHERE empresa = reg.empresa
         AND cod_oper = reg.cod_oper;

      SELECT cod_msg
        INTO v_cod_msg_opr
        FROM ft_oper
       WHERE empresa = reg.empresa
         AND cod_oper = reg.cod_oper;

      -- Le o estado da filial que fatura
      SELECT uf
        INTO v_uf_origem
        FROM cd_firmas
       WHERE empresa = emp
         AND filial = fil;

      --| Le o registro do cliente e dados de suframa/livro comercio
      SELECT *
        INTO reg_cli
        FROM cd_firmas
       WHERE firma = reg.firma;

      v_suf := reg_cli.cod_suframa;
      v_con := reg_cli.cons_final;

      OPEN cr_zf(reg_cli.cod_cidade);
      FETCH cr_zf
         INTO v_zf;

      IF cr_zf%NOTFOUND THEN
         v_zf := 'N';
      END IF;

      CLOSE cr_zf;

      --| Guarda mensagem para titulo
      comp_nota.obs_titulo := reg.obs_titulo;


      --| Grava registro da nota |-----------------------------------------------
      nf.empresa      := reg.empresa;
      nf.filial       := fil;
      nf.num_nota     := v_num_nota;
      nf.sr_nota      := v_sr_nota;
      nf.parte        := reg.parte;
      nf.firma        := reg.firma;
      nf.cnpj_cpf     := cd_firmas_utl.cgc_cpf(reg.firma);
      nf.iest         := cd_firmas_utl.inscr(reg.firma);
      nf.dt_emissao   := trunc(dta);
      nf.cod_oper     := reg.cod_oper;
      nf.cod_cfo      := reg.cod_cfo;
      nf.producao     := reg.producao;
      nf.periodo      := reg.periodo;
      nf.status       := 'A';
      nf.dt_entsai    := nvl(g_data_saida,
                             trunc(dta));
      nf.dt_cancela   := NULL;
      nf.num_pedido   := reg.num_pedido;
      nf.agente1      := reg.agente1;
      nf.agente2      := reg.agente2;
      nf.pc_desc      := reg.pc_desc;
      nf.dias_desc    := reg.dias_desc;
      nf.cod_condpag  := reg.cod_condpag;
      nf.tipo_cob     := reg.tipo_cob;
      nf.tipo_tit     := reg.tipo_tit;
      nf.banco        := reg.banco;
      nf.agencia      := NULL;
      nf.tp_frete     := comp_nota.tp_frete;
      nf.tp_juros     := reg.tp_juros;
      nf.pc_juros     := reg.pc_juros;
      nf.pc_multa     := reg.pc_multa;
      nf.dias_multa   := reg.dias_multa;
      nf.dias_juros   := reg.dias_juros;
      nf.ent_ender    := reg.ent_ender;
      nf.ent_compl    := reg.ent_compl;
      nf.ent_bairro   := reg.ent_bairro;
      nf.ent_cidade   := reg.ent_cidade;
      nf.ent_uf       := reg.ent_uf;
      nf.ent_pais     := reg.ent_pais;
      nf.ent_cep      := reg.ent_cep;
      nf.cob_ender    := reg.cob_ender;
      nf.cob_compl    := reg.cob_compl;
      nf.cob_bairro   := reg.cob_bairro;
      nf.cob_cidade   := reg.cob_cidade;
      nf.cob_uf       := reg.cob_uf;
      nf.cob_pais     := reg.cob_pais;
      nf.cob_cep      := reg.cob_cep;
      nf.vl_bicms     := 0;
      nf.vl_bicms_sub := 0;
      nf.vl_bipi      := 0;
      nf.vl_biss      := 0;
      nf.vl_total     := 0;
      nf.vl_produtos  := 0;
      nf.vl_desconto  := 0;
      nf.vl_icms      := 0;
      nf.vl_icms_sub  := 0;
      nf.vl_icms_fre  := 0;
      nf.vl_ipi       := 0;
      nf.vl_iss       := 0;
      nf.vl_embalagem := comp_nota.vl_embalagem;
      nf.vl_frete     := comp_nota.vl_frete;
      nf.vl_seguro    := comp_nota.vl_seguro;
      nf.vl_outros    := reg.vl_outros;
      nf.pc_desc_ir   := 0;
      nf.vl_desc_ir   := 0;
      nf.vol_qtd      := comp_nota.vol_qtd;
      nf.vol_especie  := comp_nota.vol_especie;
      nf.vol_marca    := comp_nota.vol_marca;
      nf.vol_numero   := comp_nota.vol_numero;
      nf.peso_liquido := comp_nota.peso_liquido;
      nf.peso_bruto   := comp_nota.peso_bruto;
      nf.cod_transp   := comp_nota.cod_transp;
      nf.motorista    := comp_nota.motorista;
      nf.cpf_mot      := comp_nota.cpf_mot;
      nf.placa_veic   := comp_nota.placa_veic;
      nf.placa_uf     := comp_nota.placa_uf;
      nf.firma_ent    := reg.firma_ent;
      nf.num_fatura   := 0;
      nf.sr_fatura    := '';
      nf.fil_pedido   := reg.filial;
      nf.lote_cont    := NULL;
      nf.vl_pis       := 0;
      nf.vl_cofins    := 0;
      nf.empresa_dest := NULL;
      nf.filial_dest  := NULL;
      nf.aliq_iss     := 0;
      nf.vl_servicos  := reg.vl_servicos;
      nf.desc_serv    := reg.desc_serv;
      nf.vl_icms_desp := 0;
      nf.fl_dest      := NULL;
      nf.nf_dest      := NULL;
      nf.sr_dest      := NULL;
      nf.fr_dest      := NULL;
      
      --| falta finalidade 3 ajuste
      If reg_opr.devolucao = 'S' then
        nf.finalidade_nfe := 4; 
      elsif reg_opr.comp_icms = 'S' or reg_opr.comp_ipi = 'S' then
        nf.finalidade_nfe := 2; 
      else
        nf.finalidade_nfe := 1;
      End If;      
      
      SELECT FT_NOTAS_SEQ.NEXTVAL INTO NF.ID FROM DUAL;
      V_ID_NOTA := NF.ID;

      --/29/10/2007
      nf.frete_bicms := reg.frete_bicms; -- 29/10/2007
      --/*
         --raise_application_error(-20101,'aqui2');
      IF reg.frete_bicms = 'S' THEN
         nf.vl_total := nvl(nf.vl_servicos,
                            0) + nvl(nf.vl_embalagem,
                                     0) + nvl(nf.vl_frete,
                                              0) +
                        nvl(nf.vl_seguro,
                            0);
      ELSE
         nf.vl_total := nvl(nf.vl_servicos,
                            0);
      END IF;
      --/29/10/2007
      --IF reg.cod_oper != 31 THEN -- IMOBILIZADO
         nf.vl_total := nvl(nf.vl_total,
                            0) + nvl(nf.vl_outros,
                                     0);
      --END IF;
      --*/

      nf.num_exped    := comp_nota.num_exped;
      nf.vl_desconto  := 0;
      nf.vl_bicms_pro := 0;
      nf.vl_icms_pro  := 0;
      nf.vl_binss     := 0;
      nf.vl_inss      := 0;
      nf.vl_ccp       := 0;
      nf.atividade    := reg.atividade;
      nf.cfps         := reg.cfps;
      nf.vlr_deduz    := reg.vlr_deduz;

      n_msg := 0;
      t_msg.DELETE;

      --| Grava a nota
      grava_reg_nf(nf);
             --raise_application_error(-20200,'shshsh');
      --| Se frete autonomo
      IF nvl(comp_nota.vl_frete_au,
             0) > 0 THEN
         INSERT INTO ft_cnf
         VALUES
            (nf.empresa,
             nf.filial,
             nf.num_nota,
             nf.sr_nota,
             nf.parte,
             comp_nota.vl_frete_au);
      END IF;

      --| Le os dias para condicao de pagamento
      SELECT dia1,
             dia2,
             dia3
        INTO v_dia1,
             v_dia2,
             v_dia3
        FROM ft_condpag
       WHERE cod_condpag = reg.cod_condpag;

      --| Percorre os itens do pedido
      FOR rgi IN cri LOOP
         --raise_application_error('-20100',rgi.valor_unit);
         --| Le registro de produto

         SELECT *
           INTO reg_pro
           FROM ce_produtos
          WHERE empresa = rgi.empresa
            AND produto = rgi.produto;

         --| Se for devolucao  - impostos como na nota origem (se nao estiver marcado para recalcular)
         IF b_devolucao
            AND nvl(lib_marca.valor,
                    0) = 0 THEN

            SELECT *
              INTO reg_in
              FROM ft_itens_nf
             WHERE seq_item = rgi.seq_origem;
            --/
            v_bicms     := round((reg_in.vl_bicms / reg_in.qtd) *
                                 rgi.qtd_ped,
                                 2);
            v_bicms_sub := round((reg_in.vl_bicms_sub / reg_in.qtd) *
                                 rgi.qtd_ped,
                                 2);
            v_icms      := round((reg_in.vl_icms / reg_in.qtd) *
                                 rgi.qtd_ped,
                                 2);
            v_icms_sub  := round((reg_in.vl_icms_sub / reg_in.qtd) *
                                 rgi.qtd_ped,
                                 2);
            v_bipi      := round((reg_in.vl_bipi / reg_in.qtd) *
                                 rgi.qtd_ped,
                                 2);
            v_ipi       := round((reg_in.vl_ipi / reg_in.qtd) * rgi.qtd_ped,
                                 2);



            v_icm       := reg_in.aliq_icms;
            v_pcipi     := reg_in.aliq_ipi;
            v_tri       := reg_in.cod_tribut;
            --/
            v_pruni_sst := reg_in.pruni_sst;
            --/
            v_biss      := 0;
            v_iss       := 0;
            v_pciss     := 0;
            v_bicms_pro := round((reg_in.vl_bicms_pro / reg_in.qtd) *
                                 rgi.qtd_ped,
                                 2);
            v_icms_pro  := round((reg_in.vl_icms_pro / reg_in.qtd) *
                                 rgi.qtd_ped,
                                 2);

            --| Se for devolucao a fornecedor - impostos como na nota origem
         ELSIF b_devrm THEN

            BEGIN
               SELECT *
                 INTO reg_rm
                 FROM ce_itens_nf
                WHERE ID = rgi.seq_origem;
            EXCEPTION
               WHEN OTHERS THEN
                  raise_application_error(-20105,
                                          'ft_nf.grava_nf: Nota fiscal de origem n?o encontrada!');
            END;

            SELECT rec_ipi_50
              INTO v_rec50
              FROM ce_notas a,
                   ft_oper  b
             WHERE a.empresa = reg_rm.empresa
               AND a.filial = reg_rm.filial
               AND a.num_nota = reg_rm.num_nota
               AND a.sr_nota = reg_rm.sr_nota
               AND a.cod_fornec = reg_rm.cod_fornec
               AND a.parte = reg_rm.parte
               AND a.empresa = b.empresa
               AND a.cod_oper = b.cod_oper;

            v_bicms := round((reg_rm.vl_bicms / reg_rm.qtd) * rgi.qtd_ped,
                             2);
            v_icms  := round((reg_rm.vl_icms / reg_rm.qtd) * rgi.qtd_ped,
                             2);

            IF v_rec50 = 'S' THEN
               v_ipi   := 0;
               v_pcipi := 0;
               v_bipi  := 0;
            ELSE

               v_ipi := round((reg_rm.vl_ipi / reg_rm.qtd) * rgi.qtd_ped,
                              2);

               v_pcipi := reg_rm.aliq_ipi;
               IF nvl(v_pcipi,
                      0) = 0 THEN
                  v_bipi := 0;
               ELSE
                  v_bipi := round((v_ipi * 100) / v_pcipi,
                                  2);
               END IF;
            END IF;

            v_icm       := reg_rm.aliq_icms;
            v_tri       := reg_rm.cod_tribut;
            v_pruni_sst := reg_rm.valor_unit;

            BEGIN
               SELECT *
                 INTO reg_tri
                 FROM ft_tribut
                WHERE cod_tribut = v_tri;
            EXCEPTION
               WHEN OTHERS THEN
                  raise_application_error(-20101,
                                          '(FT_NF.GRVA_NF)Erro na leitura de codigo de tributação==> (' ||
                                          v_tri||')');
            END;

            v_bicms_sub := 0;
            v_icms_sub  := 0;
            v_biss      := 0;
            v_iss       := 0;
            v_pciss     := 0;

            IF reg_tri.isento = 'N'
               AND nvl(v_icm,
                       0) > 0 THEN
               IF reg_tri.subtri = 'S'
                  AND reg_tri.isento = 'N'
                  AND reg_tri.anter = 'N' THEN
                  v_bicms_sub := v_bicms;
                  v_icms_sub  := v_icms;
                  v_bicms     := 0;
                  v_icms      := 0;
               END IF;
            END IF;

            --| Se nao for devolucao
         ELSE
            v_base_icms := rgi.qtd_val * rgi.valor_unit;

            IF v_nat = 'E' THEN
               --| Calcula impostos (ICMS)
               IF reg.cod_oper = 31 THEN
                  -- imobilizado
                  v_base_icms := v_base_icms + nvl(reg.vl_outros,
                                                   0);
               END IF;




               v_ret := ft_fisco.calc_impostos(rgi.empresa,
                                               rgi.filial,
                                               rgi.produto,
                                               nvl(rgi.cod_cfo,
                                                   reg.cod_cfo),
                                               reg.ent_uf,
                                               v_uf_origem,
                                               v_base_icms,
                                               v_zf,
                                               v_suf,
                                               v_con,
                                               reg_opr.servico,
                                               v_fis,
                                               v_msg);
            ELSE
               --| Calcula impostos (ICMS)
              --RAISE_APPLICATION_ERROR(-20100, v_uf_origem||'-'|| reg.ent_uf);

               v_ret := ft_fisco.calc_impostos(rgi.empresa,
                                               rgi.filial,
                                               rgi.produto,
                                               nvl(rgi.cod_cfo,
                                                   reg.cod_cfo),
                                               v_uf_origem,
                                               reg.ent_uf,
                                               v_base_icms --rgi.qtd_val * rgi.valor_unit
                                              ,
                                               v_zf,
                                               v_suf,
                                               v_con,
                                               reg_opr.servico,
                                               v_fis,
                                               v_msg);


            END IF;

            IF v_ret <> '0' THEN
               raise_application_error(-20101,
                                       ' FT_FISCO.CALC_IMPOSTOS: Erro no calculo: ' ||
                                       to_char(v_ret));
            END IF;

            --| Inclui na tabela interna de mensagens
            FOR n IN 1 .. v_msg.COUNT LOOP
               n_ind := 0;
               FOR i IN 1 .. t_msg.COUNT LOOP
                  IF t_msg(i) = v_msg(n) THEN
                     n_ind := i;
                     EXIT;
                  END IF;
               END LOOP;
               IF n_ind = 0 THEN
                  n_msg := n_msg + 1;
                  t_msg(n_msg) := v_msg(n);
               END IF;
            END LOOP;

            BEGIN
               IF v_fis.cod_tribut IS NOT NULL THEN
                  SELECT *
                    INTO reg_tri
                    FROM ft_tribut
                   WHERE cod_tribut = v_fis.cod_tribut;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  raise_application_error(-20101,
                                          'FT_NF.GRAVA_NF:Erro na leitura de codigo de tributac?o  : ' ||
                                          v_fis.cod_tribut);
            END;

            IF reg_cfo.calc_iss = 'S' THEN
               v_pciss := nvl(v_fis.pc_iss,
                              0);
               v_biss  := (rgi.qtd_val * rgi.valor_unit);
               v_iss   := (v_biss * v_pciss) / 100;
            END IF;

            IF nvl(v_fis.red_inss,
                   0) > 0 THEN
               v_binss := ((rgi.qtd_val * rgi.valor_unit) *
                          nvl(v_fis.red_inss,
                               0)) / 100;
               v_inss  := (v_binss * nvl(v_fis.pc_inss,
                                         0)) / 100;
            END IF;

            IF nvl(v_fis.pc_irf,
                   0) > 0 THEN
               v_vl_irf := (v_biss * nvl(v_fis.pc_irf,
                                         0) / 100);
               v_pc_irf := nvl(v_fis.pc_irf,
                               0);
            END IF;

            v_pc_icms := nvl(v_fis.pc_icms,
                             0);

            IF reg_opr.inc_ccp = 'S' THEN
               v_ccp := (v_biss * nvl(v_aliq_ccp,
                                      0)) / 100;
            ELSE
               v_ccp := 0;
            END IF;
            -- desabilitar valor do ccp em virtude de contabilizacao agora no recebimento
            v_ccp := 0;

            IF v_inss >= v_vl_min_inss THEN
               v_inss  := v_inss;
               v_binss := v_binss;
            ELSE
               v_inss  := 0;
               v_binss := 0;
            END IF;

            IF v_vl_irf >= v_vl_min_irf THEN
               v_vl_irf := v_vl_irf;
               v_pc_irf := v_pc_irf;
            ELSE
               v_vl_irf := 0;
               v_pc_irf := 0;
            END IF;

            v_pcipi     := nvl(v_fis.pc_ipi,
                               0);
            v_bipi      := nvl(v_fis.bs_ipi,
                               0);
            v_ipi       := nvl(v_fis.vl_ipi,
                               0);
            v_tri       := v_fis.cod_tribut;
            v_icm       := v_fis.pc_icms;
            v_bicms     := v_fis.bs_icms;
            v_icms      := v_fis.vl_icms;
            v_bicms_sub := v_fis.bs_isub;
            v_icms_sub  := v_fis.vl_isub;
            v_des       := v_fis.com_des;

            IF reg.cod_oper = 31 THEN
               -- imobilizado
               v_pruni_sst := (v_fis.destr - nvl(reg.vl_outros,
                                                 0)) / rgi.qtd_ped;
            ELSE
               v_pruni_sst := v_fis.destr / rgi.qtd_ped;
            END IF;

            -- v_pruni_sst := v_fis.destr / rgi.qtd_ped;
            v_cfo2      := v_fis.cod_cfo;
            v_bicms_pro := v_fis.bs_ipro;
            v_icms_pro  := v_fis.vl_ipro;
            v_dsct      := v_fis.vl_dsct;

            --| PIS e COFINS 28/12/2012
            v_piscof := v_fis.destr;--07/02/2017 (slf/wagner)v_bicms;

            IF reg_opr.pis = 'S' THEN
               v_vl_pis := round(v_piscof * (v_pis / 100),
                                  2);
                v_trib_pis := v_fis.cod_tribut_pis;
                if v_trib_pis is null then
                   v_trib_pis := reg_cfo.cod_tribut_pis;
                end if;
            END IF;

            IF reg_opr.cofins = 'S' THEN
               v_vl_cof := round(v_piscof * (v_cofins / 100),
                                     2);
                v_trib_cof := v_fis.cod_tribut_cof;
                if v_trib_cof is null then
                   v_trib_cof := reg_cfo.cod_tribut_cof;
                end if;
            END IF;

            v_trib_ipi := v_fis.cod_tribut_ipi;
            if v_trib_ipi is null then
               v_trib_ipi := reg_cfo.cod_tribut_ipi;
            end if;

         END IF; -- Se devolucao

        --raise_application_error(-20201,v_trib_ipi || ' pis '|| v_trib_pis || ' icm '|| v_fis.cod_tribut) ;
         v_ncm := ce_produtos_utl.Cod_Nbm(rgi.empresa, rgi.produto);
         V_ENQ_IPI := CD_NFE_UTL.fnc_enq_ipi_pref(v_trib_ipi);
         v_cest    := cd_nfe_utl.fnc_cest(v_ncm);
                  
         if nvl(v_vl_pis,0) = 0 then
             v_pis := 0;
         end if;
         
         if nvl(v_vl_cof,0) = 0 then
             v_cofins := 0;
         end if;
         

         
         INSERT INTO ft_itens_nf
         VALUES
            (FT_ITENS_NF_SEQ.NEXTVAL,
             V_ID_NOTA ,
             rgi.empresa,                                                                       -- EMPRESA
             rgi.filial,                                                                        -- FILIAL
             v_num_nota,                                                                        -- NUM_NOTA
             v_sr_nota,                                                                         -- SR_NOTA
             nf.parte,                                                                          -- PARTE
             rgi.produto,                                                                       -- PRODUTO
             ft_itens_nf_seq.NEXTVAL,                                                           -- SEQ_ITEM
             rgi.descricao || '  ' || rgi.num_chapa,                                            -- DESCRICAO
             rgi.qtd_ped,                                                                       -- QTD
             rgi.valor_unit,                                                                    -- VALOR_UNIT
             rgi.uni_ven,                                                                       -- UNI_VEN
             rgi.uni_est,                                                                       -- UNI_EST
             rgi.uni_val,                                                                       -- UNI_VAL
             rgi.qtd_val,                                                                       -- QTD_VAL
             rgi.qtd_fat,                                                                       -- QTD_FAT
             rgi.qtd_dev,                                                                       -- QTD_DEV
             rgi.valor_base,                                                                    -- VALOR_BASE
             nvl(v_cfo2,nvl(rgi.cod_cfo, nf.cod_cfo)),                                          -- COD_CFO
             round(v_bicms,  2),                                                                -- VL_BICMS
             round(v_bicms_sub, 2),                                                             -- VL_BICMS_SUB
             round(v_bipi,2),                                                                   -- VL_BIPI
             round(v_biss, 2),                                                                  -- VL_BISS
             round(v_icm,  2),                                                                  -- ALIQ_ICMS
             round(v_pcipi,2),                                                                  -- ALIQ_IPI
             round(v_pciss,2),                                                                  -- ALIQ_ISS
             round(v_icms,2),                                                                   -- VL_ICMS
             round(v_ipi, 2),                                                                   -- VL_IPI
             round(v_iss,2),                                                                    -- VL_ISS
             round(v_icms_sub,2),                                                                --VL_ICMS_SUB
             reg_pro.cod_origem,                                                                 --COD_ORIGEM
             v_tri,                                                                              --COD_TRIBUT
             round(rgi.valor_unit * rgi.qtd_val * nvl(nvl(rgi.pc_com,reg.pc_comi1), 0),2),       --VL_COMI1
             round(rgi.valor_unit * rgi.qtd_val * nvl(reg.pc_comi2, 0),2),                       --VL_COMI2
             rgi.fil_origem,                                                                     --FIL_ORIGEM
             rgi.doc_origem,                                                                     --DOC_ORIGEM
             rgi.ser_origem,                                                                     --SER_ORIGEM
             rgi.seq_origem,                                                                     --SEQ_ORIGEM
             NULL,                                                                               --SEQ_MOVEST1
             NULL,                                                                               --SEQ_MOVEST2
             rgi.LOCAL,                                                                          --LOCAL
             rgi.seq_item,                                                                       --SEQ_PEDIDO
             NULL,                                                                               --SEQ_EXPED
             rgi.fil_local,                                                                      --FIL_LOCAL
             rgi.uni_emb,                                                                        --UNI_EMB
             rgi.qtd_emb,                                                                        --QTD_EMB
             v_pruni_sst,                                                                        --PRUNI_SST
             round(v_bicms_pro, 2),                                                              --VL_BICMS_PRO
             round(v_icms_pro, 2),                                                               --VL_ICMS_PRO
             nvl(rgi.pc_com,reg.pc_comi1),                                                       --PC_COM
             NULL,                                                                               --PROD_SEC
             round(v_binss,   2),                                                                --VL_BINSS
             round(v_inss, 2),                                                                   --VL_INSS
             round(v_ccp, 2),                                                                    --VL_CCP
             round(v_vl_irf, 2),                                                                 --VL_DESC_IR
             v_trib_ipi,                                                                         --COD_TRIBUT_IPI
             v_trib_cof,                                                                         --COD_TRIBUT_COF
             v_trib_pis,                                                                         --COD_TRIBUT_PIS
             v_piscof,                                                                           --VL_BPIS
             v_piscof,                                                                           --VL_BCOF
             v_pis,                                                                              --ALIQ_PIS
             v_cofins,                                                                           --ALIQ_COF
             v_vl_pis,                                                                           --VL_PIS
             v_vl_cof,                                                                           --VL_COF
             NULL,                                                                               --VL_SEGURO
             rgi.vl_desconto,                                                                               --VL_DESCTO
             NULL,                                                                               --VL_FRETE
             NULL,                                                                               --VL_OUTRAS
             NULL,                                                                               --VL_TOTAL_BRUTO
             NULL, --incl                                                                        INCL_SERV
             null,                                                                               --MOD_ICMS
             v_ALIQ_RED_BCIMS,                                                                   --ALIQ_RED_BCIMS
             null,                                                                               --MOD_ICMS_ST
             v_ALIQ_RED_BCIMS_ST,                                                                --ALIQ_RED_BCIMS_ST
             null,                                                                               --MARG_ADIC_BCIMS_ST
             null,                                                                               --UF_ST
             null,                                                                               --VL_BASE_IMP
             null,                                                                               --VL_DESP_ADUAN
             null,                                                                               --VL_IOF
             null  ,                                                                             --VL_IMPOSTO_IMP
             NULL,
             v_ncm,
             v_enq_ipi,
             v_cest);                                                                              --VL_ICMS_FRETE


         nf.vl_produtos := nf.vl_produtos +
                           round(nvl(v_dsct,
                                     rgi.qtd_val * v_pruni_sst),
                                 2);
         IF reg.cod_oper = 31 THEN
            -- imobilizado
            nf.vl_total := nf.vl_total + round(nvl(v_dsct,
                                                   rgi.qtd_val * v_pruni_sst),
                                               2) +
                           nvl(reg.vl_outros,
                               0);
         ELSE
            nf.vl_total := nf.vl_total + round(nvl(v_dsct,
                                                   rgi.qtd_val * v_pruni_sst),
                                               2);
         END IF;

         nf.vl_bicms_sub := nf.vl_bicms_sub + v_bicms_sub;
         nf.vl_icms_sub  := nf.vl_icms_sub + v_icms_sub;
         nf.vl_bicms     := nf.vl_bicms + v_bicms;
         nf.vl_icms      := nf.vl_icms + v_icms;
         nf.vl_bipi      := nf.vl_bipi + v_bipi;
         nf.vl_ipi       := round(nf.vl_ipi,
                                  2) + round(v_ipi,
                                             2);
         nf.vl_icms_pro  := nf.vl_icms_pro + v_icms_pro;
         nf.vl_bicms_pro := nf.vl_bicms_pro + v_bicms_pro;
         nf.vl_binss     := nf.vl_binss + v_binss;
         nf.vl_inss      := nf.vl_inss + v_inss;
         nf.vl_biss      := nf.vl_biss + v_biss;
         nf.vl_iss       := nf.vl_iss + v_iss;
         nf.vl_ccp       := nf.vl_ccp + v_ccp;
         nf.pc_desc_ir   := v_pc_irf;
         nf.vl_desc_ir   := nf.vl_desc_ir + v_vl_irf;

         v_desconto := rgi.vl_desconto; /*(rgi.qtd_val * v_pruni_sst) -
                       nvl(v_dsct,
                           rgi.qtd_val * v_pruni_sst);*/

         nf.vl_desconto := nf.vl_desconto + nvl(v_desconto,
                                                0);

      END LOOP;
      

      begin
      IF NOT imp THEN
         IF v_dmax IS NOT NULL THEN
            IF abs(nvl(nf.vl_icms,
                       0) - nvl(reg.vl_icms,
                                0)) > v_dmax
               OR abs(nvl(nf.vl_icms_sub,
                          0) - nvl(reg.vl_icms_sub,
                                   0)) > v_dmax
               OR abs(nvl(nf.vl_ipi,
                          0) - nvl(reg.vl_ipi,
                                   0)) > v_dmax THEN
               raise_application_error(-20110,
                                       'Diferenca de impostos maior que o limite (Maximo ' ||
                                       ltrim(to_char(v_dmax,
                                                     '990D00')) || ')');
            END IF;
         END IF;
         IF (nvl(nf.vl_icms,
                 0) - nvl(reg.vl_icms,
                           0)) <> 0.00 THEN
            -- Caso haja diferenca entre o valor calculo de icms com o valor informado
            najuste := abs(nvl(nf.vl_icms,
                               0) - nvl(reg.vl_icms,
                                        0));

            OPEN curicms(nf.empresa,
                         nf.filial,
                         nf.num_nota,
                         nf.sr_nota,
                         najuste);
            FETCH curicms
               INTO v_seq_icms; -- Localiza item para lancamento da # do icms
            CLOSE curicms;
            IF v_seq_icms IS NULL THEN
               raise_application_error(-20111,
                                       'Nao Encontrado Item para Rateio do ICMS. Valor a Ratear: ' ||
                                       to_char(najuste,
                                               '990D00'));
            END IF;
            IF (nvl(nf.vl_icms,
                    0) - nvl(reg.vl_icms,
                              0)) > 0.00 THEN
               -- Se o Valor no BD for > que o INFORMADO, entao diminui no BD, senao, aumenta
               najuste := najuste * -1;
            END IF;
          begin
            UPDATE ft_itens_nf
               SET vl_icms = vl_icms + najuste
             WHERE seq_item = v_seq_icms;
           exception
             when others then
               raise_application_error(-20103,'grava_nf:update_ft_itens');
           end ;
         END IF;
         nf.vl_bicms_sub := reg.vl_bicms_sub;
         nf.vl_icms_sub  := reg.vl_icms_sub;
         nf.vl_bicms     := reg.vl_bicms;
         nf.vl_icms      := reg.vl_bicms;
         nf.vl_bipi      := reg.vl_bipi;
         nf.vl_ipi       := reg.vl_ipi;
      END IF;
      exception
        when others then
             raise_application_error(-20103,'not imp');
      end;


      --| Valor total da nota
      IF (v_comp_icms <> 'S')
         AND (v_comp_ipi <> 'S') THEN
         nf.vl_total := nf.vl_total + nvl(nf.vl_ipi,
                                          0) +
                        nvl(nf.vl_icms_sub,
                            0);
      END IF;
      IF v_comp_ipi = 'S' THEN
         nf.vl_total := nf.vl_total;
      END IF;

      IF v_comp_icms = 'S' THEN
         nf.vl_bicms    := 0;
         nf.vl_icms_sub := 0;
         nf.vl_icms     := nf.vl_total;
      END IF;

         nf.vl_bipi := 0;
         nf.vl_ipi := 0;
         open cr_soma_imp(V_ID_NOTA);
         fetch cr_soma_imp into  nf.vl_bipi,
                                 nf.vl_ipi;
         close cr_soma_imp;

   --begin
      --| PIS e COFINS
      v_piscof := nf.vl_total - nvl(nf.vl_ipi,
                                    0);

      IF reg_opr.pis = 'S' THEN
         nf.vl_pis := round(v_piscof * (v_pis / 100),
                            2);
      END IF;

      IF reg_opr.cofins = 'S' THEN
         nf.vl_cofins := round(v_piscof * (v_cofins / 100),
                               2);
      END IF;

  --exception
   -- when others then
    --  raise_application_error(-20103,'pis-cof');
  --end;
      --ALTRECAO FEITA PELO ORLANDO NOTA DE ENTRADA


         

      IF (v_nat = 'E')
         AND (v_comp_icms = 'N')
         AND (v_comp_ipi = 'N') THEN
         --| Atualiza nota

         IF reg.cod_oper != 31 THEN

            nf.vl_bicms := nf.vl_bicms + nvl(reg.vl_outros,
                                             0);

         END IF;

         UPDATE ft_notas
            SET vl_total     = nf.vl_total,
                vl_produtos  = nf.vl_produtos,
                vl_bicms_sub = nf.vl_bicms_sub,
                vl_icms_sub  = nf.vl_icms_sub,
                vl_bicms     = nf.vl_bicms,
                vl_icms      = (nf.vl_bicms * v_pc_icms / 100),
                vl_bipi      = nf.vl_bipi,
                vl_ipi       = nf.vl_ipi,
                vl_desconto  = nf.vl_desconto,
                vl_bicms_pro = nf.vl_bicms_pro,
                vl_icms_pro  = nf.vl_icms_pro,
                vl_pis       = nf.vl_pis,
                vl_cofins    = nf.vl_cofins,
                vl_binss     = nf.vl_binss,
                vl_inss      = nf.vl_inss,
                vl_biss      = nf.vl_biss,
                vl_iss       = nf.vl_iss,
                aliq_iss     = v_pciss,
                vl_ccp       = nf.vl_ccp,
                vl_desc_ir   = nf.vl_desc_ir,
                pc_desc_ir   = nf.pc_desc_ir
          WHERE empresa = nf.empresa
            AND filial = nf.filial
            AND num_nota = nf.num_nota
            AND sr_nota = nf.sr_nota
            AND parte = nf.parte;
      ELSIF (v_nat = 'S')
            AND (v_comp_icms = 'N')
            AND (v_comp_ipi = 'S') THEN
         --/ 30/04/2008- SLF/ORLANDO:COMPLEMENTO DE IPI

         UPDATE ft_notas
            SET vl_total     = nf.vl_total,
                vl_produtos  = nf.vl_produtos,
                vl_bicms_sub = 0,
                vl_icms_sub  = 0,
                vl_bicms     = 0,
                vl_icms      = 0,
                vl_bipi      = 0,
                vl_ipi       = nf.vl_total,
                vl_desconto  = nf.vl_desconto,
                vl_bicms_pro = nf.vl_bicms_pro,
                vl_icms_pro  = nf.vl_icms_pro,
                vl_pis       = 0,
                vl_cofins    = 0,
                vl_binss     = nf.vl_binss,
                vl_inss      = nf.vl_inss,
                vl_biss      = nf.vl_biss,
                vl_iss       = nf.vl_iss,
                aliq_iss     = v_pciss,
                vl_ccp       = nf.vl_ccp,
                vl_desc_ir   = nf.vl_desc_ir,
                pc_desc_ir   = nf.pc_desc_ir
          WHERE empresa = nf.empresa
            AND filial = nf.filial
            AND num_nota = nf.num_nota
            AND sr_nota = nf.sr_nota
            AND parte = nf.parte;

      ELSE

        nf.vl_total := nf.vl_produtos +
                       nvl(nf.vl_embalagem,0) + 
                       nvl(nf.vl_frete,0) + 
                       nvl(nf.vl_seguro,0) + 
                       nvl(nf.vl_outros,0) - 
                       nvl(nf.vl_desconto,0);

         UPDATE ft_notas
            SET vl_total     = nf.vl_total,
                vl_produtos  = nf.vl_produtos,
                vl_bicms_sub = nf.vl_bicms_sub,
                vl_icms_sub  = nf.vl_icms_sub,
                vl_bicms     = nf.vl_bicms,
                vl_icms      = nf.vl_icms,
                vl_bipi      = nf.vl_bipi,
                vl_ipi       = nf.vl_ipi,
                vl_desconto  = nf.vl_desconto,
                vl_bicms_pro = nf.vl_bicms_pro,
                vl_icms_pro  = nf.vl_icms_pro,
                vl_pis       = nf.vl_pis,
                vl_cofins    = nf.vl_cofins,
                vl_binss     = nf.vl_binss,
                vl_inss      = nf.vl_inss,
                vl_biss      = nf.vl_biss,
                vl_iss       = nf.vl_iss,
                aliq_iss     = v_pciss,
                vl_ccp       = nf.vl_ccp,
                vl_desc_ir   = nf.vl_desc_ir,
                pc_desc_ir   = nf.pc_desc_ir
          WHERE empresa = nf.empresa
            AND filial = nf.filial
            AND num_nota = nf.num_nota
            AND sr_nota = nf.sr_nota
            AND parte = nf.parte;

      END IF;

      IF nnf IS NULL
         OR ser IS NULL THEN

         UPDATE ft_num_nota
            SET num_nota = v_num_nota
          WHERE CURRENT OF cr_num;

         IF v_tipo_nf IN (1, 3,55) THEN
            UPDATE ft_num_nota
               SET num_nota = v_num_nota
             WHERE empresa = emp
               AND filial = fil
               AND tipo_nota IN (1, 3,55);

         END IF;
      END IF;

      --| Mensagens da nota
      IF reg.obs_nota IS NOT NULL THEN
         v_mensagem := sub_msgs(reg.obs_nota,
                                nf.empresa,
                                nf.filial,
                                nf.num_nota,
                                nf.sr_nota);
         IF v_mensagem IS NOT NULL THEN
            INSERT INTO ft_msgs_nf
            VALUES
               (FT_MSGS_NF_ID_SEQ.NEXTVAL,
                NF.ID,
                nf.empresa,
                nf.filial,
                nf.num_nota,
                nf.sr_nota,
                nf.parte,
                ft_msgs_nf_seq.NEXTVAL,
                'M',
                v_mensagem);
         END IF;
      END IF;
      --| Mensagem adicional
      IF comp_nota.msg_adicional IS NOT NULL THEN
         v_mensagem := sub_msgs(comp_nota.msg_adicional,
                                nf.empresa,
                                nf.filial,
                                nf.num_nota,
                                nf.sr_nota);
         IF v_mensagem IS NOT NULL THEN
            INSERT INTO ft_msgs_nf
            VALUES
               (FT_MSGS_NF_ID_SEQ.NEXTVAL,
                NF.ID,
                nf.empresa,
                nf.filial,
                nf.num_nota,
                nf.sr_nota,
                nf.parte,
                ft_msgs_nf_seq.NEXTVAL,
                'M',
                v_mensagem);
         END IF;
      END IF;
      IF v_cod_msg_opr IS NOT NULL THEN
         SELECT mensagem
           INTO v_msg_opr
           FROM ft_msgs
          WHERE cod_msg = v_cod_msg_opr;
         v_mensagem := sub_msgs(v_msg_opr,
                                nf.empresa,
                                nf.filial,
                                nf.num_nota,
                                nf.sr_nota);
         IF v_mensagem IS NOT NULL THEN
            INSERT INTO ft_msgs_nf
            VALUES
               (FT_MSGS_NF_ID_SEQ.NEXTVAL,
                NF.ID,
                nf.empresa,
                nf.filial,
                nf.num_nota,
                nf.sr_nota,
                nf.parte,
                ft_msgs_nf_seq.NEXTVAL,
                'M',
                v_mensagem);
         END IF;
      END IF;
      --raise_application_error(-20100,'AKI 7'||' '||t_msg(1));

      FOR n IN 1 .. t_msg.COUNT LOOP
         SELECT mensagem
           INTO v_mensagem
           FROM ft_msgs
          WHERE cod_msg = t_msg(n);
         v_mensagem := sub_msgs(v_mensagem,
                                nf.empresa,
                                nf.filial,
                                nf.num_nota,
                                nf.sr_nota);
         IF v_mensagem IS NOT NULL THEN
            INSERT INTO ft_msgs_nf
            VALUES
               (FT_MSGS_NF_ID_SEQ.NEXTVAL,
                NF.ID,
                nf.empresa,
                nf.filial,
                nf.num_nota,
                nf.sr_nota,
                nf.parte,
                ft_msgs_nf_seq.NEXTVAL,
                'M',
                v_mensagem);
         END IF;
      END LOOP;

      IF nvl(nf.vl_desconto,
             0) > 0 THEN
         v_mensagem := 'PRECO MERCAD: ' ||
                       ltrim(to_char(nf.vl_produtos + nf.vl_desconto,
                                     '999G999G990D00')) || ' DESCTO: ' ||
                       ltrim(to_char(nf.vl_desconto,
                                     '999G999G990D00')) || ' LIQUID: ' ||
                       ltrim(to_char(nf.vl_produtos,
                                     '999G999G990D00'));
         IF v_mensagem IS NOT NULL THEN
            INSERT INTO ft_msgs_nf
            VALUES
               (FT_MSGS_NF_ID_SEQ.NEXTVAL,
                NF.ID,
                nf.empresa,
                nf.filial,
                nf.num_nota,
                nf.sr_nota,
                nf.parte,
                ft_msgs_nf_seq.NEXTVAL,
                'M',
                v_mensagem);
         END IF;
      END IF;

      --| Parcelas da nota, se nao for entrada
      IF reg_opr.natureza = 'S'
         AND reg_cfo.atl_crec = 'S' THEN

         IF reg_opr.ret_iss = 'S' THEN
            v_iss := nvl(nf.vl_iss,
                         0);
         ELSE
            v_iss := 0;
         END IF;
         v_parc := 0;

         FOR reg_pp IN cr_par LOOP
            IF reg_pp.dt_vence IS NULL THEN
               v_dt_base := nvl(g_data_saida,
                                trunc(dta)) + nvl(reg_pp.dias,
                                                  0) +
                            nvl(g_dias_mais,
                                0);
            ELSE
               v_dt_base := reg_pp.dt_vence + nvl(g_dias_mais,
                                                  0);
            END IF;
            v_dt_base := lib_data.util(nf.empresa,
                                       v_dt_base,
                                       nf.firma);
            v_dt_base := prx_dia(v_dt_base,
                                 v_dia1,
                                 v_dia2,
                                 v_dia3);
            v_dt_base := lib_data.util(nf.empresa,
                                       v_dt_base,
                                       nf.firma);

            IF nvl(reg_pp.pc_valor,
                   0) > 0 THEN
               INSERT INTO ft_parc_nf
               VALUES
                  (FT_PARC_NF_SEQ.NEXTVAL,
                NF.ID,
                nf.empresa,
                   nf.filial,
                   nf.num_nota,
                   nf.sr_nota,
                   nf.parte,
                   trunc(v_dt_base),
                   round(nf.vl_total - v_iss - nvl(nf.vl_ccp,
                                                   0) -
                         nvl(nf.vl_inss,
                             0) -
                         nvl(nf.vl_desc_ir,
                             0) * round((reg_pp.pc_valor / 100),
                                        2)),
                   reg_pp.c_apresent);
            ELSE
               INSERT INTO ft_parc_nf
               VALUES
                  (FT_PARC_NF_SEQ.NEXTVAL,
                NF.ID,
                nf.empresa,
                   nf.filial,
                   nf.num_nota,
                   nf.sr_nota,
                   nf.parte,
                   trunc(v_dt_base),
                   reg_pp.valor,
                   reg_pp.c_apresent);
            END IF;

            v_parc   := v_parc + 1;
            v_pc_val := reg_pp.pc_valor;
         END LOOP;

         --| Nao existem parcelas no pedido : verifica pela condicao de pagamento
         IF v_parc = 0
            AND nf.cod_condpag IS NOT NULL THEN
            SELECT ct_apres,
                   a_vista
              INTO v_ct_apres,
                   v_avista
              FROM ft_condpag
             WHERE cod_condpag = nf.cod_condpag;
            IF v_avista = 'S' THEN
               INSERT INTO ft_parc_nf
               VALUES
                  (FT_PARC_NF_SEQ.NEXTVAL,
                NF.ID,
                nf.empresa,
                   nf.filial,
                   nf.num_nota,
                   nf.sr_nota,
                   nf.parte,
                   trunc(nvl(g_data_saida,
                             dta)),
                   nf.vl_total - v_iss - nvl(nf.vl_ccp,
                                             0) -
                   nvl(nf.vl_inss,
                       0) - nvl(nf.vl_desc_ir,
                                0),
                   v_ct_apres);
            ELSE
               FOR reg_cp IN cr_cp(nf.cod_condpag) LOOP
                  v_dt_base := nvl(g_data_saida,
                                   trunc(dta)) + reg_cp.dias +
                               nvl(g_dias_mais,
                                   0);
                  v_dt_base := lib_data.util(nf.empresa,
                                             v_dt_base,
                                             nf.firma);
                  v_dt_base := prx_dia(v_dt_base,
                                       v_dia1,
                                       v_dia2,
                                       v_dia3);
                  v_dt_base := lib_data.util(nf.empresa,
                                             v_dt_base,
                                             nf.firma);
                  INSERT INTO ft_parc_nf
                  VALUES
                     (FT_PARC_NF_SEQ.NEXTVAL,
                NF.ID,
                nf.empresa,
                      nf.filial,
                      nf.num_nota,
                      nf.sr_nota,
                      nf.parte,
                      trunc(v_dt_base),
                      round(nf.vl_total - v_iss -
                            nvl(nf.vl_ccp,
                                0) - nvl(nf.vl_inss,
                                         0) -
                            nvl(nf.vl_desc_ir,
                                0) * (reg_cp.pc_parcela / 100),
                            2),
                      v_ct_apres);
               END LOOP;
            END IF;
         END IF;

         v_pnf := 0;
         FOR reg_pnf IN cr_pnf(nf.empresa,
                               nf.filial,
                               nf.num_nota,
                               nf.sr_nota,
                               nf.parte) LOOP
            v_pnf := v_pnf + reg_pnf.valor;
         END LOOP;
         v_pnf := nf.vl_total - v_iss - nvl(nf.vl_ccp,
                                            0) -
                  nvl(nf.vl_inss,
                      0) - nvl(nf.vl_desc_ir,
                               0) - v_pnf;
         IF v_pnf <> 0 THEN
            OPEN cr_pnf(nf.empresa,
                        nf.filial,
                        nf.num_nota,
                        nf.sr_nota,
                        nf.parte);
            FETCH cr_pnf
               INTO reg_pn;
            if cr_pnf%found then
              UPDATE ft_parc_nf
                 SET valor = valor + v_pnf
               WHERE CURRENT OF cr_pnf;
            end if;
            CLOSE cr_pnf;
         END IF;

      END IF; -- Se nao for devolucao...
  
      IF resultado.numero_inicial IS NULL THEN
         resultado.numero_inicial := v_num_nota;
      END IF;
      resultado.numero_final := v_num_nota;

      nnf := nf.num_nota;
      ser := nf.sr_nota;

   END;

   --------------------------------------------------------------------------------
   PROCEDURE estoque_nf(emp  IN ft_notas.empresa%TYPE,
                        fil  IN ft_notas.filial%TYPE,
                        num  IN ft_notas.num_nota%TYPE,
                        ser  IN ft_notas.sr_nota%TYPE,
                        v_nf IN ft_notas.num_nota%TYPE,
                        v_sr IN ft_notas.sr_nota%TYPE,
                        px   IN ft_notas.parte%TYPE)
   /*
      || Movimenta estoque
      */
    IS

      reg      ft_notas%ROWTYPE;
      reg_cfo  ft_cfo%ROWTYPE;
      reg_oper ft_oper%ROWTYPE;

      CURSOR cr_i IS
         SELECT *
           FROM ft_itens_nf
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = num
            AND sr_nota = ser
            AND parte = px
            FOR UPDATE;

      CURSOR cr_loc(o ft_oper_loc.cod_oper%TYPE, e ft_oper_loc.empresa%TYPE, f ft_oper_loc.filial%TYPE) IS
         SELECT *
           FROM ft_oper_loc
          WHERE cod_oper = o
            AND empresa = e
            AND filial = f;

      CURSOR cr_local(pc_pro ce_produtos.produto%TYPE, pc_dat ft_notas.dt_emissao%TYPE) IS
         SELECT a.LOCAL LOCAL
           FROM ce_saldo_local a
          WHERE a.empresa = emp
            AND a.filial = fil
            AND a.produto = pc_pro
            AND a.dt_saldo <= trunc(pc_dat)
            AND a.saldo_fisico > 0
            AND a.dt_saldo =
                (SELECT MAX(dt_saldo)
                   FROM ce_saldo_local c
                  WHERE c.empresa = a.empresa
                    AND c.filial = a.filial
                    AND c.produto = a.produto
                    AND c.LOCAL = a.LOCAL
                    AND c.dt_saldo <= trunc(pc_dat))
          ORDER BY a.saldo_fisico ASC,
                   a.empresa,
                   a.filial,
                   a.LOCAL,
                   a.produto,
                   a.dt_saldo DESC;

      CURSOR cr_local_std(p_pro ce_produtos.produto%TYPE) IS
         SELECT a.loc_padrao LOCAL
           FROM ce_uniprod a
          WHERE a.empresa = emp
            AND a.filial = fil
            AND a.produto = p_pro;

      CURSOR curtransf(pc_emp fs_transf.empresa%TYPE, pc_fil fs_transf.fil_origem%TYPE, pc_cfo fs_transf.cfo_origem%TYPE, pc_des fs_transf.fil_destino%TYPE) IS
         SELECT local_destino
           FROM fs_transf
          WHERE empresa = pc_emp
            AND fil_origem = pc_fil
            AND cfo_origem = pc_cfo
            AND fil_destino = pc_des;

      reg_loc ft_oper_loc%ROWTYPE;

      v_seq1            NUMBER;
      v_seq2            NUMBER;
      v_custo           NUMBER;
      v_oper_desc       ce_operacoes.descricao%TYPE;
      v_local           ce_locest.LOCAL%TYPE;
      v_fil_local       ce_locest.filial%TYPE;
      v_local_destino   fs_transf.local_destino%TYPE;
      v_filial          cd_firmas.filial%TYPE;
      v_operacao_transf ce_param.cod_oper_tre%TYPE;
      v_aux2 varchar2(100);
   BEGIN

      IF num IS NULL THEN
         RETURN;
      END IF;
v_aux2 := 'estoque_nf:01';
      --| Le a nota
      SELECT *
        INTO reg
        FROM ft_notas
       WHERE empresa = emp
         AND filial = fil
         AND num_nota = num
         AND sr_nota = ser
         AND parte = px;
v_aux2 := 'estoque_nf:02';
      --| Le CFO para verificar os procedimento de integracao
      SELECT *
        INTO reg_cfo
        FROM ft_cfo
       WHERE cod_cfo = reg.cod_cfo;
v_aux2 := 'estoque_nf:03';
      --| Le FT_OPER para verificar natureza
      SELECT *
        INTO reg_oper
        FROM ft_oper
       WHERE empresa = reg.empresa
         AND cod_oper = reg.cod_oper;
v_aux2 := 'estoque_nf:04';
      --| Verifica se atualiza estoque
      IF reg_cfo.atl_estq = 'N' THEN
         RETURN;
      END IF;
v_aux2 := 'estoque_nf:05';
      --| Verifica os locais de movimentacao do estoque
      OPEN cr_loc(reg_oper.cod_oper,
                  emp,
                  fil);
      FETCH cr_loc
         INTO reg_loc;
      IF cr_loc%NOTFOUND THEN
         --    raise_application_error(-20102, 'Falta registro de locais para operac?o');
         NULL;
      END IF;
v_aux2 := 'estoque_nf:06';
      --| Percorre os itens da nota lancando no estoque
      FOR rgi IN cr_i LOOP

         v_seq1 := NULL;
         v_seq2 := NULL;

         --| Calcula o custo do movimento
v_aux2 := 'estoque_nf:07';
         v_custo := custo_pro(reg_oper,
                              reg,
                              rgi);
v_aux2 := 'estoque_nf:07-01a';                              
         --raise_application_error(-20103,rgi.produto);
         --| Movimento 1
         v_local := nvl(comp_nota.local_sai,
                        reg_loc.local_sai);
v_aux2 := 'estoque_nf:07-01b';                              
         IF v_local IS NULL THEN
            -- achar o local conforme saldo
            v_local := NULL;
            OPEN cr_local_std(rgi.produto);
            FETCH cr_local_std
               INTO v_local;
            IF cr_local_std%NOTFOUND THEN
               CLOSE cr_local_std;
               raise_application_error(-20103,
                                       'FT_NF.ESTOQUE_NF:Falta Local de Estoque na tabela de operacoes e no Movimento.');
            END IF;
            CLOSE cr_local_std;
         END IF;
v_aux2 := 'estoque_nf:07-01c';                              
         /*
             if rgi.produto = 8964 then

                raise_application_error(-20103, 'local'||v_local);
             end if;
         */
         
         IF v_local IS NOT NULL THEN
            SELECT ce_movest_seq.NEXTVAL
              INTO v_seq1
              FROM dual;
            IF reg_oper.cod_opr_est IS NULL THEN
               raise_application_error(-20103,
                                       'Falta codigo de opr.estoque 1 na tabela de operacoes');
            END IF;
v_aux2 := 'estoque_nf:07-01d';                                          
            SELECT descricao
              INTO v_oper_desc
              FROM ce_operacoes
             WHERE empresa = rgi.empresa
               AND cod_oper = reg_oper.cod_opr_est;
               
            --|zxcv
            /*
                  if rgi.produto = 6091 then
                     v_local := '323.13.T.01';
                  end if;
            */
v_aux2 := 'estoque_nf:07-02';
            INSERT INTO ce_movest
            VALUES
               (v_seq1,
                rgi.empresa,
                nvl(v_fil_local,
                    fil),
                v_local,
                rgi.produto,
                rgi.qtd * ce_unid_utl.fator(rgi.uni_ven,
                                            rgi.uni_est),
                (rgi.qtd * ce_unid_utl.fator(rgi.uni_ven,
                                             rgi.uni_est) * v_custo),
                to_char(rgi.num_nota) || '.' || rgi.sr_nota,
                reg_oper.cod_opr_est,
                reg.dt_emissao,
                v_oper_desc || ' N.F. ' || to_char(v_nf) || '.' || v_sr,
                NULL,
                'N',
                SYSDATE,
                rgi.qtd_val,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL);

            --vg_custo_med := nvl(vg_custo_med,0) + (rgi.qtd * ce_unid_utl.fator(rgi.uni_ven,rgi.uni_est) * v_custo);
         END IF;
v_aux2 := 'estoque_nf:07-03';
         --| Movimento 2
         IF nvl(comp_nota.local_ent,
                reg_loc.local_ent) IS NOT NULL THEN
            SELECT ce_movest_seq.NEXTVAL
              INTO v_seq2
              FROM dual;
            IF reg_oper.cod_opr_est2 IS NULL THEN
               raise_application_error(-20104,
                                       'Falta codigo de opr.estoque 2 na tabela de operacoes');
            END IF;
            
v_aux2 := 'estoque_nf:07-04';            
            SELECT descricao
              INTO v_oper_desc
              FROM ce_operacoes
             WHERE empresa = rgi.empresa
               AND cod_oper = reg_oper.cod_opr_est2;
v_aux2 := 'estoque_nf:07-05';
            IF reg_cfo.natureza = 'E' THEN
               v_fil_local := nvl(rgi.fil_local,
                                  rgi.filial);
               v_local     := rgi.LOCAL;
               IF v_local IS NULL THEN
                  v_local := nvl(comp_nota.local_ent,
                                 reg_loc.local_ent);
               END IF;
            ELSE
               v_local := nvl(comp_nota.local_ent,
                              reg_loc.local_ent);
               --v_fil_local := rgi.filial;
               v_fil_local := nvl(rgi.fil_local,
                                  rgi.filial);
            END IF;
            --|zxcv
            /*
            if rgi.produto = 6091 then
               v_local := '323.13.T.01';
            end if;
            */
v_aux2 := 'estoque_nf:07-06';            
            INSERT INTO ce_movest
            VALUES
               (v_seq2,
                rgi.empresa,
                nvl(v_fil_local,
                    fil),
                v_local,
                rgi.produto,
                rgi.qtd * ce_unid_utl.fator(rgi.uni_ven,
                                            rgi.uni_est),
                (rgi.qtd * ce_unid_utl.fator(rgi.uni_ven,
                                             rgi.uni_est) * v_custo),
                to_char(rgi.num_nota) || '.' || rgi.sr_nota,
                reg_oper.cod_opr_est2,
                reg.dt_emissao,
                v_oper_desc || ' N.F. ' || to_char(v_nf) || '.' || v_sr,
                NULL,
                'N',
                SYSDATE,
                rgi.qtd_val,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL);
         END IF;
v_aux2 := 'estoque_nf:07-07';
         --| Sendo Transferencia, fazer entrada no estoque da filial destino
         SELECT filial
           INTO v_filial
           FROM cd_firmas
          WHERE firma = reg.firma;
          
         IF v_filial IS NOT NULL THEN
            v_local_destino := NULL;
            OPEN curtransf(reg.empresa,
                           reg.filial,
                           reg.cod_cfo,
                           v_filial);
            FETCH curtransf
               INTO v_local_destino;
            CLOSE curtransf;
            IF v_local_destino IS NOT NULL THEN
               SELECT cod_oper_tre
                 INTO v_operacao_transf
                 FROM ce_param
                WHERE empresa = reg.empresa;
v_aux2 := 'estoque_nf:07-08';                
                
               INSERT INTO ce_movest
               VALUES
                  (ce_movest_seq.NEXTVAL,
                   reg.empresa,
                   v_filial,
                   v_local_destino,
                   rgi.produto,
                   rgi.qtd * ce_unid_utl.fator(rgi.uni_ven,
                                               rgi.uni_est),
                   (rgi.qtd_val * rgi.valor_unit) -
                   nvl(rgi.vl_icms,
                       0),
                   to_char(rgi.num_nota) || '.' || rgi.sr_nota,
                   v_operacao_transf,
                   reg.dt_emissao,
                   'ENTRADA POR TRANSFERENCIA N.F. ' || to_char(v_nf) || '.' || v_sr,
                   NULL,
                   'N',
                   SYSDATE,
                   rgi.qtd_val,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
            END IF;
         END IF;
v_aux2 := 'estoque_nf:08';
         UPDATE ft_itens_nf
            SET seq_movest1 = v_seq1,
                seq_movest2 = v_seq2
          WHERE CURRENT OF cr_i;

      END LOOP;
      /*
      EXCEPTION
        WHEN OTHERS THEN
           IF SQLCODE NOT IN (-20104,-20103,-20102) THEN
              RAISE_APPLICATION_ERROR(-20101, v_aux2||SUBSTR(SQLERRM,1,100));
           END IF;
           RAISE;
      */
   END;

   --------------------------------------------------------------------------------
   PROCEDURE crec_nf(emp     IN ft_notas.empresa%TYPE,
                     fil     IN ft_notas.filial%TYPE,
                     num     IN ft_notas.num_nota%TYPE,
                     ser     IN ft_notas.sr_nota%TYPE,
                     reg_ped IN ft_pedidos%ROWTYPE)
   /*
      || Integracao com contas a receber
      */
    IS

      reg      ft_notas%ROWTYPE;
      reg_cfo  ft_cfo%ROWTYPE;
      reg_oper ft_oper%ROWTYPE;
      reg_fnp  fn_prgen%ROWTYPE;

      CURSOR cr_ultdup(emp fn_param.empresa%TYPE) IS
         SELECT ult_duplic
           FROM fn_param
          WHERE empresa = emp
            FOR UPDATE OF ult_duplic;

      CURSOR cr_nf IS
         SELECT *
           FROM ft_notas
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = num
            AND sr_nota = ser;
      --/
      CURSOR cri(p NUMBER) IS
         SELECT *
           FROM ft_itens_nf
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = num
            AND sr_nota = ser
            AND parte = p;
      --/
      CURSOR cr_parc(p NUMBER) IS
         SELECT *
           FROM ft_parc_nf
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = num
            AND sr_nota = ser
            AND parte = p
          ORDER BY dt_vence;
      --/
      CURSOR cru(nt IN fn_itens_dup.num_titulo%TYPE, st IN fn_itens_dup.seq_titulo%TYPE, p IN NUMBER) IS
         SELECT *
           FROM fn_itens_dup
          WHERE empresa = emp
            AND filial = fil
            AND num_titulo = nt
            AND seq_titulo = st
            AND parte = p
            FOR UPDATE;
      --/
      CURSOR curped IS
         SELECT p.op_os,
                p.tipo_tit
           FROM ft_pedidos p,
                ft_notas   n
          WHERE p.empresa = n.empresa
            AND p.filial = n.filial
            AND p.num_pedido = n.num_pedido
            AND n.empresa = emp
            AND n.filial = fil
            AND n.num_nota = num
            AND n.sr_nota = ser;
      --/
      CURSOR crcon(p_op pp_ordens.ordem%TYPE) IS
         SELECT contrato
           FROM pp_ordens a
          WHERE a.empresa = emp
            AND filial = fil
            AND ordem = p_op;

      v_ult_duplic    fn_param.ult_duplic%TYPE;
      v_pos_aberto    fn_prgen.pos_aberto%TYPE;
      v_cont_fisico   CHAR(1);
      v_cs            ft_param.cod_servico%TYPE;
      v_cont_tot      NUMBER;
      v_firma         cd_firmas.firma%TYPE;
      v_cod_historico NUMBER;
      v_avista        ft_condpag.a_vista%TYPE;
      v_sm            NUMBER;
      v_dm            DATE;
      v_seq           NUMBER;
      v_totrec        NUMBER;
      v_qp            NUMBER;
      v_pruni         NUMBER;
      v_op_os         ft_pedidos.op_os%TYPE;
      v_tipo_tit      ft_pedidos.tipo_tit%TYPE;
      v_apr           CHAR(1);
      v_dtv           DATE;
      v_vlr           NUMBER;
      v_contrato      NUMBER(9);
   BEGIN

      --| Le a nota
      FOR reg IN cr_nf LOOP
         -- Open crCon(reg.
         --| Le CFO para verificar os procedimento de integracao
         SELECT *
           INTO reg_cfo
           FROM ft_cfo
          WHERE cod_cfo = reg.cod_cfo;

         --| Le FT_OPER para verificar natureza
         SELECT *
           INTO reg_oper
           FROM ft_oper
          WHERE empresa = reg.empresa
            AND cod_oper = reg.cod_oper;

         --| Se atualiza c.receber
         IF reg_cfo.atl_crec <> 'S'
            OR reg_oper.natureza <> 'S' THEN
            RETURN;
         END IF;

         --| Verifica se operacao de remessa, que gera cobranca para o agente1
         IF reg_oper.remessa = 'S'
            AND reg.agente1 IS NOT NULL THEN
            v_firma := reg.firma;
         ELSE
            v_firma := reg.firma;
         END IF;

         --| Pedido
         OPEN curped;
         FETCH curped
            INTO v_op_os, v_tipo_tit;
         CLOSE curped;

         --| Le Condicao de Pagamento
         SELECT a_vista
           INTO v_avista
           FROM ft_condpag
          WHERE cod_condpag = reg.cod_condpag;

         --| Gerar conta corrente caso NAO seja a vista, senao, gera contas a receber
         IF FALSE
            AND v_avista <> 'S' THEN

            SELECT COUNT(*)
              INTO v_qp
              FROM ft_parc_nf
             WHERE empresa = emp
               AND filial = fil
               AND num_nota = num
               AND sr_nota = ser
               AND parte = reg.parte;

            --| Para cada parcela da nota
            v_sm := 0;
            FOR reg_par IN cr_parc(reg.parte) LOOP
               v_dm := add_months(reg.dt_emissao,
                                  v_sm);
               v_sm := v_sm + 1;
            END LOOP;

            --| Atualiza Limite de Credito
            IF v_avista <> 'S' THEN
               IF reg_oper.credito = 'S' THEN
                  UPDATE cd_firmas
                     SET vl_usado = nvl(vl_usado,
                                        0) + reg.vl_total
                   WHERE firma = v_firma;
               END IF;
            END IF;

            resultado.titulo_inicial := 0;
            resultado.titulo_final   := 0;
            RETURN;
         END IF;

         --| Ultimo nr de duplicata
         OPEN cr_ultdup(emp);
         FETCH cr_ultdup
            INTO v_ult_duplic;

         --| Posicao de duplicata em aberto
         SELECT pos_aberto
           INTO v_pos_aberto
           FROM fn_prgen;
         SELECT cont_fisico
           INTO v_cont_fisico
           FROM fn_param
          WHERE empresa = emp;

         v_totrec := 0;

         --| Para cada parcela da nota
         FOR reg_par IN cr_parc(reg.parte) LOOP
            v_apr := reg_par.c_apresent;
            v_dtv := trunc(reg_par.dt_vence);
            v_vlr := reg_par.valor;

            v_ult_duplic := nvl(v_ult_duplic,
                                0) + 1;

            IF reg_oper.pre_pago = 'N' THEN
               INSERT INTO fn_ctrec
               VALUES
                  (reg.empresa,
                   reg.filial,
                   v_ult_duplic,
                   1,
                   reg.parte,
                   v_firma,
                   reg.dt_emissao,
                   reg_par.dt_vence,
                   reg_par.valor,
                   reg.tipo_tit,
                   reg.tipo_cob,
                   reg.tp_juros,
                   reg.pc_juros,
                   reg.pc_multa,
                   reg.pc_desc,
                   reg_par.dt_vence - nvl(reg.dias_desc,
                                          0),
                   reg_par.dt_vence + nvl(reg.dias_multa,
                                          0),
                   reg_par.dt_vence + nvl(reg.dias_juros,
                                          0),
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   reg.banco,
                   NULL,
                   reg.num_nota, --null,
                   comp_nota.obs_titulo,
                   NULL,
                   NULL,
                   NULL,
                   reg.agente1,
                   reg.agente2,
                   reg.producao,
                   v_pos_aberto,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   'A',
                   'N',
                   reg_par.c_apresent,
                   NULL,
                   reg.periodo,
                   '',
                   '',
                   0,
                   v_avista,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   reg_oper.inc_ccp,
                   NULL,
                   v_contrato,
                   reg.sr_nota,
                   reg.id,
                   null, --vl_retencao
                   null, --vl_ret_irrf
                   null
                   );
            ELSE
               IF reg_par.c_apresent = 'N' THEN
                  UPDATE fn_ctrec
                     SET tipo_tit  = v_tipo_tit,
                         documento = reg_par.num_nota,
                         dt_movim  = reg.dt_emissao,
                         dt_vence  = reg_par.dt_vence,
                         inc_ccp   = reg_oper.inc_ccp
                   WHERE empresa = reg_par.empresa
                     AND filial = reg_par.filial
                     AND ordem = v_op_os
                     AND dt_vence <= reg_par.dt_vence
                     AND valor = reg_par.valor
                     AND status = 'A'
                     AND documento <> to_char(reg_par.num_nota)
                     AND rownum = 1;
                  IF SQL%ROWCOUNT = 0 THEN
                     UPDATE fn_ctrec
                        SET tipo_tit  = v_tipo_tit,
                            documento = reg_par.num_nota,
                            dt_movim  = reg.dt_emissao,
                            inc_ccp   = reg_oper.inc_ccp
                      WHERE empresa = reg_par.empresa
                        AND filial = reg_par.filial
                        AND ordem = v_op_os
                        AND dt_vence > reg_par.dt_vence
                        AND valor = reg_par.valor
                        AND status = 'A'
                        AND documento <> to_char(reg_par.num_nota)
                        AND rownum < 2;
                     IF SQL%ROWCOUNT = 0 THEN

                        INSERT INTO fn_ctrec
                        VALUES
                           (reg.empresa,
                            reg.filial,
                            v_ult_duplic,
                            1,
                            reg.parte,
                            v_firma,
                            reg.dt_emissao,
                            reg_par.dt_vence,
                            reg_par.valor,
                            reg.tipo_tit,
                            reg.tipo_cob,
                            reg.tp_juros,
                            reg.pc_juros,
                            reg.pc_multa,
                            reg.pc_desc,
                            reg_par.dt_vence - nvl(reg.dias_desc,
                                                   0),
                            reg_par.dt_vence + nvl(reg.dias_multa,
                                                   0),
                            reg_par.dt_vence + nvl(reg.dias_juros,
                                                   0),
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            reg.banco,
                            NULL,
                            reg.num_nota, --null,
                            comp_nota.obs_titulo,
                            NULL,
                            NULL,
                            NULL,
                            reg.agente1,
                            reg.agente2,
                            reg.producao,
                            v_pos_aberto,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            'A',
                            'N',
                            reg_par.c_apresent,
                            NULL,
                            reg.periodo,
                            '',
                            '',
                            0,
                            'S',
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            reg_oper.inc_ccp,
                            NULL,
                            v_contrato,
                            reg.sr_nota,
                            reg.id,
                            null, --vl_retencao
                             null, --vl_ret_irrf
                             null
                             );
                     END IF;
                  END IF;
               ELSE
                  INSERT INTO fn_ctrec
                  VALUES
                     (reg.empresa,
                      reg.filial,
                      v_ult_duplic,
                      1,
                      reg.parte,
                      v_firma,
                      reg.dt_emissao,
                      reg.dt_emissao, --reg_par.dt_vence,
                      reg_par.valor,
                      reg.tipo_tit,
                      reg.tipo_cob,
                      reg.tp_juros,
                      reg.pc_juros,
                      reg.pc_multa,
                      reg.pc_desc,
                      reg_par.dt_vence - nvl(reg.dias_desc,
                                             0),
                      reg_par.dt_vence + nvl(reg.dias_multa,
                                             0),
                      reg_par.dt_vence + nvl(reg.dias_juros,
                                             0),
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      reg.banco,
                      NULL,
                      reg.num_nota, --null,
                      comp_nota.obs_titulo,
                      NULL,
                      NULL,
                      NULL,
                      reg.agente1,
                      reg.agente2,
                      reg.producao,
                      v_pos_aberto,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      'A',
                      'N',
                      reg_par.c_apresent,
                      NULL,
                      reg.periodo,
                      '',
                      '',
                      0,
                      'S',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      reg_oper.inc_ccp,
                      NULL,
                      v_contrato,
                      reg.sr_nota,
                      reg.id,
                      null, -- vl_retencao
                      null,  --vl_ret_irrf
                      null
                      );
               END IF;
            END IF;
            v_totrec := v_totrec + reg_par.valor;

            IF reg_oper.pre_pago = 'N' THEN
               --| Itens da duplicata
               IF v_cont_fisico = 'S' THEN

                  -- Gera itens pelos itens das notas
                  FOR rgi IN cri(reg.parte) LOOP
                     INSERT INTO fn_itens_dup
                     VALUES
                        (reg.empresa,
                         reg.filial,
                         v_ult_duplic,
                         1,
                         reg.parte,
                         fn_itens_dup_seq.NEXTVAL,
                         rgi.produto,
                         rgi.qtd,
                         (rgi.qtd_val * rgi.valor_unit),
                         0,
                         0,
                         NULL,
                         reg.num_nota,
                         reg.sr_nota,
                         0,
                         NULL,
                         RGI.ID);
                  END LOOP;
               ELSE
                  -- Sem controle fisico

                  FOR rgi IN cri(reg.parte) LOOP

                     IF nvl(rgi.pruni_sst,
                            0) > 0 THEN
                        v_pruni := rgi.pruni_sst;
                     ELSE
                        v_pruni := rgi.valor_unit;
                     END IF;
                     INSERT INTO fn_itens_dup
                     VALUES
                        (reg.empresa,
                         reg.filial,
                         v_ult_duplic,
                         1,
                         reg.parte,
                         fn_itens_dup_seq.NEXTVAL,
                         rgi.produto,
                         1,
                         round(reg_par.valor * (rgi.qtd_val * v_pruni) /
                               (reg.vl_produtos + nvl(reg.vl_servicos,
                                                      0)),
                               2),
                         0,
                         0,
                         NULL,
                         reg.num_nota,
                         reg.sr_nota,
                         0,
                         NULL,
                         RGI.ID);
                  END LOOP;

                  IF reg.vl_servicos > 0 THEN
                     SELECT cod_servico
                       INTO v_cs
                       FROM ft_param
                      WHERE empresa = reg.empresa;
                     IF v_cs IS NOT NULL THEN
                        INSERT INTO fn_itens_dup
                        VALUES
                           (reg.empresa,
                            reg.filial,
                            v_ult_duplic,
                            1,
                            reg.parte,
                            fn_itens_dup_seq.NEXTVAL,
                            v_cs,
                            1,
                            round(reg_par.valor * reg.vl_servicos /
                                  (reg.vl_produtos +
                                  nvl(reg.vl_servicos,
                                       0)),
                                  2),
                            0,
                            0,
                            NULL,
                            reg.num_nota,
                            reg.sr_nota,
                            0,
                            NULL,
                            REG.ID);
                     END IF;
                  END IF;
               END IF;

            END IF;

            --| Se nao tem controle fisico, percorre as parcelas novamente
            --| ajustando os valor da primeira para tirar a diferenca
            IF reg_oper.pre_pago = 'N' THEN
               IF v_cont_fisico = 'N' THEN
                  v_cont_tot := 0;
                  FOR rgu IN cru(v_ult_duplic,
                                 1,
                                 reg.parte) LOOP
                     v_cont_tot := v_cont_tot + rgu.valor;
                  END LOOP;
                  -- Se total for diferente da parcela, ajusta pela diferenca
                  IF v_cont_tot <> reg_par.valor THEN
                     FOR rgu IN cru(v_ult_duplic,
                                    1,
                                    reg.parte) LOOP
                        UPDATE fn_itens_dup
                           SET valor = valor + (reg_par.valor - v_cont_tot)
                         WHERE CURRENT OF cru;
                        EXIT;
                     END LOOP;
                  END IF;
               END IF;
            END IF;

            IF resultado.titulo_inicial IS NULL THEN
               resultado.titulo_inicial := v_ult_duplic;
            END IF;
            resultado.titulo_final := v_ult_duplic;

         END LOOP;

         -- raise_application_error('-20100',v_op_os||'pr'||reg_oper.pre_pago||' '||v_apr||' '||v_dtv||' '||v_vlr);

         --| Atualiza numero da ultima duplicata
         UPDATE fn_param
            SET ult_duplic = v_ult_duplic
          WHERE CURRENT OF cr_ultdup;
         CLOSE cr_ultdup;

         --| Atualiza Limite de Credito
         IF v_avista <> 'S' THEN
            IF reg_oper.credito = 'S' THEN
               UPDATE cd_firmas
                  SET vl_usado = nvl(vl_usado,
                                     0) + reg.vl_total
                WHERE firma = v_firma;
            END IF;
         END IF;

      END LOOP;

   END;
   --------------------------------------------------------------------------------
   PROCEDURE transporte_nf( emp  IN ft_notas.empresa%TYPE,
                            fil  IN ft_notas.filial%TYPE,
                            num  IN ft_notas.num_nota%TYPE,
                            ser  IN ft_notas.sr_nota%TYPE) is
   /*
   cria dados de transporte
   */
   cursor crBusca is
     select f.id
       from ft_transporte f
          , ft_notas n
       where f.id_ft_nota = n.id
         and n.empresa = emp
         AND n.filial = fil
         AND n.num_nota = num
         AND n.sr_nota = ser
         AND n.parte = 0;
       
   reg     ft_notas%ROWTYPE;
   v_id number(9);
   v_id_vol number(9);
   v_mod_frete ft_transporte.modalidade_frete%type;
   v_achou number(9) := 0;
   
   begin
     open crBusca;
     fetch crBusca into v_achou;
     close crBusca;
     
     if nvl(v_achou,0) > 0 then
       return;
     end if;
     
      --| Le a nota
      SELECT *
        INTO reg
        FROM ft_notas f
       WHERE empresa = emp
         AND filial = fil
         AND num_nota = num
         AND sr_nota = ser
         AND parte = 0;
         
      select ft_transporte_seq.nextval into v_id from dual;
      if reg.tp_frete = 'E' then
         v_mod_frete := 0;
       else
         v_mod_frete := 1;
      end if;
      
      insert into ft_transporte(id,
                                id_ft_nota,
                                modalidade_frete,
                                cod_transp,
                                cpf_cnpj,
                                motorista,
                                inscricao_estadual,
                                endereco,
                                nome_municipio,
                                uf,
                                valor_servico,
                                base_calculo_retencao_icms,
                                aliquota_retencao_icms,
                                valor_icms_retido,
                                cfop,
                                MUNICIPIO_ICMS,
                                placa_veiculo,
                                uf_veiculo,
                                rntc_veiculo,
                                CPF_MOTORISTA)
                           values(
                                v_id,
                                reg.id,
                                v_mod_frete, --modalidade_frete,
                                reg.firma, --cod_transp,
                                reg.CNPJ_CPF, --cpf_cnpj,
                                reg.motorista,
                                reg.iest, --inscricao_estadual,
                                cd_firmas_utl.endereco_com_numero(reg.firma),
                                cd_firmas_utl.cidade(reg.firma),--nome_municipio,
                                cd_firmas_utl.uf(reg.firma),
                                reg.vl_frete, --valor_servico,
                                0, --base_calculo_retencao_icms,
                                null,-- aliquota_retencao_icms,
                                null,--valor_icms_retido,
                                null, --cfop,
                                NULL,
                                REG.PLACA_VEIC, --placa_veiculo,
                                REG.PLACA_UF, --uf_veiculo,
                                NULL, --rntc_veiculo
                                REG.CPF_MOT
                                );
       /*                             
       INSERT INTO FT_TRANSPORTE_REBOQUE(ID,
                                  ID_FT_TRANSPORTE,
                                  ITEM,
                                  PLACA_REBOQUE,
                                  UF_REBOQUE,
                                  RNTC_REBOQUE,
                                  VAGAO_REBOQUE,
                                  BALSA_REBOQUE)   
        */
        select ft_transporte_volume_seq.nextval into v_id_vol from dual;                                  
        INSERT INTO FT_TRANSPORTE_VOLUME(ID,
                                         ID_FT_TRANSPORTE,
                                         QTDE_VOL_TRANSPORTADOS,
                                         ESPECIE_VOL_TRANSPORTADOS,
                                         MARCA_VOL_TRANSPORTADOS,
                                         NUMERACAO_VOL_TRANSPORTADOS,
                                         PESO_LIQUIDO,
                                         PESO_BRUTO,
                                         NUMERO_LACRES) 
                                 values (v_ID_vol,
                                         v_id,
                                         reg.VOL_QTD, --QTDE_VOL_TRANSPORTADOS,
                                         reg.VOL_ESPECIE,--ESPECIE_VOL_TRANSPORTADOS,
                                         reg.vol_marca, --MARCA_VOL_TRANSPORTADOS,
                                         reg.vol_numero, --NUMERACAO_VOL_TRANSPORTADOS,
                                         reg.peso_liquido,--PESO_LIQUIDO,
                                         reg.peso_bruto, --PESO_BRUTO,
                                         null --NUMERO_LACRES
                                         );                                                                                            
                           

   end;
   
   --------------------------------------------------------------------------------
   PROCEDURE livro_nf(emp  IN ft_notas.empresa%TYPE,
                      fil  IN ft_notas.filial%TYPE,
                      num  IN ft_notas.num_nota%TYPE,
                      ser  IN ft_notas.sr_nota%TYPE,
                      v_nf IN ft_notas.num_nota%TYPE,
                      v_sr IN ft_notas.sr_nota%TYPE)
   /*
      || Integra com livro fiscal
      */
    IS

      reg     ft_notas%ROWTYPE;
      reg_cfo ft_cfo%ROWTYPE;
      erro    VARCHAR2(100);

   BEGIN

      IF num IS NULL THEN
         RETURN;
      END IF;

      --| Le a nota
      SELECT *
        INTO reg
        FROM ft_notas
       WHERE empresa = emp
         AND filial = fil
         AND num_nota = num
         AND sr_nota = ser
         AND parte = 0;

      --| Le CFO para verificar os procedimento de integracao
      SELECT *
        INTO reg_cfo
        FROM ft_cfo
       WHERE cod_cfo = reg.cod_cfo;

      --| Se atualiza L.Fiscal
      IF reg_cfo.atl_lfis <> 'S' THEN
         resultado.livro      := FALSE;
         resultado.erro_livro := 'CFO n?o atualiza Livros Fiscais';
         RETURN;
      END IF;

      ft_lf.livro_fiscal(emp,
                         fil,
                         num,
                         ser,
                         erro,
                         v_nf,
                         v_sr);

      IF erro IS NULL THEN
         resultado.livro      := TRUE;
         resultado.nr_livro   := resultado.nr_livro + 1;
         resultado.erro_livro := '';
      ELSE
         resultado.livro      := FALSE;
         resultado.erro_livro := erro;
      END IF;

   END;

   --------------------------------------------------------------------------------
   PROCEDURE cria_dev(emp  IN ft_notas.empresa%TYPE,
                      fil  IN ft_notas.filial%TYPE,
                      num  IN ft_notas.num_nota%TYPE,
                      ser  IN ft_notas.sr_nota%TYPE,
                      dta  IN DATE,
                      v_nf IN ft_notas.num_nota%TYPE,
                      v_sr IN ft_notas.sr_nota%TYPE,
                      v_px IN NUMBER)
   /*
      || Grava devolucao
      */
    IS

      reg          ft_notas%ROWTYPE;
      v_num        NUMBER;
      vicmscliente NUMBER;

      CURSOR cri IS
         SELECT *
           FROM ft_itens_nf
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = num
            AND sr_nota = ser
            AND parte = v_px;

   BEGIN

      --| Le a nota
      SELECT *
        INTO reg
        FROM ft_notas
       WHERE empresa = emp
         AND filial = fil
         AND num_nota = num
         AND sr_nota = ser
         AND parte = v_px;

      --| Exclui registro de devolucao que ja exista com este numero
      --| e que tenha sido cancelado
      SELECT COUNT(num_nota)
        INTO v_num
        FROM ft_devol
       WHERE empresa = reg.empresa
         AND filial = reg.filial
         AND num_nota = reg.num_nota
         AND sr_nota = reg.sr_nota
         AND firma = reg.firma
         AND parte = reg.parte
         AND status <> 'C';
      IF v_num > 0 THEN
         raise_application_error(-20108,
                                 'Nota de devoluc?o ja existe : ' ||
                                 to_char(reg.num_nota));
      END IF;
      DELETE FROM ft_itens_dev
       WHERE empresa = reg.empresa
         AND filial = reg.filial
         AND num_nota = reg.num_nota
         AND sr_nota = reg.sr_nota
         AND firma = reg.firma
         AND parte = reg.parte;
      DELETE FROM ft_devol
       WHERE empresa = reg.empresa
         AND filial = reg.filial
         AND num_nota = reg.num_nota
         AND sr_nota = reg.sr_nota
         AND firma = reg.firma
         AND parte = reg.parte;

      --| Grava o registro de devolucao
      INSERT INTO ft_devol
      VALUES
         (reg.empresa,
          reg.filial,
          v_nf,
          v_sr,
          reg.firma,
          reg.parte,
          trunc(dta),
          reg.cod_oper,
          reg.cod_cfo,
          reg.producao,
          reg.periodo,
          'A',
          NULL,
          reg.num_pedido,
          reg.agente1,
          reg.agente2,
          reg.ent_ender,
          reg.ent_compl,
          reg.ent_bairro,
          reg.ent_cidade,
          reg.ent_uf,
          reg.ent_pais,
          reg.ent_cep,
          reg.vl_total,
          reg.vl_bicms,
          reg.vl_bicms_sub,
          reg.vl_bipi,
          reg.vl_icms,
          reg.vl_icms_sub,
          reg.vl_ipi,
          NULL);

      --| Para cada item da nota - cria item de devolucao
      FOR rgi IN cri LOOP
         INSERT INTO ft_itens_dev
         VALUES
            (rgi.empresa,
             rgi.filial,
             v_nf,
             v_sr,
             reg.firma,
             rgi.parte,
             rgi.produto,
             rgi.descricao,
             ft_itens_dev_seq.NEXTVAL,
             rgi.qtd,
             rgi.qtd_val,
             rgi.valor_unit,
             rgi.uni_ven,
             rgi.uni_est,
             rgi.uni_val,
             rgi.doc_origem,
             rgi.ser_origem,
             rgi.fil_origem,
             rgi.seq_origem,
             rgi.cod_origem,
             rgi.cod_tribut,
             rgi.vl_bicms,
             rgi.vl_bicms_sub,
             rgi.aliq_icms,
             rgi.vl_icms,
             rgi.vl_icms_sub,
             rgi.aliq_ipi,
             rgi.vl_bipi,
             rgi.vl_ipi,
             rgi.LOCAL,
             rgi.fil_local,
             rgi.seq_movest1);
      END LOOP;

   END;

   --------------------------------------------------------------------------------
   PROCEDURE adiant_nf(emp  IN ft_notas.empresa%TYPE,
                       fil  IN ft_notas.filial%TYPE,
                       num  IN ft_notas.num_nota%TYPE,
                       ser  IN ft_notas.sr_nota%TYPE,
                       v_nf IN ft_notas.num_nota%TYPE,
                       v_sr IN ft_notas.sr_nota%TYPE,
                       px   IN ft_notas.parte%TYPE)
   /*
      || Integracao com adiantamento para devolucoes
      */
    IS

      reg       ft_notas%ROWTYPE;
      reg_cfo   ft_cfo%ROWTYPE;
      reg_oper  ft_oper%ROWTYPE;
      reg_oper2 ft_oper%ROWTYPE;
      reg_ori   ft_notas%ROWTYPE;
      reg_rm    ce_notas%ROWTYPE;

      TYPE reg_dev_t IS RECORD(
         firma cd_firmas.firma%TYPE,
         cc    CHAR(1),
         valor NUMBER);
      TYPE tab_dev_t IS TABLE OF reg_dev_t INDEX BY BINARY_INTEGER;

      tab_dev tab_dev_t;

      v_ind NUMBER;
      i     NUMBER;

      CURSOR cri IS
         SELECT *
           FROM ft_itens_nf
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = num
            AND sr_nota = ser
            AND parte = px;

      v_valor  NUMBER;
      v_firma  cd_firmas.firma%TYPE;
      v_avista ft_condpag.a_vista%TYPE;
      v_cc     CHAR(1);
      v_doc_origem number(9);
   BEGIN

      IF num IS NULL THEN
         RETURN;
      END IF;

      --| Le a nota
      SELECT *
        INTO reg
        FROM ft_notas
       WHERE empresa = emp
         AND filial = fil
         AND num_nota = num
         AND sr_nota = ser
         AND parte = px;

      --| Le FT_OPER para verificar natureza
      SELECT *
        INTO reg_oper
        FROM ft_oper
       WHERE empresa = reg.empresa
         AND cod_oper = reg.cod_oper;

      --| Se nao for entrada - cancela
      IF reg_oper.natureza <> 'E' THEN
         --| Se nao for saida com origem em RM
         IF NOT (reg_oper.natureza = 'S' AND reg_oper.rm_origem = 'S' AND
             reg_oper.nf_origem = 'S') THEN
            RETURN;
         END IF;
      END IF;

      --| Verifica se operacao de remessa, que gera cobranca para o agente1
      IF reg_oper.remessa = 'S'
         AND reg.agente1 IS NOT NULL THEN
         v_firma := reg.agente1;
      ELSE
         v_firma := reg.firma;
      END IF;

      v_ind := 0;

      -- Percorre os itens verificando as NF origem que geram contas a receber
      FOR rgi IN cri LOOP

         -- Se tiver nota origem
         IF rgi.doc_origem IS NOT NULL
            AND rgi.fil_origem IS NOT NULL
            AND rgi.ser_origem IS NOT NULL THEN

            IF reg_oper.natureza = 'E' THEN

               -- Le a operacao e o cfo da nota origem
               SELECT *
                 INTO reg_ori
                 FROM ft_notas
                WHERE empresa = rgi.empresa
                  AND filial = rgi.fil_origem
                  AND num_nota = rgi.doc_origem
                  AND sr_nota = rgi.ser_origem
                  AND parte = px;
                  
               SELECT *
                 INTO reg_cfo
                 FROM ft_cfo
                WHERE cod_cfo = reg_ori.cod_cfo;

               -- Se nota origem atualiza c.receber
               IF reg_cfo.atl_crec = 'S' THEN

                  -- Se for operacao de remessa, a firma e o agente1
                  SELECT *
                    INTO reg_oper2
                    FROM ft_oper
                   WHERE empresa = reg_ori.empresa
                     AND cod_oper = reg_ori.cod_oper;
                     
                  IF reg_oper2.remessa = 'S'
                     AND reg_ori.agente1 IS NOT NULL THEN
                     --          v_firma := reg_ori.agente1;
                     v_firma := reg_ori.firma;
                  ELSE
                     v_firma := reg_ori.firma;
                  END IF;

                  --| Le Condicao de Pagamento
                  SELECT a_vista
                    INTO v_avista
                    FROM ft_condpag
                   WHERE cod_condpag = reg_ori.cod_condpag;

                  --| Gerar conta corrente caso NAO seja a vista, senao, gera adiantamento
                  v_cc := 'N';
                  IF FALSE
                     AND v_avista <> 'S' THEN
                     v_cc := 'S';
                  END IF;

                  -- Guarda firmas e valores a lancar no adiantamento na tabela intena tab_dev
                  i := 0;
                  
                  FOR n IN 1 .. v_ind LOOP
                     IF tab_dev(n).firma = v_firma
                        AND tab_dev(n).cc = v_cc THEN
                        i := n;
                        EXIT;
                     END IF;
                  END LOOP;
                  
                  IF i = 0 THEN
                     v_ind := v_ind + 1;
                     tab_dev(v_ind).firma := v_firma;
                     tab_dev(v_ind).cc := v_cc;
                     tab_dev(v_ind).valor := (rgi.qtd_val * rgi.valor_unit) +
                                             nvl(rgi.vl_ipi,
                                                 0);
                  ELSE
                     tab_dev(i).valor := tab_dev(i)
                                        .valor +
                                         ((rgi.qtd_val * rgi.valor_unit) +
                                          nvl(rgi.vl_ipi,
                                              0));
                  END IF;
               END IF;

            ELSE

               -- Le a operacao e o cfo da nota origem
               SELECT *
                 INTO reg_rm
                 FROM ce_notas
                WHERE empresa = rgi.empresa
                  AND filial = rgi.fil_origem
                  AND num_nota = rgi.doc_origem
                  AND sr_nota = rgi.ser_origem
                  AND cod_fornec = reg.firma
                  AND parte = px;
                  
                  v_doc_origem := rgi.doc_origem;
               SELECT *
                 INTO reg_cfo
                 FROM ft_cfo
                WHERE cod_cfo = reg_rm.cod_cfo;

               -- Se nota origem atualiza c.receber
               IF reg_cfo.atl_cpag = 'S' THEN

                  -- Se for operacao de remessa, a firma e o agente1
                  SELECT *
                    INTO reg_oper2
                    FROM ft_oper
                   WHERE empresa = reg_rm.empresa
                     AND cod_oper = reg_rm.cod_oper;
                  v_firma := reg_rm.cod_fornec;

                  --| Gerar conta corrente caso NAO seja a vista, senao, gera adiantamento
                  v_cc := 'N';

                  -- Guarda firmas e valores a lancar no adiantamento na tabela intena tab_dev
                  i := 0;
                  FOR n IN 1 .. v_ind LOOP
                     IF tab_dev(n).firma = v_firma
                        AND tab_dev(n).cc = v_cc THEN
                        i := n;
                        EXIT;
                     END IF;
                  END LOOP;
                  IF i = 0 THEN
                     v_ind := v_ind + 1;
                     tab_dev(v_ind).firma := v_firma;
                     tab_dev(v_ind).cc := v_cc;
                     tab_dev(v_ind).valor := (rgi.qtd_val * rgi.valor_unit) +
                                             nvl(rgi.vl_ipi,
                                                 0);
                  ELSE
                     tab_dev(i).valor := tab_dev(i)
                                        .valor +
                                         ((rgi.qtd_val * rgi.valor_unit) +
                                          nvl(rgi.vl_ipi,
                                              0));
                  END IF;
               END IF;

            END IF;

         END IF;

      END LOOP;

      --| Se existe(m) valor(es) a devolver - gera adiantamento(s)
      FOR n IN 1 .. v_ind LOOP

         --| Lancamento em conta corrente
         IF tab_dev(n).cc = 'S' THEN
            NULL;
         ELSE
            INSERT INTO fn_adiant
            VALUES
               (emp,
                tab_dev(n).firma,
                reg.dt_emissao,
                fn_adiant_seq.NEXTVAL,
                decode(reg_oper.natureza,
                       'E',
                       'A',
                       'P'),
                'R',
                tab_dev(n).valor,
                to_char(nvl(v_nf,
                            num)) || '.' ||
                nvl(v_sr,
                    ser),
                NULL,
                'DEVOLUCAO N.F. ' || to_char(nvl(v_nf,
                                                 num)) || '.' ||
                nvl(v_sr,
                    ser),
                USER,
                NULL,
                trunc(SYSDATE),
                reg.parte,
                NULL,
                v_doc_origem,
                reg.firma
                );
         END IF;

      END LOOP;

   END;

   --------------------------------------------------------------------------------
   FUNCTION sub_hist(v_h    ft_msgs.mensagem%TYPE,
                     v_desc NUMBER,
                     cnotas VARCHAR2,
                     cdatas VARCHAR2,
                     nvalor NUMBER) RETURN VARCHAR2
   /*
      || Substituicoes nos historicos
      */
    IS

      v_his ft_msgs.mensagem%TYPE;
      n     NUMBER;
      nh    NUMBER;

   BEGIN

      v_his := v_h;
      n     := instr(v_his,
                     '@');
      WHILE n > 0 LOOP
         IF lib_util.is_numeric(substr(v_his,
                                       n + 1,
                                       2)) = 'S' THEN
            nh := to_number(substr(v_his,
                                   n + 1,
                                   2));
            IF nh = 1 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || to_char(v_desc) ||
                        substr(v_his,
                               n + 3);
            ELSIF nh = 2 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || cnotas ||
                        substr(v_his,
                               n + 3);
            ELSIF nh = 3 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || cdatas ||
                        substr(v_his,
                               n + 3);
            ELSIF nh = 4
                  AND nvalor > 0 THEN
               v_his := substr(v_his,
                               1,
                               n - 1) || substr(v_his,
                                                n + 3);
            ELSE
               v_his := substr(v_his,
                               1,
                               n - 1) || substr(v_his,
                                                n + 3);
            END IF;
            n := instr(v_his,
                       '@');
         ELSE
            v_his := substr(v_his,
                            1,
                            n - 1) || substr(v_his,
                                             n + 1);
            n     := instr(v_his,
                           '@');
         END IF;
      END LOOP;

      RETURN v_his;

   END;

   --------------------------------------------------------------------------------
   PROCEDURE complemento_exp(emp ft_pedidos.empresa%TYPE,
                             fil ft_pedidos.filial%TYPE,
                             num ft_pedidos.num_pedido%TYPE) IS
      /*
      || Prepara dados complementares da nota (fat.expedicoes)
      */

      CURSOR cr_i IS
         SELECT *
           FROM t_itens_ped
          WHERE empresa = emp
            AND filial = fil
            AND num_pedido = num;

      CURSOR cr_p IS
         SELECT *
           FROM t_pedidos
          WHERE empresa = emp
            AND filial = fil
            AND num_pedido = num;
      reg_p ft_pedidos%ROWTYPE;

      CURSOR cr_e(ct ft_espec.cod_espec%TYPE) IS
         SELECT *
           FROM ft_espec
          WHERE cod_espec = ct;
      reg_esp ft_espec%ROWTYPE;

      CURSOR cr_pro(emp ce_produtos.empresa%TYPE, pro ce_produtos.produto%TYPE) IS
         SELECT *
           FROM ce_produtos
          WHERE empresa = emp
            AND produto = pro;
      reg_pro ce_produtos%ROWTYPE;

      v_espec     ft_espec.descricao%TYPE;
      v_marca     ft_espec.marca%TYPE;
      v_numer     ft_espec.numero%TYPE;
      v_qtd       NUMBER;
      v_peso      NUMBER;
      v_peso_emb  NUMBER;
      v_valor_emb NUMBER;

   BEGIN

      OPEN cr_p;
      FETCH cr_p
         INTO reg_p;
      IF substr(reg_p.cod_cfo,
                1,
                1) IN ('1',
                       '2') THEN
         CLOSE cr_p;
         RETURN;
      END IF;
      CLOSE cr_p;

      v_espec := '';
      v_marca := '';
      v_numer := '';

      v_qtd       := 0;
      v_peso      := 0;
      v_peso_emb  := 0;
      v_valor_emb := 0;

      FOR reg IN cr_i LOOP
         OPEN cr_e(reg.uni_ven);
         FETCH cr_e
            INTO reg_esp;
         IF cr_e%FOUND THEN
            IF v_espec IS NULL THEN
               v_espec := reg_esp.descricao;
            ELSIF reg_esp.descricao IS NOT NULL
                  AND v_espec <> reg_esp.descricao THEN
               v_espec := 'DIVERSOS';
            END IF;
            IF v_marca IS NULL THEN
               v_marca := reg_esp.marca;
            ELSIF reg_esp.marca IS NOT NULL
                  AND v_marca <> reg_esp.marca THEN
               v_marca := 'DIVERSAS';
            END IF;
            IF v_numer IS NULL THEN
               v_numer := reg_esp.numero;
            ELSIF reg_esp.numero IS NOT NULL
                  AND v_numer <> reg_esp.numero THEN
               v_numer := 'DIVERSOS';
            END IF;
            v_peso_emb  := v_peso_emb +
                           (reg.qtd_ped * nvl(reg_esp.peso,
                                              0));
            v_valor_emb := v_valor_emb +
                           (reg.qtd_ped * nvl(reg_esp.valor,
                                              0));
         END IF;
         v_qtd := v_qtd + reg.qtd_ped;
         IF reg.uni_val = 'KG' THEN
            v_peso := v_peso + reg.qtd_val;
         ELSE
            OPEN cr_pro(reg.empresa,
                        reg.produto);
            FETCH cr_pro
               INTO reg_pro;
            IF cr_pro%FOUND THEN
               v_peso := v_peso +
                         (nvl(reg_pro.peso,
                              0) * ce_unid_utl.fator(reg_pro.uni_peso,
                                                      'KG') * reg.qtd_ped);
            END IF;
            CLOSE cr_pro;
         END IF;
         CLOSE cr_e;
      END LOOP;

      comp_nota.vol_qtd      := v_qtd;
      comp_nota.vol_especie  := v_espec;
      comp_nota.vol_marca    := v_marca;
      comp_nota.vol_numero   := v_numer;
      comp_nota.peso_bruto   := v_peso;
      comp_nota.peso_liquido := v_peso - v_peso_emb;
      comp_nota.vl_embalagem := v_valor_emb;

   END;

   --------------------------------------------------------------------------------
   /*
   || Rotinas exportadas
   */
   --------------------------------------------------------------------------------
   PROCEDURE grava_reg_nf(nf ft_notas%ROWTYPE)
   /*
      || Grava o registro da nota
      */
    IS

   BEGIN

      INSERT INTO ft_notas
      VALUES
         (NF.ID,
          nf.empresa,
          nf.filial,
          nf.num_nota,
          nf.sr_nota,
          nf.parte,
          nf.firma,
          nf.dt_emissao,
          nf.cod_oper,
          nf.cod_cfo,
          nf.producao,
          nf.periodo,
          nf.status,
          nvl(g_data_saida,
              nf.dt_entsai),
          nf.dt_cancela,
          nf.num_pedido,
          nf.agente1,
          nf.agente2,
          nf.pc_desc,
          nf.dias_desc,
          nf.cod_condpag,
          nf.tipo_cob,
          nf.tipo_tit,
          nf.banco,
          nf.agencia,
          nf.tp_frete,
          nf.tp_juros,
          nf.pc_juros,
          nf.pc_multa,
          nf.dias_multa,
          nf.dias_juros,
          nf.ent_ender,
          nf.ent_compl,
          nf.ent_bairro,
          nf.ent_cidade,
          nf.ent_uf,
          nf.ent_pais,
          nf.ent_cep,
          nf.cob_ender,
          nf.cob_compl,
          nf.cob_bairro,
          nf.cob_cidade,
          nf.cob_uf,
          nf.cob_pais,
          nf.cob_cep,
          nf.vl_bicms,
          nf.vl_bicms_sub,
          nf.vl_bipi,
          nf.vl_biss,
          nf.vl_total,
          nf.vl_produtos,
          nf.vl_icms,
          nf.vl_icms_sub,
          nf.vl_icms_fre,
          nf.vl_ipi,
          nf.vl_iss,
          nf.vl_embalagem,
          nf.vl_frete,
          nf.vl_seguro,
          nf.vl_outros,
          nf.pc_desc_ir,
          nf.vl_desc_ir,
          nf.vol_qtd,
          nf.vol_especie,
          nf.vol_marca,
          nf.vol_numero,
          nf.peso_liquido,
          nf.peso_bruto,
          nf.cod_transp,
          nf.motorista,
          nf.cpf_mot,
          nf.placa_veic,
          nf.placa_uf,
          nf.firma_ent,
          nf.num_fatura,
          nf.sr_fatura,
          nf.fil_pedido,
          nf.lote_cont,
          nf.vl_pis,
          nf.vl_cofins,
          nf.empresa_dest,
          nf.filial_dest,
          nf.aliq_iss,
          nf.vl_servicos,
          nf.desc_serv,
          nf.vl_icms_desp,
          nf.fl_dest,
          nf.nf_dest,
          nf.sr_dest,
          nf.fr_dest,
          nf.num_exped,
          nf.vl_desconto,
          nf.vl_bicms_pro,
          nf.vl_icms_pro,
          nf.vl_binss,
          nf.vl_inss,
          nf.vl_ccp,
          nf.atividade,
          nf.cfps,
          nf.vlr_deduz,
          NULL,
          NULL,
          nf.frete_bicms,
          nf.cnpj_cpf,
          nf.iest,
          NULL ,-- NFE
          NF.ENT_NUMERO, -- VARCHAR2(20)
          NF.COB_NUMERO,
          0, --STATUS_NFE DIGITADO VARCHAR2(10)
          NULL, -- CHAVE_NFE  VARCHAR2(100)
          NULL, --DIGEST_VALUE VARCHAR2(100)
          null, --arquivo_xml
          null, -- email nfe
          null,  --dt_email_nfe
          null, --ret_msg_nfe
          null, --justificativa cancelamento
          0, -- forma emissao
          null, --PROTOCOL_NFE
          null, -- RECIBO_NFE
          null, -- DT_RECIBO_NFE
          null, --    CSTAT
          1,--   AMBIENTE_NFE
          1, --finalidade_nfe 1 normal
          1 --indicador de cosumidor final (0)-nao (1)-sim
          );

   END;

   --------------------------------------------------------------------------------
   PROCEDURE data_saida(dat DATE)
   /*
      || Guarda a data de saida
      */
    IS

   BEGIN

      g_data_saida := dat;

   END;

   --------------------------------------------------------------------------------
   FUNCTION tipo_nf(emp IN ft_notas.empresa%TYPE,
                    fil IN ft_notas.filial%TYPE,
                    opr IN ft_notas.cod_oper%TYPE) RETURN NUMBER
   /*
      || Retorno o tipo de nota a usar
      */
    IS

      CURSOR cr_opr IS
         SELECT tipo_nf
           FROM ft_oper_trans
          WHERE empresa = emp
            AND filial = fil
            AND cod_oper = opr;

      CURSOR cr_fil IS
         SELECT tipo_nota
           FROM ft_numera
          WHERE empresa = emp
            AND filial = fil;
      CURSOR cr_emp IS
         SELECT tipo_nota
           FROM ft_param
          WHERE empresa = emp;
      v_tipo ft_param.tipo_nota%TYPE;

   BEGIN

      OPEN cr_opr;
      FETCH cr_opr
         INTO v_tipo;
      IF cr_opr%FOUND
         AND nvl(v_tipo,
                 0) > 0 THEN
         CLOSE cr_opr;
         RETURN v_tipo;
      END IF;
      CLOSE cr_opr;
      OPEN cr_fil;
      FETCH cr_fil
         INTO v_tipo;
      IF cr_fil%FOUND
         AND nvl(v_tipo,
                 0) > 0 THEN
         CLOSE cr_fil;
         RETURN v_tipo;
      END IF;
      CLOSE cr_fil;
      OPEN cr_emp;
      FETCH cr_emp
         INTO v_tipo;
      IF cr_emp%FOUND
         AND nvl(v_tipo,
                 0) > 0 THEN
         CLOSE cr_emp;
         RETURN v_tipo;
      END IF;
      CLOSE cr_emp;
      RETURN NULL;

   END;

   --------------------------------------------------------------------------------
   FUNCTION tipo_exped(emp IN ft_exped.empresa%TYPE,
                       fil IN ft_exped.filial%TYPE,
                       num IN ft_exped.num_exped%TYPE) RETURN NUMBER
   /*
      || Retorna tipo da nota a gerar para a expedicao
      */
    IS

      CURSOR cr_ped IS
         SELECT empresa,
                fil_pedido,
                num_pedido
           FROM ft_itens_exp
          WHERE empresa = emp
            AND filial = fil
            AND num_exped = num
          ORDER BY empresa,
                   fil_pedido,
                   num_pedido;
      reg cr_ped%ROWTYPE;

      v_cod ft_oper.cod_oper%TYPE;

      CURSOR cr_opr(opr ft_oper.cod_oper%TYPE) IS
         SELECT tipo_nf
           FROM ft_oper_trans
          WHERE empresa = emp
            AND filial = fil
            AND cod_oper = opr;
      CURSOR cr_fil IS
         SELECT tipo_nota
           FROM ft_numera
          WHERE empresa = emp
            AND filial = fil;
      CURSOR cr_emp IS
         SELECT tipo_nota
           FROM ft_param
          WHERE empresa = emp;
      v_tipo ft_param.tipo_nota%TYPE;

   BEGIN

      --| Le o registro da expedicao
      OPEN cr_ped;
      FETCH cr_ped
         INTO reg;
      CLOSE cr_ped;

      --| Le a operacao do primeiro pedido da expedicao
      SELECT cod_oper
        INTO v_cod
        FROM ft_pedidos
       WHERE empresa = reg.empresa
         AND filial = reg.fil_pedido
         AND num_pedido = reg.num_pedido;

      --| Encontra o tipo da nota
      OPEN cr_opr(v_cod);
      FETCH cr_opr
         INTO v_tipo;
      IF cr_opr%FOUND
         AND nvl(v_tipo,
                 0) > 0 THEN
         CLOSE cr_opr;
         RETURN v_tipo;
      END IF;
      CLOSE cr_opr;
      OPEN cr_fil;
      FETCH cr_fil
         INTO v_tipo;
      IF cr_fil%FOUND
         AND nvl(v_tipo,
                 0) > 0 THEN
         CLOSE cr_fil;
         RETURN v_tipo;
      END IF;
      CLOSE cr_fil;
      OPEN cr_emp;
      FETCH cr_emp
         INTO v_tipo;
      IF cr_emp%FOUND
         AND nvl(v_tipo,
                 0) > 0 THEN
         CLOSE cr_emp;
         RETURN v_tipo;
      END IF;
      CLOSE cr_emp;
      RETURN NULL;

   END;

   --------------------------------------------------------------------------------
   FUNCTION tipo_lote(emp IN ft_pedidos.empresa%TYPE,
                      fil IN ft_pedidos.filial%TYPE,
                      nlt IN ft_pedidos.lote%TYPE) RETURN NUMBER
   /*
      || Retorna tipo da nota a gerar para o lote
      */
    IS

      CURSOR cr_ped IS
         SELECT cod_oper
           FROM ft_pedidos
          WHERE empresa = emp
            AND filial = fil
            AND lote = nlt
          ORDER BY empresa,
                   filial,
                   num_pedido;

      v_cod ft_oper.cod_oper%TYPE;

      CURSOR cr_opr(opr ft_oper.cod_oper%TYPE) IS
         SELECT tipo_nf
           FROM ft_oper_trans
          WHERE empresa = emp
            AND filial = fil
            AND cod_oper = opr;
      CURSOR cr_fil IS
         SELECT tipo_nota
           FROM ft_numera
          WHERE empresa = emp
            AND filial = fil;
      CURSOR cr_emp IS
         SELECT tipo_nota
           FROM ft_param
          WHERE empresa = emp;
      v_tipo ft_param.tipo_nota%TYPE;

   BEGIN

      --| Le a operacao do primeiro pedido da expedicao
      OPEN cr_ped;
      FETCH cr_ped
         INTO v_cod;
      CLOSE cr_ped;

      --| Encontra o tipo da nota
      OPEN cr_opr(v_cod);
      FETCH cr_opr
         INTO v_tipo;
      IF cr_opr%FOUND
         AND nvl(v_tipo,
                 0) > 0 THEN
         CLOSE cr_opr;
         RETURN v_tipo;
      END IF;
      CLOSE cr_opr;
      OPEN cr_fil;
      FETCH cr_fil
         INTO v_tipo;
      IF cr_fil%FOUND
         AND nvl(v_tipo,
                 0) > 0 THEN
         CLOSE cr_fil;
         RETURN v_tipo;
      END IF;
      CLOSE cr_fil;
      OPEN cr_emp;
      FETCH cr_emp
         INTO v_tipo;
      IF cr_emp%FOUND
         AND nvl(v_tipo,
                 0) > 0 THEN
         CLOSE cr_emp;
         RETURN v_tipo;
      END IF;
      CLOSE cr_emp;
      RETURN NULL;

   END;

   --------------------------------------------------------------------------------
   FUNCTION contab_nf(emp IN ft_notas.empresa%TYPE,
                      fil IN ft_notas.filial%TYPE,
                      num IN ft_notas.num_nota%TYPE,
                      ser IN ft_notas.sr_nota%TYPE,
                      par IN ft_notas.parte%TYPE,
                      aut IN CHAR := 'S') RETURN NUMBER
   /*
      || Contabiliza nota
      */
    IS

      CURSOR cr_nf IS
         SELECT *
           FROM ft_notas
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = num
            AND sr_nota = ser
            AND (aut = 'S' OR parte = par);

      --reg_nf ft_notas%rowtype;
      reg_cfo ft_cfo%ROWTYPE;

      v_lote cg_lancto.lote%TYPE;

      v_ano NUMBER(4);
      v_mes NUMBER(2);

      TYPE type_tab_val IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      tab_val type_tab_val;

      CURSOR cr(a cg_exerc.ano%TYPE) IS
         SELECT mes
           FROM cg_exerc
          WHERE empresa = emp
            AND ano = a;

      CURSOR cr_i(p ft_notas.parte%TYPE) IS
         SELECT *
           FROM ft_itens_nf
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = num
            AND sr_nota = ser
            AND parte = p;

      CURSOR cr_cst(emp ce_saldo.empresa%TYPE, fil ce_saldo.filial%TYPE, pro ce_saldo.produto%TYPE) IS
         SELECT *
           FROM ce_saldo
          WHERE empresa = emp
            AND filial = fil
            AND produto = pro
          ORDER BY empresa,
                   filial,
                   produto,
                   dt_saldo DESC;

      reg_cst ce_saldo%ROWTYPE;

      CURSOR cr_po(emp ft_pedidos.empresa%TYPE, fil ft_pedidos.filial%TYPE, ped ft_pedidos.num_pedido%TYPE, itm ft_itens_ped.seq_origem%TYPE) IS
         SELECT qtd_ped
           FROM ft_itens_ped
          WHERE empresa = emp
            AND filial = fil
            AND seq_item = itm
            AND num_pedido = ped;

      CURSOR cr_no(emp ft_itens_nf.empresa%TYPE, fil ft_itens_nf.filial%TYPE, ped ft_itens_nf.num_nota%TYPE, itm ft_itens_nf.seq_item%TYPE, par ft_itens_nf.parte%TYPE) IS
         SELECT b.seq_movest1
           FROM ft_itens_nf b,
                ft_notas    a
          WHERE b.empresa = emp
            AND b.filial = fil
            AND b.seq_pedido = itm
            AND b.parte = par
            AND a.empresa = b.empresa
            AND a.filial = b.filial
            AND a.num_nota = b.num_nota
            AND a.parte = b.parte
            AND a.num_pedido = ped;

      --/ 10/06/2008 - slf - notas em recpcao de mercadoria
      CURSOR cr_norm(emp ce_itens_nf.empresa%TYPE, fil ce_itens_nf.filial%TYPE, ped ce_itens_nf.num_nota%TYPE, itm ce_itens_nf.ID%TYPE, ser ce_itens_nf.sr_nota%TYPE, par ce_itens_nf.parte%TYPE, forn ce_itens_nf.cod_fornec%TYPE) IS
         SELECT b.qtd,
                b.seq_mov
           FROM ce_itens_nf b
          WHERE b.empresa = emp
            AND b.filial = fil
            AND b.ID = itm
            AND b.parte = par
            AND b.sr_nota = ser
            AND b.cod_fornec = forn
            AND b.num_nota = ped;

      --/ 10/06/2008 - slf - notas propria (smtc)
      CURSOR cr_nop(emp ft_itens_nf.empresa%TYPE, fil ft_itens_nf.filial%TYPE, nnf ft_itens_nf.num_nota%TYPE, itm ft_itens_nf.seq_item%TYPE, par ft_itens_nf.parte%TYPE) IS
         SELECT b.qtd_fat,
                b.seq_movest1
           FROM ft_itens_nf b
          WHERE b.empresa = emp
            AND b.filial = fil
            AND b.seq_item = itm
            AND b.parte = par
            AND b.num_nota = nnf;

      CURSOR cr_mvs(seq ce_movest.seq_mov%TYPE) IS
         SELECT round(vlr_tot_mov / qtde_mov,
                      2) custo
           FROM ce_movest
          WHERE seq_mov = seq
            AND nvl(qtde_mov,
                    0) <> 0;

      CURSOR cr_ot(opr ft_oper_trans.cod_oper%TYPE, emp ft_oper_trans.empresa%TYPE, fil ft_oper_trans.filial%TYPE) IS
         SELECT cod_trans
           FROM ft_oper_trans
          WHERE cod_oper = opr
            AND empresa = emp
            AND filial = fil;

      CURSOR cr_ot2(opr ft_condpag_trans.cod_oper%TYPE, emp ft_condpag_trans.empresa%TYPE, fil ft_condpag_trans.filial%TYPE, cp ft_condpag_trans.cod_condpag%TYPE) IS
         SELECT cod_trans
           FROM ft_condpag_trans
          WHERE cod_oper = opr
            AND empresa = emp
            AND filial = fil
            AND cod_condpag = cp;

      CURSOR cr_zf(c cd_cidades.cod_cidade%TYPE) IS
         SELECT 'S'
           FROM ft_cidades_zf
          WHERE cod_cidade = c;

      ----------------------------------------------
      --/ VARIAVEIS
      ----------------------------------------------
      v_seq_ori   NUMBER;
      v_custo_ori NUMBER;

      reg_oper          ft_oper%ROWTYPE;
      dummy             NUMBER;
      v_desc_pro        VARCHAR2(4000);
      v_desc_p1         ce_produtos.descricao%TYPE;
      v_val             NUMBER;
      v_custo           NUMBER;
      v_tot_pis         NUMBER;
      v_tot_cofins      NUMBER;
      v_tot_itens       NUMBER;
      v_item_atual      NUMBER;
      v_pis             NUMBER;
      v_cofins          NUMBER;
      valor_pis         NUMBER;
      valor_cofins      NUMBER;
      v_despesas        NUMBER;
      v_tot_despesas    NUMBER;
      valor_despesas    NUMBER;
      valor_icms_desp   NUMBER;
      v_tot_icms_desp   NUMBER;
      v_icms_desp       NUMBER;
      v_tot_itens_icms  NUMBER;
      v_item_icms_atual NUMBER;
      v_produtos_icms   NUMBER;
      v_qtd_ped_ori     ft_itens_ped.qtd_ped%TYPE;
      snotas            VARCHAR2(4000);
      v_trans           ft_oper_trans.cod_trans%TYPE;
      v_lote_cont       cg_lancto.lote%TYPE;
      v_afonte          cg_trans.cod_afonte%TYPE;
      v_erc             NUMBER;

      v_msg       ft_fisco.tab_msg_t;
      v_fis       ft_fisco.impostos_t;
      v_icm       NUMBER;
      v_uf_origem cd_uf.uf%TYPE;
      v_tri       ft_tribut.cod_tribut%TYPE;
      v_red       NUMBER;
      v_ret       NUMBER;
      v_cfo2      ft_cfo.cod_cfo%TYPE;
      v_des       CHAR;
      v_codfirma  cd_firmas.firma%TYPE;

      v_zf       CHAR(1);
      v_suf      VARCHAR2(50);
      v_con      CHAR(1);
      reg_cli    cd_firmas%ROWTYPE;
      v_ret_lote cg_lancto.lote%TYPE;
      v_adiant   NUMBER;

      vl_csll   NUMBER(15,
                       2);
      vl_cofins NUMBER(15,
                       2);
      vl_pis    NUMBER(15,
                       2);

   BEGIN

      FOR reg_nf IN cr_nf LOOP

         SELECT *
           INTO reg_cfo
           FROM ft_cfo
          WHERE cod_cfo = reg_nf.cod_cfo;

         --| Le o registro do cliente e dados de suframa/livro comercio
         SELECT *
           INTO reg_cli
           FROM cd_firmas
          WHERE firma = reg_nf.firma;
         --/
         v_suf := reg_cli.cod_suframa;
         v_con := reg_cli.cons_final;
         --/
         OPEN cr_zf(reg_cli.cod_cidade);
         FETCH cr_zf
            INTO v_zf;
         IF cr_zf%NOTFOUND THEN
            v_zf := 'N';
         END IF;
         CLOSE cr_zf;

         --| Se for nota de saida
         IF reg_cfo.natureza = 'S'
            OR nvl(g_dev,
                   'N') = 'N' THEN
            SELECT firma
              INTO v_codfirma
              FROM cd_firmas
             WHERE empresa = emp
               AND filial = fil;
            SELECT uf
              INTO v_uf_origem
              FROM cd_firmas
             WHERE firma = v_codfirma;
         ELSIF nvl(g_dev,
                   'N') = 'S' THEN
            SELECT uf
              INTO v_uf_origem
              FROM cd_firmas
             WHERE firma = reg_nf.firma;
         END IF;

         snotas := '';
         v_ano  := to_number(to_char(reg_nf.dt_emissao,
                                     'YYYY'));
         OPEN cr(v_ano);
         FETCH cr
            INTO v_mes;
         IF cr%NOTFOUND THEN
            CLOSE cr;
            raise_application_error(-20106,
                                    'Exercicio contabil da data da nota nao esta aberto');
         END IF;
         IF v_mes >= to_number(to_char(reg_nf.dt_emissao,
                                       'MM')) THEN
            CLOSE cr;
            raise_application_error(-20106,
                                    'Mes da data da nota ja foi fechado');
         END IF;
         CLOSE cr;

         --| Le FT_OPER para verificar natureza
         SELECT *
           INTO reg_oper
           FROM ft_oper
          WHERE empresa = reg_nf.empresa
            AND cod_oper = reg_nf.cod_oper;

         v_desc_pro := '';
         tab_val.DELETE;

         valor_pis         := nvl(reg_nf.vl_pis,
                                  0);
         valor_cofins      := nvl(reg_nf.vl_cofins,
                                  0);
         v_tot_pis         := valor_pis;
         v_tot_cofins      := valor_cofins;
         v_item_atual      := 0;
         v_item_icms_atual := 0;

         valor_despesas := nvl(reg_nf.vl_seguro,
                               0) + nvl(reg_nf.vl_outros,
                                        0) + nvl(reg_nf.vl_frete,
                                                 0);
         v_tot_despesas := valor_despesas;

         valor_icms_desp := nvl(reg_nf.vl_icms_desp,
                                0) + nvl(reg_nf.vl_icms_fre,
                                         0);
         v_tot_icms_desp := valor_icms_desp;

         --| Le o numero total de itens para rateios de impostos
         SELECT COUNT(*)
           INTO v_tot_itens
           FROM ft_itens_nf
          WHERE empresa = reg_nf.empresa
            AND filial = reg_nf.filial
            AND num_nota = reg_nf.num_nota
            AND sr_nota = reg_nf.sr_nota
            AND parte = reg_nf.parte;

         SELECT COUNT(*),
                SUM(qtd * valor_unit)
           INTO v_tot_itens_icms,
                v_produtos_icms
           FROM ft_itens_nf
          WHERE empresa = reg_nf.empresa
            AND filial = reg_nf.filial
            AND num_nota = reg_nf.num_nota
            AND sr_nota = reg_nf.sr_nota
            AND parte = reg_nf.parte
            AND nvl(vl_icms,
                    0) > 0;

         -- Rateia o valor do CCP 4,65
         vl_csll   := (reg_nf.vl_ccp * 1 / 4.65 * 100) / 100;
         vl_cofins := (reg_nf.vl_ccp * 3 / 4.65 * 100) / 100;
         vl_pis    := (reg_nf.vl_ccp * .65 / 4.65 * 100) / 100;
         vl_pis    := vl_pis +
                      (reg_nf.vl_ccp - (vl_csll + vl_cofins + vl_pis));

         --| Para todos os itens da nota
         FOR rgi IN cr_i(reg_nf.parte) LOOP

            --| Guarda nomes de produtos para contabilizar
            SELECT descricao
              INTO v_desc_p1
              FROM ce_produtos
             WHERE empresa = rgi.empresa
               AND produto = rgi.produto;
            IF v_desc_pro IS NULL THEN
               v_desc_pro := to_char(rgi.qtd) || ' ' || rgi.uni_ven || ' ' ||
                             rtrim(v_desc_p1);
            ELSIF length(v_desc_pro) < 1900 THEN
               v_desc_pro := v_desc_pro || ', ' || to_char(rgi.qtd) || ' ' ||
                             rgi.uni_ven || ' ' || rtrim(v_desc_p1);
            END IF;

            --| Verifica os valores para contabilizacao
            v_val := cg_int.valor_pro(rgi.empresa,
                                      rgi.produto,
                                      'R');
            IF v_val > 0 THEN
               IF tab_val.EXISTS(v_val) THEN
                  tab_val(v_val) := tab_val(v_val) +
                                    round(rgi.valor_unit * rgi.qtd_val,
                                          2);
               ELSE
                  tab_val(v_val) := round(rgi.valor_unit * rgi.qtd_val,
                                          2);
               END IF;
               v_ret := ft_fisco.calc_impostos(rgi.empresa,
                                               rgi.filial,
                                               rgi.produto,
                                               nvl(rgi.cod_cfo,
                                                   reg_nf.cod_cfo),
                                               v_uf_origem,
                                               reg_nf.ent_uf,
                                               rgi.qtd * rgi.valor_unit,
                                               v_zf,
                                               v_suf,
                                               v_con,
                                               reg_oper.servico,
                                               v_fis,
                                               v_msg);
               IF v_fis.com_des = 'S' THEN
                  tab_val(v_val) := tab_val(v_val) -
                                    (round((rgi.qtd_val * rgi.valor_unit),
                                           2) - nvl(rgi.vl_bicms,
                                                    0)) *
                                    (nvl(rgi.aliq_icms,
                                         0) / 100);
               END IF;
            END IF;

            --| Verifica os valores para contabilizacao : Custos
            --| Se for saida pegar o ultimo custo do produto
            IF reg_oper.natureza = 'S' THEN

               -- Pega custo atual para saida
               OPEN cr_cst(rgi.empresa,
                           rgi.filial,
                           rgi.produto);
               FETCH cr_cst
                  INTO reg_cst;
               --16/06/2005  if cr_cst%notfound or nvl(reg_cst.saldo_fisico,0) = 0 then
               IF cr_cst%NOTFOUND
                  OR nvl(reg_cst.custo_medio,
                         0) = 0 THEN
                  CLOSE cr_cst;
                  v_custo := rgi.valor_unit;
               ELSE
                  CLOSE cr_cst;
                  v_custo := reg_cst.custo_medio;

               END IF;

               --| 16/06/2005
               v_val := cg_int.valor_pro(rgi.empresa,
                                         rgi.produto,
                                         'C');
               IF v_val > 0 THEN
                  IF tab_val.EXISTS(v_val) THEN
                     tab_val(v_val) := tab_val(v_val) +
                                       round(v_custo * rgi.qtd,
                                             2);
                  ELSE
                     tab_val(v_val) := round(v_custo * rgi.qtd,
                                             2);
                  END IF;
               END IF;

               --| 16/06/2005
               --| Guarda Notas e data origem para mensagem
               IF rgi.fil_origem IS NOT NULL
                  AND rgi.doc_origem IS NOT NULL
                  AND rgi.ser_origem IS NOT NULL
                  AND length(snotas) < 1900 THEN
                  snotas := snotas || to_char(rgi.doc_origem) || ' ';
               ELSE
                  snotas := snotas || to_char(rgi.num_nota);
               END IF;

               -- Se tiver pedido origem : Pega o custo original
               IF nvl(rgi.fil_origem,
                      0) <> 0 THEN
                  --/ 10/06/2008:SLF - tem que verificar a origem
                  --/ o lancto pode ter origem em pedido, NF propria, NF de terceiros(RM)
                  --/
                  IF reg_oper.pd_origem = 'S' THEN
                     OPEN cr_po(rgi.empresa,
                                rgi.fil_origem,
                                rgi.doc_origem,
                                rgi.seq_origem);
                     FETCH cr_po
                        INTO v_qtd_ped_ori;
                     IF cr_po%FOUND
                        AND rgi.qtd < v_qtd_ped_ori THEN
                        CLOSE cr_po;
                        --/
                        OPEN cr_no(rgi.empresa,
                                   rgi.fil_origem,
                                   rgi.doc_origem,
                                   rgi.seq_origem,
                                   rgi.parte);
                        FETCH cr_no
                           INTO v_seq_ori;
                        IF cr_no%FOUND THEN
                           OPEN cr_mvs(v_seq_ori);
                           FETCH cr_mvs
                              INTO v_custo_ori;
                           CLOSE cr_mvs;
                        ELSE
                           v_custo_ori := rgi.valor_unit;
                        END IF;
                        CLOSE cr_no;
                        --/
                        v_val := cg_int.valor_pro(rgi.empresa,
                                                  rgi.produto,
                                                  'O');
                        IF v_val > 0 THEN
                           IF tab_val.EXISTS(v_val) THEN
                              tab_val(v_val) := tab_val(v_val) +
                                                round(v_custo_ori *
                                                      (v_qtd_ped_ori -
                                                      rgi.qtd),
                                                      2);
                           ELSE
                              tab_val(v_val) := round(v_custo_ori *
                                                      (v_qtd_ped_ori -
                                                      rgi.qtd),
                                                      2);
                           END IF;
                        END IF;
                     ELSE
                        CLOSE cr_po;
                     END IF;
                  ELSIF reg_oper.rm_origem = 'S' THEN
                     --/ origem recepcao
                     --/
                     OPEN cr_norm(rgi.empresa,
                                  rgi.fil_origem,
                                  rgi.doc_origem,
                                  rgi.seq_origem,
                                  rgi.ser_origem,
                                  rgi.parte,
                                  reg_nf.firma);
                     FETCH cr_norm
                        INTO v_qtd_ped_ori, v_seq_ori;
                     IF cr_norm%FOUND THEN
                        OPEN cr_mvs(v_seq_ori);
                        FETCH cr_mvs
                           INTO v_custo_ori;
                        CLOSE cr_mvs;
                     ELSE
                        v_custo_ori := rgi.valor_unit;
                     END IF;
                     CLOSE cr_norm;
                     --/
                     v_val := cg_int.valor_pro(rgi.empresa,
                                               rgi.produto,
                                               'O');
                     IF v_val > 0 THEN
                        IF tab_val.EXISTS(v_val) THEN
                           tab_val(v_val) := nvl(tab_val(v_val),
                                                 0) +
                                             round(v_custo_ori * rgi.qtd,
                                                   2);
                        ELSE
                           tab_val(v_val) := round(v_custo_ori * rgi.qtd,
                                                   2);
                        END IF;
                     END IF;

                  ELSE
                     --/ origem em NF propria
                     OPEN cr_nop(rgi.empresa,
                                 rgi.fil_origem,
                                 rgi.doc_origem,
                                 rgi.seq_origem,
                                 rgi.parte);
                     FETCH cr_nop
                        INTO v_qtd_ped_ori, v_seq_ori;
                     IF cr_nop%FOUND THEN
                        OPEN cr_mvs(v_seq_ori);
                        FETCH cr_mvs
                           INTO v_custo_ori;
                        CLOSE cr_mvs;
                     ELSE
                        v_custo_ori := rgi.valor_unit;
                     END IF;
                     CLOSE cr_nop;
                     --/
                     v_val := cg_int.valor_pro(rgi.empresa,
                                               rgi.produto,
                                               'O');
                     IF v_val > 0 THEN
                        IF tab_val.EXISTS(v_val) THEN
                           tab_val(v_val) := nvl(tab_val(v_val),
                                                 0) +
                                             round(v_custo_ori * rgi.qtd,
                                                   2);
                        ELSE
                           tab_val(v_val) := round(v_custo_ori * rgi.qtd,
                                                   2);
                        END IF;
                     END IF;

                  END IF;
               END IF;

               --| Se for entrada (devolucao) buscar o custo que o produto saiu (de ce_movest)
            ELSE

               OPEN cr_no(rgi.empresa,
                          rgi.fil_origem,
                          rgi.doc_origem,
                          rgi.ser_origem,
                          rgi.parte);
               FETCH cr_no
                  INTO v_seq_ori;
               IF cr_no%FOUND THEN
                  OPEN cr_mvs(v_seq_ori);
                  FETCH cr_mvs
                     INTO v_custo;
                  CLOSE cr_mvs;
               ELSE
                  v_custo := rgi.valor_unit;
               END IF;
               CLOSE cr_no;
               v_val := cg_int.valor_pro(rgi.empresa,
                                         rgi.produto,
                                         'C');
               IF v_val > 0 THEN
                  IF tab_val.EXISTS(v_val) THEN
                     tab_val(v_val) := tab_val(v_val) +
                                       round(v_custo * rgi.qtd,
                                             2);
                  ELSE
                     tab_val(v_val) := round(v_custo * rgi.qtd,
                                             2);
                  END IF;
               END IF;
            END IF;

            --| Verifica os valores para contabilizacao : ICMS
            v_val := cg_int.valor_pro(rgi.empresa,
                                      rgi.produto,
                                      'I');
            IF v_val > 0 THEN
               IF tab_val.EXISTS(v_val) THEN
                  tab_val(v_val) := tab_val(v_val) +
                                    nvl(rgi.vl_icms,
                                        0) + nvl(rgi.vl_icms_pro,
                                                 0) +
                                    nvl(rgi.vl_icms_sub,
                                        0);
               ELSE
                  tab_val(v_val) := nvl(rgi.vl_icms,
                                        0) + nvl(rgi.vl_icms_pro,
                                                 0);
               END IF;
            END IF;

            --| Verifica os valores para contabilizacao : IPI
            v_val := cg_int.valor_pro(rgi.empresa,
                                      rgi.produto,
                                      'P');
            IF v_val > 0 THEN
               IF tab_val.EXISTS(v_val) THEN
                  tab_val(v_val) := tab_val(v_val) + rgi.vl_ipi;
               ELSE
                  tab_val(v_val) := rgi.vl_ipi;
               END IF;
            END IF;

            --| Verifica os valores para contabilizacao : Rateio de ICMS DESPESAS/FRETE
            IF valor_icms_desp > 0 THEN
               IF nvl(rgi.vl_icms,
                      0) > 0 THEN
                  v_item_icms_atual := v_item_icms_atual + 1;
                  IF v_item_icms_atual < v_tot_itens_icms THEN
                     v_icms_desp     := round(valor_icms_desp *
                                              ((rgi.valor_unit *
                                              rgi.qtd_val) /
                                              v_produtos_icms),
                                              2);
                     v_tot_icms_desp := v_tot_icms_desp - v_icms_desp;
                  ELSE
                     v_icms_desp := v_tot_icms_desp;
                  END IF;
                  v_val := cg_int.valor_pro(rgi.empresa,
                                            rgi.produto,
                                            'I');
                  IF v_val > 0 THEN
                     IF tab_val.EXISTS(v_val) THEN
                        tab_val(v_val) := tab_val(v_val) +
                                          nvl(v_icms_desp,
                                              0);
                     ELSE
                        tab_val(v_val) := v_icms_desp;
                     END IF;
                  END IF;
               END IF;
            END IF;

            v_item_atual := v_item_atual + 1;

            --| Verifica os valores para contabilizacao : PIS
            IF valor_pis > 0 THEN
               IF v_item_atual < v_tot_itens THEN
                  v_pis     := round(valor_pis *
                                     ((rgi.valor_unit * rgi.qtd_val) /
                                     reg_nf.vl_produtos),
                                     2);
                  v_tot_pis := v_tot_pis - v_pis;
               ELSE
                  v_pis := v_tot_pis;
               END IF;
               v_val := cg_int.valor_pro(rgi.empresa,
                                         rgi.produto,
                                         'S');
               IF v_val > 0 THEN
                  IF tab_val.EXISTS(v_val) THEN
                     tab_val(v_val) := tab_val(v_val) + v_pis;
                  ELSE
                     tab_val(v_val) := v_pis;
                  END IF;
               END IF;
            END IF;

            --| Verifica os valores para contabilizacao : COFINS
            IF valor_cofins > 0 THEN
               IF v_item_atual < v_tot_itens THEN
                  v_cofins     := round(valor_cofins *
                                        ((rgi.valor_unit * rgi.qtd_val) /
                                        reg_nf.vl_produtos),
                                        2);
                  v_tot_cofins := v_tot_cofins - v_cofins;
               ELSE
                  v_cofins := v_tot_cofins;
               END IF;
               v_val := cg_int.valor_pro(rgi.empresa,
                                         rgi.produto,
                                         'F');
               IF v_val > 0 THEN
                  IF tab_val.EXISTS(v_val) THEN
                     tab_val(v_val) := tab_val(v_val) + v_cofins;
                  ELSE
                     tab_val(v_val) := v_cofins;
                  END IF;
               END IF;
            END IF;

            --| Verifica os valores para contabilizacao : Rateio de DESPESAS/FRETES
            IF valor_despesas > 0 THEN
               IF v_item_atual < v_tot_itens THEN
                  v_despesas     := round(valor_despesas *
                                          ((rgi.valor_unit * rgi.qtd_val) /
                                          reg_nf.vl_produtos),
                                          2);
                  v_tot_despesas := v_tot_despesas - v_despesas;
               ELSE
                  v_despesas := v_tot_despesas;
               END IF;
               v_val := cg_int.valor_pro(rgi.empresa,
                                         rgi.produto,
                                         'R');
               IF v_val > 0 THEN
                  IF tab_val.EXISTS(v_val) THEN
                     tab_val(v_val) := tab_val(v_val) + v_despesas;
                  ELSE
                     tab_val(v_val) := v_despesas;
                  END IF;
               END IF;
            END IF;

         END LOOP;

         -- Adiantamento (Colocado na parcela como c_apresent='S')
         /*    If reg_oper.PRE_PAGO = 'S' Then
           Select Sum( VALOR )
             InTo V_ADIANT
             From FT_Parc_NF
            Where EMPRESA  = reg_nf.EMPRESA
              And FILIAL   = reg_nf.FILIAL
              And NUM_NOTA = reg_nf.NUM_NOTA
              And SR_NOTA  = reg_nf.SR_NOTA
              And PARTE    = reg_nf.PARTE
              And C_APRESENT = 'S';
         End If;*/

         --| Se chamado para contabilizar automaticamente
         IF aut = 'S' THEN

            --| Verifica a transacao
            OPEN cr_ot2(reg_nf.cod_oper,
                        reg_nf.empresa,
                        reg_nf.filial,
                        reg_nf.cod_condpag);
            FETCH cr_ot2
               INTO v_trans;
            IF cr_ot2%NOTFOUND
               OR nvl(v_trans,
                      0) = 0 THEN
               v_trans := NULL;
            END IF;
            CLOSE cr_ot2;

            --| Verifica a transacao
            IF v_trans IS NULL THEN
               OPEN cr_ot(reg_nf.cod_oper,
                          reg_nf.empresa,
                          reg_nf.filial);
               FETCH cr_ot
                  INTO v_trans;
               -- Se nao encontrar : nao contabiliza
               IF cr_ot%NOTFOUND
                  OR nvl(v_trans,
                         0) = 0 THEN
                  CLOSE cr_ot;
                  resultado.erro_cont := 6;
                  RETURN NULL;
               END IF;
               CLOSE cr_ot;
            END IF;

            -- Se encontrou, le a area fonte
            SELECT cod_afonte
              INTO v_afonte
              FROM cg_trans
             WHERE empresa = reg_nf.empresa
               AND cod_trans = v_trans;

            -- Prepara para integracao contabil
            cg_int.novo_lote;
            cg_int.inicia('',
                          '');
            cg_int.seta_historico(1,
                                  to_char(num) || ' - ' ||
                                  reg_cfo.descricao);
            cg_int.seta_historico(2,
                                  to_char(num));
            IF reg_oper.remessa = 'N' THEN
               cg_int.seta_historico(3,
                                     cd_firmas_utl.nome(reg_nf.firma));
               cg_int.seta_historico(4,
                                     cd_firmas_utl.nome(reg_nf.firma));
            ELSE
               cg_int.seta_historico(3,
                                     cd_firmas_utl.nome(nvl(reg_nf.agente1,
                                                            reg_nf.firma)));
               cg_int.seta_historico(4,
                                     cd_firmas_utl.nome(nvl(reg_nf.agente1,
                                                            reg_nf.firma)));
            END IF;
            cg_int.seta_historico(9,
                                  substr(snotas,
                                         1,
                                         2000));
            cg_int.seta_historico(10,
                                  substr(v_desc_pro,
                                         1,
                                         2000));
            cg_int.seta_valor(1,
                              reg_nf.vl_total);
            cg_int.seta_valor(3,
                              reg_nf.vl_icms + nvl(reg_nf.vl_icms_pro,
                                                   0));
            cg_int.seta_valor(4,
                              reg_nf.vl_ipi);
            --      cg_int.seta_valor(5,reg_nf.vl_total - nvl(reg_nf.vl_icms,0) - nvl(reg_nf.vl_pis,0));
            --cg_int.seta_valor(5,reg_nf.vl_total - nvl(reg_nf.vl_ipi,0));
            cg_int.seta_valor(5,
                              reg_nf.vl_total - nvl(reg_nf.vl_ipi,
                                                    0) -
                              nvl(reg_nf.vl_icms,
                                  0) - nvl(reg_nf.vl_pis,
                                           0) - nvl(reg_nf.vl_cofins,
                                                    0));
            cg_int.seta_valor(6,
                              reg_nf.vl_frete);
            cg_int.seta_valor(7,
                              v_adiant);
            cg_int.seta_valor(8,
                              reg_nf.vl_desc_ir);
            cg_int.seta_valor(9,
                              reg_nf.vl_iss);
            cg_int.seta_valor(18,
                              reg_nf.vl_pis);
            cg_int.seta_valor(19,
                              reg_nf.vl_cofins);
            cg_int.seta_valor(20,
                              reg_nf.vl_biss);
            cg_int.seta_valor(21,
                              reg_nf.vl_inss);
            cg_int.seta_valor(31,
                              reg_nf.vl_ccp);
            cg_int.seta_valor(25,
                              reg_nf.vl_icms_sub);
            cg_int.seta_valor(30,
                              reg_nf.vl_total - nvl(reg_nf.vl_ipi,
                                                    0));
            cg_int.seta_valor(32,
                              vl_csll);
            cg_int.seta_valor(33,
                              vl_cofins);
            cg_int.seta_valor(34,
                              vl_pis);
            --cg_int.seta_valor(110,vl_custo_med);
            --| Seta valores dos produtos
            v_val := tab_val.FIRST;
            WHILE v_val IS NOT NULL LOOP
               IF v_val >= 100 THEN
                  cg_int.seta_valor(v_val,
                                    tab_val(v_val));
               END IF;
               v_val := tab_val.NEXT(v_val);
            END LOOP;

            SELECT cg_lotes_seq.NEXTVAL
              INTO v_lote_cont
              FROM dual;
            cg_int.prepara(reg_nf.empresa,
                           v_lote_cont,
                           v_trans,
                           trunc(reg_nf.dt_emissao),
                           v_afonte,
                           reg_nf.firma,
                           NULL,
                           NULL);
            cg_int.seta_filial(reg_nf.filial);
            cg_int.cenario(reg_nf.parte);

            cg_int.estorno(FALSE);
            cg_int.set_commit(FALSE);
            cg_int.monta_transacao;

            -- Verifica se retornou erro de contabilizacao
            v_erc := chk_lancto(emp,
                                v_lote_cont,
                                trunc(reg_nf.dt_emissao));
            IF v_erc > 0 THEN
               IF reg_nf.parte = 0 THEN
                  resultado.erro_cont := v_erc;
               ELSE
                  resultado.erro_cont2 := v_erc;
               END IF;
               cg_int.limpa_lote;
               v_ret_lote := NULL;

               -- Se chegou aqui : Contabiliza
            ELSE
               IF reg_nf.parte = 0 THEN
                  resultado.erro_cont := v_erc;
               ELSE
                  resultado.erro_cont2 := v_erc;
               END IF;
               cg_int.grava_lote;
               resultado.nr_cont := resultado.nr_cont + 1;
               IF reg_nf.parte = 0 THEN
                  resultado.lote_cont := cg_int.ler_ultlote;
                  v_ret_lote          := resultado.lote_cont;
               ELSE
                  resultado.lote_cont2 := cg_int.ler_ultlote;
                  v_ret_lote           := resultado.lote_cont2;
               END IF;
            END IF;

            --| Se chamado interativamente do form
         ELSE

            -- Prepara para integracao contabil
            cg_int.novo_lote;
            cg_int.inicia('',
                          '');
            cg_int.seta_filial(reg_nf.filial);
            cg_int.seta_historico(1,
                                  to_char(num) || ' - ' ||
                                  reg_cfo.descricao);
            cg_int.seta_historico(2,
                                  to_char(num));
            cg_int.seta_historico(3,
                                  cd_firmas_utl.nome(reg_nf.firma));
            cg_int.seta_historico(4,
                                  cd_firmas_utl.nome(reg_nf.firma));
            cg_int.seta_historico(9,
                                  substr(snotas,
                                         1,
                                         2000));
            cg_int.seta_historico(10,
                                  substr(v_desc_pro,
                                         1,
                                         2000));
            cg_int.seta_valor(1,
                              reg_nf.vl_total);
            cg_int.seta_valor(3,
                              reg_nf.vl_icms + nvl(reg_nf.vl_icms_pro,
                                                   0));
            cg_int.seta_valor(4,
                              reg_nf.vl_ipi);
            --      cg_int.seta_valor(5,reg_nf.vl_total - nvl(reg_nf.vl_icms,0) - nvl( reg_nf.vl_pis, 0 ));
            --      cg_int.seta_valor(5,reg_nf.vl_total - nvl(reg_nf.vl_ipi,0));
            cg_int.seta_valor(5,
                              reg_nf.vl_total - nvl(reg_nf.vl_ipi,
                                                    0) -
                              nvl(reg_nf.vl_icms,
                                  0) - nvl(reg_nf.vl_pis,
                                           0) - nvl(reg_nf.vl_cofins,
                                                    0));
            cg_int.seta_valor(6,
                              reg_nf.vl_frete);
            cg_int.seta_valor(7,
                              v_adiant);
            cg_int.seta_valor(8,
                              reg_nf.vl_desc_ir);
            cg_int.seta_valor(9,
                              reg_nf.vl_iss);
            cg_int.seta_valor(18,
                              reg_nf.vl_pis);
            cg_int.seta_valor(19,
                              reg_nf.vl_cofins);
            cg_int.seta_valor(20,
                              reg_nf.vl_biss);
            cg_int.seta_valor(21,
                              reg_nf.vl_inss);
            cg_int.seta_valor(31,
                              reg_nf.vl_ccp);
            cg_int.seta_valor(25,
                              reg_nf.vl_icms_sub);
            cg_int.seta_valor(30,
                              reg_nf.vl_total - nvl(reg_nf.vl_ipi,
                                                    0));
            cg_int.seta_valor(32,
                              vl_csll);
            cg_int.seta_valor(33,
                              vl_cofins);
            cg_int.seta_valor(34,
                              vl_pis);
            cg_int.cenario(reg_nf.parte);

            --| Seta valores dos produtos
            v_val := tab_val.FIRST;
            WHILE v_val IS NOT NULL LOOP
               IF v_val >= 100 THEN
                  cg_int.seta_valor(v_val,
                                    tab_val(v_val));
               END IF;
               v_val := tab_val.NEXT(v_val);
            END LOOP;

            v_ret_lote := NULL;

         END IF; --| if aut ...

      END LOOP;

      --raise_application_error(-20100, vl_csll||' '||vl_cofins||' '||vl_pis);

      RETURN v_ret_lote;

   END;

   --------------------------------------------------------------------------------
   PROCEDURE grava_comp(rt comp_nota_t)
   /*
      || Prepara os dados de transporte e volume
      */
    IS

   BEGIN

      comp_nota.cod_transp    := rt.cod_transp;
      comp_nota.motorista     := rt.motorista;
      comp_nota.cpf_mot       := rt.cpf_mot;
      comp_nota.placa_veic    := rt.placa_veic;
      comp_nota.placa_uf      := rt.placa_uf;
      comp_nota.vol_qtd       := rt.vol_qtd;
      comp_nota.vol_especie   := rt.vol_especie;
      comp_nota.vol_marca     := rt.vol_marca;
      comp_nota.vol_numero    := rt.vol_numero;
      comp_nota.peso_liquido  := rt.peso_liquido;
      comp_nota.peso_bruto    := rt.peso_bruto;
      comp_nota.tp_frete      := rt.tp_frete;
      comp_nota.vl_frete      := rt.vl_frete;
      comp_nota.vl_embalagem  := rt.vl_embalagem;
      comp_nota.vl_seguro     := rt.vl_seguro;
      comp_nota.local_sai     := rt.local_sai;
      comp_nota.vl_frete_au   := rt.vl_frete_au;
      comp_nota.msg_adicional := rt.msg_adicional;

   END;

   --------------------------------------------------------------------------------
   FUNCTION le_resultado RETURN resultado_t
   /*
      || Retorna resultados da operacao
      */
    IS

   BEGIN

      RETURN resultado;

   END;

   --------------------------------------------------------------------------------
   FUNCTION checa_param(emp IN ft_pedidos.empresa%TYPE,
                        fil IN ft_pedidos.filial%TYPE) RETURN NUMBER
   /*
      || Checa parametros para emissao da nota
      */
    IS

   BEGIN

      RETURN 0;

   END;
   --------------------------------------------------------------------------------
   FUNCTION  monta_descr_prod(p_descr  ft_itens_ped.descricao%type
                             ,p_unid   ft_itens_ped.uni_ven%type
                             ,p_qtd_pc ft_itens_ped.qtd_pc%type
                             ,p_comp   ft_itens_ped.comp%type
                             ,p_larg   ft_itens_ped.larg%type
                             ,p_qtd    ft_itens_ped.qtd_ped%type
                             ) return  ft_itens_ped.descricao%type
    is 
    
    v_ret ft_itens_ped.descricao%type;
    v_qtd number;
    
    begin
      v_qtd := p_qtd_pc;
      
      if p_unid IN ( 'PC', 'UN','CJ') THEN
        if nvl(v_qtd,0) = 0 then
           v_qtd := p_qtd;
        end if;
      END IF;
      --/
      if NVL(p_comp,0) > 0  then
         
         v_ret := v_qtd || ' PC de '|| p_comp;
         if NVL(p_larg,0) > 0  then
            v_ret := v_ret || ' X '|| p_larg;
         end if;
      elsif  NVL(p_larg,0) > 0 then
         v_ret := v_qtd || ' PC de '|| p_larg;
      end if;
      --/
      if v_ret is not null then
         v_ret := p_descr || ' - '|| v_ret ||' MM';
      else
         v_ret := p_descr;
      end if;
      --/
      return v_ret;
      --/
    EXCEPTION 
      WHEN OTHERS THEN
         RETURN P_DESCR;
    end;
   --------------------------------------------------------------------------------
   PROCEDURE cria_nota(emp IN ft_pedidos.empresa%TYPE,
                       fil IN ft_pedidos.filial%TYPE,
                       num IN ft_pedidos.num_pedido%TYPE,
                       dta IN DATE,
                       com IN BOOLEAN := FALSE,
                       tmp IN NUMBER := 0,
                       ger IN BOOLEAN := TRUE)
   /*
      || Grava nota de um pedido
      */
    IS

      v_integrar cg_prgen.integrar%TYPE;
      v_result   NUMBER;
      nnf        ft_notas.num_nota%TYPE;
      ser        ft_notas.sr_nota%TYPE;
      b_imp      BOOLEAN;
      v_nf       ft_notas.num_nota%TYPE;
      v_sr       ft_notas.sr_nota%TYPE;
      reg_ped    ft_pedidos%ROWTYPE;
      reg_opr    ft_oper%ROWTYPE;
      px         ft_notas.parte%TYPE;
      px2        ft_notas.parte%TYPE;
      v_aux      varchar2(100);
   BEGIN

      --| Limpa registro de resultados
      IF tmp = 0 THEN
         resultado.numero_inicial := NULL;
         resultado.numero_final   := NULL;
         resultado.titulo_inicial := NULL;
         resultado.titulo_final   := NULL;
         resultado.lote_cont      := NULL;
         resultado.erro_cont      := 0;
         resultado.livro          := FALSE;
         resultado.nr_cont        := 0;
         resultado.nr_livro       := 0;
         resultado.lote_cont2     := NULL;
         resultado.erro_cont2     := 0;
      END IF;

      --| Verifica se integracao contabil ligada
      SELECT integrar
        INTO v_integrar
        FROM cg_prgen;

      --| Prepara os registros temporarios de pedidos
      IF tmp = 0 THEN

         INSERT INTO t_pedidos
            (SELECT *
               FROM ft_pedidos
              WHERE empresa = emp
                AND filial = fil
                AND num_pedido = num);
v_aux := 'PASSO:01';
         INSERT INTO t_itens_ped
            (SELECT EMPRESA      ,  
                    FILIAL       , 
                    NUM_PEDIDO   ,
                    PRODUTO      ,
                    SEQ_ITEM     ,
                    FT_NF.monta_descr_prod( DESCRICAO    ,UNI_VEN,QTD_PC,COMP,LARG,QTD_PED) DESCRICAO,
                    QTD_PED      ,
                    UNI_VEN      ,
                    UNI_EST      ,
                    UNI_VAL      ,
                    VALOR_UNIT   ,
                    QTD_VAL      ,
                    QTD_FAT      ,
                    QTD_DEV      ,
                    QTD_CAN      ,
                    VALOR_BASE   ,
                    FIL_ORIGEM   ,
                    DOC_ORIGEM   ,
                    SER_ORIGEM   ,
                    SEQ_ORIGEM   ,
                    SEQ_MOVEST   ,
                    VL_ORIGEM    ,
                    VL_BASE_ORI  ,
                    LOCAL        ,
                    FIL_LOCAL    ,
                    UNI_EMB      ,
                    QTD_EMB      ,
                    PC_COM       ,
                    PC_CAL       ,
                    OBSERVACAO   ,
                    PRO_VENDA    ,
                    COD_CFO      ,
                    COMP         ,
                    LARG         ,
                    PROF         ,
                    COR          ,
                    NUM_CHAPA    ,
                    SEQ_ITEM_ROM ,
                    USU_INCL     ,
                    DT_INCL      ,
                    USU_ALT      ,
                    DT_ALT       ,
                    OPOS         ,
                    QTD_PC       ,
                    PESO         ,
                    vl_desconto
            
               FROM ft_itens_ped
              WHERE empresa = emp
                AND filial = fil
                AND num_pedido = num);
      v_aux := 'PASSO:02';
         INSERT INTO t_parc_ped
            (SELECT *
               FROM ft_parc_ped
              WHERE empresa = emp
                AND filial = fil
                AND num_pedido = num);

      v_aux := 'PASSO:03';
         INSERT INTO t_parc_ped1
            (SELECT *
               FROM ft_parc_ped2
              WHERE empresa = emp
                AND filial = fil
                AND num_pedido = num);
      END IF;
      v_aux := 'PASSO:04';
      --| Le o pedido
      SELECT *
        INTO reg_ped
        FROM ft_pedidos
       WHERE empresa = emp
         AND filial = fil
         AND num_pedido = num;

      v_aux := 'PASSO:05';
      --| Le a operacao
      SELECT *
        INTO reg_opr
        FROM ft_oper
       WHERE empresa = emp
         AND cod_oper = reg_ped.cod_oper;

      nnf := NULL;
      ser := NULL;

      v_aux := 'PASSO:06';
      --| Se nao for gerar nota, nao calcula impostos (vai usar do pedido)
      IF NOT ger THEN
         b_imp := FALSE;
         nnf   := reg_ped.num_nota;
         ser   := '000';
      ELSE
         IF reg_opr.serie5 = 'X' THEN
            b_imp := FALSE;
            nnf   := reg_ped.num_nota;
            ser   := reg_ped.sr_nota;
         ELSE
            b_imp := TRUE;
         END IF;
      END IF;
      v_aux := 'PASSO:07';
      --| Auditar
      ft_log.auditar;
      v_aux := 'PASSO:08';
      ---------------------------------------------------------------
      --/ GERA A NOTA E OS ITENS
      ---------------------------------------------------------------
      begin
      grava_nf(emp,
               fil,
               num,
               dta,
               nnf,
               ser,
               b_imp);
      --exception
        -- when others then
          -- raise_application_error(-20105,'aqui');
      end;
      v_aux := 'PASSO:09';
      ---------------------------------------------------------------
      --/ AUDITA NOTA
      ---------------------------------------------------------------
      begin
      ft_log.audita_nf(emp,
                       fil,
                       num,
                       dta,
                       nnf,
                       ser,
                       px,
                       g_dias_mais);
     -- exception
      --   when others then
       --    raise_application_error(-20101,'aqui2');
      end;
      v_aux := 'PASSO:10';
      g_dev := 'N';
      --| Se for devolucao - Grava registro em ft_devol/ft_itens_dev e atualiza adiantamento
      IF NOT ger THEN
         cria_dev(emp,
                  fil,
                  nnf,
                  ser,
                  dta,
                  reg_ped.num_nota,
                  reg_ped.sr_nota,
                  px);
         g_dev := 'S';
      END IF;
     v_aux := 'PASSO:11-transporte';   
     transporte_nf(emp,
               fil,
               num,
               ser);
      
     v_aux := 'PASSO:11-estoque';     
     --| Integra com estoque  
     begin
      IF nvl(px,
             0) = 0
         OR reg_opr.natureza = 'S'
         OR ser = '999' THEN
         --vg_custo_med := 0;
         estoque_nf(emp,
                    fil,
                    nnf,
                    ser,
                    reg_ped.num_nota,
                    reg_ped.sr_nota,
                    px);
      END IF;

      end;
      v_aux := 'PASSO:12';
      --| Integra com Contas a Receber
      crec_nf(emp,
              fil,
              nnf,
              ser,
              reg_ped);

      v_aux := 'PASSO:13';
      --| Integra com Adiantamentos
      adiant_nf(emp,
                fil,
                nnf,
                ser,
                reg_ped.num_nota,
                reg_ped.sr_nota,
                px);
     v_aux := 'PASSO:14';
     --| Integra com livro fiscal
     begin
     IF px = 0 and 1=2 /*28/12/2012*/ THEN
         livro_nf(emp,
                  fil,
                  nnf,
                  ser,
                  reg_ped.num_nota,
                  reg_ped.sr_nota);
      END IF;
       --  exception
         --    when others then
         --  raise_application_error(-20102,'aqui2');
      end;
      v_aux := 'PASSO:15';
      --| Integra com contabilidade
      IF v_integrar = 'S' and 1=2 /*28/12/2012*/
         AND nnf IS NOT NULL THEN
         BEGIN
            v_result := contab_nf(emp,
                                  fil,
                                  nnf,
                                  ser,
                                  0,
                                  'S');
         EXCEPTION
            WHEN OTHERS THEN
               NULL; ---
         END;

         v_aux := 'PASSO:16';         
         IF resultado.lote_cont IS NOT NULL THEN
            -- Se gerou nossa nota, grava lote contabil nela
            IF ger THEN
               UPDATE ft_notas
                  SET lote_cont = resultado.lote_cont
                WHERE empresa = emp
                  AND filial = fil
                  AND num_nota = nnf
                  AND sr_nota = ser
                  AND parte = 0;
               -- Se nota de devolucao do cliente, grava lote contabil em ft_devol
            ELSE
               UPDATE ft_devol
                  SET lote_cont = resultado.lote_cont
                WHERE empresa = emp
                  AND filial = fil
                  AND num_nota = reg_ped.num_nota
                  AND sr_nota = reg_ped.sr_nota
                  AND firma = reg_ped.firma;
            END IF;
         END IF;

         v_aux := 'PASSO:17';
         IF resultado.lote_cont2 IS NOT NULL THEN
            -- Se gerou nossa nota, grava lote contabil nela
            IF ger THEN
               UPDATE ft_notas
                  SET lote_cont = resultado.lote_cont2
                WHERE empresa = emp
                  AND filial = fil
                  AND num_nota = nnf
                  AND sr_nota = ser
                  AND parte = 1;
            END IF;
         END IF;

      END IF;
      v_aux := 'PASSO:18';
      --| Acerta o status do pedido
      IF tmp IN (0, 2) THEN
         UPDATE ft_pedidos
            SET status = 'F'
          WHERE empresa = emp
            AND filial = fil
            AND num_pedido = num;

         --| Atualiza romaneio com numero da NF
            update ft_roman r
              set r.num_nota = nnf
                ,r.sr_nota   = ser
             where r.empresa = emp
               and r.filial  = fil
               and r.num_pedido = num;
      v_aux := 'PASSO:19';               
      ELSE
         UPDATE ft_pedidos
            SET status = 'P'
          WHERE empresa = emp
            AND filial = fil
            AND num_pedido = num;
            
      END IF;
      v_aux := 'PASSO:20';
      --| Se nao esta gerando nossa nota - deleta
      IF NOT ger THEN
         DELETE FROM ft_itens_nf
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = nnf
            AND sr_nota = ser
            AND parte = 0;
         v_aux := 'PASSO:21';            
         DELETE FROM ft_msgs_nf
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = nnf
            AND sr_nota = ser
            AND parte = 0;
         v_aux := 'PASSO:22';            
         DELETE FROM ft_notas
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = nnf
            AND sr_nota = ser
            AND parte = 0;
      END IF;
      v_aux := 'PASSO:23';
      --| Deleta os registros temporarios de pedidos
      DELETE FROM t_parc_ped
       WHERE empresa = emp
         AND filial = fil
         AND num_pedido = num;
      v_aux := 'PASSO:24';         
      DELETE FROM t_parc_ped1
       WHERE empresa = emp
         AND filial = fil
         AND num_pedido = num;

      v_aux := 'PASSO:25';         
      DELETE FROM t_itens_ped
       WHERE empresa = emp
         AND filial = fil
         AND num_pedido = num;

      v_aux := 'PASSO:26';         
      DELETE FROM t_pedidos
       WHERE empresa = emp
         AND filial = fil
         AND num_pedido = num;
      IF com THEN
         COMMIT;
      END IF;
      v_aux := 'PASSO:27';
/*
   exception
     when others then
           raise_application_error(-20101,
                                          v_aux||' - ' || substr(sqlerrm,1,200)
                                          ); 
    */                                   
   END;

   --------------------------------------------------------------------------------
   PROCEDURE fatura_exped(emp IN ft_exped.empresa%TYPE,
                          fil IN ft_exped.filial%TYPE,
                          num IN ft_exped.num_exped%TYPE,
                          dta IN DATE,
                          com IN BOOLEAN)
   /*
      || Fatura expedicao
      */
    IS

      CURSOR cr_exp IS
         SELECT *
           FROM ft_exped
          WHERE empresa = emp
            AND filial = fil
            AND num_exped = num
            FOR UPDATE;
      reg_exp ft_exped%ROWTYPE;

      CURSOR cr_ped IS
         SELECT DISTINCT empresa,
                         fil_pedido,
                         firma,
                         classe,
                         cod_condpag,
                         cod_condpag2,
                         tipo_tit,
                         tipo_tit2,
                         tipo_cob,
                         tipo_cob2,
                         moeda
           FROM vft_itens_exp
          WHERE empresa = emp
            AND filial = fil
            AND num_exped = num;

      CURSOR cr_pri(a vft_itens_exp.fil_pedido%TYPE, b vft_itens_exp.firma%TYPE, c vft_itens_exp.classe%TYPE, d vft_itens_exp.cod_condpag%TYPE, e vft_itens_exp.cod_condpag2%TYPE, f vft_itens_exp.tipo_tit%TYPE, g vft_itens_exp.tipo_tit2%TYPE, h vft_itens_exp.tipo_cob%TYPE, i vft_itens_exp.tipo_cob2%TYPE, m vft_itens_exp.moeda%TYPE) IS
         SELECT num_pedido
           FROM vft_itens_exp
          WHERE empresa = emp
            AND filial = fil
            AND num_exped = num
            AND fil_pedido = a
            AND firma = b
            AND classe = c
            AND cod_condpag = d
            AND nvl(cod_condpag2,
                    0) = nvl(e,
                             0)
            AND tipo_tit = f
            AND nvl(tipo_tit2,
                    0) = nvl(g,
                             0)
            AND tipo_cob = h
            AND nvl(tipo_cob2,
                    0) = nvl(i,
                             0)
            AND nvl(moeda,
                    'R$') = nvl(m,
                                'R$')
          ORDER BY num_pedido;
      v_num_pedido ft_pedidos.num_pedido%TYPE;

      CURSOR cr_iex(a vft_itens_exp.fil_pedido%TYPE, b vft_itens_exp.firma%TYPE, c vft_itens_exp.classe%TYPE, d vft_itens_exp.cod_condpag%TYPE, e vft_itens_exp.cod_condpag2%TYPE, f vft_itens_exp.tipo_tit%TYPE, g vft_itens_exp.tipo_tit2%TYPE, h vft_itens_exp.tipo_cob%TYPE, i vft_itens_exp.tipo_cob2%TYPE, m vft_itens_exp.moeda%TYPE) IS
         SELECT *
           FROM vft_itens_exp
          WHERE empresa = emp
            AND filial = fil
            AND num_exped = num
            AND fil_pedido = a
            AND firma = b
            AND classe = c
            AND cod_condpag = d
            AND nvl(cod_condpag2,
                    0) = nvl(e,
                             0)
            AND tipo_tit = f
            AND nvl(tipo_tit2,
                    0) = nvl(g,
                             0)
            AND tipo_cob = h
            AND nvl(tipo_cob2,
                    0) = nvl(i,
                             0)
            AND nvl(moeda,
                    'R$') = nvl(m,
                                'R$');

      CURSOR cr_i(n ft_itens_ped.seq_item%TYPE) IS
         SELECT *
           FROM ft_itens_ped
          WHERE seq_item = n;
      reg_i ft_itens_ped%ROWTYPE;

      v_sal    NUMBER;
      v_vol    NUMBER;
      v_peso   NUMBER;
      v_espec  VARCHAR2(500);
      v_cambio NUMBER;
      v_dias   NUMBER;

   BEGIN

      g_dias_mais := 0;

      DELETE FROM t_itens_ped;
      DELETE FROM t_parc_ped;
      DELETE FROM t_parc_ped1;
      DELETE FROM t_pedidos;

      --| Prepara valores de transporte
      resultado.numero_inicial := NULL;
      resultado.numero_final   := NULL;
      resultado.titulo_inicial := NULL;
      resultado.titulo_final   := NULL;
      resultado.lote_cont      := NULL;
      resultado.erro_cont      := 0;
      resultado.livro          := FALSE;
      resultado.nr_cont        := 0;
      resultado.nr_livro       := 0;

      --| Le o registro da expedicao
      OPEN cr_exp;
      FETCH cr_exp
         INTO reg_exp;
      IF cr_exp%NOTFOUND THEN
         CLOSE cr_exp;
         raise_application_error(-20105,
                                 'Expedição não encontrada');
      END IF;
      IF reg_exp.status <> 'A' THEN
         CLOSE cr_exp;
         raise_application_error(-20105,
                                 'Expedição ja faturada');
      END IF;

      --| Para cada caso distinto na expedicao
      FOR reg_ped IN cr_ped LOOP

         -- Le o primeiro pedido com este numero
         OPEN cr_pri(reg_ped.fil_pedido,
                     reg_ped.firma,
                     reg_ped.classe,
                     reg_ped.cod_condpag,
                     reg_ped.cod_condpag2,
                     reg_ped.tipo_tit,
                     reg_ped.tipo_tit2,
                     reg_ped.tipo_cob,
                     reg_ped.tipo_cob2,
                     reg_ped.moeda);
         FETCH cr_pri
            INTO v_num_pedido;
         CLOSE cr_pri;

         --| Cria pedido temporario igual
         INSERT INTO t_pedidos
            SELECT *
              FROM ft_pedidos
             WHERE empresa = reg_ped.empresa
               AND filial = reg_ped.fil_pedido
               AND num_pedido = v_num_pedido;

         --| Cria parcelas iguais
         INSERT INTO t_parc_ped
            SELECT *
              FROM ft_parc_ped
             WHERE empresa = reg_ped.empresa
               AND filial = reg_ped.fil_pedido
               AND num_pedido = v_num_pedido;
               
               
         INSERT INTO t_parc_ped1
            SELECT *
              FROM ft_parc_ped2
             WHERE empresa = reg_ped.empresa
               AND filial = reg_ped.fil_pedido
               AND num_pedido = v_num_pedido;

         v_vol   := 0;
         v_peso  := 0;
         v_espec := '';
         v_dias  := 0;

         IF reg_ped.moeda IS NULL THEN
            v_cambio := 1;
         ELSE
            v_cambio := fn_moeda.conv2(reg_ped.moeda,
                                       dta,
                                       emp);
            IF v_cambio = 0 THEN
               raise_application_error(-20105,
                                       'Nenhuma taxe de cambio encontrada');
            END IF;
         END IF;

         --| Cria itens deste pedido baseados nos itens da expedicao
         FOR reg_iex IN cr_iex(reg_ped.fil_pedido,
                               reg_ped.firma,
                               reg_ped.classe,
                               reg_ped.cod_condpag,
                               reg_ped.cod_condpag2,
                               reg_ped.tipo_tit,
                               reg_ped.tipo_tit2,
                               reg_ped.tipo_cob,
                               reg_ped.tipo_cob2,
                               reg_ped.moeda) LOOP

            OPEN cr_i(reg_iex.seq_item);
            FETCH cr_i
               INTO reg_i;
            CLOSE cr_i;
            
            INSERT INTO t_itens_ped
            VALUES
               (reg_ped.empresa,
                reg_ped.fil_pedido,
                v_num_pedido,
                reg_i.produto,
                reg_i.seq_item,
                reg_i.descricao,
                reg_iex.qtd_ped,
                reg_i.uni_ven,
                reg_i.uni_est,
                reg_i.uni_val,
                reg_i.valor_unit * v_cambio,
                reg_iex.qtd_val,
                0, -- qtd_fat
                0, -- qtd_dev
                0, -- qtd_can
                reg_i.valor_base,
                reg_i.fil_origem,
                reg_i.doc_origem,
                reg_i.ser_origem,
                reg_i.seq_origem,
                reg_i.seq_movest,
                reg_i.vl_origem,
                reg_i.vl_base_ori,
                reg_iex.local_sai,
                reg_iex.fil_local,
                reg_i.uni_emb,
                reg_i.qtd_emb,
                reg_i.pc_com,
                reg_i.pc_cal,
                reg_i.observacao,
                reg_i.pro_venda,
                reg_i.cod_cfo,
                reg_i.comp,
                reg_i.larg,
                reg_i.prof,
                reg_i.cor,
                NULL,
                reg_i.seq_item_rom,
                NULL,
                NULL,
                NULL,
                NULL,
                reg_i.opos,
                REG_I.QTD_PC,
                reg_i.peso,
                reg_i.vl_desconto);

            v_vol  := v_vol + nvl(reg_iex.vol_qtd,
                                  0);
            v_peso := v_peso + nvl(reg_iex.vol_peso,
                                   0);
                                   
            IF v_espec IS NULL THEN
               v_espec := reg_iex.vol_especie;
            ELSE
               --|
               IF instr(v_espec,
                        reg_iex.vol_especie) = 0 THEN
                  v_espec := v_espec || '/' || reg_iex.vol_especie;
               END IF;
               --|
            END IF;
            --|
            IF nvl(reg_iex.dias,
                   0) > v_dias THEN
               v_dias := reg_iex.dias;
            END IF;
            --|
         END LOOP; --| for reg_iex in cr_iex

         --| Complementa pedido
         --complemento_exp(reg_ped.empresa, reg_ped.fil_pedido,v_num_pedido);
         comp_nota.cod_transp   := reg_exp.cod_transp;
         comp_nota.motorista    := reg_exp.motorista;
         comp_nota.cpf_mot      := reg_exp.cpf_mot;
         comp_nota.placa_veic   := reg_exp.placa_veic;
         comp_nota.placa_uf     := reg_exp.placa_uf;
         comp_nota.tp_frete     := reg_exp.tp_frete;
         comp_nota.vl_frete     := reg_exp.vl_frete;
         comp_nota.vl_seguro    := reg_exp.vl_seguro;
         comp_nota.num_exped    := num;
         comp_nota.vol_qtd      := v_vol;
         comp_nota.vol_especie  := substr(v_espec,
                                          1,
                                          50);
         comp_nota.peso_bruto   := v_peso;
         comp_nota.peso_liquido := v_peso;

         IF v_dias <> 0 THEN
            g_dias_mais := v_dias;
         END IF;

         --| Cria a nota
         cria_nota(reg_ped.empresa,
                   reg_ped.fil_pedido,
                   v_num_pedido,
                   dta,
                   FALSE,
                   1);

      --| Verifica status do pedido
      END LOOP; --| for reg_ped in cr_ped

      UPDATE ft_exped
         SET status = 'F'
       WHERE CURRENT OF cr_exp;
      CLOSE cr_exp;

      g_dias_mais := 0;
      IF com THEN
         COMMIT;
      END IF;

   END;

   --------------------------------------------------------------------------------
   PROCEDURE fatura_lote(emp IN ft_pedidos.empresa%TYPE,
                         fil IN ft_pedidos.filial%TYPE,
                         num IN ft_pedidos.lote%TYPE,
                         dta IN DATE,
                         com IN BOOLEAN)
   /*
      || Fatura lote
      */
    IS

      CURSOR cr_ped IS
         SELECT *
           FROM ft_pedidos
          WHERE empresa = emp
            AND filial = fil
            AND lote = num
            AND status IN ('P', 'A');

   BEGIN

      g_dias_mais := 0;

      --| Prepara valores de transporte
      resultado.numero_inicial := NULL;
      resultado.numero_final   := NULL;
      resultado.titulo_inicial := NULL;
      resultado.titulo_final   := NULL;
      resultado.lote_cont      := NULL;
      resultado.erro_cont      := 0;
      resultado.livro          := FALSE;
      resultado.nr_cont        := 0;
      resultado.nr_livro       := 0;

      --| Para cada pedido do lote
      FOR reg_ped IN cr_ped LOOP

         --| Cria pedido temporario igual
         INSERT INTO t_pedidos
            SELECT *
              FROM ft_pedidos
             WHERE empresa = reg_ped.empresa
               AND filial = reg_ped.filial
               AND num_pedido = reg_ped.num_pedido;
         INSERT INTO t_itens_ped
            SELECT *
              FROM ft_itens_ped
             WHERE empresa = reg_ped.empresa
               AND filial = reg_ped.filial
               AND num_pedido = reg_ped.num_pedido;

         --| Complementa pedido
         complemento_exp(reg_ped.empresa,
                         reg_ped.filial,
                         reg_ped.num_pedido);

         --| Cria a nota
         cria_nota(reg_ped.empresa,
                   reg_ped.filial,
                   reg_ped.num_pedido,
                   dta,
                   FALSE,
                   2);

      END LOOP; --| for reg_ped in cr_ped

      g_dias_mais := 0;
      IF com THEN
         COMMIT;
      END IF;

   END;
   -------------------------------------------------------------------------------
   FUNCTION valor_ipi(emp fs_itens_livro.empresa%TYPE,
                      fil fs_itens_livro.filial%TYPE,
                      tip fs_itens_livro.tip_livro%TYPE,
                      num fs_itens_livro.num_docto%TYPE,
                      ser fs_itens_livro.ser_docto%TYPE,
                      tpd fs_itens_livro.tip_docto%TYPE,
                      fir fs_itens_livro.firma%TYPE,
                      nat fs_itens_livro.nat_oper%TYPE,
                      ali fs_itens_livro.aliquota%TYPE,
                      imp fs_itens_livro.tip_imposto%TYPE) RETURN NUMBER IS
      --/ retorna o valor do ipi por natureza e aliquota
      CURSOR cr_cfo_item IS
         SELECT SUM(nvl(vl_ipi,
                        0)),
                SUM(nvl(vl_dipi,
                        0))
           FROM ce_itens_nf
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = num
            AND sr_nota = ser
            AND cod_fornec = fir
            AND cod_cfo LIKE nat || '%'
            AND ((imp = 'ICMS' AND aliq_icms = ali) OR
                (imp = 'IPI' AND aliq_ipi = ali));

      CURSOR cr_cfo_nota IS
         SELECT SUM(nvl(vl_ipi,
                        0)),
                SUM(nvl(vl_dipi,
                        0))
           FROM ce_itens_nf i,
                ce_notas    n
          WHERE i.empresa = n.empresa
            AND i.filial = n.filial
            AND i.num_nota = n.num_nota
            AND i.sr_nota = n.sr_nota
            AND i.cod_fornec = n.cod_fornec
            AND ((imp = 'ICMS' AND aliq_icms = ali) OR
                (imp = 'IPI' AND aliq_ipi = ali))
            AND n.empresa = emp
            AND n.filial = fil
            AND n.num_nota = num
            AND n.sr_nota = ser
            AND n.cod_fornec = fir
            AND n.cod_cfo LIKE nat || '%';

      CURSOR cr_sem_cfo IS
         SELECT SUM(nvl(vl_ipi,
                        0)),
                SUM(nvl(vl_dipi,
                        0))
           FROM ce_itens_nf
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = num
            AND sr_nota = ser
            AND cod_fornec = fir
            AND ((imp = 'ICMS' AND aliq_icms = ali) OR
                (imp = 'IPI' AND aliq_ipi = ali));

      CURSOR cr_ft IS
         SELECT SUM(nvl(vl_ipi,
                        0))
           FROM ft_itens_nf
          WHERE empresa = emp
            AND filial = fil
            AND num_nota = num
            AND sr_nota = ser
            AND cod_cfo LIKE nat || '%'
            AND ((imp = 'ICMS' AND aliq_icms = ali) OR
                (imp = 'IPI' AND aliq_ipi = ali));
      v_dipi NUMBER := 0;
      v_ret  NUMBER;
   BEGIN
      IF tip = 'E' THEN
         OPEN cr_cfo_item;
         FETCH cr_cfo_item
            INTO v_ret, v_dipi;
         IF cr_cfo_item%NOTFOUND THEN
            OPEN cr_ft;
            FETCH cr_ft
               INTO v_ret;
            CLOSE cr_ft;
         END IF;
         CLOSE cr_cfo_item;
         v_ret := nvl(v_ret,
                      0) + nvl(v_dipi,
                               0);
         IF v_ret = 0 THEN
            OPEN cr_cfo_nota;
            FETCH cr_cfo_nota
               INTO v_ret, v_dipi;
            CLOSE cr_cfo_nota;
            v_ret := nvl(v_ret,
                         0) + nvl(v_dipi,
                                  0);
         END IF;
         IF v_ret = 0 THEN
            OPEN cr_sem_cfo;
            FETCH cr_sem_cfo
               INTO v_ret, v_dipi;
            CLOSE cr_sem_cfo;
            v_ret := nvl(v_ret,
                         0) + nvl(v_dipi,
                                  0);
         END IF;

         --RAISE_APPLICATION_ERROR(-20201,v_dipi||'-'||EMP||'-'||FIL||'-'||NUM||'-'||SER||'-'||FIR||'-'||NAT||'-'||IMP);
      ELSE
         OPEN cr_ft;
         FETCH cr_ft
            INTO v_ret;
         CLOSE cr_ft;
      END IF;

      RETURN nvl(v_ret,
                 0);
   END;
   --------------------------------------------------------------------------------
   PROCEDURE emb_etiq(p_item ft_roman_etiq.seq_rom%TYPE,
                      p_seq  ft_roman_etiq.item_rom_seq%TYPE)
   /*
      || Gera tabela temporaria para ETIQUETA
      */
    IS

      CURSOR cr1 IS
         SELECT a.item_rom seq_rom,
                a.item_rom_seq,
                a.desenho,
                a.reduzido,
                a.qtdpc,
                a.quantidade qtd,
                a.ordem
           FROM ft_roman_etiq a
          WHERE empresa = 1
            AND filial = 1
            AND (p_seq IS NULL OR a.item_rom = p_item)
            AND (p_item IS NULL OR a.item_rom_seq = p_seq)
          ORDER BY 1,
                   2;

      v_descricao pp_desenho.descricao%TYPE;
      v_cont      NUMBER;
      v_nivel     NUMBER;
      v_aux       NUMBER(10,
                         3);
      v_peso      NUMBER;

   BEGIN

      --| Limpar Tabelas
      DELETE tft_etiqueta;

      --| Para todos os itens do desenho Chamado
      v_nivel := 0;

      FOR reg IN cr1 LOOP

         v_cont := 1;

         WHILE v_cont <= reg.qtdpc LOOP
            v_cont := v_cont + 1;
            -- Item da Lista
            INSERT INTO tft_etiqueta
               (seq_rom,
                item_rom_seq,
                desenho,
                ordem,
                reduzido,
                qtd,
                qtdpc)
            VALUES
               (reg.seq_rom,
                reg.item_rom_seq,
                reg.desenho,
                reg.ordem,
                reg.reduzido,
                reg.qtd,
                reg.qtdpc);

         END LOOP;
      END LOOP;

   END;
   ----------------------------------------------------------------------
END ft_nf;
/
