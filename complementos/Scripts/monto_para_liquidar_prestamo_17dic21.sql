create or replace function
monto_para_liquidar_prestamo(integer, integer, integer, date) returns numeric as $$
declare
  x_suma    numeric;
begin

  select
  into   x_suma sum(x::numeric)
  from   regexp_split_to_table(replace(sai_distribucion_prestamo($1,$2,$3,$4,999999999.99),'|','@'),'@') as x;

  return x_suma;
end;
$$ language 'plpgsql';


