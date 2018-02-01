create or replace function pipe_meses return TMeses
pipelined is

lista TMeses := TMeses(1,2,3,4,5,6,7,8,9,10,11,12);
begin
  for i in 1..lista.LAST LOOP
      pipe row(lista(i));
  end loop;
  return;
end;
/
