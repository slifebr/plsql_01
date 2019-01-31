create or replace package lib_util is

   --||
   --|| LIB_UTIL.PKS : Rotinas utilitarias
   --||

   function extenso(v_num in varchar2) return varchar2;
   pragma restrict_references(extenso,
                              wnds,
                              wnps);
   --------------------------------------------------------------------------------
   function extenso(v_num in varchar2
                   ,b_mda in char) return varchar2;
   pragma restrict_references(extenso,
                              wnds,
                              wnps);

   --------------------------------------------------------------------------------
   function strzero(p_num in number
                   ,p_zer in number) return varchar2;
   pragma restrict_references(strzero,
                              wnds,
                              wnps);
   --------------------------------------------------------------------------------
   function is_numeric(v_num in varchar2) return varchar2;
   pragma restrict_references(is_numeric,
                              wnds,
                              wnps);

   function is_minuscula(v_num in varchar2) return varchar2;
   pragma restrict_references(is_minuscula,
                              wnds,
                              wnps);

   function is_maiuscula(v_num in varchar2) return varchar2;
   pragma restrict_references(is_maiuscula,
                              wnds,
                              wnps);

   --------------------------------------------------------------------------------
   function is_date(p_dt in varchar2) return varchar2;
   pragma restrict_references(is_date,
                              wnds,
                              wnps);
   --------------------------------------------------------------------------------
   function nome_constraint(errmsg varchar2) return varchar2;
   pragma restrict_references(nome_constraint,
                              wnds,
                              wnps);
   --------------------------------------------------------------------------------
   function traduz_msg(texto varchar2
                      ,num   number) return varchar2;
   pragma restrict_references(traduz_msg,
                              wnds,
                              wnps);
   --------------------------------------------------------------------------------
   procedure registro(osu out varchar2
                     ,trm out varchar2
                     ,mdl out varchar2);
   --------------------------------------------------------------------------------
   procedure registro(osu out varchar2
                     ,trm out varchar2
                     ,mdl out varchar2
                     ,tim out date);
   --------------------------------------------------------------------------------
   procedure grava;
   --------------------------------------------------------------------------------
   function nome_base(v_nome in varchar2) return varchar2;
   pragma restrict_references(nome_base,
                              wnds,
                              wnps);
   --------------------------------------------------------------------------------
   function nome_base_com_extensao(v_nome in varchar2) return varchar2;
   pragma restrict_references(nome_base_com_extensao,
                              wnds,
                              wnps);   
   --------------------------------------------------------------------------------

   procedure send_mail(nome_orig in varchar2
                      ,endr_orig in varchar2
                      ,nome_dest in varchar2
                      ,endr_dest in varchar2
                      ,assunto   in varchar2
                      ,mensagem  in varchar2);
   --------------------------------------------------------------------------------

   procedure send_smtp(nome_orig in varchar2
                      ,endr_orig in varchar2
                      ,nome_dest in varchar2
                      ,endr_dest in varchar2
                      ,assunto   in varchar2
                      ,mensagem  in varchar2);

   procedure send_mail1(nome_orig in varchar2
                       ,endr_orig in varchar2
                       ,nome_dest in varchar2
                       ,endr_dest in varchar2
                       ,assunto   in varchar2
                       ,mensagem  in varchar2);

   procedure send_mail_auth(nome_orig in varchar2
                           ,endr_orig in varchar2
                           ,nome_dest in varchar2
                           ,endr_dest in varchar2
                           ,assunto   in varchar2
                           ,mensagem  in varchar2);

   procedure send_att(endr_orig  in varchar2
                     ,endr_dest  in varchar2
                     ,assunto    in varchar2
                     ,mensagem   in varchar2
                     ,diretorio  in varchar2 := null
                     ,arquivo    in varchar2 := null
                     ,endr_copia in varchar2 := null);
   --------------------------------------------------------------------------------

   procedure send_anexo(nome_orig in varchar2
                       ,endr_orig in varchar2
                       ,nome_dest in varchar2
                       ,endr_dest in varchar2
                       ,assunto   in varchar2
                       ,mensagem  in varchar2
                       ,filename1 varchar2 default null
                       ,max_size  number default 9999999999);

   --------------------------------------------------------------------------------
   function data_util(v_data in date) return date;
   --------------------------------------------------------------------------------
   function carac_especial(v_caracter in varchar2) return varchar2;
   pragma restrict_references(carac_especial,
                              wnds,
                              wnps);
   --------------------------------------------------------------------------------
   function mascara(val  in varchar2
                   ,masc in varchar2) return varchar2;
   pragma restrict_references(mascara,
                              wnds,
                              wnps);

   --------------------------------------------------------------------------------
   function ofuscar(val in varchar2) return varchar2;
   pragma restrict_references(ofuscar,
                              wnds,
                              wnps);
   --------------------------------------------------------------------------------
   function desofuscar(val in varchar2) return varchar2;
   pragma restrict_references(desofuscar,
                              wnds,
                              wnps);

   --------------------------------------------------------------------------------
   function encriptar(val in varchar2) return varchar2;
   pragma restrict_references(encriptar,
                              wnds,
                              wnps);
   function tira_caracter(pstring in varchar2) return varchar2;
   pragma restrict_references(tira_caracter,
                              wnds,
                              wnps);
   ---------------------------------------------------------------------------------
   function formata_string(p_str varchar2) return varchar2;
   pragma restrict_references(formata_string,
                              wnds,
                              wnps);

   ---------------------------------------------------------------------------------
   function formata_string(p_str   varchar2
                          ,p_caixa char) return varchar2;
   pragma restrict_references(formata_string,
                              wnds,
                              wnps);

   -----------------------------------------------------------------------------------
   function somente_numero(p_str varchar2) return varchar2;
   pragma restrict_references(somente_numero,
                              wnds,
                              wnps);
   --|---------------------------------------------------------------------------
   function dominio(p_cd sgn_dominio.codigo%type) return sgn_dominio.valor%type;

   --|---------------------------------------------------------------------------
   function trata_linha_folha(p_linha in varchar2
                             ,p_valor in varchar2) return varchar2;
   pragma restrict_references(trata_linha_folha,
                              wnds,
                              wnps);
   -----------------------------------------------------------------------
   function fnc_trata_string(string in varchar2) return varchar2;
   pragma restrict_references(fnc_trata_string,
                              wnds,
                              wnps);
   ----------------------------------------------------------------------
   function fnc_nome_arquivo(p_texto varchar2) return varchar2;
   pragma restrict_references(fnc_nome_arquivo,
                              wnds,
                              wnps);

   ----------------------------------------------------------------------
   function fnc_retira_extensao_arquivo(p_texto varchar2) return varchar2;
   pragma restrict_references(fnc_retira_extensao_arquivo,
                              wnds,
                              wnps);

   ----------------------------------------------------------------------
   function fnc_extensao_arquivo(p_texto varchar2) return varchar2;
   pragma restrict_references(fnc_extensao_arquivo,
                              wnds,
                              wnps);
   ----------------------------------------------------------------------
   function fnc_path_arquivo(p_texto varchar2) return varchar2;   
   pragma restrict_references(fnc_path_arquivo,
                              wnds,
                              wnps);                              
   -------------------------------------------------------------

   function fnc_maquina_usu return varchar2;

   ----------------------------------------------------------------------
   function split_texto(p_texto varchar2
                       ,p_tam   number) return varchar2;
   pragma restrict_references(split_texto,
                              wnds,
                              wnps);
   --| splite retornando um ref cursor 
   function split_texto(p_texto       varchar2
                       ,p_delimitador varchar2) return dbms_sql.varchar2_table; --sys_refcursor;
   pragma restrict_references(split_texto,
                              wnds,
                              wnps);
end lib_util;
/
create or replace package body lib_util is

   --||
   --|| LIB_UTIL.PKB : Rotinas utilitarias
   --||

   --------------------------------------------------------------------------------
   /*
   || Funcoes internas
   */
   --------------------------------------------------------------------------------
   function iifv(b  in boolean
                ,e1 in varchar2
                ,e2 in varchar2) return varchar2
   /*
      || If imediato para varchar2
      */
    is
   
   begin
   
      if b then
         return e1;
      else
         return e2;
      end if;
   
   end;

   --------------------------------------------------------------------------------
   function iifn(b  in boolean
                ,e1 in number
                ,e2 in number) return number
   /*
      || If imediato para numeros
      */
    is
   
   begin
   
      if b then
         return e1;
      else
         return e2;
      end if;
   
   end;

   --------------------------------------------------------------------------------
   function ex1(n in number) return varchar2
   /*
      || Retorna unidade
      */
    is
   
   begin
   
      if n = 1 then
         return ' UM';
      elsif n = 2 then
         return ' DOIS';
      elsif n = 3 then
         return ' TRES';
      elsif n = 4 then
         return ' QUATRO';
      elsif n = 5 then
         return ' CINCO';
      elsif n = 6 then
         return ' SEIS';
      elsif n = 7 then
         return ' SETE';
      elsif n = 8 then
         return ' OITO';
      elsif n = 9 then
         return ' NOVE';
      elsif n = 11 then
         return ' ONZE';
      elsif n = 12 then
         return ' DOZE';
      elsif n = 13 then
         return ' TREZE';
      elsif n = 14 then
         return ' QUATORZE';
      elsif n = 15 then
         return ' QUINZE';
      elsif n = 16 then
         return ' DEZESSEIS';
      elsif n = 17 then
         return ' DEZESSETE';
      elsif n = 18 then
         return ' DEZOITO';
      elsif n = 19 then
         return ' DEZENOVE';
      end if;
   
   end;

   --------------------------------------------------------------------------------
   function ex2(n in number) return varchar2
   /*
      || Retorna dezena
      */
    is
   
   begin
   
      if n = 1 then
         return ' DEZ';
      elsif n = 2 then
         return ' VINTE';
      elsif n = 3 then
         return ' TRINTA';
      elsif n = 4 then
         return ' QUARENTA';
      elsif n = 5 then
         return ' CINQUENTA';
      elsif n = 6 then
         return ' SESSENTA';
      elsif n = 7 then
         return ' SETENTA';
      elsif n = 8 then
         return ' OITENTA';
      elsif n = 9 then
         return ' NOVENTA';
      end if;
   
   end;

   --------------------------------------------------------------------------------
   function ex3(n in number) return varchar2
   /*
      || Retorna centena
      */
    is
   
   begin
   
      if n = 1 then
         return ' CENTO';
      elsif n = 2 then
         return ' DUZENTOS';
      elsif n = 3 then
         return ' TREZENTOS';
      elsif n = 4 then
         return ' QUATROCENTOS';
      elsif n = 5 then
         return ' QUINHENTOS';
      elsif n = 6 then
         return ' SEISCENTOS';
      elsif n = 7 then
         return ' SETECENTOS';
      elsif n = 8 then
         return ' OITOCENTOS';
      elsif n = 9 then
         return ' NOVECENTOS';
      end if;
   
   end;

   --------------------------------------------------------------------------------
   function grx(n in number) return varchar2
   /*
      || Retorna extenso de grupo de 3 algarismos
      */
    is
   
      x1  number;
      x2  number;
      x3  number;
      exx varchar2(100);
   
   begin
   
      x1 := substr(to_char(n,
                           '000'),
                   2,
                   1);
      x2 := substr(to_char(n,
                           '000'),
                   3,
                   1);
      x3 := substr(to_char(n,
                           '000'),
                   4,
                   1);
   
      if x1 = 0 and
         x2 = 0 and
         x3 = 0 then
         exx := ' ZERO';
      elsif x1 = 0 and
            x2 = 0 and
            x3 <> 0 then
         exx := ex1(x3);
      elsif x1 = 0 and
            x2 <> 0 and
            x3 = 0 then
         exx := ex2(x2);
      elsif x1 = 0 and
            x2 <> 0 and
            x3 <> 0 then
         if x2 = 1 then
            exx := ex1(10 + x3);
         else
            exx := ex2(x2) || ' E' || ex1(x3);
         end if;
      elsif x1 <> 0 and
            x2 = 0 and
            x3 = 0 then
         if x1 = 1 then
            exx := ' CEM';
         else
            exx := ex3(x1);
         end if;
      elsif x1 <> 0 and
            x2 = 0 and
            x3 <> 0 then
         exx := ex3(x1) || ' E' || ex1(x3);
      elsif x1 <> 0 and
            x2 <> 0 and
            x3 = 0 then
         exx := ex3(x1) || ' E' || ex2(x2);
      elsif x1 <> 0 and
            x2 <> 0 and
            x3 <> 0 then
         if x2 = 1 then
            exx := ex3(x1) || ' E' || ex1(10 + x3);
         else
            exx := ex3(x1) || ' E' || ex2(x2) || ' E' || ex1(x3);
         end if;
      end if;
   
      return exx;
   
   end;

   --------------------------------------------------------------------------------
   function ext(n  in number
               ,bm in boolean) return varchar2
   /*
      || Retorna extenso
      */
    is
   
      g1  number;
      g2  number;
      g3  number;
      g4  number;
      gc  number;
      bs  varchar2(20) := ' BILHOES';
      b   varchar2(20) := ' BILHAO';
      ms  varchar2(20) := ' MILHOES';
      m   varchar2(20) := ' MILHAO';
      l   varchar2(20) := ' MIL';
      zs  varchar2(20);
      z   varchar2(20);
      cs  varchar2(20);
      c   varchar2(20);
      fl2 number;
      fl3 number;
      fl4 number;
      flc number;
      bi  varchar2(100);
      exx varchar2(200);
   
   begin
   
      g1  := substr(to_char(n,
                            '000000000000D00'),
                    2,
                    3);
      g2  := substr(to_char(n,
                            '000000000000D00'),
                    5,
                    3);
      g3  := substr(to_char(n,
                            '000000000000D00'),
                    8,
                    3);
      g4  := substr(to_char(n,
                            '000000000000D00'),
                    11,
                    3);
      gc  := substr(to_char(n,
                            '000000000000D00'),
                    15,
                    2);
      zs  := iifv(bm,
                  ' REAIS',
                  '');
      z   := iifv(bm,
                  ' REAL',
                  '');
      cs  := iifv(bm,
                  ' CENTAVOS',
                  '');
      c   := iifv(bm,
                  ' CENTAVO',
                  '');
      fl2 := iifn(g2 = 0,
                  0,
                  1);
      fl3 := iifn(g3 = 0,
                  0,
                  1);
      fl4 := iifn(g4 = 0,
                  0,
                  1);
      flc := iifn(gc = 0,
                  0,
                  1);
   
      if g1 = 0 then
         bi := '';
      else
         if g2 + g3 + g4 = 0 then
            if gc <> 0 then
               return iifv(g1 = 1,
                           'UM' || b || ' DE' || zs,
                           grx(g1) || bs || ' DE' || zs) || iifv(gc = 1,
                                                                 ' E UM' || c,
                                                                 ' E' ||
                                                                 grx(gc) || cs);
            else
               return iifv(g1 = 1,
                           'UM' || b || ' DE' || zs,
                           grx(g1) || bs || ' DE' || zs);
            end if;
         else
            if fl2 + fl3 + fl4 + flc = 1 then
               bi := iifv(g1 = 1,
                          'UM' || b,
                          grx(g1) || bs) || ' E';
            else
               bi := iifv(g1 = 1,
                          'UM' || b,
                          grx(g1) || bs) || ',';
            end if;
         end if;
      end if;
   
      if g2 = 0 and
         g3 = 0 and
         g4 = 0 then
         return bi || iifv(gc = 0,
                           'ZERO' || zs,
                           iifv(gc = 1,
                                ' UM' || c,
                                grx(gc) || cs));
      elsif g2 = 0 and
            g3 = 0 and
            g4 <> 0 then
         return bi || iifv(g4 = 1 and g1 = 0,
                           ' UM' || z,
                           grx(g4) || zs) || iifv(gc = 0,
                                                  '',
                                                  iifv(gc = 1,
                                                       ' E UM' || c,
                                                       ' E' || grx(gc) || cs));
      elsif g2 = 0 and
            g3 <> 0 and
            g4 = 0 then
         return bi || grx(g3) || l || zs || iifv(gc = 0,
                                                 '',
                                                 iifv(gc = 1,
                                                      ' E UM' || c,
                                                      ' E' || grx(gc) || cs));
      elsif g2 = 0 and
            g3 <> 0 and
            g4 <> 0 then
         if gc <> 0 then
            return bi || grx(g3) || l || ',' || grx(g4) || zs || iifv(gc = 0,
                                                                      '',
                                                                      iifv(gc = 1,
                                                                           ' E UM' || c,
                                                                           ' E' ||
                                                                           grx(gc) || cs));
         else
            return bi || grx(g3) || ' MIL E' || grx(g4) || zs;
         end if;
      elsif g2 <> 0 and
            g3 = 0 and
            g4 = 0 then
         if gc <> 0 then
            return bi || iifv(g2 = 1,
                              ' UM' || m || ' DE' || zs,
                              grx(g2) || ms || ' DE' || zs) || iifv(gc = 1,
                                                                    ' E UM' || c,
                                                                    ' E' ||
                                                                    grx(gc) || cs);
         else
            return bi || iifv(g2 = 1,
                              ' UM' || m || ' DE' || zs,
                              grx(g2) || ms || ' DE' || zs);
         end if;
      elsif g2 <> 0 and
            g3 = 0 and
            g4 <> 0 then
         if gc <> 0 then
            return bi || iifv(g2 = 1,
                              ' UM' || m,
                              grx(g2) || ms) || ',' || grx(g4) || zs || ' E' || iifv(gc = 1,
                                                                                     ' UM' || c,
                                                                                     grx(gc) || cs);
         else
            return bi || iifv(g2 = 1,
                              ' UM' || m,
                              grx(g2) || ms) || ' E' || grx(g4) || zs;
         end if;
      elsif g2 <> 0 and
            g3 <> 0 and
            g4 = 0 then
         if gc <> 0 then
            return bi || iifv(g2 = 1,
                              ' UM' || m,
                              grx(g2) || ms) || ',' || grx(g3) || l || zs || ' E' || iifv(gc = 1,
                                                                                          ' UM' || c,
                                                                                          grx(gc) || cs);
         else
            return bi || iifv(g2 = 1,
                              ' UM' || m,
                              grx(g2) || ms) || ' E' || grx(g3) || l || zs;
         end if;
      elsif g2 <> 0 and
            g3 <> 0 and
            g4 <> 0 then
         if gc <> 0 then
            return bi || iifv(g2 = 1,
                              ' UM' || m,
                              grx(g2) || ms) || ',' || grx(g3) || l || ',' || iifv(g4 = 1,
                                                                                   ' UM' || z,
                                                                                   grx(g4) || zs) || ' E' || iifv(gc = 1,
                                                                                                                  ' UM' || c,
                                                                                                                  grx(gc) || cs);
         else
            return bi || iifv(g2 = 1,
                              ' UM' || m,
                              grx(g2) || ms) || ',' || grx(g3) || l || ' E' || iifv(g4 = 1,
                                                                                    ' UM' || z,
                                                                                    grx(g4) || zs);
         end if;
      
      end if;
   
   end;

   --------------------------------------------------------------------------------
   /*
   || Funcoes exportadas
   */
   --------------------------------------------------------------------------------
   function extenso(v_num in varchar2) return varchar2
   /*
      || Retorna o extenso
      */
    is
   
   begin
   
      return ext(v_num,
                 true);
   
   end;

   --------------------------------------------------------------------------------
   function extenso(v_num in varchar2
                   ,b_mda in char) return varchar2
   /*
      || Retorna o extenso
      */
    is
   
   begin
   
      return ext(v_num,
                 b_mda = 'S');
   
   end;
   --------------------------------------------------------------------------------
   function is_maiuscula(v_num in varchar2) return varchar2
   /*
      || Verifica se string È maiuscula
      */
    is
   
      v_aux number;
   
   begin
   
      v_aux := instr('ZXCVBNMASDFGHJKLQWERTYUIOP',
                     v_num);
   
      if nvl(v_aux,
             0) > 0 then
         return 'S';
      else
         return 'N';
      end if;
   
   exception
   
      when others then
         return 'N';
      
   end;
   --------------------------------------------------------------------------------
   function is_minuscula(v_num in varchar2) return varchar2
   /*
      || Verifica se string È MINUSCULA
      */
    is
   
      v_aux number;
   
   begin
   
      v_aux := instr('zxcvbnmasdfghjklqwertyuiop',
                     v_num);
   
      if nvl(v_aux,
             0) > 0 then
         return 'S';
      else
         return 'N';
      end if;
   
   exception
   
      when others then
         return 'N';
      
   end;

   --------------------------------------------------------------------------------
   function is_numeric(v_num in varchar2) return varchar2
   /*
      || Verifica se string e um numero
      */
    is
   
      v_aux number;
   
   begin
   
      v_aux := to_number(v_num);
   
      return 'S';
   
   exception
   
      when others then
         return 'N';
      
   end;

   --------------------------------------------------------------------------------
   function is_date(p_dt in varchar2) return varchar2
   /*
      || Verifica se È uma data
      */
    is
   
      v_aux date;
   
   begin
   
      v_aux := to_date(p_dt,
                       'DD/MM/RRRR');
      return 'S';
   
   exception
   
      when others then
         return 'N';
      
   end;
   --------------------------------------------------------------------------------
   function nome_constraint(errmsg varchar2) return varchar2
   /*
      || Extrai o nome da constraint na mensagem de erro do oracle
      || aparece entre parenteses nos erros 02290-02292 e 02296-02299.
      */
    is
   
      lv_pos1 number;
      lv_pos2 number;
   
   begin
      lv_pos1 := instr(errmsg,
                       '(');
      lv_pos2 := instr(errmsg,
                       ')');
      if (lv_pos1 = 0 or lv_pos2 = 0) then
         return(null);
      else
         return(upper(substr(errmsg,
                             lv_pos1 + 1,
                             lv_pos2 - lv_pos1 - 1)));
      end if;
   
   end;

   --------------------------------------------------------------------------------
   function traduz_msg(texto varchar2
                      ,num   number) return varchar2
   /*
      || Extrai o nome da constraint na mensagem de erro do oracle
      || aparece entre parenteses nos erros 02290-02292 e 02296-02299.
      */
    is
   
      cursor cr_pk(dn varchar2
                  ,ct varchar2) is
         select 1
           from all_constraints
          where owner = dn
            and constraint_name = ct
            and constraint_type = 'P';
   
      cursor cr_pkcol(dn varchar2
                     ,ct varchar2) is
         select column_name
           from all_cons_columns
          where owner = dn
            and constraint_name = ct
          order by position;
   
      cursor cr_ukcol(dn varchar2
                     ,ct varchar2) is
         select column_name
           from all_ind_columns
          where table_owner = dn
            and index_name = ct
          order by column_position;
   
      cursor cr_fk(dn varchar2
                  ,ct varchar2) is
         select 1
           from all_constraints
          where owner = dn
            and constraint_name = ct
            and constraint_type = 'R';
   
      cursor cr_fkr(dn varchar2
                   ,ct varchar2) is
         select r_owner
               ,r_constraint_name
           from all_constraints
          where owner = dn
            and constraint_name = ct;
   
      cursor cr_fktab(dn varchar2
                     ,ct varchar2) is
         select table_name
           from all_constraints
          where owner = dn
            and constraint_name = ct;
   
      cursor cr_ck(dn varchar2
                  ,ct varchar2) is
         select search_condition
           from all_constraints
          where owner = dn
            and constraint_name = ct;
   
      cursor cr_com(dn varchar2
                   ,ct varchar2) is
         select comments
           from all_tab_comments
          where owner = dn
            and table_name = ct
            and table_type = 'TABLE';
   
      dono      varchar2(100);
      tabela    varchar2(100);
      ctn       varchar2(100);
      dono_r    varchar2(100);
      tabela_r  varchar2(100);
      tabela_fk varchar2(100);
      v_ck      varchar2(100);
      n         number;
      colunas   varchar2(100);
      sep       char(1);
      v_desc    varchar2(1000);
   
   begin
   
      ctn := nome_constraint(texto);
      if ctn is null then
         return texto;
      end if;
      n := instr(ctn,
                 '.',
                 1);
      if n = 0 then
         return texto;
      end if;
      dono   := substr(ctn,
                       1,
                       n - 1);
      tabela := substr(ctn,
                       n + 1);
   
      --| Chave unica ou primaria
      if num = -1 then
      
         open cr_pk(dono,
                    tabela);
         fetch cr_pk
            into n;
         if cr_pk%found then
            close cr_pk;
            colunas := '';
            sep     := '';
            for reg in cr_pkcol(dono,
                                tabela) loop
               colunas := colunas || sep || upper(rtrim(reg.column_name));
               sep     := ',';
            end loop;
            return 'Chave primaria duplicada : ' || chr(10) || 'Ja existe registro com o mesmo valor em ' || colunas || '.';
         else
            close cr_pk;
            colunas := '';
            sep     := '';
            for reg in cr_ukcol(dono,
                                tabela) loop
               colunas := colunas || sep || upper(rtrim(reg.column_name));
               sep     := ',';
            end loop;
            return 'Chave unica ' || ctn || ': ' || chr(10) || 'Ja existe registro com o mesmo valor em ' || colunas || '.';
         end if;
      
         --| Foreign key : Child not found
      elsif num = -2292 then
      
         open cr_fktab(dono,
                       tabela);
         fetch cr_fktab
            into tabela_fk;
         if cr_fktab%notfound then
            close cr_fktab;
            return texto;
         end if;
         close cr_fktab;
         open cr_com(dono,
                     tabela_fk);
         fetch cr_com
            into v_desc;
         if cr_com%found and
            v_desc is not null then
            tabela_fk := tabela_fk || ' (' || rtrim(v_desc) || ')';
         end if;
         close cr_com;
         return 'Chave estrangeira ' || ctn || ': ' || chr(10) || 'Tabela ' || tabela_fk || ' possui registros apontando para este.';
      
         --| Foreign key : Parent not found
      elsif num = -2291 then
      
         open cr_fkr(dono,
                     tabela);
         fetch cr_fkr
            into dono_r
                ,tabela_r;
         if cr_fkr%notfound then
            close cr_fkr;
            return texto;
         end if;
         close cr_fkr;
         open cr_fktab(dono_r,
                       tabela_r);
         fetch cr_fktab
            into tabela_fk;
         if cr_fktab%notfound then
            close cr_fktab;
            return texto;
         end if;
         close cr_fktab;
         open cr_com(dono,
                     tabela_fk);
         fetch cr_com
            into v_desc;
         if cr_com%found and
            v_desc is not null then
            tabela_fk := tabela_fk || ' (' || rtrim(v_desc) || ')';
         end if;
         close cr_com;
         return 'Chave estrangeira ' || ctn || ': ' || chr(10) || 'Tabela ' || tabela_fk || ' n„o possui o registro apontado.';
      
         --| Check constraint
      elsif num = -2290 then
      
         open cr_ck(dono,
                    tabela);
         fetch cr_ck
            into v_ck;
         if cr_ck%notfound then
            close cr_ck;
            return texto;
         end if;
         close cr_ck;
         return 'CondiÁ„o ' || ctn || ' violada: ' || chr(10) || v_ck || '.';
      
      end if;
   
      return texto;
   
   end;

   --------------------------------------------------------------------------------
   procedure registro(osu out varchar2
                     ,trm out varchar2
                     ,mdl out varchar2)
   /*
      || Retorna variaveis da sessao
      */
    is
   
      cursor cr is
         select unique sid from v$mystat;
      v_sid number;
   
   begin
   
      open cr;
      fetch cr
         into v_sid;
      close cr;
      select osuser
            ,terminal
            ,module
        into osu
            ,trm
            ,mdl
        from v$session
       where sid = v_sid;
      return;
   
   exception
   
      when others then
         null;
      
   end;

   --------------------------------------------------------------------------------
   procedure registro(osu out varchar2
                     ,trm out varchar2
                     ,mdl out varchar2
                     ,tim out date)
   /*
      || Retorna variaveis da sessao
      */
    is
   
      cursor cr is
         select unique sid from v$mystat;
      v_sid number;
   
   begin
   
      open cr;
      fetch cr
         into v_sid;
      close cr;
      select osuser
            ,terminal
            ,module
            ,logon_time
        into osu
            ,trm
            ,mdl
            ,tim
        from v$session
       where sid = v_sid;
      return;
   
   exception
   
      when others then
         null;
      
   end;

   --------------------------------------------------------------------------------
   procedure grava is
   
   begin
   
      commit;
   
   end;

   --------------------------------------------------------------------------------
   function nome_base(v_nome in varchar2) return varchar2
   /*
      || Retorna o nome base
      */
    is
   
      v_aux varchar2(1000);
      n     number;
   
   begin
   
      n := instr(v_nome,
                 '.',
                 -1);
      if n > 1 then
         v_aux := substr(v_nome,
                         1,
                         n - 1);
      elsif n = 1 then
         v_aux := substr(v_nome,
                         2);
      else
         v_aux := v_nome;
      end if;
      --| 2 PARTE: SEM EXTENSAO
      n := instr(v_aux,
                 '\',
                 -1);
      if n > 0 then
         v_aux := substr(v_aux,
                         n + 1);
      end if;
      n := instr(v_aux,
                 '/',
                 -1);
      if n > 0 then
         v_aux := substr(v_aux,
                         n + 1);
      end if;
      n := instr(v_aux,
                 ':',
                 -1);
      if n > 0 then
         v_aux := substr(v_aux,
                         n + 1);
      end if;
      return v_aux;
   
   end;
   --------------------------------------------------------------------------------
   function nome_base_com_extensao(v_nome in varchar2) return varchar2
   /*
      || Retorna o nome base com extensao do arquivo
      */
    is
   
      v_aux varchar2(1000);
      n     number;
   
   begin
     v_aux := v_nome;
      n := instr(v_aux,
                 '\',
                 -1);
                 
      if n > 0 then
         v_aux := substr(v_aux,
                         n + 1);
      end if;
      
      n := instr(v_aux,
                 '/',
                 -1);
      if n > 0 then
         v_aux := substr(v_aux,
                         n + 1);
      end if;
      n := instr(v_aux,
                 ':',
                 -1);
      if n > 0 then
         v_aux := substr(v_aux,
                         n + 1);
      end if;
      return v_aux;
   
   end;
   -----------------------------------------------------
   procedure send_mail(nome_orig in varchar2
                      ,endr_orig in varchar2
                      ,nome_dest in varchar2
                      ,endr_dest in varchar2
                      ,assunto   in varchar2
                      ,mensagem  in varchar2) is
      cursor cr is
         select * from cd_config;
   
      reg cd_config%rowtype;
   
      v_host varchar2(100);
      v_crlf char(2) := chr(13) || chr(10);
      v_msg  varchar2(4000);
   begin
      v_msg := 'Date: ' || to_char(sysdate,
                                   'dd Mon rr hh24:mi:ss') || v_crlf ||
               'From: ' || nome_orig || '<' || endr_orig || '>' || v_crlf ||
               'Subject: ' || assunto || v_crlf || 'To: ' || nome_dest || '<' ||
               endr_dest || '>' || v_crlf || v_crlf || mensagem;
   
      utl_mail.send(endr_orig,
                    endr_dest,
                    null,
                    null,
                    assunto,
                    v_msg,
                    'text/plain; charset=us-ascii',
                    null);
   end;
   --------------------------------------------------------------------------------

   procedure send_smtp(nome_orig in varchar2
                      ,endr_orig in varchar2
                      ,nome_dest in varchar2
                      ,endr_dest in varchar2
                      ,assunto   in varchar2
                      ,mensagem  in varchar2)
   
      --
      --|| Envia mail
      --
   
    is
   
      cursor cr is
         select * from cd_config;
   
      reg cd_config%rowtype;
   
      v_host   varchar2(100);
      v_crlf   char(2) := chr(13) || chr(10);
      v_msg    varchar2(4000);
      mail_con utl_smtp.connection;
   
   begin
   
      open cr;
      fetch cr
         into reg;
      if cr%notfound or
         reg.mail_host is null then
         close cr;
         return;
      end if;
      close cr;
   
      v_msg := 'Date: ' || to_char(sysdate,
                                   'dd Mon rr hh24:mi:ss') || v_crlf ||
               'From: ' || nome_orig || '<' || endr_orig || '>' || v_crlf ||
               'Subject: ' || assunto || v_crlf || 'To: ' || nome_dest || '<' ||
               endr_dest || '>' || v_crlf || v_crlf || mensagem;
   
      mail_con := utl_smtp.open_connection(reg.mail_host,
                                           25);
      utl_smtp.helo(mail_con,
                    reg.mail_host);
      utl_smtp.mail(mail_con,
                    endr_orig);
      utl_smtp.rcpt(mail_con,
                    endr_dest);
      utl_smtp.data(mail_con,
                    v_msg);
      utl_smtp.quit(mail_con);
   
      --   EXCEPTION
   
      --    WHEN OTHERS THEN
      --      NULL;
   
   end;

   --------------------------------------------------------------------------------

   procedure send_mail1(nome_orig in varchar2
                       ,endr_orig in varchar2
                       ,nome_dest in varchar2
                       ,endr_dest in varchar2
                       ,assunto   in varchar2
                       ,mensagem  in varchar2)
   
      --
      --|| Envia mail
      --
   
    is
   
      cursor cr is
         select * from cd_config;
   
      reg cd_config%rowtype;
   
      v_host   varchar2(100);
      v_crlf   char(2) := chr(13) || chr(10);
      v_msg    varchar2(4000);
      mail_con utl_smtp.connection;
   
   begin
   
      open cr;
      fetch cr
         into reg;
      if cr%notfound or
         reg.mail_host is null then
         close cr;
         return;
      end if;
      close cr;
   
      v_msg := 'Date: ' || to_char(sysdate,
                                   'dd Mon rr hh24:mi:ss') || v_crlf ||
               'From: ' || endr_orig || v_crlf || 'Subject: ' || assunto ||
               v_crlf || 'To: ' || endr_dest || v_crlf || v_crlf ||
              --'To: ' || nome_dest || '<' || endr_dest || '>' || v_crlf || v_crlf ||
               mensagem;
   
      mail_con := utl_smtp.open_connection(reg.mail_host,
                                           25);
      utl_smtp.helo(mail_con,
                    reg.mail_host);
      utl_smtp.mail(mail_con,
                    endr_orig);
      utl_smtp.rcpt(mail_con,
                    endr_dest);
      utl_smtp.data(mail_con,
                    v_msg);
      utl_smtp.quit(mail_con);
   
   exception
   
      when others then
         null;
      
   end;

   --------------------------------------------------------------------------------

   procedure send_mail_auth(nome_orig in varchar2
                           ,endr_orig in varchar2
                           ,nome_dest in varchar2
                           ,endr_dest in varchar2
                           ,assunto   in varchar2
                           ,mensagem  in varchar2)
   /*
      || Envia mail (usando utl_smtp)
      */
    is
   
      cursor cr is
         select * from cd_config;
   
      reg cd_config%rowtype;
   
      v_host   varchar2(100);
      v_crlf   char(2) := chr(13) || chr(10);
      v_msg    varchar2(4000);
      mail_con utl_smtp.connection;
   
   begin
   
      open cr;
      fetch cr
         into reg;
      if cr%notfound or
         reg.mail_host is null then
         close cr;
         return;
      end if;
      close cr;
   
      v_msg := 'Date: ' || to_char(sysdate,
                                   'dd Mon rr hh24:mi:ss') || v_crlf ||
               'From: ' || nome_orig || '<' || endr_orig || '>' || v_crlf ||
               'Subject: ' || assunto || v_crlf || 'To: ' || nome_dest || '<' ||
               endr_dest || '>' || v_crlf || v_crlf || mensagem;
   
      mail_con := utl_smtp.open_connection(reg.mail_host,
                                           25);
   
      utl_smtp.command(mail_con,
                       'AUTH LOGIN');
      utl_smtp.command(mail_con,
                       utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw('sage3@sermatec.com.br'))));
      utl_smtp.command(mail_con,
                       utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw('it5869'))));
   
      utl_smtp.helo(mail_con,
                    reg.mail_host);
      utl_smtp.mail(mail_con,
                    endr_orig);
      utl_smtp.rcpt(mail_con,
                    endr_dest);
      utl_smtp.data(mail_con,
                    v_msg);
      utl_smtp.quit(mail_con);
      /*
      exception
      
        when others then
          null;
      */
   end;

   --------------------------------------------------------------------------------
   procedure send_att(endr_orig  in varchar2
                     ,endr_dest  in varchar2
                     ,assunto    in varchar2
                     ,mensagem   in varchar2
                     ,diretorio  in varchar2 := null
                     ,arquivo    in varchar2 := null
                     ,endr_copia in varchar2 := null)
   /*
      || Envia mail (Usando mail_tools)
      */
    is
   
      cursor cr is
         select * from cd_config;
   
      reg cd_config%rowtype;
   
      t_blob blob;
   
   begin
   
      open cr;
      fetch cr
         into reg;
      if cr%notfound or
         reg.mail_host is null then
         close cr;
         return;
      end if;
      close cr;
   
      -- Se informou diretorio e arquivo, le seu conteudo como bloc para enviar como anexo
      if diretorio is not null and
         arquivo is not null then
         t_blob := mail_tools.get_local_binary_data(diretorio,
                                                    arquivo);
      else
         t_blob := empty_blob();
      end if;
   
      -- Chama a funcao de mail_tools
      mail_tools.sendmail(smtp_server => reg.mail_host,
                          from_name   => endr_orig,
                          to_name     => endr_dest,
                          cc_name     => endr_copia,
                          subject     => assunto,
                          message     => mensagem,
                          filename    => arquivo,
                          binaryfile  => t_blob);
   
   end;

   --------------------------------------------------------------------------------

   procedure send_anexo(nome_orig in varchar2
                       ,endr_orig in varchar2
                       ,nome_dest in varchar2
                       ,endr_dest in varchar2
                       ,assunto   in varchar2
                       ,mensagem  in varchar2
                       ,filename1 varchar2 default null
                       ,max_size  number default 9999999999)
   --
      --|| Envia mail
      --
    is
   
      cursor cr is
         select * from cd_config;
      --/
      reg cd_config%rowtype;
      --/
      v_host             varchar2(100);
      v_crlf             char(2) := chr(13) || chr(10);
      v_msg              varchar2(32767);
      mail_con           utl_smtp.connection;
      v_smtp_server_port number := 25;
      v_directory_name   varchar2(100);
      v_file_name        varchar2(100);
      v_line             varchar2(1000);
      v_slash_pos        number;
      v_file_handle      utl_file.file_type;
      invalid_path exception;
      msg_length_exceeded boolean := false;
   
   begin
   
      open cr;
      fetch cr
         into reg;
      if cr%notfound or
         reg.mail_host is null then
         close cr;
         return;
      end if;
      close cr;
   
      v_msg := 'Date: ' || to_char(sysdate,
                                   'dd Mon rr hh24:mi:ss') || v_crlf ||
               'From: ' || nome_orig || '<' || endr_orig || '>' || v_crlf ||
               'Subject: ' || assunto || v_crlf || 'To: ' || nome_dest || '<' ||
               endr_dest || '>' || v_crlf || v_crlf || mensagem;
      --'To: ' || nome_dest || '<' || endr_dest || '>' || v_crlf || v_crlf ||
   
      mail_con := utl_smtp.open_connection(reg.mail_host,
                                           25);
      utl_smtp.helo(mail_con,
                    reg.mail_host);
      utl_smtp.mail(mail_con,
                    endr_orig);
      utl_smtp.rcpt(mail_con,
                    endr_dest);
      utl_smtp.open_data(mail_con);
      --/
      utl_smtp.write_data(mail_con,
                          v_msg);
      /*
      --/
      if filename1 is not null then
        begin
          v_slash_pos := instr(filename1, '/', -1 );
          if v_slash_pos = 0 then
            v_slash_pos := instr(filename1, '\', -1 );
          end if;
          v_directory_name := substr(filename1, 1, v_slash_pos - 1 );
          v_file_name      := substr(filename1, v_slash_pos + 1 );
          v_file_handle    := utl_file.fopen(v_directory_name, v_file_name, 'r' );
          --v_file_handle    := utl_file.fopen('k:\anexo\', v_file_name, 'r' );
          -- generate the MIME boundary line ...
          v_msg := v_crlf || '--DMW.Boundary.605592468' || v_crlf
                        || 'Content-Type: application/octet-stream; name="' || v_file_name || '"' || v_crlf
                      || 'Content-Disposition: attachment; filename="' || v_file_name || '"' || v_crlf
                      || 'Content-Transfer-Encoding: 7bit' || v_crlf || v_crlf ;
          utl_smtp.write_data ( mail_con, v_msg );
          loop
            utl_file.get_line(v_file_handle, v_line);
            v_msg := v_line || v_crlf;
            utl_smtp.write_data ( mail_con, v_msg );
          end loop;
      
        exception
            when others then
              null;
          when utl_file.invalid_path then
            raise_application_error(-20100,'Erro na abertura do arquivo '||filename1 );
          when others then
                raise_application_error(-20101,'Erro na abertura do arquivo '||filename1  );
      
        end;
      
      end if;
      */
      --/
      v_msg := v_crlf || '--DMW.Boundary.605592468--' || v_crlf;
      utl_smtp.close_data(mail_con);
      utl_smtp.quit(mail_con);
   
   exception
   
      when others then
         raise_application_error(-20102,
                                 'Erro na abertura do arquivo ' || filename1);
      
   end;

   --------------------------------------------------------------------------------
   function data_util(v_data in date) return date
   /*
      || Retorna a data util subsequente
      */
    is
   
      v_dia varchar2(2);
   
   begin
   
      v_dia := to_char(v_data,
                       'D');
      if v_dia = '7' then
         return v_data + 2;
      elsif v_dia = '1' then
         return v_data + 1;
      else
         return v_data;
      end if;
   
   end;

   --------------------------------------------------------------------------------
   function carac_especial(v_caracter in varchar2) return varchar2
   /*
      || Testa se ha caracter especial na string
      */
    is
      v_retorno varchar2(1) := 'N';
   
   begin
   
      if v_caracter is null then
         return 'N';
      end if;
   
      for i in 1 .. length(v_caracter) loop
         if ascii(substr(upper(v_caracter),
                         i,
                         1)) not in (32,
                                     38,
                                     39,
                                     44,
                                     45,
                                     46,
                                     47) then
            if ascii(substr(upper(v_caracter),
                            i,
                            1)) not between 65 and 90 then
               if ascii(substr(upper(v_caracter),
                               i,
                               1)) not between 48 and 57 then
                  v_retorno := 'S';
               end if;
            end if;
         end if;
      end loop;
   
      return v_retorno;
   
   end;

   -----------------------------------------------------------------------------------
   function mascara(val  in varchar2
                   ,masc in varchar2) return varchar2 is
   
      c  varchar2(30);
      v  varchar2(30);
      t  number;
      n  number;
      i  number;
      tc number;
      tm number;
      tv number;
   
      aux   char(1);
      v_ret varchar2(30);
   begin
   
      if masc is null then
         return v_ret;
      end if;
   
      c  := '';
      t  := length(masc);
      tm := 0;
      for n in 1 .. t loop
         aux := substr(masc,
                       n,
                       1);
         if aux = '9' or
            aux = 'A' or
            aux = 'X' then
            tm := tm + 1;
         end if;
      end loop;
      tc := length(val);
      v  := '';
      for n in 1 .. tc loop
        
         aux := substr(val,
                       n,
                       1);
                       
         if (aux >= '0' and aux <= '9') or
            (aux >= 'A' and aux <= 'Z') then
            
            v := v || substr(val,
                             n,
                             1);
                             
         end if;
      end loop;
      tv := length(v);
      if tm <> tv then
         return val;
      end if;
      i := 0;
      for n in 1 .. t loop
         if substr(masc,
                   n,
                   1) = '9' then
            i   := i + 1;
            aux := substr(v,
                          i,
                          1);
            if aux >= '0' and
               aux <= '9' then
               c := c || aux;
            else
               return val;
            end if;
         elsif substr(masc,
                      n,
                      1) = 'A' then
            i   := i + 1;
            aux := substr(v,
                          i,
                          1);
            if aux >= 'A' and
               aux <= 'Z' then
               c := c || aux;
            else
               return val;
            end if;
         elsif substr(masc,
                      n,
                      1) = 'X' then
            i   := i + 1;
            aux := substr(v,
                          i,
                          1);
            if (aux >= 'A' and aux <= 'Z') or
               (aux >= '0' and aux <= '9') then
               c := c || aux;
            else
               return val;
            end if;
         else
            c := c || substr(masc,
                             n,
                             1);
         end if;
      end loop;
      v_ret := c;
      return v_ret;
   
   end;
   --------------------------------------------------------------------------------
   function ofuscar(val in varchar2) return varchar2 is
   
      v_ret      varchar2(100);
      v_raw      long raw;
      v_chave    varchar2(100) := 'SYSEFILS'; 
      v_chave_rw long raw;
      v_val_rw   long raw;
      --/     
      multiplo_err exception;
      pragma exception_init(multiplo_err,
                            -28232);
      multiplo_err_msg varchar2(100) := '*** VALOR N√O … MULTIPLO DE 8 BYTES ***';
      --/
      valor_flutuante_err exception;
      pragma exception_init(valor_flutuante_err,
                            -28233);
      valor_flutuante_err_msg varchar2(100) := '*** N√O E¥PERMITIDO VALOR COM VIRGULA ***';
      --/
   begin
      v_val_rw   := utl_raw.cast_to_raw(val);
      v_chave_rw := utl_raw.cast_to_raw(v_chave);
      dbms_obfuscation_toolkit.desencrypt(input          => v_val_rw,
                                          key            => v_chave_rw,
                                          encrypted_data => v_raw);
   
      v_ret := utl_raw.cast_to_varchar2(v_raw);
      return v_ret;
   exception
      when multiplo_err then
         raise_application_error(-20101,
                                 multiplo_err_msg);
      when valor_flutuante_err then
         raise_application_error(-20101,
                                 valor_flutuante_err_msg);
   end;

   /* exemplo
   SELECT LIB_UTIL.IS_MINUSCULA('A'),
          LIB_UTIL.IS_MAIUSCULA('a'),
          instr('aaaa','A'),
          instr('aAbA','A',3),
          lib_util.ofuscar('sergio00'),
          lib_util.desofuscar(lib_util.ofuscar('sergio00')) ds1,
          lib_util.desofuscar('ø∑ŒÙL„øP') ds12,
          lib_util.encriptar('sergio'),
          CASE WHEN lib_util.ofuscar('sergio00') ='ø∑ŒÙL„øP' THEN
             'OK'
             ELSE
             'NAO'
             END VERF 
   
   FROM DUAL  
     */
   --------------------------------------------------------------------------------
   function desofuscar(val in varchar2) return varchar2 is
   
      v_ret      varchar2(100);
      v_raw      long raw;
      v_chave    varchar2(100) := 'YSEFILS'; --'CETAMRES';
      v_chave_rw long raw;
      v_val_rw   long raw;
      --/     
      multiplo_err exception;
      pragma exception_init(multiplo_err,
                            -28232);
      multiplo_err_msg varchar2(100) := '*** VALOR N√O … MULTIPLO DE 8 BYTES ***';
      --/
      valor_flutuante_err exception;
      pragma exception_init(valor_flutuante_err,
                            -28233);
      valor_flutuante_err_msg varchar2(100) := '*** N√O E¥PERMITIDO VALOR COM VIRGULA ***';
      --/
   begin
      v_val_rw   := utl_raw.cast_to_raw(val);
      v_chave_rw := utl_raw.cast_to_raw(v_chave);
      dbms_obfuscation_toolkit.desdecrypt(input          => v_val_rw,
                                          key            => v_chave_rw,
                                          decrypted_data => v_raw);
   
      v_ret := utl_raw.cast_to_varchar2(v_raw);
      return v_ret;
   exception
      when multiplo_err then
         raise_application_error(-20101,
                                 multiplo_err_msg);
      when valor_flutuante_err then
         raise_application_error(-20101,
                                 valor_flutuante_err_msg);
   end;

   --------------------------------------------------------------------------------
   function encriptar(val in varchar2) return varchar2 is
      v_ret varchar2(100);
   begin
      v_ret := ltrim(to_char(dbms_utility.get_hash_value((val),
                                                         298345672,
                                                         power(2,
                                                               30)),
                             rpad('X',
                                  29,
                                  'X') || 'X'));
   
      return v_ret;
   
   end;
   -----------------------------------------------------------------------------------
   function tira_caracter(pstring in varchar2) return varchar2 is
      v_ret varchar2(32000);
   begin
      v_ret := translate(pstring,
                         'ø‘¬√’¡…Õ”⁄¿» Ã“ŸACEIOUAEIOUAEIOU«¡EU‚„ı·ÍÈÌÙÛ˙‡ËÏÚ˘aceiouaeiouaeiouÁ„ıeu',
                         ' OAAOAEIOUAEEIOUACEIOUAEIOUAEIOUCAEUaaoaeeioouaeiouaceiouaeiouaeioucaoeu');
   
      return v_ret;
   end;

   --------------------------------------------------------------------------------
   function strzero(p_num in number
                   ,p_zer in number) return varchar2 is
      v_ret varchar2(20);
   begin
      v_ret := lpad(p_num,
                    nvl(p_zer,
                        0),
                    '0');
      return v_ret;
   end;
   ---------------------------------------------------------------------------------
   function formata_string(p_str varchar2) return varchar2 is
   begin
      return rtrim(ltrim(lib_util.tira_caracter(upper(p_str))));
   exception
      when others then
         return p_str;
   end;

   ---------------------------------------------------------------------------------
   function formata_string(p_str   varchar2
                          ,p_caixa char) return varchar2 is
   begin
      if p_caixa = 'U' then
         return rtrim(ltrim(lib_util.tira_caracter(upper(p_str))));
      elsif p_caixa = 'L' then
         return rtrim(ltrim(lib_util.tira_caracter(lower(p_str))));
      elsif p_caixa = 'I' then
         return rtrim(ltrim(lib_util.tira_caracter(initcap(p_str))));
      else
         return rtrim(ltrim(lib_util.tira_caracter((p_str))));
      end if;
   exception
      when others then
         return p_str;
   end;
   -----------------------------------------------------------------------------------
   function somente_numero(p_str varchar2) return varchar2 is
      v_ret varchar2(1000);
   begin
      v_ret := p_str;
      v_ret := rtrim(ltrim(v_ret));
      v_ret := replace(v_ret,
                       '.',
                       '');
      v_ret := replace(v_ret,
                       ',',
                       '');
      v_ret := replace(v_ret,
                       '-',
                       '');
      v_ret := replace(v_ret,
                       '/',
                       '');
      v_ret := replace(v_ret,
                       '\',
                       '');
      v_ret := replace(v_ret,
                       ':',
                       '');
   
      return v_ret;
   
   end;

   --|---------------------------------------------------------------------------
   function dominio(p_cd sgn_dominio.codigo%type) return sgn_dominio.valor%type is
      --|
      cursor cr is
         select valor from sgn_dominio where codigo = p_cd;
      --|
      v_ret sgn_dominio.valor%type;
      --|
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   end;

   --|---------------------------------------------------------------------------
   function trata_linha_folha(p_linha in varchar2
                             ,p_valor in varchar2) return varchar2 is
      v_numero number;
      v_res_n  number;
      v_cont   number;
      v_mask   varchar2(30);
      v_ret    varchar2(4000);
      v_linha  varchar2(4000);
      v_char   char(1);
      v_sep    char(1);
   begin
      v_linha  := trim(p_linha);
      v_numero := length(v_linha);
      v_cont   := 0;
      --if v_linha is not null
      for i in 1 .. nvl(length(v_linha),
                        0) loop
         v_char := substr(v_linha,
                          i,
                          1);
      
         if v_char = ';' then
            v_cont := v_cont + 1;
            if v_cont = 1 then
               if i = 1 then
                  v_char := '';
               else
                  v_char := p_valor;
               end if;
            
            elsif v_cont > 1 then
               v_char := '';
            end if;
         else
            v_cont := 0;
         end if;
         v_ret := v_ret || v_char;
      end loop;
   
      return v_ret;
   end trata_linha_folha;
   -----------------------------------------------------------------------
   function fnc_trata_string(string in varchar2) return varchar2 is
      v_string varchar2(32767);
   begin
      select translate(upper(rtrim(ltrim(string))),
                       'ø‘¬√’¡…Õ”⁄¿» Ã“ŸACEIOUAEIOUAEIOU«¡EU‚„ı·ÍÈÌÙÛ˙‡ËÏÚ˘aceiouaeiouaeiouÁ„ıeu',
                       ' OAAOAEIOUAEEIOUACEIOUAEIOUAEIOUCAEUaaoaeeioouaeiouaceiouaeiouaeioucaoeu')
        into v_string
        from dual;
   
      for i in 0 .. 31 loop
         v_string := replace(v_string,
                             chr(i),
                             null);
      end loop;
   
      return v_string;
   end;
   ----------------------------------------------------------------------
   function fnc_nome_arquivo(p_texto varchar2) return varchar2 is
   
      v_ret varchar2(1000);
   
   begin
      select reverse(substr(reverse(p_texto),
                            1,
                            instr(reverse(p_texto),
                                  '\') - 1))
        into v_ret
        from dual;
   
      return v_ret;
   end;

   ----------------------------------------------------------------------
   function fnc_path_arquivo(p_texto varchar2) return varchar2 is
   
      v_ret varchar2(1000);
   
   begin
      select reverse(substr(reverse(p_texto),
                            1,
                            instr(reverse(p_texto),
                                  '\') - 1))
        into v_ret
        from dual;
        
        v_ret := replace(p_texto,
                       v_ret,
                       '');
      return v_ret;
   end;
   ----------------------------------------------------------------------
   function fnc_retira_extensao_arquivo(p_texto varchar2) return varchar2 is
   
      v_ret varchar2(1000);
   
   begin
      select reverse(substr(reverse(p_texto),
                            1,
                            instr(reverse(p_texto),
                                  '.')))
        into v_ret
        from dual;
      v_ret := replace(p_texto,
                       v_ret,
                       '');
      return v_ret;
   end;

   ----------------------------------------------------------------------
   function fnc_extensao_arquivo(p_texto varchar2) return varchar2 is
   
      v_ret varchar2(1000);
   
   begin
      select reverse(substr(reverse(p_texto),
                            1,
                            instr(reverse(p_texto),
                                  '.')))
        into v_ret
        from dual;
      v_ret := replace(v_ret,
                       '.' || '');
      return v_ret;
   end;
   -------------------------------------------------------------

   function fnc_maquina_usu return varchar2 is
      v_ret varchar2(100);
   begin
   
      select /*sys_context('USERENV',
                                           'SERVER_HOST') "Nome SERVIDOR"
                               ,sys_context('USERENV',
                                           'INSTANCE_NAME') "Inst‚ncia"
                               */
       sys_context('USERENV',
                   'HOST') "CLIENTE"
      /* ,sys_context('USERENV',
                  'IP_ADDRESS') "IP Cliente"
      ,sys_context('USERENV',
                  'OS_USER') "Usu·rio SO"
      ,sys_context('USERENV',
                  'SESSION_USER') "Usu·rio BD"*/
        into v_ret
        from dual;
      return v_ret;
   exception
      when others then
         return 'erro';
      
   end;
   --|---------------------------------------------------------------
   function split_texto(p_texto varchar2
                       ,p_tam   number) return varchar2 is
      v_aux number(3);
      v_ini number(3);
   
      v_texto varchar2(4000);
      v_sep   varchar2(10);
   begin
      if p_tam is null then
         return p_texto;
      end if;
   
      v_aux := floor(length(p_texto) / p_tam);
   
      if nvl(v_aux,
             0) = 0 then
         return p_texto;
      end if;
   
      v_ini := 1;
      for i in 1 .. v_aux loop
         if i = v_aux then
            v_texto := v_texto || v_sep || substr(p_texto,
                                                  v_ini);
         else
            v_texto := v_texto || v_sep || substr(p_texto,
                                                  v_ini,
                                                  p_tam);
         end if;
         v_sep := chr(10);
         v_ini := v_ini + p_tam;
      end loop;
      return v_texto;
   end;
   --|--------------------------------------------------------------------------
   --| split retornando um varchar2_table
   --|--------------------------------------------------------------------------
   function split_texto(p_texto       varchar2
                       ,p_delimitador varchar2) return dbms_sql.varchar2_table is
  
      v_expressao varchar2(100) := '[^' || p_delimitador || ']+';
      i           number(9);
   
      vt_texto dbms_sql.varchar2_table;
   
      cursor cr is
         select regexp_substr(p_texto,
                              v_expressao,
                              1,
                              level)
           from dual
         connect by regexp_substr(p_texto,
                                  v_expressao,
                                  
                                  1,
                                  level) is not null;
   
   begin
      open cr;
      fetch cr bulk collect
         into vt_texto;
      close cr;
      return vt_texto;
   end;
   --|---------------------------------------------------------------
/*  EXEMPLO DE MASCARA COM EXPRESSAO REGULAR
 SELECT decode(cpf
             ,NULL
             ,NULL
             ,translate(to_char(cpf / 100, '000,000,000.00'), ',.', '.-')) cpf_com_mascara
       ,regexp_replace(cpf,'([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})','\1.\2.\3-\4') cpf_com_mascara_regexp
       ,regexp_replace('05860120', '([[:digit:]]{2})([[:digit:]]{3})([[:digit:]]{3})', '\1.\2-\3') as CEP
  FROM ((SELECT '12345678912' cpf
               ,'12345678000189' cnpj
           FROM dual))
   */        
end lib_util;
/
