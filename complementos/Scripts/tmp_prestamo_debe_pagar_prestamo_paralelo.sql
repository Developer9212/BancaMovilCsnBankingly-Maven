create or replace function primero_debe_pagar_prestamo_paralelo(integer, integer, integer)
returns varchar as $$
declare
  p_idorigenp  alias for $1;
  p_idproducto alias for $2;
  p_idauxiliar alias for $3;

  p_idorigenp_p  integer;
  p_idproducto_p integer;
  p_idauxiliar_p integer;

  x integer;
  y integer;

  msj varchar;

  fecha_hoy date;

  r_aux record;
begin

  select into fecha_hoy date(fechatrabajo) from origenes limit 1;
  if not found or fecha_hoy is NULL then fecha_hoy := date(now()); end if;

  x := 0;
  select into x count(*) from referenciasp
  where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and tiporeferencia = 10;
  if not found or x is NULL then x := 0; end if;

  y := 0;
  select into y (case when dato1 is NULL or dato1 = '' then '0' else dato1 end)::integer from tablas
  where lower(idtabla) = 'param' and lower(idelemento) like 'prestamos_paralelos%' and length(idelemento) > 19 and
        sai_texto1_like_texto2(p_idproducto::text, NULL, dato2, '|') > 0;
  if not found or y is NULL then y := 0; end if;

  msj := NULL;
  if x > 0 or y > 0 then

    p_idorigenp_p := 0; p_idproducto_p := 0; p_idauxiliar_p := 0;
    select into p_idorigenp_p, p_idproducto_p, p_idauxiliar_p
                idorigenpr,    idproductor,    idauxiliarr
    from referenciasp
    where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and tiporeferencia = 10;
    if not found then
      p_idorigenp_p := 0; p_idproducto_p := 0; p_idauxiliar_p := 0;
    else
      if p_idorigenp_p is NULL  then p_idorigenp_p := 0; end if;
      if p_idproducto_p is NULL then p_idproducto_p := 0; end if;
      if p_idauxiliar_p is NULL then p_idauxiliar_p := 0; end if;
    end if;

    select into r_aux *
    from auxiliares
    where idorigenp = p_idorigenp_p and idproducto = p_idproducto_p and idauxiliar = p_idauxiliar_p and estatus = 2;
    if found then

      -- SI ES PRESTAMO TIPO COVID LAS FECHAS SE EVALUAN DIFERENTE
      x := 0;
      if r_aux.tipoprestamo = 5 then
        select into x count(*)
        from amortizaciones
        where idorigenp = p_idorigenp_p and idproducto = p_idproducto_p and idauxiliar = p_idauxiliar_p and
              vence <= fecha_hoy and (todopag = FALSE or abono != abonopag);
        if not found or x is NULL then x := 0; end if;
      else
        select into x count(*)
        from amortizaciones
        where idorigenp = p_idorigenp_p and idproducto = p_idproducto_p and idauxiliar = p_idauxiliar_p and
              vence < fecha_hoy and (todopag = FALSE or abono != abonopag);
        if not found or x is NULL then x := 0; end if;
      end if;

      if x > 0 then
        msj := 'ANTES DE HACER UN PAGO AL FOLIO '||text(p_idorigenp)||'-'||text(p_idproducto)||'-'||text(p_idauxiliar)||
               ' LA PERSONA DEBE ABONARLE AL '||text(p_idorigenp_p)||'-'||text(p_idproducto_p)||'-'||text(p_idauxiliar_p);
      end if;
    end if;
  end if;

  return msj;
end;
$$ language 'plpgsql';

/*
select * from auxiliares
where (idorigenp,idproducto,idauxiliar) in
      (select idorigenp,idproducto,idauxiliar from referenciasp where tiporeferencia = 10) and estatus = 2;

select * from carteravencida
where (idorigenp,idproducto,idauxiliar) in
      (select idorigenp,idproducto,idauxiliar from referenciasp where tiporeferencia = 10);
*/

