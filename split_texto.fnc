create or replace function split_texto(p_texto       varchar2
                                      ,p_delimitador varchar2) return t_row
   pipelined is

   v_expressao varchar2(100) := '[^' || p_delimitador || ']+';
   curopen     sys_refcursor;
   vt_texto    dbms_sql.varchar2_table;

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

   for i in 1 .. vt_texto.last loop
      pipe row(vt_texto(i));
   
   end loop;

   return;

end;
/
