CREATE OR REPLACE FUNCTION FG_GET_LINE_ERROR (ev_local   in varchar2
                           ,ev_msg_usu in varchar2
                           ,ev_msg_ora in varchar2) return varchar2 IS


--
----------------------------------------------------------------------------------------------
--
--   IDENTIFICAÇÃO
--   -------------
--   Package      : FG_GET_LINE_ERROR
--   Autor        : Edson Gonçalez/Marcio Gonçalez
--   Data criação : 23/08/2016
--
--   DEPENDÊ NCIAS
--   ------------
--
--   COMENTÁRIO
--   ----------
--
----------------------------------------------------------------------------------------------
--
-- $$plsql_unit
-- $$plsql_line
--
----------------------------------------------------------------------------------------------
--

/*
   MANUTENÇÕES
   -----------

   -------------------------------------------------------------------------------------
   ---DATA---   PROGRAMADOR --VERSÃO-- -----------------DESCRIÇÃO-----------------------
   -------------------------------------------------------------------------------------
   23/08/2016   Sergio         1.0        Criação da funcao

*/
--|-------------------------------------------------------------------------------------
--| Variáveis Globais
--|-------------------------------------------------------------------------------------
v_m           varchar2 (4000) := dbms_utility.format_error_backtrace;
v_n1          varchar2 (10);
--
vv_linha      varchar2 (10);
vv_mensagem   varchar2 (4000);
--

BEGIN
   v_m  := replace(v_m,chr(10),null);
   v_m  := replace(v_m,chr(13),null);
--
   v_n1 := trim(substr(v_m,instr(v_m,' ', -1),length(v_m)));
--
   if v_n1 is not null and length( v_n1 ) > 0 then
      vv_linha := v_n1;
   else
      vv_linha := null;
   end if;
--
   vv_mensagem := 'Erro na ' || ev_local;
--
   if vv_linha is not null then
      vv_mensagem := vv_mensagem || ', Linha: ' || vv_linha;
   end if;
--
   if ev_msg_usu is not null then
      vv_mensagem := vv_mensagem || ', ' || ev_msg_usu;
   end if;
--
   if ev_msg_ora is not null then
      vv_mensagem := vv_mensagem || ', ' || ev_msg_ora;
   end if;
--
   return (vv_mensagem);
--
END FG_GET_LINE_ERROR;
/
