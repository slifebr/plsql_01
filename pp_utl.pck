create or replace package pp_utl is
   --||
   --|| PP_UTL.PKS : tipos
   --||
   type t_tb_number_10 is table of number(10);
   --||
   --|| PP_UTL.PKS : Funcoes gerais da produc?o
   --||

   --------------------------------------------------------------------
   -- Retorna Peso do produto na lista de legenda
   --------------------------------------------------------------------
   function peso_total_legenda(p_emp pp_ordens.empresa%type
                              ,p_fil pp_ordens.filial%type
                              ,p_ord pp_ordens.ordem%type
                              ,p_des pp_desenho.desenho%type
                              ,p_ver pp_desenho_ver.versao%type
                              ,p_pos pp_desenho_pos.posicao%type) return number;
   ---------------------------------------------------------------------
   -- Retorna Qtde do produto na lista de legenda
   ---------------------------------------------------------------------
   function qtde_total_legenda(p_emp pp_ordens.empresa%type
                              ,p_fil pp_ordens.filial%type
                              ,p_ord pp_ordens.ordem%type
                              ,p_des pp_desenho.desenho%type
                              ,p_ver pp_desenho_ver.versao%type
                              ,p_pos pp_desenho_pos.posicao%type) return number;
   --/ sobrecarga
   function qtde_total_legenda(p_emp pp_ordens.empresa%type
                              ,p_fil pp_ordens.filial%type
                              ,p_ord pp_ordens.ordem%type
                              ,p_des pp_desenho.desenho%type
                              ,p_ver pp_desenho_ver.versao%type
                              ,p_pos pp_desenho_pos.posicao%type
                              ,p_prd ce_produtos.produto%type) return number;
   --/ SOBRECARGA PARA LA
   function qtde_total_legenda(p_emp pp_ordens.empresa%type
                              ,p_fil pp_ordens.filial%type
                              ,p_ord pp_ordens.ordem%type
                              ,p_prd ce_produtos.produto%type) return number;
   -----------------------------------------------------------------------------------------------------
   --/ % Expedido da OP
   ----------------------------------------------------------------------------------------------------------------------
   function perc_exped_op(p_emp pp_ordens.empresa%type
                         ,p_fil pp_ordens.filial%type
                         ,p_ord pp_ordens.ordem%type
                         ,p_des pp_desenho.desenho%type
                         ,p_prd ce_produtos.produto%type) return number;

   ----------------------------------------------------------------------
   -- Retorna Maior Versao do Desenho
   ----------------------------------------------------------------------
   function fnc_max_versao_des(p_emp pp_desenho.empresa%type
                              ,p_fil cd_filiais.filial%type
                              ,p_des pp_desenho.desenho%type)
      return pp_desenho_ver.versao%type;
   -----------------------------------------------------------------------------------------------------
   --/ % retorna o desenho de uma id versao
   ----------------------------------------------------------------------------------------------------------------------
   function fnc_desenho(p_id pp_desenho_ver.id_desenhover%type)
      return pp_desenho.desenho%type;

   -----------------------------------------------------------------------------------------------------
   --/ % retorna o versao de uma id versao
   ----------------------------------------------------------------------------------------------------------------------
   function fnc_versao_desenho(p_id pp_desenho_ver.id_desenhover%type)
      return pp_desenho_ver.versao%type;
   -----------------------------------------------------------------------------------------------------
   --/ % retorna o produto de um desenho
   ----------------------------------------------------------------------------------------------------------------------
   function fnc_produto_desenho(p_des pp_desenho.desenho%type)
      return pp_desenho.produto%type;

   -----------------------------------------------------------------------------------------------------
   --/ % retorna o produto da posicao de um desenho 
   ----------------------------------------------------------------------------------------------------------------------
   function fnc_produto_desenho_pos(p_idver pp_desenho_pos.id_desenhover%type
                                   ,p_pos   pp_desenho_pos.posicao%type)
      return pp_desenho.produto%type;
   -----------------------------------------------------------------------------------------------------
   function peso_total_croqui(p_emp pp_desenho.empresa%type
                             ,p_fil pp_desenho.filial%type
                             ,p_des pp_desenho.desenho%type
                             ,p_ver pp_desenho_ver.versao%type
                             ,p_pos pp_desenho_pos.posicao%type) return number;

   -----------------------------------------------------------------------------------------------------
   function qtde_proj(p_emp  pp_desenho.empresa%type
                     ,p_fil  pp_desenho.filial%type
                     ,p_opos pp_ordens.ordem%type
                     ,p_prd  ce_produtos.produto%type) return number;
   -----------------------------------------------------------------------------------------------------
   function qtde_posicao(p_emp  pp_desenho.empresa%type
                        ,p_fil  pp_desenho.filial%type
                        ,p_opos pp_ordens.ordem%type
                        ,p_des  pp_desenho.desenho%type
                        ,p_ver  pp_desenho_ver.versao%type
                        ,p_pos  pp_desenho_pos.posicao%type) return number;
   ------------------------------------------------------------------------------------------------------
   function mascara_opos(val in varchar2) return varchar2;

   ------------------------------------------------------------------------------------------------------
   function mascara_des(val in varchar2) return varchar2;

   -------------------------------------------------------------------------
   function pipe_sequencia(p_num number) return t_tb_number_10
      pipelined;
   -------------------------------------------------------------------------
   -------------------------------------------------------------------------
   
   function proximo_desenho(p_emp cd_filiais.empresa%type
                           , p_des pp_desenho.desenho%type)  
                           return pp_desenho.desenho%type;
   --|---------------------------------------------------------------
   function fnc_status_contrato(p_emp pp_contratos.empresa%type
                               ,p_con pp_contratos.contrato%type
                               ) return pp_contratos.status%type;

   --|---------------------------------------------------------------
   function fnc_descr_aplic_eap(p_apl pp_grupos_cron.aplic%type) return varchar2;
end;
/
create or replace package body pp_utl is

   --||
   --|| PP_UTL.PKB : Funcoes gerais da produc?o
   --||

   ----------------------------------------------------------------------------------------------------------------------
   -- Retorna Qtde do produto na lista de legenda
   ----------------------------------------------------------------------------------------------------------------------
   function peso_total_legenda(p_emp pp_ordens.empresa%type
                              ,p_fil pp_ordens.filial%type
                              ,p_ord pp_ordens.ordem%type
                              ,p_des pp_desenho.desenho%type
                              ,p_ver pp_desenho_ver.versao%type
                              ,p_pos pp_desenho_pos.posicao%type) return number is
   
      cursor cr is
         select (d.peso_total * b.qtde) peso_total
         --,(d.peso_total  /D.QUANTIDADE)  PESO_ACABADO_UNIT
         --, B.QUANTIDADE * D.QUANTIDADE AS QTDTOT
           from pp_desenho_est b
               ,pp_desenho_pos d
               ,pp_desenho_ver v
               ,pp_desenho     des
               ,pp_eap_proj    eap
          where d.empresa = eap.empresa
               --     AND DES.DESENHO = B.DESENHO
               --     AND V.VERSAO  = B.VERSAO
            and v.id_desenhover = d.id_desenhover
            and des.id_desenho = v.id_desenho
            and b.id_desenhover = v.id_desenhover
            and d.empresa = p_emp
            and eap.opos = p_ord
            and eap.id_eap = b.id_eap
            and des.desenho = p_des
            and v.versao = p_ver
            and d.posicao = p_pos;
   
      v_ret number;
   
   begin
   
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end peso_total_legenda;
   -------------------------------------------------------------------------------------------------------------------------

   -- Retorna Qtde do produto na lista de legenda
   ----------------------------------------------------------------------------------------------------------------------
   function qtde_total_legenda(p_emp pp_ordens.empresa%type
                              ,p_fil pp_ordens.filial%type
                              ,p_ord pp_ordens.ordem%type
                              ,p_des pp_desenho.desenho%type
                              ,p_ver pp_desenho_ver.versao%type
                              ,p_pos pp_desenho_pos.posicao%type) return number is
   
      cursor cr is
         select qtd_unid qtde
           from pp_desenho_est b
               ,pp_desenho_pos d
               ,pp_desenho_ver v
               ,pp_desenho     des
               ,pp_eap_proj    eap
          where d.empresa = eap.empresa
               
            and des.id_desenho = v.id_desenho
            and v.id_desenhover = d.id_desenhover
               
            and d.empresa = p_emp
            and b.id_desenhover = v.id_desenhover
            and eap.opos = p_ord
            and eap.id_eap = b.id_eap
            and des.desenho = p_des
            and v.versao = p_ver
            and d.posicao = p_pos
            and d.pos_produto is not null;
      v_ret number;
   
   begin
      v_ret := 0;
   
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
   end qtde_total_legenda;
   -----------------------------------------------------------------------------------------------------
   --/ sobrecarga
   ----------------------------------------------------------------------------------------------------------------------
   function qtde_total_legenda(p_emp pp_ordens.empresa%type
                              ,p_fil pp_ordens.filial%type
                              ,p_ord pp_ordens.ordem%type
                              ,p_des pp_desenho.desenho%type
                              ,p_ver pp_desenho_ver.versao%type
                              ,p_pos pp_desenho_pos.posicao%type
                              ,p_prd ce_produtos.produto%type) return number is
   
      cursor cr is
         select sum(qtde)
           from (select case
                           when unidade = 'KG' then
                            (decode(nvl(peso_total,
                                        0),
                                    0,
                                    1,
                                    peso_total) * qtd_b)
                           when unidade in ('M',
                                            'MT') then
                            ((nvl(comprimento,
                                  0) / 1000) * qtd_d * qtd_b)
                           when unidade = 'M2' then
                            (nvl(comprimento,
                                 0) / 1000) * (nvl(largura,
                                                   0) / 1000) * qtd_d * qtd_b
                           else -- ('PC','CJ','L','GL','JG','BR', 'FL' ,'FR','RL') then
                            (qtd_d * qtd_b)
                        end qtde
                   from (select pos_produto
                               ,'' unidade
                               ,d.peso_total
                               ,b.qtde qtd_b
                               ,d.comprimento
                               ,d.largura
                               ,d.quantidade qtd_d
                           from pp_desenho_est b
                               ,pp_desenho_pos d
                               ,pp_desenho     des
                               ,pp_desenho_ver v
                               ,pp_eap_proj    eap
                          where d.empresa = eap.empresa
                            and d.empresa = p_emp
                            and v.id_desenhover = b.id_desenhover
                            and v.id_desenho = des.id_desenho
                            and v.versao = p_ver
                            and des.desenho = p_des
                            and eap.opos = p_ord
                            and eap.id_eap = b.id_eap
                            and pos_produto = p_prd
                         -- CONNECT BY PRIOR D.POS_DESENHO = D.DESENHO AND D.POS_VERSAO = D.VERSAO
                         --START WITH POS_PRODUTO = P_PRD
                         ));
   
      v_ret number;
   
   begin
      v_ret := 0;
      if p_des is not null then
         v_ret := nvl(qtde_total_legenda(p_emp,
                                         p_fil,
                                         p_ord,
                                         p_des,
                                         p_ver,
                                         p_pos),
                      0);
         if v_ret = 0 then
            v_ret := nvl(qtde_total_legenda(p_emp,
                                            p_fil,
                                            p_ord,
                                            p_prd),
                         0);
         end if;
      
      else
      
         open cr;
         fetch cr
            into v_ret;
         close cr;
         --/
         if nvl(v_ret,
                0) = 0 then
            v_ret := nvl(qtde_total_legenda(p_emp,
                                            p_fil,
                                            p_ord,
                                            p_prd),
                         0);
         end if;
      
      end if;
   
      return nvl(v_ret,
                 0);
   end qtde_total_legenda;
   -----------------------------------------------------------------------------------------------------
   --/ sobrecarga
   ----------------------------------------------------------------------------------------------------------------------
   function qtde_total_legenda(p_emp pp_ordens.empresa%type
                              ,p_fil pp_ordens.filial%type
                              ,p_ord pp_ordens.ordem%type
                              ,p_prd ce_produtos.produto%type) return number is
   
      cursor cr is
         select case
                   when unidade = 'KG' then
                    (decode(nvl(peso_total,
                                0),
                            0,
                            1,
                            peso_total))
                   when unidade in ('M',
                                    'MT') then
                    ((nvl(comprimento,
                          0) / 1000) * qtd_d)
                   when unidade = 'M2' then
                    (nvl(comprimento,
                         0) / 1000) * (nvl(largura,
                                           0) / 1000) * qtd_d
                   else -- ('PC','CJ','L','GL','JG','BR', 'FL' ,'FR','RL') then
                    (qtd_d)
                end qtde
           from (select d.unidade
                       ,d.peso_total
                       ,d.comprimento
                       ,d.largura
                       ,d.quantidade qtd_d
                   from pp_listaa       b
                       ,pp_listaa_itens d
                  where d.empresa = b.empresa
                    and d.filial = b.filial
                    and d.listaa = b.listaa
                    and d.empresa = p_emp
                    and d.filial = p_fil
                    and b.ordem = p_ord
                    and d.produto = p_prd);
   
      v_ret number;
   
   begin
      v_ret := 0;
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
   end qtde_total_legenda;
   -----------------------------------------------------------------------------------------------------

   -----------------------------------------------------------------------------------------------------
   --/ % Expedido da OP
   ----------------------------------------------------------------------------------------------------------------------
   function perc_exped_op(p_emp pp_ordens.empresa%type
                         ,p_fil pp_ordens.filial%type
                         ,p_ord pp_ordens.ordem%type
                         ,p_des pp_desenho.desenho%type
                         ,p_prd ce_produtos.produto%type) return number is
   
      cursor cr is
         select sum(nvl(a.perc_op,
                        0))
           from ft_itens_rom a
          where a.opos = p_ord
            and a.empresa = p_emp
            and a.filial = p_fil
            and (p_des is null or a.desenho = p_des)
            and (p_prd is null or a.produto = p_prd);
      v_ret number;
   
   begin
      v_ret := 0;
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
   end perc_exped_op;
   -----------------------------------------------------------------------------------------------------

   -----------------------------------------------------------------------------------------------------

   function num_dia_semana(p_dat in date) return number
   
      /*
      || Numero do dia da semana da data
      */
    is
   
      n       number;
      d1      number;
      d2      number;
      v_dat   date;
      v_dia   number;
      v_dia_r number;
      v_conta number;
      p_sem   varchar2(10);
      p_ano   number(4);
      p_mes   number(2);
   
   begin
   
      v_dia_r := to_char(p_dat,
                         'd'); --to_number( to_char(p_dat,'dd')) - ((trunc((to_number( to_char(p_dat,'dd')) -1) / 7)) * 7 );
   
      return v_dia_r;
   
   end;
   ----------------------------------------------------------------------
   -- Retorna Maior Versao do Desenho
   ----------------------------------------------------------------------
   function fnc_max_versao_des(p_emp pp_desenho.empresa%type
                              ,p_fil cd_filiais.filial%type
                              ,p_des pp_desenho.desenho%type)
      return pp_desenho_ver.versao%type is
      --/ variaveis
      v_ret pp_desenho_ver.versao%type;
   
   begin
   
      select max(v.versao)
        into v_ret
        from pp_desenho     d
            ,pp_desenho_ver v
       where d.empresa = p_emp
         and d.desenho = p_des
         and v.id_desenho = d.id_desenho
         and v.versao = (select max(v2.versao)
                           from pp_desenho_ver v2
                          where v2.id_desenho = d.id_desenho);
   
      return v_ret;
   
   end;
   -----------------------------------------------------------------------------------------------------
   --/ % retorna o desenho de uma versao
   ----------------------------------------------------------------------------------------------------------------------
   function fnc_desenho(p_id pp_desenho_ver.id_desenhover%type)
      return pp_desenho.desenho%type is
      cursor cr is
         select desenho
           from pp_desenho     a
               ,pp_desenho_ver b
          where b.id_desenhover = p_id
            and a.id_desenho = b.id_desenho;
   
      v_ret pp_desenho.desenho%type;
   begin
      --/
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;
   -----------------------------------------------------------------------------------------------------
   --/ % retorna o versao de uma id versao
   ----------------------------------------------------------------------------------------------------------------------
   function fnc_versao_desenho(p_id pp_desenho_ver.id_desenhover%type)
      return pp_desenho_ver.versao%type is
      cursor cr is
         select versao from pp_desenho_ver b where b.id_desenhover = p_id;
   
      v_ret pp_desenho_ver.versao%type;
   begin
      --/
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;

   -----------------------------------------------------------------------------------------------------
   --/ % retorna o produto de um desenho
   ----------------------------------------------------------------------------------------------------------------------
   function fnc_produto_desenho(p_des pp_desenho.desenho%type)
      return pp_desenho.produto%type is
      cursor cr is
         select a.produto from pp_desenho a where a.desenho = p_des;
   
      v_ret pp_desenho.produto%type;
   begin
      --/
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;

   -----------------------------------------------------------------------------------------------------
   --/ % retorna o produto da posicao de um desenho 
   ----------------------------------------------------------------------------------------------------------------------
   function fnc_produto_desenho_pos(p_idver pp_desenho_pos.id_desenhover%type
                                   ,p_pos   pp_desenho_pos.posicao%type)
      return pp_desenho.produto%type is
      cursor cr is
         select a.produto
           from pp_desenho     a
               ,pp_desenho_ver b
               ,pp_desenho_pos c
          where a.id_desenho = b.id_desenho
            and b.id_desenhover = c.id_desenhover
            and c.id_desenhover = p_idver
            and c.posicao = p_pos;
   
      v_ret pp_desenho.produto%type;
   begin
      --/
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;
   -----------------------------------------------------------------------------------------------------
   function peso_total_croqui(p_emp pp_desenho.empresa%type
                             ,p_fil pp_desenho.filial%type
                             ,p_des pp_desenho.desenho%type
                             ,p_ver pp_desenho_ver.versao%type
                             ,p_pos pp_desenho_pos.posicao%type) return number is
      cursor cr is
      
         select sum(peso_acabado_unit * quantidade) peso
           from pp_desenho_pos p
               ,pp_desenho_ver v
               ,pp_desenho     d
          where d.empresa = p_emp
            and d.filial = p_fil
            and d.desenho = p_des
            and v.versao = p_ver
            and v.id_desenho = d.id_desenho
            and p.id_desenhover = v.id_desenhover
            and (p_pos is null or p.posicao = p_pos);
   
      v_peso number;
   begin
      v_peso := null;
      open cr;
      fetch cr
         into v_peso;
      close cr;
   
      return v_peso;
   end;
   -----------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------
   function qtde_proj(p_emp  pp_desenho.empresa%type
                     ,p_fil  pp_desenho.filial%type
                     ,p_opos pp_ordens.ordem%type
                     ,p_prd  ce_produtos.produto%type) return number is
      cursor cr is
         select sum(po.qtd_unid * pe.qtde)
           from pp_desenho_est pe
               ,pp_desenho     de
               ,pp_desenho_ver v
               ,pp_desenho_pos po
          where po.id_desenhover = v.id_desenhover
            and v.id_desenho = de.id_desenho
            and pe.id_desenhover = v.id_desenhover
            and v.versao = (select max(v2.versao)
                              from pp_desenho_ver v2
                             where v2.id_desenho = de.id_desenho)
            and pe.ordem = p_opos
            and po.pos_produto = p_prd
            and pe.empresa = p_emp
            and pe.filial = p_fil;
   
      v_ret number;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
   end;

   -----------------------------------------------------------------------------------------------------
   function qtde_posicao(p_emp  pp_desenho.empresa%type
                        ,p_fil  pp_desenho.filial%type
                        ,p_opos pp_ordens.ordem%type
                        ,p_des  pp_desenho.desenho%type
                        ,p_ver  pp_desenho_ver.versao%type
                        ,p_pos  pp_desenho_pos.posicao%type) return number is
      cursor cr is
         select sum(po.qtd_unid * pe.qtde)
           from pp_desenho_est pe
               ,pp_desenho     de
               ,pp_desenho_ver v
               ,pp_desenho_pos po
          where po.id_desenhover = v.id_desenhover
            and v.id_desenho = de.id_desenho
            and pe.id_desenhover = v.id_desenhover
               /*
               and v.versao = (select max(v2.versao)
                                 from pp_desenho_ver v2
                                where v2.id_desenho = de.id_desenho)
                                */
            and pe.ordem = p_opos
            and po.posicao = p_pos
            and v.versao = p_ver
            and de.desenho = p_des
            and pe.empresa = p_emp
            and pe.filial = p_fil;
   
      v_ret number;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
   end;

   ------------------------------------------------------------------------------------------------------
   function mascara_opos(val in varchar2) return varchar2 is
   
      cursor cr is
         select m.masc_ordem from pp_prgen m;
   
      v_ret  varchar2(30);
      v_masc varchar2(30);
   
   begin
      open cr;
      fetch cr
         into v_masc;
      close cr;
   
      v_ret := lib_util.mascara(val,
                                v_masc);
   
      return v_ret;
   
   end;
   ------------------------------------------------------------------------------------------------------
   function mascara_des(val in varchar2) return varchar2 is
      cursor cr is
         select m.masc_desen from pp_prgen m;
   
      v_ret  varchar2(30);
      v_masc varchar2(30);
   
   begin
      open cr;
      fetch cr
         into v_masc;
      close cr;
   
      v_ret := lib_util.mascara(val,
                                v_masc);
   
      return v_ret;
   
   end;

   -------------------------------------------------------------------------
   function pipe_sequencia(p_num number) return t_tb_number_10
      pipelined is
   
      lista t_tb_number_10 := t_tb_number_10();
   begin
      lista.extend(p_num);
      for i in 1 .. p_num loop
         lista(i) := i;
         pipe row(lista(i));
      end loop;
      return;
   end;
   -------------------------------------------------------------------------
   
   function proximo_desenho(p_emp cd_filiais.empresa%type
                           , p_des pp_desenho.desenho%type)  
                           return pp_desenho.desenho%type is
   
   cursor crMax (p_des2 pp_desenho.desenho%type) is
     select max(substr(d.desenho,-1 * (instr(reverse(d.desenho), '.')-1))) seq
      from pp_desenho d
     where d.empresa = p_emp
       and d.desenho like p_des2;
   
   cursor crPrx(p_des2 pp_desenho.desenho%type, p_num number) is
      select min(t.column_value) 
        from (select t.* 
        from table (pp_utl.pipe_sequencia(p_num)) t) t
          ,(select d.desenho ,
                   substr(d.desenho,-1 * (instr(reverse(d.desenho), '.')-1)) seq 
              from pp_desenho d
             where d.desenho like p_des2) d
       where  t.column_value = d.seq(+)
       and d.desenho is null;
   
    cursor crP is
       select masc_desen, 
              instr(reverse( p.masc_desen),'.')-1 
        from pp_prgen p;
    
   v_ret     pp_desenho.desenho%type;
   v_aux     varchar2(40);
   vn_aux    number(10);
   v_des     pp_desenho.desenho%type;
   v_tam     number(4);
   v_max     number(9);
   v_mascara pp_prgen.masc_desen%type;
   
   begin
      v_des  := p_des||'%';
      open crMax(v_des);
      fetch crMax into v_max;
      close crMax;
      
      if nvl(v_max,0) = 0 then
         vn_aux := 1;
      else
        vn_aux := 0;
        open crPrx(v_des, v_max);
        fetch crPrx into vn_aux;
        close crprx;
        
        if nvl(vn_aux,0) = 0 then
           vn_aux := v_max + 1;
        end if;
        
      end if;
      
      open crP;
      fetch crP into v_mascara,v_tam;
      close crP;
      v_des := p_des||lpad(nvl(vn_aux,0),v_tam,'0');
      v_ret := lib_util.mascara(v_des,v_mascara);

      return v_ret;
   end;     
   --|---------------------------------------------------------------
   function fnc_status_contrato(p_emp pp_contratos.empresa%type
                               ,p_con pp_contratos.contrato%type
                               ) return pp_contratos.status%type
                               is
   cursor cr is
     select p.status
       from pp_contratos p
      where p.empresa = p_emp
        and p.contrato = p_con;
       
   v_ret pp_contratos.status%type;
   begin
     open cr;
     fetch cr into v_ret;
     close cr;
     
     return v_ret;
   end;
   --|---------------------------------------------------------------
   function fnc_descr_aplic_eap(p_apl pp_grupos_cron.aplic%type) return varchar2
   is
   v_ret varchar2(50);
   
   begin
     if p_apl = 'C' then
        v_ret := 'Caldeira';
     elsif p_apl = 'A' then
        v_ret := 'Açucar/Alcool';
     elsif p_apl = 'O' then
        v_ret := 'Outros';
     else 
       v_ret := 'Outros';
     end if;
     
     return v_ret;
   end;
end;
/
