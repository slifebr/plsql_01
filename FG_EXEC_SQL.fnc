CREATE OR REPLACE FUNCTION FG_EXEC_SQL
 (E_COMANDO IN VARCHAR2
 )
 RETURN INTEGER
 IS
  nCursor  INTEGER;
  nLinhas  INTEGER;
begin
--     Não esquecer de tratar erros na chamada da função com Begin e Exception
--          Ex.:    begin
--                     fg_exec_sql('select 1 from dual');
--                  exception
--                     when others then
--                  end;
  /* Abrir o cursor */
  nCursor := dbms_sql.open_cursor;
  if (dbms_sql.is_open(nCursor)) then
      dbms_sql.parse( nCursor, e_comando, dbms_sql.NATIVE );
      nLinhas := dbms_sql.execute( nCursor );
  end if;
  /* Fechar o cursor */
  dbms_sql.close_cursor( nCursor );
  return  nLinhas;
end FG_EXEC_SQL;
/
