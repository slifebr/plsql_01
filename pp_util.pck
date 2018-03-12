create or replace package pp_util is

   --
   ----------------------------------------------------------------------------------------------
   --
   --   IDENTIFICAC?O
   --   -------------
   --   Package      : PP_UTIL
   --   Autor        : SERGIO LIMA
   --   Data criac?o : 01/01/2006
   --
   --   DEPENDENCIAS
   --   ------------
   --
   --   COMENTARIO
   --   ----------
   --
   --
   --   MANUTENC?ES
   --   -----------
   --
   --------------------------------------------------------------------------------
   subtype tnum is number;
   subtype tvalor is number(14,
                            2);
   subtype tvalor2 is number(16,
                             4);
   subtype tchar is varchar2(1);
   subtype tchar50 is varchar2(50);
   subtype tstr0 is varchar2(1024);
   subtype tstr is varchar2(32767);
   subtype tcurs is pls_integer;
   subtype tint is pls_integer;
   subtype tid is number(10);
   --
   p_usuario constant varchar2(30) := user;
   --
   gn_fator_min constant number := round(100 / 60,
                                         7);

   --------------------------------------------------------------------------------
   /*
   || Funcoes
   */
   --------------------------------------------------------------------------------
   procedure concat_data(e_data in date
                        ,es_hrs in out date);

   procedure pp_limpa(e_ord in pp_ordens.ordem%type);

   --------------------------------------------------------------------------------
   function max_func_dtvigen(p_emp   in cd_filiais.empresa%type
                            ,p_fil   in cd_filiais.filial%type
                            ,p_firma in cd_firmas.firma%type) return date;
   -------------------------------------------------------------------------------
   function op_cliente(p_ord pp_ordens.ordem%type) return varchar2;
   --/--------------------------------------------------------------------------
   function codigo_cliente_op(p_emp pp_ordens.empresa%type
                      ,p_fil pp_ordens.filial%type
                      ,p_op  pp_ordens.ordem%type) return cd_firmas.firma%type;
        
   --/--------------------------------------------------------------------------
   function codigo_cliente_prop(p_emp  pp_ordens.empresa%type
                               ,p_fil  pp_ordens.filial%type
                               ,p_prop pp_contratos.proposta%type) return cd_firmas.firma%type;    
   --------------------------------------------------------------------------------
   /*
   function Valida_Fx_RendProc( p_id_rendopmqfx in pp_rend_opprodmaq_fx.id_rendopmqfx%type
                              , p_id_rendopmq   in pp_rend_opprodmaq_fx.id_rendopmq%type
                              , p_fx_ini        in pp_rend_opprodmaq_fx.fx_ini%type
                              , p_fx_fim        in pp_rend_opprodmaq_fx.fx_fim%type
                              ) return boolean;
   */
   --------------------------------------------------------------------------------
   function horas_para_minutos(p_hora in varchar2) return number;

   function horas_para_minutos(p_hora in date) return number;

   function minutos_para_horas(p_min in number) return varchar2;
   function minutos_para_data(p_min in number) return date;

   function dif_data(p_dt_ini in date
                    ,p_dt_fim in date) return number;
   function dif_data_dias(p_dt_ini in date
                         ,p_dt_fim in date) return number;
   --------------------------------------------------------------------------------
   function fkg_cent_hora_cent(en_valor number) return number;
   -- select pp_util.fkg_cent_hora_cent (1.5) from dual;
   -- Resultado : 1.50000001
   --
   function fkg_soma_hora(en_minutos number
                         ,ed_dt1     date
                         ,ed_dt2     date) return tint; -- Retorna em Minutos
   --
   -- select pp_util.fkg_soma_hora (0,to_date('15/10/2004 16:10','dd/mm/yyyy hh24:mi'),to_date('15/10/2004 16:15','dd/mm/yyyy hh24:mi')) from dual;
   -- Resultado : 5 (Minutos)
   --
   -- select pp_util.fkg_soma_hora (4,to_date('15/10/2004 16:10','dd/mm/yyyy hh24:mi'),to_date('15/10/2004 16:15','dd/mm/yyyy hh24:mi')) from dual;
   -- Resultado : 9 (Minutos) = 5 + (4 passados como parametro)
   --
   function fkg_min_cent(en_minutos tint) return tvalor;
   -- select pp_util.fkg_min_cent (90) from dual;
   -- Resultado : 1.5
   --
   function fkg_min_hora(en_minutos tint) return tvalor;
   -- select pp_util.fkg_min_hora (90) from dual;
   -- Resultado : 1.3
   --
   function fkg_hora_cent(en_valor number) return tvalor;
   -- select pp_util.fkg_hora_cent (1.3) from dual;
   -- Resultado : 1.5
   --
   function fkg_hora_min(en_valor number) return tint;
   -- select pp_util.fkg_hora_min  (1.3) from dual;
   -- Resultado : 90
   --
   function fkg_cent_hora(en_valor number) return tvalor;
   -- select pp_util.fkg_cent_hora (1.5) from dual;
   -- Resultado : 1.3
   --
   function fkg_cent_min(en_valor number) return tint;
   -- select pp_util.fkg_cent_min (1.5) from dual;
   -- Resultado : 90
   --
   function fkg_masc_hora_hora(en_hora number) return varchar2;
   -- select pp_util.fkg_masc_hora_hora (1.3) from dual;
   -- Resultado : 1:30
   --
   function fkg_masc_min_hora(en_minutos number) return varchar2;
   -- select pp_util.fkg_masc_min_hora (90) from dual;
   -- Resultado : 1:30
   --
   function fkg_masc_cent_hora(en_valor number) return varchar2;
   -- select pp_util.fkg_masc_cent_hora (1.5) from dual;
   -- Resultado : 1:30
   --
   function fkg_dif_hora(ed_dt1    in date
                        ,ed_dt2    in date
                        ,vn_tp_ret in tnum) return number; -- 0-Minutos, 1-Horas, 2-Centesimal
   --
   function fkg_dif_min(en_min1   in tint
                       ,en_min2   in tint
                       ,vn_tp_ret in tnum) return number; -- 0-Minutos, 1-Horas, 2-Centesimal
   --
   function fkg_dif_cent(en_cent1  in tnum
                        ,en_cent2  in tnum
                        ,vn_tp_ret in tnum) return number; -- 0-Minutos, 1-Horas, 2-Centesimal
   --
   function fkg_dif_dia_hora_min(ed_dt1 in date
                                ,ed_dt2 in date) return varchar2;
   --
   function fkg_date(ed_dt in date default sysdate) return varchar2;
   --
   function fkg_date_hr(ed_dt in date default sysdate) return varchar2;
   --
   function fkg_date_hr_ss(ed_dt in date default sysdate) return varchar2;
   --
   function fkg_add_ano(ed_dt  in date default sysdate
                       ,en_ano in tint default 1) return date;
   --
   function fkg_add_mes(ed_dt  in date default sysdate
                       ,en_mes in tint default 1) return date;
   --
   function fkg_add_dia(ed_dt  in date default sysdate
                       ,en_dia in tint default 1) return date;
   --
   function fkg_add_hor(ed_dt  in date default sysdate
                       ,en_hor in tint default 1) return date;
   --
   function fkg_add_min(ed_dt  in date default sysdate
                       ,en_min in tint default 1) return date;
   --
   function fkg_add_sec(ed_dt  in date default sysdate
                       ,en_sec in tint default 1) return date;
   --

   function retqtdereq(v_desenho in varchar2
                      ,v_posicao in varchar2
                      ,v_versao  in varchar2
                      ,v_ordem   in varchar2) return number;

   function retlargurareq(v_desenho in varchar2
                         ,v_posicao in varchar2
                         ,v_versao  in varchar2) return number;

   function retcomprimentoreq(v_desenho in varchar2
                             ,v_posicao in varchar2
                             ,v_versao  in varchar2) return number;
   --
   function fnc_peso_la(p_emp  pp_listaa_itens.empresa%type
                       ,p_fil  pp_listaa_itens.filial%type
                       ,p_lst  pp_listaa_itens.listaa%type
                       ,p_prod pp_listaa_itens.produto%type) return number;

   function fnc_dtbloq(p_dt_necess date
                      ,p_ordem     in varchar2
                      ,p_titulo    in varchar2) return number;

   function fnc_sugdtbloq(p_ordem  in varchar2
                         ,p_titulo in varchar2) return date;

   function pdias(p_data    date
                 ,p_nrodias number) return date;
   --/-------------------------------------------------------------------------
   --|| Funcão para retornar proximos dias corrido atraves da data parametro.
   function pdias_c(p_data    date
                 ,p_nrodias number) return date;
                 
   function fdias(p_data    date
                 ,p_nrodias number) return date;
                 
   function fdias_c(p_data    date
                 ,p_nrodias number) return date;
                 
   function difdata(data1 date
                   ,data2 date) return number;

   function nsem(nsdatan date) return number;

   function primeirodianrosemana(anosem varchar) return date;

   function ultimodianrosemana(anosem varchar) return date;

   function desc_op(p_ord pp_ordens.ordem%type) return varchar2;

   function gera_codigo_op(p_merc number
                          ,p_ano  number) return pp_ordens.ordem%type;

   function cliente_op(p_emp pp_ordens.empresa%type
                      ,p_fil pp_ordens.filial%type
                      ,p_op  pp_ordens.ordem%type) return cd_firmas.nome%type;
   --/--------------------------------------------------------------------------
   function cliente_prop(p_emp    pp_ordens.empresa%type
                         ,p_fil   pp_ordens.filial%type
                         ,p_prop  pp_contratos.proposta%type) return cd_firmas.nome%type;
      
   --------------------------------------------------------------------------------------
   function fnc_data_carga(p_dt    date
                          ,p_carga number) return date;
   --------------------------------------------------------------------------------------
   function fnc_dias_carga(p_dt    date
                          ,p_carga number) return number;
   -----------------------------------------------------------------------------------------
   function fnc_dias_producao(p_ini date
                             ,p_fim date) return number;
   -----------------------------------------------------------------------------------------

   function desc_desenho(p_desenho pp_desenho.desenho%type) return varchar2;

   ---------------------------------------------------------------------------------------

   function fnc_nro_la(p_emp     cd_filiais.empresa%type
                      ,p_fil     cd_filiais.filial%type
                      ,p_des     pp_desenho.desenho%type
                      ,p_ver     pp_desenho_ver.versao%type
                      ,p_pos     pp_desenho_pos.posicao%type
                      ,p_num_req ce_requis.num_req%type) return varchar2;
   ----------------------------------------------------------------------------------------
   function fnc_perc_fabrica(p_id prod_cron_des.id%type) return number;
   
   ----------------------------------------------------------------------------------------
   function fnc_desenho_fabrica(p_id prod_cron_des.id%type) return pp_desenho.desenho%type;   
   -----------------------------------------------------------------------------------------
   function fnc_dt_carga_trab(p_ini   date
                             ,p_fator number) return date;

   --------------------------------------------------------------------------------------
   function fnc_qtd_desenho_estr(p_emp cd_filiais.empresa%type
                                ,p_fil cd_filiais.filial%type
                                ,p_ord pp_ordens.ordem%type
                                ,p_des pp_desenho.desenho%type) return number;

   /*
   Retorna a Qtde de desenho informada na estrutural da O.P.
   */
   ----------------------------------------------------------------------------------------
   function calceval(p_formula varchar2) return number;
   ----------------------------------------------------------------------------------------
   function fnc_cd_eap(p_id pp_eap_proj.id_eap%type)
      return pp_eap_proj.cd_eap%type;
   ----------------------------------------------------------------------------------------
   function fnc_versao_desenho(p_id pp_desenho_ver.id_desenhover%type)
      return pp_desenho_ver.versao%type;
   ----------------------------------------------------------------------------------------
   function fnc_desenho_e_versao(p_id pp_desenho_ver.id_desenhover%type)
      return tchar50;

   ------------------------------------------------------------------------------------------
   function fnc_produto_croqui(p_id pp_desenho_ver.id_desenhover%type)
      return ce_produtos.produto%type;
   ------------------------------------------------------------------------------------------------------
   function fnc_descr_produto_croqui(p_emp pp_desenho.empresa%type
                                    ,p_id  pp_desenho_ver.id_desenhover%type)
      return ce_produtos.descricao%type;

   ------------------------------------------------------------------------------------------------------
   function fnc_qtd_etiq(p_id     pp_desenho_ver.id_desenhover%type
                        ,p_qtd_pc number) return number;
   ------------------------------------------------------------------------------------------------------
   function fnc_posicao_croqui(p_id pp_desenho_ver.id_desenhover%type
                               
                               ) return number;

   function complemento(des pp_desenho.desenho%type
                       ,ver pp_desenho_ver.versao%type
                       ,pos pp_desenho_pos.posicao%type) return varchar2;

   function obs_compra(des pp_desenho.desenho%type
                      ,ver pp_desenho_ver.versao%type
                      ,pos pp_desenho_pos.posicao%type) return varchar2;
   --|---------------------------------------------------------------------------                                                                       
   function fnc_situacao(p_emp cd_filiais.empresa%type
                        ,p_fil cd_filiais.filial%type
                        ,p_con pp_ordens.contrato%type
                        ,p_op  pp_ordens.ordem%type
                        ,p_sit varchar2) return char;
   -------------------------------------------------------------------------------------
   function desc_desenho(p_desenho pp_desenho.desenho%type
                        ,p_versao  pp_desenho_ver.versao%type) return varchar2;

   --|-----------------------------------------------------------------------------
   --| retorna a Proposta da OP/OS
   --|-----------------------------------------------------------------------------
   function get_proposta_opos(p_emp pp_ordens.empresa%type
                             ,p_fil pp_ordens.filial%type
                             ,p_op pp_ordens.ordem%type) return pp_contratos.proposta%type;
  
   --|-----------------------------------------------------------------------------
   --| retorna a Peso da OP/OS
   --|-----------------------------------------------------------------------------
   function get_peso_opos(p_emp pp_ordens.empresa%type
                             ,p_fil pp_ordens.filial%type
                             ,p_op pp_ordens.ordem%type) return pp_ordens.peso%type;
  
end;
/
create or replace package body pp_util is
   --
   ----------------------------------------------------------------------------------------------
   --
   --   IDENTIFICAC?O
   --   -------------
   --   Package      : PP_UTIL
   --   Autor        : SERGIO LIMA
   --   Data criac?o : 01/01/2006
   --
   --   DEPENDENCIAS
   --   ------------
   --
   --   COMENTARIO
   --   ----------
   --
   --
   --   MANUTENC?ES
   --   -----------
   --
   ----------------------------------------------------------------------------------------------
   /*
     subtype Tnum         is number;
      subtype TValor       is number   (14,2);
      subtype TValor2      is number   (16,4);
      subtype TChar        is varchar2 (1);
      subtype TStr0        is varchar2 (1024);
      subtype TStr         is varchar2 (32767);
      subtype TCurs        is pls_integer;
      subtype TInt         is pls_integer;
      subtype TId          is number (10);
   */
   --------------------------------------------------------------------------------
   /*
   || Funcoes
   */
   --------------------------------------------------------------------------------
   procedure concat_data(e_data in date
                        ,es_hrs in out date) is
   
      v_hr varchar2(5);
   
   begin
      if e_data is not null and
         trunc(e_data) != trunc(es_hrs) then
         v_hr   := to_char(es_hrs,
                           'hh24:mi');
         es_hrs := to_date(to_char(e_data,
                                   'dd/mm/rrrr') || v_hr,
                           'dd/mm/rrrr hh24:mi');
      end if;
   
   exception
      when others then
         raise_application_error(-20001,
                                 'CONCAT_DAT:' || sqlerrm);
      
   end concat_data;

   ----------------------------------------------------------------------------------
   function max_func_dtvigen(p_emp   in cd_filiais.empresa%type
                            ,p_fil   in cd_filiais.filial%type
                            ,p_firma in cd_firmas.firma%type) return date is
   
      /*
      || Retorna a data maxima da funcao vigente para o colaborador
      */
      /*
         cursor cr is
            select max(dt_vigen)
              from pp_colabpro_func
             where empresa = p_emp
               and filial  = p_fil
               and firma   = p_firma;
      */
      v_dt date;
   
   begin
      /*
         open cr;
         fetch cr into v_dt;
         close cr;
      */
      return v_dt;
   
   end max_func_dtvigen;

   --------------------------------------------------------------------------------------

   --------------------------------------------------------------------------------------
   function horas_para_minutos(p_hora in varchar2) return number is
   
      /*
      || Retorna a  as horas da data passada em minutos
      */
   
      v_hora number;
      v_min  number;
   
   begin
      --
      begin
         v_hora := to_number(replace(p_hora,
                                     ':',
                                     ','));
      exception
         when others then
            v_hora := to_number(replace(p_hora,
                                        ':',
                                        '.'));
      end;
      --
      v_min := to_number(v_hora - trunc(v_hora)) * 100;
      v_min := v_min + (trunc(v_hora) * 60);
      return nvl(v_min,
                 0);
   exception
      when others then
         raise_application_error(-20100,
                                 'HORAS_PARA_MINUTO: Transformac?o invalida');
   end horas_para_minutos;

   --------------------------------------------------------------------------------------
   function horas_para_minutos(p_hora in date) return number is
   
      /*
      || Retorna a  as horas da data passada em minutos
      */
   
      v_hora varchar2(20);
      v_min  number;
   begin
      v_hora := to_char(p_hora,
                        'hh24:mi');
      v_min  := horas_para_minutos(v_hora);
      return nvl(v_min,
                 0);
   exception
      when others then
         raise_application_error(-20100,
                                 'HORAS_PARA_MINUTO(2): Transformac?o invalida');
   end horas_para_minutos;

   --------------------------------------------------------------------------------------
   --Function Minutos_Para_Horas( p_min in number, p_dt in date ) return varchar2

   function minutos_para_horas(p_min in number) return varchar2 is
   
      /*
      || Retorna os miuntos passados em um data com horas
      */
   
      v_hora   number;
      v_hora_c varchar2(20);
      v_min    number;
   begin
      if p_min > 0 then
         v_hora   := (p_min / 60); --
         v_min    := v_hora - trunc(v_hora);
         v_min    := round((60 * v_min));
         v_hora_c := to_char(trunc(v_hora)) || ':' ||
                     lpad(to_char(v_min),
                          2,
                          '0');
      else
         v_hora_c := null;
      end if;
   
      return v_hora_c;
   
   exception
      when others then
         raise_application_error(-20100,
                                 'MINUTOs_PARA_HORAS(1): Transformação invalida ');
   end minutos_para_horas;
   --------------------------------------------------------------------------------------
   --Function Minutos_Para_Horas( p_min in number, p_dt in date ) return date

   function minutos_para_data(p_min in number) return date is
   
      /*
      || Retorna os miuntos passados em um data com horas
      */
   
      v_hora   number;
      v_hora_c varchar2(20);
      v_ret    date;
      v_min    number;
      v_aux number(2);
   begin
      if p_min > 0 then
         v_aux := 1;
         v_hora   := (p_min / 60); --
         v_aux := 2;
         v_min    := v_hora - trunc(v_hora);
         v_aux := 3;
         v_min    := round((60 * v_min));
        v_aux := 4;         
         v_hora_c := to_char(trunc(v_hora)) || ':' ||
                     lpad(to_char(v_min),
                          2,
                          '0');
        v_aux := 5;                          
         v_ret    := to_date('01/01/2012' || v_hora_c,
                             'dd/mm/rrrrhh24:mi');
        v_aux := 6;        
      else
         v_hora_c := null;
      end if;
   
      return v_ret;
   
   exception
      when others then
         raise_application_error(-20100,
                                 'MINUTO_PARA_HORAS(2): Transformação invalida '||p_min || '  ' ||v_hora_c);
   end minutos_para_data;
   ---------------------------------------------------------------------------------------
   function dif_data(p_dt_ini in date
                    ,p_dt_fim in date) return number is
      v_hr     number;
      v_hr_ini number;
      v_hr_fim number;
      v_ret    number;
   begin
   
      v_hr     := trunc(p_dt_fim) - trunc(p_dt_ini);
      v_hr     := v_hr * 24 * 60;
      v_hr_ini := horas_para_minutos(p_dt_ini);
      v_hr_fim := horas_para_minutos(p_dt_fim) +
                  nvl(v_hr,
                      0);
      v_ret    := v_hr_fim - v_hr_ini;
      return v_ret;
   
   end dif_data;

   function dif_data_dias(p_dt_ini in date
                         ,p_dt_fim in date) return number is
      v_hr     number;
      v_hr_ini number;
      v_hr_fim number;
      v_ret    number;
   begin
      v_hr  := trunc(p_dt_fim) - trunc(p_dt_ini);
      v_ret := v_hr;
      return v_ret;
   
   end;
   -----------------------------------------------------------------------------------------
   --

   function fkg_date(ed_dt in date default sysdate) return varchar2 is
      --
      v_ret tstr;
      --
   begin
      v_ret := to_char(nvl(ed_dt,
                           sysdate),
                       'dd/mm/yyyy');
      --
      return(v_ret);
      --
   
   end fkg_date;

   --

   function fkg_date_hr(ed_dt in date default sysdate) return varchar2 is
      --
      v_ret tstr;
      --
   begin
      v_ret := to_char(nvl(ed_dt,
                           sysdate),
                       'dd/mm/yyyy hh24:mi');
      --
      return(v_ret);
      --
   
   end fkg_date_hr;

   --

   function fkg_date_hr_ss(ed_dt in date default sysdate) return varchar2 is
      --
      v_ret tstr;
      --
   begin
      v_ret := to_char(nvl(ed_dt,
                           sysdate),
                       'dd/mm/yyyy hh24:mi:ss');
      --
      return(v_ret);
      --
   
   end fkg_date_hr_ss;

   --

   function fkg_add_ano(ed_dt  in date default sysdate
                       ,en_ano in tint default 1) return date is
      --
   begin
      return(ed_dt + numtoyminterval(en_ano,
                                     'YEAR'));
   
   end fkg_add_ano;

   --

   function fkg_add_mes(ed_dt  in date default sysdate
                       ,en_mes in tint default 1) return date is
      --
   
   begin
      return(ed_dt + numtoyminterval(en_mes,
                                     'MONTH'));
   
   end fkg_add_mes;

   --

   function fkg_add_dia(ed_dt  in date default sysdate
                       ,en_dia in tint default 1) return date is
      --
   begin
      return(ed_dt + numtodsinterval(en_dia,
                                     'DAY'));
   
   end fkg_add_dia;

   --

   function fkg_add_hor(ed_dt  in date default sysdate
                       ,en_hor in tint default 1) return date is
      --
   begin
      return(ed_dt + numtodsinterval(en_hor,
                                     'HOUR'));
   
   end fkg_add_hor;

   --

   function fkg_add_min(ed_dt  in date default sysdate
                       ,en_min in tint default 1) return date is
      --
   begin
      return(ed_dt + numtodsinterval(en_min,
                                     'MINUTE'));
   
   end fkg_add_min;

   --

   function fkg_add_sec(ed_dt  in date default sysdate
                       ,en_sec in tint default 1) return date is
      --
   begin
      return(ed_dt + numtodsinterval(en_sec,
                                     'SECOND'));
   
   end fkg_add_sec;

   --

   function fkg_dif_hora(ed_dt1    in date -- Hora Inicial
                        ,ed_dt2    in date -- Hora Final
                        ,vn_tp_ret in tnum) return number is
      -- 0-Minutos, 1-Horas, 2-Centesimal
      --
      vn_minutos tnum;
      vd_dt1     date;
      vd_dt2     date;
      vn_ret     tnum;
      --
   begin
      vd_dt1 := trunc(ed_dt1,
                      'MI');
      vd_dt2 := trunc(ed_dt2,
                      'MI');
      --
      vn_minutos := round((vd_dt2 - vd_dt1) * 24 * 60);
      --
      if vn_tp_ret = 0 then
         -- Minutos
         vn_ret := vn_minutos;
      elsif vn_tp_ret = 1 then
         -- Horas
         vn_ret := fkg_min_hora(vn_minutos);
      elsif vn_tp_ret = 2 then
         -- Centesimal
         vn_ret := fkg_min_cent(vn_minutos);
      end if;
      --
      return(nvl(vn_ret,
                 0));
      --
   exception
      when others then
         if sqlcode <> -20001 then
            raise_application_error(-20001,
                                    'Erro na pp_util.FKG_DIF_HORA : ' ||
                                    sqlerrm);
         end if;
         raise;
         --
   end fkg_dif_hora;

   --

   function fkg_dif_dia_hora_min(ed_dt1 in date
                                ,ed_dt2 in date) return varchar2 is
      --
      vn_min  tint;
      vn_dia  tint;
      vn_hora tint;
      vn_ret  varchar2(30);
      vn_fase tint;
      --
   begin
      vn_fase := 1;
      --
      vn_min := fkg_dif_hora(ed_dt1,
                             ed_dt2,
                             0);
      --
      vn_fase := 2;
      --
      if vn_min < 1440 then
         vn_ret := '00000-D ';
      else
         vn_dia := trunc(vn_min / 1440);
         vn_ret := vn_ret || trim(to_char(vn_dia,
                                          '00000')) || '-D ';
         vn_min := vn_min - (vn_dia * 1440);
      end if;
      --
      vn_fase := 3;
      --
      if vn_min > 60 then
         vn_hora := trunc(fkg_min_hora(vn_min));
         vn_ret  := vn_ret || trim(to_char(vn_hora,
                                           '00')) || '-H ';
         vn_min  := vn_min - (vn_hora * 60);
      else
         vn_ret := vn_ret || '00-H ';
      end if;
      --
      vn_fase := 4;
      --
      if vn_min > 0 then
         vn_ret := vn_ret || trim(to_char(vn_min,
                                          '00')) || '-M';
      else
         vn_ret := vn_ret || '00-M';
      end if;
      --
      vn_fase := 5;
      --
      return(vn_ret);
      --
   exception
      when others then
         if sqlcode <> -20001 then
            raise_application_error(-20001,
                                    'Erro na pp_util.FKG_DIF_DIA_HORA_MIN, Fase : ' ||
                                    vn_fase || ', Erro : ' || sqlerrm);
         end if;
         raise;
         --
   end fkg_dif_dia_hora_min;
   --

   function fkg_dif_min(en_min1   in tint
                       ,en_min2   in tint
                       ,vn_tp_ret in tnum) return number is
      -- 0-Minutos, 1-Horas, 2-Centesimal
      --
      vn_minutos tnum;
      vn_ret     tnum;
      --
   begin
      vn_minutos := nvl(en_min2,
                        0) - nvl(en_min1,
                                 0);
      --
      if vn_tp_ret = 0 then
         -- Minutos
         vn_ret := vn_minutos;
      elsif vn_tp_ret = 1 then
         -- Horas
         vn_ret := fkg_min_hora(vn_minutos);
      elsif vn_tp_ret = 2 then
         -- Centesimal
         vn_ret := fkg_min_cent(vn_minutos);
      end if;
      --
      return(nvl(vn_ret,
                 0));
      --
   exception
      when others then
         if sqlcode <> -20001 then
            raise_application_error(-20001,
                                    'Erro na pp_util.FKG_DIF_MIN : ' || sqlerrm);
         end if;
         raise;
         --
   end fkg_dif_min;

   --

   function fkg_dif_cent(en_cent1  in tnum
                        ,en_cent2  in tnum
                        ,vn_tp_ret in tnum) return number is
      -- 0-Minutos, 1-Horas, 2-Centesimal
      --
      vn_minutos tnum;
      vn_ret     tnum;
      --
   begin
      vn_minutos := round(fkg_cent_min(nvl(trunc(en_cent2,
                                                 2),
                                           0) - nvl(trunc(en_cent1,
                                                          2),
                                                    0)));
      --
      if vn_tp_ret = 0 then
         -- Minutos
         vn_ret := vn_minutos;
      elsif vn_tp_ret = 1 then
         -- Horas
         vn_ret := fkg_min_hora(vn_minutos);
      elsif vn_tp_ret = 2 then
         -- Centesimal
         vn_ret := fkg_min_cent(vn_minutos);
      end if;
      --
      return(nvl(vn_ret,
                 0));
      --
   exception
      when others then
         if sqlcode <> -20001 then
            raise_application_error(-20001,
                                    'Erro na pp_util.FKG_DIF_CENT : ' ||
                                    sqlerrm);
         end if;
         raise;
         --
   end fkg_dif_cent;

   --

   function fkg_cent_hora_cent(en_valor number) return number is
      --
      v_valor tnum;
      --
   begin
      if en_valor is not null then
         v_valor := trunc(nvl(en_valor,
                              0)) +
                    ((round(mod(nvl(en_valor,
                                    0),
                                1) * 100 / gn_fator_min) * gn_fator_min) / 100);
      else
         v_valor := null;
      end if;
      --
      return(v_valor);
      --
   exception
      when others then
         if sqlcode <> -20001 then
            raise_application_error(-20001,
                                    'Erro na pp_util.FKG_CENT_HORA_CENT : ' ||
                                    sqlerrm);
         end if;
         raise;
         --
   end fkg_cent_hora_cent;

   --

   function fkg_soma_hora(en_minutos number
                         ,ed_dt1     date
                         ,ed_dt2     date) return tint is
      --
      v_minutos tint;
      --
   begin
      --
      v_minutos := fkg_dif_hora(ed_dt1,
                                ed_dt2,
                                0); -- Retonar diferenca em minutos
      --
      v_minutos := nvl(v_minutos,
                       0) + nvl(en_minutos,
                                0);
      --
      return(v_minutos); -- Retorna a Diferenca de Horas em Minutos + Minutos Passados no parametro
      --
   exception
      when others then
         raise_application_error(-20000,
                                 'Erro na pp_util.FKG_SOMA_HORA : ' || sqlerrm);
         --
   end fkg_soma_hora;

   --

   function fkg_min_cent(en_minutos tint) return tvalor is
   
      v_horas tint;
      v_minut tint;
      v_ret   tnum;
   
   begin
      v_ret := 0;
      --
      if en_minutos is not null then
         --
         if en_minutos >= 60 then
            --
            v_horas := trunc(en_minutos / 60);
            v_minut := en_minutos - (v_horas * 60);
            v_minut := trunc(v_minut * gn_fator_min);
            --
         else
            --
            v_horas := 0;
            v_minut := trunc(en_minutos * gn_fator_min);
            --
         end if;
         --
         v_ret := v_horas + (v_minut / 100);
         v_ret := fkg_cent_hora_cent(v_ret);
         --
      else
         --
         v_ret := null;
         --
      end if;
      --
      return(round(v_ret,
                   2));
      --
   exception
      when others then
         if sqlcode <> -20001 then
            raise_application_error(-20001,
                                    'Erro em pp_util.FKG_MIN_CENT : ' ||
                                    substr(sqlerrm,
                                           1,
                                           350));
         end if;
         raise;
         --
   end fkg_min_cent;

   --

   function fkg_min_hora(en_minutos tint) return tvalor is
      --
      v_horas tint;
      v_minut tint;
      v_ret   tnum;
      --
   begin
      v_ret := 0;
      --
      if en_minutos is not null then
         --
         if en_minutos >= 60 then
            --
            v_horas := trunc(en_minutos / 60);
            v_minut := en_minutos - (v_horas * 60);
            --
         else
            --
            v_horas := 0;
            v_minut := en_minutos;
            --
         end if;
         --
         v_ret := v_horas + (v_minut / 100);
         --
      else
         --
         v_ret := null;
         --
      end if;
      --
      return(round(v_ret,
                   2));
      --
   exception
      when others then
         if sqlcode <> -20001 then
            raise_application_error(-20001,
                                    'Erro em pp_util.FKG_MINUTO_HORA : ' ||
                                    substr(sqlerrm,
                                           1,
                                           350));
         end if;
         raise;
         --
   end fkg_min_hora;

   --

   function fkg_hora_cent(en_valor number) return tvalor is
      --
      v_ret tnum;
      --
   begin
      if en_valor is not null then
         v_ret := trunc(en_valor) + (mod(en_valor,
                                         1) * gn_fator_min);
         v_ret := nvl(fkg_cent_hora_cent(v_ret),
                      0);
      else
         v_ret := null;
      end if;
      --
      return(round(v_ret,
                   2));
      --
   exception
      when others then
         if sqlcode <> -20001 then
            raise_application_error(-20001,
                                    'Erro na pp_util.FKG_HORA_CENT : ' ||
                                    sqlerrm);
         end if;
         raise;
      
   end fkg_hora_cent;

   --

   function fkg_hora_min(en_valor number) return tint is
   
      v_ret tint;
   
   begin
      if en_valor is not null then
         v_ret := (trunc(en_valor) * 60) +
                  (mod(en_valor,
                       1) * 100);
      else
         v_ret := null;
      end if;
      --
      return(v_ret);
      --
   exception
      when others then
         if sqlcode <> -20001 then
            raise_application_error(-20001,
                                    'Erro na pp_util.FKG_HORA_MIN : ' ||
                                    sqlerrm);
         end if;
         raise;
         --
   end fkg_hora_min;

   --

   function fkg_cent_hora(en_valor number) return tvalor is
   
      v_ret     tnum;
      en_valor2 tnum;
      --
   begin
      if en_valor is not null then
         en_valor2 := fkg_cent_hora_cent(en_valor);
         v_ret     := trunc(en_valor) +
                      (mod(en_valor,
                           1) / gn_fator_min);
      else
         v_ret := null;
      end if;
      --
      return(round(v_ret,
                   2));
      --
   exception
      when others then
         if sqlcode <> -20001 then
            raise_application_error(-20001,
                                    'Erro na pp_util.FKG_CENT_HORA : ' ||
                                    sqlerrm);
         end if;
         raise;
      
   end fkg_cent_hora;

   --

   function fkg_cent_min(en_valor number) return tint is
   
      v_ret     tint;
      en_valor2 tnum;
      --
   begin
      if en_valor is not null then
         en_valor2 := fkg_cent_hora_cent(en_valor);
         v_ret     := (trunc(en_valor) * 60) +
                      ((mod(en_valor,
                            1) / gn_fator_min) * 100);
      else
         v_ret := null;
      end if;
      --
      return(v_ret);
      --
   exception
      when others then
         if sqlcode <> -20001 then
            raise_application_error(-20001,
                                    'Erro na pp_util.FKG_CENT_MIN : ' ||
                                    sqlerrm);
         end if;
         raise;
         --
   end fkg_cent_min;

   --

   function fkg_masc_hora_hora(en_hora number) return varchar2 is
   
      v_masc tstr0;
   
   begin
      if en_hora is not null then
         v_masc := replace(trim(to_char(trunc(abs(en_hora)),
                                        '999g999g999')) || ':' ||
                           trim(to_char(mod(abs(en_hora),
                                            1) * 100,
                                        '09')),
                           ',',
                           '.');
         if en_hora < 0 then
            v_masc := '-' || v_masc;
         end if;
      else
         v_masc := null;
      end if;
      --
      return(v_masc);
      --
   exception
      when others then
         if sqlcode <> -20001 then
            raise_application_error(-20001,
                                    'Erro em pp_util.FKG_MASC_HORA_HORA : ' ||
                                    substr(sqlerrm,
                                           1,
                                           350));
         end if;
         raise;
         --
   end fkg_masc_hora_hora;

   --

   function fkg_masc_min_hora(en_minutos number) return varchar2 is
      --
      v_masc  tstr0;
      en_hora tvalor;
      --
   begin
      if en_minutos is not null then
         en_hora := nvl(fkg_min_hora(abs(en_minutos)),
                        0);
         v_masc  := replace(trim(to_char(trunc(abs(en_hora)),
                                         '999g999g999')) || ':' ||
                            trim(to_char(mod(abs(en_hora),
                                             1) * 100,
                                         '09')),
                            ',',
                            '.');
         if en_minutos < 0 then
            v_masc := '-' || v_masc;
         end if;
      else
         v_masc := null;
      end if;
      --
      return(v_masc);
      --
   exception
      when others then
         if sqlcode <> -20001 then
            raise_application_error(-20001,
                                    'Erro em pp_util.FKG_MASC_MIN_HORA : ' ||
                                    substr(sqlerrm,
                                           1,
                                           350));
         end if;
         raise;
         --
   end fkg_masc_min_hora;

   --

   function fkg_masc_cent_hora(en_valor number) return varchar2 is
      --
      v_masc  tstr0;
      en_hora tvalor;
      --
   begin
      if en_valor is not null then
         en_hora := fkg_cent_hora(abs(en_valor));
         v_masc  := replace(trim(to_char(trunc(abs(en_hora)),
                                         '999g999g999')) || ':' ||
                            trim(to_char(mod(abs(en_hora),
                                             1) * 100,
                                         '09')),
                            ',',
                            '.');
         if en_valor < 0 then
            v_masc := '-' || v_masc;
         end if;
      else
         v_masc := null;
      end if;
      --
      return(v_masc);
      --
   exception
      when others then
         if sqlcode <> -20001 then
            raise_application_error(-20001,
                                    'Erro em pp_util.FKG_MASC_CENT_HORA : ' ||
                                    substr(sqlerrm,
                                           1,
                                           350));
         end if;
         raise;
         --
   end fkg_masc_cent_hora;

   --

   function retqtdereq(v_desenho in varchar2
                      ,v_posicao in varchar2
                      ,v_versao  in varchar2
                      ,v_ordem   in varchar2) return number is
      v_quantidade number(15,
                          2);
   
      cursor cr is
         select nvl(a.quantidade,
                    0) * nvl(b.qtde,
                             0)
           from pp_desenho_pos a
               ,pp_desenho_est b
               ,pp_desenho_ver v
               ,pp_desenho     d
               ,pp_eap_proj    eap
          where a.empresa = eap.empresa
               --     and  d.desenho = b.desenho
               --     and  v.versao  = b.versao
            and v.id_desenhover = b.id_desenhover
            and d.desenho = v_desenho
            and v.versao = v_versao
            and a.posicao = v_posicao
            and eap.opos = v_ordem
            and eap.id_eap = b.id_eap
            and a.id_desenhover is not null;
   begin
      open cr;
      fetch cr
         into v_quantidade;
      if cr%notfound then
         v_quantidade := 0;
      end if;
   
      close cr;
      return v_quantidade;
   end;

   function retlargurareq(v_desenho in varchar2
                         ,v_posicao in varchar2
                         ,v_versao  in varchar2) return number is
      v_largura number(15,
                       5);
   
      cursor cr is
         select largura
           from pp_desenho_pos
          where /*desenho = v_desenho
                                             --     and  versao  = v_versao
                                                     and  posicao = v_posicao
                                                     and */
          id_desenhover is not null;
   begin
      open cr;
      fetch cr
         into v_largura;
      if cr%notfound then
         v_largura := 0;
      end if;
      close cr;
   
      return v_largura;
   end;

   function retcomprimentoreq(v_desenho in varchar2
                             ,v_posicao in varchar2
                             ,v_versao  in varchar2) return number is
      v_comprimento number(15,
                           5);
   
      cursor cr is
         select comprimento
           from pp_desenho_pos
          where /*desenho = v_desenho
                                                     and  versao  = v_versao
                                                     and  */
          posicao = v_posicao
          and id_desenhover is not null;
   begin
      open cr;
      fetch cr
         into v_comprimento;
      if cr%notfound then
         v_comprimento := 0;
      end if;
   
      close cr;
      return v_comprimento;
   end;
   --/--------------------------------------------------------------------------
   --/ retorna total do peso de uma lista antecipada
   --/-------------------------------------------------------------------------
   function fnc_peso_la(p_emp  pp_listaa_itens.empresa%type
                       ,p_fil  pp_listaa_itens.filial%type
                       ,p_lst  pp_listaa_itens.listaa%type
                       ,p_prod pp_listaa_itens.produto%type) return number is
      v_tot number;
   begin
      select sum(g.peso_total)
        into v_tot
        from pp_listaa_itens g
       where g.empresa = p_emp
         and g.filial = p_fil
         and g.listaa = p_lst
         and g.produto = p_prod;
   
      return nvl(v_tot,
                 0);
   
   end;

   function fnc_dtbloq(p_dt_necess date
                      ,p_ordem     in varchar2
                      ,p_titulo    in varchar2) return number is
      v_aux number(9);
   begin
      select case
                when trunc(pp_util.fdias(p_dt_necess,
                                         max(b.leadtime))) <= trunc(sysdate) then
                 1
                else
                 0
             end
        into v_aux
        from prod_crondes_item a
            ,prod_cron_des     ds
            ,prod_cron         t
            ,ce_produtos       b
       where a.empresa = b.empresa
         and a.produto = b.produto
         and t.ordem = p_ordem
         and t.titulo = p_titulo
         and ds.id = a.id_prod_cron_des
         and t.id = ds.id_prod_cron;
   
      return v_aux;
   end;

   function fnc_sugdtbloq(p_ordem  in varchar2
                         ,p_titulo in varchar2) return date is
      v_aux date;
   begin
      select trunc(pp_util.pdias(sysdate,
                                 max(nvl(b.leadtime,
                                         0))))
        into v_aux
        from prod_crondes_item a
            ,prod_cron_des     ds
            ,prod_cron         t
            ,
             
             ce_produtos b
       where a.empresa = b.empresa
         and a.produto = b.produto
         and t.titulo = p_titulo
         and ds.id = a.id_prod_cron_des
         and t.id = ds.id_prod_cron;
   
      if v_aux is null then
         v_aux := trunc(sysdate) + 10;
      end if;
   
      return v_aux;
   end;

   --/--------------------------------------------------------------------------
   --/ calculo de data utilizando calendario sermatec
   --/-------------------------------------------------------------------------
   --|| Funcao para retornar dias UTEIS anteriores atraves da data parametro.
   function fdias(p_data    date
                 ,p_nrodias number) return date is
   
      cursor cr is
         select trunc(p_data - level) datas_retro
           from dual
          where lib_data.is_util(trunc(p_data - level)) = 'S'
            and rownum <= p_nrodias
         connect by level <= p_nrodias + 10
          order by 1 asc;
   
      v_data    date;
      v_nrodias number;
   
   begin
   
      if p_data is not null and
         nvl(p_nrodias,
             0) <> 0 then
      
        -- v_nrodias := p_nrodias;
         /*
            Select Data
              Into v_Data
              From (Select Rownum Linha, a.*
                      From (Select a.*
                              From Calendr a
                             Where a.Data <= p_Data
                             Order By a.Data Desc) a)
             Where Linha = v_Nrodias;
         */
         open cr;
         fetch cr into v_data;
         close cr;
         
         return v_data;
      else
         return p_data;
      end if;
   end;
   --|| Funcao para retornar dias CORRIDO anteriores atraves da data parametro.
   function fdias_c(p_data    date
                 ,p_nrodias number) return date is
   
      cursor cr is
         select trunc(P_data - level) datas_retro
           from dual
          where rownum <= p_nrodias
         connect by level <= p_nrodias + 10
          order by 1 asc;
   
      v_data    date;
      v_nrodias number;
   
   begin
   
      if p_data is not null and
         nvl(p_nrodias,
             0) <> 0 then
      
        -- v_nrodias := p_nrodias;
         /*
            Select Data
              Into v_Data
              From (Select Rownum Linha, a.*
                      From (Select a.*
                              From Calendr a
                             Where a.Data <= p_Data
                             Order By a.Data Desc) a)
             Where Linha = v_Nrodias;
         */
         open cr;
         fetch cr into v_data;
         close cr;
         
         return v_data;
      else
         return p_data;
      end if;
   end;
   --/-------------------------------------------------------------------------
   --|| Func?o para retornar proximos dias uteis atraves da data parametro.
   function pdias(p_data    date
                 ,p_nrodias number) return date is

     cursor cr is
       select trunc(p_data + level) datas_retro
         from dual
        where lib_data.is_util(trunc(p_data + level)) = 'S'
          and rownum <= p_nrodias
       connect by level <= p_nrodias + 10
        order by 1 desc;
          
      v_data    date;
      v_nrodias number;
   
   begin
   
      if p_data is not null and
         nvl(p_nrodias,
             0) <> 0 then
      /*
         v_nrodias := p_nrodias;
      
         select data
           into v_data
           from (select rownum linha
                       ,a.*
                   from (select a.*
                           from calendr a
                          where a.data > p_data
                          order by a.data) a)
          where linha = v_nrodias;
      */
       open cr;
         fetch cr into v_data;
         close cr;
         
         return v_data;
      else
         return p_data;
      end if;
   EXCEPTION
     WHEN OTHERS THEN
          return p_data;    
   end;
   
   --/-------------------------------------------------------------------------
   --|| Funcão para retornar proximos dias corrido atraves da data parametro.
   function pdias_c(p_data    date
                 ,p_nrodias number) return date is

     cursor cr is
       select trunc(p_data + level) datas_retro
         from dual
        where rownum <= p_nrodias
       connect by level <= p_nrodias + 10
        order by 1 desc;
          
      v_data    date;
      v_nrodias number;
   
   begin
   
      if p_data is not null and
         nvl(p_nrodias,
             0) <> 0 then
      /*
         v_nrodias := p_nrodias;
      
         select data
           into v_data
           from (select rownum linha
                       ,a.*
                   from (select a.*
                           from calendr a
                          where a.data > p_data
                          order by a.data) a)
          where linha = v_nrodias;
      */
       open cr;
         fetch cr into v_data;
         close cr;
         
         return v_data;
      else
         return p_data;
      end if;
   end;
   --/-------------------------------------------------------------------------
   function difdata(data1 date
                   ,data2 date) return number is
      v_aux number(9);
   begin
      v_aux := 0;
      if (data1 is not null) and
         (data2 is not null) then
         select count(data)
           into v_aux
           from calendr
          where data >= data1
            and data <= data2;
      else
         v_aux := 0;
      end if;
   
      return v_aux;
   
   end;

   --/-------------------------------------------------------------------------
   --/NSem Retorna o numero da semana de uma determinada data
   function nsem(nsdatan date) return number is
      nsdata1  varchar2(10);
      dsx      varchar2(10);
      ndia0101 varchar2(10);
      nsvalor  number(9,
                      2);
      nsvalor1 number(9,
                      2);
      nsvalor2 number(9);
      vlaux    number(9);
      nsemx    number(9);
      ano      number(9);
      mes      number(9);
      dia      number(9);
      nsdatanx date;
   
   begin
      nsdatanx := nsdatan;
   
      dia := to_char(nsdatanx,
                     'dd');
      mes := to_char(nsdatanx,
                     'mm');
      ano := to_char(nsdatanx,
                     'YYYY');
   
      if ((mes = 1) and (dia > 4)) or
         (mes > 1) then
         if to_char(to_date(nsdatanx),
                    'DY') = 'DOM' then
            nsdatanx := nsdatanx + 3;
         end if;
         if to_char(to_date(nsdatanx),
                    'DY') = 'SEG' then
            nsdatanx := nsdatanx + 2;
         end if;
         if to_char(to_date(nsdatanx),
                    'DY') = 'TER' then
            nsdatanx := nsdatanx + 1;
         end if;
         if to_char(to_date(nsdatanx),
                    'DY') = 'QUA' then
            nsdatanx := nsdatanx - 1;
         end if;
         if to_char(to_date(nsdatanx),
                    'DY') = 'QUI' then
            nsdatanx := nsdatanx - 2;
         end if;
         if to_char(to_date(nsdatanx),
                    'DY') = 'SEX' then
            nsdatanx := nsdatanx - 3;
         end if;
      end if;
   
      nsdata1 := '01/01/' || ano;
      --NSValor  := (pp_util.DifData(NSDataNX,NSData1) + 1) / 7;
      select (pp_util.difdata(nsdata1,
                              nsdatanx) + 1) / 7
        into nsvalor
        from dual;
   
      nsvalor1 := round(nsvalor);
   
      if ((nsvalor - nsvalor1) > 0) or
         (nsvalor = 0) then
         nsemx := round(nsvalor1) + 1;
      else
         nsemx := round(nsvalor1);
      end if;
   
      return nsemx;
   
   end;

   --/-------------------------------------------------------------------------
   function primeirodianrosemana(anosem varchar) return date is
   
      cursor cr is
         select data
           from calendr
          where to_char(data,
                        'yy') = substr(anosem,
                                       1,
                                       2)
            and pp_util.nsem(data) = substr(anosem,
                                            3,
                                            2)
          order by data;
   
      v_aux date;
   begin
      open cr;
      fetch cr
         into v_aux;
      close cr;
   
      return v_aux;
   end;

   function ultimodianrosemana(anosem varchar) return date is
      cursor cr is
         select data
           from calendr
          where to_char(data,
                        'yy') = substr(anosem,
                                       1,
                                       2)
            and pp_util.nsem(data) = substr(anosem,
                                            3,
                                            2)
          order by data desc;
   
      v_aux date;
   begin
      open cr;
      fetch cr
         into v_aux;
      close cr;
   
      return v_aux;
   
   end;
   ---------------------------------------------------------------------------------------
   procedure pp_limpa(e_ord in pp_ordens.ordem%type) is
   
      cursor cr is
         select c.rowid
               ,c.produto
               ,b.ordem
               ,c.num_req
               ,c.item_req
               ,decode(nvl(c.qtde_aprovada,
                           0),
                       0,
                       nvl(c.qtde_req,
                           0),
                       c.qtde_aprovada) qtde
               ,decode(nvl(c.qtde_aprovada,
                           0),
                       0,
                       nvl(c.qtde_req,
                           0),
                       c.qtde_aprovada) - nvl(c.qtde_entregue,
                                              0) -
                nvl(c.qtde_cancel,
                    0) saldo_req
               ,a.tipo
               ,nvl(ce_saldo_utl.custo_medio(1,
                                             1,
                                             c.produto,
                                             sysdate),
                    0) custo_medio
               ,c.qtde_cancel
           from ce_produtos  d
               ,pp_ordens    b
               ,ce_itens_req c
               ,ce_requis    a
          where b.empresa = a.empresa
            and b.filial = a.filial
            and b.ordem = a.opos
            and d.empresa = c.empresa
            and d.produto = c.produto
            and c.empresa = a.empresa
            and
               -- b.status in('A','P')             and
                c.filial = a.filial
            and c.num_req = a.num_req
            and a.empresa = 1
            and a.filial = 1
            and a.tipo in ('B')
            and decode(nvl(c.qtde_aprovada,
                           0),
                       0,
                       nvl(c.qtde_req,
                           0),
                       c.qtde_aprovada) - nvl(c.qtde_entregue,
                                              0) -
                nvl(c.qtde_cancel,
                    0) > 0
            and b.ordem = e_ord;
      v_aux number;
   begin
   
      for reg in cr loop
         update ce_itens_req k
            set k.qtde_cancel = nvl(k.qtde_cancel,
                                    0) + nvl(reg.saldo_req,
                                             0)
          where rowid = reg.rowid;
         v_aux := nvl(reg.qtde_cancel,
                      0) + nvl(reg.saldo_req,
                               0);
         /*   Insert into PP_LOG_DESBLOQ (SEQ ,
                ORDEM   ,
                NUMREQ   ,
                ITEMREQ  ,
                QTD)
         values(
                PP_LOG_DESBLOQ_SEQ.nextval,
                reg.ordem,
                reg.num_req,
                reg.item_req,
                v_aux);*/
      
      end loop;
   
      commit;
   end pp_limpa;

   --------------------------------------------------------------------------------------
   --RETORNA CLIENTE DA OP
   --------------------------------------------------------------------------------------
   function op_cliente(p_ord pp_ordens.ordem%type) return varchar2 is
      v_des varchar2(50);
   begin
      select distinct cd.nome
        into v_des
        from pp_contratos pc
            ,cd_firmas    cd
            ,pp_ordens    od
       where cd.firma = pc.firma
         and pc.contrato = od.contrato
         and pc.empresa = od.empresa
         and od.ordem = p_ord;
   
      return v_des;
   
   end;

   --------------------------------------------------------------------------------------
   function desc_op(p_ord pp_ordens.ordem%type) return varchar2 is
   
      /*
      Retorna a descric?o da O.P.
      */
   
      cursor cr_op is
         select descricao
           from pp_ordens
          where ordem = p_ord
            and empresa = 1
            and filial = 1;
   
      v_des varchar2(200);
   
   begin
   
      open cr_op;
      fetch cr_op
         into v_des;
      close cr_op;
   
      return v_des;
   
   end;
   --------------------------------------------------------------------------------------
   function gera_codigo_op(p_merc number
                          ,p_ano  number) return pp_ordens.ordem%type is
      v_max  number(4);
      v_ret  pp_ordens.ordem%type;
      v_ano  varchar2(2);
      v_masc varchar2(30) := '9.99.999';
   
   begin
      if length(to_char(p_ano)) > 2 then
         v_ano := substr(p_ano,
                         -2);
      else
         v_ano := lpad(to_char(p_ano),
                       2,
                       '0');
      end if;
   
      select max(substr(a.ordem,
                        6,
                        3)) seq_op
        into v_max
        from pp_ordens a
       where lib_cniv.cod_hash(substr(a.ordem,
                                      1,
                                      5)) = p_merc || v_ano;
   
      v_max := nvl(v_max,
                   0) + 1;
   
      v_ret := p_merc || v_ano || lpad(v_max,
                                       3,
                                       '0'); -- p_merc||'.'||v_ano||'.'|| lpad(v_max,3,'0');
      v_ret := lib_cniv.mascara(v_ret,
                                v_masc);
      return v_ret;
   exception
      when others then
         return p_merc || '.' || v_ano || '.' || '000';
   end;
   --/--------------------------------------------------------------------------
   function cliente_op(p_emp pp_ordens.empresa%type
                      ,p_fil pp_ordens.filial%type
                      ,p_op  pp_ordens.ordem%type) return cd_firmas.nome%type is
      cursor cr is
         select f.nome
           from pp_ordens    a
               ,pp_contratos b
               ,cd_firmas    f
          where f.firma = b.firma
            and b.empresa = a.empresa
            and b.contrato = a.contrato
            and a.empresa = p_emp
            and a.filial = p_fil
            and a.ordem = p_op;
   
      v_ret cd_firmas.nome%type;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   end;
   --/--------------------------------------------------------------------------
   function cliente_prop(p_emp    pp_ordens.empresa%type
                         ,p_fil   pp_ordens.filial%type
                         ,p_prop  pp_contratos.proposta%type) return cd_firmas.nome%type is
      cursor cr is
         select f.nome
           from pp_contratos b
               ,cd_firmas    f
          where f.firma = b.firma
            and b.empresa = p_emp
            and b.proposta = p_prop;
   
      v_ret cd_firmas.nome%type;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   end;   
   --/--------------------------------------------------------------------------
   function codigo_cliente_op(p_emp pp_ordens.empresa%type
                      ,p_fil pp_ordens.filial%type
                      ,p_op  pp_ordens.ordem%type) return cd_firmas.firma%type is
      cursor cr is
         select f.firma
           from pp_ordens    a
               ,pp_contratos b
               ,cd_firmas    f
          where f.firma = b.firma
            and b.empresa = a.empresa
            and b.contrato = a.contrato
            and a.empresa = p_emp
            and a.filial = p_fil
            and a.ordem = p_op;
   
      v_ret cd_firmas.firma%type;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   end;  
   
   --/--------------------------------------------------------------------------
   function codigo_cliente_prop(p_emp   pp_ordens.empresa%type
                               ,p_fil   pp_ordens.filial%type
                               ,p_prop  pp_contratos.proposta%type) return cd_firmas.firma%type is
      cursor cr is
         select f.firma
           from pp_contratos b
               ,cd_firmas    f
          where f.firma = b.firma
            and b.empresa = p_emp
            and b.proposta = p_prop;
   
      v_ret cd_firmas.firma%type;
   
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   end;        
   ---------------------------------------------------------------------------------------
   --------------------------------------------------------------------------------------
   function fnc_data_carga(p_dt    date
                          ,p_carga number) return date is
      v_carga_dia number;
      v_ret       date;
      v_dias      number(10);
   begin
      v_carga_dia := 8 * 60; --pp_fabrica_utl.carga_dia ( 1);
      v_dias      := ceil(p_carga * 60 / v_carga_dia);
      v_dias      := v_dias - 1; --/ retira 1 devido a funcao pdias
      v_ret       := pp_util.pdias(p_dt,
                                   v_dias);
      return v_ret;
   end;
   --------------------------------------------------------------------------------------
   function fnc_dias_carga(p_dt    date
                          ,p_carga number) return number is
      v_carga_dia number;
      v_ret       number;
      v_dias      number(10);
   begin
      v_carga_dia := 8 * 60; --pp_fabrica_utl.carga_dia ( 1);
      v_dias      := ceil(p_carga * 60 / v_carga_dia);
      v_ret       := v_dias;
   
      return v_ret;
   end;

   -----------------------------------------------------------------------------------------
   function fnc_dias_producao(p_ini date
                             ,p_fim date) return number is
      cursor cr is
         select count(a.data)
           from calendr a
          where a.data between p_ini and p_fim;
      v_ret number;
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
      return nvl(v_ret,
                 0);
   end;

   ---------------------------------------------------------------------------------------------
   --------------------------------------------------------------------------------------
   function desc_desenho(p_desenho pp_desenho.desenho%type) return varchar2 is
   
      /*
      Retorna a descric?o do Desenho
      */
   
      cursor cr_op is
         select descricao
           from pp_desenho a
          where a.empresa = 1
            and desenho = p_desenho;
   
      v_des varchar2(2000);
   
   begin
   
      open cr_op;
      fetch cr_op
         into v_des;
      close cr_op;
   
      return v_des;
   
   end;
   ------------------------------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------

   function fnc_nro_la(p_emp     cd_filiais.empresa%type
                      ,p_fil     cd_filiais.filial%type
                      ,p_des     pp_desenho.desenho%type
                      ,p_ver     pp_desenho_ver.versao%type
                      ,p_pos     pp_desenho_pos.posicao%type
                      ,p_num_req ce_requis.num_req%type) return varchar2 is
      cursor cr_la is
         select listaa
           from ce_itens_la_req
          where empresa = p_emp
            and filial = p_fil
            and desenho = p_des
            and versao = p_ver
            and posicao = p_pos
            and num_req = p_num_req;
   
      v_la  varchar2(2000);
      v_nro number;
   begin
      v_la  := null;
      v_nro := 0;
      for reg in cr_la loop
         if v_nro > 0 then
            v_la := v_la || ',' || reg.listaa;
         else
            v_la := v_la || reg.listaa;
         end if;
         v_nro := v_nro + 1;
      end loop;
   
      return v_la;
   end;
   ------------------------------------------------------------------------------------------------
   --------------------------------------------------------------------------------------
   function fnc_perc_fabrica(p_id prod_cron_des.id%type) return number is
      cursor cr is
         select b.per_concl
           from prod_cron_des         a
               ,prod_fabrica_cron_des c
               ,prod_fabricacao       b
          where b.id = c.id_prod_fabricacao
            and c.id_prod_cron_des = a.id
            and a.id = p_id;
   
      v_ret number(12,
                   3);
   
   begin
   
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
   
   end;
   
   ----------------------------------------------------------------------------------------
   function fnc_desenho_fabrica(p_id prod_cron_des.id%type) return pp_desenho.desenho%type is

   cursor cr is
     select des.desenho
       from prod_fabricacao pf
          , pp_desenho_ver ver
          , pp_desenho des
       where pf.id = p_id
         and ver.id_desenhover = pf.id_desenhover
         and des.id_desenho = ver.id_desenho;
       
   v_ret pp_desenho.desenho%type;
   
   begin
   
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   end;
   -----------------------------------------------------------------------------------------
   --| retorna uma data conforme o numero de horas passada no fator
   --| considerando a carga diaria de trabalho
   function fnc_dt_carga_trab(p_ini   date
                             ,p_fator number) return date is
      v_ret      date;
      v_aux      number;
      v_carga_hr number := 8;
   begin
      v_aux := ceil(p_fator / v_carga_hr);
   
      if v_aux > 0 then
         v_aux := v_aux - 1;
      end if;
   
      v_ret := p_ini + v_aux;
   
      return v_ret;
   end;

   --------------------------------------------------------------------------------------
   function fnc_qtd_desenho_estr(p_emp cd_filiais.empresa%type
                                ,p_fil cd_filiais.filial%type
                                ,p_ord pp_ordens.ordem%type
                                ,p_des pp_desenho.desenho%type) return number is
   
      /*
      Retorna a Qtde de desenho informada na estrutural da O.P.
      */
      cursor cr is
         select b.qtde quantidade
           from pp_desenho     a
               ,pp_desenho_est b
               ,pp_desenho_ver v
          where a.empresa = p_emp
            and a.filial = p_fil
            and a.desenho = p_des
            and v.id_desenho = a.id_desenho
            and b.id_desenhover = v.id_desenhover
            and b.ordem = p_ord
            and v.versao =
                (select max(v2.versao)
                   from pp_desenho_est b2
                       ,pp_desenho_ver v2
                  where b2.empresa = b.empresa
                    and b2.filial = b.filial
                    and b2.ordem = b.ordem
                    and v2.id_desenho = a.id_desenho
                    and v2.id_desenhover = b2.id_desenhover);
      --/
      v_ret number;
      --/
   begin
      --/
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
      --/
   end;

   ----------------------------------------------------------------------------------------
   function calceval(p_formula varchar2) return number is
   
      aux  varchar2(200);
      calc varchar2(200);
      tot  number;
      a    number;
      j    number;
   begin
      aux := p_formula;
      j   := 1;
      --    tot := 0;
      if aux is not null then
         for a in 1 .. length(aux) loop
            if substr(aux,
                      a,
                      1) = '+' then
               j    := a + 1;
               calc := nvl(substr(aux,
                                  j,
                                  instr(substr(aux,
                                               j),
                                        '+') - 1),
                           0);
               tot  := nvl(tot,
                           0) + to_number(calc);
            end if;
            if substr(aux,
                      a,
                      1) = '*' then
               j    := a + 1;
               calc := nvl(substr(aux,
                                  j,
                                  instr(substr(aux,
                                               j),
                                        '*') - 1),
                           1);
               tot  := nvl(tot,
                           1) * to_number(calc);
            end if;
         end loop;
      end if;
   
      return nvl(tot,
                 0);
   
   exception
      when others then
         begin
            return 0;
         end;
      
   end;

   ----------------------------------------------------------------------------------------
   function fnc_cd_eap(p_id pp_eap_proj.id_eap%type)
      return pp_eap_proj.cd_eap%type is
      cursor cr is
         select cd_eap from pp_eap_proj where id_eap = p_id;
   
      v_ret pp_eap_proj.cd_eap%type;
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
      return v_ret;
   end;

   ----------------------------------------------------------------------------------------
   function fnc_versao_desenho(p_id pp_desenho_ver.id_desenhover%type)
      return pp_desenho_ver.versao%type is
      cursor cr is
         select versao from pp_desenho_ver where id_desenhover = p_id;
   
      v_ret pp_desenho_ver.versao%type;
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
      return v_ret;
   end;
   ----------------------------------------------------------------------------------------
   function fnc_desenho_e_versao(p_id pp_desenho_ver.id_desenhover%type)
      return tchar50 is
      cursor cr is
         select d.desenho || '-' || versao
           from pp_desenho_ver v
               ,pp_desenho     d
          where id_desenhover = p_id
            and d.id_desenho = v.id_desenho;
   
      v_ret varchar2(50);
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
      return v_ret;
   end;

   ------------------------------------------------------------------------------------------------------
   function fnc_produto_croqui(p_id pp_desenho_ver.id_desenhover%type)
      return ce_produtos.produto%type is
      cursor cr is
         select po.pos_produto
               ,d.produto
               ,count(posicao) over() conta
           from pp_desenho_ver v
               ,pp_desenho_pos po
               ,pp_desenho     d
          where po.id_desenhover = v.id_desenhover
            and d.id_desenho = v.id_desenho
            and v.id_desenhover = p_id
         -- group by po.pos_produto
         --   ,  d.produto
         ;
   
      v_prd   number(9);
      v_prd_d number(9);
      v_conta number;
   
   begin
      open cr;
      fetch cr
         into v_prd
             ,v_prd_d
             ,v_conta;
      close cr;
   
      if nvl(v_conta,
             0) > 1 then
         return v_prd_d;
      elsif nvl(v_conta,
                0) = 1 then
         return v_prd;
      else
         return 0;
      end if;
   end;
   ------------------------------------------------------------------------------------------------------
   function fnc_descr_produto_croqui(p_emp pp_desenho.empresa%type
                                    ,p_id  pp_desenho_ver.id_desenhover%type)
      return ce_produtos.descricao%type is
      cursor cr is
         select po.pos_produto
               ,d.produto
               ,count(posicao) over() conta
           from pp_desenho_ver v
               ,pp_desenho_pos po
               ,pp_desenho     d
          where po.id_desenhover = v.id_desenhover
            and d.id_desenho = v.id_desenho
            and v.id_desenhover = p_id
         --po.pos_produto
         --,  d.produto
         ;
   
      v_prd   number(9);
      v_prd_d number(9);
      v_conta number;
   
   begin
      open cr;
      fetch cr
         into v_prd
             ,v_prd_d
             ,v_conta;
      close cr;
   
      if nvl(v_conta,
             0) > 1 then
         return ce_produtos_utl.descricao(p_emp,
                                          v_prd_d);
      elsif nvl(v_conta,
                0) = 1 then
         return ce_produtos_utl.descricao(p_emp,
                                          v_prd);
      else
         return 'Não encontrado';
      end if;
   end;

   ------------------------------------------------------------------------------------------------------
   function fnc_qtd_etiq(p_id     pp_desenho_ver.id_desenhover%type
                        ,p_qtd_pc number) return number is
      cursor cr is
         select d.produto
               ,po.quantidade
               ,count(posicao) over() conta
           from pp_desenho_ver v
               ,pp_desenho_pos po
               ,pp_desenho     d
          where po.id_desenhover = v.id_desenhover
            and d.id_desenho = v.id_desenho
            and v.id_desenhover = p_id
         --po.pos_produto
         --,  d.produto
         ;
   
      v_prd   number(9);
      v_qtd   number;
      v_conta number;
   
   begin
      open cr;
      fetch cr
         into v_prd
             ,v_qtd
             ,v_conta;
      close cr;
   
      if nvl(v_conta,
             0) > 1 then
         return p_qtd_pc;
      elsif nvl(v_conta,
                0) = 1 then
         return p_qtd_pc * v_qtd;
      else
         return p_qtd_pc;
      end if;
   
   exception
      when others then
         return p_qtd_pc;
   end;

   ------------------------------------------------------------------------------------------------------
   function fnc_posicao_croqui(p_id pp_desenho_ver.id_desenhover%type
                               
                               ) return number is
      cursor cr is
         select d.produto
               ,po.posicao
               ,count(posicao) over() conta
           from pp_desenho_ver v
               ,pp_desenho_pos po
               ,pp_desenho     d
          where po.id_desenhover = v.id_desenhover
            and d.id_desenho = v.id_desenho
            and v.id_desenhover = p_id
         --po.pos_produto
         --,  d.produto
         ;
   
      v_prd   number(9);
      v_pos   number;
      v_conta number;
   
   begin
      open cr;
      fetch cr
         into v_prd
             ,v_pos
             ,v_conta;
      close cr;
   
      if nvl(v_conta,
             0) > 1 then
         return 0;
      elsif nvl(v_conta,
                0) = 1 then
         return v_pos;
      else
         return 0;
      end if;
   
   exception
      when others then
         return 0;
   end;

   --------------------------------------------------------------------------------------
   --RETORNA COMPLEMENTO DA POSICAO DO DESENHO
   --------------------------------------------------------------------------------------
   function complemento(des pp_desenho.desenho%type
                       ,ver pp_desenho_ver.versao%type
                       ,pos pp_desenho_pos.posicao%type) return varchar2 is
   
      cursor cr_posicao is
         select p.obs_engenh
           from pp_desenho_pos p
               ,pp_desenho_ver v
               ,pp_desenho     d
          where d.desenho = des
            and v.versao = ver
            and p.posicao = pos
            and v.id_desenhover = p.id_desenhover
            and d.id_desenho = v.id_desenho;
   
      v_complemento pp_desenho_pos.obs_compra%type;
   
   begin
   
      open cr_posicao;
      fetch cr_posicao
         into v_complemento;
      close cr_posicao;
   
      return v_complemento;
   
   end;

   --------------------------------------------------------------------------------------
   --RETORNA obs_compra DA POSICAO DO DESENHO
   --------------------------------------------------------------------------------------
   function obs_compra(des pp_desenho.desenho%type
                      ,ver pp_desenho_ver.versao%type
                      ,pos pp_desenho_pos.posicao%type) return varchar2 is
   
      cursor cr_posicao is
         select p.obs_compra
           from pp_desenho_pos p
               ,pp_desenho_ver v
               ,pp_desenho     d
          where d.desenho = des
            and v.versao = ver
            and p.posicao = pos
            and v.id_desenhover = p.id_desenhover
            and d.id_desenho = v.id_desenho;
   
      v_complemento pp_desenho_pos.obs_compra%type;
   
   begin
   
      open cr_posicao;
      fetch cr_posicao
         into v_complemento;
      close cr_posicao;
   
      return v_complemento;
   
   end;
   --|-------------------------------------------------------------           
   function fnc_situacao(p_emp cd_filiais.empresa%type
                        ,p_fil cd_filiais.filial%type
                        ,p_con pp_ordens.contrato%type
                        ,p_op  pp_ordens.ordem%type
                        ,p_sit varchar2) return char is
      cursor cr is
         select case
                   when p_sit = 'COMPRA' then
                    b.lib_compra
                   when p_sit = 'FABRICA' then
                    b.lib_fabrica
                   when p_sit = 'MONTAG' then
                    b.lib_montag
                   when p_sit = 'FINAN' then
                    b.lib_financ
                   when p_sit = 'PLAN' then
                    b.lib_planej
                   when p_sit = 'ESTOQUE' then
                    b.lib_estoque
                   when p_sit = 'EXPED' then
                    b.lib_exped
                   when p_sit = 'ADT' then
                    b.lib_adt
                   else
                    'N'
                end sit
           from pp_contratos     a
               ,pp_situacao_proj b
          where a.empresa = p_emp
            and a.contrato = p_con
            and b.situacao = a.situacao;
   
      cursor cr2 is
         select case
                   when p_sit = 'COMPRA' then
                    b.lib_compra
                   when p_sit = 'FABRICA' then
                    b.lib_fabrica
                   when p_sit = 'MONTAG' then
                    b.lib_montag
                   when p_sit = 'FINAN' then
                    b.lib_financ
                   when p_sit = 'PLAN' then
                    b.lib_planej
                   when p_sit = 'ESTOQUE' then
                    b.lib_estoque
                   when p_sit = 'EXPED' then
                    b.lib_exped
                   when p_sit = 'ADT' then
                    b.lib_adt
                   else
                    'N'
                end sit
           from pp_ordens        a
               ,pp_situacao_proj b
          where a.empresa = p_emp
            and a.filial = p_fil
            and a.ordem = p_op
            and b.situacao = a.situacao;
      v_ret varchar2(1);
   
   begin
   
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      if p_op is not null and
         v_ret is not null and
         v_ret != 'N' then
      
         open cr2;
         fetch cr2
            into v_ret;
         close cr2;
      else
         v_ret := 'N';
      end if;
   
      return v_ret;
   
   end;
   --|----------------------------------------------------
   -------------------------------------------------------------------------------------
   function desc_desenho(p_desenho pp_desenho.desenho%type
                        ,p_versao  pp_desenho_ver.versao%type) return varchar2 is
   
      /*
      Retorna a descric?o do Desenho
      */
   
      cursor cr_op is
         select d.descricao
           from pp_desenho     d
               ,pp_desenho_ver v
          where d.empresa = 1
            and d.filial = 1
            and d.desenho = p_desenho
            and v.versao = p_versao
            and d.id_desenho = v.id_desenho;
   
      v_des varchar2(2000);
   
   begin
   
      open cr_op;
      fetch cr_op
         into v_des;
      close cr_op;
   
      return v_des;
   
   end;

   --|-----------------------------------------------------------------------------
   --| retorna a Proposta da OP/OS
   --|-----------------------------------------------------------------------------
   function get_proposta_opos(p_emp pp_ordens.empresa%type
                             ,p_fil pp_ordens.filial%type
                             ,p_op pp_ordens.ordem%type) return pp_contratos.proposta%type is
   cursor cr is
        select pc.proposta
          from pp_contratos pc
             , pp_ordens  po
         where pc.empresa = po.empresa
           and pc.contrato = po.contrato
           and po.empresa = p_emp
           and po.filial = p_fil
           and po.ordem = p_op;
   
   v_ret pp_contratos.proposta%type;
   
   begin
     open cr;
     fetch cr into v_ret;
     close cr;
     
     return v_ret;
     
   end;
   
   --|-----------------------------------------------------------------------------
   --| retorna a Peso da OP/OS
   --|-----------------------------------------------------------------------------
   function get_peso_opos(p_emp pp_ordens.empresa%type
                             ,p_fil pp_ordens.filial%type
                             ,p_op pp_ordens.ordem%type) return pp_ordens.peso%type is
   cursor cr is
        select po.peso
          from pp_ordens  po
         where po.empresa = p_emp
           and po.filial = p_fil
           and po.ordem = p_op;
   
   v_ret pp_ordens.peso%type;
   
   begin
     open cr;
     fetch cr into v_ret;
     close cr;
     
     return v_ret;
     
   end;   
end pp_util;
/
