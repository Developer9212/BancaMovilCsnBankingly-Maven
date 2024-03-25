/*------------------------------------------------------------------------------
 * SAICoop 0.1
 * Sistema de Administracion Integrado para Cooperativas de Ahorro y Prestamo
 * (c) 2001 Federacion Regional de Cooperativas de Ahorro y Prestamo Noreste SCL
 * -----------------------------------------------------------------------------
 * Archivo    : pl_prestamos.sql
 * Descripcion: Procedimientos relacionados con los auxiliares de credito
 * Autor      : Lic. Jaime N. Charles Trevinio (jaime_charles@yahoo.com)
 * Fecha      : 01 de Noviembre de 2002
 * -----------------------------------------------------------------------------
 * Notas         : Se separaron estos procedimientos de pl_auxiliares.
 * Modificaciones:
 -----------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
 Realiza una apertura de PRESTAMO a nivel funcion pl
------------------------------------------------------------------------------*/
create or replace function --rev 8.4
sai_prestamos_crea_apertura (_text) returns integer as '
-- Sintaxis:

--  (o,g,s,o,p,fecha,idfinalidad,monto,plazo,periodoabono,idusuario,tasa(t/f),estatus(0/1))

--  El periodo si es <= 0 toma el periodo de la tabla ''param'',''peridoabono~''
--  Si el estatus es autorizado (1) el montoaperturado y autorizado son iguales
--  La tasa si es TRUE usa las tasas del producto, si FALSE tasas = 0
--  El monto aperturado y monto autorizado son lo mismo si el estatus = 1
declare
  p_mat         alias for $1;
  p_idorigen    integer;
  p_idgrupo     integer;
  p_idsocio     integer;
  p_idorigenp   integer;
  p_idproducto  integer;
  p_fecha       date;
  p_idfinalidad integer;
  p_monto       numeric;
  p_plazo       integer;
  p_idusuario   integer;
  p_tasa        boolean;
  p_periodo     integer;
  p_estatus     integer;
  llave_folio   text;
  x_folio       integer;
  x_tasaio      numeric;
  x_tasaiod     numeric;
  x_tasaim      numeric;
  r_prod        record;
  x_montoaut    numeric;
  x_idusraut    integer;
  x_periodo     integer;
  x_pdiafijo    integer;
  x_resint      integer;
  paso          text;
begin
  p_idorigen    := p_mat[1];
  p_idgrupo     := p_mat[2];
  p_idsocio     := p_mat[3];
  p_idorigenp   := p_mat[4];
  p_idproducto  := p_mat[5];
  p_fecha       := p_mat[6];
  p_idfinalidad := p_mat[7];
  p_monto       := p_mat[8];
  p_plazo       := p_mat[9];
  p_periodo     := p_mat[10];
  p_idusuario   := p_mat[11];
  p_tasa        := p_mat[12];
  p_estatus     := p_mat[13];

  if p_estatus not in (0,1) then
    raise exception ''EL ESTATUS ESTA FUERA DE RANGO (0 y 1)...'';
  end if;

  if p_plazo <= 0 then
    raise exception ''EL PLAZO DEBE SER MAYOR IGUAL A 1...'';
  end if;

  if p_estatus = 0 then
    x_montoaut := 0;
  else
    x_montoaut := p_monto;
    x_idusraut := p_idusuario;
  end if;

  -- Retrives params from productos
  select into r_prod * from productos where idproducto = p_idproducto;

  -- Trae las tasas de producto si p_tasa es verdadero
  if p_tasa then
    x_tasaio   := r_prod.tasaio;
    x_tasaiod  := r_prod.tasaiod;
    x_tasaim   := r_prod.tasaim;
  else
    x_tasaio  := 0;
    x_tasaiod := 0;
    x_tasaim  := 0;
  end if;

  -- Valida el periodoabono
  if p_periodo > 0 then
    x_periodo := p_periodo;
  else
    select into x_periodo int4(dato1)
           from tablas
          where idtabla = ''param'' and
                idelemento = (''periodoabono''||text(p_idproducto));
    if not found then
      select into x_periodo int4(dato1)
             from tablas
            where idtabla = ''param'' and idelemento = ''periodoabono'';
      if not found then
        x_periodo := 30;
        raise notice ''EL PERIODO DE ABONO FUE ASIGNADO POR DEFAULT A 30'';
      end if;
    end if;
  end if;

  x_pdiafijo := r_prod.pagodiafijo;

  llave_folio := ''APE''||trim(to_char(p_idorigenp,''099999''))||
                 trim(to_char(p_idproducto,''09999''));
  x_folio := sai_folio(TRUE,llave_folio);
/*
  paso := ''insert into auxiliares (idorigen,idgrupo,idsocio,idorigenp,idproducto,''||
          ''idauxiliar,fechaape,idfinalidad,estatus,plazo,periodoabonos,pagodiafijo,''||
          ''montosolicitado,montoautorizado,tasaio,tasaiod,tasaim,idnotas,''||
          ''elaboro,autorizo) values('';

  raise notice ''% %,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,NULL,%,%);'',paso,p_idorigen,
               p_idgrupo,p_idsocio,p_idorigenp,p_idproducto,x_folio,p_fecha,
               p_idfinalidad,p_estatus,p_plazo,x_periodo,x_pdiafijo,p_monto,
               x_montoaut,x_tasaio,x_tasaiod,x_tasaim,p_idusuario,x_idusraut;
*/
  insert into auxiliares (idorigen,idgrupo,idsocio,idorigenp,idproducto,
                          idauxiliar,fechaape,idfinalidad,estatus,
                          plazo,periodoabonos,pagodiafijo,
                          montosolicitado,montoautorizado,
                          tasaio,tasaiod,tasaim,
                          idnotas,elaboro,autorizo)
                  values (p_idorigen,p_idgrupo,p_idsocio,p_idorigenp,
                          p_idproducto,x_folio,p_fecha,p_idfinalidad,p_estatus,
                          p_plazo,x_periodo,x_pdiafijo,
                          p_monto,x_montoaut,
                          x_tasaio,x_tasaiod,x_tasaim,
                          NULL,p_idusuario,x_idusraut);

  x_resint := sai_amortizaciones_crea_tabla (p_idorigenp,p_idproducto,x_folio,
                                             date(p_fecha), ''genera_todo'');

  return x_folio;
end;
' language 'plpgsql';

-- Esta funcion se usara para saber si debe usarse o no el MONTO DE PAGOS FIJOS
-- de un prestamo. Valida si hay diferencias con la tabla de amortizaciones, por
-- si esta no tiene valores correctos ------------------------------------------
create or replace function
no_usar_monto_pagos_fijos(integer,integer,integer,numeric,numeric)
returns boolean as $$
DECLARE
  p_idorigenp  ALIAS FOR $1;
  p_idproducto ALIAS FOR $2;
  p_idauxiliar ALIAS FOR $3;
  p_monto_fijo ALIAS FOR $4;
  p_iva        ALIAS FOR $5;

  r_aux   RECORD;
  r_amort RECORD;

  primer_pago_dif BOOLEAN;
  st      INTEGER;
  periodo INTEGER;

  fechaact TEXT;

  pago_df INTEGER;
  montox  NUMERIC;
  difx    NUMERIC;
  ivaiox  NUMERIC;
  cont    INTEGER;

  no_usar BOOLEAN;

  cant_pagos INTEGER;
  cont2      INTEGER;
BEGIN

  primer_pago_dif := FALSE;
  SELECT INTO st, fechaact, periodo, pago_df
              estatus, (CASE WHEN fechaactivacion IS NULL THEN '' ELSE TEXT(fechaactivacion) END),
              periodoabonos, pagodiafijo
  FROM auxiliares
  WHERE idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar;
  IF FOUND THEN
    IF pago_df = 1 AND ( (st < 2 AND LENGTH(fechaact) > 0 AND periodo = 0) OR periodo != 0 ) THEN
      primer_pago_dif := TRUE;
    END IF;
  END IF;

  cant_pagos := 0;
  SELECT INTO cant_pagos COUNT(*) FROM amortizaciones
  WHERE idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar AND todopag = FALSE;
  IF NOT FOUND OR cant_pagos IS NULL THEN RETURN FALSE; END IF;
  IF cant_pagos <= 1 THEN RETURN TRUE; END IF;

  cont := 0; cont2 := 0;
  FOR r_amort IN
    SELECT idamortizacion, abono, abonopag, io, iopag FROM amortizaciones
    WHERE idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar AND todopag = FALSE
    ORDER BY idamortizacion
    LIMIT (cant_pagos - 1)
  LOOP
    cont2 := cont2 + 1;
    --montox := (r_amort.abono - r_amort.abonopag) + round((r_amort.io - r_amort.iopag)*(1 + (p_iva/100.0)),2);
    montox := r_amort.abono + round(r_amort.io*(1 + (p_iva/100.0)),2);
    difx := p_monto_fijo - montox;

    -- IF r_amort.idamortizacion < cant_pagos THEN
    IF cont2 < cant_pagos THEN
      IF difx < 0 THEN difx := difx*(-1); END IF;
      IF difx < 0.012 THEN difx := 0; END IF;
      IF difx > 0 THEN cont := cont + 1; END IF;
    END IF;

    IF r_amort.idamortizacion=1 AND cont=1 AND primer_pago_dif THEN cont := 0;
    END IF;
  END LOOP;

  no_usar := FALSE;
  IF cont > 0 THEN no_usar := TRUE; END IF;

  RETURN no_usar;
END;
$$ language 'plpgsql';

drop function if exists es_ultimo_pago (integer, integer, integer, date);
create or replace function es_ultimo_pago (integer, integer, integer, date)
returns boolean as $$
DECLARE
  p_idorigenp  ALIAS FOR $1;
  p_idproducto ALIAS FOR $2;
  p_idauxiliar ALIAS FOR $3;
  fecha_amort  ALIAS FOR $4;
  ultima_fecha DATE;
BEGIN

  SELECT INTO ultima_fecha vence FROM amortizaciones
  WHERE idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar
  ORDER BY vence DESC LIMIT 1;
  IF NOT FOUND OR ultima_fecha IS NULL THEN RETURN FALSE; END IF;

  IF ultima_fecha = fecha_amort THEN RETURN TRUE; END IF;

  RETURN FALSE;
END;
$$ language 'plpgsql';

-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::                                                                                      ::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::         A Q U I   I N I C I A    F U N C I O N E S   D E :   sai_auxiliar_pr         ::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::         sai_pr_dv,  fecha_correcta_siguiente_pago,  sai_pr_dv_por_interes            ::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::                                                                                      ::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
create or replace function
sai_pr_dv_por_interes (integer,integer,integer,numeric,numeric,numeric,date,
                       integer,date,integer,date)
returns text as $$
declare
  p_idorigenp           alias for $1;
  p_idproducto          alias for $2;
  p_idauxiliar          alias for $3;
  p_iototal             alias for $4;
  p_tasaio              alias for $5;
  p_saldo               alias for $6;
  p_fecha_hoy           alias for $7;
  p_pagodiafijo         alias for $8;
  p_fecha_vencimiento   alias for $9;
  p_periodoabonos       alias for $10;
  p_fechaactivacion     alias for $11;

  x_dt                  integer;
  x_fecha_ini           date;
  x_fecha_ini_dv        date;
  x_fmin                date;
  x_fecha_prox_ab       date;
  x_mons                integer;
  x_days                integer;
  x_tasaio              numeric;
  dv_heredados          integer;
  refer                 record;
  c_atiempo             integer;
  max_dias              integer;
  dias_vencidos_intord  integer;
  r_amort               record;
  r_paso                record;
  x_paso                text;
  x_nueva_forma         boolean;
  x_doit                boolean;
  x numeric;
begin
  if p_tasaio = 0 or p_iototal = 0 or p_saldo = 0 or
     p_fechaactivacion is NULL then
    return NULL;
  end if;

  x_dt := ((p_iototal / (p_tasaio/100/30)) / p_saldo)::numeric(7);

  x_fecha_ini := p_fecha_hoy - x_dt;

  if x_fecha_ini > p_fecha_hoy then
    return NULL;
  else
    select
    into   r_paso *
    from   tablas
    where  idtabla = 'param' and idelemento = 'dv_por_interes_inmediato';
    x_nueva_forma := found;

    if x_nueva_forma then
      select into x_fecha_ini_dv,x_fmin max(vence),min(vence)
      from        (select   vence,todopag
                   from     amortizaciones
                   where    idorigenp  = p_idorigenp and
                            idproducto = p_idproducto and
                            idauxiliar = p_idauxiliar and vence > x_fecha_ini
                   order by vence asc
                   limit    1) as cc;
      x_doit := (not found or x_fecha_ini_dv is NULL);
    else
      select into x_fecha_ini_dv,x_fmin max(vence),min(vence)
      from        (select   vence,todopag
                   from     amortizaciones
                   where    idorigenp  = p_idorigenp and
                            idproducto = p_idproducto and
                            idauxiliar = p_idauxiliar and vence >= x_fecha_ini
                   order by vence asc
                   limit    2) as cc;
      x_doit := (not found or x_fecha_ini_dv is NULL or x_fecha_ini_dv = x_fmin);
    end if;

    if x_doit then
      if p_pagodiafijo = 1 then
        if x_fecha_ini_dv = x_fmin then
          x_fecha_ini_dv := date(x_fmin + '1 month'::interval);
        else
          x_mons := extract (month from age(x_fecha_ini,p_fecha_vencimiento));
          x_days := extract (days  from age(x_fecha_ini,p_fecha_vencimiento));
          if x_days > 0 then
            x_mons := x_mons + 1;
          end if;
          x_mons := x_mons + 1;
          x_fecha_ini_dv := date(p_fecha_vencimiento +
                                 (text(x_mons)||' month')::interval);
        end if;
      else
        x := 0.0;
        x := (case when p_pagodiafijo = 0
                   then p_periodoabonos
                   else case when x_dt = 0 then 15 else x_dt end
              end);
        x_fecha_ini_dv := p_fecha_vencimiento + ((ceil((x_fecha_ini -
                          p_fecha_vencimiento)::numeric/x) + 1) * x)::integer;
      end if;
    else
      select into r_amort *
      from        amortizaciones
      where       idorigenp = p_idorigenp and idproducto = p_idproducto and
                  idauxiliar = p_idauxiliar and vence = x_fmin
      order by    vence asc;
      if r_amort.todopag or r_amort.abono = r_amort.abonopag then
        if x_nueva_forma then
          x_fecha_prox_ab := x_fmin;
        else
          x_fecha_prox_ab := x_fecha_ini_dv;
        end if;
      else
        x_fecha_ini_dv  := x_fmin;
        x_fecha_prox_ab := x_fmin;
      end if;
    end if;

    dias_vencidos_intord := p_fecha_hoy - x_fecha_ini_dv;
    if dias_vencidos_intord < 0 then
      dias_vencidos_intord := 0;
    end if;

    if x_fecha_prox_ab < p_fecha_hoy then
      select into r_amort *
      from        amortizaciones
      where       idorigenp = p_idorigenp and idproducto = p_idproducto and
                  idauxiliar = p_idauxiliar and vence >= p_fecha_hoy
      order by    vence asc
      limit       1;
      if not found then
        select into r_amort *
        from        amortizaciones
        where       idorigenp = p_idorigenp and idproducto = p_idproducto and
                    idauxiliar = p_idauxiliar and vence < p_fecha_hoy
        order by    vence desc
        limit       1;
      end if;
      x_fecha_prox_ab := r_amort.vence;
    end if;
  end if;

  return text(dias_vencidos_intord)||'|'||text(x_fecha_prox_ab);
end;
$$ language 'plpgsql';

-- ESTA FUNCION SE USA EN sai_pr_dv() Y g4ticket.c PARA EL CALCULO DE LA FECHA -
-- DEL SIGUIENTE PAGO (JFPA, 13/OCTUBRE/2016) ----------------------------------
-- MODIF: 19/DIC/2016:JFPA, COPIADA POR: JGMB
create or replace function fecha_correcta_siguiente_pago(integer, integer, integer, date, integer, integer)
returns date as $$
declare
  p_idorigenp  alias for $1;
  p_idproducto alias for $2;
  p_idauxiliar alias for $3;
  p_fecha_hoy  alias for $4;
  p_diasv      alias for $5;
  p_dias_int   alias for $6;

  x    integer;
  y    integer;
  dif1 integer;
  dif2 integer;
  tp   boolean;

  adelantado boolean;
  tipo_amort integer;

  fechax date;
  fecha1 date;
  fecha2 date;

  fecha_base     date;
  fecha_ult_pago date;
  fecha_ant      date;

  hay_dias_no_validos_para_pagos boolean;
begin

  -- Hay un listado de dias no validos para pagar ??
  hay_dias_no_validos_para_pagos := FALSE; x = 0;
  select into x count(*) from tablas where lower(idtabla)='dias_no_validos_para_pagos';
  if not found or x is null then x := 0; end if;
  if x > 0 then hay_dias_no_validos_para_pagos := TRUE; end if;

  -- SI EL SOCIO TIENE DIAS VENCIDOS, LA FECHA DE PAGO ES HOY !!!
  if p_diasv > 0 then
    if hay_dias_no_validos_para_pagos = FALSE then return p_fecha_hoy; end if;

    if p_diasv > 10 then return p_fecha_hoy; end if;

    fechax := sai_fecha_valida_para_pagos(p_fecha_hoy);

    x := 0;
    select into x count(*) from tablas
    where lower(idtabla) = 'dias_no_validos_para_pagos' and
          date(idelemento) between (p_fecha_hoy - p_diasv) and (p_fecha_hoy - 1);
    if not found or x is NULL then x := 0; end if;

    if x = p_diasv then return fechax; end if;

    return p_fecha_hoy;
  end if;

  --- Si se tiene la tabla donde el interes se calcula al siguiente pago aunque
  --- tenga pagos adelantados, reviso si con otra tabla la siguiente fecha de
  --- pago es simplemente la de la tabla de amortizaciones (JFPA, 17/JULIO/2019)
  x := 0; y := 0;
  select into x count(*) from tablas where idtabla = 'param' and idelemento = 'dv_por_interes_inmediato';
  if not found or x is NULL then x := 0; end if;

  -- insert into tablas values ('param', 'calcular_fecha_por_interes_inmediato', NULL, NULL, NULL, NULL, NULL, NULL, 0);
  select into y count(*) from tablas where idtabla = 'param' and idelemento = 'calcular_fecha_por_interes_inmediato';
  if not found or y is NULL then y := 0; end if;

  if x > 0 or y > 0 then
    select into fecha1 vence from amortizaciones
    where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and vence >= p_fecha_hoy
    order by vence limit 1;
    if not found then fecha1 := NULL; end if;
    if fecha1 is NULL then fecha1 := p_fecha_hoy; end if;
    return fecha1;
  end if;

  --- El socio ha ADELANTADO pagos ?? ---
  x := 0; adelantado := FALSE;
  select into x count(*) from amortizaciones
  where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and vence >= p_fecha_hoy and
        todopag = TRUE;
  if not found or x is null then x := 0; end if;
  if x > 0 then adelantado := TRUE; end if;

  -- EN CAPITAL ACTIVO SE PRESENTA EL CASO DE QUE LOS PAGOS ADELANTADOS ESTAN AL
  -- FINAL DE LA TABLA, NO SON LOS PAGOS SIGUIENTES DE LA FECHA DE HOY, POR ESO
  -- BUSCO QUE AL MENOS EL SIGUIENTE PAGO ESTE CUBIERTO
  if adelantado then
    tp := FALSE;
    select into tp todopag from amortizaciones
    where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and vence >= p_fecha_hoy
    limit 1;
    if not found then tp := FALSE; end if;
    adelantado := tp;
  end if;

  -- FECHA DEL ULTIMO PAGO COMPLETO ...
  select into fecha_ult_pago vence from amortizaciones
  where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and todopag = TRUE
  order by vence desc limit 1;
  if not found then fecha_ult_pago := NULL; end if;

  -- CASO ESPECIAL DE CAPITAL ACTIVO Y TAL VEZ OTROS : COMO LOS ADELANTOS SE VAN
  -- HASTA EL FINAL, PARECE QUE SI ESTA ADELANTADO Y EL ULTIMO PAGO COMPLETO ES
  -- EL ULTIMO DE LA TABLA DE PAGOS, POR ESO SE DEBE HACER OTRA VALIDACION
  fecha1 := NULL;
  if x > 0 and not adelantado and fecha_ult_pago is not null and fecha_ult_pago > p_fecha_hoy then

    fecha_ant := NULL; tp := FALSE;
    select into fecha_ant, tp vence, todopag from amortizaciones
    where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and vence <= p_fecha_hoy
    order by vence desc limit 1;
    if not found then
      fecha_ant := NULL; tp := FALSE;
    end if;

    if fecha_ant is not null then

      if tp then

        select into fecha1 vence from amortizaciones
        where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and vence > fecha_ant
        order by vence limit 1;
        if not found then fecha1 := NULL; end if;
        if fecha1 is NULL then fecha1 := p_fecha_hoy; end if;

      else

        if hay_dias_no_validos_para_pagos then
          fecha2 := NULL;
          fecha2 := sai_fecha_valida_para_pagos(fecha_ant);

          if fecha_ant <= p_fecha_hoy and p_fecha_hoy <= fecha2 then fecha1 := fecha2;
          else
            fecha1 := p_fecha_hoy;
          end if;
        else
          fecha1 := p_fecha_hoy;
        end if;

      end if;
    else
      fecha1 := p_fecha_hoy;
    end if;

    return fecha1;

  end if;

  -- HAY CASOS DONDE YA SE HIZO EL PAGO CORRESPONDIENTE A UN DIA NO VALIDO PERO
  -- NO SE DETECTA, AQUI DEBE VALIDARSE
  fecha_base := NULL; fecha1 := NULL;
  if x = 0 and hay_dias_no_validos_para_pagos then

    if fecha_ult_pago is not null then

      if abs(p_fecha_hoy - fecha_ult_pago) <= 5 then
        fecha1 := sai_fecha_valida_para_pagos(fecha_ult_pago);
        if fecha1 >= p_fecha_hoy then
          x := 0;
          select into x count(*) from amortizaciones
          where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and todopag = TRUE and
                vence > fecha1;
          if not found or x is null then x := 0; end if;
          if x > 0 then
            adelantado := TRUE;
            fecha_base := fecha_ult_pago;
          end if;
        end if;
      end if;

    end if;

  end if;

  tipo_amort := 99;
  select into tipo_amort tipoamortizacion
  from auxiliares where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar;
  if not found or tipo_amort is null then tipo_amort := 99; end if;

  fechax := NULL;

  ------------------------------------------------------------------------------
  if adelantado then -- PRESTAMO CON PAGOS ADELANTADOS -------------------------

    if tipo_amort = 5 then

      select into fechax vence from amortizaciones
      where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and
            vence > (case when fecha_base is not null then fecha_base else p_fecha_hoy end) and todopag = FALSE
      order by vence limit 1;

    else

      -- AUNQUE ESTE ADELANTADO, PUEDE TENER DIAS DE INTERES Y SE DEBEN TOMAR EN
      -- CUENTA PARA NO MANDAR UNA FECHA DE PAGO MUY A FUTURO DONDE PODRIA ESTAR
      -- VENCIDO
      fecha1 := NULL;
      fecha1 := p_fecha_hoy - p_dias_int;

      select into fechax vence from amortizaciones
      where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and
            vence > (select vence from amortizaciones
                     where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and
                           vence >= fecha1
                     order by vence limit 1)
      order by vence limit 1;

    end if;

    return fechax;

  end if; ----------------------------------------------------------------------
  ------------------------------------------------------------------------------

  fecha1 := NULL; fecha2 := NULL;

  if fecha_ult_pago is not null and hay_dias_no_validos_para_pagos then

    select into fecha1 vence from amortizaciones
    where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and vence > fecha_ult_pago
    order by vence asc limit 1;

    if abs(p_fecha_hoy - fecha1) <= 5 then
      fecha2 := sai_fecha_valida_para_pagos(fecha1);
      if fecha2 >= p_fecha_hoy then return fecha2; end if;
    end if;

  else

    select into fecha1 vence from amortizaciones
    where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and vence >= p_fecha_hoy
    order by vence asc limit 1;
    if not found then fecha1 = p_fecha_hoy; end if;

    if hay_dias_no_validos_para_pagos then
      fecha1 := sai_fecha_valida_para_pagos(fecha1);
      return fecha1;
    end if;

  end if;

  ------------------------------------------------------------------------------
  -- ULTIMA MODIFICACION : 02/DICIEMBRE/2019 -----------------------------------
  ------------------------------------------------------------------------------

  return fecha1;
end;
$$ language 'plpgsql';

-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

/*------------------------------------------------------------------------------
 En esta funcion se calcula un sin fin de detalles acerca de los prestamos
 que a final de cuentas se retornan a sai_auxiliar_pr
------------------------------------------------------------------------------*/
-- LE MODIFIQUE EL CALCULO DEL INTERES, PARA QUE USARA EL IO DE DESCUENTO EN VEZ
-- DEL INTERES NORMAL CUANDO TUVIERA DIAS VENCIDOS PERO QUE FUERA POR CAUSA DE -
-- DIAS INHABILES (JFPA, 05/ENERO/2016) ----------------------------------------
create or replace function sai_pr_dv (_text) returns _text as $$
declare
  p_idorigenp             integer;
  p_idproducto            integer;
  p_idauxiliar            integer;
  p_fecha_hoy             date;
  p_fecha_umi             date;
  p_cartera               char;
  p_tipoamort             integer;
  p_aux_tasaio            numeric;
  p_aux_tasaiod           numeric;
  p_aux_tasaim            numeric;
  p_saldo                 numeric;
  p_montoprest            numeric;
  p_tipoprest             numeric;
  p_iodif_gar             numeric;
  p_fechaprestamo         date;
  p_periodoabonos         integer;
  p_pagodiafijo           integer;
  p_fecha_ven             date;
  p_aux_io                numeric;
  p_aux_idnc              numeric;
  p_aux_ieco              numeric;
  p_estatus               integer;
  p_tipoamortizacion      integer;

  max_dias                integer;
  fecha_limite            date;
  abonos_vencidos         numeric;
  dias_vencidos_capital   integer;
  dias_vencidos_intord    integer;
  dias_vencidos           integer;
  monto_vencido           numeric;
  monto_por_vencer        numeric;
  io_calculado            numeric;
  monto_bonificacion      numeric;
  im_calculado            numeric;
  fecha_sig_abono         date;
  fecha_comienzo_capital  date;
  fecha_comienzo_intord   date;
  fecha_uav               date;
  valida_monto_x_vencer   boolean;
  estatusc                char;
  fc                      date;
  fad                     date;
  faa                     date;
  num_vars                integer;
  tim                     numeric;
  tio                     numeric;
  tio2                    numeric;
  tiod                    numeric;
  dt                      integer;
  i                       integer;
  b                       _text;
  c                       _text;
  result                  _text;
  amort                   record;
  refer                   record;
  abonos_cubiertos        integer;
  o_estatus               boolean;
  todo_pag                boolean;
  c_atiempo               integer;
  dv_heredados            integer;
  paso                    char;
  prox_a_salir            boolean;
  x_dato1                 text;
  x_dato2                 text;
  x_dato3                 text;
  r_tasas                 record;
  llave_tasad             text;
  fraccion                numeric;
  tasa_desc               numeric;
  puntos                  numeric;
  calculo_by_av           boolean;
  limite_av               integer;
  x1                      integer;
  x2                      integer;
  p1                      numeric;
  p2                      numeric;
  es_sindescuento         boolean;
  io_calculado_sd         numeric;
  dif_descto_io           numeric;
  y                       numeric;
  cant_io_aux             numeric;
  cant_idnc_aux           numeric;
  cant_ieco_aux           numeric;
  t_iva_io                numeric;
  io_calculado2b          numeric;
  folio_aux               text;
  cant_folio_aux          text;
  io_pendiente            numeric;
  x_comienzo              integer;
  x_partadiv              integer;
  x_tol_int_mor           integer;
  x_dias_tol_cnp          integer;
  x_monto_por_cnp         numeric;
  comision_np_calc        numeric;
  primera_vez             boolean;
  cont_abonos_x           integer;
  x_io_sd                 numeric;
  io_calculado_cd         numeric;
  im_usar_saldo           boolean;
  fecha_activacion        date;
  fecha_nuevo_calculo_im  date;
  im_aux                  numeric;
  fecha_trabajo           DATE;
  fechax                  DATE;
  x_con_capital           integer;
  x_total_amorts          integer;
--  es_caja                 boolean;
  es_ven_7_21_15_45       boolean;
  r_paso                  record;
  es_dia_inhabil          boolean;
  r_prevol                record;
  es_revolvente           boolean;
  p_idorigen              integer;
  p_idgrupo               integer;
  p_idsocio               integer;
  hay_dias_inhabiles      boolean;
  dias_inhabiles          integer;
  dias_interes            integer;
  px1                     varchar;
  es_prestamo_apoyado     boolean;
  found_refer             boolean;
  x_pnc_covid_es_apoyo    boolean;
begin
  p_cartera           := sai_not_null($1[1]);
  p_idorigenp         := sai_not_null($1[2]);
  p_idproducto        := sai_not_null($1[3]);
  p_idauxiliar        := sai_not_null($1[4]);
  p_fecha_hoy         := sai_not_null($1[5]);
  p_tipoamort         := sai_not_null($1[6]);
  p_aux_tasaio        := sai_not_null($1[7]);
  p_aux_tasaiod       := sai_not_null($1[8]);
  p_aux_tasaim        := sai_not_null($1[9]);
  p_saldo             := sai_not_null($1[10]);
  p_fecha_umi         := sai_not_null($1[11]);
  p_montoprest        := sai_not_null($1[12]);
  p_tipoprest         := sai_not_null($1[13]);
  p_iodif_gar         := sai_not_null($1[14]);

  if $1[15] = 'NULL' then
    p_fechaprestamo   := NULL;
  else
    p_fechaprestamo   := sai_not_null($1[15]);
  end if;

  p_periodoabonos     := sai_not_null($1[16]);
  p_pagodiafijo       := sai_not_null($1[17]);
  p_aux_io            := sai_not_null($1[18]);
  p_aux_idnc          := sai_not_null($1[19]);
  p_aux_ieco          := sai_not_null($1[20]);

  IF $1[21] = 'NULL' THEN
    p_fecha_ven := NULL;
  ELSE
    p_fecha_ven := sai_not_null($1[21]);
  END IF;

  p_estatus           := sai_not_null($1[22]);
  p_tipoamortizacion  := sai_not_null($1[23]);
  p_idorigen          := sai_not_null($1[24]);
  p_idgrupo           := sai_not_null($1[25]);
  p_idsocio           := sai_not_null($1[26]);

  ------------------------------------------------------------------------------
  -- Aqui se calcula la tasa de descuento al estilo Nuevo Mexico de la forma
  -- siguiente:
  --  - La tasa de descuento es gradual depende del saldo actual de prestamo
  --    entre menos saldo mas descuento y el descuento va aumentando en
  --    puntos (dato3), asu vez los puntos varian segun la tasa del interes
  --    ordinario que tenga, si esta dentro del rango que esta definido en el
  --    dato1 y dato2.
  --  - El saldo se mide, segun, el monto prestado dividido en x partes (dato4_b)
  --    si el saldo esta por debajo de la x parte (dato4_a) comienza a rebajarse
  --    en puntos la tasa de descuento.
  --  - El Descuento se aplica o la rutina se aplica si la fecha del prestamo
  --    (fechaactivacion) es menor a la del dato5.
  --
  -- idtabla|idelemento   |       nombre       |dato1|dato2|dato3|dato4|dato5
  -- -------+-------------+--------------------+-----+-----+-----+-----+-----------
  -- tasas  |tasad30102r01|Desc Ordinarios .20%| 0.80| 1.49| 0.20| 1|4 | 31/05/2008
  -- tasas  |tasad30102r02|Desc Ordinarios .30%| 1.50| 3.00| 0.30| 1|4 | 31/05/2008
  -- tasas  |tasad30302r01|Desc Automatico .20%| 0.80| 1.49| 0.20| 1|4 | 31/05/2008
  -- tasas  |tasad30302r02|Desc Automatico .30%| 1.50| 3.00| 0.30| 1|4 | 31/05/2008
  -- tasas  |tasad30402r01|Desc Ordinarios .20%| 0.80| 1.49| 0.20| 1|4 | 31/05/2008
  -- tasas  |tasad30402r02|Desc Ordinarios .30%| 1.50| 3.00| 0.30| 1|4 | 31/05/2008
  ------------------------------------------------------------------------------
  if p_saldo > 0 then
    llave_tasad := 'tasad' || trim(to_char(p_idproducto,'09999')) || '%';

    select into r_tasas * from tablas
          where idtabla = 'tasas' and idelemento like llave_tasad and
                text(dato1)::numeric <= p_aux_tasaio and
                text(dato2)::numeric >= p_aux_tasaio and
                p_fechaprestamo <= date(dato5) limit 1;
    if found then
      x_comienzo := sai_token(1,r_tasas.dato4,'|');
      x_partadiv := sai_token(2,r_tasas.dato4,'|');

      x1 := 0; x2 := 0;
      x1 := int4(x_comienzo);
      x2 := int4(x_partadiv);

      fraccion := 1.00 - (p_saldo / p_montoprest);

      --- x_comienzo = comienzo --- x_partadiv = partes a dividir ---
      if fraccion >= int4(x_comienzo) / int4(x_partadiv) then
        puntos := r_tasas.dato3;

        for i in x1..x2 - 1
        loop
          p1 := i / x2::numeric;
          p2 := (i + 1) / x2::numeric;
          if fraccion >= p1 and fraccion <= p2 then
            p_aux_tasaiod := p_aux_tasaio - (puntos * i);
          end if;
        end loop;
      end if;
    end if;
  end if;

  -- Datos desde la tabla: Productos -------------------------------------------
  select into max_dias, x_tol_int_mor, x_dias_tol_cnp,         x_monto_por_cnp,               t_iva_io
              maxdv,    tolerancia_im, tolerancia_com_no_pago, coalesce(monto_com_no_pago,0), iva
  from productos where idproducto = p_idproducto;
  if (max_dias <= 0) OR (max_dias is NULL) then max_dias := 89; end if;

  -- Recorrer todo el plan de pago ---------------------------------------------
  abonos_vencidos         := 0.0;
  abonos_cubiertos        := 0;
  fecha_uav               := NULL;
  fecha_comienzo_capital  := NULL;
  fecha_comienzo_intord   := NULL;
  monto_vencido           := 0;
  io_calculado            := 0;
  io_calculado2b          := 0;
  monto_por_vencer        := 0;
  im_calculado            := 0;
  monto_bonificacion      := 0;
  dias_vencidos_capital   := 0;
  dias_vencidos_intord    := 0;
  dias_vencidos           := 0;
  dif_descto_io           := 0;
  valida_monto_x_vencer   := TRUE;
  prox_a_salir            := FALSE;
  c_atiempo               := 0;
  fecha_sig_abono         := NULL;
  cont_abonos_x           := 0;

  -- HAY DIAS INHABILES EN LA CAJA ??
  hay_dias_inhabiles := FALSE; x1 := 0;
  select into x1 count(*) from tablas where lower(idtabla) = 'dias_no_validos_para_pagos';
  if not found or x1 is null then x1 := 0; end if;
  if x1 > 0 then hay_dias_inhabiles := TRUE; end if;

  ------------------------------------------------------------------------------
  -- Configura como calcula el int. moratorio
  -- dato1: 0 = Calculo normal,  1 = Calcula apartir de x abonos (dato2)
  -- dato2: ej. 3 (abonos_vencidos >= limite_av :: 3 >= 3 ...Calcula)
  -- dato3: 1 = Calculo usando SOLAMENTE CAPITAL, != 1 calcula CAPITAL + IO + IVAIO
  -- dato1 ==> calculo_by_av (TRUE/FALSE)
  -- dato2 ==> limite_av (integer)
  ------------------------------------------------------------------------------
  select into x_dato1,x_dato2,x_dato3
              case when dato1 is NULL or dato1 = ''
                   then '0' else dato1
              end,
              case when dato2 is NULL or dato2 = ''
                   then '0' else dato2
              end,
              case when dato3 is NULL or dato3 = ''
                   then '0' else dato3
              end
         from tablas
        where idelemento = 'calculo_interes_moratorio';
  if not found then
    x_dato1 := text(0); x_dato2 := text(0); x_dato3 := text(0);
  end if;

  calculo_by_av := FALSE;
  limite_av     := 0;
  if int4(x_dato1) = 1 then
    calculo_by_av := TRUE;
    limite_av     := int4(x_dato2);
  end if;

  ------------------------------------------------------------------------------
  --- Otra forma de calcular el interes moratorio sera usando TODO EL SALDO que
  --- se debe, para esto debe existir la siguiente tabla, y que el prestamo haya
  --- sido aperturado despues de la fecha que esta en DATO1 (JFPA 19/JULIO/2012)
  --- IDTABLA    = 'param'
  --- IDELEMENTO = 'usar_todo_el_saldo_para_im'
  --- DATO1      = FECHA A PARTIR DE LA CUAL DEBE CALCULARSE EL NUEVO I. M.
  --- DATO2      = PRODUCTOS A LOS QUE APLICA, SEPARADOS POR COMAS O PIPAS
  ------------------------------------------------------------------------------
  im_usar_saldo := FALSE;
-- p_fechaprestamo es aux.fechaactivcion. Viene desde sai_auxiliar_pr  
  --fecha_activacion := NULL;
--  SELECT INTO fecha_activacion fechaactivacion FROM auxiliares
--  WHERE idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar;
  IF p_fechaprestamo IS NOT NULL THEN
    x1 := 0;
    SELECT
    INTO   x1 COUNT(*)
    FROM   tablas
    WHERE  LOWER(idtabla) = 'param' AND LOWER(idelemento) = 'usar_todo_el_saldo_para_im' AND
           DATE(dato1) <= p_fechaprestamo AND
           dato2 LIKE '%'||TRIM(TO_CHAR(p_idproducto,'999999'))||'%';
    IF NOT FOUND OR x1 IS NULL THEN
      x1 := 0;
    END IF;
    if x1 > 0 then
      im_usar_saldo := TRUE;
    end if;
  END IF;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------

  -- Busca si es un prestamo apoyado, para poder calcular la EPS apartir del apoyo ---------
  es_prestamo_apoyado = FALSE;
  found_refer := FALSE;
  if p_tipoprest != 5 then
    select
    into   refer rp2.*,a.fechaactivacion as pr_apoyo_fechaactivacion
    from   referenciasp rp2
           inner join auxiliares a using (idorigenp,idproducto,idauxiliar)
    where  idorigenpr = p_idorigenp and idproductor = p_idproducto and idauxiliarr = p_idauxiliar and
           rp2.tiporeferencia in (2,3) and a.tipoprestamo = 5 and a.estatus = 2;
    if found then
      found_refer := TRUE;
      es_prestamo_apoyado = TRUE;
    end if;
  else
    select
    into   refer rp2.*,a.fechaactivacion as pr_apoyo_fechaactivacion
    from   referenciasp rp2
           inner join auxiliares a using (idorigenp,idproducto,idauxiliar)
    where  idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and
           rp2.tiporeferencia in (2,3) and a.tipoprestamo = 5 and a.estatus = 2;
  end if;

  ------------------------------------------------------------------------------
  -- Comienza a leer la tabla de amortizaciones, sobre la marcha comienza a
  -- calcular varios datos
  ------------------------------------------------------------------------------
  for amort in
    select * from amortizaciones
    where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar
    order by idorigenp,idproducto,idauxiliar,idamortizacion
  loop

    x1 := 0;
    x1 := abs(p_fecha_hoy - amort.vence);
    fechax := NULL;
    if hay_dias_inhabiles and x1 <= 5 then
      fechax := sai_fecha_valida_para_pagos(amort.vence);
      dias_inhabiles := x1;
    end if;

    -- Deduce el monto por vencer al primer momento en que la fecha de la tabla
    -- sea mayor a la fecha de hoy
    if valida_monto_x_vencer then

      if p_fecha_hoy <= amort.vence then
        monto_por_vencer := amort.abono - amort.abonopag;
        valida_monto_x_vencer := FALSE;
      else
        if hay_dias_inhabiles and p_fecha_hoy > amort.vence and dias_inhabiles <= 5 then
          if p_fecha_hoy <= fechax then
            monto_por_vencer := amort.abono - amort.abonopag;
            valida_monto_x_vencer := FALSE;
          end if;
        end if;
      end if;

      -- SI TIPO_AMORTIZACION = 4 , LOS INTERESES DEPENDEN DE LO QUE ESTA EN LA
      -- TABLA DE AMORTIZACIONES, NO DE LA TASA NI DE LOS DIAS TRANSCURRIDOS
      if p_tipoamort = 4 then
        y := amort.io - amort.iopag - amort.bonificacion;
        if y < 0.009 then y := 0.0; end if;
        io_calculado := io_calculado + y;
      end if;

      -- SI TIPO_AMORTIZACION = 5,NO SE DEBEN CONSIDERAR LOS INTERESES QUE SEAN
      -- DE PAGOS CON EL CAMPO TODOPAG = TRUE
      if p_tipoamort = 5 and not amort.todopag then
        y := amort.io - amort.iopag - amort.bonificacion;
        if y < 0.009 then y := 0.0; end if;
        io_calculado := io_calculado + y;
      end if;

    end if;

    if p_tipoamort in (0,2) and p_aux_tasaio > 0 and p_fecha_hoy <= amort.vence and fecha_sig_abono is NULL then

      cont_abonos_x := cont_abonos_x + 1;
/*
      if hay_dias_inhabiles and (amort.vence - p_fecha_hoy) <= 5 then
        if not amort.todopag then
          fecha_sig_abono := fechax;
raise notice '----------------------------------------------------------------->> 1a';
          end if;
        if amort.todopag and cont_abonos_x = 2 then
          fecha_sig_abono := fechax;
raise notice '----------------------------------------------------------------->> 2a';
        end if;
      else
        if not amort.todopag then
          fecha_sig_abono := amort.vence;
raise notice '----------------------------------------------------------------->> 1';
        end if;
        if amort.todopag and cont_abonos_x = 2 then
          fecha_sig_abono := amort.vence;
raise notice '----------------------------------------------------------------->> 2';
        end if;
      end if;
*/
    end if;

    ----------------------------------------------------------------------------
    -- Ignora lo que ya esta cubierto en la tabla (por medio del campo todopag)
    -- lo que aun no esta cubierto entra por aqui a realizar calculos
    ----------------------------------------------------------------------------
    if not amort.todopag and amort.abono > 0 and amort.abono != amort.abonopag then

      if amort.abono != amort.abonopag and fecha_comienzo_capital is NULL then fecha_comienzo_capital := amort.vence;
      end if;

/*-------  YA NO SE CALCULA AQUI, SE CALCULA ABAJO !!!  -----------------------------
      if fecha_limite is NULL then
        fecha_limite:=coalesce(fecha_comienzo_intord,fecha_comienzo_capital) +
                      (max_dias - 1);
      end if;
-----------------------------------------------------------------------------------*/

      if p_fecha_hoy > amort.vence then

        fecha_uav := amort.vence;

        -- abonos vencidos --
        --abonos_vencidos := abonos_vencidos + 1;
        if amort.abonopag > 0 then
          abonos_vencidos := ((amort.abono - amort.abonopag) / amort.abono) + abonos_vencidos;
        else
          abonos_vencidos := 1 + abonos_vencidos;
        end if;

        -- dias vencidos de capital --
        if not fecha_comienzo_capital is NULL then dias_vencidos_capital := p_fecha_hoy - fecha_comienzo_capital;
        end if;

        -- montos vencidos capital --
        monto_vencido := monto_vencido + (amort.abono - amort.abonopag);

        if p_fecha_umi <= amort.vence then
           fc := amort.vence;
        else
           fc := p_fecha_umi;
        end if;

        b := array[trim(to_char(p_idproducto,'999999')) , trim(to_char(p_aux_tasaio,'999999.9999')),
                   trim(to_char(p_aux_tasaiod,'999999.9999')) , trim(to_char(p_aux_tasaim,'999999.9999')),
                   trim(to_char(fc,'DD/MM/YYYY')) , trim(to_char(p_fecha_hoy,'DD/MM/YYYY'))];

        c := sai_tasasvariables(b);
        num_vars := sai_not_null(c[1]);
        fad := NULL;
        for i in 1..num_vars loop
          if fad is NULL then fad := fc;
          else
             fad := c[2+(4*(i-1))]::date;
          end if;

          if (num_vars > i) then faa := c[2+(4*i)]::date;
          else
             faa := p_fecha_hoy;
          end if;
          tim := c[5+(4*(i-1))];

          dt := faa - fad;

          -- Si TIPO DE AMORTIZACION = 4, se debe ---
          -- considerar el IO y el IVA del IO -------
          -- Le agregue el TIPO DE AMORTIZACION = 5 ya que el calculo --------
          -- del IM para los PAGOS HIPOTECARIOS es igual al tipo 4, ----------
          -- pero SIN USAR EL IO_CALCULADO2 (JFPA, 25/NOVIEMBRE/2008) --------
          if p_tipoamort = 4 or p_tipoamort = 5 then
--           ARRIBA, AL PRINCIPIO, YA ESTA LEYENDO PRODUCTOS. AHI CONECTO t_iva_io
--            t_iva_io := 0.0;
--            select into t_iva_io iva from productos where idproducto=p_idproducto;
--            if not found or t_iva_io is null then t_iva_io := 16; end if;

            y  := 0; p1 := 0; p2 := 0;
            y  := amort.abono - amort.abonopag;
            if int4(x_dato3) != 1 then
              p1 := amort.io - amort.iopag;
              p2 := p1 * (t_iva_io/100);
            end if;

            tio2 := 0.0;
            tio2 := p_aux_tasaio;

            if calculo_by_av then
              if abonos_vencidos >= limite_av then
                if not im_usar_saldo then
                  im_calculado := im_calculado + ((y+p1+p2)*(((tim/100)/30)*dt));
                end if;
                if p_tipoamort = 4 then
                  io_calculado2b := io_calculado2b + (y*(((tio2/100)/30)*dt));
                end if;
              end if;
            else
              if (dt > 0) then
                if not im_usar_saldo then
                  im_calculado := im_calculado + ((y+p1+p2)*(((tim/100)/30)*dt));
                end if;
                if p_tipoamort = 4 then
                  io_calculado2b := io_calculado2b + (y*(((tio2/100)/30)*dt));
                end if;
              end if;
            end if;
          else
            if calculo_by_av then
              if abonos_vencidos >= limite_av and not im_usar_saldo then
                 im_calculado := im_calculado + ((amort.abono - amort.abonopag)*(((tim / 100) / 30) * dt));
              end if;
            else
              if dt > 0 and not im_usar_saldo then
                im_calculado := im_calculado + ((amort.abono - amort.abonopag)*(((tim / 100) / 30) * dt));
              end if;
            end if;
          end if;

        end loop;
/*
      else
        if fecha_sig_abono is NULL then

          if hay_dias_inhabiles then
            fecha_sig_abono := fechax;
raise notice '----------------------------------------------------------------->> 3a';
          else
            fecha_sig_abono := amort.vence;
raise notice '----------------------------------------------------------------->> 3b';
          end if;
          prox_a_salir := TRUE;

        end if;
*/
      end if;

    else --- Los que ya estan pagados complestos (cubiertos) ---

      --------------------------------------------------------------------------
      -- CASO ESPECIAL DE PAGOS HIPOTECARIOS DONDE EL CAPITAL SE LIQUIDA EN EL -
      -- ULTIMO PAGO, TODOS LOS DEMAS SON SOLO DE PAGO DE INTERES --------------
      --------------------------------------------------------------------------
      if not amort.todopag and amort.abono = 0 and p_tipoamort = 5 then

/*-------  YA NO SE CALCULA AQUI, SE CALCULA ABAJO !!!  -----------------------------
        if fecha_limite is NULL then
          fecha_limite:=coalesce(fecha_comienzo_intord,fecha_comienzo_capital) + (max_dias - 1);
        end if;
-----------------------------------------------------------------------------------*/

        if p_fecha_hoy > amort.vence then

          fc := case when p_fecha_umi <= amort.vence then amort.vence else p_fecha_umi end;

          b := array[trim(to_char(p_idproducto,'999999')) , trim(to_char(p_aux_tasaio,'999999.9999')),
                     trim(to_char(p_aux_tasaiod,'999999.9999')) , trim(to_char(p_aux_tasaim,'999999.9999')),
                     trim(to_char(fc,'DD/MM/YYYY')) , trim(to_char(p_fecha_hoy,'DD/MM/YYYY'))];
          c := sai_tasasvariables(b);

          num_vars := sai_not_null(c[1]);
          fad := NULL;
          for i in 1..num_vars loop
            fad := case when fad is NULL then fc else c[2+(4*(i-1))]::date end;
            faa := case when num_vars > i then c[2+(4*i)]::date else p_fecha_hoy end;
            tim := c[5+(4*(i-1))];
            dt := faa - fad;

--           ARRIBA, AL PRINCIPIO, YA ESTA LEYENDO PRODUCTOS. AHI CONECTO t_iva_io
--            t_iva_io := 0.0;
--            select into t_iva_io iva from productos where idproducto=p_idproducto;
--            if not found or t_iva_io is null then t_iva_io := 16; end if;

            p1 := 0; p2 := 0;
            if int4(x_dato3) != 1 then
              p1 := amort.io - amort.iopag;
              p2 := p1 * (t_iva_io/100);
            end if;

            tio2 := 0.0;
            tio2 := p_aux_tasaio;

            if calculo_by_av then
              if abonos_vencidos >= limite_av then
                if not im_usar_saldo then
                  im_calculado := im_calculado + ((p1+p2)*(((tim/100)/30)*dt));
                end if;
              end if;
            else
              if (dt > 0) then
                if not im_usar_saldo then
                  im_calculado := im_calculado + ((p1+p2)*(((tim/100)/30)*dt));
                end if;
              end if;
            end if;

          end loop;
        else
/*
          if fecha_sig_abono is NULL then

            if hay_dias_inhabiles and fechax is not null then
              fecha_sig_abono := fechax;
            else
              fecha_sig_abono := amort.vence;
            end if;
raise notice '----------------------------------------------------------------->> 4';
          end if;
*/
          prox_a_salir := TRUE;
        end if;
      --------------------------------------------------------------------------
      --------------------------------------------------------------------------
      --------------------------------------------------------------------------
      else
        abonos_cubiertos := abonos_cubiertos + 1;
      end if;

    end if;

    --- Control de la eps (evidencia de pagos sostenidos) ----
    --- Contador de los pagos continuos que esten a tiempo ---
    if c_atiempo != 3 then
      c_atiempo := case when es_prestamo_apoyado
                        then case when amort.vence >= refer.pr_apoyo_fechaactivacion and
                                       amort.vence <= p_fecha_hoy and amort.atiempo is TRUE
                                  then c_atiempo + 1
                                  else 0
                             end
                        else case when amort.vence <= p_fecha_hoy and amort.atiempo is TRUE
                                  then c_atiempo + 1
                                  else 0
                             end
                   end;
    end if;

    exit when prox_a_salir;
  end loop;

  ------------------------------------------------------------------------------
  -- CALCULO DE LA COMISION POR NO PAGO
  ------------------------------------------------------------------------------
  comision_np_calc  := 0;

  if monto_vencido > 0 then
    if p_fecha_hoy > date(fecha_uav + x_dias_tol_cnp) and p_fecha_umi <= date(fecha_uav + x_dias_tol_cnp) then
      comision_np_calc := x_monto_por_cnp;
    end if;
  end if;

  ------------------------------------------------------------------------------
  -- En el IO_CALCULADO tambien debe tomarse en cuenta si hay algun un interes
  -- pendiente en la tabla IO_CALCULADO2 en el campo IOPENDIENTE
  io_pendiente := 0.0;
  if p_tipoamort = 4 then
    select into io_pendiente iopendiente from io_calculado2
    where idorigenp=p_idorigenp and idproducto=p_idproducto and idauxiliar=p_idauxiliar;
    if found then
      if io_pendiente is NULL then
        io_pendiente := 0.0;
      end if;
    else
      io_pendiente := 0.0;
    end if;
  end if;
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- IO_CALCULADO2 = es el interes ordinario de un pago atrasado en un plan de
  --                 pagos fijos mensuales (p_tipoamort = 4)
  ------------------------------------------------------------------------------
  io_calculado := io_calculado + (io_calculado2b + io_pendiente);

  ------------------------------------------------------------------------------
  -- En estas lineas se guarda el IO_CALCULADO2 para luego usarse --------------
  -- al aplicar el abono al prestamo en PL_AUXILIARES.SQL ----------------------
  if p_tipoamort = 4 then
    select into y iocalculado from io_calculado2 where idorigenp = p_idorigenp
           and idproducto = p_idproducto and idauxiliar = p_idauxiliar;
    if found then
      update io_calculado2 set iocalculado = io_calculado2b
      where idorigenp = p_idorigenp and idproducto = p_idproducto and
            idauxiliar = p_idauxiliar;
    else
      insert into io_calculado2 (idorigenp,idproducto,idauxiliar,iocalculado,
                                 ioacumulado,ioeliminado,iopendiente)
      values (p_idorigenp,p_idproducto,p_idauxiliar,io_calculado2b,0,0,0);
    end if;
  end if;
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------

  -- Calculo de IO con tasas variables -----------------------------------------
  io_calculado_sd := 0;
  if p_tipoamort != 4 and p_tipoamort != 5 then
    fc := p_fecha_umi;
    b := array[trim(to_char(p_idproducto,'999999')) , trim(to_char(p_aux_tasaio,'999999.9999')),
               trim(to_char(p_aux_tasaiod,'999999.9999')) , trim(to_char(p_aux_tasaim,'999999.9999')),
               trim(to_char(fc,'DD/MM/YYYY')) , trim(to_char(p_fecha_hoy,'DD/MM/YYYY'))];
    c := sai_tasasvariables(b);
    io_calculado    := 0;
    io_calculado_sd := 0;
    num_vars := sai_not_null(c[1]);
  end if;

  es_sindescuento := FALSE;

  -- Si TIPO_AMORTIZACION = 4 o  5, el interes ya esta -----
  -- calculado en base a la tabla de amortizaciones --------
  if p_tipoamort = 4 or p_tipoamort = 5 then

    es_sindescuento := TRUE;
    select into cant_io_aux, cant_idnc_aux, cant_ieco_aux io, idnc, ieco
    from auxiliares where idorigenp = p_idorigenp and idproducto = p_idproducto
         and idauxiliar = p_idauxiliar;

    if found then io_calculado := io_calculado - cant_io_aux - cant_idnc_aux - cant_ieco_aux; end if;

  else
    io_calculado    := 0;
    io_calculado_cd := 0;
    io_calculado_sd := 0;

    fad := NULL;
    for i in 1..num_vars loop
      if fad is NULL then
        fad := fc;
      else
        fad := c[2+(4*(i-1))]::date;
      end if;
      if (num_vars > i) then
        faa := c[2+(4*i)]::date;
      else
        faa := p_fecha_hoy;
      end if;
      tio := c[3+(4*(i-1))];
      tiod := c[4+(4*(i-1))];
      dt := faa - fad;

      if (dt > 0) then
        -- sin descuento ----
        io_calculado_sd := io_calculado_sd+(p_saldo*(((tio/100)/30)*dt));
        -- con descuento ----
        io_calculado_cd := io_calculado_cd+(p_saldo*(((tiod/100)/30)*dt));
      end if;
    end loop;
  end if;

  x_io_sd := io_calculado_sd + p_aux_io + p_aux_idnc + p_aux_ieco + p_iodif_gar;
-- raise notice '**** (1) fecha_sig_abono: % ****',fecha_sig_abono;

  if p_estatus = 2 and (p_tipoamortizacion = 0 or p_tipoamortizacion = 2 or p_tipoamortizacion = 5) and
    (p_aux_tasaio > 0 or p_aux_tasaiod > 0) and x_io_sd > 0 then

    if p_tipoamortizacion = 5 then
      dias_vencidos_intord :=
        p_fecha_hoy - (select min(vence)
                       from   amortizaciones
                       where  idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and
                              not todopag and io != iopag);
      if dias_vencidos_intord < 0 then
        dias_vencidos_intord := 0;
      end if;
      x_dato1 := NULL;
    else
      x_dato1 := sai_pr_dv_por_interes(p_idorigenp,p_idproducto,p_idauxiliar,x_io_sd,tio,p_saldo,p_fecha_hoy,
                                       p_pagodiafijo,p_fecha_ven,p_periodoabonos,p_fechaprestamo);
    end if;

    if x_dato1 is not NULL and x_dato1 != '' then
      dias_vencidos_intord := sai_token(1,x_dato1,'|')::integer;
      fecha_sig_abono      := sai_token(2,x_dato1,'|')::date;
    end if;

  end if;
-- raise notice '**** (2) fecha_sig_abono: % ****',fecha_sig_abono;
  --- Define los dias vencidos reales ---
  if dias_vencidos_capital < dias_vencidos_intord then
    dias_vencidos := dias_vencidos_intord;
  else
    dias_vencidos := dias_vencidos_capital;
  end if;

  -- ESTE VALOR SE USARA PARA CALCULART LA FECHA SEL SIGUIENTE PAGO EN LOS
  -- PRESTAMOS ADELANTADOS tipoamortizacion 0 Y 2
  dias_interes := 0;
  if p_estatus > 1 then
    if tio > 0 and p_saldo > 0 then
      dias_interes := (((x_io_sd/(tio/100/30))/p_saldo)::numeric(7))::integer;
      if dias_interes < 0 then dias_interes := 0; end if;
    end if;
  end if;

  fecha_sig_abono := fecha_correcta_siguiente_pago(p_idorigenp, p_idproducto, p_idauxiliar, p_fecha_hoy, dias_vencidos,
                                                   dias_interes);
-- raise notice '**** (3) fecha_sig_abono: % ****',fecha_sig_abono;
  dias_inhabiles := 0;
  if hay_dias_inhabiles and dias_vencidos > 0 then
    select into dias_inhabiles count(*) from tablas where idtabla = 'dias_no_validos_para_pagos' and
                date(idelemento) between (p_fecha_hoy - dias_vencidos) and p_fecha_hoy;
    if not found or dias_inhabiles is null then dias_inhabiles := 0; end if;
  end if;

  --- Si hay DV ya no hay descuento y define el io_calculado ---
  if p_tipoamortizacion = 0 or p_tipoamortizacion = 2 then
    es_sindescuento := FALSE;
    if dias_vencidos_intord > 0 or dias_vencidos_capital > 0 then es_sindescuento := TRUE; end if;

    if es_sindescuento and dias_inhabiles > 0 then
      if dias_vencidos <= dias_inhabiles then es_sindescuento := FALSE; end if;
    end if;

    if es_sindescuento then
      io_calculado := io_calculado_sd + p_iodif_gar;
      dif_descto_io := 0.00;
    else
      io_calculado := io_calculado_cd;
      dif_descto_io := io_calculado_sd - io_calculado_cd;
    end if;
  end if;

  -- Clasifica la cartera ------------------------------------------------------
  estatusc := p_cartera;

  es_revolvente := FALSE;
  select into r_prevol *
  from        tablas
  where       idtabla = 'param' and idelemento = 'prestamos_revolventes';
  if found then
    if r_prevol.dato1 = '1' then
      es_revolvente := exists(select *
                              from   limite_de_credito
                              where  idorigen = p_idorigen and
                                     idgrupo = p_idgrupo and
                                     idsocio = p_idsocio and
                                     (idproducto = p_idproducto or idproducto = 39999));
    end if;
    if not es_revolvente then
      es_revolvente := (sai_texto1_like_texto2(p_idproducto::text,NULL, r_prevol.dato2,'|') > 0);
    end if;
    if es_revolvente then
      max_dias := case when r_prevol.dato3 is null or r_prevol.dato3 = ''
                       then -1
                       else r_prevol.dato3::text::integer
                  end;
      if max_dias = -1 then
        es_revolvente := FALSE;
      end if;
    end if;
  end if;

  es_ven_7_21_15_45 := FALSE;
  /*--- Siendo Cooperativa... ---*/
  select into es_ven_7_21_15_45
              case when dato1 = '1'
                   then TRUE
                   else FALSE
              end
  from        tablas
  where       idtabla = 'param' and idelemento = 'vencimiento_7_21_15_45';

  /*--- ... Manipula el parametro "max_dias" ----*/
  if not es_revolvente then
    with amort_x
      as (select * from amortizaciones where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar)
    select into x_con_capital, x_total_amorts
                (select count(*) from amort_x where abono > 0),
                (select count(*) from amort_x);
    max_dias := case when x_con_capital = 1 and x_total_amorts = 1
                     then 29
                     when x_con_capital = 1 and x_total_amorts > 1
                     then case when dias_vencidos_capital >= 30 then 29 else max_dias end
                     else max_dias
                end;
    if es_ven_7_21_15_45 then
      max_dias := case when p_pagodiafijo = 0 and p_periodoabonos = 7
                       then 20
                      -- when p_pagodiafijo = 0 and p_periodoabonos = 15
                       when (p_pagodiafijo = 0 and (p_periodoabonos = 14 or p_periodoabonos = 15)) or p_pagodiafijo = 2
                       then 44
                       else max_dias
                  end;
    end if;
  end if;

  -- AHORA, AQUI SE CALCULA LA FECHA LIMITE. YA NO, ARRIBA !!!
  fecha_limite := p_fecha_hoy + (max_dias - 1);

/* ::::::: COMO ESTABA ANTES HASTA LA VERSION 1.42.0 :::::::::::::::::::::::::::::::::
  if es_caja then -- SOLO COOPERATIVAS
    if not es_revolvente then
      with amort_x
        as (select *
            from   amortizaciones
            where  idorigenp = p_idorigenp and idproducto = p_idproducto and
                   idauxiliar = p_idauxiliar)
      select into x_con_capital, x_total_amorts
                  (select count(*)
                   from   amort_x
                   where  abono > 0),
                  (select count(*)
                   from   amort_x);
      max_dias := case when x_con_capital = 1 and x_total_amorts = 1
                       then 29
                       when x_con_capital = 1 and x_total_amorts > 1
                       then case when dias_vencidos_capital >= 30
                                 then 29
                                 when dias_vencidos_intord >= 90
                                 then 89
                                 else 29
                            end
                       else case when p_pagodiafijo = 0 and p_periodoabonos = 7
                                      then 20
                                 -- when p_pagodiafijo = 0 and p_periodoabonos = 15
                                 when (p_pagodiafijo = 0 and (p_periodoabonos = 14 or p_periodoabonos = 15)) or p_pagodiafijo = 2
                                      then 44
                                 else 89
                            end
                  end;
    end if;
::::::: COMO ESTABA ANTES HASTA LA VERSION 1.42.0 ::::::::::::::::::::::::::::::::: ----*/

  select into r_paso *
  from        tablas
  where       idtabla = 'dias_no_validos_para_pagos' and
              (idelemento = trim(to_char(p_fecha_hoy,'dd/mm/yyyy')) or idelemento = trim(to_char(p_fecha_hoy,'dd/mm/yy')));
  es_dia_inhabil := found;

  -- Tratamiento de las Renovaciones y Reestructaciones ------------------------------------------------------------------------------
    -- Busca la renovacion (ref.opa) NOTA: ARRIBA YA BUSCO SI ES UN PRESTAMO APOYADO
  if ((p_tipoprest = 1 or p_tipoprest = 2) and not es_prestamo_apoyado) or p_tipoprest = 5 then --tp=5 Es prestamo de apoyo covid
    
    found_refer := FALSE;
    
    select
    into   refer *
    from   referenciasp
    where  idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and
           tiporeferencia in (2,3);
    if found then
     found_refer = TRUE;
    end if;
  end if;

    -- Evalua la herencia
  dv_heredados := 0;
  x_pnc_covid_es_apoyo := FALSE;
  if ((p_tipoprest = 1 or p_tipoprest = 2) and not es_prestamo_apoyado) or p_tipoprest = 5 or es_prestamo_apoyado then
    
    if found_refer then
      if refer.referencia is NULL or sai_token(1,refer.referencia,'|') is NULL or sai_token(1,refer.referencia,'|') = '' then
        dv_heredados := 0;
      else
        dv_heredados := int4(sai_token(1,refer.referencia,'|'));
      end if;
    end if;

    if p_tipoprest = 5 and dv_heredados > 0 then
      select
      into   r_paso *
      from   prestamo_covid_normal_eps
      where  idorigenp_c = p_idorigenp and idproducto_c = p_idproducto and idauxiliar_c = p_idauxiliar;
      if found then
        if r_paso.ceps_normal or r_paso.ceps_covid then
          dv_heredados = 0;
        end if;
        x_pnc_covid_es_apoyo := r_paso.covid_es_apoyo; -- Esto es para los prestamos tipo covid, pero no son de apoyo.
      end if;                                          -- Renovacion Comun tipo covid ( Caso San Isidro )
    end if;

    if (p_tipoprest != 5 or (p_tipoprest = 5 and not x_pnc_covid_es_apoyo)) and c_atiempo < 3 then
      dias_vencidos := dias_vencidos + dv_heredados;
    end if;
  end if;

  -- Tratamiento del estatus de Cartera segun los dias vencidos --------------------------------------------------------
  if not es_dia_inhabil then
    estatusc := case when dias_vencidos = 0
                     then 'C'
                     when dias_vencidos > max_dias
                     then 'V'
                     when dias_vencidos <= max_dias and p_cartera != 'V'
                     then 'M'
                     else 'V'
                end;
  else
    estatusc := case when dias_vencidos = 0
                     then 'C'
                     else p_cartera
                end;
  end if;


  ------------------------------------------------------------------------------
  -- AQUI SE HACE EL CALCULO DEL INTERES MORATORIO SI ES POR TODO EL SALDO -----
  ------------------------------------------------------------------------------
/*--- CALCULO ORIGINAL ---------------------------------------------------------
  if im_usar_saldo and dias_vencidos_capital > 0 then
    im_calculado := 0;
    dt := p_fecha_hoy - p_fecha_umi;
    im_calculado := p_saldo*(((p_aux_tasaim/100)/30)*dt);
  end if;
------------------------------------------------------------------------------*/
  if im_usar_saldo and dias_vencidos_capital > 0 then
    im_calculado := 0;
    if p_cartera != 'C' then dt := p_fecha_hoy - p_fecha_umi;
    else

      -- EN EL CASO DE UNA PROYECCION, LA FECHA DE HOY PUEDE SER -----
      -- DIFERENTE A LA DE TRABAJO Y SE TIENE QUE CALCULAR DE OTRA ---
      -- FORMA LA CANTIDAD DE DIAS PARA EL INTERES MORATORIO ---------
      select into fecha_trabajo distinct fechatrabajo from origenes limit 1;
      if not found or fecha_trabajo is null then fecha_trabajo := p_fecha_hoy;
      end if;

      if fecha_trabajo = p_fecha_hoy then dt := p_fecha_hoy - p_fecha_umi;
      else
        x1 := 0; x2 := 0;

        -- HAY AMORTIZACIONES ENTRE HOY Y LA FECHA DE PROYECCION ?? ------------
        select into x1 count(*) from amortizaciones
        where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and
              vence between fecha_trabajo and p_fecha_hoy;
        if not found or x1 is null then x1 := 0; end if;

        -- HAY AMORTIZACIONES PAGADAS ENTRE HOY Y LA FECHA DE PROYECCION ?? ----
        select into x2 count(*) from amortizaciones
        where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and todopag and
              vence between fecha_trabajo and p_fecha_hoy;
        if not found or x2 is null then x2 := 0; end if;

        if x1 = 0 then dt := p_fecha_hoy - p_fecha_umi;
        else
          if x1 = x2 then dt := 0;
          else
            select into fechax vence from amortizaciones
            where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and not todopag and
                  vence between fecha_trabajo and p_fecha_hoy
            order by vence limit 1;
            if not found or fechax is null then dt := p_fecha_hoy - p_fecha_umi;
            else
              dt := p_fecha_hoy - fechax;
            end if;
          end if;
        end if;
      end if;
    end if;

    im_calculado := p_saldo*(((p_aux_tasaim/100)/30)*dt);
  end if;

  -- Pagos Fijos e Hipotecarios ------------------------------------------------
  if p_tipoamort = 4 or p_tipoamort = 5 then
    --- Si el dia de pago es el mismo dia que se aperturo ---
    --- el prestamo, los intereses deben ser CERO -----------
    --- LEON FRANCO SOLICITO QUE EL MISMO DIA DE LA ENTREGA SE PUEDA ABONAR PERO
    --- SE OCUPA TAMBIEN QUE EL INTERES NO SEA CERO (JFPA, 20/DICIEMBRE/2018)

    x1 := 0;
    px1 := '%'||text(p_idproducto)||'%';
    select into x1 count(*) from tablas
    where lower(idtabla) = 'param' and lower(idelemento) = 'abono_mismo_dia_de_la_entrega' and
          (dato2 is NULL or dato2 like px1);
    if not found or x1 is NULL then x1 := 0; end if;

    if p_fechaprestamo = p_fecha_hoy and x1 = 0 then io_calculado := 0.0; end if;
  end if;

  if fecha_sig_abono is NULL then fecha_sig_abono := date(now()); end if;
-- raise notice '**** (4) fecha_sig_abono: % ****',fecha_sig_abono;
  ------------------------------------------------------------------------------
  -- ULTIMA MODIFICACION : 30/DICIEMBRE/2016 -----------------------------------
  ------------------------------------------------------------------------------

  -- Resultado -----------------------------------------------------------------
  result := array[
            trim(to_char(fecha_limite,'DD/MM/YYYY'))          ,  -- 1
            trim(to_char(dias_vencidos_capital,'99990'))      ,  -- 2
            trim(to_char(dias_vencidos_intord,'99990'))       ,  -- 3
            trim(to_char(monto_vencido,'999999990.00'))       ,  -- 4
            trim(to_char(io_calculado,'999999990.00'))        ,  -- 5
            trim(to_char(monto_por_vencer,'999999990.00'))    ,  -- 6
            trim(to_char(monto_bonificacion,'999999990.00'))  ,  -- 7
            trim(to_char(im_calculado,'999999990.00'))        ,  -- 8
            trim(to_char(abonos_vencidos,'999.99'))           ,  -- 9
            trim(to_char(fecha_sig_abono,'DD/MM/YYYY'))       ,  -- 10
            estatusc                                          ,  -- 11
            trim(to_char(dif_descto_io,'999999990.00'))       ,  -- 12
            trim(to_char(x_tol_int_mor,'99'))                 ,  -- 13
            trim(to_char(comision_np_calc,'999999990.00'))    ,  -- 14
            trim(to_char(c_atiempo,'9'))                      ,  -- 15
            trim(to_char(max_dias,'9999'))                    ,  -- 16
            trim(to_char(dias_vencidos,'99990'))              ,  -- 17
            text(dv_heredados)                                ,  -- 18
            text(es_prestamo_apoyado)];                          -- 19
  return result;
end;
$$ language 'plpgsql';

-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

/*------------------------------------------------------------------------------
 Esta funcion realiza calculos a un auxiliar tipo Ahorros y retorna lo sig.:

  >> Diagrama del parametro de retorno:

  ----------------------------------------------------------------------------
  2|04/03/2004|3|67|2366.13|0|1349.45|0.00|15/01/2006|85.18|05/06/2004|788.71|
  -|----------|-|--|-------|-|-------|----|----------|-----|----------|------|
  1      2     3  4    5    6    7      8       9       10      11       12
  --------------------------------------------------------------
  952.06|M|0.00|85.18|01/06/2004|202.42|12.78|0.00|100.00|300.00
  ------|-|----|-----|----------|------|-----|----|------|------
    13  14  15    16      17       18     19   20    21     22

   1 - tipo_producto           :2
   2 - fechaumi                :04/03/2004
*  3 - abonos_vencidos         :3
*  4 - dias_vencidos           :67
*  5 - monto_vencido           :2366.13
   6 - dias_vencidos_intord    :0
   7 - monto_io_total          :1349.45
   8 - monto_bonificacion      :0.00
   9 - fecha_vencimiento       :15/01/2006
* 10 - im_calculado            :85.18
  11 - fecha_sig_abono         :05/06/2004
* 12 - monto_por_vencer        :788.71
  13 - io_calculado            :952.06
  14 - estatus_cartera         :M
  15 - idnc_calculado          :0.00
* 16 - monto_im_total          :85.18
  17 - fecha_limite            :01/06/2004
  18 - iva_io_total            :202.42
* 19 - iva_im_total            :12.78
  20 - dif_descto_io           :0.00
  21 - comision_np_calc        :100.00 (1 comision, la actual)
  22 - comision_np_total       :300.00 (3 comsiones no pagadas)
  23 - dias_vencidos_capital   :67
------------------------------------------------------------------------------*/
create or replace function
sai_auxiliar_pr (refcursor,date,date,integer,numeric,numeric,integer,boolean)
returns text as $$
declare
  -- Parametros
  p_cursor    alias for $1;
  p_defecha   alias for $2;
  p_afecha    alias for $3;
  p_tc        alias for $4; -- NO SE USA
  p_debug     alias for $7; -- NO SE USA
  p_actualiza alias for $8; -- NO SE USA

  -- Varables ------------------
  p_iva_io              numeric;
  p_iva_im              numeric;

  fecha_vencimiento     date;
  fecha_limite          date;
  defecha               date;
  dias_vencidos_capital integer;
  dias_vencidos_intord  integer;
  monto_vencido         numeric;
  io_calculado          numeric;
  io_calculado_sd       numeric;
  idnc_calculado        numeric;
  monto_por_vencer      numeric;
  monto_bonificacion    numeric;
  im_calculado          numeric;
  abonos_vencidos       numeric;
  fecha_sig_abono       date := NULL;
  estatus_cartera       char; -- estatus cartera: C,M,V, --
  monto_io_total        numeric;
  monto_im_total        numeric;
  iva_io_total          numeric;
  iva_im_total          numeric;
  tasaio                numeric;
  tasaiod               numeric;
  dif_descto_io         numeric;
  x_tol_int_mor         integer;
  cont                  integer;
  aux                   RECORD;
  a                     _text;
  b                     _text;
  fecha_activ           date;
  val_interval          text;
  r_paso                record;
  comision_np_calc      numeric;
  comision_np_total     numeric;

  r_int2009             record;
  idnc_2009             numeric;
  ieco_2009             numeric;
  im_2009               numeric;
  p_iva_io_2009         numeric;
  p_iva_im_2009         numeric;

  x_mtoiva_2009         numeric;
  x_mtoiva              numeric;

  monto_fijo            numeric;
  dif                   numeric;
  fecha_hoy             date;
  dias_vencidos         numeric;
  dv_heredados          integer;
  x_dt                  integer;
  x_fecha_ini           date;
  x_fecha_ini_dv        date;
  x_fmin                date;
  x_mons                integer;
  x_days                integer;
  x_tasaio              numeric;
  refer                 record;
  c_atiempo             integer;
  max_dias              integer;
  es_prestamo_apoyado   boolean;
  -- Usado en Suspencion de MORA --
  hay_dias_inhabiles    boolean;

  todos_los_pagos_iguales_15na boolean;
begin
  fecha_hoy := p_afecha;
  fetch p_cursor into aux;

  p_iva_io := $5;
  p_iva_im := $6;

  idnc_calculado = 0; todos_los_pagos_iguales_15na := FALSE;

  /*--- Prorroga del 15 del iva, segun la tabla -----------------------*/
  if aux.fechaactivacion is not NULL and (date('31/12/2009') - aux.fechaactivacion) >= 0 then
    select into r_paso * from tablas where idtabla = 'param' and idelemento = 'prorroga_iva_15';
    if found and r_paso.dato1 is not NULL and r_paso.dato1 != '' then
      if (date(r_paso.dato1) - fecha_hoy) >= 0 then
        if p_iva_io > 0 then p_iva_io := p_iva_io - 1; end if;
        if p_iva_im > 0 then p_iva_im := p_iva_im - 1; end if;
      end if;
    end if;
  end if;

--------------------------------------------------------------------------------
-- NUEVO -- NUEVO -- NUEVO -- NUEVO -- NUEVO -- NUEVO -- NUEVO -- NUEVO -- NUEVO
--------------------------------------------------------------------------------
  if aux.estatus > 2 then

    fecha_activ := aux.fechaactivacion;

    select
    into     fecha_vencimiento vence
    from     (select *
              from   amortizaciones
              where  idorigenp = aux.idorigenp and idproducto = aux.idproducto and idauxiliar = aux.idauxiliar
              union
              select *
              from   amortizaciones_h
              where  idorigenp = aux.idorigenp and idproducto = aux.idproducto and idauxiliar = aux.idauxiliar) as am
    order by idamortizacion desc
    limit    1;
    if not found then fecha_vencimiento := null; end if;

    if fecha_vencimiento is null then

      if aux.pagodiafijo = 1 then
        val_interval := aux.plazo||' month';
        fecha_vencimiento := date(fecha_activ + val_interval::interval);
      else
        if aux.periodoabonos > 0 then
          fecha_vencimiento := fecha_activ + (aux.plazo * aux.periodoabonos)::integer;
        else
          fecha_vencimiento := sai_fecha_mas_meses (fecha_activ, aux.plazo);
        end if;
      end if;

    end if;

    if fecha_vencimiento is NULL then fecha_vencimiento := date(now()); end if;

    return text(aux.fechaumi)||'|0|0|0.00|0|0.00|0.00|'||text(fecha_vencimiento)||'|0.00|'||text(date(now()))||
           '|0.00|0.00|C|0.00|0.00|'||text(date(now()))||'|0.00|0.00|0.00|0.00|0.00|0';
  end if;
--------------------------------------------------------------------------------
-- NUEVO -- NUEVO -- NUEVO -- NUEVO -- NUEVO -- NUEVO -- NUEVO -- NUEVO -- NUEVO
--------------------------------------------------------------------------------

  -- Bandera para proceso de Suspencion de MORA (mas abajo) ---------------
  hay_dias_inhabiles := FALSE; cont := 0;
  select into cont count(*) from tablas where lower(idtabla) = 'dias_no_validos_para_pagos';
  if not found or cont is null then cont := 0; end if;
  if cont > 0 then hay_dias_inhabiles := TRUE; end if;

  if hay_dias_inhabiles then
    cont := 0;
    select into cont count(*) from tablas where lower(idtabla) = 'param' and lower(idelemento) = 'eliminar_im_de_dias_inhabiles';
    if not found or cont is null then cont := 0; end if;
    if cont = 0 then hay_dias_inhabiles := FALSE; end if;
  end if;

  /*----------------------------------------------------------------------------
  :: Para calcular la fecha de vencimiento, requiero saber la fecha de
  :: activacion del prestamo. La fecha de activacion es la fecha de arranque
  :: de un prestamo, pero existen circunstancias que varia el origen de esta
  :: fecha, por ejemplo el sistema de pago dia fijo y si la fecha del primer
  :: pago no es a la fecha de entrega.
  :: NOTA : Despues de que varias cajas nos hicieran la observacion de que la
  ::        fecha de vencimiento no coincidia en varios documentos, se determino
  ::        que la fecha mas exacta de vencimiento es la ultima de la tabla de
  ::        amortizaciones (JFPA, 28/JULIO/2015)
  ----------------------------------------------------------------------------*/

  select
  into     fecha_vencimiento vence
  from     amortizaciones
  where    idorigenp = aux.idorigenp and idproducto = aux.idproducto and idauxiliar = aux.idauxiliar
  order by idamortizacion desc
  limit    1;
  if not found then
    fecha_vencimiento := null;
  end if;

  if fecha_vencimiento is null then

    if aux.estatus = 1 then
      if aux.pagodiafijo = 1 then
        select into r_paso * from tablas where idtabla = 'param' and idelemento = 'dias_fechaactivacion_virtual_p';
        if found then
          fecha_activ := date(aux.fechaactivacion - '1 month'::interval);
        else
          fecha_activ := fecha_hoy;
        end if;
      else
        fecha_activ := fecha_hoy;
      end if;
    end if;

    if aux.estatus = 2 then
      if aux.pagodiafijo = 1 then
        fecha_activ := aux.fechaactivacion + int4(aux.periodoabonos);
      else
        fecha_activ := aux.fechaactivacion;
      end if;
    end if;

    if aux.estatus in (1,2) then
      if aux.pagodiafijo = 1 then
        val_interval := aux.plazo||' month';
        fecha_vencimiento := date(fecha_activ + val_interval::interval);
      else
        if aux.periodoabonos > 0 then
          fecha_vencimiento := fecha_activ + (aux.plazo * aux.periodoabonos)::integer;
        else
          fecha_vencimiento := sai_fecha_mas_meses (fecha_activ, aux.plazo);
        end if;
      end if;
    end if;

  end if;

  tasaio  := 0;
  tasaiod := 0;

  tasaio  := aux.tasaio;
  tasaiod := aux.tasaiod;

  /*--- Si la tasa de descto es = 0 o mayor a tasa io, igualar ---*/
  if tasaiod = 0 or tasaiod > tasaio then
    tasaiod = tasaio;
  end if;

  /*----------------------------------------------------------------------------
  :: Prepara las maletas para irnos de vacaciones al la funcion: sai_pr_dv
  :: aqui se calculara varios datos como: los dias vencidos, abonos vencidos,
  :: Int. ordinarios y moratorios calculados, etc. para mayor informacion ver la
  :: funcion que esta posterior a esta.
  ----------------------------------------------------------------------------*/

  b := array[aux.cartera,                                        -- 1
             trim(to_char(aux.idorigenp,'999999')) ,             -- 2
             trim(to_char(aux.idproducto,'99999')) ,             -- 3
             trim(to_char(aux.idauxiliar,'99999999')) ,          -- 4
             trim(to_char(fecha_hoy,'dd/mm/yyyy')) ,             -- 5
             trim(to_char(int4(aux.tipoamortizacion),'9')) ,     -- 6
             trim(to_char(tasaio,'999999.9999')) ,               -- 7
             trim(to_char(tasaiod,'999999.9999')) ,              -- 8
             trim(to_char(aux.tasaim,'999999.9999')) ,           -- 9
             trim(to_char(aux.saldo,'9999999999.99')) ,          -- 10
             trim(to_char(aux.fechaumi,'dd/mm/yyyy')) ,          -- 11
             trim(to_char(aux.montoprestado,'9999999999.99')) ,  -- 12
             trim(to_char(aux.tipoprestamo,'9')) ,               -- 13
             trim(to_char(aux.iodif,'9999999.99')) ,             -- 14

             case when aux.fechaactivacion is NULL
                  then 'NULL'
                  else trim(to_char(aux.fechaactivacion,'dd/mm/yyyy'))
             end ,                                                 -- 15

             trim(to_char(aux.periodoabonos,'9999')) ,            -- 16
             trim(to_char(aux.pagodiafijo,'9')) ,                 -- 17
             trim(to_char(aux.io,'9999999.99')) ,                 -- 18
             trim(to_char(aux.idnc,'9999999.99')) ,               -- 19
             trim(to_char(aux.ieco,'9999999.99')) ,               -- 20

             -- trim(to_char(fecha_vencimiento,'dd/mm/yyyy')) +   -- 21
             case when fecha_vencimiento is NULL
                  then 'NULL'
                  else trim(to_char(fecha_vencimiento,'dd/mm/yyyy'))
             end ,

             trim(to_char(aux.estatus,'9')) ,                     -- 22
             trim(to_char(aux.tipoamortizacion,'9')) ,            -- 23
             trim(to_char(aux.idorigen,'999999')) ,               -- 24
             trim(to_char(aux.idgrupo,'99')) ,                    -- 25
             trim(to_char(aux.idsocio,'99999999'))];              -- 26

  a := sai_pr_dv(b);

  /*--- Retorno del viaje a: sai_pr_dv --------*/
  fecha_limite          := sai_not_null(a[1]);
  dias_vencidos_capital := sai_not_null(a[2]);
  dias_vencidos_intord  := sai_not_null(a[3]);
  monto_vencido         := sai_not_null(a[4]);
  io_calculado          := sai_not_null(a[5]);
  monto_por_vencer      := sai_not_null(a[6]);
  monto_bonificacion    := sai_not_null(a[7]);
  im_calculado          := sai_not_null(a[8]);
  abonos_vencidos       := sai_not_null(a[9]);
  fecha_sig_abono       := sai_not_null(a[10]);
  estatus_cartera       := sai_not_null(a[11]);
  dif_descto_io         := sai_not_null(a[12]);
  x_tol_int_mor         := sai_not_null(a[13]);
  comision_np_calc      := sai_not_null(a[14]);
  c_atiempo             := sai_not_null(a[15]);
  max_dias              := sai_not_null(a[16]);
  dias_vencidos         := sai_not_null(a[17]);
  dv_heredados          := sai_not_null(a[18]);
  es_prestamo_apoyado   := sai_not_null(a[19]);

  ------------------------------------------------------------------------------
  -- COMISION POR NO PAGO TOTAL
  ------------------------------------------------------------------------------
  comision_np_total := coalesce(aux.comision_np,0) + comision_np_calc;

  iva_io_total := 0;
  iva_im_total := 0;
  monto_io_total := 0;
  monto_im_total := 0;
  idnc_2009 := 0;
  ieco_2009 := 0;
  im_2009 := 0;

  if aux.estatus = 2 then
    select into r_int2009 *
           from interes_prestamos_2009
          where idorigenp = aux.idorigen and idproducto = aux.idproducto and
                idauxiliar = aux.idauxiliar;
    if found then
      idnc_2009 := r_int2009.idnc - r_int2009.idnc_pagado;
      ieco_2009 := r_int2009.ieco - r_int2009.ieco_pagado;
      im_2009   := r_int2009.im   - r_int2009.im_pagado;
    end if;
  end if;

  /*--- solo permite calcular interes hasta el fin del prestamo ----*/
  select into r_paso *
         from tablas
        where idtabla = 'param' and
              idelemento = 'solo_calcula_io_hasta_ult_pago';
  if found then
    if fecha_hoy > fecha_vencimiento then
      if aux.fechaumi >= fecha_vencimiento then
        io_calculado := 0;
      else
        io_calculado := ((io_calculado / (fecha_hoy - aux.fechaumi)) *
                         (fecha_vencimiento - aux.fechaumi))::numeric(10,2);
      end if;
    end if;
  end if;

  monto_io_total := aux.io + io_calculado + aux.idnc + aux.ieco;

  -- filtracion del iva ---
  if (idnc_2009 + ieco_2009) > 0 then
    -- Requiere la tasa de iva io ---
    p_iva_io_2009 := sai_tasaiva_io_2009 (aux.idorigenp,aux.idproducto);

    -- (io2009 * 0.15) + (io * 0.16) ---
    x_mtoiva_2009 := (idnc_2009 + ieco_2009) * (p_iva_io_2009/100);
    x_mtoiva      := abs((idnc_2009+ieco_2009)-monto_io_total) * (p_iva_io/100);
    iva_io_total  := round(x_mtoiva_2009 + x_mtoiva, 2);
  else
    iva_io_total := round(monto_io_total * (p_iva_io/100),2);
  end if;

  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- Si existe el caso especial de que es un prestamo con TIPOAMORTIZACION = 5
  -- (Hipotecaria) y el PAGODIAFIJO = 0, puede ser el caso de CREDICLUB donde al
  -- hacer el calculo de los pagos siempre quedaba un centavo mas por redondeo,
  -- por eso agregue esta funcion que calcula el IO e IVA IO como en VENTANILLA
  -- (JFPA, 17/MAYO/2010) ------------------------------------------------------
  ------------------------------------------------------------------------------
  if monto_io_total > 0 and iva_io_total > 0 and aux.tipoamortizacion = 5 then

    if aux.pagodiafijo = 2 then
      todos_los_pagos_iguales_15na := FALSE; cont := 0;
      select into cont case when dato5 = '1' then 1 else 0 end from tablas
      where lower(idtabla) = 'param' AND lower(idelemento) = 'pagos_quincenales_dias_exactos';
      if not found or cont is null then cont := 0; end if;
      if cont = 1 then todos_los_pagos_iguales_15na := TRUE; end if;
    end if;

    monto_io_total:=0.0; iva_io_total:=0.0; monto_fijo:=0.0;

    select into monto_fijo monto from monto_pagos_fijos
    where idorigenp=aux.idorigenp and idproducto=aux.idproducto and
          idauxiliar=aux.idauxiliar;
    if not found or monto_fijo is null then monto_fijo := 0.0; end if;

    if monto_fijo > 0 then
      if no_usar_monto_pagos_fijos(aux.idorigenp, aux.idproducto, aux.idauxiliar, monto_fijo, p_iva_io) then
        monto_fijo := 0.0;
      end if;
    end if;

    for r_paso in
      select x.*
      from ((select a1.idamortizacion,a1.vence,round((a1.io-a1.iopag),2) as io_pagar,a1.abono,a1.io,a1.iopag,
                    round((a1.io-a1.iopag)*((p_iva_io/100.0)),2) as io_iva_pag,a1.abonopag
             from amortizaciones as a1
             where a1.idorigenp=aux.idorigenp and a1.idproducto=aux.idproducto and a1.idauxiliar=aux.idauxiliar and
                   (a1.abono!=a1.abonopag or a1.todopag=FALSE) and a1.vence < fecha_hoy)
            union
            (select a2.idamortizacion,a2.vence,round((a2.io-a2.iopag),2) as io_pagar,a2.abono,a2.io,a2.iopag,
                    round((a2.io-a2.iopag)*((p_iva_io/100.0)),2) as io_iva_pag,a2.abonopag
             from amortizaciones as a2
             where a2.idorigenp=aux.idorigenp and a2.idproducto=aux.idproducto and a2.idauxiliar=aux.idauxiliar and
                   (a2.abono!=a2.abonopag or a2.todopag=FALSE) and a2.vence >= fecha_hoy
             limit 1)) as x
      order by x.vence
    loop
      monto_io_total := monto_io_total + r_paso.io_pagar;
      if monto_fijo > 0 then
        if r_paso.idamortizacion = 1 or es_ultimo_pago(aux.idorigenp,aux.idproducto,aux.idauxiliar,r_paso.vence) or
           (r_paso.abonopag + r_paso.iopag) > 0
        then

          -- SI SE TIENEN PAGOS QUINCENALES DONDE SE ESPECIFICA QUE TODOS LOS --
          -- PAGOS DEBEN SER IGUALES, NO SE DEBE HACER EL CALCULO DEL IO COMO --
          -- SE HACE EN FORMA NORMAL, SINO USANDO EL VALOR QUE EN LA TABLA -----
          -- monto_pagos_fijos (JFPA 19/ENERO/2016) ----------------------------
          if r_paso.idamortizacion = 1 and aux.pagodiafijo = 2 and todos_los_pagos_iguales_15na and
             (r_paso.abonopag + r_paso.iopag) = 0 then
            dif := 0.0;
            dif := (monto_fijo - r_paso.io - r_paso.abono) - round((r_paso.iopag*(p_iva_io/100.0)), 2);
            if dif < 0 then dif := 0; end if;
            if dif < 0.009 then dif := 0; end if;
            iva_io_total := iva_io_total + dif;
          else
            iva_io_total := iva_io_total + r_paso.io_iva_pag;
          end if;

        else
          dif := 0.0;
          dif := (monto_fijo - r_paso.io - r_paso.abono) - round((r_paso.iopag*(p_iva_io/100.0)), 2);
          if dif < 0 then dif := 0; end if;
          if dif < 0.009 then dif := 0; end if;
          iva_io_total := iva_io_total + dif;
        end if;
      else
        iva_io_total := iva_io_total + r_paso.io_iva_pag;
      end if;
    end loop;
  end if;

  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  if dias_vencidos::integer > x_tol_int_mor then

-- ::::::::::::::::::::::::::::::::::::::::::
-- ::: @@@ NUEVA FORMA CALCULAR IM @@@ -- :::
-- ::::::::::::::::::::::::::::::::::::::::::
    select into r_paso *
    from        tablas
    where       idtabla = 'param' and idelemento = 'devengar_interes_moratorio';
    if found then
      monto_im_total := im_calculado + aux.im + aux.idncm + aux.iecom;
    else
      monto_im_total := aux.im + im_calculado;
    end if;


-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- ::::  AQUI PROXIMAMENTE: COMISION PAGO TARDIO !! :::::::::::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

    b := array[text(aux.idorigenp),                -- 1
               text(aux.idproducto),               -- 2
               text(aux.idauxiliar),               -- 3
               text(monto_im_total),               -- 4
               text(dias_vencidos),                -- 5
               text(fecha_hoy),                    -- 6
               text(aux.fechaumi),                 -- 7
               text(p_iva_io),                     -- 8
               case when aux.fechaactivacion is NULL
                    then 'NULL'
                    else text(aux.fechaactivacion)
               end,                                -- 9
               text(aux.tipoamortizacion),         -- 10
               text(tasaio),                       -- 11
               text(tasaiod),                      -- 12
               text(aux.tasaim)];                  -- 13
--raise notice '1) monto_im_total: %', monto_im_total;
    monto_im_total := sai_comision_pago_tardio (b);
--raise notice '2) monto_im_total: %', monto_im_total;

    -- Suspencion de MORA, 1 dia despues de los dias inhabiles ---------------
    if hay_dias_inhabiles and (dias_vencidos::integer - dv_heredados) between 1 and 7 then
      select
      into   cont count(*)
      from   tablas
      where  lower(idtabla) = 'dias_no_validos_para_pagos' and
             date(idelemento) between (fecha_hoy - (dias_vencidos::integer - dv_heredados)) and
                                      (fecha_hoy - 1);
      if not found or cont is null then cont := 0; end if;

      if cont = (dias_vencidos::integer - dv_heredados) then
        monto_im_total        := 0.0;
        im_calculado          := 0.0;
        if dv_heredados > 0 then
          dias_vencidos       := dv_heredados::numeric;
        else
          dias_vencidos       := 0;
          estatus_cartera     := 'C';
        end if;
        dias_vencidos_intord  := 0;
        abonos_vencidos       := 0.00;
        monto_vencido         := 0.00;
        dias_vencidos_capital := 0;
      end if;
    end if;
--raise notice '<-- dias_vencidos: %', dias_vencidos;

    -- filtracion del iva ---
    if im_2009 > 0 then
      -- Requiere la tasa de iva im ---
      p_iva_im_2009 := sai_tasaiva_io_2009 (aux.idorigenp,aux.idproducto);
      -- (im2009 * 0.15) + (im * 0.16) ---
      x_mtoiva_2009 := im_2009 * (p_iva_im_2009/100);
      x_mtoiva      := abs(im_2009 - monto_im_total) * (p_iva_im/100);
      iva_im_total  := round(x_mtoiva_2009 + x_mtoiva, 2);
    else
      iva_im_total := round(monto_im_total * (p_iva_im/100), 2);
    end if;
  end if;
  -- Si aun no liquida en su totalidad los intereses, estando Vencido, no puede regresar a Corriente
--  if aux.cartera = 'V' and estatus_cartera = 'C' and (monto_im_total > 0 or monto_io_total > 0) then
  if aux.cartera = 'V' and estatus_cartera = 'C' and (aux.idnc + aux.ieco + aux.idncm + aux.iecom) > 0 then
    estatus_cartera := 'V';
  end if;

  --Esto pasa cuando las fechas de calculo estan al reves (algunos casos SAI3)--
  if fecha_vencimiento is NULL then fecha_vencimiento := date(now()); end if;

  if aux.estatus in (0,1,3,4) then
    dias_vencidos := 0;
    dias_vencidos_capital := 0;
    dias_vencidos_intord := 0;
    abonos_vencidos := 0;
    monto_vencido := 0;
    monto_io_total := 0;
    im_calculado := 0;
    monto_por_vencer := 0;
    io_calculado := 0;
    idnc_calculado := 0;
    monto_im_total := 0;
    iva_io_total := 0;
    iva_im_total := 0;
  end if;

--------------------------------------------------------------------------------
-- ULTIMA MODIFICACION : 30/JUNIO/2016 -----------------------------------------
--------------------------------------------------------------------------------

  return text(aux.fechaumi)          || '|' ||
         text(abonos_vencidos)       || '|' ||
         text(dias_vencidos)         || '|' ||
         text(monto_vencido)         || '|' ||
         text(dias_vencidos_intord)  || '|' ||
         text(monto_io_total)        || '|' ||
         text(monto_bonificacion)    || '|' ||
         text(fecha_vencimiento)     || '|' ||
         text(im_calculado)          || '|' ||
         text(fecha_sig_abono)       || '|' ||
         text(monto_por_vencer)      || '|' ||
         text(io_calculado)          || '|' ||
         text(estatus_cartera)       || '|' ||
         text(idnc_calculado)        || '|' ||
         text(monto_im_total)        || '|' ||
         text(fecha_limite)          || '|' ||
         text(iva_io_total)          || '|' ||
         text(iva_im_total)          || '|' ||
         text(dif_descto_io)         || '|' ||
         text(comision_np_calc)      || '|' ||
         text(comision_np_total)     || '|' ||
         text(dias_vencidos_capital) || '|' ||
         text(dv_heredados)          || '|' ||
         case when es_prestamo_apoyado
              then 't'
              else 'f'
         end                         || '|' ||
         case when c_atiempo >= 3
              then 't'
              else 'f'
         end;
end;
$$ language 'plpgsql';
comment on function sai_auxiliar_pr(refcursor,date,date,int,numeric,numeric,int,
                                    boolean)
is 'Calcula el INTERES de un auxiliar de prestamo (SAICoop)';
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::                                                                                      ::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::                                      F  I  N                                         ::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::                                                                                      ::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


-- Esta funcion traspasa los datos de un prestamo que esta en el historial de --
-- auxiliares a las tablas normales, ya que se pudo haber seleccionado para ----
-- hacerle un ajuste y no tener que hacer cambios mas fuertes en las funciones -
-- donde se manejan estos calculos. --------------------------------------------
create or replace function
sai_revive_prestamo(integer,integer,integer) returns integer as $$
DECLARE
  p_idorigenp  alias for $1;
  p_idproducto alias for $2;
  p_idauxiliar alias for $3;
  contador     integer;
BEGIN

  contador := 0;
  SELECT INTO contador COUNT(*) FROM auxiliares WHERE idorigenp=p_idorigenp AND
         idproducto=p_idproducto AND idauxiliar=p_idauxiliar;
  IF NOT FOUND OR contador IS NULL THEN contador := 0; END IF;
  IF contador > 0 THEN
    RAISE NOTICE 'YA ESTA EN AUXILIARES !!!';
    RETURN 1;
  END IF;

  contador := 0;
  SELECT INTO contador COUNT(*) FROM auxiliares_h
  WHERE idorigenp=p_idorigenp AND idproducto=p_idproducto AND
        idauxiliar=p_idauxiliar;
  IF NOT FOUND OR contador IS NULL THEN contador := 0; END IF;
  IF contador <= 0 THEN
    RAISE NOTICE 'NO ESTA EN AUXILIARES NI EN AUXILIARES_H !!!';
    RETURN 0;
  END IF;

  -- auxiliares -----------------------------------------------------------------------------------------------
  INSERT INTO auxiliares
              (SELECT *
               FROM   auxiliares_h
               WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar);

  -- amortizaciones -------------------------------------------------------------------------------------------
  INSERT INTO amortizaciones
              (SELECT *
               FROM   amortizaciones_h
               WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar);
  DELETE
  FROM   amortizaciones_h
  WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar;

  -- auxiliares_d ---------------------------------------------------------------------------------------------
  INSERT INTO auxiliares_d
              (SELECT *
               FROM   auxiliares_d_h
               WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar);
  DELETE
  FROM   auxiliares_d_h
  WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar;


  -- balancecred ----------------------------------------------------------------------------------------------
  INSERT INTO balancecred
              (SELECT *
               FROM   balancecred_h
               WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar);
  DELETE
  FROM   balancecred_h
  WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar;

  -- evaluacion_crediticia ------------------------------------------------------------------------------------
  INSERT INTO evaluacion_crediticia
              (SELECT *
               FROM   evaluacion_crediticia_h
               WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar);
  DELETE
  FROM   evaluacion_crediticia_h
  WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar;

  -- evaluacion_crediticia_d ----------------------------------------------------------------------------------
  INSERT INTO evaluacion_crediticia_d
              (SELECT *
               FROM   evaluacion_crediticia_d_h
               WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar);
  DELETE
  FROM   evaluacion_crediticia_d_h
  WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar;

  -- requisitossocios -----------------------------------------------------------------------------------------
  INSERT INTO requisitossocios
              (SELECT *
               FROM   requisitossocios_h
               WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar);
  DELETE
  FROM   requisitossocios_h
  WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar;

  -- retencion_ide --------------------------------------------------------------------------------------------
  INSERT INTO retencion_ide
              (SELECT *
               FROM   retencion_ide_h
               WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar);
  DELETE
  FROM   retencion_ide_h
  WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar;

  -- carteravencida_historial ---------------------------------------------------------------------------------
  INSERT INTO carteravencida_historial
              (SELECT *
               FROM   carteravencida_historial_h
               WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar);
  DELETE
  FROM   carteravencida_historial_h
  WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar;

  -- Borrado de auxiliares  -----------------------------------------------------------------------------------
  DELETE
  FROM   auxiliares_h
  WHERE  idorigenp = p_idorigenp AND idproducto = p_idproducto AND idauxiliar = p_idauxiliar;

  RETURN 1;
END;
$$ language 'plpgsql';

/*------------------------------------------------------------------------------
 LAS FUNCIONES DE ABAJO IGUAL PARECE QUE SON DEL JAIME CHARLES Y AL
 PARECER NO SE UTILIZAN, IGUALMENTE BUSCAR INDICIOS EN LOS PRGS.
------------------------------------------------------------------------------*/
-- Detalla el calculo de interes a los prestamos.
-- Simula calculo en base a movimientos reales del socio
create or replace function
sai_pr_dci (int, int, int, date, int) returns integer as '
DECLARE
  -- Parametros
  p_idorigenp  ALIAS FOR $1;
  p_idproducto ALIAS FOR $2;
  p_idauxiliar ALIAS FOR $3;
  p_afecha     ALIAS FOR $4;
  p_debug      ALIAS FOR $5;

BEGIN
  -- Trabajar sobre tablas temporales para la simulacion -----------------------
  CREATE LOCAL TEMP TABLE auxiliares AS
    SELECT * FROM auxiliares
            WHERE idorigenp  = p_idorigenp  AND
                  idproducto = p_idproducto AND
                  idauxiliar = p_idauxiliar;
  CREATE LOCAL TEMP TABLE amortizaciones AS
    SELECT * FROM amortizaciones
            WHERE FALSE LIMIT 0;

  PERFORM sair_auxiliar_pr (p_idorigenp, p_idproducto, p_idauxiliar, p_afecha,
                            p_debug);
  -- Elimina tablas temporales (no las reales) ---------------------------------
  DROP TABLE auxiliares;
  DROP TABLE amortizaciones;
  RETURN 0;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION sai_pr_dci (int, int, int, date, int)
  IS 'Detalla calculo de interes a los prestamos mediante un simulacion.';

-- Distribuye un abono de capital o interes en el plan de amortizaciones -------
CREATE OR REPLACE FUNCTION
sai_pr_amortiza_abono (int,int,int,numeric,numeric) RETURNS integer AS '
DECLARE
  -- Parametros
  p_idorigenp  ALIAS FOR $1;
  p_idproducto ALIAS FOR $2;
  p_idauxiliar ALIAS FOR $3;

  -- Variables
  acapital  NUMERIC;
  aio       NUMERIC;
  xabonopag NUMERIC;
  xio       NUMERIC;
  resto     NUMERIC;

  pa        RECORD;
BEGIN
  acapital := $4;
  aio      := $5;
  FOR pa in SELECT * FROM amortizaciones
                    WHERE idorigenp  = p_idorigenp  AND
                          idproducto = p_idproducto AND
                          idauxiliar = p_idauxiliar AND
                         ((abono <> abonopag) OR         -- Abono no pagoado o
                          (io > 0))                      -- intereses pendientes
                 ORDER BY idorigenp,idproducto,idauxiliar,idamortizacion
                          LOOP
    -- A Capital ---------------------------------------------------------------
    xabonopag := pa.abonopag;
    resto := (pa.abono - pa.abonopag);
    IF (acapital > 0) AND (resto > 0) THEN
      IF (resto <= acapital) THEN -- Se termina de cubrir el abono
        xabonopag := pa.abono;
        acapital  := acapital - resto;
      ELSE -- Se cubre solo una parte del abono
        xabonopag := pa.abonopag + acapital;
        acapital  := 0;
      END IF;
    END IF;

    -- A Interes Ordinario -----------------------------------------------------
    xio := pa.io;
    resto := (pa.io);
    IF (aio > 0) AND (resto > 0) THEN
      IF (resto <= aio) THEN -- Se termina de cubrir el interes
        xio := 0;
        aio := aio - resto;
      ELSE -- Se cubre solo una parte del interes
        xio := pa.io - aio;
        aio := 0;
      END IF;
    END IF;

    -- Actualiza la Base de datos
    UPDATE amortizaciones
       SET abonopag = xabonopag,
           io       = xio
     WHERE idorigenp      = p_idorigenp  AND
           idproducto     = p_idproducto AND
           idauxiliar     = p_idauxiliar AND
           idamortizacion = pa.idamortizacion;

    -- Terminado?
    EXIT WHEN (acapital <= 0 AND aio <= 0);
  END LOOP;
  RETURN 0;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION sai_pr_amortiza_abono (int,int,int,numeric,numeric)
  IS 'Distribuye un abono de capital y/o interes en el plan de amortizaciones';

/*--- Condonacio masiva de interes al prestamo -------------------------------*/
create or replace function --rev 8.4
sai_condonacion_masiva (integer,text,integer) returns integer as $$
declare
  p_idorigenc     alias for $1;
  p_nomarch       alias for $2;
  p_idusuario     alias for $3;
  r_cond          record;
  r_aux           record;
  r_ctas          record;
  x_resp          integer;
  paso            text;
  exist_ctasord   boolean;
  fecha_hoy       date;
  x_io            numeric;
  x_aio           numeric;
  x_im            numeric;
  x_aim           numeric;
  x_mov           integer;
  x_concepto      text;
  x_periodo       varchar;
  x_npoliza       integer;
  x_stp           numeric;
  x_tp            integer;
  x_a_idorigenp   integer;
  x_a_idproducto  integer;
  x_a_idauxiliar  integer;
  x_d_idorigenp   integer;
  x_d_idproducto  integer;
  x_d_idauxiliar  integer;
  x_mat           _text;
  x_dv            integer;
  x_mven          numeric;

begin

  select into fecha_hoy date(fechatrabajo) from origenes limit 1;

  select into x_tp coalesce(case when dato5 is NULL or trim(dato5) = ''
                                 then 0
                                 else int4(dato5)
                            end, 0)
    from tablas as t
   where t.idtabla = 'param' and t.idelemento = 'condonaciones';

  if x_tp = 0 then
    -- Valida que las cuentas contables de orden para condonacion existan ------
    select into exist_ctasord
                case when x.c1 like '0' or x.c2 like '0' or
                     x.c3 like '0' or x.c4 like '0'
                     then FALSE
                     else TRUE
                end
           from (select case when exists (select c.*
                                            from cuentas as c
                                           where c.idcuenta = t.dato1 and
                                                 c.clase = 5 and tipo = 6)
                             then dato1
                             else '0'
                        end as c1,
                        case when exists (select c.*
                                            from cuentas as c
                                           where c.idcuenta = t.dato2 and
                                                 c.clase = 5 and tipo = 7)
                             then dato2
                             else '0'
                        end as c2,
                        case when exists (select c.*
                                            from cuentas as c
                                           where c.idcuenta = t.dato3 and
                                                 c.clase = 5 and tipo = 6)
                             then dato3
                             else '0'
                        end as c3,
                        case when exists (select c.*
                                            from cuentas as c
                                           where c.idcuenta = t.dato4 and
                                                 c.clase = 5 and tipo = 7)
                             then dato4
                             else '0'
                        end as c4
                   from tablas as t
                  where t.idtabla = 'param' and
                        t.idelemento = 'condonaciones') as x;
    if not exist_ctasord then
      paso := 'NO ESTAN DEFINIDAS LAS CUENTAS DE ORDEN PARA LA CONDONACION '||
              '\nDE LOS INTERESES ORDINARIOS Y MORATORIOS.';
      raise notice '|MSG3|%', paso;
      raise exception '<';
    end if;
  end if;
  if x_tp = 1 then
    -- Valida que las producto de orden para condonacion existan ------
    select into exist_ctasord (x.c1 and x.c2 and x.c3 and x.c4)
           from (select (exists (select *
                                   from productos as p inner join cuentas as c
                                        on (p.cuentaaplica = c.idcuenta)
                                  where p.idproducto = int4(t.dato1) and
                                        c.clase = 5 and c.tipo = 6)) as c1,
                        (exists (select *
                                   from productos as p inner join cuentas as c
                                        on (p.cuentaaplica = c.idcuenta)
                                  where p.idproducto = int4(t.dato2) and
                                        c.clase = 5 and c.tipo = 7)) as c2,
                        (exists (select *
                                   from productos as p inner join cuentas as c
                                        on (p.cuentaaplica = c.idcuenta)
                                  where p.idproducto = int4(t.dato3) and
                                        c.clase = 5 and c.tipo = 6)) as c3,
                        (exists (select *
                                   from productos as p inner join cuentas as c
                                        on (p.cuentaaplica = c.idcuenta)
                                  where p.idproducto = int4(t.dato4) and
                                        c.clase = 5 and c.tipo = 7)) as c4
                   from tablas as t
                  where t.idtabla = 'param' and
                        t.idelemento = 'condonaciones') as x;
    if not exist_ctasord then
      paso := '1) NO ESTAN DEFINIDOS LOS PRODUCTOS TIPO DEUDOR Y ACREEDOR DE '
                 'ORDEN.\n'
              '2) O ESTAN MAL DEFINIDOS.\n'
              '3) O SE ESTAN USANDO LOS MISMOS PARA LA COND. DE ORDINARIOS Y '
                 'MORATORIOS.\n'
              '4) O LA CUENTA DE APLICACION DE LOS PRODUCTOS NO SON DE TIPO '
                 'ACREEDOR O DEUDOR.\n';
      raise notice '|MSG3|%', paso;
      raise exception '<';
    end if;
  end if;

  -- Crea una tabla de paso ----------------------------------------------------
  begin
    create temp table condonaciones_masivas
    (idorigenp  integer,
     idproducto integer,
     idauxiliar integer,
     ord        integer,
     mor        integer);
  end;

  -- Carga de datos ------------------------------------------------------------
  paso := 'copy condonaciones_masivas from '''||p_nomarch||''' delimiters ''|''';
  execute paso;

  -- Analiza si en realidad se cargaron los OPAs del archivo txt ---------------
  select into x_resp count(*)
         from condonaciones_masivas;
  if x_resp = 0 then
    raise notice '|MSG3|EL ARCHIVO LEIDO ESTA VACIO';
    raise exception '<';
  end if;

  -- VALIDA QUE NO HAYA DUPLICADOS ---------------------------------------------
  select into paso text(idorigenp)||'-'||text(idproducto)||'-'||
                   text(idauxiliar)
    from (select distinct on (idorigenp,idproducto,idauxiliar)
                 idorigenp,idproducto,idauxiliar,
                 (select count(*)
                    from condonaciones_masivas
                   where idorigenp = mc1.idorigenp and
                         idproducto = mc1.idproducto and
                         idauxiliar = mc1.idauxiliar) as veces
            from condonaciones_masivas as mc1) as z
   where veces > 1;

  if found then
    raise notice '|MSG3|EXISTE UN AUXILIAR DUPLICADO: %', paso;
    raise exception '.';
  end if;

  -- Calcula registros a contar para la barra de avance en la aplicacion -------
  x_resp := (x_resp * 6) + 1;
  raise notice '|MSG1|%',x_resp; -- Conteo de los registros a leer

  -- Valida que la informacion de OPAs sea correcta ----------------------------
  for r_cond in select * from condonaciones_masivas
  loop

    raise notice '|MSG2|Validando...';

    select into r_aux *
           from auxiliares
          where idorigenp   = r_cond.idorigenp and
                idproducto  = r_cond.idproducto and
                idauxiliar  = r_cond.idauxiliar;
    if not found then
      raise notice '|MSG3|EL FOLIO: %-%-% NO EXISTE',r_cond.idorigenp,
                   r_cond.idproducto,r_cond.idauxiliar;
      raise exception '<';
    end if;
    if r_aux.estatus != 2 then
      raise notice '|MSG3|EL ESTATUS DEL FOLIO: %-%-%, NO ES ACTIVO',
                   r_cond.idorigenp,r_cond.idproducto,r_cond.idauxiliar;
      raise exception '<';
    end if;

    select into x_resp tipoproducto
           from productos
          where idproducto = r_cond.idproducto;
    if not found then
      paso := 'EL PRODUCTO DEL FOLIO: '||text(r_cond.idorigenp)||'-'||
              text(r_cond.idproducto)||'-'||r_cond.idauxiliar||
              ' NO EXISTE EN LA TABLA DE PRODUCTOS.';
      raise notice '%', paso;
      raise exception '<';
    end if;
    if x_resp != 2 then
      paso := 'EL PRODUCTO DEL FOLIO: '||text(r_cond.idorigenp)||'-'||
              text(r_cond.idproducto)||'-'||r_cond.idauxiliar||
              ' NO ES UN PRESTAMO.';
      raise notice '%', paso;
      raise exception '<';
    end if;
  end loop;

  if x_tp = 0 then
    select into r_ctas case when exists (select c.*
                                           from cuentas as c
                                          where c.idcuenta = t.dato1 and
                                                c.clase = 5 and tipo = 6)
                            then dato1
                            else '0'
                       end as c1,
                       case when exists (select c.*
                                           from cuentas as c
                                          where c.idcuenta = t.dato2 and
                                                c.clase = 5 and tipo = 7)
                            then dato2
                            else '0'
                       end as c2,
                       case when exists (select c.*
                                           from cuentas as c
                                          where c.idcuenta = t.dato3 and
                                                c.clase = 5 and tipo = 6)
                            then dato3
                            else '0'
                       end as c3,
                       case when exists (select c.*
                                           from cuentas as c
                                          where c.idcuenta = t.dato4 and
                                                c.clase = 5 and tipo = 7)
                            then dato4
                            else '0'
                       end as c4
           from tablas as t
          where t.idtabla = 'param' and t.idelemento = 'condonaciones';
  else
    select into r_ctas case when exists (select *
                              from productos as p inner join cuentas as c
                                   on (p.cuentaaplica = c.idcuenta)
                             where p.idproducto = int4(t.dato1) and
                                   c.clase = 5 and c.tipo = 6)
                           then int4(dato1)
                           else 0
                       end as p1,
                       case when exists (select *
                               from productos as p inner join cuentas as c
                                    on (p.cuentaaplica = c.idcuenta)
                              where p.idproducto = int4(t.dato2) and
                                    c.clase = 5 and c.tipo = 7)
                            then int4(dato2)
                            else 0
                       end as p2,
                       case when exists (select *
                               from productos as p inner join cuentas as c
                                    on (p.cuentaaplica = c.idcuenta)
                              where p.idproducto = int4(t.dato3) and
                                    c.clase = 5 and c.tipo = 6)
                            then int4(dato3)
                            else 0
                       end as p3,
                       case when exists (select *
                               from productos as p inner join cuentas as c
                                    on (p.cuentaaplica = c.idcuenta)
                              where p.idproducto = int4(t.dato4) and
                                    c.clase = 5 and c.tipo = 7)
                            then int4(dato4)
                            else 0
                       end as p4
           from tablas as t
          where t.idtabla = 'param' and t.idelemento = 'condonaciones';
  end if;

  x_mov := 0;
  for r_cond in select cm.ord,cm.mor,a.*
                  from condonaciones_masivas as cm inner join auxiliares as a
                       using(idorigenp,idproducto,idauxiliar)
  loop
    paso := sai_auxiliar(r_cond.idorigenp,r_cond.idproducto,r_cond.idauxiliar,
                         date(fecha_hoy));

    x_io := sai_token(7,paso,'|')::numeric;
    x_im := sai_token(16,paso,'|')::numeric;
    x_dv := sai_token(4,paso,'|')::integer;
    x_mven := sai_token(5,paso,'|')::numeric;

    if x_io > 0 or x_im > 0 then
      x_aio := 0;
      x_aim := 0;

      if r_cond.ord = 1 and x_io > 0 then
        x_aio := x_io;
      end if;

      if r_cond.mor = 1 and x_im > 0 then
        x_aim := x_im;
      end if;

      --- Aplicacion al producto prestamo de los I.O. e I.M.
      x_mov := x_mov + 1;
      insert into temporal(idusuario,sesion,idorigen,idgrupo,idsocio,idorigenp,
                           idproducto,idauxiliar,esentrada,acapital,io_pag,
                           io_cal,im_pag,im_cal,idcuenta,aplicado,aiva,abonifio,
                           saldodiacum,ivaio_pag,ivaio_cal,ivaim_pag,ivaim_cal,
                           tipomov,mov,diasvencidos,montovencido)
                    VALUES (p_idusuario,'COND_MASIVAS',r_cond.idorigen,
                           r_cond.idgrupo,r_cond.idsocio,r_cond.idorigenp,
                           r_cond.idproducto,r_cond.idauxiliar,TRUE,0,x_aio,
                           x_aio,x_aim,x_aim,'0',FALSE,0.00,0.00,0.00,0,0,0,
                           0,3,x_mov,x_dv,x_mven);
      raise notice '|MSG2|Aplicando mov: %', x_mov;

      -- Registro del movimiento en Cuentas de Orden tipo 6 y 7 -----
      -- Mediante Cuentas Contables Directamente -----
      if x_tp = 0 then

        --- Aplicacion para los I.O. ------
        if x_aio > 0 then

          --- Abono a Parte Deudora -----
          x_mov := x_mov + 1;
          insert into temporal(idusuario,sesion,idorigen,idgrupo,idsocio,
                               idorigenp,idproducto,idauxiliar,esentrada,
                               acapital,io_pag,io_cal,im_pag,im_cal,idcuenta,
                               aplicado,aiva,abonifio,saldodiacum,ivaio_pag,
                               ivaio_cal,ivaim_pag,ivaim_cal,tipomov,mov)
                       VALUES (p_idusuario,'COND_MASIVAS',r_cond.idorigen,
                               r_cond.idgrupo,r_cond.idsocio,0,1,0,FALSE,x_aio,
                               0,0,0,0,r_ctas.c1,FALSE,0.00,0.00,0.00,0,0,0,0,3,
                               x_mov);
          raise notice '|MSG2|Aplicando mov: %', x_mov;

          --- Cargo a Parte Acreedora -----
          x_mov := x_mov + 1;
          insert into temporal(idusuario,sesion,idorigen,idgrupo,idsocio,
                               idorigenp,idproducto,idauxiliar,esentrada,
                               acapital,io_pag,io_cal,im_pag,im_cal,idcuenta,
                               aplicado,aiva,abonifio,saldodiacum,ivaio_pag,
                               ivaio_cal,ivaim_pag,ivaim_cal,tipomov,mov)
                       VALUES (p_idusuario,'COND_MASIVAS',r_cond.idorigen,
                               r_cond.idgrupo,r_cond.idsocio,0,1,0,TRUE,x_aio,
                               0,0,0,0,r_ctas.c2,FALSE,0.00,0.00,0.00,0,0,0,0,3,
                               x_mov);
          raise notice '|MSG2|Aplicando mov: %', x_mov;
        end if;

        --- Aplicacion para los I.M. ------
        if x_aim > 0 then

          --- Abono a Parte Deudora -----
          x_mov := x_mov + 1;
          insert into temporal(idusuario,sesion,idorigen,idgrupo,idsocio,
                               idorigenp,idproducto,idauxiliar,esentrada,
                               acapital,io_pag,io_cal,im_pag,im_cal,idcuenta,
                               aplicado,aiva,abonifio,saldodiacum,ivaio_pag,
                               ivaio_cal,ivaim_pag,ivaim_cal,tipomov,mov)
                       VALUES (p_idusuario,'COND_MASIVAS',r_cond.idorigen,
                               r_cond.idgrupo,r_cond.idsocio,0,1,0,FALSE,x_aim,
                               0,0,0,0,r_ctas.c3,FALSE,0.00,0.00,0.00,0,0,0,0,3,
                               x_mov);
          raise notice '|MSG2|Aplicando mov: %', x_mov;

          --- Cargo a Parte Acreedora -----
          x_mov := x_mov + 1;
          insert into temporal(idusuario,sesion,idorigen,idgrupo,idsocio,
                               idorigenp,idproducto,idauxiliar,esentrada,
                               acapital,io_pag,io_cal,im_pag,im_cal,idcuenta,
                               aplicado,aiva,abonifio,saldodiacum,ivaio_pag,
                               ivaio_cal,ivaim_pag,ivaim_cal,tipomov,mov)
                       VALUES (p_idusuario,'COND_MASIVAS',r_cond.idorigen,
                               r_cond.idgrupo,r_cond.idsocio,0,1,0,TRUE,x_aim,
                               0,0,0,0,r_ctas.c4,FALSE,0.00,0.00,0.00,0,0,0,0,3,
                               x_mov);
          raise notice '|MSG2|Aplicando mov: %', x_mov;
        end if;

      -- Usando Productos Deudores y Acreedores que apuntan a las -------------
      -- Cuentas de Orden, para llevar tambien el registro al socio -----------
      else

        --- Aplicacion para los I.O. ------
        if x_aio > 0 then

          -- Busca el Folio Deudor y Acreedor --------------------------
          -- si no lo encuenta realiza la Apertura Respectivamente -----

          -- Deudor -------
          select into x_d_idorigenp, x_d_idproducto, x_d_idauxiliar
                      idorigenp, idproducto, idauxiliar
                 from auxiliares
                where idorigen = r_cond.idorigen and
                      idgrupo = r_cond.idgrupo and idsocio = r_cond.idsocio and
                      idproducto = r_ctas.p1 and estatus <= 2;
          if not found then
            x_d_idorigenp  := r_cond.idorigen;
            x_d_idproducto := r_ctas.p1;

            x_mat := array[text(r_cond.idorigen) , text(r_cond.idgrupo) ,
                           text(r_cond.idsocio) , text(x_d_idorigenp) ,
                           text(x_d_idproducto) , text(fecha_hoy) ,
                           text(p_idusuario) , text(0)];

            x_d_idauxiliar := sai_deudores_diversos_crea_apertura(x_mat);
          end if;

          -- Acreedor -------
          select into x_a_idorigenp, x_a_idproducto, x_a_idauxiliar
                      idorigenp, idproducto, idauxiliar
                 from auxiliares
                where idorigen = r_cond.idorigen and
                      idgrupo = r_cond.idgrupo and idsocio = r_cond.idsocio and
                      idproducto = r_ctas.p2 and estatus <= 2;
          if not found then
            x_a_idorigenp  := r_cond.idorigen;
            x_a_idproducto := r_ctas.p2;

            x_mat := array[text(r_cond.idorigen) , text(r_cond.idgrupo) ,
                           text(r_cond.idsocio) , text(x_a_idorigenp) ,
                           text(x_a_idproducto) , text(fecha_hoy) ,
                           text(p_idusuario) , text(0)];

            x_a_idauxiliar := sai_acredores_diversos_crea_apertura(x_mat);
          end if;

          --- Abono a Parte Deudora -----
          x_mov := x_mov + 1;
          insert into temporal(idusuario,sesion,idorigen,idgrupo,idsocio,
                               idorigenp,idproducto,idauxiliar,esentrada,
                               acapital,io_pag,io_cal,im_pag,im_cal,idcuenta,
                               aplicado,aiva,abonifio,saldodiacum,ivaio_pag,
                               ivaio_cal,ivaim_pag,ivaim_cal,tipomov,mov)
                       VALUES (p_idusuario,'COND_MASIVAS',r_cond.idorigen,
                               r_cond.idgrupo,r_cond.idsocio,x_d_idorigenp,
                               x_d_idproducto,x_d_idauxiliar,FALSE,x_aio,
                               0,0,0,0,'0',FALSE,0.00,0.00,0.00,0,0,0,0,3,
                               x_mov);
          raise notice '|MSG2|Aplicando mov: %', x_mov;

          --- Cargo a Parte Acreedora -----
          x_mov := x_mov + 1;
          insert into temporal(idusuario,sesion,idorigen,idgrupo,idsocio,
                               idorigenp,idproducto,idauxiliar,esentrada,
                               acapital,io_pag,io_cal,im_pag,im_cal,idcuenta,
                               aplicado,aiva,abonifio,saldodiacum,ivaio_pag,
                               ivaio_cal,ivaim_pag,ivaim_cal,tipomov,mov)
                       VALUES (p_idusuario,'COND_MASIVAS',r_cond.idorigen,
                               r_cond.idgrupo,r_cond.idsocio,x_a_idorigenp,
                               x_a_idproducto,x_a_idauxiliar,TRUE,x_aio,
                               0,0,0,0,'0',FALSE,0.00,0.00,0.00,0,0,0,0,3,
                               x_mov);
          raise notice '|MSG2|Aplicando mov: %', x_mov;
        end if;

        --- Aplicacion para los I.M. ------
        if x_aim > 0 then

          -- Busca el Folio Deudor y Acreedor --------------------------
          -- si no lo encuenta realiza la Apertura Respectivamente -----

          -- Deudor -------
          select into x_d_idorigenp, x_d_idproducto, x_d_idauxiliar
                      idorigenp, idproducto, idauxiliar
                 from auxiliares
                where idorigen = r_cond.idorigen and
                      idgrupo = r_cond.idgrupo and idsocio = r_cond.idsocio and
                      idproducto = r_ctas.p3 and estatus <= 2;
          if not found then
            x_d_idorigenp  := r_cond.idorigen;
            x_d_idproducto := r_ctas.p3;

            x_mat := array[text(r_cond.idorigen) , text(r_cond.idgrupo) ,
                           text(r_cond.idsocio) , text(x_d_idorigenp) ,
                           text(x_d_idproducto) , text(fecha_hoy) ,
                           text(p_idusuario) , text(0)];

            x_d_idauxiliar := sai_deudores_diversos_crea_apertura(x_mat);
          end if;

          -- Acreedor -------
          select into x_a_idorigenp, x_a_idproducto, x_a_idauxiliar
                      idorigenp, idproducto, idauxiliar
                 from auxiliares
                where idorigen = r_cond.idorigen and
                      idgrupo = r_cond.idgrupo and idsocio = r_cond.idsocio and
                      idproducto = r_ctas.p4 and estatus <= 2;
          if not found then
            x_a_idorigenp  := r_cond.idorigen;
            x_a_idproducto := r_ctas.p4;

            x_mat := array[text(r_cond.idorigen) , text(r_cond.idgrupo) ,
                           text(r_cond.idsocio) , text(x_a_idorigenp) ,
                           text(x_a_idproducto) , text(fecha_hoy) ,
                           text(p_idusuario) , text(0)];

            x_a_idauxiliar := sai_acredores_diversos_crea_apertura(x_mat);
          end if;

          --- Abono a Parte Deudora -----
          x_mov := x_mov + 1;
          insert into temporal(idusuario,sesion,idorigen,idgrupo,idsocio,
                               idorigenp,idproducto,idauxiliar,esentrada,
                               acapital,io_pag,io_cal,im_pag,im_cal,idcuenta,
                               aplicado,aiva,abonifio,saldodiacum,ivaio_pag,
                               ivaio_cal,ivaim_pag,ivaim_cal,tipomov,mov)
                       VALUES (p_idusuario,'COND_MASIVAS',r_cond.idorigen,
                               r_cond.idgrupo,r_cond.idsocio,x_d_idorigenp,
                               x_d_idproducto,x_d_idauxiliar,FALSE,x_aim,
                               0,0,0,0,'0',FALSE,0.00,0.00,0.00,0,0,0,0,3,
                               x_mov);
          raise notice '|MSG2|Aplicando mov: %', x_mov;

          --- Cargo a Parte Acreedora -----
          x_mov := x_mov + 1;
          insert into temporal(idusuario,sesion,idorigen,idgrupo,idsocio,
                               idorigenp,idproducto,idauxiliar,esentrada,
                               acapital,io_pag,io_cal,im_pag,im_cal,idcuenta,
                               aplicado,aiva,abonifio,saldodiacum,ivaio_pag,
                               ivaio_cal,ivaim_pag,ivaim_cal,tipomov,mov)
                       VALUES (p_idusuario,'COND_MASIVAS',r_cond.idorigen,
                               r_cond.idgrupo,r_cond.idsocio,x_a_idorigenp,
                               x_a_idproducto,x_a_idauxiliar,TRUE,x_aim,
                               0,0,0,0,'0',FALSE,0.00,0.00,0.00,0,0,0,0,3,
                               x_mov);
          raise notice '|MSG2|Aplicando mov: %', x_mov;

        end if;
      end if;
    end if;
  end loop;

  -- Limpia de memoria la tabla temporal ---
  begin
    drop table condonaciones_masivas;
  end;

  x_stp := x_mov;

  if x_mov > 0 then
    x_concepto := 'CONDONACION MASIVA DE INTERESES A PRESTAMO';
    x_periodo := to_char(date(fecha_hoy),'yyyymm');
    x_npoliza := sai_poliza_nueva (p_idorigenc,x_periodo,3,0,fecha_hoy,
                                   x_concepto,''::varchar,TRUE,p_idusuario);

    x_stp := sai_temporal_procesa(p_idusuario,'COND_MASIVAS',fecha_hoy,
                                  p_idorigenc,x_npoliza,3,x_concepto,TRUE,TRUE);

    if x_stp is NOT NULL and x_stp > 0 then
      update temporal
         set aplicado = TRUE
       where idusuario=p_idusuario and sesion='COND_MASIVAS';

      delete from temporal where idusuario=p_idusuario and
                                 sesion='COND_MASIVAS' and aplicado;
      raise notice '|MSG2|Aplica Poliza...';
    else
      raise notice '|MSG3|HUBO UN ERROR AL APLICAR LA FUNCION SAI_TEMPORAL_PROCESA';
      raise exception '<';
    end if;
  else
    paso := 'NO HUBO MOVIMIENTOS QUE PROCESAR: LOS FOLIOS NO TENIAN '||
            'INTERESES\nTALVEZ YA SE HABIA PROCESADO ESTA LISTA ANTERIORMENTE.';
    raise notice '|MSG3|%', paso;
    raise exception '<';
  end if;

  return x_npoliza;
end;
$$ language 'plpgsql';

drop type tipo_sai_prestamos_hipotecarios_calcula_seguro_a_pagar cascade;
create type tipo_sai_prestamos_hipotecarios_calcula_seguro_a_pagar as (
  idorigenpr  integer,
  idproductor integer,
  idauxiliarr integer,
  tasa_iva    numeric(6,4),
  seguro      numeric(12,2),
  ivaseguro   numeric(12,2),
  pagado      numeric(12,2),
  ivapagado   numeric(12,2),
  apagar      numeric(12,2),
  ivaapagar   numeric(12,2)
);

create or replace function
sai_prestamos_hipotecarios_calcula_seguro_a_pagar (integer,integer,integer,date)
returns setof tipo_sai_prestamos_hipotecarios_calcula_seguro_a_pagar as $$
declare
  p_idorigenp  alias for $1;
  p_idproducto alias for $2;
  p_idauxiliar alias for $3;
  p_fecha      alias for $4;
  res          text;
  f_prox_ab    date;
  r_refp       record;
  meses_nats   integer;
  first_time   boolean;
  x_fechaact   date;
  x_tpa        integer;
  r            tipo_sai_prestamos_hipotecarios_calcula_seguro_a_pagar%rowtype;

  x numeric;
  y integer;

  aj1 numeric;
begin
  res := sai_auxiliar(p_idorigenp,p_idproducto,p_idauxiliar,p_fecha);
  f_prox_ab := sai_token(11,res,'|');

  select into x_fechaact fechaactivacion from auxiliares
  where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and tipoamortizacion = 5;
  if found then

    if p_fecha = x_fechaact then
      return;
    end if;

  else

    y := 0;
    select into y count(*) from referenciasp
    where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and tiporeferencia = 6;
    if not found or y is null then y := 0; end if;
    if y > 0 then
      select into x_fechaact fechaactivacion from auxiliares
      where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar;
      if found then
        if p_fecha = x_fechaact then return; end if;
      end if;
    end if;

  end if;

  r.seguro    := 0;
  r.ivaseguro := 0;
  r.pagado    := 0;
  r.ivapagado := 0;
  r.apagar    := 0;
  r.ivaapagar := 0;
  r.tasa_iva  := 0;
  first_time  := TRUE;

  for r_refp in select rp.*,p.iva
                 from referenciasp as rp inner join productos as p on (p.idproducto = rp.idproductor)
                where rp.idorigenp = p_idorigenp and rp.idproducto = p_idproducto and
                      rp.idauxiliar = p_idauxiliar and rp.tiporeferencia = 6
  loop
    r.idorigenpr  := r_refp.idorigenpr;
    r.idproductor := r_refp.idproductor;
    r.idauxiliarr := r_refp.idauxiliarr;
    r.tasa_iva    := r_refp.iva;

    r.seguro      := text(r_refp.referencia)::numeric;
    r.ivaseguro   := round(text(r_refp.referencia)::numeric * (r_refp.iva / 100),2);

    select into r.pagado, r.ivapagado coalesce(sum(monto),0), coalesce(sum(montoiva),0)
           from auxiliares_d
          where idorigenp = r_refp.idorigenpr and
                idproducto = r_refp.idproductor and
                idauxiliar = r_refp.idauxiliarr and
                cargoabono = 1 and tipomov = 0;

    select into r.pagado, r.ivapagado r.pagado - coalesce(sum(monto),0),
                r.ivapagado - coalesce(sum(montoiva),0)
           from auxiliares_d
          where idorigenp = r_refp.idorigenpr and
                idproducto = r_refp.idproductor and
                idauxiliar = r_refp.idauxiliarr and
                cargoabono = 0 and tipomov = 6;

    if first_time then
      select into meses_nats coalesce(count(*),0)
        from (select distinct vence
              from amortizaciones
              where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and
                    vence <= f_prox_ab) as z;
      first_time := FALSE;
    end if;

    ----------------------------------------------------------------------------
    -- CASO SAN NICOLAS : EN EL MES DE NOVIEMBRE DEL 2019 SE HIZO UN CARGO A
    -- VARIOS SEGUROS PERO ESO METIO RUIDO EN EL CALCULO DE LOS MESES SIGUIENTES
    ----------------------------------------------------------------------------
    aj1 := 0.0; y = 0;
    select into y idorigen from origenes where matriz = 0 limit 1;
    if not found or y is NULL then y := 0; end if;

    if y = 30200 then
      select into aj1 coalesce(sum(monto),0)
      from auxiliares_d
      where idorigenp = r_refp.idorigenpr and idproducto = r_refp.idproductor and idauxiliar = r_refp.idauxiliarr and
            idorigenc > 0 and periodo = '201911' and idtipo = 3 and idpoliza > 0 and cargoabono = 0 and tipomov = 0 and
            date(fecha) = date('30/11/2019') and idproducto in (5011, 5012);
      if not found or aj1 is NULL then aj1 := 0.0; end if;
    end if;
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------

    x :=  (meses_nats * r.seguro) - r.pagado + aj1;

    r.apagar    := (case when x < 0 then 0.0 else x end);
    r.ivaapagar := round(r.apagar * (r_refp.iva / 100),2);
/*
    raise notice 'seguro: %, iva: %', r.seguro, r.ivaseguro;
    raise notice 'pagado: %, iva: %', r.pagado, r.ivapagado;
    raise notice 'apagar: %, iva: %', r.apagar, r.ivaapagar;
    raise notice 'meses_nats: %', meses_nats;
*/

    return next r;
  end loop;

  ------------------------------------------------------------------------------
  -- ULTIMA MODIFICACION : 02/ENERO/2020 ---------------------------------------
  ------------------------------------------------------------------------------

  return;
end;
$$ language 'plpgsql';

/*------------------------------------------------------------------------------
::: ABONOS_PROGRAMADOS_A_PRESTAMOS    ---- I N I C I O ----
------------------------------------------------------------------------------*/
create or replace function
sai_apertura_masiva_producto_abonos_programado_a_prestamo (integer) returns integer as $$
declare
  p_idusuario   alias for $1;
  r_app         record;
  r_aux         record;
  r_paso        record;
  x_fecha_hoy   date;
  x_mat         _text;
  x_folio       integer;
begin
  select
  into   r_app *
  from   tablas
  where  idtabla = 'param' and idelemento = 'abonos_programados_a_prestamos';
  if not found then
    raise notice 'NO EXISTE LA TABLA: param / abonos_programados_a_prestamos, NO SE PODRA EJECUTAR ESTE PROCESO';
    return 1;
  end if;
  if r_app.dato2 is NULL or trim(r_app.dato2) = '' then
    raise notice 'EL PARAMETRO 2 DE LA TABLA: param / abonos_programados_a_prestamos ESTA VACIO, NO EXISTEN PRESTAMOS A EXAMINAR';
    return 1;
  end if;

  select
  into   x_fecha_hoy date(fechatrabajo)
  from   origenes
  limit  1;

  for r_aux
  in  select a.*
      from   auxiliares as a
             inner join productos as p using(idproducto)
      where  p.tipoproducto = 2 and sai_texto1_like_texto2(a.idproducto::text,NULL,r_app.dato2,'|') > 0 and
             a.fechaactivacion = x_fecha_hoy
  loop
    select
    into   r_paso *
    from   auxiliares
    where  idorigen = r_aux.idorigen and idgrupo = r_aux.idgrupo and idsocio = r_aux.idsocio and
           idproducto = r_app.dato1::integer and estatus in (0,2);
    continue when found;

    x_mat := array[r_aux.idorigen::text ,
                   r_aux.idgrupo::text  ,
                   r_aux.idsocio::text  ,
                   r_aux.idorigen::text ,
                   r_app.dato1          ,
                   x_fecha_hoy::text    ,
                   p_idusuario::text    ,
                   '0'];

    x_folio := sai_ahorro_crea_apertura (x_mat);
  end loop;

  return 1;
end;
$$ language 'plpgsql';

create or replace function
sai_abonos_programados_a_prestamos_procesa (_text) returns integer as $$
declare
  p_mat         alias for $1;
  p_idorigen    integer;
  p_idgrupo     integer;
  p_idsocio     integer;
  p_idorigenp   integer;
  p_idproducto  integer;
  p_idauxiliar  integer;
  p_fecha       date;
  p_es          boolean;
  p_monto       numeric;
  p_mov         integer;
  p_idusuario   integer;
  p_tipoamort   integer;
  p_ref         text;
  p_aux         text;

  paso_txt      text;
  x_acapital    numeric;
  x_io_pag      numeric;
  x_io_cal      numeric;
  x_im_pag      numeric;
  x_im_cal      numeric;
  x_ivaio_pag   numeric;
  x_ivaio_cal   numeric;
  x_ivaim_pag   numeric;
  x_ivaim_cal   numeric;
  x_cmnpag_pag  numeric;
  x_cmnpag_cal  numeric;
  x_montoseg    numeric;
  x_ret         numeric;
  x_saldodiacum numeric;
  x_t_ivaio     numeric;
  x_t_ivaim     numeric;
  x_iva         numeric;
  x_t_iva       numeric;
  r_paso        record;
  folio         integer;
  impte_desglo  numeric;
  cta_reembolso varchar(20);
  x_prod_ret    integer;
  t_dim         _text;

begin

  p_idorigen    := p_mat[1];
  p_idgrupo     := p_mat[2];
  p_idsocio     := p_mat[3];
  p_idorigenp   := p_mat[4];
  p_idproducto  := p_mat[5];
  p_idauxiliar  := p_mat[6];
  p_fecha       := p_mat[7];
  p_es          := p_mat[8];
  p_monto       := p_mat[9];
  p_mov         := p_mat[10];
  p_idusuario   := p_mat[11];
  p_tipoamort   := p_mat[12];
  p_ref         := p_mat[13];
  p_aux         := p_mat[14];

  x_acapital    := p_monto;
  x_io_pag      := 0;
  x_io_cal      := 0;
  x_im_pag      := 0;
  x_im_cal      := 0;
  x_ivaio_pag   := 0;
  x_ivaio_cal   := 0;
  x_ivaim_pag   := 0;
  x_ivaim_cal   := 0;
  x_montoseg    := 0;
  x_cmnpag_pag  := 0;
  x_cmnpag_cal  := 0;
  x_saldodiacum := 0;
  x_ret         := 0;
  x_iva         := 0;

  x_t_ivaio := sai_iva_segun_sucursal(p_idorigenp,p_idproducto,0);
  x_t_ivaim := sai_iva_segun_sucursal(p_idorigenp,p_idproducto,1);
  x_t_iva   := x_t_ivaio;

  if sai_findstr(p_ref,'|')+1 = 10 and
     int4(sai_token(10,p_ref,'|')) = 2 then

    x_montoseg    := sai_token(2,p_ref,'|')::numeric;
    x_io_cal      := sai_token(4,p_ref,'|')::numeric;
    x_im_cal      := sai_token(6,p_ref,'|')::numeric;
    x_ivaio_cal   := sai_token(5,p_ref,'|')::numeric;
    x_ivaim_cal   := sai_token(7,p_ref,'|')::numeric;
    x_cmnpag_cal  := sai_token(9,p_ref,'|')::numeric;

    if x_montoseg > 0 then
      if x_acapital < x_montoseg then
        x_montoseg := x_acapital;
        x_acapital := 0;
      else
        x_acapital := x_acapital - x_montoseg;
      end if;
    end if;

    if x_acapital > 0 then
      if x_acapital < x_cmnpag_cal then
        x_cmnpag_pag  := x_acapital;
        x_acapital    := 0;
      else
        x_cmnpag_pag  := x_cmnpag_cal;
        x_acapital    := x_acapital - x_cmnpag_cal;
      end if;
    end if;

    if x_acapital > 0 and (x_ivaio_cal > 0 or x_ivaim_cal > 0) then
      select into x_t_ivaio,x_t_ivaim iva,ivaim from productos
        where idproducto = p_idproducto;
    end if;

    if x_acapital > 0 then
      if x_acapital < (x_im_cal + x_ivaim_cal) then
        impte_desglo  := x_acapital / ((x_t_ivaim / 100) + 1);
        x_ivaim_pag   := x_acapital - impte_desglo;
        x_im_pag      := impte_desglo;
        x_acapital    := 0;
      else
        x_ivaim_pag   := x_ivaim_cal;
        x_im_pag      := x_im_cal;
        x_acapital    := x_acapital - (x_im_cal + x_ivaim_cal);
        x_acapital    := case when x_acapital <= 0 then 0 else x_acapital end;
      end if;
    end if;

    if x_acapital > 0 then
      if x_acapital < (x_io_cal + x_ivaio_cal) then
        impte_desglo  := x_acapital / ((x_t_ivaio / 100) + 1);
        x_ivaio_pag   := x_acapital - impte_desglo;
        x_io_pag      := impte_desglo;
        x_acapital    := 0;
      else
        x_ivaio_pag   := x_ivaio_cal;
        x_io_pag      := x_io_cal;
        x_acapital    := x_acapital - (x_io_cal + x_ivaio_cal);
        x_acapital    := case when x_acapital <= 0 then 0 else x_acapital end;
      end if;
    end if;
  end if;

  if sai_findstr(p_ref,'|')+1 = 4 and int4(sai_token(1,p_ref,'|')) = 0 then
    x_io_cal      := sai_token(2,p_ref,'|')::numeric;
    x_io_pag      := 0;
    x_ret         := sai_token(3,p_ref,'|')::numeric;
    x_saldodiacum := sai_token(4,p_ref,'|')::numeric;
  end if;

  if sai_findstr(p_ref,'|')+1 = 2 and int4(sai_token(1,p_ref,'|')) = 5 then
    x_iva         := sai_token(2,p_ref,'|')::numeric;
  end if;

  if x_acapital > 0 or x_io_pag > 0 or x_im_pag > 0 or x_cmnpag_pag > 0 then
    INSERT INTO temporal(idusuario,sesion,idorigen,idgrupo,idsocio,idorigenp,
                         idproducto,idauxiliar,esentrada,acapital,io_pag,io_cal,
                         im_pag,im_cal,idcuenta,aplicado,aiva,abonifio,
                         saldodiacum,ivaio_pag,ivaio_cal,ivaim_pag,ivaim_cal,
                         tipomov,mov,cpnp_pag,cpnp_cal,sai_aux)
                 VALUES (p_idusuario,'ABONO_PROG_PREST',p_idorigen,p_idgrupo,
                         p_idsocio,p_idorigenp,p_idproducto,p_idauxiliar,p_es,
                         x_acapital,x_io_pag,x_io_cal,x_im_pag,x_im_cal,'0',
                         FALSE,x_iva,0,x_saldodiacum,x_ivaio_pag,x_ivaio_cal,
                         x_ivaim_pag,x_ivaim_cal,0,p_mov,x_cmnpag_pag,
                         x_cmnpag_cal,p_aux);
  end if;

  if x_montoseg > 0 then
    p_mov := p_mov + 1;  
    for r_paso in select *
                    from sai_prestamos_hipotecarios_calcula_seguro_a_pagar (
                           p_idorigenp,p_idproducto,p_idauxiliar,p_fecha)
    loop
      if x_montoseg < (r_paso.apagar + r_paso.ivaapagar) then
        x_acapital  := x_montoseg / ((r_paso.tasa_iva / 100) + 1);
        x_iva       := x_montoseg - x_acapital;
        x_montoseg  := 0;
      else
        x_acapital  := r_paso.apagar;
        x_iva       := r_paso.ivaapagar;
        x_montoseg  := x_montoseg - (r_paso.apagar + r_paso.ivaapagar);
      end if;

      t_dim := array[text(p_idorigen) , text(p_idgrupo) , text(p_idsocio) ,
                     text(r_paso.idorigenpr) , text(r_paso.idproductor) , text(r_paso.idauxiliarr) ,
                     text(p_fecha) , 't' , text(x_acapital) , text(p_mov) ,
                     text(p_idusuario) , text(0) , '5'||'|'||text(x_iva)];
      p_mov := sai_abonos_programados_a_prestamos_procesa (t_dim);
    end loop;
    p_mov := p_mov - 1;
  end if;

  if x_ret > 0 and x_io_pag > 0 then

    /*-- Posible reembolso de retencion en caso de existir la tabla ---*/
    select into cta_reembolso
                case when exists (select c.*
                                    from cuentas as c
                                   where c.idcuenta = t.dato1 and c.clase = 5)
                     then dato1
                     else '0'
                end
           from tablas as t
          where t.idtabla = 'param' and t.idelemento = 'regresa_retencion';
    if not found then
      cta_reembolso := '0';
    end if;

    select into r_paso *
      from auxiliares
     where idorigen = p_idorigen and idgrupo = p_idgrupo and
           idsocio = p_idsocio and idproducto = x_prod_ret;
    if found then
      p_idorigenp := r_paso.idorigenp;
      folio := r_paso.idauxiliar;
    else
      t_dim := array[text(p_idorigen) , text(p_idgrupo) , text(idsocio) ,
                     text(p_idorigenp) , text(p_idproducto) , text(p_fecha) ,
                     text(p_idusuario) , text(0)];
      folio := sai_ahorro_crea_apertura (t_dim);
    end if;

    p_mov := p_mov + 1;
    INSERT INTO temporal(idusuario,sesion,idorigen,idgrupo,idsocio,idorigenp,
                         idproducto,idauxiliar,esentrada,acapital,io_pag,io_cal,
                         im_pag,im_cal,idcuenta,aplicado,aiva,abonifio,
                         saldodiacum,ivaio_pag,ivaio_cal,ivaim_pag,ivaim_cal,
                         tipomov,mov,sai_aux)
                 VALUES (p_idusuario,'ABONO_PROG_PREST',p_idorigen,p_idgrupo,
                         p_idsocio,p_idorigenp,x_prod_ret,folio,TRUE,x_ret,0,0,0,0,
                         '0',FALSE,0,0,0,0,0,0,0,0,p_mov,p_aux);

    if cta_reembolso NOT like '0' then
      p_mov := p_mov + 1;
      INSERT INTO temporal(idusuario,sesion,idorigen,idgrupo,idsocio,idorigenp,
                         idproducto,idauxiliar,esentrada,acapital,io_pag,io_cal,
                         im_pag,im_cal,idcuenta,aplicado,aiva,abonifio,
                         saldodiacum,ivaio_pag,ivaio_cal,ivaim_pag,ivaim_cal,
                         tipomov,mov,sai_aux)
                 VALUES (p_idusuario,'ABONO_PROG_PREST',p_idorigen,p_idgrupo,
                         p_idsocio,p_idorigenp,1,0,FALSE,x_ret,0,0,0,0,
                         cta_reembolso,FALSE,0,0,0,0,0,0,0,0,p_mov,p_aux);
    end if;
  end if;

  p_mov := p_mov + 1;

  return p_mov;
end;
$$ language 'plpgsql';

create or replace function
sai_abonos_programados_a_prestamos_cuanto(integer,integer,integer,date,integer,text)
returns text as $$
declare
  p_idorigenp   alias for $1;
  p_idproducto  alias for $2;
  p_idauxiliar  alias for $3;
  p_fecha       alias for $4;
  p_ta          alias for $5;
  p_aux         alias for $6;


  n_montoseg    numeric;
  n_montoven    numeric;
  n_io          numeric;
  n_ivaio       numeric;
  n_im          numeric;
  n_ivaim       numeric;
  n_proxabono   numeric;
  n_comnopag    numeric;
  n_suma        numeric;

begin

  n_montoseg := 0;

  -- Monto seguro hipotecario
  if p_ta = 5 then
    select into n_montoseg coalesce(sum(apagar + ivaapagar), 0)
      from sai_prestamos_hipotecarios_calcula_seguro_a_pagar (p_idorigenp,p_idproducto,p_idauxiliar,p_fecha);

  end if;

  n_montoven    := sai_token(5,p_aux,'|')::numeric;
  n_io          := sai_token(7,p_aux,'|')::numeric;
  n_ivaio       := sai_token(18,p_aux,'|')::numeric;
  n_im          := sai_token(16,p_aux,'|')::numeric;
  n_ivaim       := sai_token(19,p_aux,'|')::numeric;
  n_proxabono   := sai_token(12,p_aux,'|')::numeric;
  n_comnopag    := sai_token(22,p_aux,'|')::numeric;

  n_suma := n_montoseg + n_montoven + n_io + n_ivaio + n_im + n_ivaim +
            n_proxabono + n_comnopag;

  return text(n_suma)||'|'||text(n_montoseg)||'|'||text(n_montoven)||'|'||
         text(n_io)||'|'||text(n_ivaio)||'|'||text(n_im)||'|'||
         text(n_ivaim)||'|'||text(n_proxabono)||'|'||
         text(n_comnopag)||'|'||sai_token(1,p_aux,'|');
end;
$$ language 'plpgsql';

create or replace function --rev 8.4
sai_abonos_programados_a_prestamos (integer) returns integer as $$
declare
  p_idusuario             alias for $1;

  b_primera_vez           boolean;
  d_fecha_hoy             date;
  i_cont                  integer;
  i_movs                  integer;
  i_origenapl             integer;
  i_poliza                integer;
  i_prod_app              integer; -- Producto abono programado a prestamos
  n_monto_abono           numeric;
  n_resto                 numeric;
  n_suma_abonos           numeric;
  n_paso                  numeric;
  r_movs                  record;
  r_movs_ant              record;
  r_ref                   record;
  t_concepto              text;
  t_dim                   text[];
  t_opa                   text;
  t_periodo               text;
  t_resp                  text;
  t_sai_aux               text;
  r_aux_ah                record;
  r_app                   record;
  i_abonar_max            integer;
  r_paso                  record;
  i_movs_tot              integer;
  i_veces                 integer;
  b_por_origen_frontera   boolean;
begin

  /*--- Validar la tabla: abonos_programados_a_prestamos ---*/
  select
  into   r_app *
  from   tablas
  where  idtabla = 'param' and idelemento = 'abonos_programados_a_prestamos';
  if not found then
    t_resp := 'NO ESTA HABILITADO ABONOS PROGRAMADOS A PRESTAMOS'||E'\012';
    raise notice '|MSG_AVISO|%',t_resp;
    return 1;
  end if;
  if r_app.dato1 is NULL or trim(r_app.dato1) = '' then
    t_resp := 'NO ESTA CONFIGURADA CORRECTAMENTE LA TABLA: param / abonos_programados_a_prestamos'||E'\012';
    raise notice '|MSG_AVISO|%',t_resp;
    return 1;
  end if;
  i_prod_app    := int4(r_app.dato1);
  i_abonar_max  := case when r_app.dato3 is NULL or trim(r_app.dato3) = '' or r_app.dato3 != '1'
                        then 0
                        else 1
                   end;

  select into d_fecha_hoy date(fechatrabajo)
    from origenes as o
   limit 1;

  /*--- origen de aplicacion ---------------------------*/
  select into i_origenapl int4(dato1)
    from tablas
   where idtabla = 'param' and idelemento = 'origen_abono_prog_a_prestamos';
  if not found then
    select into i_origenapl idorigen
      from usuarios
     where idusuario = p_idusuario;
  end if;
  /*--- origen de aplicacion ---------------------------*/
  select
  into   r_paso *
    from tablas
   where idtabla = 'param' and idelemento = 'aplicar_por_origen_socio_fronterizo';
  b_por_origen_frontera := found;

  -- Conteo de los registros a leer ------------------------------
  select
  into   i_cont coalesce(count(*),0)
  from   referenciasp rp7
         inner join amortizaciones as am
           on(am.idorigenp = rp7.idorigenpr and am.idproducto = rp7.idproductor and am.idauxiliar = rp7.idauxiliarr)
         inner join auxiliares     as a
           on(a.idorigenp  = rp7.idorigenpr and a.idproducto  = rp7.idproductor and a.idauxiliar  = rp7.idauxiliarr)
  where  am.vence = d_fecha_hoy and a.estatus = 2 and rp7.idproducto = i_prod_app and rp7.tiporeferencia = 7 and
         rp7.referencia is not null and trim(rp7.referencia) != '' and sai_token(2,rp7.referencia,'|')::numeric > 0 and
         exists (select idorigenp,idproducto,idauxiliar,saldo
                 from   auxiliares a2
                 where  a2.idorigenp  = rp7.idorigenp  and a2.idproducto = rp7.idproducto and
                        a2.idauxiliar = rp7.idauxiliar and a2.saldo > 0);
  if i_cont = 0 then
    t_resp := '|MSG_AVISO|NO HAY ABONOS PROGRAMADOS A PRESTAMOS PARA ESTE DIA ('||d_fecha_hoy||')'||E'\012';
    raise notice '%',t_resp;
    return 1;
  end if;

  -- Show me how many records there are ---
  raise notice '|MSG_CONTEO|%|1',i_cont;

  i_veces := 1;
  if b_por_origen_frontera then
    i_veces := 2;
  end if;

  i_movs_tot := 0;
  for i_cont in reverse i_veces..1
  loop

    t_opa := '';
    n_suma_abonos := 0;
    b_primera_vez := TRUE;
    i_movs := 0;
    for r_movs
    in  select     idorigen,idgrupo,idsocio,a.tipoamortizacion,rp7.*
        from       referenciasp rp7
                   inner join amortizaciones as am
                     on(am.idorigenp = rp7.idorigenpr and am.idproducto = rp7.idproductor and am.idauxiliar = rp7.idauxiliarr)
                   inner join auxiliares     as a
                     on(a.idorigenp = rp7.idorigenpr and a.idproducto = rp7.idproductor and a.idauxiliar = rp7.idauxiliarr)
        where      am.vence = d_fecha_hoy and a.estatus = 2 and rp7.idproducto = i_prod_app and rp7.tiporeferencia = 7 and
                   rp7.referencia is not null and trim(rp7.referencia) != '' and sai_token(2,rp7.referencia,'|')::numeric > 0 and
                   case when i_cont = 2
                        then a.idorigenp in (select   idorigen
                                             from     origenes
                                             where    sai_texto1_like_texto2(idorigen::text, NULL,
                                                                             (select dato2
                                                                              from   tablas
                                                                              where  idelemento = 'iva_sucursal_fronteriza'), '|') > 0
                                             order by idorigen)
                        when i_cont = 1 and b_por_origen_frontera
                        then a.idorigenp in (select   idorigen
                                             from     origenes
                                             where    not sai_texto1_like_texto2(idorigen::text, NULL,
                                                                                 (select dato2
                                                                                  from   tablas
                                                                                  where  idelemento = 'iva_sucursal_fronteriza'), '|') > 0
                                             order by idorigen)
                        else TRUE
                   end and
                   exists (select idorigenp,idproducto,idauxiliar,saldo
                           from   auxiliares a2
                           where  a2.idorigenp  = rp7.idorigenp  and a2.idproducto = rp7.idproducto and
                                  a2.idauxiliar = rp7.idauxiliar and a2.saldo > 0)
    loop
      if t_opa != (text(r_movs.idorigenp)||text(r_movs.idproducto)||text(r_movs.idauxiliar))         
      then
        if not b_primera_vez and n_suma_abonos > 0
        then  /*--- Aplica CARGO/RETIRO al prod. origen ---*/
          /*--- Concatena en texto Consulta de Ints, Retenciones, Saldodiacums ---*/
          t_sai_aux := sai_auxiliar(r_movs_ant.idorigenp,r_movs_ant.idproducto,r_movs_ant.idauxiliar,d_fecha_hoy);

          t_resp := sai_token(1,t_sai_aux,'|')||'|'||
                    sai_token(2,t_sai_aux,'|')||'|'||
                    sai_token(4,t_sai_aux,'|')||'|'||
                    sai_token(5,t_sai_aux,'|');

          i_movs := case when i_movs = 0
                         then 1
                         else i_movs
                    end;

          /*--- Prepara en CARGO al prod. programado ---*/
          t_dim := array[text(r_movs_ant.idorigen)  , text(r_movs_ant.idgrupo)    , text(r_movs_ant.idsocio)    ,
                         text(r_movs_ant.idorigenp) , text(r_movs_ant.idproducto) , text(r_movs_ant.idauxiliar) ,
                         text(d_fecha_hoy)          , 'f'                         , text(n_suma_abonos)         ,
                         text(i_movs)               , text(p_idusuario)           , text(0)                     ,
                         t_resp                     , t_sai_aux];

          i_movs := sai_abonos_programados_a_prestamos_procesa (t_dim);

          n_suma_abonos := 0;
        end if;

        select into r_aux_ah *
        from        auxiliares
        where       idorigenp  = r_movs.idorigenp  and
                    idproducto = r_movs.idproducto and
                    idauxiliar = r_movs.idauxiliar;
        continue when r_aux_ah.saldo <= 0;
      end if;
      b_primera_vez := FALSE;

      -- calculo de sai_auxiliar:
      t_sai_aux := sai_auxiliar(r_movs.idorigenpr, r_movs.idproductor, r_movs.idauxiliarr, d_fecha_hoy);

      /*--- Reservacion de datos para poder realizar Cargo al Prod. Programado
            depues de los Abonos a los Prestamos ------------------------------*/
      select r_movs.idorigen    as idorigen,      r_movs.idgrupo    as idgrupo,       r_movs.idsocio      as idsocio,
             r_movs.idorigenp   as idorigenp,     r_movs.idproducto as idproducto,    r_movs.idauxiliar   as idauxiliar,
             r_movs.referencia  as referencia,    r_movs.idorigenpr as idorigenpr,    r_movs.idproductor  as idproductor,
             r_movs.idauxiliarr as idauxiliarr,   t_sai_aux         as aux   --r_movs.aux        as aux
      into   r_movs_ant;

      /*--- Calcula el monto a abonar del prestamo actual leido -------------*/
      t_resp := sai_abonos_programados_a_prestamos_cuanto (r_movs.idorigenpr,r_movs.idproductor,r_movs.idauxiliarr,
                                                           d_fecha_hoy,r_movs.tipoamortizacion,t_sai_aux); --r_movs.aux);

      /*--- Abono Neto del Prestamo ---*/
      n_monto_abono := sai_token(1,t_resp,'|')::numeric;

      continue when n_monto_abono = 0;

      /*--- Si no hay suficiente para abonar: smaller(saldo_ah,referencia) ---*/
      n_paso := numeric_smaller(  (r_aux_ah.saldo - n_suma_abonos),  sai_token(2,r_movs_ant.referencia,'|')::numeric);
      n_paso := numeric_larger(  n_paso,  0  );

      if n_paso < n_monto_abono then
        n_monto_abono := n_paso;
      else
        if i_abonar_max = 1 then
          if r_movs.tipoamortizacion = 5 then
            for r_paso in select   abono
                          from     amortizaciones
                          where    idorigenp  = r_movs.idorigenpr  and idproducto = r_movs.idproductor and
                                   idauxiliar = r_movs.idauxiliarr and not todopag and vence > d_fecha_hoy
                          order by vence
             loop
               exit when n_monto_abono + r_paso.abono >
                         numeric_smaller((r_aux_ah.saldo - n_suma_abonos), sai_token(2,r_movs_ant.referencia,'|')::numeric);
               n_monto_abono := n_monto_abono + r_paso.abono;
             end loop;
          else
            n_monto_abono := numeric_smaller((r_aux_ah.saldo - n_suma_abonos), sai_token(2,r_movs_ant.referencia,'|')::numeric);
          end if;
        end if;
      end if;

      if n_monto_abono > 0 then
        t_dim := array[text(r_movs.idorigen)   , text(r_movs.idgrupo)      , text(r_movs.idsocio)          ,
                       text(r_movs.idorigenpr) , text(r_movs.idproductor)  , text(r_movs.idauxiliarr)      ,
                       text(d_fecha_hoy)       , 't'                       , text(n_monto_abono)           ,
                       text(i_movs)            , text(p_idusuario)         , text(r_movs.tipoamortizacion) ,
                       t_resp                  , t_sai_aux];   --r_movs.aux];

        i_movs := case when i_movs = 0
                       then 1
                       else i_movs
                  end;

        i_movs := sai_abonos_programados_a_prestamos_procesa (t_dim);

        /*--- Modifica la referencia: (Monto orig|Mto Actualizado  ----------
          --- ej. 5000|2720.25 ---------------------------------------------*/
        n_resto := sai_token(2,r_movs_ant.referencia,'|')::numeric - n_monto_abono;

        update referenciasp
           set referencia = sai_token(1,r_movs_ant.referencia,'|')||'|'||text(n_resto)
         where idorigenp    = r_movs_ant.idorigenp    and
               idproducto   = r_movs_ant.idproducto   and
               idauxiliar   = r_movs_ant.idauxiliar   and
               idorigenpr   = r_movs_ant.idorigenpr   and
               idproductor  = r_movs_ant.idproductor  and
               idauxiliarr  = r_movs_ant.idauxiliarr;
      end if;

      n_suma_abonos := n_suma_abonos + n_monto_abono;

      t_opa := text(r_movs.idorigenp)||text(r_movs.idproducto)||text(r_movs.idauxiliar);

      -- Avance del proceso ---
      raise notice '|MSG_AVANCE';

    end loop;

    -- Esto es cuando no hay prestamos con origen fronterizo
    continue when b_primera_vez;

    if i_movs > 0 then
      /*--- Concatena en texto Consulta de Ints, Retenciones, Saldodiacums ---*/
      t_sai_aux := sai_auxiliar(r_movs_ant.idorigenp,r_movs_ant.idproducto,r_movs_ant.idauxiliar,d_fecha_hoy);

      t_resp := sai_token(1,t_sai_aux,'|')||'|'||
                sai_token(2,t_sai_aux,'|')||'|'||
                sai_token(4,t_sai_aux,'|')||'|'||
                sai_token(5,t_sai_aux,'|');

      /*--- Prepara en CARGO al prod. programado ---*/
      t_dim := array[text(r_movs_ant.idorigen)  , text(r_movs_ant.idgrupo)    , text(r_movs_ant.idsocio)    ,
                     text(r_movs_ant.idorigenp) , text(r_movs_ant.idproducto) , text(r_movs_ant.idauxiliar) ,
                     text(d_fecha_hoy)          , 'f'                         , text(n_suma_abonos)         ,
                     text(i_movs)               , text(p_idusuario)           , text(0)                     ,
                     t_resp                     , t_sai_aux];

      i_movs := sai_abonos_programados_a_prestamos_procesa (t_dim);

      /*--- Modifica la referencia: (Monto orig|Mto Actualizado  ----------
        --- ej. 5000|2720.25 ---------------------------------------------*/
      n_resto := sai_token(2,r_movs_ant.referencia,'|')::numeric -
                 n_suma_abonos;
      update referenciasp
         set referencia = sai_token(1,r_movs_ant.referencia,'|')||'|'||
                                    text(n_resto)
       where idorigenp    = r_movs_ant.idorigenp    and
             idproducto   = r_movs_ant.idproducto   and
             idauxiliar   = r_movs_ant.idauxiliar   and
             idorigenpr   = r_movs_ant.idorigenpr   and
             idproductor  = r_movs_ant.idproductor  and
             idauxiliarr  = r_movs_ant.idauxiliarr;

      n_suma_abonos := 0;
    end if;

    /*----------------------------------------------------------------------------
    -- GENERACION DE POLIZA
    ----------------------------------------------------------------------------*/
    if i_movs > 0 then
      t_concepto  := 'ABONO PROGRAMADO A PRESTAMOS';
      t_periodo   := to_char(date(d_fecha_hoy),'yyyymm');
      i_poliza    := sai_poliza_nueva (i_origenapl,t_periodo,3,0,d_fecha_hoy,
                                       t_concepto,''::varchar,TRUE,p_idusuario);

      i_movs := sai_temporal_procesa(p_idusuario,'ABONO_PROG_PREST'::varchar,
                                     d_fecha_hoy,i_origenapl,i_poliza,3,
                                     t_concepto,FALSE,TRUE);

      if i_movs is NOT NULL and i_movs > 0 then
        update temporal
           set aplicado = TRUE
         where idusuario = p_idusuario and sesion = 'ABONO_PROG_PREST';

        delete from temporal where idusuario = p_idusuario and
                                   sesion = 'ABONO_PROG_PREST' and aplicado;
      else
        raise exception 'HUBO UN ERROR AL APLICAR LA FUNCION SAI_TEMPORAL_PROCESA';
      end if;
      
      i_movs_tot := i_movs_tot + i_movs;
    end if;
  end loop;

  if i_movs_tot = 0 then
    t_resp := 'PARA EL DIA DE HOY, NO ENCONTRO MOVIMIENTOS QUE PROCESAR DE '||
              'ABONOS PROGRAMADOS A PRESTAMOS'||E'\012';
    raise notice '|MSG_AVISO|%', t_resp;
    i_movs := 1;
  else
    t_resp := 'ABONOS PROGRAMADOS A PRESTAMOS, TERMINO CORRECTAMENTE !';
    raise notice '|MSG_AVISO|%', t_resp;
  end if;

  return i_movs;

  --- ** ANTES SE BASABA EN LA FECHA PROX. ABONO DEL SAI AUXILIAR ***
  --  ** AHORA SE BASA EN LA FECHA VENCE DE AMORTIZACIONES:       ***
/*
  select
  into   i_cont coalesce(count(*),0)
  from   (select     sai_token(11,sai_auxiliar(a.idorigenp,a.idproducto,a.idauxiliar,d_fecha_hoy),'|')::date as fecha_prox_abono
          from       referenciasp rp
          inner join auxiliares as a on (a.idorigenp  = rp.idorigenpr  and a.idproducto = rp.idproductor and
                                         a.idauxiliar = rp.idauxiliarr)
          where      a.estatus = 2 and rp.idproducto = i_prod_app and rp.tiporeferencia = 7 and
                     sai_token(2,rp.referencia,'|')::numeric > 0 and
                     exists (select idorigenp,idproducto,idauxiliar,saldo
                             from   auxiliares a2
                             where  a2.idorigenp  = rp.idorigenp  and a2.idproducto = rp.idproducto and
                                    a2.idauxiliar = rp.idauxiliar and a2.saldo > 0)) as abs
  where  fecha_prox_abono = d_fecha_hoy;
*/

/* CONSULTA PRINCIPAL DEL CICLO FOR. ESTO ESTABA ANTES ASI:
    for r_movs
    in  select *
        from   (select     idorigen,idgrupo,idsocio,tipoamortizacion,rp.*,
                           sai_auxiliar(a.idorigenp,a.idproducto,a.idauxiliar,d_fecha_hoy) as aux --sai_aux del prestamo
                from       referenciasp rp
                           -- Ojo: Ref. al Prestamo
                inner join auxiliares as a on (a.idorigenp  = rp.idorigenpr  and a.idproducto = rp.idproductor and
                                               a.idauxiliar = rp.idauxiliarr)
                where      a.estatus = 2 and rp.idproducto = i_prod_app and rp.tiporeferencia = 7 and
                           sai_token(2,rp.referencia,'|')::numeric > 0 and
                           case when i_cont = 2
                                then idorigen in (select   idorigen
                                                  from     origenes
                                                  where    sai_texto1_like_texto2(idorigen::text, NULL,
                                                                                  (select dato2
                                                                                   from   tablas
                                                                                   where  idelemento = 'iva_sucursal_fronteriza'), '|') > 0
                                                  order by idorigen)
                                when i_cont = 1 and b_por_origen_frontera
                                then idorigen in (select   idorigen
                                                  from     origenes
                                                  where    not sai_texto1_like_texto2(idorigen::text, NULL,
                                                                                      (select dato2
                                                                                       from   tablas
                                                                                       where  idelemento = 'iva_sucursal_fronteriza'), '|') > 0
                                                  order by idorigen)
                                else TRUE
                           end and
                           exists (select idorigenp,idproducto,idauxiliar,saldo
                                   from   auxiliares a2
                                   where  a2.idorigenp  = rp.idorigenp  and a2.idproducto = rp.idproducto and
                                          a2.idauxiliar = rp.idauxiliar and a2.saldo > 0)) as abs
        where  sai_token(11,aux,'|')::date = d_fecha_hoy
  */
end;
$$ language 'plpgsql';
/*------------------------------------------------------------------------------
::: ABONOS_PROGRAMADOS_A_PRESTAMOS    ---- F I N A L ----
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
Esta funcion es usada dentro de: sai_auxiliar_actualiza, pl_auxiliares.sql, en
la seccion de prestamos, al momento de realizar una reestructura o renovacion,
se requiere heredar los DV y la Cartera. DV y Cartera se concatenan: 95|V y se
guardan en: referenciasp.referencia
------------------------------------------------------------------------------*/
create or replace function
hay_prestamos_mas_vencidos_en_temporal(integer, integer, integer, date, varchar, integer, varchar, integer)
returns varchar as $$
declare
  p_idorigenp  alias for $1;
  p_idproducto alias for $2;
  p_idauxiliar alias for $3;
  p_fecha      alias for $4;
  p_sesion     alias for $5;
  p_usuario    alias for $6;
  p_cartera    alias for $7;
  p_dias_v     alias for $8;

  r_temp record;

  aux_tmp varchar;

  x integer;

  cartera  varchar;
  dv       integer;
  carterax varchar;
  dvx      integer;
  datox    varchar;

  idx   integer;
  prodx integer;
  aux   integer;
  resp varchar;
begin

  cartera := p_cartera; dv := p_dias_v;

  -- HAY OTRS PRESTAMOS EN temporal, ADEMAS DEL QUE ESTA EN referenciasp ??
  x := 0;
  select into x count(*) from temporal
  where sesion = p_sesion and idusuario = p_usuario and esentrada and
        not (idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar) and
        idproducto in (select idproducto from productos where tipoproducto = 2);
  if not found or x is null then x := 0; end if;

  if x <= 0 then return NULL; end if;

  -- AQUI SE BUSCA EN CADA PRESTAMO LA CARTERA Y DIAS VENCIDOS PARA VER SI ESTAN
  -- MAS ATRASADOS QUE EL PRESTAMO QUE SE REESTRUCTURO O RENOVO ORIGINALMENTE
  resp := NULL;
  for r_temp in
    select idorigenp,idproducto,idauxiliar from temporal
    where sesion = p_sesion and idusuario = p_usuario and esentrada and
          not (idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar) and
          idproducto in (select idproducto from productos where tipoproducto = 2)
  loop
    aux_tmp := sai_auxiliar(r_temp.idorigenp, r_temp.idproducto, r_temp.idauxiliar, p_fecha);

    if aux_tmp is not null then
      carterax := trim(sai_token(14,aux_tmp,'|'));
      dvx      := trim(sai_token(4,aux_tmp,'|'))::integer;
      datox    := text(r_temp.idorigenp)||'|'||text(r_temp.idproducto)||'|'||text(r_temp.idauxiliar)||'|'||carterax||'|'
                ||text(dvx);

      if cartera = 'C' then
        if carterax = 'C' then
          if dvx > dv then
            cartera := carterax; dv := dvx; resp := datox;
          end if;
        else
          cartera := carterax; dv := dvx; resp := datox;
        end if;
      end if;

      if cartera = 'M' then
        if carterax = 'M' then
          if dvx > dv then
            cartera := carterax; dv := dvx; resp := datox;
          end if;
        end if;

        if carterax = 'V' then
          cartera := carterax; dv := dvx; resp := datox;
        end if;
      end if;


      if cartera = 'V' then
        if dvx > dv then
          cartera := carterax; dv := dvx; resp := datox;
        end if;
      end if;

    end if;
  end loop;

  return resp;
end;
$$ language 'plpgsql';

create or replace function
sai_reestructuras_y_renovaciones_aplica (integer,integer,integer,integer,_text)
returns varchar as $$
declare
  p_idorigenp           alias for $1;
  p_idproducto          alias for $2;
  p_idauxiliar          alias for $3;
  p_tipo                alias for $4;
  p_mat                 alias for $5;
  p_cartera             varchar;
  p_montoprestado       numeric;
  p_saldo               numeric;
  p_fecha               date;
  p_fechaactivacion     date;
  p_sesion              varchar;
  p_usuario             integer;
  x_fecha_venc          date;
  r_refp                record;
  r_aux                 record;
  r_temp                record;
  tres_cuartas_partes   numeric;
  aux_paso              text;
  ref                   varchar;
  mat                   _text;
  x_con_capital         integer;
  x_plazo_total         integer;
  x_plazo_hasta_hoy     integer;
  x_plazo_porcentual    numeric;
  x_io_total            numeric;
  px1                   text;
  dv                    integer;
  -- SI HAY OTRO/ PRESTAMO AUN MAS ATRASADO AL QUE ESTA EN referenciasp, ESTAS
  -- VARIABLES SON PARA EL OPA
  p_idorigenp2          integer;
  p_idproducto2         integer;
  p_idauxiliar2         integer;
  ref_dv_ec_covid19     varchar;
  x_res_covid           integer;

  es_linea     boolean;
  x            integer;
  es_factoraje boolean;
begin
--raise notice 'sai_reestructuras_y_renovaciones_aplica: %,%,%,%,[%]', $1,$2,$3,$4,$5;

  ---------------------
  --- 1: Autorizado ---
  ---------------------
  if p_tipo = 1 then

    p_fecha   := p_mat[1];
    p_sesion  := p_mat[2];
    p_usuario := p_mat[3];

    select into r_refp rp.*, a.montoautorizado, a.idorigen, a.idgrupo, a.idsocio
           from referenciasp as rp
     inner join auxiliares as a
             on (a.idorigenp = rp.idorigenp and a.idproducto = rp.idproducto and
                 a.idauxiliar = rp.idauxiliar and a.estatus = 1)
          where rp.idorigenp = p_idorigenp and rp.idproducto = p_idproducto and
                rp.idauxiliar = p_idauxiliar and rp.tiporeferencia in (2,3);
    if not found then
      return NULL;
    end if;
-- raise notice 'p_sesion: %, p_usuario: %, idorigenp: %, idproducto: %, idauxiliar: %', p_sesion, p_usuario,
-- r_refp.idorigenp, r_refp.idproducto, r_refp.idauxiliar;
    select into r_temp *
    from        temporal
    where       sesion = p_sesion and idusuario = p_usuario and idorigenp = r_refp.idorigenpr and
                idproducto = r_refp.idproductor and idauxiliar = r_refp.idauxiliarr and
                esentrada;
    if not found then
      mat := p_mat;
      mat := array_append(mat, r_refp.montoautorizado::text);
      mat := array_append(mat, r_refp.idorigen::text);
      mat := array_append(mat, r_refp.idgrupo::text);
      mat := array_append(mat, r_refp.idsocio::text);

      x_res_covid := contingencia_covid19_permite_renovar_sin_liquidar(r_refp.idproducto, mat);
      if x_res_covid != 1 then
        px1 := case when x_res_covid = 0
                    then 'AL ENTREGAR UN PRESTAMO RENOVADO O REESTRUCTURADO DEBE'||E'\012'||
                         '      LIQUDAR EL ANTERIOR EN LA MISMA OPERACION'||E'\012'||E'\012'
                    when x_res_covid = -1
                    then 'DEBE TRASPASAR EL MONTO TOTAL DE LA RENOVACION COVID19 AL PRODUCTO'||E'\012'||
                         '        CORRESPONDIENTE DE ABONOS PROGRAMADOS'||E'\012'||E'\012'
                    when x_res_covid = -2
                    then 'ESTA USANDO UN PRODUCTO INCORRECTO PARA TRASPASAR LA RENOVACION COVID19'||E'\012'||
                         '        SE REQUIERE EL PRODUCTO CORRESPONDIENTE PARA EL ABONO PROGRAMADO'||E'\012'||E'\012'
                    when x_res_covid = -3
                    then 'PARA PODER TRASPASAR LA RENOVACION COVID19 NECESITA DEFINIR EL PRODUCTO'||E'\012'||
                         '        CORRESPONDIENTE EN LA TABLA: param / abonos_programados_a_prestamos'||E'\012'||E'\012'
               end;
        raise exception '%',px1;
      end if;
    end if;

    ref := sai_token(2,r_refp.referencia,'|');

    if ref is NULL or ref = '' then
      select into r_aux *
             from auxiliares
            where idorigenp = r_refp.idorigenpr and idproducto = r_refp.idproductor and
                  idauxiliar = r_refp.idauxiliarr and estatus = 2;
      if not found then
        px1 := 'EL PRESTAMO RENOVADO O REESTRUCTURADO PERDIO LA REFERENCIA'||E'\012'||
               'LLAME A SISTEMAS...'||E'\012'||E'\012';
        raise exception '%',px1;
      end if;

      mat := array[text(r_aux.cartera) , text(r_aux.montoprestado) , text(r_aux.saldo) , text(p_fecha) ,
                   text(r_aux.fechaactivacion) , p_sesion , text(p_usuario)];

      ref := sai_reestructuras_y_renovaciones_aplica(r_aux.idorigenp, r_aux.idproducto, r_aux.idauxiliar, 2, mat );
    end if;
  end if;

  ------------------
  --- 2 : Activo ---
  ------------------
  p_idorigenp2 := 0; p_idproducto2 := 0; p_idauxiliar2 := 0;
  if p_tipo = 2 then
    select
    into   r_refp rp.*, a.estatus, a.tipoprestamo
    from   referenciasp as rp
           inner join auxiliares as a on (a.idorigenp = rp.idorigenp   and a.idproducto = rp.idproducto and
                                          a.idauxiliar = rp.idauxiliar and a.estatus = 1)
    where  rp.idorigenpr = p_idorigenp and rp.idproductor = p_idproducto and rp.idauxiliarr = p_idauxiliar and
           rp.tiporeferencia in (2,3);
    if not found then
      return NULL;
    end if;

    if p_mat is not null then
      p_cartera         := p_mat[1];
      p_montoprestado   := p_mat[2];
      p_saldo           := p_mat[3];
      p_fecha           := p_mat[4];
      p_fechaactivacion := p_mat[5];
      p_sesion          := p_mat[6];
      p_usuario         := p_mat[7];
    end if;
-- raise notice 'trace 0: p_sesion: %, p_usuario: %, idorigenp: %, idproducto: %, idauxiliar: %', p_sesion, p_usuario,
-- r_refp.idorigenp, r_refp.idproducto, r_refp.idauxiliar;
    -- Valida que en el momento de hacer la renovacion o reestructura desde
    -- Traspasos, exista el prestamo (de renov/rest) a entregar, para que sea
    -- ligada la operacion entre los 2 prestamos.
    select into r_temp *
    from        temporal
    where       sesion = p_sesion and idusuario = p_usuario and idorigenp = r_refp.idorigenp and
                idproducto = r_refp.idproducto and idauxiliar = r_refp.idauxiliar and not esentrada;
    if not found then
      return NULL;
    end if;

    ref := sai_token(2,r_refp.referencia,'|');

    if ref is NULL or ref = '' then
      ref := p_cartera;
/*
      es_caja := FALSE;
      --- Deduce que sea cooperativa ---
      select into es_caja (case when dato1 = '1' then TRUE else FALSE end)
      from tablas where idtabla = 'param' and idelemento = 'cooperativa';
*/
      -- Traspasa los DV y La cartera -----
      aux_paso := sai_auxiliar(p_idorigenp,p_idproducto,p_idauxiliar,p_fecha);

      px1 := sai_token(14,aux_paso,'|'); -- Estatus cartera
      if px1 is not null and px1 in ('C','M','V') then p_cartera := px1; end if;

      dv := 0;
      px1 := sai_token(4,aux_paso,'|'); -- Dias vencidos
      if px1 is not null and px1 != '' then dv := px1::integer; end if;

      -- QUE PASA SI AL LIQUIDAR ESTE PRESTAMO, PUEDE ESTAR AL CORRIENTE Y SE
      -- LIQUIDAN OTROS QUE ESTAN VENCIDOS ?? AQUI SE HACE LA BUSQUEDA, PARA
      -- CAMBIAR EL CAMPO referencia EN referenciasp
      px1 := NULL;
      px1 := hay_prestamos_mas_vencidos_en_temporal(p_idorigenp, p_idproducto, p_idauxiliar, p_fecha, p_sesion,
                                                    p_usuario, p_cartera, dv);
 
 -- ------------------------------------------------------------ CONTINGENCIA COVID19 --------------------------------------------------------------
      if r_refp.tipoprestamo = 5 then
        ref_dv_ec_covid19 := contingencia_covid19_hereda_cartera_y_diasvencidos(p_idorigenp, p_idproducto, p_idauxiliar, dv, p_cartera);
        if px1 is not NULL then
          px1 := 'NO PUEDE ENTREGAR UNA RENOVACION DE TIPO CONTINGENCIA COVID19 SI HAY MAS DE 1 PRESTAMO A LIQUIDAR'||E'\012'||E'\012';
          raise exception '%',px1;
        else
          update referenciasp
          set    referencia = ref_dv_ec_covid19
          where  idorigenpr = r_refp.idorigenpr and idproductor = r_refp.idproductor and idauxiliarr = r_refp.idauxiliarr and
                 tiporeferencia = r_refp.tiporeferencia;

          return sai_token(2,ref_dv_ec_covid19,'|');
        end if;
      end if;
-- ------------------------------------------------------------ CONTINGENCIA COVID19 --------------------------------------------------------------

      if px1 is not NULL then
        p_idorigenp2  := trim(sai_token(1, px1, '|'))::integer;
        p_idproducto2 := trim(sai_token(2, px1, '|'))::integer;
        p_idauxiliar2 := trim(sai_token(3, px1, '|'))::integer;
        p_cartera     := trim(sai_token(4, px1, '|'));
        dv            := trim(sai_token(5, px1, '|'))::integer;

        aux_paso := sai_auxiliar(p_idorigenp2, p_idproducto2, p_idauxiliar2, p_fecha);

        select into p_saldo, p_montoprestado, p_fechaactivacion
                    saldo, montoprestado, fechaactivacion
        from auxiliares
        where idorigenp = p_idorigenp2 and idproducto = p_idproducto2 and idauxiliar = p_idauxiliar2;
      end if;


      --- Se nos hizo la observacion de que una de las condiciones para no
      --- marcar como vencido un credito reestructurado es considerar que este
      --- en una linea de credito (JFPA, 18/JULIO/2021)
      es_linea := FALSE; x := 0;
      if p_idorigenp2 > 0 and p_idproducto2 > 0 and p_idauxiliar2 > 0 then
        select into x count(*) from limite_de_credito
        where (idorigen, idgrupo, idsocio) in
              (select idorigen, idgrupo, idsocio from auxiliares
               where idorigenp = p_idorigenp2 and idproducto = p_idproducto2 and idauxiliar = p_idauxiliar2) and
              (idproducto = p_idproducto2 or idproducto = 39999);
        if not found or x is NULL then x := 0; end if;
      else
        select into x count(*) from limite_de_credito
        where (idorigen, idgrupo, idsocio) in
              (select idorigen, idgrupo, idsocio from auxiliares
               where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar) and
              (idproducto = p_idproducto or idproducto = 39999);
        if not found or x is NULL then x := 0; end if;
      end if;
      if x > 0 then es_linea := TRUE; end if;


      if p_cartera = 'C' then
        if p_idorigenp2 > 0 and p_idproducto2 > 0 and p_idauxiliar2 > 0 then
          select into x_con_capital count(*) from amortizaciones
          where idorigenp = p_idorigenp2 and idproducto = p_idproducto2 and idauxiliar = p_idauxiliar2 and abono > 0;
        else
          select into x_con_capital count(*) from amortizaciones
          where idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and abono > 0;
        end if;

        if x_con_capital > 1 then

          x_fecha_venc        := sai_token(9,aux_paso,'|')::date; -- Fecha en que termina el credito
          x_io_total          := sai_token(7,aux_paso,'|')::numeric;

          x_plazo_total       := x_fecha_venc - p_fechaactivacion;  -- DIAS de inicio a fin del credito
          x_plazo_hasta_hoy   := p_fecha      - p_fechaactivacion;  -- DIAS de inicio a hoy del credito

          x_plazo_porcentual  := x_plazo_hasta_hoy::numeric / x_plazo_total::numeric; -- Plazo Porcentual (en porcentaje)

          if x_io_total = 0 then                       -- Int.Ord. Pagado --
            if x_plazo_porcentual > 0.80 then          -- 0.8001 al 1.00 % (transcurso del 20% final)
              if p_saldo < p_montoprestado * 0.40 then -- Haber cubierto mas del 60% del saldo (saldo menos del 40%)
                ref := p_cartera;
              else
                ref := 'V';
              end if;
            else  -- 1 al 80
              ref := p_cartera;
            end if;
          else
            ref := 'V';
          end if;
        else

          -- Aunque sea prestamo de un solo pago, de debe evaluar que :
          -- 1) si es de una linea de credito
          -- 2) si ya cubrio la totalidad de los intereses
          -- 3) haber cubierto los pagos hasta la fecha actual
          -- Por el momento solo se validara la condicion 1 para los prestamos
          -- de FACTORAJE (JFPA, 19/JULIO/2021)
          es_factoraje := FALSE; x := 0;
          select into x count(*)
          from productos
          where tasasp > 0 and tipoproducto = 2 and
                idproducto = (case when p_idproducto2 > 0 then p_idproducto2 else p_idproducto end);
          if not found or x is NULL then x := 0; end if;
          if x > 0 then es_factoraje := TRUE; end if;

          ref := (case when es_factoraje and es_linea then 'C' else 'V' end);

        end if;
      else
        ref := 'V';
      end if;

      if p_idorigenp2 > 0 and p_idproducto2 > 0 and p_idauxiliar2 > 0 then
        update referenciasp
        set    referencia = text(dv)||'|'||ref,
               idorigenpr = p_idorigenp2, idproductor = p_idproducto2, idauxiliarr = p_idauxiliar2
        where  idorigenpr = r_refp.idorigenpr and idproductor = r_refp.idproductor and idauxiliarr = r_refp.idauxiliarr and
               tiporeferencia = r_refp.tiporeferencia;
      else
        update referenciasp
        set    referencia = sai_token(4,aux_paso,'|')||'|'||ref
        where  idorigenpr = r_refp.idorigenpr and idproductor = r_refp.idproductor and idauxiliarr = r_refp.idauxiliarr and
               tiporeferencia = r_refp.tiporeferencia;
      end if;
    end if;

  end if;

  ------------------------------------------------------------------------------
  -- ULTIMA MODIFICACION : 19/JULIO/2021 ---------------------------------------
  ------------------------------------------------------------------------------

  return ref;
end;
$$ language 'plpgsql';

--------------------------------------------------------------------------------
-- ESTAS FUNCIONES SE HICIERON PARA CAJA SAN NICOLAS PARA EL SISTEMA SISCORE ---
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION
datos_de_los_avalados(INTEGER, INTEGER, INTEGER, DATE)
RETURNS TEXT AS '
DECLARE
  p_idorigen   ALIAS FOR $1;
  p_idgrupo    ALIAS FOR $2;
  p_idsocio    ALIAS FOR $3;
  p_fecha_hoy  ALIAS FOR $4;

  r_avalados RECORD;
  dias       NUMERIC;
  saldosx    NUMERIC;
  abonosx    NUMERIC;
  montox     NUMERIC;
  montoy     NUMERIC;
  montoz     NUMERIC;
  tasa_iva   NUMERIC;
  px1        VARCHAR;
  px2        VARCHAR;
  resultado  TEXT;
BEGIN
  saldosx := 0; abonosx := 0;
  FOR r_avalados IN
    SELECT a.* FROM auxiliares a INNER JOIN productos p USING (idproducto)
    WHERE p.tipoproducto = 2 AND a.estatus = 2 AND a.idorigenp > 0 AND
          a.idproducto > 0 AND a.idauxiliar > 0 AND
          (a.idorigen,a.idgrupo,a.idsocio) IN
          (SELECT idorigen,idgrupo,idsocio FROM referencias
           WHERE idorigenr = p_idorigen AND idgrupor = p_idgrupo AND
                 idsocior = p_idsocio AND tiporeferencia = 8)
  LOOP
    -- Acumulacion de los saldos --
    saldosx := saldosx + r_avalados.saldo;

    IF r_avalados.tipoamortizacion = 2 OR r_avalados.tipoamortizacion = 4 OR
       r_avalados.tipoamortizacion = 5 THEN

      tasa_iva := 0.0;
      tasa_iva := sai_iva_segun_sucursal(
                      r_avalados.idorigenp, r_avalados.idproducto, 0);
      IF tasa_iva = 0 THEN tasa_iva := 16.0; END IF;

      IF r_avalados.periodoabonos = 0 THEN dias := 30.4;
      ELSE dias = r_avalados.periodoabonos;
      END IF;

      montox := 0.0; montoy := 0.0;
      montox := (r_avalados.tasaio/100.0)*(1 + (tasa_iva/100.0));
      montoy := (montox/30.0)*dias;
      montox := 0.0;
      montox = (r_avalados.montoprestado*montoy)/(1-(1/POW((1+montoy)::NUMERIC,
                                                 r_avalados.plazo::NUMERIC)));
      montoz := ROUND(montox, 2);
    ELSE
      montoz := ROUND((r_avalados.montoprestado/r_avalados.plazo), 2);
    END IF;
    abonosx := abonosx + montoz;
  END LOOP;

  px1 := CASE WHEN saldosx IS NULL THEN ''0.00''
              ELSE TRIM(TO_CHAR(saldosx,''99999999.99'')) END;
  px2 := CASE WHEN abonosx IS NULL THEN ''0.00''
              ELSE TRIM(TO_CHAR(abonosx,''99999999.99'')) END;

  resultado := TEXT(px1||''|''||px2);

  RETURN resultado;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION
lista_variables_socio(INTEGER, INTEGER, INTEGER)
RETURNS TEXT AS '
DECLARE
  p_idorigenp  ALIAS FOR $1;
  p_idproducto ALIAS FOR $2;
  p_idauxiliar ALIAS FOR $3;

  -- OGS DEL SOLICITANTE --
  r_datos        RECORD;
  r_trabajo1     RECORD;
  r_trabajo2     RECORD;
  r_trabajo3     RECORD;
  r_s_economicos RECORD;
  r_pagos        RECORD;
  hay_trabajo1   BOOLEAN;
  hay_trabajo2   BOOLEAN;
  hay_trabajo3   BOOLEAN;
  idorigenp_ah   INTEGER;
  idproducto_ah  INTEGER;
  idauxiliar_ah  INTEGER;

  -- OGS DEL CONYUGE --
  idorigen_c       INTEGER;
  idgrupo_c        INTEGER;
  idsocio_c        INTEGER;
  hay_conyuge      BOOLEAN;
  r_datos_c        RECORD;
  r_trabajo1_c     RECORD;
  r_trabajo2_c     RECORD;
  r_trabajo3_c     RECORD;
  r_s_economicos_c RECORD;
  hay_trabajo1_c   BOOLEAN;
  hay_trabajo2_c   BOOLEAN;
  hay_trabajo3_c   BOOLEAN;

  -- OGS DEL AVAL 1 --
  idorigen_a1  INTEGER;
  idgrupo_a1   INTEGER;
  idsocio_a1   INTEGER;
  hay_aval1    BOOLEAN;
  r_datos_a1   RECORD;
  r_trabajo_a1 RECORD;
  r_s_economicos_a1 RECORD;

  -- OGS DEL AVAL 2 --
  idorigen_a2  INTEGER;
  idgrupo_a2   INTEGER;
  idsocio_a2   INTEGER;
  hay_aval2    BOOLEAN;
  r_datos_a2   RECORD;
  r_trabajo_a2 RECORD;
  r_s_economicos_a2 RECORD;

  -- OGS DEL GARANTE PRENDARIO --
  idorigen_gp  INTEGER;
  idgrupo_gp   INTEGER;
  idsocio_gp   INTEGER;
  hay_gp       BOOLEAN;
  r_datos_gp   RECORD;
  r_trabajo_gp RECORD;

  r_datosx  RECORD;

  fecha_hoy DATE;
  mensaje   TEXT;
  r_aux     RECORD;
  px1       TEXT;
  px2       TEXT;
  x         INTEGER;
  y         INTEGER;
  z         INTEGER;
  cred_e1   INTEGER;
  cred_e2   INTEGER;
  cred_e3   INTEGER;
  cred_e4   INTEGER;
  montox    NUMERIC;
  montoy    NUMERIC;
  montoz    NUMERIC;
  saldosx   NUMERIC;
  abonosx   NUMERIC;
  tasa_iva  NUMERIC;
  dias      NUMERIC;

  -------------------------
  -- VARIABLES DEL SOCIO --
  -------------------------
  act_economica VARCHAR; -- Actividad Economica
  act_economica_conyuge VARCHAR; -- Actividad Economica Conyuge
  ahorro_2o_mes_ant VARCHAR; -- Ahorro durante el 2o mes anterior
  ahorro_3er_mes_ant VARCHAR; -- Ahorro durante el 3er mes anterior
  ahorro_1er_mes_ant VARCHAR; -- Ahorro durante el mes anterior
  am_mas_alto_3y_1 VARCHAR; -- AM mas alto en tres anios 1
  am_mas_alto_3y_2 VARCHAR; -- AM mas alto en tres anios 2
  am_mas_alto_3y_3 VARCHAR; -- AM mas alto en tres anios 3
  am_mas_alto_3y_4 VARCHAR; -- AM mas alto en tres anios 4
  am_mas_alto_3y_5 VARCHAR; -- AM mas alto en tres anios 5
  am_mas_alto_3y_6 VARCHAR; -- AM mas alto en tres anios 6
  ant_garprendaria VARCHAR; -- Antiguedad de la Garantia Prendaria en anios
  ant_auto VARCHAR; -- Antiguedad del auto (en anios)

  comp_ingresos_1 VARCHAR; -- Comprobacion Ingresos 1
  comp_ingresos_2 VARCHAR; -- Comprobacion Ingresos 2
  comp_ingresos_3 VARCHAR; -- Comprobacion Ingresos 3
  comp_ingresos_conyuge_1 VARCHAR; -- Comprobacion Ingresos Conyuge 1
  comp_ingresos_conyuge_2 VARCHAR; -- Comprobacion Ingresos Conyuge 2
  comp_ingresos_conyuge_3 VARCHAR; -- Comprobacion Ingresos Conyuge 3

  dep_edo_cuenta_1 VARCHAR; -- Depositos Estado de Cuenta 1
  dep_edo_cuenta_2 VARCHAR; -- Depositos Estado de Cuenta 2
  dep_edo_cuenta_3 VARCHAR; -- Depositos Estado de Cuenta 3
  dep_edo_cuenta_conyuge_1 VARCHAR; -- Depositos Estado de Cuenta_C 1
  dep_edo_cuenta_conyuge_2 VARCHAR; -- Depositos Estado de Cuenta_C 2
  dep_edo_cuenta_conyuge_3 VARCHAR; -- Depositos Estado de Cuenta_C 3

  destino_credito VARCHAR; -- Destino del credito
  destino_vehiculo VARCHAR; -- Destino del vehiculo
  destino_operacion VARCHAR; -- Destino Operacion
  dom_aval1_mismo_del_solicitante VARCHAR; -- Domicilio de Aval 1 es mismo del Solicitante
  dom_aval2_mismo_del_solicitante VARCHAR; -- Domicilio de Aval 2 es mismo del Solicitante
  aval1_es_socio VARCHAR; -- El Aval 1 es socio
  aval2_es_socio VARCHAR; -- El Aval 2 es socio

  enganche VARCHAR; -- Enganche
  escolaridad VARCHAR; -- Escolaridad
  edo_civil VARCHAR; -- Estado Civil
  fecha_ingreso VARCHAR; -- Fecha de Ingreso como Socio
  fecha_nacimiento VARCHAR; -- Fecha de Nacimiento
  fecha_domicilio VARCHAR; -- Fecha Domicilio
  fecha_nac_aval1 VARCHAR; -- Fecha Nacimiento Aval 1
  fecha_nac_aval2 VARCHAR; -- Fecha Nacimiento Aval 2
  fecha_nac_otorgante_gar_prend VARCHAR; -- Fecha Nac. Otorgante Gtia Prendaria

  gasto_mensual_familiar VARCHAR; -- Gasto mensual manutencion familiar
  sexo VARCHAR; -- Genero
  ing_mens_bruto_aval1 VARCHAR; -- Ingreso bruto mensual Aval 1
  ing_mens_bruto_aval2 VARCHAR; -- Ingreso bruto mensual Aval 2
  ing_mens_bruto_concesionario VARCHAR; -- Ing. bruto mensual Concesionario
  ing_mens_bruto_concesionario_conyuge VARCHAR; -- Ing. bruto mensual Concesionario_C
  ing_mens_bruto_nomina VARCHAR; -- Ingreso bruto mensual nomina
  ing_mens_bruto_nomina_conyuge VARCHAR; -- Ingreso bruto mensual nomina_C
  ing_mens_bruto_carta_cont_conyuge VARCHAR; -- Ingreso bruto mensual segun Carta Contador_C
  ing_mens_bruto_carta_patron_conyuge VARCHAR; -- Ingreso bruto mensual segun Carta Patron_C
  ing_mens_bruto_taxista VARCHAR; -- Ingreso bruto mensual taxista
  ing_mens_bruto_taxista_conyuge VARCHAR; -- Ingreso bruto mensual taxista_C
  ing_mens_bruto_carta_cont VARCHAR; -- Ingreso mensual bruto segun Carta Contador
  ing_mens_bruto_carta_patron VARCHAR; -- Ingreso mensual bruto segun Carta Patron
  meses_en_empleo VARCHAR; -- Meses en el Empleo o Actividad
  meses_en_empleo_conyuge VARCHAR; -- Meses en el Empleo o Actividad Conyuge

  monto_credito VARCHAR; -- Monto del Credito original
  monto_contrato_arrendamiento VARCHAR; -- Monto en Contrato de Arrendamiento
  monto_contrato_arrendamiento_conyuge VARCHAR; -- Monto en Contrato de Arrendamiento_C
  monto_riesgo_autocredito VARCHAR; -- Monto en riesgo Autocredito
  monto_riesgo_credi10 VARCHAR; -- Monto en riesgo Credi 10
  monto_riesgo_credifise VARCHAR; -- Monto en riesgo Credifise
  monto_riesgo_elite VARCHAR; -- Monto en riesgo Elite
  monto_riesgo_hipotecario VARCHAR; -- Monto en riesgo Hipotecario
  monto_riesgo_nom_empresarial VARCHAR; -- Monto en riesgo Nomina Empresarial
  monto_riesgo_ordinario VARCHAR; -- Monto en riesgo Ordinario
  monto_riesgo_confianza VARCHAR; -- Monto en riesgo Prestamo Confianza
  monto_riesgo_prest_extraordinario VARCHAR; -- Monto en riesgo Prestamo extraordinario
  monto_riesgo_prest_gerencial VARCHAR; -- Monto en riesgo Prestamo Gerencial
  monto_riesgo_prest_reestruct VARCHAR; -- Monto en riesgo Prestamo reestructurado
  monto_riesgo_prest_renovado VARCHAR; -- Monto en riesgo Prestamo renovado
  monto_riesgo_prest_simple VARCHAR; -- Monto en Riesgo Prestamo Simple
  monto_riesgo_prest_inversion VARCHAR; -- Monto en riesgo Prestamo sobre Inversion
  monto_solicitado VARCHAR; -- Monto Solicitado

  -- TODOS LOS CAMPOS DE MOROSIDAD SON EN MESES Y ES EL --
  -- VALOR MAXIMO EN EL LAPSO DE TIEMPO ESPECIFICADO -----
  morosidad_actual VARCHAR; -- Morosidad actual
  morosidad_avalados_12m VARCHAR; -- Morosidad maxima avalados ultimos 12 meses
  morosidad_solicitante_es_conyuge_12m VARCHAR; -- Morosidad maxima en Solicitante es Conyuge ultimos 12 meses
  morosidad_solicitante VARCHAR; -- Morosidad maxima historica
  morosidad_solicitante_ultimos_12m VARCHAR; -- Morosidad maxima ultimos 12 meses
  morosidad_solicitante_ultimos_24m VARCHAR; -- Morosidad maxima ultimos 24 meses
  morosidad_vig_aval1 VARCHAR; -- Morosidad maxima vigente Aval 1
  morosidad_vig_aval2 VARCHAR; -- Morosidad maxima vigente Aval 2
  morosidad_vig_aval1_es_conyuge VARCHAR; -- Morosidad maxima vigente  en Aval 1 es Conyuge
  morosidad_vig_aval2_es_conyuge VARCHAR; -- Morosidad maxima vigente en Aval 2 es Conyuge
  morosidad_vig_avalados_aval1 VARCHAR; -- Morosidad maxima vigente en creditos avalados Aval 1
  morosidad_vig_avalados_aval2 VARCHAR; -- Morosidad maxima vigente en creditos avalados Aval 2

  num_avales VARCHAR; -- Num. de avales
  num_creditos_vivos_avalados VARCHAR; -- Num. de Cred. vivos avalados por Solicitante
  num_creditos_vivos_avalados_conyuge VARCHAR; -- Num. de Cred. vivos Solicitante es Conyuge ***
  num_dependientes VARCHAR; -- Numero de dependientes
  num_despendientes_esc VARCHAR; -- Numero de dependientes escolares
  num_empleados VARCHAR; -- Numero de empleados (incluyendose)
  num_empleados_conyuge VARCHAR; -- Numero de Empleados Conyuge (incluyendose)
  num_taxis VARCHAR; -- Numero de taxis
  num_taxis_conyuge VARCHAR; -- Numero de taxis Conyuge

  ocupacion VARCHAR; -- Ocupacion en el Empleo
  ocupacion_conyuge VARCHAR; -- Ocupacion en el Empleo Conyuge
  ocupacion_principal VARCHAR; -- Ocupacion Principal
  ocupacion_principal_conyuge VARCHAR; -- Ocupacion Principal Conyuge
  pago_mensual_deudas_por_nomina VARCHAR; -- Pago mensual de deudas retenidas en nomina
  pago_mensual_deudas_por_nomina_conyuge VARCHAR; -- Pago mensual de deudas retenidas en nomina_C
  pago_mensual VARCHAR; -- Pago mensual de la Operacion
  plazo_meses VARCHAR; -- Plazo en meses

  pago_mens_max_3a_1 VARCHAR; -- PM por Credito mas alto en tres anios 1
  pago_mens_max_3a_2 VARCHAR; -- PM por Credito mas alto en tres anios 2
  pago_mens_max_3a_3 VARCHAR; -- PM por Credito mas alto en tres anios 3
  pago_mens_max_3a_4 VARCHAR; -- PM por Credito mas alto en tres anios 4
  pago_mens_max_3a_5 VARCHAR; -- PM por Credito mas alto en tres anios 5
  pago_mens_max_3a_6 VARCHAR; -- PM por Credito mas alto en tres anios 6

  predial_aval1 VARCHAR; -- Presenta Predial Aval 1
  predial_aval2 VARCHAR; -- Presenta Predial Aval 2

  saldo_certificados VARCHAR; -- Saldo actual en Certificados de Aportacion
  saldo_credito_original VARCHAR; -- Saldo del Credito original
  saldo_ahorro VARCHAR; -- Saldo en Ahorro actual
  monto_max_hist_morosidad3m VARCHAR; -- Monto maximo historico de prestamos con morosidad >= 3 ***

  sector_actividad VARCHAR; -- Sector de Actividad
  sector_actividad_conyuge VARCHAR; -- Sector de Actividad Conyuge
  monto_riesgo_avalados_aval1 VARCHAR; -- Suma de Monto en Riesgo avalado Aval 1
  monto_riesgo_avalados_aval2 VARCHAR; -- Suma de Monto en Riesgo avalado Aval 2
  pagos_mens_avalados_aval1 VARCHAR; -- Suma de Pagos mensuales avalados Aval 1
  pagos_mens_avalados_aval2 VARCHAR; -- Suma de Pagos mensuales avalados Aval 2
  tipo_credito_a_convertir VARCHAR; -- Tipo de credito que se va a convertir
  tipo_garantia_prendaria_coche VARCHAR; -- Tipo de Garantia Prendaria automotor
  tipo_operacion VARCHAR; -- Tipo de Operacion
  direccion_gar_hip VARCHAR; -- Ubicacion Garantia Hipotecaria
  valor_gar_prendaria VARCHAR; -- Valor de Garantia prendaria
  valor_gar_real VARCHAR; -- Valor de Garantia real
  valor_relacion_patr_aval1 VARCHAR; -- Valor de relacion patrimonial Aval 1
  valor_relacion_patr_aval2 VARCHAR; -- Valor de relacion patrimonial Aval 2
  valor_venta_automovil VARCHAR; -- Valor de venta del automovil
  vendedor_auto_seminuevo VARCHAR; -- Vendedor de auto seminuevo
  impuestos_y_deducciones VARCHAR; -- Impuestos y otras deducciones mensuales
  impuestos_y_deducciones_conyuge VARCHAR; -- Impuestos y otras deducciones mensuales_C

  numcred_factor_elite VARCHAR; -- Num. de cred. historicos para factor Elite
  numcred_factor_elite_10a VARCHAR; -- Num. de cred. ultimos 10 anios factor Elite
  numcred_factor_elite_3a VARCHAR; -- Num. de cred. ultimos 3 anios factor Elite
  numcred_factor_elite_5a VARCHAR; -- Num. de cred. ultimos 5 anios factor Elite

  fecha_venc_inversion VARCHAR; -- Fecha de vencimiento de la inversion
  fecha_venc_credito VARCHAR; -- Fecha de vencimiento del credito
  monto_penult_cred_factor_elite_3a VARCHAR; -- Monto del penultimo credito Factor Elite en los ultimos 3 anios
  monto_ult_cred_factor_elite_3a VARCHAR; -- Monto del ultimo credito Factor Elite en los ultimos 3 anios
  saldo_inv_actual VARCHAR; -- Saldo en Inversion actual (sin intereses)
  valor_avaluo_vivienda VARCHAR; -- Valor de avaluo de la vivienda
  valor_venta_vivienda VARCHAR; -- Valor de venta de la vivienda
  pago_mensual_credifise VARCHAR; -- Pago mensual Credifise

  predial_solicitante VARCHAR; -- Presenta Predial Solicitante
  valor_inmueble VARCHAR; -- Valor estimado Inmueble Solicitante
  es_renovacion VARCHAR; -- Es renovacion
  folio_credito_renovado VARCHAR; -- Numero de Credito que renueva
  nombre_credito_reestructurado VARCHAR; -- Tipo de Credito que reestructura

  resultado TEXT;

BEGIN
  SELECT INTO fecha_hoy DATE(fechatrabajo) FROM origenes LIMIT 1;
  IF NOT FOUND THEN fecha_hoy := DATE(NOW()); END IF;

  ------------------------------------------------------------------------------
  -- DATOS DEL SOCIO Y DEL PRESTAMO --------------------------------------------
  ------------------------------------------------------------------------------
----> p.fechaingreso,p.fechanacimiento
----- a.montosolicitado,a.plazo,a.montosolicitado,a.tipoamortizacion,a.tasaio
----- a.idfinalidad
  SELECT INTO r_datos p.*,a.*
  FROM personas p INNER JOIN auxiliares a USING (idorigen,idgrupo,idsocio)
  WHERE a.idorigenp = p_idorigenp AND a.idproducto = p_idproducto AND
        a.idauxiliar = p_idauxiliar;
  IF NOT FOUND THEN
    mensaje := ''EL FOLIO ''||TRIM(TO_CHAR(p_idorigenp,''099999''))||''-''||
                              TRIM(TO_CHAR(p_idproducto,''09999''))||''-''||
                              TRIM(TO_CHAR(p_idauxiliar,''09999999''))||
               '' NO EXISTE !!!'';
    RAISE EXCEPTION ''%'', mensaje;
  END IF;

  SELECT INTO r_s_economicos *,
              (CASE WHEN gastosordinarios IS NULL THEN 0.0
                    ELSE gastosordinarios END) AS s_gastosordinarios,
              (CASE WHEN gastosextraordinarios IS NULL THEN 0.0
                    ELSE gastosextraordinarios END) AS s_gastosextraordinarios,
              (CASE WHEN fechahabitacion is NOT NULL
                    THEN ROUND((DATE_MI(fecha_hoy,DATE(fechahabitacion))/365.0),1)
                    ELSE 0.0 END) AS s_tiemporesidencia
  FROM socioeconomicos
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio;

  -- PARA LOS TRABAJOS ESTOY CONSIDERANDO QUE EL VALOR DEL CAMPO --
  -- consecutivo ES 1 PARA EL TRABAJO MAS ANTIGUO Y EL SUBINDICE --
  -- 1 DE LAS VARIABLES record ES PARA EL MAS NUEVO ---------------
  hay_trabajo1 := FALSE; hay_trabajo2 := FALSE; hay_trabajo3 := FALSE; x := 0;
  SELECT INTO x COUNT(*) FROM trabajo
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio;

  act_economica := '''';
  IF x > 0 THEN
    SELECT INTO r_trabajo1 *,
           CASE WHEN fechaingreso IS NOT NULL
                THEN TRIM(TO_CHAR(
                            ROUND(DATE_MI(fecha_hoy,
                                  DATE(fechaingreso))/30.4,0),''999''))
                ELSE '''' END AS antiguedad
    FROM trabajo
    WHERE idorigen=r_datos.idorigen AND idgrupo=r_datos.idgrupo AND
          idsocio=r_datos.idsocio AND consecutivo=x;
    IF FOUND THEN hay_trabajo1 := TRUE; END IF;

    IF hay_trabajo1 THEN
      SELECT INTO act_economica descripcion FROM actividades_economicas
      WHERE id_actividad = r_trabajo1.actividad_economica;
      IF NOT FOUND OR act_economica IS NULL THEN act_economica := ''''; END IF;
    END IF;

    IF x > 1 THEN
      SELECT INTO r_trabajo2 *,
             CASE WHEN fechaingreso IS NOT NULL
                  THEN TRIM(TO_CHAR(
                              ROUND(DATE_MI(fecha_hoy,
                                    DATE(fechaingreso))/30.4,0),''999''))
                  ELSE '''' END AS antiguedad
      FROM trabajo
      WHERE idorigen=r_datos.idorigen AND idgrupo=r_datos.idgrupo AND
            idsocio=r_datos.idsocio AND consecutivo=x-1;
      IF FOUND THEN hay_trabajo2 := TRUE; END IF;
    END IF;

    IF x > 2 THEN
      SELECT INTO r_trabajo3 *,
             CASE WHEN fechaingreso IS NOT NULL
                  THEN TRIM(TO_CHAR(DATE_MI(fecha_hoy,
                                    DATE(fechaingreso))/30.4,''999.9''))
                  ELSE '''' END AS antiguedad
      FROM trabajo
      WHERE idorigen=r_datos.idorigen AND idgrupo=r_datos.idgrupo AND
            idsocio=r_datos.idsocio AND consecutivo=x-2;
      IF FOUND THEN hay_trabajo3 := TRUE; END IF;
    END IF;
  END IF;

  ------------------------------------------------------------------------------
  -- DATOS DEL CONYUGE ---------------------------------------------------------
  ------------------------------------------------------------------------------
  hay_conyuge := FALSE;
  SELECT INTO idorigen_c,idgrupo_c,idsocio_c idorigenr,idgrupor,idsocior
  FROM referencias
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND tiporeferencia = 1;
  IF FOUND THEN hay_conyuge := TRUE; END IF;

  IF hay_conyuge THEN
    SELECT INTO r_datos_c * FROM personas
    WHERE idorigen = idorigen_c AND idgrupo = idgrupo_c AND idsocio = idsocio_c;
    IF NOT FOUND THEN hay_conyuge := FALSE; END IF;
  END IF;

  hay_trabajo1_c := FALSE; hay_trabajo2_c := FALSE; hay_trabajo3_c := FALSE;
  act_economica_conyuge := '''';
  IF hay_conyuge THEN
    x := 0;
    SELECT INTO x COUNT(*) FROM trabajo
    WHERE idorigen = idorigen_c AND idgrupo = idgrupo_c AND idsocio = idsocio_c;

    IF x > 0 THEN
      SELECT INTO r_trabajo1_c *,
             CASE WHEN fechaingreso IS NOT NULL
                  THEN TRIM(TO_CHAR(DATE_MI(fecha_hoy,
                                    DATE(fechaingreso))/30.4,''999.9''))
                  ELSE '''' END AS antiguedad
      FROM trabajo
      WHERE idorigen = idorigen_c AND idgrupo = idgrupo_c AND
            idsocio = idsocio_c AND consecutivo=x;
      IF FOUND THEN hay_trabajo1_c := TRUE; END IF;

      IF hay_trabajo1_c THEN
        SELECT INTO act_economica_conyuge descripcion
        FROM actividades_economicas
        WHERE id_actividad = r_trabajo1_c.actividad_economica;
        IF NOT FOUND OR act_economica_conyuge IS NULL THEN
          act_economica_conyuge := '''';
        END IF;
      END IF;

      IF x > 1 THEN
        SELECT INTO r_trabajo2_c *,
               CASE WHEN fechaingreso IS NOT NULL
                    THEN TRIM(TO_CHAR(DATE_MI(fecha_hoy,
                                      DATE(fechaingreso))/30.4,''999.9''))
                    ELSE '''' END AS antiguedad
        FROM trabajo
        WHERE idorigen = idorigen_c AND idgrupo = idgrupo_c AND
              idsocio = idsocio_c AND consecutivo=x-1;
        IF FOUND THEN hay_trabajo2_c := TRUE; END IF;
      END IF;

      IF x > 2 THEN
        SELECT INTO r_trabajo3_c *,
               CASE WHEN fechaingreso IS NOT NULL
                    THEN TRIM(TO_CHAR(DATE_MI(fecha_hoy,
                                      DATE(fechaingreso))/30.4,''999.9''))
                    ELSE '''' END AS antiguedad
        FROM trabajo
        WHERE idorigen = idorigen_c AND idgrupo = idgrupo_c AND
              idsocio = idsocio_c AND consecutivo=x-2;
        IF FOUND THEN hay_trabajo3_c := TRUE; END IF;
      END IF;
    END IF;

    SELECT INTO r_s_economicos_c *,
              (CASE WHEN gastosordinarios IS NULL THEN 0.0
                    ELSE gastosordinarios END) AS s_gastosordinarios,
              (CASE WHEN gastosextraordinarios IS NULL THEN 0.0
                    ELSE gastosextraordinarios END) AS s_gastosextraordinarios,
              (CASE WHEN fechahabitacion is NOT NULL
                    THEN ROUND((DATE_MI(fecha_hoy,DATE(fechahabitacion))/365.0),1)
                    ELSE 0.0 END) AS s_tiemporesidencia
    FROM socioeconomicos
    WHERE idorigen=idorigen_c AND idgrupo=idgrupo_c AND idsocio=idsocio_c;
  END IF;

  ------------------------------------------------------------------------------
  -- DATOS DEL AVAL 1 ----------------------------------------------------------
  ------------------------------------------------------------------------------
  hay_aval1 := FALSE;
  px1 := ''1|''||TRIM(TO_CHAR(p_idorigenp,''099999''))||''|''||
         TRIM(TO_CHAR(p_idproducto,''09999''))||''|''||
         TRIM(TO_CHAR(p_idauxiliar,''09999999''))||''%'';
  SELECT INTO idorigen_a1,idgrupo_a1,idsocio_a1 idorigenr,idgrupor,idsocior
  FROM referencias
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND referencia LIKE px1 AND tiporeferencia = 8;
  IF FOUND THEN hay_aval1 := TRUE; END IF;

  IF hay_aval1 THEN
    SELECT INTO r_datos_a1 * FROM personas
    WHERE idorigen=idorigen_a1 AND idgrupo=idgrupo_a1 AND idsocio=idsocio_a1;
    IF NOT FOUND THEN hay_aval1 := FALSE; END IF;
  END IF;
  IF hay_aval1 THEN
    SELECT INTO r_trabajo_a1 *,
           CASE WHEN fechaingreso IS NOT NULL
                THEN TRIM(TO_CHAR(DATE_MI(fecha_hoy,
                                  DATE(fechaingreso))/30.4,''999.9''))
                ELSE '''' END AS antiguedad
    FROM trabajo
    WHERE idorigen=idorigen_a1 AND idgrupo=idgrupo_a1 AND idsocio=idsocio_a1
    ORDER BY fechaingreso DESC LIMIT 1;

    SELECT INTO r_s_economicos_a1 * FROM socioeconomicos
    WHERE idorigen=idorigen_a1 AND idgrupo=idgrupo_a1 AND idsocio=idsocio_a1;
  END IF;

  ------------------------------------------------------------------------------
  -- DATOS DEL AVAL 2 ----------------------------------------------------------
  ------------------------------------------------------------------------------
  hay_aval2 := FALSE;
  px1 := ''2|''||TRIM(TO_CHAR(p_idorigenp,''099999''))||''|''||
         TRIM(TO_CHAR(p_idproducto,''09999''))||''|''||
         TRIM(TO_CHAR(p_idauxiliar,''09999999''))||''%'';
  SELECT INTO idorigen_a2,idgrupo_a2,idsocio_a2 idorigenr,idgrupor,idsocior
  FROM referencias
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND referencia LIKE px1 AND tiporeferencia = 8;
  IF FOUND THEN hay_aval2 := TRUE; END IF;

  IF hay_aval2 THEN
    SELECT INTO r_datos_a2 * FROM personas
    WHERE idorigen=idorigen_a2 AND idgrupo=idgrupo_a2 AND idsocio=idsocio_a2;
    IF NOT FOUND THEN hay_aval2 := FALSE; END IF;
  END IF;
  IF hay_aval2 THEN
    SELECT INTO r_trabajo_a2 *,
           CASE WHEN fechaingreso IS NOT NULL
                THEN TRIM(TO_CHAR(DATE_MI(fecha_hoy,
                                  DATE(fechaingreso))/30.4,''999.9''))
                ELSE '''' END AS antiguedad
    FROM trabajo
    WHERE idorigen=idorigen_a2 AND idgrupo=idgrupo_a2 AND idsocio=idsocio_a2
    ORDER BY fechaingreso DESC LIMIT 1;

    SELECT INTO r_s_economicos_a2 * FROM socioeconomicos
    WHERE idorigen=idorigen_a2 AND idgrupo=idgrupo_a2 AND idsocio=idsocio_a2;
  END IF;

  -------------------------------------------
  -- LOS AVALES SON SOCIOS ?? (IDGRUPO=10) --
  -------------------------------------------
  x := 0;
  IF hay_aval1 THEN
    SELECT INTO x COUNT(*) FROM personas
    WHERE idorigen=idorigen_a1 AND idgrupo=idgrupo_a1 AND idsocio=idsocio_a1 AND
          idgrupo=10;
    IF NOT FOUND OR x IS NULL THEN x := 0; END IF;
    aval1_es_socio := CASE WHEN x = 0 THEN ''NO'' ELSE ''SI'' END;
  ELSE aval1_es_socio := ''''; END IF;

  x := 0;
  IF hay_aval2 THEN
    SELECT INTO x COUNT(*) FROM personas
    WHERE idorigen=idorigen_a2 AND idgrupo=idgrupo_a2 AND idsocio=idsocio_a2 AND
          idgrupo=10;
    IF NOT FOUND OR x IS NULL THEN x := 0; END IF;
    aval2_es_socio := CASE WHEN x = 0 THEN ''NO'' ELSE ''SI'' END;
  ELSE aval2_es_socio := ''''; END IF;

  -- LOS AVALES VIVEN EN EL MISMO DOMICILIO QUE EL SOCIO ? --
  dom_aval1_mismo_del_solicitante:=''''; dom_aval2_mismo_del_solicitante:='''';
  IF hay_aval1 THEN
    px2 := NULL;
    px1 := ''1|''||TRIM(TO_CHAR(p_idorigenp,''099999''))||''|''||
           TRIM(TO_CHAR(p_idproducto,''09999''))||''|''||
           TRIM(TO_CHAR(p_idauxiliar,''09999999''))||''%'';
    SELECT INTO px2 SAI_TOKEN(6,referencia,''|'')
    FROM referencias
    WHERE idorigen=r_datos.idorigen AND idgrupo=r_datos.idgrupo AND
          idsocio=r_datos.idsocio AND idorigenr=idorigen_a1 AND
          idgrupor=idgrupo_a1 AND idsocior=idsocio_a1 AND referencia LIKE px1
          AND tiporeferencia=8 AND SAI_FINDSTR(referencia, ''|'') = 5;
    IF FOUND AND (UPPER(px2) = ''SI'' OR UPPER(px2) = ''NO'') THEN
      dom_aval1_mismo_del_solicitante := UPPER(px2);
    END IF;
  END IF;

  IF hay_aval2 THEN
    px2 := NULL;
    px1 := ''2|''||TRIM(TO_CHAR(p_idorigenp,''099999''))||''|''||
           TRIM(TO_CHAR(p_idproducto,''09999''))||''|''||
           TRIM(TO_CHAR(p_idauxiliar,''09999999''))||''%'';
    SELECT INTO px2 SAI_TOKEN(6,referencia,''|'')
    FROM referencias
    WHERE idorigen=r_datos.idorigen AND idgrupo=r_datos.idgrupo AND
          idsocio=r_datos.idsocio AND idorigenr=idorigen_a1 AND
          idgrupor=idgrupo_a1 AND idsocior=idsocio_a1 AND referencia LIKE px1
          AND tiporeferencia=8 AND SAI_FINDSTR(referencia, ''|'') = 5;
    IF FOUND AND (UPPER(px2) = ''SI'' OR UPPER(px2) = ''NO'') THEN
      dom_aval2_mismo_del_solicitante := UPPER(px2);
    END IF;
  END IF;

  ---------------------------------
  -- DATOS DEL GARANTE PRENDARIO --
  ---------------------------------
  hay_gp := FALSE;
  px1 := ''GP|''||TRIM(TO_CHAR(p_idorigenp,''099999''))||''|''||
         TRIM(TO_CHAR(p_idproducto,''09999''))||''|''||
         TRIM(TO_CHAR(p_idauxiliar,''09999999''))||''%'';
  SELECT INTO px2 descripcion FROM notas WHERE idnota LIKE px1;
  IF NOT FOUND THEN px2 := NULL; END IF;
  IF px2 IS NOT NULL THEN
    IF sai_findstr(px2, ''|'') = 2 THEN
      idorigen_gp := TO_NUMBER(SAI_TOKEN(1, px2, ''|''), ''999999'');
      idgrupo_gp  := TO_NUMBER(SAI_TOKEN(2, px2, ''|''), ''99'');
      idsocio_gp  := TO_NUMBER(SAI_TOKEN(3, px2, ''|''), ''99999999'');
      IF idorigen_gp > 0 AND idgrupo_gp > 0 AND idsocio_gp > 0 THEN
        hay_gp := TRUE;
      END IF;
    END IF;
  END IF;

  IF hay_gp THEN
    SELECT INTO r_datos_gp * FROM personas
    WHERE idorigen=idorigen_gp AND idgrupo=idgrupo_gp AND idsocio=idsocio_gp;
    IF NOT FOUND THEN hay_gp := FALSE; END IF;
  END IF;

  IF hay_gp THEN
    SELECT INTO r_trabajo_gp *,
           CASE WHEN fechaingreso IS NOT NULL
                THEN TRIM(TO_CHAR(DATE_MI(fecha_hoy,
                                  DATE(fechaingreso))/30.4,''999.9''))
                ELSE '''' END AS antiguedad
    FROM trabajo
    WHERE idorigen=idorigen_gp AND idgrupo=idgrupo_gp AND idsocio=idsocio_gp
    ORDER BY fechaingreso DESC LIMIT 1;
  END IF;

  ------------------------------------------------------------------------------
  -- DATOS QUE SALEN DIRECTAMENTE DE LAS CONSULTAS YA HECHAS A PERSONAS, TRABAJO
  -- Y SOCIOECONOMICOS ---------------------------------------------------------
  ------------------------------------------------------------------------------

  -- ESTADO CIVIL --
  edo_civil := CASE WHEN r_datos.estadocivil = 0 THEN ''NO DEFINIDO''
                    WHEN r_datos.estadocivil = 1 THEN ''Soltero''
                    WHEN r_datos.estadocivil = 2 THEN ''Casado''
                    WHEN r_datos.estadocivil = 3 THEN ''Divorciado''
                    WHEN r_datos.estadocivil = 4 THEN ''Viudo''
                    WHEN r_datos.estadocivil = 5 THEN ''Union Libre''
                    ELSE ''NO DEFINIDO'' END;

  --------------------------------------
  -- DATOS DEL AHORRO DEL SOLICITANTE --
  --------------------------------------
  idorigenp_ah := 0; idproducto_ah := 0; idauxiliar_ah := 0;
  SELECT INTO idorigenp_ah, idproducto_ah, idauxiliar_ah
              idorigenp, idproducto, idauxiliar
  FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND idproducto = 110 AND estatus = 2 LIMIT 1;
  IF NOT FOUND THEN
    idorigenp_ah := 0; idproducto_ah := 0; idauxiliar_ah := 0;
  END IF;

  x := 0; y:= 0;
  x := INT4(TRIM(TO_CHAR(fecha_hoy, ''YYYY'')));
  y := INT4(TRIM(TO_CHAR(fecha_hoy, ''MM'')));

  IF y <= 2 THEN
    px1 := TRIM(TO_CHAR((x-1), ''0999''))||TRIM(TO_CHAR((y+10), ''09''));
  ELSE
    px1 := TRIM(TO_CHAR(x, ''0999''))||TRIM(TO_CHAR((y-2), ''09''));
  END IF;
  montox := 0.0;
  SELECT INTO montox SUM(monto) FROM auxiliares_d
  WHERE idorigenp = idorigenp_ah AND idproducto = idproducto_ah AND
        idauxiliar = idauxiliar_ah AND cargoabono = 1 AND
        periodo = px1::VARCHAR;
  IF NOT FOUND OR montox IS NULL THEN montox := 0.0; END IF;
  ahorro_2o_mes_ant := TRIM(TO_CHAR(montox, ''99999999.99''));

  IF y <= 3 THEN
    px1 := TRIM(TO_CHAR((x-1), ''0999''))||TRIM(TO_CHAR((y+9), ''09''));
  ELSE
    px1 := TRIM(TO_CHAR(x, ''0999''))||TRIM(TO_CHAR((y-3), ''09''));
  END IF;
  montox := 0.0;
  SELECT INTO montox SUM(monto) FROM auxiliares_d
  WHERE idorigenp = idorigenp_ah AND idproducto = idproducto_ah AND
        idauxiliar = idauxiliar_ah AND cargoabono = 1 AND
        periodo = px1::VARCHAR;
  IF NOT FOUND OR montox IS NULL THEN montox := 0.0; END IF;
  ahorro_3er_mes_ant := TRIM(TO_CHAR(montox, ''99999999.99''));

  IF y = 1 THEN px1 := TRIM(TO_CHAR((x-1), ''0999''))||''12'';
  ELSE
    px1 := TRIM(TO_CHAR(x, ''0999''))||TRIM(TO_CHAR((y-1), ''09''));
  END IF;
  montox := 0.0;
  SELECT INTO montox SUM(monto) FROM auxiliares_d
  WHERE idorigenp = idorigenp_ah AND idproducto = idproducto_ah AND
        idauxiliar = idauxiliar_ah AND cargoabono = 1 AND
        periodo = px1::VARCHAR;
  IF NOT FOUND OR montox IS NULL THEN montox := 0.0; END IF;
  ahorro_1er_mes_ant := TRIM(TO_CHAR(montox, ''99999999.99''));

  am_mas_alto_3y_1 := ''0.00''; am_mas_alto_3y_2 := ''0.00'';
  am_mas_alto_3y_3 := ''0.00''; am_mas_alto_3y_4 := ''0.00'';
  am_mas_alto_3y_5 := ''0.00''; am_mas_alto_3y_6 := ''0.00'';
  x := 1;
  FOR r_aux IN
    SELECT ad.periodo_n, ad.deposito
    FROM (SELECT DISTINCT INT4(periodo) AS periodo_n, SUM(monto) AS deposito
          FROM auxiliares_d
          WHERE idorigenp = idorigenp_ah AND idproducto = idproducto_ah AND
                idauxiliar = idauxiliar_ah AND cargoabono = 1 AND
                DATE(fecha) >= DATE(fecha_hoy - ''3 YEAR''::INTERVAL)
          GROUP BY INT4(periodo)) AS ad
    ORDER BY ad.deposito DESC
  LOOP
    IF x = 1 THEN
      am_mas_alto_3y_1 := TRIM(TO_CHAR(r_aux.deposito, ''99999999.99''));
    END IF;

    IF x = 2 THEN
      am_mas_alto_3y_2 := TRIM(TO_CHAR(r_aux.deposito, ''99999999.99''));
    END IF;

    IF x = 3 THEN
      am_mas_alto_3y_3 := TRIM(TO_CHAR(r_aux.deposito, ''99999999.99''));
    END IF;

    IF x = 4 THEN
      am_mas_alto_3y_4 := TRIM(TO_CHAR(r_aux.deposito, ''99999999.99''));
    END IF;

    IF x = 5 THEN
      am_mas_alto_3y_5 := TRIM(TO_CHAR(r_aux.deposito, ''99999999.99''));
    END IF;

    IF x = 6 THEN
      am_mas_alto_3y_6 := TRIM(TO_CHAR(r_aux.deposito, ''99999999.99''));
    END IF;

    x := x + 1;
  END LOOP;

  ------------------------------------------------------------------------------
  -- FORMA DE COMPROBAR INGRESOS Y OTROS DATOS LABORALES DEL SOCIO Y DEL CONYUGE
  ------------------------------------------------------------------------------
  IF hay_trabajo1 THEN
    comp_ingresos_1 :=
        CASE WHEN r_trabajo1.forma_comprobar_ing = 1 THEN ''Recibos de Nomina''
             WHEN r_trabajo1.forma_comprobar_ing = 3 THEN ''Estados de Cuenta''
             WHEN r_trabajo1.forma_comprobar_ing = 4 THEN ''Contrato Arrendamiento''
             WHEN r_trabajo1.forma_comprobar_ing = 11 OR
                  r_trabajo1.forma_comprobar_ing = 16 THEN ''Carta Patron''
             WHEN r_trabajo1.forma_comprobar_ing = 17 THEN ''Carta Contador''
             WHEN r_trabajo1.forma_comprobar_ing = 18 THEN ''Taxista Concesionario''
             WHEN r_trabajo1.forma_comprobar_ing = 19 THEN ''Taxista trabajador''
             ELSE '''' END;

    IF r_trabajo1.forma_comprobar_ing = 3 THEN
      dep_edo_cuenta_1 :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo1.ing_mensual_bruto END),
                        ''99999999.99''));
    ELSE dep_edo_cuenta_1 := ''''; END IF;

    IF r_trabajo1.forma_comprobar_ing = 18 THEN
      ing_mens_bruto_concesionario :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo1.ing_mensual_bruto END),
                        ''99999999.99''));
      num_taxis :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1.num_taxis IS NULL
                             THEN 0 ELSE r_trabajo1.num_taxis END),''9999''));
    ELSE
      ing_mens_bruto_concesionario := ''''; num_taxis := '''';
    END IF;

    IF r_trabajo1.forma_comprobar_ing = 1 THEN
      ing_mens_bruto_nomina :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo1.ing_mensual_bruto END),
                        ''99999999.99''));

      pago_mensual_deudas_por_nomina :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1.deducciones_deudas IS NULL
                             THEN 0.0 ELSE r_trabajo1.deducciones_deudas END),
                        ''99999999.99''));

      impuestos_y_deducciones :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1.deducciones_otros IS NULL
                             THEN 0.0 ELSE r_trabajo1.deducciones_otros END),
                        ''99999999.99''));
    ELSE
      ing_mens_bruto_nomina := ''''; pago_mensual_deudas_por_nomina := '''';
      impuestos_y_deducciones := '''';
    END IF;

    IF r_trabajo1.forma_comprobar_ing = 17 THEN
      ing_mens_bruto_carta_cont :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo1.ing_mensual_bruto END),
                        ''99999999.99''));
    ELSE ing_mens_bruto_carta_cont := ''''; END IF;

    IF r_trabajo1.forma_comprobar_ing=11 OR r_trabajo1.forma_comprobar_ing=16 THEN
      ing_mens_bruto_carta_patron :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo1.ing_mensual_bruto END),
                        ''99999999.99''));
    ELSE ing_mens_bruto_carta_patron := ''''; END IF;

    IF r_trabajo1.forma_comprobar_ing = 19 THEN
      ing_mens_bruto_taxista :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo1.ing_mensual_bruto END),
                        ''99999999.99''));
    ELSE ing_mens_bruto_taxista := ''''; END IF;

    IF r_trabajo1.tipo_empleo = 2 OR r_trabajo1.tipo_empleo = 4 THEN
      num_empleados :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1.num_empleados IS NULL
                             THEN 0 ELSE r_trabajo1.num_empleados END),''9999''));
    ELSE num_empleados := ''''; END IF;

    IF r_trabajo1.tipo_empleo = 1 THEN
      ocupacion := CASE WHEN r_trabajo1.ocupacion IS NULL THEN ''''
                        ELSE r_trabajo1.ocupacion END;
      ocupacion_principal := '''';
    ELSE
      ocupacion := '''';
      ocupacion_principal :=
        CASE WHEN r_trabajo1.tipo_empleo = 0 THEN ''NO DEFINIDO''
             WHEN r_trabajo1.tipo_empleo = 2 THEN ''Independiente''
             WHEN r_trabajo1.tipo_empleo = 3 THEN ''Economia Informal''
             WHEN r_trabajo1.tipo_empleo = 4 THEN ''Negocio Propio''
             WHEN r_trabajo1.tipo_empleo = 5 THEN ''Ama de Casa''
             ELSE ''NO DEFINIDO'' END;
    END IF;
  ELSE
    comp_ingresos_1 := ''''; dep_edo_cuenta_1 := '''';
    ing_mens_bruto_concesionario := ''''; ing_mens_bruto_nomina := '''';
    ing_mens_bruto_carta_cont := ''''; ing_mens_bruto_carta_patron := '''';
    ing_mens_bruto_taxista := ''''; num_empleados := ''''; num_taxis := '''';
    pago_mensual_deudas_por_nomina := ''''; impuestos_y_deducciones := '''';
  END IF;

  IF hay_trabajo2 THEN
    comp_ingresos_2 :=
        CASE WHEN r_trabajo2.forma_comprobar_ing = 1 THEN ''Recibos de Nomina''
             WHEN r_trabajo2.forma_comprobar_ing = 3 THEN ''Estados de Cuenta''
             WHEN r_trabajo2.forma_comprobar_ing = 4 THEN ''Contrato Arrendamiento''
             WHEN r_trabajo2.forma_comprobar_ing = 11 OR
                  r_trabajo2.forma_comprobar_ing = 16 THEN ''Carta Patron''
             WHEN r_trabajo2.forma_comprobar_ing = 17 THEN ''Carta Contador''
             WHEN r_trabajo2.forma_comprobar_ing = 18 THEN ''Taxista Concesionario''
             WHEN r_trabajo2.forma_comprobar_ing = 19 THEN ''Taxista trabajador''
             ELSE '''' END;

    IF r_trabajo2.forma_comprobar_ing = 3 THEN
      dep_edo_cuenta_2 :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo2.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo2.ing_mensual_bruto END),
                        ''99999999.99''));
    ELSE dep_edo_cuenta_2 := ''''; END IF;
  ELSE
    comp_ingresos_2 := ''''; dep_edo_cuenta_2 := '''';
  END IF;

  IF hay_trabajo3 THEN
    comp_ingresos_3 :=
        CASE WHEN r_trabajo3.forma_comprobar_ing = 1 THEN ''Recibos de Nomina''
             WHEN r_trabajo3.forma_comprobar_ing = 3 THEN ''Estados de Cuenta''
             WHEN r_trabajo3.forma_comprobar_ing = 4 THEN ''Contrato Arrendamiento''
             WHEN r_trabajo3.forma_comprobar_ing = 11 OR
                  r_trabajo3.forma_comprobar_ing = 16 THEN ''Carta Patron''
             WHEN r_trabajo3.forma_comprobar_ing = 17 THEN ''Carta Contador''
             WHEN r_trabajo3.forma_comprobar_ing = 18 THEN ''Taxista Concesionario''
             WHEN r_trabajo3.forma_comprobar_ing = 19 THEN ''Taxista trabajador''
             ELSE '''' END;

    IF r_trabajo3.forma_comprobar_ing = 3 THEN
      dep_edo_cuenta_3 :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo3.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo3.ing_mensual_bruto END),
                        ''99999999.99''));
    ELSE dep_edo_cuenta_3 := ''''; END IF;
  ELSE
    comp_ingresos_3 := ''''; dep_edo_cuenta_3 := '''';
  END IF;

  IF hay_trabajo1_c THEN
    comp_ingresos_conyuge_1 :=
        CASE WHEN r_trabajo1_c.forma_comprobar_ing = 1 THEN ''Recibos de Nomina''
             WHEN r_trabajo1_c.forma_comprobar_ing = 3 THEN ''Estados de Cuenta''
             WHEN r_trabajo1_c.forma_comprobar_ing = 4 THEN ''Contrato Arrendamiento''
             WHEN r_trabajo1_c.forma_comprobar_ing = 11 OR
                  r_trabajo1_c.forma_comprobar_ing = 16 THEN ''Carta Patron''
             WHEN r_trabajo1_c.forma_comprobar_ing = 17 THEN ''Carta Contador''
             WHEN r_trabajo1_c.forma_comprobar_ing = 18 THEN ''Taxista Concesionario''
             WHEN r_trabajo1_c.forma_comprobar_ing = 19 THEN ''Taxista trabajador''
             ELSE '''' END;

    IF r_trabajo1_c.forma_comprobar_ing = 3 THEN
      dep_edo_cuenta_conyuge_1 :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1_c.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo1_c.ing_mensual_bruto END),
                        ''99999999.99''));
    ELSE dep_edo_cuenta_conyuge_1 := ''''; END IF;

    IF r_trabajo1_c.forma_comprobar_ing = 18 THEN
      ing_mens_bruto_concesionario_conyuge :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1_c.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo1_c.ing_mensual_bruto END),
                        ''99999999.99''));
      num_taxis_conyuge :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1_c.num_taxis IS NULL
                             THEN 0 ELSE r_trabajo1_c.num_taxis END),''9999''));
    ELSE
      ing_mens_bruto_concesionario_conyuge := ''''; num_taxis_conyuge := '''';
    END IF;

    IF r_trabajo1_c.forma_comprobar_ing = 1 THEN
      ing_mens_bruto_nomina_conyuge :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1_c.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo1_c.ing_mensual_bruto END),
                        ''99999999.99''));

      pago_mensual_deudas_por_nomina_conyuge :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1_c.deducciones_deudas IS NULL
                             THEN 0.0 ELSE r_trabajo1_c.deducciones_deudas END),
                        ''99999999.99''));

      impuestos_y_deducciones_conyuge :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1_c.deducciones_otros IS NULL
                             THEN 0.0 ELSE r_trabajo1_c.deducciones_otros END),
                        ''99999999.99''));
    ELSE
      ing_mens_bruto_nomina_conyuge := '''';
      pago_mensual_deudas_por_nomina_conyuge := '''';
      impuestos_y_deducciones_conyuge := '''';
    END IF;

    IF r_trabajo1_c.forma_comprobar_ing = 17 THEN
      ing_mens_bruto_carta_cont_conyuge :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1_c.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo1_c.ing_mensual_bruto END),
                        ''99999999.99''));
    ELSE ing_mens_bruto_carta_cont_conyuge := ''''; END IF;

    IF r_trabajo1_c.forma_comprobar_ing = 11 OR
       r_trabajo1_c.forma_comprobar_ing = 16 THEN
      ing_mens_bruto_carta_patron_conyuge :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1_c.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo1_c.ing_mensual_bruto END),
                        ''99999999.99''));
    ELSE ing_mens_bruto_carta_patron_conyuge := ''''; END IF;

    IF r_trabajo1_c.forma_comprobar_ing = 19 THEN
      ing_mens_bruto_taxista_conyuge :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo1_c.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo1_c.ing_mensual_bruto END),
                        ''99999999.99''));
    ELSE ing_mens_bruto_taxista_conyuge := ''''; END IF;

    IF r_trabajo1_c.tipo_empleo = 2 OR r_trabajo1_c.tipo_empleo = 4 THEN
      num_empleados_conyuge :=
        TRIM(TO_CHAR((CASE WHEN r_trabajo1_c.num_empleados IS NULL
                           THEN 0 ELSE r_trabajo1_c.num_empleados END),''9999''));
    ELSE num_empleados_conyuge := ''''; END IF;

    IF r_trabajo1_c.tipo_empleo = 1 THEN
      ocupacion_conyuge := CASE WHEN r_trabajo1_c.ocupacion IS NULL THEN ''''
                                ELSE r_trabajo1_c.ocupacion END;
      ocupacion_principal_conyuge := '''';
    ELSE
      ocupacion_conyuge := '''';
      ocupacion_principal_conyuge :=
        CASE WHEN r_trabajo1_c.tipo_empleo = 0 THEN ''NO DEFINIDO''
             WHEN r_trabajo1_c.tipo_empleo = 2 THEN ''Independiente''
             WHEN r_trabajo1_c.tipo_empleo = 3 THEN ''Economia Informal''
             WHEN r_trabajo1_c.tipo_empleo = 4 THEN ''Negocio Propio''
             WHEN r_trabajo1_c.tipo_empleo = 5 THEN ''Ama de Casa''
             ELSE ''NO DEFINIDO'' END;
    END IF;

  ELSE
    comp_ingresos_conyuge_1 := ''''; dep_edo_cuenta_conyuge_1 := '''';
    ing_mens_bruto_concesionario_conyuge := '''';
    ing_mens_bruto_nomina_conyuge := '''';
    ing_mens_bruto_carta_cont_conyuge := '''';
    ing_mens_bruto_carta_patron_conyuge := '''';
    ing_mens_bruto_taxista_conyuge := ''''; num_empleados_conyuge := '''';
    num_taxis_conyuge := ''''; pago_mensual_deudas_por_nomina_conyuge := '''';
    impuestos_y_deducciones_conyuge := '''';
  END IF;

  IF hay_trabajo2_c THEN
    comp_ingresos_conyuge_2 :=
        CASE WHEN r_trabajo2_c.forma_comprobar_ing = 1 THEN ''Recibos de Nomina''
             WHEN r_trabajo2_c.forma_comprobar_ing = 3 THEN ''Estados de Cuenta''
             WHEN r_trabajo2_c.forma_comprobar_ing = 4 THEN ''Contrato Arrendamiento''
             WHEN r_trabajo2_c.forma_comprobar_ing = 11 OR
                  r_trabajo2_c.forma_comprobar_ing = 16 THEN ''Carta Patron''
             WHEN r_trabajo2_c.forma_comprobar_ing = 17 THEN ''Carta Contador''
             WHEN r_trabajo2_c.forma_comprobar_ing = 18 THEN ''Taxista Concesionario''
             WHEN r_trabajo2_c.forma_comprobar_ing = 19 THEN ''Taxista trabajador''
             ELSE '''' END;

    IF r_trabajo2_c.forma_comprobar_ing = 3 THEN
      dep_edo_cuenta_conyuge_2 :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo2_c.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo2_c.ing_mensual_bruto END),
                        ''99999999.99''));
    ELSE dep_edo_cuenta_conyuge_2 := ''''; END IF;
  ELSE
    comp_ingresos_conyuge_2 := ''''; dep_edo_cuenta_conyuge_2 := '''';
  END IF;

  IF hay_trabajo3 THEN
    comp_ingresos_conyuge_3 :=
        CASE WHEN r_trabajo3_c.forma_comprobar_ing = 1 THEN ''Recibos de Nomina''
             WHEN r_trabajo3_c.forma_comprobar_ing = 3 THEN ''Estados de Cuenta''
             WHEN r_trabajo3_c.forma_comprobar_ing = 4 THEN ''Contrato Arrendamiento''
             WHEN r_trabajo3_c.forma_comprobar_ing = 11 OR
                  r_trabajo3_c.forma_comprobar_ing = 16 THEN ''Carta Patron''
             WHEN r_trabajo3_c.forma_comprobar_ing = 17 THEN ''Carta Contador''
             WHEN r_trabajo3_c.forma_comprobar_ing = 18 THEN ''Taxista Concesionario''
             WHEN r_trabajo3_c.forma_comprobar_ing = 19 THEN ''Taxista trabajador''
             ELSE '''' END;

    IF r_trabajo3_c.forma_comprobar_ing = 3 THEN
      dep_edo_cuenta_conyuge_3 :=
          TRIM(TO_CHAR((CASE WHEN r_trabajo3_c.ing_mensual_bruto IS NULL
                             THEN 0.0 ELSE r_trabajo3_c.ing_mensual_bruto END),
                        ''99999999.99''));
    ELSE dep_edo_cuenta_conyuge_3 := ''''; END IF;
  ELSE
    comp_ingresos_conyuge_3 := ''''; dep_edo_cuenta_conyuge_3 := '''';
  END IF;

  escolaridad :=
      CASE WHEN r_datos.grado_estudios = 0 THEN ''''
           WHEN r_datos.grado_estudios = 1 THEN ''Ninguno''
           WHEN r_datos.grado_estudios = 2 THEN ''Primaria''
           WHEN r_datos.grado_estudios = 3 THEN ''Secundaria''
           WHEN r_datos.grado_estudios = 4 THEN ''Bachillerato''
           WHEN r_datos.grado_estudios = 5 THEN ''Tecnica''
           WHEN r_datos.grado_estudios = 6 THEN ''Licenciatura''
           WHEN r_datos.grado_estudios = 7 THEN ''Posgrado''
           ELSE '''' END;

  fecha_ingreso := TRIM(TO_CHAR(r_datos.fechaingreso, ''DD/MM/YYYY''));
  fecha_nacimiento := TRIM(TO_CHAR(r_datos.fechanacimiento, ''DD/MM/YYYY''));
  fecha_domicilio := CASE WHEN r_s_economicos.fechahabitacion IS NULL THEN ''''
                          ELSE TRIM(TO_CHAR(r_s_economicos.fechahabitacion,
                               ''DD/MM/YYYY'')) END;

  IF hay_aval1 THEN
    fecha_nac_aval1 := TRIM(TO_CHAR(r_datos_a1.fechanacimiento, ''DD/MM/YYYY''));
  ELSE
    fecha_nac_aval1 := '''';
  END IF;

  IF hay_aval2 THEN
    fecha_nac_aval2 := TRIM(TO_CHAR(r_datos_a2.fechanacimiento, ''DD/MM/YYYY''));
  ELSE
    fecha_nac_aval2 := '''';
  END IF;

  IF hay_gp THEN
    fecha_nac_otorgante_gar_prend :=
        TRIM(TO_CHAR(r_datos_gp.fechanacimiento, ''DD/MM/YYYY''));
  ELSE
    fecha_nac_otorgante_gar_prend := '''';
  END IF;

  gasto_mensual_familiar := TRIM(TO_CHAR(
        ((CASE WHEN r_s_economicos.gastosordinarios IS NULL
               THEN 0.0 ELSE r_s_economicos.gastosordinarios END) +
         (CASE WHEN r_s_economicos.gastosextraordinarios IS NULL
               THEN 0.0 ELSE r_s_economicos.gastosextraordinarios END)),
        ''99999999.99''));
  sexo := CASE WHEN r_datos.sexo = 0 THEN ''Sin Definir''
               WHEN r_datos.sexo = 1 THEN ''Masculino''
               ELSE ''Femenino'' END;

  IF hay_aval1 THEN
    ing_mens_bruto_aval1 :=
        TRIM(TO_CHAR((CASE WHEN r_trabajo_a1.ing_mensual_bruto IS NULL
                           THEN 0.0 ELSE r_trabajo_a1.ing_mensual_bruto END),
                      ''99999999.99''));
  ELSE
    ing_mens_bruto_aval1 := '''';
  END IF;

  IF hay_aval2 THEN
    ing_mens_bruto_aval2 :=
        TRIM(TO_CHAR((CASE WHEN r_trabajo_a2.ing_mensual_bruto IS NULL
                           THEN 0.0 ELSE r_trabajo_a2.ing_mensual_bruto END),
                     ''99999999.99''));
  ELSE
    ing_mens_bruto_aval2 := '''';
  END IF;

  meses_en_empleo := r_trabajo1.antiguedad;
  IF hay_conyuge THEN
    meses_en_empleo_conyuge := r_trabajo1_c.antiguedad;
  ELSE
    meses_en_empleo_conyuge := '''';
  END IF;

  -------------------------------------------------------------------
  -- EN ESTE CASO CONSIDERE EL MONTO SOLICITADO EN EL PRESTAMO QUE --
  -- SE ESTA EVALUANDO, PORQUE SE SUPONE QUE NO ESTA AUTORIZADO -----
  -------------------------------------------------------------------
  monto_credito := TRIM(TO_CHAR(r_datos.montosolicitado,''99999999.99''));

  ------------------------------------------------------------------------------
  -- POR LA HOJA DE LAS DESCRIPCIONES, EN ESTOS CAMPOS SE PONEN ESTOS VALORES --
  ------------------------------------------------------------------------------
  monto_contrato_arrendamiento :=
      TRIM(TO_CHAR((CASE WHEN r_trabajo1.ing_mensual_bruto IS NULL
                         THEN 0.0 ELSE r_trabajo1.ing_mensual_bruto END),
                    ''99999999.99''));
  IF hay_conyuge THEN
    monto_contrato_arrendamiento_conyuge :=
        TRIM(TO_CHAR((CASE WHEN r_trabajo1_c.ing_mensual_bruto IS NULL
                           THEN 0.0 ELSE r_trabajo1_c.ing_mensual_bruto END),
                      ''99999999.99''));
  ELSE
    monto_contrato_arrendamiento_conyuge := '''';
  END IF;

  ---------------------------------------------
  -- MONTOS DE DIFERENTES TIPOS DE PRESTAMOS --
  ---------------------------------------------
  montox := 0.0;
  SELECT INTO montox SUM(saldo) FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND estatus = 2 AND
        SUBSTR(TRIM(TO_CHAR(idproducto,''099999'')),1,4) = ''0328'';
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  monto_riesgo_autocredito := TRIM(TO_CHAR(montox, ''9999999999.99''));

  montox := 0.0;
  SELECT INTO montox SUM(saldo) FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND estatus = 2 AND
        SUBSTR(TRIM(TO_CHAR(idproducto,''099999'')),1,4) = ''0330'';
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  monto_riesgo_credi10 := TRIM(TO_CHAR(montox, ''9999999999.99''));

--------------------------------------------------------------------------------
-- PENDIENTE : NO DICE QUE PRODUCTOS SE DEBEN CONSIDERAR -----------------------
--------------------------------------------------------------------------------
  montox := 0.0;
  SELECT INTO montox SUM(saldo) FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND estatus = 2 AND
        SUBSTR(TRIM(TO_CHAR(idproducto,''099999'')),1,4) = ''?????'';
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  monto_riesgo_credifise := TRIM(TO_CHAR(montox, ''9999999999.99''));
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

  montox := 0.0;
  SELECT INTO montox SUM(saldo) FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND estatus = 2 AND
        SUBSTR(TRIM(TO_CHAR(idproducto,''099999'')),1,4)
        IN (''0331'',''0332'',''0339'');
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  monto_riesgo_elite := TRIM(TO_CHAR(montox, ''9999999999.99''));

  montox := 0.0;
  SELECT INTO montox SUM(saldo) FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND estatus = 2 AND
        SUBSTR(TRIM(TO_CHAR(idproducto,''099999'')),1,4) = ''0334'';
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  monto_riesgo_hipotecario := TRIM(TO_CHAR(montox, ''9999999999.99''));

  montox := 0.0;
  SELECT INTO montox SUM(saldo) FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND estatus = 2 AND
        SUBSTR(TRIM(TO_CHAR(idproducto,''099999'')),1,4) = ''0329'';
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  monto_riesgo_nom_empresarial := TRIM(TO_CHAR(montox, ''9999999999.99''));

  montox := 0.0;
  SELECT INTO montox SUM(saldo) FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND estatus = 2 AND
        SUBSTR(TRIM(TO_CHAR(idproducto,''099999'')),1,4) = ''0301'';
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  monto_riesgo_ordinario := TRIM(TO_CHAR(montox, ''9999999999.99''));

  montox := 0.0;
  SELECT INTO montox SUM(saldo) FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND estatus = 2 AND idproducto = 30402;
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  monto_riesgo_confianza := TRIM(TO_CHAR(montox, ''9999999999.99''));

  montox := 0.0;
  SELECT INTO montox SUM(saldo) FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND estatus = 2 AND idproducto = 30246;
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  monto_riesgo_prest_extraordinario := TRIM(TO_CHAR(montox, ''9999999999.99''));

  montox := 0.0;
  SELECT INTO montox SUM(saldo) FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND estatus = 2 AND idproducto = 30302;
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  monto_riesgo_prest_gerencial := TRIM(TO_CHAR(montox, ''9999999999.99''));

  montox := 0.0;
  SELECT INTO montox SUM(saldo) FROM auxiliares
  WHERE  idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND tipoprestamo IN (2,4) AND estatus = 2;
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  monto_riesgo_prest_reestruct := TRIM(TO_CHAR(montox, ''9999999999.99''));

  montox := 0.0;
  SELECT INTO montox SUM(saldo) FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND estatus = 2 AND tipoprestamo IN (1,3);
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  monto_riesgo_prest_renovado := TRIM(TO_CHAR(montox, ''9999999999.99''));

  montox := 0.0;
  SELECT INTO montox SUM(saldo) FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND estatus = 2 AND
        SUBSTR(TRIM(TO_CHAR(idproducto,''099999'')),1,4) = ''0312'';
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  monto_riesgo_prest_simple := TRIM(TO_CHAR(montox, ''9999999999.99''));

  montox := 0.0;
  SELECT INTO montox SUM(saldo) FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND estatus = 2 AND
        SUBSTR(TRIM(TO_CHAR(idproducto,''099999'')),1,4) = ''0307'';
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  monto_riesgo_prest_inversion := TRIM(TO_CHAR(montox, ''9999999999.99''));

  -------------------------------------------------------------
  -- OJO !!! MISMO VALOR QUE EL CAMPO ANTERIOR monto_credito --
  -------------------------------------------------------------
  monto_solicitado := TRIM(TO_CHAR(r_datos.montosolicitado,''99999999.99''));

  ------------------------------------------------------------------------------
  -- VALORES DE MOROSIDAD ------------------------------------------------------
  ------------------------------------------------------------------------------

  -- MOROSIDAD MAXIMA ACTUAL DEL SOLICITANTE --
  montox := 0;
  SELECT INTO montox MAX(abonosvencidos) FROM carteravencida
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio;
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  morosidad_actual := TRIM(TO_CHAR(ROUND(montox,0), ''99999''));

  -- PARA LA MOROSIDAD DE LOS AVALADOS, SE BUSCARA SOLO --
  -- LOS CREDITOS VIVOS, EN balancecred Y auxiliares_d ---
  x := 0; montox := 0;
  SELECT INTO montox MAX(abonosvencidos)
  FROM balancecred
  WHERE (idorigen,idgrupo,idsocio) IN
        (SELECT idorigen,idgrupo,idsocio FROM referencias
         WHERE idorigenr = r_datos.idorigen AND idgrupor = r_datos.idgrupo AND
               idsocior = r_datos.idsocio AND tiporeferencia = 8)
        AND fechacierre >= DATE(fecha_hoy - ''12 MONTH''::INTERVAL);
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  x := INT4(ROUND(montox, 0));

  y := 0; montox := 0;
  SELECT INTO montox MAX(diasvencidos)
  FROM auxiliares_d ad INNER JOIN auxiliares a
       USING (idorigenp,idproducto,idauxiliar)
  WHERE DATE(ad.fecha) >= DATE(fecha_hoy - ''12 MONTH''::INTERVAL) AND
        (a.idorigen,a.idgrupo,a.idsocio) IN
        (SELECT idorigen,idgrupo,idsocio FROM referencias
         WHERE idorigenr=r_datos.idorigen AND idgrupor=r_datos.idgrupo AND
               idsocior=r_datos.idsocio AND tiporeferencia=8);
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  y := INT4(ROUND(montox/30.4, 0));
  IF y > x THEN x := y; END IF;

  morosidad_avalados_12m := TRIM(TO_CHAR(x, ''99999''));

  -- PARA LA MOROSIDAD DEL SOCIO COMO CONYUGE, TAMBIEN SOLO SE --
  -- BUSCARA EN LOS CREDITOS VIVOS (balancecred, auxiliares_d) --

  x := 0; montox := 0;
  SELECT INTO montox MAX(abonosvencidos)
  FROM balancecred
  WHERE (idorigenp,idproducto,idauxiliar) IN
        (SELECT a.idorigenp,a.idproducto,a.idauxiliar
         FROM auxiliares a INNER JOIN productos p USING (idproducto)
         WHERE p.tipoproducto=2 AND (a.idorigen,a.idgrupo,a.idsocio) IN
               (SELECT idorigen,idgrupo,idsocio FROM referencias
                WHERE idorigenr=r_datos.idorigen AND idgrupor=r_datos.idgrupo
                      AND idsocior=r_datos.idsocio AND tiporeferencia = 1))
        AND fechacierre >= DATE(fecha_hoy - ''12 MONTH''::INTERVAL);
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  x := INT4(ROUND(montox, 0));

  y := 0; montox := 0;
  SELECT INTO montox MAX(diasvencidos)
  FROM auxiliares_d
  WHERE DATE(fecha) >= DATE(fecha_hoy - ''12 MONTH''::INTERVAL) AND
        (idorigenp,idproducto,idauxiliar) IN
        (SELECT a.idorigenp,a.idproducto,a.idauxiliar
         FROM auxiliares a INNER JOIN productos p USING (idproducto)
         WHERE p.tipoproducto=2 AND (a.idorigen,a.idgrupo,a.idsocio) IN
               (SELECT idorigen,idgrupo,idsocio FROM referencias
                WHERE idorigenr=r_datos.idorigen AND idgrupor=r_datos.idgrupo
                      AND idsocior=r_datos.idsocio AND tiporeferencia = 1));
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  y := INT4(ROUND(montox/30.4, 0));
  IF y > x THEN x := y; END IF;

  morosidad_solicitante_es_conyuge_12m := TRIM(TO_CHAR(x, ''99999''));

  -- MOROSIDAD MAXIMA HISTORICA DEL SOCIO (hay que buscar en el historial) --
  x := 0; montox := 0;
  SELECT INTO montox MAX(abonosvencidos) FROM balancecred
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio;
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  x := INT4(ROUND(montox, 0));

  y := 0; montox := 0;
  SELECT INTO montox MAX(abonosvencidos) FROM balancecred_h
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio;
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  y := INT4(ROUND(montox, 0));
  IF y > x THEN x := y; END IF;

  y := 0; montox := 0;
  SELECT INTO montox MAX(diasvencidos)
  FROM auxiliares_d ad INNER JOIN auxiliares a
       USING (idorigenp,idproducto,idauxiliar)
  WHERE a.idorigen=r_datos.idorigen AND a.idgrupo=r_datos.idgrupo AND
        a.idsocio=r_datos.idsocio AND ad.idorigenp>0 AND ad.idproducto>0 AND
        ad.idauxiliar>0;
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  y := INT4(ROUND(montox/30.4, 0));
  IF y > x THEN x := y; END IF;

  y := 0; montox := 0;
  SELECT INTO montox MAX(diasvencidos)
  FROM auxiliares_d_h ad INNER JOIN auxiliares_h a
       USING (idorigenp,idproducto,idauxiliar)
  WHERE a.idorigen=r_datos.idorigen AND a.idgrupo=r_datos.idgrupo AND
        a.idsocio=r_datos.idsocio AND ad.idorigenp>0 AND ad.idproducto>0 AND
        ad.idauxiliar>0;
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  y := INT4(ROUND(montox/30.4, 0));
  IF y > x THEN x := y; END IF;

  morosidad_solicitante := TRIM(TO_CHAR(x, ''99999''));

  -- MOROSIDAD MAXIMA DEL SOCIO EN 12 Y 24 MESES --

  x := 0; montox := 0;
  SELECT INTO montox MAX(abonosvencidos) FROM balancecred
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND
        fechacierre >= DATE(fecha_hoy - ''12 MONTH''::INTERVAL);
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  x := INT4(ROUND(montox, 0));

  y := 0; montox := 0;
  SELECT INTO montox MAX(abonosvencidos) FROM balancecred_h
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND
        fechacierre >= DATE(fecha_hoy - ''12 MONTH''::INTERVAL);
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  y := INT4(ROUND(montox, 0));
  IF y > x THEN x := y; END IF;

  y := 0; montox := 0;
  SELECT INTO montox MAX(diasvencidos)
  FROM auxiliares_d ad INNER JOIN auxiliares a
       USING (idorigenp,idproducto,idauxiliar)
  WHERE a.idorigen=r_datos.idorigen AND a.idgrupo=r_datos.idgrupo AND
        a.idsocio=r_datos.idsocio AND ad.idorigenp>0 AND ad.idproducto>0 AND
        ad.idauxiliar>0 AND DATE(fecha)>=DATE(fecha_hoy - ''12 MONTH''::INTERVAL);
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  y := INT4(ROUND(montox/30.4, 0));
  IF y > x THEN x := y; END IF;

  y := 0; montox := 0;
  SELECT INTO montox MAX(diasvencidos)
  FROM auxiliares_d_h ad INNER JOIN auxiliares_h a
       USING (idorigenp,idproducto,idauxiliar)
  WHERE a.idorigen=r_datos.idorigen AND a.idgrupo=r_datos.idgrupo AND
        a.idsocio=r_datos.idsocio AND ad.idorigenp>0 AND ad.idproducto>0 AND
        ad.idauxiliar>0 AND DATE(fecha)>=DATE(fecha_hoy - ''12 MONTH''::INTERVAL);
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  y := INT4(ROUND(montox/30.4, 0));
  IF y > x THEN x := y; END IF;

  morosidad_solicitante_ultimos_12m := TRIM(TO_CHAR(x, ''99999''));

  x := 0; montox := 0;
  SELECT INTO montox MAX(abonosvencidos) FROM balancecred
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio
        AND fechacierre >= DATE(fecha_hoy - ''24 MONTH''::INTERVAL);
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  x := INT4(ROUND(montox, 0));

  y := 0; montox := 0;
  SELECT INTO montox MAX(abonosvencidos) FROM balancecred_h
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio
        AND fechacierre >= DATE(fecha_hoy - ''24 MONTH''::INTERVAL);
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  y := INT4(ROUND(montox, 0));
  IF y > x THEN x := y; END IF;

  y := 0; montox := 0;
  SELECT INTO montox MAX(diasvencidos)
  FROM auxiliares_d ad INNER JOIN auxiliares a
       USING (idorigenp,idproducto,idauxiliar)
  WHERE a.idorigen=r_datos.idorigen AND a.idgrupo=r_datos.idgrupo AND
        a.idsocio=r_datos.idsocio AND ad.idorigenp>0 AND ad.idproducto>0 AND
        ad.idauxiliar>0 AND DATE(fecha)>=DATE(fecha_hoy - ''24 MONTH''::INTERVAL);
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  y := INT4(ROUND(montox/30.4, 0));
  IF y > x THEN x := y; END IF;

  y := 0; montox := 0;
  SELECT INTO montox MAX(diasvencidos)
  FROM auxiliares_d_h ad INNER JOIN auxiliares_h a
       USING (idorigenp,idproducto,idauxiliar)
  WHERE a.idorigen=r_datos.idorigen AND a.idgrupo=r_datos.idgrupo AND
        a.idsocio=r_datos.idsocio AND ad.idorigenp>0 AND ad.idproducto>0 AND
        ad.idauxiliar>0 AND DATE(fecha)>=DATE(fecha_hoy - ''24 MONTH''::INTERVAL);
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  y := INT4(ROUND(montox/30.4, 0));
  IF y > x THEN x := y; END IF;

  morosidad_solicitante_ultimos_24m := TRIM(TO_CHAR(x, ''99999''));

  -- MOROSIDAD MAXIMA VIGENTE DE LOS AVALES : LO SACO --
  -- DE carteravencida QUE SON LOS CREDITOS VIGENTES ---
  montox := 0.0;
  IF hay_aval1 THEN
    SELECT INTO montox MAX(abonosvencidos) FROM carteravencida
    WHERE idorigen=idorigen_a1 AND idgrupo=idgrupo_a1 AND idsocio=idsocio_a1;
    IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  END IF;
  morosidad_vig_aval1 := TRIM(TO_CHAR(ROUND(montox,0), ''99999''));

  montox := 0.0;
  IF hay_aval2 THEN
    SELECT INTO montox MAX(abonosvencidos) FROM carteravencida
    WHERE idorigen=idorigen_a2 AND idgrupo=idgrupo_a2 AND idsocio=idsocio_a2;
    IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  END IF;
  morosidad_vig_aval2 := TRIM(TO_CHAR(ROUND(montox,0), ''99999''));

  -- MOROSIDAD DE LOS AVALES COMO CONYUGES --

  x := 0; montox := 0.0;
  IF hay_aval1 THEN
    SELECT INTO montox MAX(abonosvencidos)
    FROM balancecred
    WHERE (idorigenp,idproducto,idauxiliar) IN
          (SELECT a.idorigenp,a.idproducto,a.idauxiliar
           FROM auxiliares a INNER JOIN productos p USING (idproducto)
           WHERE p.tipoproducto=2 AND (a.idorigen,a.idgrupo,a.idsocio) IN
                 (SELECT idorigen,idgrupo,idsocio FROM referencias
                  WHERE idorigenr=idorigen_a1 AND idgrupor=idgrupo_a1 AND
                        idsocior=idsocio_a1 AND tiporeferencia = 1))
          AND fechacierre >= DATE(fecha_hoy - ''12 MONTH''::INTERVAL);
    IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
    x := INT4(ROUND(montox, 0));

    y := 0; montox := 0;
    SELECT INTO montox MAX(diasvencidos)
    FROM auxiliares_d
    WHERE DATE(fecha) >= DATE(fecha_hoy - ''12 MONTH''::INTERVAL) AND
          (idorigenp,idproducto,idauxiliar) IN
          (SELECT a.idorigenp,a.idproducto,a.idauxiliar
           FROM auxiliares a INNER JOIN productos p USING (idproducto)
           WHERE p.tipoproducto=2 AND (a.idorigen,a.idgrupo,a.idsocio) IN
                 (SELECT idorigen,idgrupo,idsocio FROM referencias
                  WHERE idorigenr=idorigen_a1 AND idgrupor=idgrupo_a1 AND
                        idsocior=idsocio_a1 AND tiporeferencia = 1));
    IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
    y := INT4(ROUND(montox/30.4, 0));
    IF y > x THEN x := y; END IF;
  END IF;
  morosidad_vig_aval1_es_conyuge := TRIM(TO_CHAR(x, ''99999''));

  x := 0; montox := 0.0;
  IF hay_aval2 THEN
    SELECT INTO montox MAX(abonosvencidos)
    FROM balancecred
    WHERE (idorigenp,idproducto,idauxiliar) IN
          (SELECT a.idorigenp,a.idproducto,a.idauxiliar
           FROM auxiliares a INNER JOIN productos p USING (idproducto)
           WHERE p.tipoproducto=2 AND (a.idorigen,a.idgrupo,a.idsocio) IN
                 (SELECT idorigen,idgrupo,idsocio FROM referencias
                  WHERE idorigenr=idorigen_a2 AND idgrupor=idgrupo_a2 AND
                        idsocior=idsocio_a2 AND tiporeferencia = 1))
          AND fechacierre >= DATE(fecha_hoy - ''12 MONTH''::INTERVAL);
    IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
    x := INT4(ROUND(montox, 0));

    y := 0; montox := 0;
    SELECT INTO montox MAX(diasvencidos)
    FROM auxiliares_d
    WHERE DATE(fecha) >= DATE(fecha_hoy - ''12 MONTH''::INTERVAL) AND
          (idorigenp,idproducto,idauxiliar) IN
          (SELECT a.idorigenp,a.idproducto,a.idauxiliar
           FROM auxiliares a INNER JOIN productos p USING (idproducto)
           WHERE p.tipoproducto=2 AND (a.idorigen,a.idgrupo,a.idsocio) IN
                 (SELECT idorigen,idgrupo,idsocio FROM referencias
                  WHERE idorigenr=idorigen_a2 AND idgrupor=idgrupo_a2 AND
                        idsocior=idsocio_a2 AND tiporeferencia = 1));
    IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
    y := INT4(ROUND(montox/30.4, 0));
    IF y > x THEN x := y; END IF;
  END IF;
  morosidad_vig_aval2_es_conyuge := TRIM(TO_CHAR(x, ''99999''));

  -- MOROSIDAD DE LOS AVALADOS POR LOS AVALES --
  x := 0; montox := 0.0;
  IF hay_aval1 THEN
    SELECT INTO montox MAX(abonosvencidos)
    FROM balancecred
    WHERE (idorigen,idgrupo,idsocio) IN
          (SELECT idorigen,idgrupo,idsocio FROM referencias
           WHERE idorigenr = idorigen_a1 AND idgrupor = idgrupo_a1 AND
                 idsocior = idsocio_a1 AND tiporeferencia = 8)
          AND fechacierre >= DATE(fecha_hoy - ''12 MONTH''::INTERVAL);
    IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
    x := INT4(ROUND(montox, 0));

    y := 0; montox := 0;
    SELECT INTO montox MAX(diasvencidos)
    FROM auxiliares_d ad INNER JOIN auxiliares a
         USING (idorigenp,idproducto,idauxiliar)
    WHERE DATE(ad.fecha) >= DATE(fecha_hoy - ''12 MONTH''::INTERVAL) AND
          (a.idorigen,a.idgrupo,a.idsocio) IN
          (SELECT idorigen,idgrupo,idsocio FROM referencias
           WHERE idorigenr = idorigen_a1 AND idgrupor = idgrupo_a1 AND
                 idsocior = idsocio_a1 AND tiporeferencia = 8);
    IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
    y := INT4(ROUND(montox/30.4, 0));
    IF y > x THEN x := y; END IF;
  END IF;
  morosidad_vig_avalados_aval1 := TRIM(TO_CHAR(x, ''99999''));

  x := 0; montox := 0.0;
  IF hay_aval2 THEN
    SELECT INTO montox MAX(abonosvencidos)
    FROM balancecred
    WHERE (idorigen,idgrupo,idsocio) IN
          (SELECT idorigen,idgrupo,idsocio FROM referencias
           WHERE idorigenr = idorigen_a2 AND idgrupor = idgrupo_a2 AND
                 idsocior = idsocio_a2 AND tiporeferencia = 8)
          AND fechacierre >= DATE(fecha_hoy - ''12 MONTH''::INTERVAL);
    IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
    x := INT4(ROUND(montox, 0));

    y := 0; montox := 0;
    SELECT INTO montox MAX(diasvencidos)
    FROM auxiliares_d ad INNER JOIN auxiliares a
         USING (idorigenp,idproducto,idauxiliar)
    WHERE DATE(ad.fecha) >= DATE(fecha_hoy - ''12 MONTH''::INTERVAL) AND
          (a.idorigen,a.idgrupo,a.idsocio) IN
          (SELECT idorigen,idgrupo,idsocio FROM referencias
           WHERE idorigenr = idorigen_a2 AND idgrupor = idgrupo_a2 AND
                 idsocior = idsocio_a2 AND tiporeferencia = 8);
    IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
    y := INT4(ROUND(montox/30.4, 0));
    IF y > x THEN x := y; END IF;
  END IF;
  morosidad_vig_avalados_aval2 := TRIM(TO_CHAR(x, ''99999''));

  -- NUMERO DE AVALES ---
  px1 := ''%''||TRIM(TO_CHAR(p_idorigenp,''099999''))||''|''||
         TRIM(TO_CHAR(p_idproducto,''09999''))||''|''||
         TRIM(TO_CHAR(p_idauxiliar,''09999999''))||''%'';
  x := 0;
  SELECT INTO x COUNT(*) FROM referencias
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND referencia LIKE px1 AND tiporeferencia = 8;
  IF NOT FOUND OR x IS NULL THEN x := 0; END IF;
  num_avales := TRIM(TO_CHAR(x, ''99999''));

  -- NUMERO DE CREDITOS VIVOS AVALADOS POR EL SOLICITANTE ---

  SELECT INTO x COUNT(*) FROM auxiliares
  WHERE estatus = 2 AND saldo > 0 AND (idorigenp,idproducto,idauxiliar) IN
        (SELECT DISTINCT
           TO_NUMBER(TRIM(SAI_TOKEN(2,referencia,''|'')),''999999'') AS idorigenp,
           TO_NUMBER(TRIM(SAI_TOKEN(3,referencia,''|'')),''99999'') AS idproducto,
           TO_NUMBER(TRIM(SAI_TOKEN(4,referencia,''|'')),''99999999'') AS idauxiliar
         FROM referencias
         WHERE idorigenr = r_datos.idorigen AND idgrupor = r_datos.idgrupo AND
               idsocior = r_datos.idsocio AND tiporeferencia = 8);
  IF NOT FOUND OR x IS NULL THEN x := 0; END IF;
  num_creditos_vivos_avalados := TRIM(TO_CHAR(x, ''99999''));

  -- NUMERO DE CREDITOS VIVOS AVALADOS POR EL CONYUGE --
  x := 0;
  IF hay_conyuge THEN
    SELECT INTO x COUNT(*) FROM auxiliares
    WHERE estatus = 2 AND saldo > 0 AND (idorigenp,idproducto,idauxiliar) IN
          (SELECT DISTINCT
             TO_NUMBER(TRIM(SAI_TOKEN(2,referencia,''|'')),''999999'') AS idorigenp,
             TO_NUMBER(TRIM(SAI_TOKEN(3,referencia,''|'')),''99999'') AS idproducto,
             TO_NUMBER(TRIM(SAI_TOKEN(4,referencia,''|'')),''99999999'') AS idauxiliar
           FROM referencias
           WHERE idorigenr = idorigen_c AND idgrupor = idgrupo_c AND
                 idsocior = idsocio_c AND tiporeferencia = 8);
    IF NOT FOUND OR x IS NULL THEN x := 0; END IF;
  END IF;
  num_creditos_vivos_avalados_conyuge := TRIM(TO_CHAR(x, ''99999''));

  ------------------
  -- DEPENDIENTES --
  ------------------
  num_dependientes := TRIM(TO_CHAR(
                           (CASE WHEN r_s_economicos.dependientes IS NULL
                                 THEN 0 ELSE r_s_economicos.dependientes END),
                           ''9999''));
  num_despendientes_esc :=
      TRIM(TO_CHAR((CASE WHEN r_s_economicos.dependientes_menores IS NULL
                         THEN 0 ELSE r_s_economicos.dependientes_menores END),
                   ''9999''));

  montoz := 0.0;
  IF r_datos.tipoamortizacion = 2 OR r_datos.tipoamortizacion = 4 OR
     r_datos.tipoamortizacion = 5 THEN
    tasa_iva := 0.0;
    tasa_iva := sai_iva_segun_sucursal(p_idorigenp, p_idproducto, 0);
    IF tasa_iva = 0 THEN tasa_iva := 16.0; END IF;

    IF r_datos.periodoabonos = 0 THEN dias := 30.4;
    ELSE dias = r_datos.periodoabonos;
    END IF;

    montox := 0.0; montoy := 0.0;
    montox := (r_datos.tasaio/100.0)*(1 + (tasa_iva/100.0)); -- Tasa IO + IVA
    montoy := (montox/30.0)*dias; -- Tasa IO + IVA CADA X DIAS
    montox := 0.0;
    montox = (r_datos.montoprestado*montoy)/(1-(1/POW((1+montoy)::NUMERIC,r_datos.plazo::NUMERIC)));
    montoz := ROUND(montox, 2);
  ELSE
    montoz := ROUND((r_datos.montoprestado/r_datos.plazo), 2);
  END IF;
  pago_mensual := TRIM(TO_CHAR(montoz,''99999999.99''));

  plazo_meses := TRIM(TO_CHAR(r_datos.plazo,''9999''));

  -------------------------------------------------
  -- PAGOS MAXIMOS MENSUALES DURANTE VARIOS ANIOS --
  -------------------------------------------------
  pago_mens_max_3a_1 := ''0.00''; pago_mens_max_3a_2 := ''0.00'';
  pago_mens_max_3a_3 := ''0.00''; pago_mens_max_3a_4 := ''0.00'';
  pago_mens_max_3a_5 := ''0.00''; pago_mens_max_3a_6 := ''0.00'';

  x := 1;
  FOR r_pagos IN
    SELECT (monto + montoio + montoim + montoiva + montoivaim) AS pago
    FROM v_auxiliares_d ad INNER JOIN v_auxiliares a
         USING (idorigenp,idproducto,idauxiliar)
         INNER JOIN productos p ON (a.idproducto=p.idproducto)
    WHERE a.idorigen=r_datos.idorigen AND a.idgrupo=r_datos.idgrupo AND
          a.idsocio=r_datos.idsocio AND p.tipoproducto=2 AND ad.cargoabono=1 AND
          DATE(ad.fecha) >= DATE(fecha_hoy - ''36 MONTH''::INTERVAL)
    ORDER BY (monto + montoio + montoim + montoiva + montoivaim) DESC
  LOOP
    IF x = 1 THEN pago_mens_max_3a_1 := TRIM(TO_CHAR(montoz,''99999999.99''));
    END IF;
    IF x = 2 THEN pago_mens_max_3a_2 := TRIM(TO_CHAR(montoz,''99999999.99''));
    END IF;
    IF x = 3 THEN pago_mens_max_3a_3 := TRIM(TO_CHAR(montoz,''99999999.99''));
    END IF;
    IF x = 4 THEN pago_mens_max_3a_4 := TRIM(TO_CHAR(montoz,''99999999.99''));
    END IF;
    IF x = 5 THEN pago_mens_max_3a_5 := TRIM(TO_CHAR(montoz,''99999999.99''));
    END IF;
    IF x = 6 THEN pago_mens_max_3a_6 := TRIM(TO_CHAR(montoz,''99999999.99''));
    END IF;

    x := x + 1;
  END LOOP;

  ----------------------------------------------------------
  -- LOS AVALES PRESENTARON EL PAGO DE PREDIAL ?? Esto se --
  -- verifica con los requisitos 393 y 394 del prestamo ----
  ----------------------------------------------------------
  predial_aval1 :=
      CASE WHEN (SELECT COUNT(*) FROM requisitossocios
                 WHERE idorigenp = p_idorigenp AND idproducto = p_idproducto AND
                       idauxiliar = p_idauxiliar AND idrequisito = 393 AND
                       estatus = TRUE) > 0 THEN ''SI'' ELSE ''NO'' END;
  predial_aval2 :=
      CASE WHEN (SELECT COUNT(*) FROM requisitossocios
                 WHERE idorigenp = p_idorigenp AND idproducto = p_idproducto AND
                       idauxiliar = p_idauxiliar AND idrequisito = 394 AND
                       estatus = TRUE) > 0 THEN ''SI'' ELSE ''NO'' END;

  montox := 0.0;
  SELECT INTO montox saldo FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND idproducto = 101 AND estatus = 2 AND
        saldo > 0;
  IF NOT FOUND OR montox IS NULL THEN montox := 0.0; END IF;
  saldo_certificados := TRIM(TO_CHAR(montox,''99999999.99''));

  montox := 0.0;
  SELECT INTO montox saldo FROM auxiliares
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND idproducto = 110 AND estatus = 2 AND
        saldo > 0;
  IF NOT FOUND OR montox IS NULL THEN montox := 0.0; END IF;
  saldo_ahorro := TRIM(TO_CHAR(montox,''99999999.99''));

  --------------------------------------------------
  -- MONTO MAXIMO PRESTADO EN QUE EL SOLICITANTE ---
  -- SE HAYA ATRASADO 3 O MAS ABONOS ---------------
  --------------------------------------------------
  montox := 0.0;
  SELECT INTO montox MAX(montoprest) FROM balancecred
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND abonosvencidos >= 3.0;
  IF NOT FOUND OR montox IS NULL THEN montox := 0.0; END IF;

  montoy := 0.0;
  SELECT INTO montoy MAX(montoprest) FROM balancecred_h
  WHERE idorigen = r_datos.idorigen AND idgrupo = r_datos.idgrupo AND
        idsocio = r_datos.idsocio AND abonosvencidos >= 3.0;
  IF NOT FOUND OR montoy IS NULL THEN montoy := 0.0; END IF;

  monto_max_hist_morosidad3m :=
      TRIM(TO_CHAR(
           (CASE WHEN montox > montoy THEN montox ELSE montoy END),
           ''99999999.99''));

  sector_actividad :=
  TRIM(TO_CHAR((CASE WHEN r_trabajo1.tipo_ocupacion IS NULL
                     THEN 0 ELSE r_trabajo1.tipo_ocupacion END), ''9999''));
  IF hay_conyuge THEN
    sector_actividad_conyuge :=
    TRIM(TO_CHAR((CASE WHEN r_trabajo1_c.tipo_ocupacion IS NULL
                       THEN 0 ELSE r_trabajo1_c.tipo_ocupacion END), ''9999''));
  ELSE
    sector_actividad_conyuge := '''';
  END IF;

  ------------------------------------------------------------------------------
  -- CICLO PARA DETERMINAR LOS MONTOS EN RIESGO DE LOS AVALADOS POR LOS AVALES -
  ------------------------------------------------------------------------------
  IF hay_aval1 THEN
    px1 := datos_de_los_avalados(idorigen_a1,idgrupo_a1, idsocio_a1, fecha_hoy);
    monto_riesgo_avalados_aval1 := TRIM(SAI_TOKEN(1, px1, ''|''));
    pagos_mens_avalados_aval1 := TRIM(SAI_TOKEN(2, px1, ''|''));
  ELSE
    monto_riesgo_avalados_aval1 := ''0''; pagos_mens_avalados_aval1 := ''0'';
  END IF;

  IF hay_aval2 THEN
    px1 := datos_de_los_avalados(idorigen_a2,idgrupo_a2, idsocio_a2, fecha_hoy);
    monto_riesgo_avalados_aval2 := TRIM(SAI_TOKEN(1, px1, ''|''));
    pagos_mens_avalados_aval2 := TRIM(SAI_TOKEN(2, px1, ''|''));
  ELSE
    monto_riesgo_avalados_aval2 := ''0''; pagos_mens_avalados_aval2 := ''0'';
  END IF;

  tipo_operacion :=
      CASE WHEN r_datos.tipoprestamo = 0      THEN ''NUEVO''
           WHEN r_datos.tipoprestamo IN (1,3) THEN ''RENOVACION''
           WHEN r_datos.tipoprestamo IN (2,4) THEN ''REESTRUCTURA''
           ELSE ''SIN DEFINIR'' END;

  ----------------------------
  -- DATOS DE LAS GARANTIAS --
  ----------------------------
  px1 := ''GAR|''||TRIM(TO_CHAR(p_idorigenp,''099999''))||''|''||
         TRIM(TO_CHAR(p_idproducto,''09999''))||''|''||
         TRIM(TO_CHAR(p_idauxiliar,''09999999''))||''%'';

  px2 := NULL;
  SELECT INTO px2 REPLACE(descripcion,'','','''') FROM notas
  WHERE idnota LIKE px1 AND SAI_FINDSTR(nota, ''|'') > 4;
  IF px2 IS NULL THEN
    valor_gar_prendaria := ''''; valor_gar_real := '''';
  ELSE
    valor_gar_prendaria := px2::VARCHAR; valor_gar_real := px2::VARCHAR;
  END IF;

  px2 := NULL;
  SELECT INTO px2 SAI_TOKEN(2, nota, ''|'') FROM notas
  WHERE idnota LIKE px1 AND SAI_FINDSTR(nota, ''|'') BETWEEN 1 AND 4 LIMIT 1;
  IF px2 IS NULL THEN direccion_gar_hip := '''';
  ELSE direccion_gar_hip := px2::VARCHAR;
  END IF;

  -----------------------------------------------------------------------------
  -- QUE USO TIENE EL COCHE QUE SE DEJA EN GARANTIA? Y QUE ANTIGUEDAD TIENE? --
  -----------------------------------------------------------------------------
  tipo_garantia_prendaria_coche := ''''; ant_garprendaria:='''';
  SELECT INTO px2 nota FROM notas
  WHERE idnota LIKE px1 AND SAI_FINDSTR(nota, ''|'') > 12;
  IF FOUND AND px2 IS NOT NULL AND LENGTH(px2) > 0 THEN
    IF UPPER(SAI_TOKEN(15, px2, ''|'')) = ''U'' THEN
      tipo_garantia_prendaria_coche := ''USO UTILITARIO'';
    END IF;
    IF UPPER(SAI_TOKEN(15, px2, ''|'')) = ''P'' THEN
      tipo_garantia_prendaria_coche := ''USO PARTICULAR'';
    END IF;

    IF SAI_TOKEN(14, px2, ''|'') != '''' THEN
      ant_garprendaria :=
        TRIM(TO_CHAR(
          ROUND(((fecha_hoy - DATE(SAI_TOKEN(14,px2,''|'')))::NUMERIC/365.0),0),
          ''999''));
      IF ant_garprendaria = NULL THEN ant_garprendaria:=''''; END IF;
    END IF;
  END IF;

  IF hay_aval1 THEN
    valor_relacion_patr_aval1 :=
    TRIM(TO_CHAR(
            (CASE WHEN r_s_economicos_a1.valorpropiedad IS NULL
                  THEN 0.0 ELSE r_s_economicos_a1.valorpropiedad END),''99999999.99''));
  ELSE
    valor_relacion_patr_aval1 := '''';
  END IF;

  IF hay_aval2 THEN
    valor_relacion_patr_aval2 :=
    TRIM(TO_CHAR(
            (CASE WHEN r_s_economicos_a2.valorpropiedad IS NULL
                  THEN 0.0 ELSE r_s_economicos_a2.valorpropiedad END),''99999999.99''));
  ELSE
    valor_relacion_patr_aval2 := '''';
  END IF;

  ------------------------------
  -- CREDITOS DE FACTOR ELITE --
  ------------------------------
  cred_e1 := 0; cred_e2 := 0; cred_e3 := 0; cred_e4 := 0;
  montox := 0.0; montoy := 0.0; y := 1;
  FOR r_aux IN
    SELECT a.idorigenp,a.idproducto,a.idauxiliar,a.fechaactivacion,
           a.montoprestado
    FROM auxiliares_h a INNER JOIN productos p USING (idproducto)
    WHERE p.tipoproducto = 2 AND a.estatus = 3 AND a.idorigenp > 0 AND
          a.idproducto > 0 AND a.idauxiliar > 0 AND a.idorigen = r_datos.idorigen
          AND a.idgrupo = r_datos.idgrupo AND a.idsocio = r_datos.idsocio AND
          (a.fechauma - a.fechaactivacion) >= 180
    ORDER BY a.fechaactivacion DESC
  LOOP
    x := 0;
    SELECT INTO x COUNT(*) FROM amortizaciones_h
    WHERE idorigenp = r_aux.idorigenp AND idproducto = r_aux.idproducto AND
          idauxiliar = r_aux.idauxiliar AND atiempo = FALSE;
    IF NOT FOUND OR x IS NULL THEN x := 0; END IF;
    IF x < 2 THEN

      cred_e1 := cred_e1 + 1;
      IF r_aux.fechaactivacion >= DATE(fecha_hoy - ''10 YEAR''::INTERVAL) THEN
        cred_e2 := cred_e2 + 1;
      END IF;
      IF r_aux.fechaactivacion >= DATE(fecha_hoy - ''3 YEAR''::INTERVAL) THEN
        cred_e3 := cred_e3 + 1;
      END IF;
      IF r_aux.fechaactivacion >= DATE(fecha_hoy - ''5 YEAR''::INTERVAL) THEN
        cred_e4 := cred_e4 + 1;
      END IF;

      IF y=1 AND r_aux.fechaactivacion>=DATE(fecha_hoy-''3 YEAR''::INTERVAL) THEN
        montox := r_aux.montoprestado;
      END IF;
      IF y=2 AND r_aux.fechaactivacion>=DATE(fecha_hoy-''3 YEAR''::INTERVAL) THEN
        montoy := r_aux.montoprestado;
      END IF;

      y := y + 1;
    END IF;

  END LOOP;
  numcred_factor_elite     := TRIM(TO_CHAR(cred_e1, ''9999''));
  numcred_factor_elite_10a := TRIM(TO_CHAR(cred_e2, ''9999''));
  numcred_factor_elite_3a  := TRIM(TO_CHAR(cred_e3, ''9999''));
  numcred_factor_elite_5a  := TRIM(TO_CHAR(cred_e4, ''9999''));

  monto_penult_cred_factor_elite_3a := TRIM(TO_CHAR(montoy,''99999999.99''));
  monto_ult_cred_factor_elite_3a    := TRIM(TO_CHAR(montox,''99999999.99''));

  fecha_venc_credito :=
   TRIM(TO_CHAR(
          (CASE WHEN r_datos.pagodiafijo = 1
                THEN (DATE(r_datos.fechaape + INT4(r_datos.periodoabonos)) +
                      TEXT(TRIM(TO_CHAR(r_datos.plazo,''9999''))||'' month'')::INTERVAL)
                ELSE DATE((r_datos.fechaape + INT4(r_datos.plazo*r_datos.periodoabonos)))
           END),''DD/MM/YYYY''));

  -- MONTO EN INVERSIONES --
  montox := 0.0;
  SELECT INTO montox SUM(a.saldo)
  FROM auxiliares a INNER JOIN productos p USING (idproducto)
  WHERE a.idorigen=r_datos.idorigen AND a.idgrupo=r_datos.idgrupo AND
        a.idsocio=r_datos.idsocio AND p.tipoproducto IN (1,8) AND a.estatus=2;
  IF NOT FOUND OR montox IS NULL THEN montox := 0.0; END IF;
  saldo_inv_actual := TRIM(TO_CHAR(montox,''99999999.99''));

  es_renovacion :=
      CASE WHEN r_datos.tipoprestamo = 0      THEN ''NUEVO''
           WHEN r_datos.tipoprestamo IN (1,3) THEN ''RENOVACION''
           WHEN r_datos.tipoprestamo IN (2,4) THEN ''REESTRUCTURA''
           ELSE ''SIN DEFINIR'' END;

  -- FOLIO DEL CREDITO RENOVADO --
  SELECT INTO px1
         TRIM(TO_CHAR(idorigenpr,''099999''))||''-''||
         TRIM(TO_CHAR(idproductor,''09999''))||''-''||
         TRIM(TO_CHAR(idauxiliarr,''09999999'')), idorigenpr
  FROM referenciasp
  WHERE idorigenp = p_idorigenp AND idproducto = p_idproducto AND
        idauxiliar = p_idauxiliar AND tiporeferencia=2;
  IF NOT FOUND THEN
    folio_credito_renovado := '''';
  ELSE
    folio_credito_renovado := px1::VARCHAR;
  END IF;

  -- NOMBRE DEL CREDITO REESTRUCTURADO --
  SELECT INTO px1 nombre FROM productos
  WHERE idproducto =
        (SELECT idproducto FROM referenciasp
         WHERE idorigenp = p_idorigenp AND idproducto = p_idproducto AND
               idauxiliar = p_idauxiliar AND tiporeferencia=3);
  IF NOT FOUND THEN
    nombre_credito_reestructurado := '''';
  ELSE
    nombre_credito_reestructurado := px1::VARCHAR;
  END IF;

  ----------------------------------------------------------------
  -- EL SOLICITANTE TIENE PREDIAL PAGADO ?? (IDREQUISITO = 391) --
  ----------------------------------------------------------------
  predial_solicitante :=
      CASE WHEN (SELECT COUNT(*) FROM requisitossocios
                 WHERE idorigenp = p_idorigenp AND idproducto = p_idproducto AND
                       idauxiliar = p_idauxiliar AND idrequisito = 391 AND
                       estatus = TRUE) > 0 THEN ''SI'' ELSE ''NO'' END;

  ----------------------------------
  -- Valor del inmueble del socio --
  ----------------------------------
  valor_inmueble :=
      TRIM(TO_CHAR(
          (CASE WHEN r_s_economicos.valorpropiedad IS NULL
                THEN 0.0 ELSE r_s_economicos.valorpropiedad END),''99999999.99''));

  ------------------------------------------------------------------------------
  -- DATOS SACADOS DE LA NUEVA TABLA solicitudes_prestamos ---------------------
  ------------------------------------------------------------------------------
  ant_auto:=''''; valor_venta_automovil:=''''; vendedor_auto_seminuevo:='''';
  valor_avaluo_vivienda:=''''; valor_venta_vivienda:='''';
  saldo_credito_original:=''''; tipo_credito_a_convertir:='''';
  SELECT INTO r_datosx * FROM solicitudes_prestamos
  WHERE idorigenp = p_idorigenp AND idproducto = p_idproducto AND
        idauxiliar = p_idauxiliar;
  IF FOUND THEN
    IF r_datosx.antiguedad_objcre IS NOT NULL THEN
      ant_auto :=
      TRIM(TO_CHAR(
        EXTRACT(YEARS FROM AGE(fecha_hoy, r_datosx.antiguedad_objcre)),''9999''));
    END IF;
--------------------------------------------------------------------------------
-- ESTO ES CORRECTO, HACER IGUALES ESTOS DOS VALORES ?? ------------------------
--------------------------------------------------------------------------------
    IF r_datosx.valor_venta_objcre IS NOT NULL THEN
      valor_venta_automovil :=
            TRIM(TO_CHAR(r_datosx.valor_venta_objcre, ''99999999.99''));
      valor_venta_vivienda :=
            TRIM(TO_CHAR(r_datosx.valor_venta_objcre, ''99999999.99''));
    END IF;

    IF r_datosx.tipo_vendedor_objcre IS NOT NULL THEN
      vendedor_auto_seminuevo :=
          CASE WHEN r_datosx.tipo_vendedor_objcre = 0 THEN ''SIN DEFINIR''
               WHEN r_datosx.tipo_vendedor_objcre = 1 THEN ''Agencia de autos''
               WHEN r_datosx.tipo_vendedor_objcre = 2 THEN ''Vendedor particular''
               ELSE ''SIN DEFINIR'' END;
    END IF;

    IF r_datosx.avaluo_objcre IS NOT NULL THEN
      valor_avaluo_vivienda :=
            TRIM(TO_CHAR(r_datosx.avaluo_objcre, ''99999999.99''));
    END IF;

    IF r_datosx.idorigenp_or IS NOT NULL AND r_datosx.idproducto_or IS NOT NULL
       AND r_datosx.idauxiliar_or IS NOT NULL THEN

      SELECT INTO saldo_credito_original, tipo_credito_a_convertir
                  TRIM(TO_CHAR(a.saldo,''99999999.99'')), p.nombre
      FROM auxiliares a INNER JOIN productos p USING (idproducto)
      WHERE a.idorigenp = r_datosx.idorigenp_or AND
            a.idproducto = r_datosx.idproducto_or AND
            a.idauxiliar = r_datosx.idauxiliar_or;
      IF NOT FOUND THEN
        saldo_credito_original:=''''; tipo_credito_a_convertir:='''';
      ELSE
        IF saldo_credito_original IS NULL THEN
          saldo_credito_original:='''';
        END IF;
        IF tipo_credito_a_convertir IS NULL THEN
          tipo_credito_a_convertir:='''';
        END IF;
      END IF;
    END IF;

  END IF;

--------------------------------------------------------------------------------
-- CAMPOS PENDIENTES DE DEFINIR, YA QUE LOS VALORES QUE DEBEN USARSE ESTAN EN EL
-- ARCHIVO Variables_110317.ods, Y SON CATALOGOS DIFERENTES A LOS DEL SAICOOP, O
-- TAMBIEN PORQUE SON VALORES QUE AUN NO SE GRABAN EN EL SISTEMA ---------------
--------------------------------------------------------------------------------

  -- DATO NUEVO EN EL SAICOOP, EN QUE SE USA EL CARRO QUE SE DEJA COMO GARANTIA
  enganche := '''';
  fecha_venc_inversion:='''';
  pago_mensual_credifise:='''';

--------------------------------------------------------------------------------
-- PENDIENTE : ESTOS DATOS SALDRAN DEL IDFINALIDAD DEL PRESTAMO, SEGUN LA LISTA
-- DE VALORES QUE DIERON PARA ESTOS CAMPOS, DEBE HABER AL MENOS 8 FINALIDADES --
--------------------------------------------------------------------------------
  -- USAR r_datos.idfinalidad
  destino_credito := '''';
  destino_vehiculo := '''';
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- PENDIENTE : ESTE DATO ES EN BASE A LA CUENTAAPLICA DEL PRODUCTO, ------------
-- PERO DEBE AJUSTARSE AL CATALOGO QUE VIENE EN EL ARCHIVO DE EXCEL ------------
--------------------------------------------------------------------------------
  destino_operacion:='''';
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

  IF act_economica IS NULL THEN act_economica := ''NULL''; END IF;
  IF act_economica_conyuge IS NULL THEN act_economica_conyuge := ''NULL''; END IF;
  IF ahorro_2o_mes_ant IS NULL THEN ahorro_2o_mes_ant := ''NULL''; END IF;
  IF ahorro_3er_mes_ant IS NULL THEN ahorro_3er_mes_ant := ''NULL''; END IF;
  IF ahorro_1er_mes_ant IS NULL THEN ahorro_1er_mes_ant := ''NULL''; END IF;
  IF am_mas_alto_3y_1 IS NULL THEN am_mas_alto_3y_1 := ''NULL''; END IF;
  IF am_mas_alto_3y_2 IS NULL THEN am_mas_alto_3y_2 := ''NULL''; END IF;
  IF am_mas_alto_3y_3 IS NULL THEN am_mas_alto_3y_3 := ''NULL''; END IF;
  IF am_mas_alto_3y_4 IS NULL THEN am_mas_alto_3y_4 := ''NULL''; END IF;
  IF am_mas_alto_3y_5 IS NULL THEN am_mas_alto_3y_5 := ''NULL''; END IF;
  IF am_mas_alto_3y_6 IS NULL THEN am_mas_alto_3y_6 := ''NULL''; END IF;
  IF ant_garprendaria IS NULL THEN ant_garprendaria := ''NULL''; END IF;
  IF ant_auto IS NULL THEN ant_auto := ''NULL''; END IF;
  IF comp_ingresos_1 IS NULL THEN comp_ingresos_1 := ''NULL''; END IF;
  IF comp_ingresos_2 IS NULL THEN comp_ingresos_2 := ''NULL''; END IF;
  IF comp_ingresos_3 IS NULL THEN comp_ingresos_3 := ''NULL''; END IF;
  IF comp_ingresos_conyuge_1 IS NULL THEN comp_ingresos_conyuge_1 := ''NULL'';
  END IF;
  IF comp_ingresos_conyuge_2 IS NULL THEN comp_ingresos_conyuge_2 := ''NULL'';
  END IF;
  IF comp_ingresos_conyuge_3 IS NULL THEN comp_ingresos_conyuge_3 := ''NULL'';
  END IF;
  IF dep_edo_cuenta_1 IS NULL THEN dep_edo_cuenta_1 := ''NULL''; END IF;
  IF dep_edo_cuenta_2 IS NULL THEN dep_edo_cuenta_2 := ''NULL''; END IF;
  IF dep_edo_cuenta_3 IS NULL THEN dep_edo_cuenta_3 := ''NULL''; END IF;
  IF dep_edo_cuenta_conyuge_1 IS NULL THEN dep_edo_cuenta_conyuge_1 := ''NULL'';
  END IF;
  IF dep_edo_cuenta_conyuge_2 IS NULL THEN dep_edo_cuenta_conyuge_2 := ''NULL'';
  END IF;
  IF dep_edo_cuenta_conyuge_3 IS NULL THEN dep_edo_cuenta_conyuge_3 := ''NULL'';
  END IF;
  IF destino_credito IS NULL THEN destino_credito := ''NULL''; END IF;
  IF destino_vehiculo IS NULL THEN destino_vehiculo := ''NULL''; END IF;
  IF destino_operacion IS NULL THEN destino_operacion := ''NULL''; END IF;
  IF dom_aval1_mismo_del_solicitante IS NULL THEN
    dom_aval1_mismo_del_solicitante := ''NULL'';
  END IF;
  IF dom_aval2_mismo_del_solicitante IS NULL THEN
    dom_aval2_mismo_del_solicitante := ''NULL'';
  END IF;
  IF aval1_es_socio IS NULL THEN aval1_es_socio := ''NULL''; END IF;
  IF aval2_es_socio IS NULL THEN aval2_es_socio := ''NULL''; END IF;
  IF enganche IS NULL THEN enganche := ''NULL''; END IF;
  IF escolaridad IS NULL THEN escolaridad := ''NULL''; END IF;
  IF edo_civil IS NULL THEN edo_civil := ''NULL''; END IF;
  IF fecha_ingreso IS NULL THEN fecha_ingreso := ''NULL''; END IF;
  IF fecha_nacimiento IS NULL THEN fecha_nacimiento := ''NULL''; END IF;
  IF fecha_domicilio IS NULL THEN fecha_domicilio := ''NULL''; END IF;
  IF fecha_nac_aval1 IS NULL THEN fecha_nac_aval1 := ''NULL''; END IF;
  IF fecha_nac_aval2 IS NULL THEN fecha_nac_aval2 := ''NULL''; END IF;
  IF fecha_nac_otorgante_gar_prend IS NULL THEN
    fecha_nac_otorgante_gar_prend := ''NULL'';
  END IF;
  IF gasto_mensual_familiar IS NULL THEN gasto_mensual_familiar := ''NULL''; END IF;
  IF sexo IS NULL THEN sexo := ''NULL''; END IF;
  IF ing_mens_bruto_aval1 IS NULL THEN ing_mens_bruto_aval1 := ''NULL''; END IF;
  IF ing_mens_bruto_aval2 IS NULL THEN ing_mens_bruto_aval2 := ''NULL''; END IF;
  IF ing_mens_bruto_concesionario IS NULL THEN
    ing_mens_bruto_concesionario := ''NULL'';
  END IF;
  IF ing_mens_bruto_concesionario_conyuge IS NULL THEN
    ing_mens_bruto_concesionario_conyuge := ''NULL'';
  END IF;
  IF ing_mens_bruto_nomina IS NULL THEN
    ing_mens_bruto_nomina := ''NULL'';
  END IF;
  IF ing_mens_bruto_nomina_conyuge IS NULL THEN
    ing_mens_bruto_nomina_conyuge := ''NULL'';
  END IF;
  IF ing_mens_bruto_carta_cont_conyuge IS NULL THEN
    ing_mens_bruto_carta_cont_conyuge := ''NULL'';
  END IF;
  IF ing_mens_bruto_carta_patron_conyuge IS NULL THEN
    ing_mens_bruto_carta_patron_conyuge := ''NULL'';
  END IF;
  IF ing_mens_bruto_taxista IS NULL THEN ing_mens_bruto_taxista := ''NULL''; END IF;
  IF ing_mens_bruto_taxista_conyuge IS NULL THEN
    ing_mens_bruto_taxista_conyuge := ''NULL'';
  END IF;
  IF ing_mens_bruto_carta_cont IS NULL THEN
    ing_mens_bruto_carta_cont := ''NULL'';
  END IF;
  IF ing_mens_bruto_carta_patron IS NULL THEN
    ing_mens_bruto_carta_patron := ''NULL'';
  END IF;
  IF meses_en_empleo IS NULL THEN meses_en_empleo := ''NULL''; END IF;
  IF meses_en_empleo_conyuge IS NULL THEN meses_en_empleo_conyuge := ''NULL''; END IF;
  IF monto_credito IS NULL THEN monto_credito := ''NULL''; END IF;
  IF monto_contrato_arrendamiento IS NULL THEN
    monto_contrato_arrendamiento := ''NULL'';
  END IF;
  IF monto_contrato_arrendamiento_conyuge IS NULL THEN
    monto_contrato_arrendamiento_conyuge := ''NULL'';
  END IF;
  IF monto_riesgo_autocredito IS NULL THEN
    monto_riesgo_autocredito := ''NULL'';
  END IF;
  IF monto_riesgo_credi10 IS NULL THEN monto_riesgo_credi10 := ''NULL''; END IF;
  IF monto_riesgo_credifise IS NULL THEN monto_riesgo_credifise := ''NULL''; END IF;
  IF monto_riesgo_elite IS NULL THEN monto_riesgo_elite := ''NULL''; END IF;
  IF monto_riesgo_hipotecario IS NULL THEN
    monto_riesgo_hipotecario := ''NULL'';
  END IF;
  IF monto_riesgo_nom_empresarial IS NULL THEN
    monto_riesgo_nom_empresarial := ''NULL'';
  END IF;
  IF monto_riesgo_ordinario IS NULL THEN monto_riesgo_ordinario := ''NULL''; END IF;
  IF monto_riesgo_confianza IS NULL THEN monto_riesgo_confianza := ''NULL''; END IF;
  IF monto_riesgo_prest_extraordinario IS NULL THEN
    monto_riesgo_prest_extraordinario := ''NULL'';
  END IF;
  IF monto_riesgo_prest_gerencial IS NULL THEN
    monto_riesgo_prest_gerencial := ''NULL'';
  END IF;
  IF monto_riesgo_prest_reestruct IS NULL THEN
    monto_riesgo_prest_reestruct := ''NULL'';
  END IF;
  IF monto_riesgo_prest_renovado IS NULL THEN
    monto_riesgo_prest_renovado := ''NULL'';
  END IF;
  IF monto_riesgo_prest_simple IS NULL THEN
    monto_riesgo_prest_simple := ''NULL'';
  END IF;
  IF monto_riesgo_prest_inversion IS NULL THEN
    monto_riesgo_prest_inversion := ''NULL'';
  END IF;
  IF monto_solicitado IS NULL THEN monto_solicitado := ''NULL''; END IF;
  IF morosidad_actual IS NULL THEN morosidad_actual := ''NULL''; END IF;
  IF morosidad_avalados_12m IS NULL THEN morosidad_avalados_12m := ''NULL''; END IF;
  IF morosidad_solicitante_es_conyuge_12m IS NULL THEN
    morosidad_solicitante_es_conyuge_12m := ''NULL'';
  END IF;
  IF morosidad_solicitante IS NULL THEN morosidad_solicitante := ''NULL''; END IF;
  IF morosidad_solicitante_ultimos_12m IS NULL THEN
    morosidad_solicitante_ultimos_12m := ''NULL'';
  END IF;
  IF morosidad_solicitante_ultimos_24m IS NULL THEN
    morosidad_solicitante_ultimos_24m := ''NULL'';
  END IF;
  IF morosidad_vig_aval1 IS NULL THEN morosidad_vig_aval1 := ''NULL''; END IF;
  IF morosidad_vig_aval2 IS NULL THEN morosidad_vig_aval2 := ''NULL''; END IF;
  IF morosidad_vig_aval1_es_conyuge IS NULL THEN
    morosidad_vig_aval1_es_conyuge := ''NULL'';
  END IF;
  IF morosidad_vig_aval2_es_conyuge IS NULL THEN
    morosidad_vig_aval2_es_conyuge := ''NULL'';
  END IF;
  IF morosidad_vig_avalados_aval1 IS NULL THEN
    morosidad_vig_avalados_aval1 := ''NULL'';
  END IF;
  IF morosidad_vig_avalados_aval2 IS NULL THEN
    morosidad_vig_avalados_aval2 := ''NULL'';
  END IF;
  IF num_avales IS NULL THEN num_avales := ''NULL''; END IF;
  IF num_creditos_vivos_avalados IS NULL THEN
    num_creditos_vivos_avalados := ''NULL'';
  END IF;
  IF num_creditos_vivos_avalados_conyuge IS NULL THEN
    num_creditos_vivos_avalados_conyuge := ''NULL'';
  END IF;
  IF num_dependientes IS NULL THEN num_dependientes := ''NULL''; END IF;
  IF num_despendientes_esc IS NULL THEN num_despendientes_esc := ''NULL''; END IF;
  IF num_empleados IS NULL THEN num_empleados := ''NULL''; END IF;
  IF num_empleados_conyuge IS NULL THEN num_empleados_conyuge := ''NULL''; END IF;
  IF num_taxis IS NULL THEN num_taxis := ''NULL''; END IF;
  IF num_taxis_conyuge IS NULL THEN num_taxis_conyuge := ''NULL''; END IF;
  IF ocupacion IS NULL THEN ocupacion := ''NULL''; END IF;
  IF ocupacion_conyuge IS NULL THEN ocupacion_conyuge := ''NULL''; END IF;
  IF ocupacion_principal IS NULL THEN ocupacion_principal := ''NULL''; END IF;
  IF ocupacion_principal_conyuge IS NULL THEN
    ocupacion_principal_conyuge := ''NULL'';
  END IF;
  IF pago_mensual_deudas_por_nomina IS NULL THEN
    pago_mensual_deudas_por_nomina := ''NULL'';
  END IF;
  IF pago_mensual_deudas_por_nomina_conyuge IS NULL THEN
    pago_mensual_deudas_por_nomina_conyuge := ''NULL'';
  END IF;
  IF pago_mensual IS NULL THEN pago_mensual := ''NULL''; END IF;
  IF plazo_meses IS NULL THEN plazo_meses := ''NULL''; END IF;
  IF pago_mens_max_3a_1 IS NULL THEN pago_mens_max_3a_1 := ''NULL''; END IF;
  IF pago_mens_max_3a_2 IS NULL THEN pago_mens_max_3a_2 := ''NULL''; END IF;
  IF pago_mens_max_3a_3 IS NULL THEN pago_mens_max_3a_3 := ''NULL''; END IF;
  IF pago_mens_max_3a_4 IS NULL THEN pago_mens_max_3a_4 := ''NULL''; END IF;
  IF pago_mens_max_3a_5 IS NULL THEN pago_mens_max_3a_5 := ''NULL''; END IF;
  IF pago_mens_max_3a_6 IS NULL THEN pago_mens_max_3a_6 := ''NULL''; END IF;
  IF predial_aval1 IS NULL THEN predial_aval1 := ''NULL''; END IF;
  IF predial_aval2 IS NULL THEN predial_aval2 := ''NULL''; END IF;
  IF saldo_certificados IS NULL THEN saldo_certificados := ''NULL''; END IF;
  IF saldo_credito_original IS NULL THEN saldo_credito_original := ''NULL''; END IF;
  IF saldo_ahorro IS NULL THEN saldo_ahorro := ''NULL''; END IF;
  IF monto_max_hist_morosidad3m IS NULL THEN
    monto_max_hist_morosidad3m := ''NULL'';
  END IF;
  IF sector_actividad IS NULL THEN sector_actividad := ''NULL''; END IF;
  IF sector_actividad_conyuge IS NULL THEN
    sector_actividad_conyuge := ''NULL'';
  END IF;
  IF monto_riesgo_avalados_aval1 IS NULL THEN
    monto_riesgo_avalados_aval1 := ''NULL'';
  END IF;
  IF monto_riesgo_avalados_aval2 IS NULL THEN
    monto_riesgo_avalados_aval2 := ''NULL'';
  END IF;
  IF pagos_mens_avalados_aval1 IS NULL THEN
    pagos_mens_avalados_aval1 := ''NULL'';
  END IF;
  IF pagos_mens_avalados_aval2 IS NULL THEN
    pagos_mens_avalados_aval2 := ''NULL'';
  END IF;
  IF tipo_credito_a_convertir IS NULL THEN
    tipo_credito_a_convertir := ''NULL'';
  END IF;
  IF tipo_garantia_prendaria_coche IS NULL THEN
    tipo_garantia_prendaria_coche := ''NULL'';
  END IF;
  IF tipo_operacion IS NULL THEN tipo_operacion := ''NULL''; END IF;
  IF direccion_gar_hip IS NULL THEN direccion_gar_hip := ''NULL''; END IF;
  IF valor_gar_prendaria IS NULL THEN valor_gar_prendaria := ''NULL''; END IF;
  IF valor_gar_real IS NULL THEN valor_gar_real := ''NULL''; END IF;
  IF valor_relacion_patr_aval1 IS NULL THEN
    valor_relacion_patr_aval1 := ''NULL'';
  END IF;
  IF valor_relacion_patr_aval2 IS NULL THEN
    valor_relacion_patr_aval2 := ''NULL'';
  END IF;
  IF valor_venta_automovil IS NULL THEN valor_venta_automovil := ''NULL''; END IF;
  IF vendedor_auto_seminuevo IS NULL THEN
    vendedor_auto_seminuevo := ''NULL'';
  END IF;
  IF impuestos_y_deducciones IS NULL THEN
    impuestos_y_deducciones := ''NULL'';
  END IF;
  IF impuestos_y_deducciones_conyuge IS NULL THEN
    impuestos_y_deducciones_conyuge := ''NULL'';
  END IF;
  IF numcred_factor_elite IS NULL THEN numcred_factor_elite := ''NULL''; END IF;
  IF numcred_factor_elite_10a IS NULL THEN
    numcred_factor_elite_10a := ''NULL'';
  END IF;
  IF numcred_factor_elite_3a IS NULL THEN
    numcred_factor_elite_3a := ''NULL'';
  END IF;
  IF numcred_factor_elite_5a IS NULL THEN
    numcred_factor_elite_5a := ''NULL'';
  END IF;
  IF fecha_venc_inversion IS NULL THEN fecha_venc_inversion := ''NULL''; END IF;
  IF fecha_venc_credito IS NULL THEN fecha_venc_credito := ''NULL''; END IF;
  IF monto_penult_cred_factor_elite_3a IS NULL THEN
    monto_penult_cred_factor_elite_3a := ''NULL'';
  END IF;
  IF monto_ult_cred_factor_elite_3a IS NULL THEN
    monto_ult_cred_factor_elite_3a := ''NULL'';
  END IF;
  IF saldo_inv_actual IS NULL THEN saldo_inv_actual := ''NULL''; END IF;
  IF valor_avaluo_vivienda IS NULL THEN valor_avaluo_vivienda := ''NULL''; END IF;
  IF valor_venta_vivienda IS NULL THEN valor_venta_vivienda := ''NULL''; END IF;
  IF pago_mensual_credifise IS NULL THEN pago_mensual_credifise := ''NULL''; END IF;
  IF predial_solicitante IS NULL THEN predial_solicitante := ''NULL''; END IF;
  IF valor_inmueble IS NULL THEN valor_inmueble := ''NULL''; END IF;
  IF es_renovacion IS NULL THEN es_renovacion := ''NULL''; END IF;
  IF folio_credito_renovado IS NULL THEN folio_credito_renovado := ''NULL''; END IF;
  IF nombre_credito_reestructurado IS NULL THEN
    nombre_credito_reestructurado := ''NULL'';
  END IF;

  resultado := ''ID1|''||act_economica||''|ID2|''||act_economica_conyuge||
      ''|ID5|''||ahorro_2o_mes_ant||''|ID6|''||ahorro_3er_mes_ant||
      ''|ID7|''||ahorro_1er_mes_ant||''|ID12|''||am_mas_alto_3y_1||
      ''|ID13|''||am_mas_alto_3y_2||''|ID14|''||am_mas_alto_3y_3||
      ''|ID15|''||am_mas_alto_3y_4||''|ID16|''||am_mas_alto_3y_5||
      ''|ID17|''||am_mas_alto_3y_6||''|ID18|''||ant_garprendaria||
      ''|ID19|''||ant_auto||''|ID28|''||comp_ingresos_1||
      ''|ID28.1|''||comp_ingresos_2||''|ID28.2|''||comp_ingresos_3||
      ''|ID29|''||comp_ingresos_conyuge_1||''|ID29.1|''||comp_ingresos_conyuge_2||
      ''|ID29.2|''||comp_ingresos_conyuge_3||''|ID30|''||dep_edo_cuenta_1||
      ''|ID31|''||dep_edo_cuenta_2||''|ID32|''||dep_edo_cuenta_3||
      ''|ID33|''||dep_edo_cuenta_conyuge_1||''|ID34|''||dep_edo_cuenta_conyuge_2||
      ''|ID35|''||dep_edo_cuenta_conyuge_3||''|ID36|''||destino_credito||
      ''|ID37|''||destino_vehiculo||''|ID38|''||destino_operacion||
      ''|ID39|''||dom_aval1_mismo_del_solicitante||
      ''|ID40|''||dom_aval2_mismo_del_solicitante||''|ID41|''||aval1_es_socio||
      ''|ID42|''||aval2_es_socio||''|ID43|''||enganche||''|ID44|''||escolaridad||
      ''|ID45|''||edo_civil||''|ID46|''||fecha_ingreso||
      ''|ID47|''||fecha_nacimiento||''|ID48|''||fecha_domicilio||
      ''|ID49|''||fecha_nac_aval1||''|ID50|''||fecha_nac_aval2||
      ''|ID51|''||fecha_nac_otorgante_gar_prend||
      ''|ID52|''||gasto_mensual_familiar||''|ID53|''||sexo||
      ''|ID60|''||ing_mens_bruto_aval1||''|ID61|''||ing_mens_bruto_aval2||
      ''|ID62|''||ing_mens_bruto_concesionario||
      ''|ID63|''||ing_mens_bruto_concesionario_conyuge||
      ''|ID64|''||ing_mens_bruto_nomina||
      ''|ID65|''||ing_mens_bruto_nomina_conyuge||
      ''|ID66|''||ing_mens_bruto_carta_cont_conyuge||
      ''|ID67|''||ing_mens_bruto_carta_patron_conyuge||
      ''|ID68|''||ing_mens_bruto_taxista||
      ''|ID69|''||ing_mens_bruto_taxista_conyuge||
      ''|ID70|''||ing_mens_bruto_carta_cont||
      ''|ID71|''||ing_mens_bruto_carta_patron||''|ID72|''||meses_en_empleo||
      ''|ID73|''||meses_en_empleo_conyuge||''|ID74|''||monto_credito||
      ''|ID75|''||monto_contrato_arrendamiento||
      ''|ID76|''||monto_contrato_arrendamiento_conyuge||
      ''|ID77|''||monto_riesgo_autocredito||''|ID78|''||monto_riesgo_credi10||
      ''|ID79|''||monto_riesgo_credifise||''|ID80|''||monto_riesgo_elite||
      ''|ID81|''||monto_riesgo_hipotecario||
      ''|ID82|''||monto_riesgo_nom_empresarial||
      ''|ID83|''||monto_riesgo_ordinario||''|ID84|''||monto_riesgo_confianza||
      ''|ID85|''||monto_riesgo_prest_extraordinario||
      ''|ID86|''||monto_riesgo_prest_gerencial||
      ''|ID87|''||monto_riesgo_prest_reestruct||
      ''|ID88|''||monto_riesgo_prest_renovado||
      ''|ID89|''||monto_riesgo_prest_simple||
      ''|ID90|''||monto_riesgo_prest_inversion||''|ID91|''||monto_solicitado||
      ''|ID92|''||morosidad_actual||''|ID93|''||morosidad_avalados_12m||
      ''|ID94|''||morosidad_solicitante_es_conyuge_12m||
      ''|ID95|''||morosidad_solicitante||
      ''|ID96|''||morosidad_solicitante_ultimos_12m||
      ''|ID97|''||morosidad_solicitante_ultimos_24m||
      ''|ID98|''||morosidad_vig_aval1||''|ID99|''||morosidad_vig_aval2||
      ''|ID100|''||morosidad_vig_aval1_es_conyuge||
      ''|ID101|''||morosidad_vig_aval2_es_conyuge||
      ''|ID102|''||morosidad_vig_avalados_aval1||
      ''|ID103|''||morosidad_vig_avalados_aval2||''|ID104|''||num_avales||
      ''|ID105|''||num_creditos_vivos_avalados||
      ''|ID106|''||num_creditos_vivos_avalados_conyuge||
      ''|ID107|''||num_dependientes||''|ID108|''||num_despendientes_esc||
      ''|ID109|''||num_empleados||''|ID110|''||num_empleados_conyuge||
      ''|ID111|''||num_taxis||''|ID112|''||num_taxis_conyuge||
      ''|ID113|''||ocupacion||''|ID114|''||ocupacion_conyuge||
      ''|ID115|''||ocupacion_principal||''|ID116|''||ocupacion_principal_conyuge||
      ''|ID117|''||pago_mensual_deudas_por_nomina||
      ''|ID118|''||pago_mensual_deudas_por_nomina_conyuge||
      ''|ID119|''||pago_mensual||''|ID122|''||plazo_meses||
      ''|ID123|''||pago_mens_max_3a_1||''|ID124|''||pago_mens_max_3a_2||
      ''|ID125|''||pago_mens_max_3a_3||''|ID126|''||pago_mens_max_3a_4||
      ''|ID127|''||pago_mens_max_3a_5||''|ID128|''||pago_mens_max_3a_6||
      ''|ID129|''||predial_aval1||''|ID130|''||predial_aval2||
      ''|ID131|''||saldo_certificados||''|ID132|''||saldo_credito_original||
      ''|ID133|''||saldo_ahorro||''|ID134|''||monto_max_hist_morosidad3m||
      ''|ID135|''||sector_actividad||''|ID136|''||sector_actividad_conyuge||
      ''|ID137|''||monto_riesgo_avalados_aval1||
      ''|ID138|''||monto_riesgo_avalados_aval2||
      ''|ID139|''||pagos_mens_avalados_aval1||
      ''|ID140|''||pagos_mens_avalados_aval2||
      ''|ID141|''||tipo_credito_a_convertir||
      ''|ID142|''||tipo_garantia_prendaria_coche||''|ID143|''||tipo_operacion||
      ''|ID144|''||direccion_gar_hip||''|ID145|''||valor_gar_prendaria||
      ''|ID146|''||valor_gar_real||''|ID147|''||valor_relacion_patr_aval1||
      ''|ID148|''||valor_relacion_patr_aval2||''|ID149|''||valor_venta_automovil||
      ''|ID150|''||vendedor_auto_seminuevo||''|ID154|''||impuestos_y_deducciones||
      ''|ID155|''||impuestos_y_deducciones_conyuge||
      ''|ID151|''||numcred_factor_elite||''|ID152|''||numcred_factor_elite_10a||
      ''|ID153|''||numcred_factor_elite_3a||''|ID154|''||numcred_factor_elite_5a||
      ''|ID155|''||fecha_venc_inversion||''|ID156|''||fecha_venc_credito||
      ''|ID157|''||monto_penult_cred_factor_elite_3a||
      ''|ID158|''||monto_ult_cred_factor_elite_3a||
      ''|ID159|''||saldo_inv_actual||''|ID160|''||valor_avaluo_vivienda||
      ''|ID161|''||valor_venta_vivienda||''|ID161|''||pago_mensual_credifise||
      ''|ID161|''||predial_solicitante||''|ID161|''||valor_inmueble||
      ''|ID161|''||es_renovacion||''|ID161|''||folio_credito_renovado||
      ''|ID161|''||nombre_credito_reestructurado;

  RETURN resultado;

END;
' LANGUAGE 'plpgsql';


-- ESTA FUNCION SE USARA CON LOS CREDITOS GRUPALES DE CREDICLUB, YA QUE A UNO DE
-- LOS CLIENTES DE UN GRUPO SE LE DEFINE EL LIMITE DE CREDITO DE TODO EL GRUPO,
-- Y BUSCA LOS PRESTAMOS QUE SE ESTAN APERTURANDO EN EL MISMO DIA O UN DIA ANTES
-- Y LOS QUE ESTAN ACTIVOS (JFPA, 13/DICIEMBRE/2012) ---------------------------
CREATE OR REPLACE FUNCTION
calcula_limite_de_credito_por_grupo(INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,NUMERIC)
RETURNS VARCHAR AS $$
DECLARE
  p_idorigen   ALIAS FOR $1;
  p_idgrupo    ALIAS FOR $2;
  p_idsocio    ALIAS FOR $3;
  p_idorigenp  ALIAS FOR $4;
  p_idproducto ALIAS FOR $5;
  p_idauxiliar ALIAS FOR $6;
  p_monto      ALIAS FOR $7;

  id_sector INTEGER;

  personas_grupo INTEGER;
  monto_grupo    NUMERIC;
  montox         NUMERIC;
  limite_credito NUMERIC;

  r_aux RECORD;

  ya_existe BOOLEAN;

  fecha_hoy DATE;

  px1 VARCHAR;
BEGIN

  IF (p_idorigen   IS NULL OR p_idorigen = 0)   OR
     (p_idgrupo    IS NULL OR p_idgrupo = 0)    OR
     (p_idsocio    IS NULL OR p_idsocio = 0)    OR
     (p_idorigenp  IS NULL OR p_idorigenp = 0)  OR
     (p_idproducto IS NULL OR p_idproducto = 0) OR
     (p_idauxiliar IS NULL OR p_idauxiliar = 0) THEN
    RETURN 'LOS DATOS DEL CLIENTE Y/O DEL FOLIO ESTAN EN CEROS !!';
  END IF;

  -- PRIMERO SE BUSCA SI EL SOCIO PERTENECE A UN GRUPO ---

  id_sector := 0;
  SELECT INTO id_sector idsector FROM personas
  WHERE  idorigen = p_idorigen AND idgrupo = p_idgrupo AND idsocio = p_idsocio;
  IF NOT FOUND OR id_sector IS NULL OR id_sector = 0 THEN
    RAISE NOTICE 'NO EXISTE EL GRUPO DE PERSONAS DONDE ESTA EL CLIENTE.';
    RETURN NULL;
  END IF;

  -- EL LIMITE DE CREDITO ESTA EN EL SOCIO ACTUAL O UNO DE LOS SOCIOS DEL GRUPO

  SELECT INTO fecha_hoy DATE(fechatrabajo) FROM origenes LIMIT 1;
  IF NOT FOUND THEN fecha_hoy := DATE(NOW()); END IF;

  limite_credito := 0.0;
  SELECT INTO limite_credito TRIM(SAI_REPLACE(limite, ',', ''))::NUMERIC
  FROM limite_de_credito lc INNER JOIN personas p USING (idorigen,idgrupo,idsocio)
  WHERE lc.idorigen > 0 AND lc.idgrupo > 0 AND lc.idsocio > 0 AND
        p.idsector = id_sector AND lc.fechalimite >= fecha_hoy AND
        (lc.idproducto = p_idproducto OR lc.idproducto = 39999)
  ORDER BY lc.limite DESC LIMIT 1;
  IF NOT FOUND OR limite_credito IS NULL OR limite_credito = 0 THEN
    RAISE NOTICE 'NO HAY DATOS DEL LIMITE DE CREDITO PARA ESTE GRUPO DE CLIENTES !!';
    RETURN NULL;
  END IF;

  -- SI EL PRESTAMO ACTUAL QUE SE EVALUA YA ESTA CAPTURADO DESDE ANTES, SE DEBE
  -- CONSIDERAR PARA EL TOTAL DE LOS PRESTAMOS, PORQUE SI ES APENAS UNA APERTURA
  -- SE DEBE SUMAR EL MONTO AL TOTAL DE LOS RPESTAMOS --------------------------

  ya_existe := FALSE;
  SELECT INTO r_aux *
  FROM (  SELECT * FROM auxiliares
          WHERE idorigen = p_idorigen AND idgrupo = p_idgrupo AND
                idsocio = p_idsocio AND idorigenp = p_idorigenp AND
                idproducto = p_idproducto AND idauxiliar = p_idauxiliar
        UNION
          SELECT * FROM auxiliares_ext
          WHERE idorigen = p_idorigen AND idgrupo = p_idgrupo AND
                idsocio = p_idsocio AND idorigenp = p_idorigenp AND
                idproducto = p_idproducto AND idauxiliar = p_idauxiliar) AS aux;
  IF FOUND THEN ya_existe := TRUE; END IF;

  -- MONTO DE LOS PRESTAMOS CAPTURADOS ---
  monto_grupo := 0.0;
  SELECT INTO monto_grupo SUM(a.montosolicitado)
  FROM auxiliares a INNER JOIN personas p USING (idorigen,idgrupo,idsocio)
       INNER JOIN productos pr USING(idproducto)
  WHERE a.idorigenp > 0 AND a.idproducto > 0 AND a.idauxiliar > 0 AND
        pr.tipoproducto = 2 AND p.idsector = id_sector AND a.estatus < 2 AND
        a.fechaape BETWEEN (fecha_hoy - 1) AND fecha_hoy;
  IF NOT FOUND OR monto_grupo IS NULL THEN monto_grupo := 0; END IF;
  monto_grupo := monto_grupo + (CASE WHEN ya_existe THEN 0 ELSE p_monto END);

  -- MONTO DE LOS PRESTAMOS ACTIVOS ---
  montox := 0.0;
  SELECT INTO montox SUM(a.montoprestado)
  FROM auxiliares a INNER JOIN personas p USING (idorigen,idgrupo,idsocio)
       INNER JOIN productos pr USING(idproducto)
  WHERE a.idorigenp > 0 AND a.idproducto > 0 AND a.idauxiliar > 0 AND
        pr.tipoproducto = 2 AND p.idsector = id_sector AND a.estatus = 2;
  IF NOT FOUND OR montox IS NULL THEN montox := 0; END IF;
  monto_grupo := monto_grupo + montox;

  IF limite_credito < monto_grupo THEN
    px1 := 'EL MONTO DE LOS PRESTAMOS DEL GRUPO ('||
           TRIM(TO_CHAR(monto_grupo,'999,999,999.99'))||
           ') ES MAYOR AL LIMITE ('||
           TRIM(TO_CHAR(limite_credito,'999,999,999.99'))||')';
    RETURN px1;
  END IF;

  RETURN NULL;
END;
$$ language 'plpgsql';

--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
/*
Funcion:
 sai_abonar_prestamos_genera_sobrantes_faltantes_gen_pol (P1,P2)

P1: Nombre del archivo que contiene el monto a abonar de cada uno de los prestamos.
    El layout es igual al de el "generador de polizas".
    Ejemplo:
     >  idcuenta|idorigenp|idproducto|idauxiliar|ca|importe
     >  ----------------------------------------------------
     >  0|35201|30102|275289|1|500.00
     >  0|35201|30102|275289|1|500.00
     >  0|35201|30102|275289|1|500.00
     >  20101040168|0|0|0|0|1500.00

P2: Concepto de la poliza.
    Puede llevar un concepto personalizado o NULL para un concepto predeterminado.
    Ejemplo:
     >  ABONOS A PRESTAMOS AL DIA: 05/05/2015, LEIDOS DEL ARCHIVO: /tmp/fulano_de_tal.txt_MODIFICADO (COMPLETANDO
         FALTANTE Y GUARDANDO SOBRANTE DE AMORTIZACIONES CORRESPONDIENTES, HACIA CUENTAS DE PASO TIPO AHORRO)

Objetivo:
 - Analizar el listado de abonos a prestamos.
 - Consulta el monto exacto (el debe ser) a la fecha.
 - Segun el monto exacto:
     * Si falta por abonar, toma del saldo del folio repositorio (tipo ahorro) correspondiente al cliente.
     * Si sobra, el importe sobrante, lo guarda a dicho folio correspondiente.
 - Modifica el importe de los prestamos, para tratar de abonar lo mas exacto que se pueda.
 - Simula estos movimientos, insertando en el archivo (listado de abonos a prestamos) cargos o abonos,
   segun sea el caso, de los folios repositorios de tipo ahorro.
 - Del archivo original, realiza otra copia con el mismo nombre, pero agregando al final la frase "_MODIFICADO",
   enviandolo al dir. /tmp del serv. de B.D.
 - El archivo modificado, se aplica automaticamente al Generador de Polizas.

---------------------------------------------------------------------------------------------------------
Funcion:
 sai_abona_sobrantes_de_abonos_de_prestamos_gen_pol()

Objetivo:
 - Funcion ejecutada al final de mes, como proceso masivo (proceso automatico).
 - A final de mes, busca los folios de los repositorios de aquellos que tengan
   saldo correspondiente a sobrantes antiguos. Abona estos sobrantes, a los
   prestamos correspondientes, con la misma regla, de no sobrepasar el monto exacto.
*/
--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- --- ABONA AL PRESTAMO, LO QUE HAY EN LOS REPOSITORIOS, UZADO AL FINAL DEL MES
create or replace function
sai_abona_sobrantes_de_abonos_de_prestamos_gen_pol()
  returns integer as $$
declare

  r_paso                      record;
  r_aux_ah                    record;
  r_aux_pr                    record;
  r_ccc                       record;
  r_ref                       record;
  x_fecha_hoy                 date;
  x_aux                       text;
  x_monto_io                  numeric;
  x_monto_im                  numeric;
  x_iva_io                    numeric;
  x_iva_im                    numeric;
  x_monto_vencido             numeric;
  x_proximoabono              numeric;
  x_comision_np               numeric;
  x_monto_seguro_hip          numeric;
  x_monto_comision_venc       numeric;
  x_monto_fijo_comision_venc  numeric;
  x_primera_vez               boolean;
  x_nom_arch                  varchar;
  x_sesion                    varchar;
  x_abonar                    numeric;
  x_suma                      numeric;
  x_cual_comision             integer;
  x_diasvencidos              integer;
  x_idusuario                 integer;

begin
  select into x_fecha_hoy date(fechatrabajo)
  from        origenes
  limit       1;

  -- Detecta el idusuario que esta ejecutando este mugrero...
  select into x_idusuario idusuario
    from      usuarios
   where      sai_texto1_like_texto2 (text(pg_backend_pid()),NULL,
                                      sai_lista_procpids_conectados(idusuario),',') > 0;
  if not found then  -- Por si alguna razon no encontro al condenado usuario, usa el sonso del 999
    x_idusuario := 999;
  end if;

  -- Crea una tabla temporal similar a movimientos_ca_paralelo, para no moverle nada.
  drop table if exists movimientos_ca_paralelo;
  create temp
   table movimientos_ca_paralelo as select * from movimientos_ca limit 1;
  delete from movimientos_ca_paralelo;

  x_primera_vez := TRUE;

  for r_paso in select   *
                from     tablas
                where    idtabla = 'sobrante_abonos_prestamos'
                order by idtabla,idelemento::integer
  loop
    for r_aux_ah in select *
                    from   auxiliares
                    where  idproducto = r_paso.dato1::integer and saldo > 0
    loop
      select into r_aux_pr *
      from        auxiliares
      where       idproducto = r_paso.idelemento::integer and
                  idorigen = r_aux_ah.idorigen and idgrupo = r_aux_ah.idgrupo and
                  idsocio = r_aux_ah.idsocio and saldo > 0;
      if found then
        x_aux := sai_auxiliar(r_aux_pr.idorigenp,r_aux_pr.idproducto,r_aux_pr.idauxiliar,x_fecha_hoy);

        x_monto_vencido   := sai_token(5,x_aux,'|');
        x_monto_io        := sai_token(7,x_aux,'|');
        x_proximoabono    := sai_token(12,x_aux,'|');
        x_monto_im        := sai_token(16,x_aux,'|');
        x_iva_io          := sai_token(18,x_aux,'|');
        x_iva_im          := sai_token(19,x_aux,'|');
        x_comision_np     := sai_token(22,x_aux,'|');

        x_monto_seguro_hip := 0;
        if x_proximoabono > 0 then
          select into x_monto_seguro_hip coalesce(sum(apagar+ivaapagar),0)
          from        sai_prestamos_hipotecarios_calcula_seguro_a_pagar (r_aux_pr.idorigenp,
                        r_aux_pr.idproducto, r_aux_pr.idauxiliar, x_fecha_hoy);
        end if;

        x_monto_comision_venc       := 0;
        x_monto_fijo_comision_venc  := 0;
        if x_diasvencidos > 0 then
          x_cual_comision := sai_cual_comision(r_aux_pr.idproducto,x_diasvencidos);

          if x_cual_comision > 0 then
            select into r_ccc *
            from        sai_calculos_de_comision_cobranza(r_aux_pr.idorigenp,
                          r_aux_pr.idproducto, r_aux_pr.idauxiliar);
            if found then
              x_monto_comision_venc       := r_ccc.monto_comision;
              x_monto_fijo_comision_venc  := case when x_cual_comision = 1 or x_cual_comision = 13
                                                  then r_ccc.monto_comision
                                                  else r_ccc.monto_fijo
                                             end;
            end if;

            -- POR EL PROGRAMA S4MODICOMCOBRANZA.C --
            select into r_ref text(referencia)::numeric as monto_fijo
            from        referenciasp
            where       idorigenp = r_aux_pr.idorigenp and idproducto = r_aux_pr.idproducto and
                        idauxiliar = r_aux_pr.idauxiliar and tiporeferencia = 9;
            if found then
              x_monto_comision_venc = r_ref.monto_fijo;
            end if;
          end if;
        end if;

        x_abonar := 0;
        x_suma = x_monto_vencido       + x_monto_io     + x_iva_io           + x_monto_im    +
                 x_iva_im              + x_proximoabono + x_monto_seguro_hip + x_comision_np +
                 x_monto_comision_venc;
        if x_suma > 0 then
          if x_primera_vez then
            delete from movimientos_ca_paralelo;
            x_primera_vez := FALSE;
          end if;
          x_abonar := r_aux_ah.saldo;
          if x_suma < r_aux_ah.saldo then
            x_abonar := x_suma;
          end if;
        end if;

        if x_abonar > 0 then
          -- TENIENDO LOS DATOS COMPLETOS, ABONA EL SOBRANTE DEL PRODUCTO AHORRO AL PRESTAMO CORRESPONDIENTE:
          insert into movimientos_ca_paralelo
                      (idcuenta, idorigenp, idproducto, idauxiliar, ca, importe)
          values      ('0', r_aux_ah.idorigenp, r_aux_ah.idproducto, r_aux_ah.idauxiliar, 0,
                      x_abonar);
          insert into movimientos_ca_paralelo
                      (idcuenta, idorigenp, idproducto, idauxiliar, ca, importe)
          values      ('0', r_aux_pr.idorigenp, r_aux_pr.idproducto, r_aux_pr.idauxiliar, 1,
                      x_abonar);
        end if;
      else
        --Informar que el prestamo ya no existe o fue pagado!!
      end if;
    end loop;
  end loop;

  if not x_primera_vez then
    x_nom_arch := '/tmp/abono_de_residuos_de_sobrantes_de_abonos_prestamos_'||
                  replace(sai_fecha_mes_con_letra(x_fecha_hoy),'/','_');
    execute 'copy movimientos_ca_paralelo (idcuenta, idorigenp, idproducto, idauxiliar, ca, importe) to '''||
            x_nom_arch||''' delimiter ''|''';

    x_sesion := pg_backend_pid()::text||'-'||trim(to_char(x_fecha_hoy,'ddmmyy'));

    for r_paso in select sai_generador_de_polizas (x_idusuario, x_sesion, TRUE,
                                                   'ABONO DE SOBRANTES DE ABONOS ANTERIORES ACUMULADOS',
                                                   x_nom_arch) as k
    loop
      raise notice 'Poliza: %', r_paso.k;
    end loop;

  end if;

  drop table if exists movimientos_ca_paralelo;

  return 1;
end;
$$ language 'plpgsql';

-- FUNCION PRINCIPAL: -----------------------------------------------------
create or replace function
sai_abonar_prestamos_genera_sobrantes_faltantes_gen_pol (text,text)
  returns integer as $$
declare
  p_nomarch                   alias for $1;
  p_concepto                  alias for $2;
  r_mov                       record;
  r_ccc                       record;
  r_ref                       record;
  r_aux                       record;
  r_aux_ah                    record;
  r_paso                      record;
  r_sobpr                     record;
  x_fecha_hoy                 date;
  x_aux                       text;
  x_monto_io                  numeric;
  x_monto_im                  numeric;
  x_iva_io                    numeric;
  x_iva_im                    numeric;
  x_monto_vencido             numeric;
  x_proximoabono              numeric;
  x_comision_np               numeric;
  x_monto_seguro_hip          numeric;
  x_monto_comision_venc       numeric;
  x_monto_fijo_comision_venc  numeric;
  x_mat                       _text;
  x_idauxiliar_ah             integer;
  x_idorigenp_ah              integer;
  x_idproducto_ah             integer;
  x_debeser                   numeric;
  x_cual_comision             integer;
  x_diasvencidos              integer;
  x_nom_arch                  varchar;
  x_sesion                    varchar;
  x_concepto                  text;
  x_idusuario                 integer;
  x_cont                      integer;
  x_found_in_r_aux_ah         boolean;
  x_acum_debeser              numeric;
  x_acum_importe              numeric;
  x_dif                       numeric;
  x_ca                        integer;
  x_importe                   numeric;
  x_suma_sobrante             numeric;
  x_modif_importe             numeric;
  x_sobrante                  boolean;
  x_inserta_registro          boolean;

begin
  select into x_fecha_hoy date(fechatrabajo)
  from        origenes
  limit       1;

  -- Detecta el idusuario que esta ejecutando este mugrero...
  select into x_idusuario idusuario
    from      usuarios
   where      sai_texto1_like_texto2 (text(pg_backend_pid()),NULL,
                                      sai_lista_procpids_conectados(idusuario),',') > 0;
  if not found then  -- Por si alguna razon no encontro al condenado usuario, usa el sonso del 999
    x_idusuario := 999;
  end if;

  -- Crea una tabla temporal similar a movimientos_ca, para no moverle nada.
  drop table if exists movimientos_ca_paralelo;
  create temp
   table movimientos_ca_paralelo as select * from movimientos_ca limit 1;
  delete from movimientos_ca_paralelo;

  -- Por si el usuario son... no le puso al inicio /tmp
  x_nom_arch := '';
  if p_nomarch not like '/tmp/%' then
    x_nom_arch := '/tmp/';
  end if;
  x_nom_arch := x_nom_arch||p_nomarch;

  -- Carga el archivo
  execute 'copy movimientos_ca_paralelo (idcuenta, idorigenp, idproducto, idauxiliar, ca, importe) from '''||
            x_nom_arch||''' delimiter ''|''';

  select into x_cont count(*)
  from        movimientos_ca_paralelo;

  if x_cont = 0 then
    raise exception 'NO ENCONTRO REGISTROS QUE PROCESAR, REVISE EL ARCHIVO: %', x_nom_arch;
  end if;

  x_cont := 0;
  for r_aux in select     a.idorigen,a.idgrupo,a.idsocio
               from       movimientos_ca_paralelo as mo
               inner join auxiliares as a
               using      (idorigenp,idproducto,idauxiliar)
               inner join productos as p
               on         (p.idproducto = a.idproducto)
               where      p.tipoproducto = 2 and mo.idcuenta = '0' and mo.ca = 1
               group by   a.idorigen,a.idgrupo,a.idsocio
               order by   idorigen,idgrupo,idsocio
  loop
    raise notice '--- soc: %-%-%',r_aux.idorigen, r_aux.idgrupo, r_aux.idsocio;

    for r_sobpr in select   idelemento::integer as idproducto_pr, dato1::integer as idproducto_ah
                   from     tablas
                   where    idtabla = 'sobrante_abonos_prestamos'
                   order by idelemento::integer
    loop
      ---------------------------------------------------------------------------------------------
      ---------------------------------------------------------------------------------------------

      x_acum_debeser  := 0;
      x_acum_importe  := 0;
      x_suma_sobrante := 0;

      for r_mov in select     mo.*,sai_auxiliar(a.idorigenp,a.idproducto,a.idauxiliar,x_fecha_hoy) as aux
                   from       movimientos_ca_paralelo as mo
                   inner join auxiliares as a
                   using      (idorigenp,idproducto,idauxiliar)
                   where      idorigen = r_aux.idorigen and idgrupo = r_aux.idgrupo and a.estatus = 2 and
                              idsocio = r_aux.idsocio and idproducto = r_sobpr.idproducto_pr
      loop
        raise notice '----- prod_sob: %',r_sobpr.idproducto_pr;
        raise notice '------- aux: %-%-%',r_mov.idorigenp,r_mov.idproducto,r_mov.idauxiliar;

        x_monto_vencido   := sai_token(5,r_mov.aux,'|');
        x_monto_io        := sai_token(7,r_mov.aux,'|');
        x_proximoabono    := sai_token(12,r_mov.aux,'|');
        x_monto_im        := sai_token(16,r_mov.aux,'|');
        x_iva_io          := sai_token(18,r_mov.aux,'|');
        x_iva_im          := sai_token(19,r_mov.aux,'|');
        x_comision_np     := sai_token(22,r_mov.aux,'|');

        x_monto_seguro_hip := 0;
        if x_proximoabono > 0 then
          select into x_monto_seguro_hip coalesce(sum(apagar+ivaapagar),0)
          from        sai_prestamos_hipotecarios_calcula_seguro_a_pagar (r_mov.idorigenp,
                        r_mov.idproducto, r_mov.idauxiliar, x_fecha_hoy);
        end if;

        x_monto_comision_venc       := 0;
        x_monto_fijo_comision_venc  := 0;
        if x_diasvencidos > 0 then
          x_cual_comision := sai_cual_comision(r_mov.idproducto,x_diasvencidos);

          if x_cual_comision > 0 then
            select into r_ccc *
            from        sai_calculos_de_comision_cobranza(r_mov.idorigenp,
                          r_mov.idproducto, r_mov.idauxiliar);
            if found then
              x_monto_comision_venc       := r_ccc.monto_comision;
              x_monto_fijo_comision_venc  := case when x_cual_comision = 1 or x_cual_comision = 13
                                                  then r_ccc.monto_comision
                                                  else r_ccc.monto_fijo
                                             end;
            end if;

            -- POR EL PROGRAMA S4MODICOMCOBRANZA.C --
            select into r_ref text(referencia)::numeric as monto_fijo
            from        referenciasp
            where       idorigenp = r_mov.idorigenp and idproducto = r_mov.idproducto and
                        idauxiliar = r_mov.idauxiliar and tiporeferencia = 9;
            if found then
              x_monto_comision_venc = r_ref.monto_fijo;
            end if;
          end if;
        end if;

        x_debeser = x_monto_vencido       + x_monto_io     + x_iva_io           + x_monto_im    +
                    x_iva_im              + x_proximoabono + x_monto_seguro_hip + x_comision_np +
                    x_monto_comision_venc;

        x_acum_debeser := x_acum_debeser + x_debeser;
        x_acum_importe := x_acum_importe + r_mov.importe;

        x_dif := r_mov.importe - x_debeser;
        if x_dif > 0 then
          x_suma_sobrante := x_suma_sobrante + x_dif;
        end if;

      end loop;
      continue when x_acum_importe = 0;

      ---------------------------------------------------------------------------------------------
      ---------------------------------------------------------------------------------------------

      x_dif := x_acum_importe - x_acum_debeser;

      raise notice '--------- (x_acum_importe: %) - (x_acum_debeser: %) = (x_dif: %)',x_acum_importe,x_acum_debeser,x_dif;

      if x_dif != 0 then
        -- BUSCA SI YA EXISTE UN O-P-A DEL PROD. SOBRANTE
        x_sobrante := (x_dif > 0);
        x_inserta_registro := TRUE;

        select into r_aux_ah *
        from        auxiliares
        where       idorigen = r_aux.idorigen and idgrupo = r_aux.idgrupo and
                    idsocio = r_aux.idsocio and idproducto = r_sobpr.idproducto_ah;
        if not found then -- SI NO EXISTE
          if x_sobrante then  -- SOBRANTE
            x_mat := array[text(r_aux.idorigen)        , text(r_aux.idgrupo)  ,
                           text(r_aux.idsocio)         , text(r_aux.idorigen) ,
                           text(r_sobpr.idproducto_ah) , text(x_fecha_hoy)    ,
                           text(x_idusuario)           , text(0)];
            x_idorigenp_ah  := r_aux.idorigen;
            x_idproducto_ah := r_sobpr.idproducto_ah;
            x_idauxiliar_ah := sai_ahorro_crea_apertura (x_mat);
            x_ca := 1;
            x_importe := x_dif;
          else                -- FALTANTE
            x_inserta_registro := FALSE;
          end if;
        else
          if x_sobrante then  -- SOBRANTE
            x_ca := 1;
            x_importe := x_dif;
          else                -- FALTANTE
            x_ca := 0;
            if r_aux_ah.saldo <= 0 then
              x_inserta_registro := FALSE;
            else
              if r_aux_ah.saldo <= abs(x_dif) then
                x_importe := r_aux_ah.saldo;
              else
                x_importe := abs(x_dif);
              end if;
              x_suma_sobrante := x_suma_sobrante + x_importe;
            end if;
          end if;
          x_idorigenp_ah  := r_aux_ah.idorigenp;
          x_idproducto_ah := r_aux_ah.idproducto;
          x_idauxiliar_ah := r_aux_ah.idauxiliar;
        end if;

        if x_inserta_registro then
          raise notice '--------- INSERT INTO: %-%-%, x_ca: %, x_importe: %',x_idorigenp_ah,x_idproducto_ah,x_idauxiliar_ah,x_ca, x_importe;
          insert into movimientos_ca_paralelo
                      (idcuenta,idorigenp,idproducto,idauxiliar,ca,importe,idorigena,paquete,
                       concepto_paquete,tipo_poliza_paquete)
          values      (r_mov.idcuenta,x_idorigenp_ah,x_idproducto_ah,x_idauxiliar_ah,x_ca,x_importe,
                       r_mov.idorigena,r_mov.paquete,r_mov.concepto_paquete,r_mov.tipo_poliza_paquete);
        end if;
      end if;

      ---------------------------------------------------------------------------------------------
      ---------------------------------------------------------------------------------------------

      raise notice '--------- x_suma_sobrante: %',x_suma_sobrante;
      for r_mov in select     mo.*,sai_auxiliar(idorigenp,idproducto,idauxiliar,x_fecha_hoy) as aux
                   from       movimientos_ca_paralelo as mo
                   inner join auxiliares as a
                   using      (idorigenp,idproducto,idauxiliar)
                   where      idorigen = r_aux.idorigen and idgrupo = r_aux.idgrupo and estatus = 2 and
                              idsocio = r_aux.idsocio and idproducto = r_sobpr.idproducto_pr
      loop

        x_monto_vencido   := sai_token(5,r_mov.aux,'|');
        x_monto_io        := sai_token(7,r_mov.aux,'|');
        x_proximoabono    := sai_token(12,r_mov.aux,'|');
        x_monto_im        := sai_token(16,r_mov.aux,'|');
        x_iva_io          := sai_token(18,r_mov.aux,'|');
        x_iva_im          := sai_token(19,r_mov.aux,'|');
        x_comision_np     := sai_token(22,r_mov.aux,'|');

        x_monto_seguro_hip := 0;
        if x_proximoabono > 0 then
          select into x_monto_seguro_hip coalesce(sum(apagar+ivaapagar),0)
          from        sai_prestamos_hipotecarios_calcula_seguro_a_pagar (r_mov.idorigenp,
                        r_mov.idproducto, r_mov.idauxiliar, x_fecha_hoy);
        end if;

        x_monto_comision_venc       := 0;
        x_monto_fijo_comision_venc  := 0;
        if x_diasvencidos > 0 then
          x_cual_comision := sai_cual_comision(r_mov.idproducto,x_diasvencidos);

          if x_cual_comision > 0 then
            select into r_ccc *
            from        sai_calculos_de_comision_cobranza(r_mov.idorigenp,
                          r_mov.idproducto, r_mov.idauxiliar);
            if found then
              x_monto_comision_venc       := r_ccc.monto_comision;
              x_monto_fijo_comision_venc  := case when x_cual_comision = 1 or x_cual_comision = 13
                                                  then r_ccc.monto_comision
                                                  else r_ccc.monto_fijo
                                             end;
            end if;

            -- POR EL PROGRAMA S4MODICOMCOBRANZA.C --
            select into r_ref text(referencia)::numeric as monto_fijo
            from        referenciasp
            where       idorigenp = r_mov.idorigenp and idproducto = r_mov.idproducto and
                        idauxiliar = r_mov.idauxiliar and tiporeferencia = 9;
            if found then
              x_monto_comision_venc = r_ref.monto_fijo;
            end if;
          end if;
        end if;

        x_debeser = x_monto_vencido       + x_monto_io     + x_iva_io           + x_monto_im    +
                    x_iva_im              + x_proximoabono + x_monto_seguro_hip + x_comision_np +
                    x_monto_comision_venc;

        -- SI NO HAY QUE ABONAR, POR ENDE EL IMPORTE PASA COMO SOBRANTE,
        -- PERO EL REGISTRO DE PRESTAMO SE ELIMINA
        raise notice '------- aux(2): %-%-%,  importe: %,  debeser: %',r_mov.idorigenp,r_mov.idproducto,r_mov.idauxiliar, r_mov.importe, x_debeser;
        if x_debeser <= 0 then
          raise notice '--------- DELETE...';
          delete
          from   movimientos_ca_paralelo
          where  idorigenp = r_mov.idorigenp and idproducto = r_mov.idproducto and
                 idauxiliar = r_mov.idauxiliar;
          continue;
        end if;

        x_dif := r_mov.importe - x_debeser;

        continue when x_dif = 0;

        if x_dif > 0 then -- SOBRANTE ??
          x_modif_importe := x_debeser;  -- TOMA DEBESER
        else              -- FALTANTE ??
          continue when x_suma_sobrante = 0;
          if x_suma_sobrante > abs(x_dif) then
            x_dif := abs(x_dif);
          else
            x_dif := x_suma_sobrante;
          end if;
          x_suma_sobrante := x_suma_sobrante - x_dif;

          x_modif_importe := r_mov.importe + x_dif;
        end if;

        raise notice '--------- UPDATE: %', x_modif_importe;
        update movimientos_ca_paralelo
        set    importe = x_modif_importe
        where  idorigenp = r_mov.idorigenp and idproducto = r_mov.idproducto and
               idauxiliar = r_mov.idauxiliar;
      end loop;
    end loop;
  end loop;

  raise notice '--- ANALIZA PRESTAMOS QUE NO ESTAN ACTIVOS...';
  for r_aux in select     a.idorigen,a.idgrupo,a.idsocio,mo.*
               from       movimientos_ca_paralelo as mo
               inner join v_auxiliares as a
               using      (idorigenp,idproducto,idauxiliar)
               inner join productos as p
               on         (p.idproducto = a.idproducto)
               where      p.tipoproducto = 2 and mo.idcuenta = '0' and mo.ca = 1 and
                          a.estatus != 2
  loop
    raise notice '----- soc: %-%-%, aux: %-%-%, importe: %',
                 r_aux.idorigen, r_aux.idgrupo, r_aux.idsocio, r_aux.idorigenp, r_aux.idproducto,
                 r_aux.idauxiliar, r_aux.importe;
    select into r_sobpr idelemento::integer as idproducto_pr, dato1::integer as idproducto_ah
    from        tablas
    where       idtabla = 'sobrante_abonos_prestamos' and idelemento::integer = r_aux.idproducto;
    if found then
      select into r_aux_ah *
      from        auxiliares
      where       idorigen = r_aux.idorigen and idgrupo = r_aux.idgrupo and
                  idsocio = r_aux.idsocio and idproducto = r_sobpr.idproducto_ah;
      if not found then -- SI NO EXISTE
        x_mat := array[text(r_aux.idorigen)        , text(r_aux.idgrupo)  ,
                       text(r_aux.idsocio)         , text(r_aux.idorigen) ,
                       text(r_sobpr.idproducto_ah) , text(x_fecha_hoy)    ,
                       text(x_idusuario)           , text(0)];
        x_idorigenp_ah  := r_aux.idorigen;
        x_idproducto_ah := r_sobpr.idproducto_ah;
        x_idauxiliar_ah := sai_ahorro_crea_apertura (x_mat);
      else
        x_idorigenp_ah  := r_aux_ah.idorigenp;
        x_idproducto_ah := r_aux_ah.idproducto;
        x_idauxiliar_ah := r_aux_ah.idauxiliar;
      end if;

      select into r_mov *
      from        movimientos_ca_paralelo
      where       idorigenp = x_idorigenp_ah and idproducto = x_idproducto_ah and
                  idauxiliar = x_idauxiliar_ah;
      if found then
        x_ca := 1;
        x_modif_importe := r_mov.importe + r_aux.importe;  -- impte_ah + impte_pr
        if r_mov.ca = 0 then
          x_modif_importe := (r_mov.importe * -1) + r_aux.importe;  -- (-)impte_ah + impte_pr <-- por ser cargo el mov_ah
          if x_modif_importe != 0 then
            x_ca := case when x_modif_importe < 0
                         then 0
                         else 1
                    end;
            x_modif_importe := abs(x_modif_importe);
          else
            delete
            from   movimientos_ca_paralelo
            where  idorigenp = x_idorigenp_ah and idproducto = x_idproducto_ah and
                   idauxiliar = x_idauxiliar_ah;
          end if;
        end if;
        raise notice '--------- UPDATE: %-%-%, x_ca: %, x_importe: %',x_idorigenp_ah,x_idproducto_ah,x_idauxiliar_ah,x_ca,x_modif_importe;
        update movimientos_ca_paralelo
        set    ca = x_ca, importe = x_modif_importe
        where  idorigenp = x_idorigenp_ah and idproducto = x_idproducto_ah and
               idauxiliar = x_idauxiliar_ah;
      else
        raise notice '--------- INSERT INTO: %-%-%, x_ca: %, x_importe: %',x_idorigenp_ah,x_idproducto_ah,x_idauxiliar_ah,1,r_aux.importe;
        insert into movimientos_ca_paralelo
                    (idcuenta,idorigenp,idproducto,idauxiliar,ca,importe,idorigena,paquete,
                     concepto_paquete,tipo_poliza_paquete)
        values      (0,x_idorigenp_ah,x_idproducto_ah,x_idauxiliar_ah,1,r_aux.importe,
                     r_aux.idorigena,r_aux.paquete,r_aux.concepto_paquete,r_aux.tipo_poliza_paquete);
      end if;

      delete
      from   movimientos_ca_paralelo
      where  idorigenp = r_aux.idorigenp and idproducto = r_aux.idproducto and
             idauxiliar = r_aux.idauxiliar;
    end if;
  end loop;

  x_nom_arch := x_nom_arch||'_MODIFICADO';
  execute 'copy movimientos_ca_paralelo (idcuenta, idorigenp, idproducto, idauxiliar, ca, importe) to '''||
          x_nom_arch||''' delimiter ''|''';

  x_sesion := pg_backend_pid()::text||'-'||trim(to_char(x_fecha_hoy,'ddmmyy'));

  if p_concepto is NULL or p_concepto = '' then
    x_concepto := 'ABONOS A PRESTAMOS AL DIA: '||x_fecha_hoy::text||', LEIDOS DEL ARCHIVO: '||
                  x_nom_arch||
                  case when x_cont > 0
                       then ' (COMPLETANDO FALTANTE Y GUARDANDO SOBRANTE DE AMORTIZACIONES CORRESPONDIENTES, HACIA CUENTAS DE PASO TIPO AHORRO)'
                       else ''
                  end;
  else
    x_concepto := p_concepto;
  end if;

  for r_paso in select sai_generador_de_polizas (x_idusuario, x_sesion, TRUE, x_concepto, x_nom_arch) as k
  loop
    raise notice 'Poliza: %', r_paso.k;
  end loop;

  drop table if exists movimientos_ca_paralelo;

  return 1;
end;
$$ language 'plpgsql';

/*-----------------------------------------------------------------------------------------------------
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Regresa la distribucion del "monto capturado" al abonar un prestamo (like Ventanilla / Traspasos) ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Sintaxis:
 - Funcion: idorigenp, idproducto, idauxiliar, fecha, monto
 - Retorno: Seguro hipotecario | Comision cobranza | IM | Iva IM | IO | Iva IO | A Capital

Ej.
data_base_x=#  select sai_distribucion_prestamo(30414,30302,2503,'31/07/2015',1000.00);

     sai_distribucion_prestamo
------------------------------------
 29.60|40.00|16.86|2.70|59.98|9.60|841.26
(1 fila)
-----------------------------------------------------------------------------------------------------*/
create or replace function
sai_distribucion_prestamo (integer,integer,integer,date,numeric) returns text as $$
begin
  return sai_distribucion_prestamo ($1,$2,$3,$4,$5,NULL);
end;
$$ language 'plpgsql';

create or replace function
sai_distribucion_prestamo (integer,integer,integer,date,numeric,text)
returns text as $$
declare
  p_idorigenp   alias for $1;
  p_idproducto  alias for $2;
  p_idauxiliar  alias for $3;
  p_fecha       alias for $4;
  p_monto       alias for $5;
  p_aux         alias for $6;
  r_aux               record;
  r_prod              record;
  r_amort             record;
  r_com               record;
  r_paso              record;
  msg_txt             text;
  paso                text;
  x_idorigen          integer;
  x_idgrupo           integer;
  x_idsocio           integer;
  x_idorigenp         integer;
  x_idproducto        integer;
  x_idauxiliar        integer;

  x_acapital          numeric;
  x_aio               numeric;
  x_aim               numeric;
  x_aivaio            numeric;
  x_aivaim            numeric;
  x_suma              numeric;
  tipo_dist           integer;
  prc_iva             numeric;
  io_x                numeric;
  x_acapital2         numeric;
  temp1               numeric;
  monto_fijo          numeric;
  x                   integer;
  y                   integer;
  pagos_adelantados   boolean;
  x_diasven           integer;
  x_monto_com         numeric;
  x_seguro_hip        numeric;
  x_cual_com          integer;
  x_aseg_hip          numeric;
  x_acomision         numeric;
  paso_fecha          date;

begin

  x_acapital := p_monto;

  select into r_aux *
         from auxiliares
        where idorigenp = p_idorigenp and
              idproducto = p_idproducto and
              idauxiliar = p_idauxiliar;
  if not found then
    raise exception 'NO EXISTE EL AUXILIAR: %-%-%', p_idorigenp, p_idproducto, p_idauxiliar;
    return NULL;
  end if;

  select into r_prod *
         from productos
        where idproducto = r_aux.idproducto;

  if p_aux is NULL or trim(p_aux) = '' then
    paso := sai_auxiliar(r_aux.idorigenp,r_aux.idproducto,r_aux.idauxiliar,NULL,p_fecha,0,FALSE,r_aux.idorigenp);
  else
    paso := p_aux;
  end if;

  x_idorigen    := r_aux.idorigen;
  x_idgrupo     := r_aux.idgrupo;
  x_idsocio     := r_aux.idsocio;
  x_idorigenp   := r_aux.idorigenp;
  x_idproducto  := r_aux.idproducto;
  x_idauxiliar  := r_aux.idauxiliar;
  x_aio         := 0;
  x_aim         := 0;
  x_aivaio      := 0;
  x_aivaim      := 0;
  x_diasven     := 0;
  x_aseg_hip    := 0;
  x_acomision   := 0;
  x_monto_com   := 0;

  x_aio         := sai_token(7,paso,'|');
  x_aim         := sai_token(16,paso,'|');
  x_aivaio      := sai_token(18,paso,'|');
  x_aivaim      := sai_token(19,paso,'|');
  x_diasven     := sai_token(4,paso,'|')::integer;

  -- SEGURO HIPOTECARIO -------------------------------
  select into x_seguro_hip coalesce(sum(apagar+ivaapagar),0)
  from        sai_prestamos_hipotecarios_calcula_seguro_a_pagar (r_aux.idorigenp, r_aux.idproducto, r_aux.idauxiliar, p_fecha);

  if x_seguro_hip > x_acapital then
    x_aseg_hip  := x_acapital;
    x_acapital  := 0;
  else
    x_aseg_hip  := x_seguro_hip;
    x_acapital  := x_acapital - x_seguro_hip;
  end if;

  -- COMISIONES ----------------------------------------
  select
  into   r_paso *
  from   tablas
  where  idtabla = 'param' and idelemento = 'nueva_comision_por_atraso';
  if found then
    select
    into   r_com *
    from   comision_por_atraso (r_aux.idorigenp, r_aux.idproducto, r_aux.idauxiliar, p_fecha, NULL);

    -- COMISION MONTO FIJO PERSONALIZADA MANUALMENTE ----
    if r_com.es_monto_fijo then
      if r_com.monto_comision > x_acapital then
        x_acomision := x_acapital;
        x_acapital  := 0;
      else
        x_acomision := r_com.monto_comision;
        x_acapital  := x_acapital - r_com.monto_comision;
      end if;
    end if;
  
    -- COMISION TASA Y MONTO FIJO POR TABLA CONFIG ------
    if not r_com.es_monto_fijo and r_com.tasa_comision > 0 then
      x_monto_com := x_acapital - round(x_acapital/(1+(r_com.tasa_comision/100)),2);
      --- Que no rebase al monto de comision total ---
      if x_monto_com > r_com.monto_comision then
        x_monto_com := r_com.monto_comision;
      end if;
      x_acapital = x_acapital - x_monto_com;
      if x_acapital <= 0 then
        x_acapital = 0;
      end if;
      x_acomision := x_monto_com;
    end if;
  
  else
    x_cual_com  := sai_cual_comision (r_aux.idproducto, x_diasven);
  
    select
    into   r_com *
    from   sai_calculos_de_comision_cobranza(r_aux.idorigenp, r_aux.idproducto, r_aux.idauxiliar);
  
    -- COMISION MONTO FIJO PERSONALIZADA MANUALMENTE ----
    if r_com.monto_fijo > 0 then
      if r_com.monto_fijo > x_acapital then
        x_acomision := x_acapital;
        x_acapital  := 0;
      else
        x_acomision := r_com.monto_fijo;
        x_acapital  := x_acapital - r_com.monto_fijo;
      end if;
    end if;
  
    -- COMISION TASA Y MONTO FIJO POR TABLA CONFIG ------
    if r_com.monto_fijo = 0 and r_com.tasa_comision > 0 then
      x_monto_com := x_acapital - round(x_acapital/(1+(r_com.tasa_comision/100)),2);
      --- Que no rebase al monto de comision total ---
      if x_monto_com > r_com.monto_comision then
        x_monto_com := r_com.monto_comision;
      end if;
      x_acapital = x_acapital - x_monto_com;
      if x_acapital <= 0 then
        x_acapital = 0;
      end if;
      x_acomision := x_monto_com;
    end if;
  end if;

  x_suma := x_aim + x_aivaim;
  if x_suma > x_acapital then
    x_aim       := x_acapital / ((r_prod.ivaim / 100) + 1);
    x_aivaim    := x_acapital - x_aim;
    x_acapital  := 0;
  else
    x_acapital  := x_acapital - x_suma;
  end if;

  if x_acapital > 0 then

    tipo_dist := 0;
    if r_aux.tipoamortizacion = 5 then
      select into tipo_dist int4(dato1)
      from tablas
      where lower(idtabla) = 'param' and
            lower(idelemento) = 'distribuye_abonos_hipotecarios';
      if not found then tipo_dist := 0; end if;
      if tipo_dist is null then tipo_dist := 0; end if;
    end if;

    -- PARA LAS AMORTIZACIONES HIPOTECARIAS, EL MONTO DEBE DISTRIBUIRSE --
    -- PRIMERO EN UN SOLO PAGO Y LUEGO EN LOS SIGUIENTES -----------------
    if tipo_dist = 1 then

      prc_iva := 0.0; prc_iva := r_prod.iva/100.0;
      x_acapital2:=0.0; x_aio:=0.0; x_aivaio:=0.0; monto_fijo:=0.0;

      if r_aux.tipoamortizacion = 5 then
        select into monto_fijo monto from monto_pagos_fijos
        where idorigenp=r_aux.idorigenp and idproducto=r_aux.idproducto and
              idauxiliar=r_aux.idauxiliar;
        if not found or monto_fijo is null then monto_fijo := 0; end if;
      end if;

      if monto_fijo > 0 then
        if no_usar_monto_pagos_fijos(r_aux.idorigenp, r_aux.idproducto,r_aux.idauxiliar, monto_fijo, r_prod.iva) then
          monto_fijo := 0;
        end if;
      end if;

      -- HAY QUE BUSCAR SI EL PRESTAMO TIENE PAGOS ADELANTADOS PARA EVITAR
      -- QUE SE COBREN INTERESES EN UN PAGO ADELANTADO, SOLO DEBE ABONARSE
      -- A CAPITAL -------------------------------------------------------
      pagos_adelantados := FALSE;
      for r_amort
      in  select   a1.vence, a1.abono, a1.io, idorigenp, idproducto, idauxiliar,
                   (a1.abono - a1.abonopag) as abono_a_pag,
                   (a1.io - a1.iopag)       as io_a_pag,
                   (case when idamortizacion > 1 and monto_fijo > 0
                         then round(((monto_fijo - a1.abono - a1.io) - a1.iopag*prc_iva), 2)
                         else round(((a1.io - a1.iopag)*prc_iva), 2)
                    end) as iva_io_a_pag
          from     amortizaciones as a1
          where    a1.idorigenp  = r_aux.idorigenp and a1.idproducto = r_aux.idproducto and
                   a1.idauxiliar = r_aux.idauxiliar and a1.abono != a1.abonopag and todopag = FALSE
          order by vence
      loop
        if x_acapital > 0 then
          -- Si el prestamo ya tiene PAGOS ADELANTADOS, no se ---
          -- considera el IO ni su IVA de los proximos pagos ----
          if r_amort.vence > p_fecha and not pagos_adelantados then
            select
            into     paso_fecha vence
            from     amortizaciones
            where    (idorigenp,idproducto,idauxiliar) =
                     (r_amort.idorigenp,r_amort.idproducto,r_amort.idauxiliar) and vence < r_amort.vence
            order by vence desc
            limit    1;
            if not found then
              pagos_adelantados := FALSE;
            else
              pagos_adelantados := (p_fecha > paso_fecha and p_fecha <= r_amort.vence) = FALSE;
            end if;
          end if;

          if not pagos_adelantados then
            if x_acapital > (r_amort.io_a_pag + r_amort.iva_io_a_pag) then
              x_aio       := x_aio      + r_amort.io_a_pag;
              x_aivaio    := x_aivaio   + r_amort.iva_io_a_pag;
              x_acapital  := x_acapital - (r_amort.io_a_pag + r_amort.iva_io_a_pag);
            else
              io_x        := round((x_acapital/(1+prc_iva)), 2);
              x_aio       := x_aio + io_x;
              x_aivaio    := x_aivaio + (x_acapital - io_x);
              x_acapital  := 0;
            end if;
          end if;  
          if x_acapital > 0 then
            if x_acapital >= r_amort.abono_a_pag then
              x_acapital2 := x_acapital2 + r_amort.abono_a_pag;
              x_acapital  := x_acapital  - r_amort.abono_a_pag;
            else
              exit when pagos_adelantados;
              x_acapital2 := x_acapital2 + x_acapital;
              x_acapital  := 0;
            end if;
          end if;

          exit when x_acapital <= 0;
        end if;
      end loop;

      -- SI LA DIFERENCIA DESPUES DE DISTRIBUIR EL PAGO ES MENOR O ---
      -- IGUAL A 0.02, SE AJUSTA CON EL IVA DEL IO, PERO SE DEBE -----
      -- CONSIDERAR TAMBIEN SI HAY IVA, Y QUE SI DEBE RESTARSE LA ----
      -- DIFERENCIA EL IVA SEA IGUAL O MAYOR A 0.02 ------------------
      -- (JFPA, 12/FEBRERO/2016) -------------------------------------
      if x_acapital != 0 and abs(x_acapital) <= 0.02 and x_aivaio > 0 then
        if x_acapital < 0 then
          if x_aivaio >= 0.02 then
            x_aivaio := x_aivaio + x_acapital;
            x_acapital := 0.0;
          end if;
        else
          x_aivaio := x_aivaio + x_acapital;
          x_acapital := 0.0;
        end if;
      end if;

      x_acapital := x_acapital2;

    else
      x_suma := x_aio + x_aivaio;
      if x_suma > x_acapital then
        x_aio      := round(x_acapital / ((r_prod.iva / 100) + 1), 2);
        x_aivaio   := x_acapital - x_aio;
        x_acapital := 0;
      else
        x_acapital  := x_acapital - x_suma;
      end if;
    end if;
  else
    x_aio := 0.0; x_aivaio := 0.0;
  end if;

  if x_acapital > r_aux.saldo then
    x_acapital := r_aux.saldo;
  end if;

  return x_aseg_hip   ::text||'|'||
         x_acomision  ::text||'|'||
         x_aim        ::text||'|'||
         x_aivaim     ::text||'|'||
         x_aio        ::text||'|'||
         x_aivaio     ::text||'|'||
         x_acapital   ::text;
end;
$$ language 'plpgsql';


create or replace function
sai_folio_fecha_buro_consulta (integer,integer,integer,integer,integer,integer,date)
returns varchar as $$
declare
  p_idorigen      alias for $1;
  p_idgrupo       alias for $2;
  p_idsocio       alias for $3;
  p_idorigenp     alias for $4;
  p_idproducto    alias for $5;
  p_idauxiliar    alias for $6;
  p_fechaprestamo alias for $7;
  folio_burox     varchar;
  fecha_burox     date;
  vigencia        integer;
begin
    folio_burox = NULL; fecha_burox := NULL;

    select
    into   folio_burox, fecha_burox folio, fecha
    from   revision_buro
    where  idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar;
    if not found then
      folio_burox = NULL; fecha_burox := NULL;
    end if;

    select
    into   vigencia (case when dato1 is NULL or dato1 = ''
                          then '0'
                          else dato1
                     end)::integer
    from   tablas
    where  lower(idtabla) = 'param' and lower(idelemento) = 'revisar_buro' and
           sai_texto1_like_texto2(p_idproducto::text,NULL,dato2,'|') > 0;
    -- Osea, si no esta el producto en la tabla,
    -- Ya no busques por persona, para evitar incongruencias
    if not found then
      return NULL;
    end if;
    if vigencia is NULL then
      vigencia := 0;
    end if;

    if folio_burox is NULL and fecha_burox is NULL then
      select into folio_burox, fecha_burox folio, fecha
      from revision_buro
      where idorigen = p_idorigen and idgrupo = p_idgrupo and idsocio = p_idsocio and
            fecha = p_fechaprestamo;

      if not found then
        folio_burox = NULL; fecha_burox := NULL;
      end if;
    end if;

    if folio_burox is NULL and fecha_burox is NULL then
      vigencia := 0;

      if vigencia > 0 then
        select
        into     folio_burox, fecha_burox
                 folio,       fecha
        from     revision_buro
        where    idorigen = p_idorigen and idgrupo = p_idgrupo and idsocio = p_idsocio and
                 fecha between (p_fechaprestamo - vigencia) and p_fechaprestamo
        order by fecha desc
        limit    1;
        if not found then
          select
          into     folio_burox, fecha_burox
                   folio,       fecha
          from     revision_buro
          where    idorigen = p_idorigen and idgrupo = p_idgrupo and idsocio = p_idsocio and
                   fecha between p_fechaprestamo and (p_fechaprestamo + 5)
          order by fecha asc
          limit    1;
          if not found then
            folio_burox = NULL; fecha_burox := NULL;
          end if;
        end if;
      end if;
    end if;

    return folio_burox||'|'||fecha_burox;

end;
$$ language 'plpgsql';

/*------------------------------------------------------------------------------------------------------------------------------------------------------------
::: A B O N  O S   A D E L A N T A D O S   A   P R E S T A M O S    ---- I N I C I O ----
------------------------------------------------------------------------------------------------------------------------------------------------------------*/
create or replace function
sai_abono_adelantado_a_interes_procesa (_text,varchar) returns integer as $$
declare
  p_mat       alias for $1;
  p_sesion    alias for $2;

  p_idorigen    integer;
  p_idgrupo     integer;
  p_idsocio     integer;
  p_idorigenp   integer;
  p_idproducto  integer;
  p_idauxiliar  integer;
  p_fecha       date;
  p_es          boolean;
  p_monto       numeric;
  p_mov         integer;
  p_idusuario   integer;
  p_tipoamort   integer;
  p_ref         text;
  p_aux         text;

  paso_txt      text;
  x_acapital    numeric;
  x_io_pag      numeric;
  x_io_cal      numeric;
  x_im_pag      numeric;
  x_im_cal      numeric;
  x_ivaio_pag   numeric;
  x_ivaio_cal   numeric;
  x_ivaim_pag   numeric;
  x_ivaim_cal   numeric;
  x_cmnpag_pag  numeric;
  x_cmnpag_cal  numeric;
  x_montoseg    numeric;
  x_ret         numeric;
  x_saldodiacum numeric;
  x_t_ivaio     numeric;
  x_t_ivaim     numeric;
  x_iva         numeric;
  x_t_iva       numeric;
  r_paso        record;
  folio         integer;
  impte_desglo  numeric;
  cta_reembolso varchar(20);
  x_prod_ret    integer;
  t_dim         _text;

begin

  p_idorigen    := p_mat[1];
  p_idgrupo     := p_mat[2];
  p_idsocio     := p_mat[3];
  p_idorigenp   := p_mat[4];
  p_idproducto  := p_mat[5];
  p_idauxiliar  := p_mat[6];
  p_fecha       := p_mat[7];
  p_es          := p_mat[8];
  p_monto       := p_mat[9];
  p_mov         := p_mat[10];
  p_idusuario   := p_mat[11];
  p_tipoamort   := p_mat[12];
  p_ref         := p_mat[13];
  p_aux         := p_mat[14];

  x_acapital    := p_monto;
  x_io_pag      := 0;
  x_io_cal      := 0;
  x_im_pag      := 0;
  x_im_cal      := 0;
  x_ivaio_pag   := 0;
  x_ivaio_cal   := 0;
  x_ivaim_pag   := 0;
  x_ivaim_cal   := 0;
  x_montoseg    := 0;
  x_cmnpag_pag  := 0;
  x_cmnpag_cal  := 0;
  x_saldodiacum := 0;
  x_ret         := 0;
  x_iva         := 0;

  x_t_ivaio := sai_iva_segun_sucursal(p_idorigenp,p_idproducto,0);
  x_t_ivaim := sai_iva_segun_sucursal(p_idorigenp,p_idproducto,1);
  x_t_iva   := x_t_ivaio;

  if sai_findstr(p_ref,'|')+1 = 10 and
     int4(sai_token(10,p_ref,'|')) = 2 then

    x_montoseg    := sai_token(2,p_ref,'|')::numeric;
    x_io_cal      := sai_token(4,p_ref,'|')::numeric;
    x_im_cal      := sai_token(6,p_ref,'|')::numeric;
    x_ivaio_cal   := sai_token(5,p_ref,'|')::numeric;
    x_ivaim_cal   := sai_token(7,p_ref,'|')::numeric;
    x_cmnpag_cal  := sai_token(9,p_ref,'|')::numeric;
/*
    if x_montoseg > 0 then
      if x_acapital < x_montoseg then
        x_montoseg := x_acapital;
        x_acapital := 0;
      else
        x_acapital := x_acapital - x_montoseg;
      end if;
    end if;

    if x_acapital > 0 then
      if x_acapital < x_cmnpag_cal then
        x_cmnpag_pag  := x_acapital;
        x_acapital    := 0;
      else
        x_cmnpag_pag  := x_cmnpag_cal;
        x_acapital    := x_acapital - x_cmnpag_cal;
      end if;
    end if;
*/
    if x_acapital > 0 and (x_ivaio_cal > 0 or x_ivaim_cal > 0) then
      select
      into   x_t_ivaio, x_t_ivaim
             iva,       ivaim
      from   productos
      where  idproducto = p_idproducto;
    end if;

    if x_acapital > 0 then
      if x_acapital < (x_im_cal + x_ivaim_cal) then
        impte_desglo  := x_acapital / ((x_t_ivaim / 100) + 1);
        x_ivaim_pag   := x_acapital - impte_desglo;
        x_im_pag      := impte_desglo;
        x_acapital    := 0;
      else
        x_ivaim_pag   := x_ivaim_cal;
        x_im_pag      := x_im_cal;
        x_acapital    := x_acapital - (x_im_cal + x_ivaim_cal);
        x_acapital    := case when x_acapital <= 0 then 0 else x_acapital end;
      end if;
    end if;

    if x_acapital > 0 then
      if x_acapital < (x_io_cal + x_ivaio_cal) then
        impte_desglo  := x_acapital / ((x_t_ivaio / 100) + 1);
        x_ivaio_pag   := x_acapital - impte_desglo;
        x_io_pag      := impte_desglo;
        x_acapital    := 0;
      else
        x_ivaio_pag   := x_ivaio_cal;
        x_io_pag      := x_io_cal;
        x_acapital    := x_acapital - (x_io_cal + x_ivaio_cal);
        x_acapital    := case when x_acapital <= 0 then 0 else x_acapital end;
      end if;
    end if;
  end if;

  if sai_findstr(p_ref,'|')+1 = 4 and int4(sai_token(1,p_ref,'|')) = 0 then
    x_io_cal      := sai_token(2,p_ref,'|')::numeric;
    x_io_pag      := 0;
    x_ret         := sai_token(3,p_ref,'|')::numeric;
    x_saldodiacum := sai_token(4,p_ref,'|')::numeric;
  end if;

  if sai_findstr(p_ref,'|')+1 = 2 and int4(sai_token(1,p_ref,'|')) = 5 then
    x_iva         := sai_token(2,p_ref,'|')::numeric;
  end if;

  if x_acapital > 0 or x_io_pag > 0 or x_im_pag > 0 or x_cmnpag_pag > 0 then
    INSERT INTO temporal(idusuario,sesion,idorigen,idgrupo,idsocio,idorigenp,idproducto,idauxiliar,esentrada,acapital,
                         io_pag,io_cal,im_pag,im_cal,idcuenta,aplicado,aiva,abonifio,saldodiacum,ivaio_pag,ivaio_cal,
                         ivaim_pag,ivaim_cal,tipomov,mov,cpnp_pag,cpnp_cal,sai_aux)
                 VALUES (p_idusuario,p_sesion,p_idorigen,p_idgrupo,p_idsocio,p_idorigenp,p_idproducto,p_idauxiliar,p_es,
                         x_acapital,x_io_pag,x_io_cal,x_im_pag,x_im_cal,'0',FALSE,x_iva,0,x_saldodiacum,x_ivaio_pag,
                         x_ivaio_cal,x_ivaim_pag,x_ivaim_cal,0,p_mov,x_cmnpag_pag,x_cmnpag_cal,p_aux);
  end if;
/*
  if x_montoseg > 0 then
    for r_paso in
      select * from sai_prestamos_hipotecarios_calcula_seguro_a_pagar(p_idorigenp,p_idproducto,p_idauxiliar,p_fecha)
    loop

      if x_montoseg < (r_paso.apagar + r_paso.ivaapagar) then
        x_acapital  := x_montoseg / ((x_t_ivaim / 100) + 1);
        x_iva       := x_montoseg - x_acapital;
        x_montoseg  := 0;
      else
        x_acapital  := r_paso.apagar;
        x_iva       := r_paso.ivaapagar;
        x_montoseg  := x_montoseg - r_paso.apagar;
      end if;

      t_dim := '{}' + text(p_idorigen) + text(p_idgrupo) + text(p_idsocio) +
               text(p_idorigenp) + text(idproducto) + text(idauxiliar) +
               text(d_fecha_hoy) + text(0) + text(x_acapital) + text(p_mov) +
               text(p_idusuario) + text(0) + '5'||'|'||text(x_iva);
      p_mov := sai_abono_adelantado_a_interes_procesa (t_dim,'ABONO_ADELA_INT_PR',NULL);
    end loop;
  end if;
*/
  if x_ret > 0 and x_io_pag > 0 then

    /*-- Posible reembolso de retencion en caso de existir la tabla ---*/
    select into cta_reembolso
                case when exists (select c.*
                                    from cuentas as c
                                   where c.idcuenta = t.dato1 and c.clase = 5)
                     then dato1
                     else '0'
                end
           from tablas as t
          where t.idtabla = 'param' and t.idelemento = 'regresa_retencion';
    if not found then
      cta_reembolso := '0';
    end if;

    p_mov := p_mov + 1;

    select into r_paso *
      from auxiliares
     where idorigen = p_idorigen and idgrupo = p_idgrupo and
           idsocio = p_idsocio and idproducto = x_prod_ret;
    if found then
      p_idorigenp := r_paso.idorigenp;
      folio := r_paso.idauxiliar;
    else
      t_dim := array[text(p_idorigen)  , text(p_idgrupo)    , text(idsocio) ,
                     text(p_idorigenp) , text(p_idproducto) , text(p_fecha) ,
                     text(p_idusuario) , text(0)];
      folio := sai_ahorro_crea_apertura (t_dim);
    end if;

    INSERT INTO temporal(idusuario,sesion,idorigen,idgrupo,idsocio,idorigenp,idproducto,idauxiliar,esentrada,acapital,
                         io_pag,io_cal,im_pag,im_cal,idcuenta,aplicado,aiva,abonifio,saldodiacum,ivaio_pag,ivaio_cal,
                         ivaim_pag,ivaim_cal,tipomov,mov)
                 VALUES (p_idusuario,p_sesion,p_idorigen,p_idgrupo,p_idsocio,p_idorigenp,x_prod_ret,folio,TRUE,x_ret,
                         0,0,0,0,'0',FALSE,0,0,0,0,0,0,0,0);

    if cta_reembolso NOT like '0' then
      p_mov := p_mov + 1;

      INSERT INTO temporal(idusuario,sesion,idorigen,idgrupo,idsocio,idorigenp,idproducto,idauxiliar,esentrada,acapital,
                           io_pag,io_cal,im_pag,im_cal,idcuenta,aplicado,aiva,abonifio,saldodiacum,ivaio_pag,ivaio_cal,
                           ivaim_pag,ivaim_cal,tipomov,mov)
                 VALUES (p_idusuario,p_sesion,p_idorigen,p_idgrupo,p_idsocio,p_idorigenp,1,0,FALSE,x_ret,0,0,0,0,
                         cta_reembolso,FALSE,0,0,0,0,0,0,0,0,p_mov);
    end if;
  end if;

  p_mov := p_mov + 1;

  return p_mov;
end;
$$ language 'plpgsql';


create or replace function
sai_abono_adelantado_a_interes_cuanto(integer,integer,integer,date,integer,text)
returns text as $$
declare
  p_idorigenp   alias for $1;
  p_idproducto  alias for $2;
  p_idauxiliar  alias for $3;
  p_fecha       alias for $4;
  p_ta          alias for $5;
  p_aux         alias for $6;


  n_montoseg    numeric;
  n_montoven    numeric;
  n_io          numeric;
  n_ivaio       numeric;
  n_im          numeric;
  n_ivaim       numeric;
  n_proxabono   numeric;
  n_comnopag    numeric;
  n_suma        numeric;

begin

  n_montoseg := 0;

  -- Monto seguro hipotecario
  if p_ta = 5 then
    select into n_montoseg coalesce(sum(apagar + ivaapagar), 0)
      from sai_prestamos_hipotecarios_calcula_seguro_a_pagar (p_idorigenp,
                                             p_idproducto,p_idauxiliar,p_fecha);

  end if;

  n_montoven    := sai_token(5,p_aux,'|')::numeric;
  n_io          := sai_token(7,p_aux,'|')::numeric;
  n_ivaio       := sai_token(18,p_aux,'|')::numeric;
  n_im          := sai_token(16,p_aux,'|')::numeric;
  n_ivaim       := sai_token(19,p_aux,'|')::numeric;
  n_proxabono   := sai_token(12,p_aux,'|')::numeric;
  n_comnopag    := sai_token(22,p_aux,'|')::numeric;

  n_suma := n_montoseg + n_montoven + n_io + n_ivaio + n_im + n_ivaim +
            n_proxabono + n_comnopag;

  return text(n_suma)||'|'||text(n_montoseg)||'|'||text(n_montoven)||'|'||
         text(n_io)||'|'||text(n_ivaio)||'|'||text(n_im)||'|'||
         text(n_ivaim)||'|'||text(n_proxabono)||'|'||
         text(n_comnopag)||'|'||sai_token(1,p_aux,'|');
end;
$$ language 'plpgsql';

create or replace function
sai_abono_adelantado_a_interes_caso_ajuste (date) returns integer as $$
declare
  p_fecha_hoy     alias for $1;
  r_aai           record;
  r_soc           record;
  x_aux           text;
  a_interes       numeric;
  a_iva           numeric;
  x_saldo_ah      numeric;
  x_primera_vez   boolean;
begin

  for r_soc
  in  select   idorigen,idgrupo,idsocio
      from     abono_adelantado_interes aai
               inner join auxiliares as a on (a.idorigenp = aai.idorigenp_p and a.idproducto = aai.idproducto_p and a.idauxiliar = aai.idauxiliar_p)
      where    a.estatus in (2,3) and aai.fecha = p_fecha_hoy and not aai.aplicado
      union
      select   idorigen,idgrupo,idsocio
      from     abono_adelantado_interes aai
               inner join auxiliares_h as a on (a.idorigenp = aai.idorigenp_p and a.idproducto = aai.idproducto_p and a.idauxiliar = aai.idauxiliar_p)
      where    a.estatus = 3 and aai.fecha = p_fecha_hoy and not aai.aplicado
      group by idorigen,idgrupo,idsocio
  loop
    x_primera_vez := TRUE;

    for r_aai
    in  select   aai.*, coalesce(p.iva,0) as tasaiva
        from     (select aai.*,a.estatus
                  from   abono_adelantado_interes aai
                         inner join auxiliares as a on (a.idorigenp = aai.idorigenp_p and a.idproducto = aai.idproducto_p and a.idauxiliar = aai.idauxiliar_p)
                  where  a.estatus in (2,3) and a.idorigen = r_soc.idorigen and a.idgrupo = r_soc.idgrupo and a.idsocio = r_soc.idsocio and
                         aai.fecha = p_fecha_hoy and not aai.aplicado
                  union
                  select aai.*,a.estatus
                  from   abono_adelantado_interes aai
                         inner join auxiliares_h as a on (a.idorigenp = aai.idorigenp_p and a.idproducto = aai.idproducto_p and a.idauxiliar = aai.idauxiliar_p)
                  where  a.estatus = 3 and a.idorigen = r_soc.idorigen and a.idgrupo = r_soc.idgrupo and a.idsocio = r_soc.idsocio and
                         aai.fecha = p_fecha_hoy and not aai.aplicado) aai
                 inner join productos as p on (p.idproducto = aai.idproducto_p)
        order by estatus, interes desc
    loop
      if x_primera_vez then
        -- Saca el saldo del Producto Ahorro
        select
        into   x_saldo_ah saldo
        from   auxiliares
        where  idorigenp = r_aai.idorigenp_a and idproducto = r_aai.idproducto_a and idauxiliar = r_aai.idauxiliar_a;
        x_primera_vez := FALSE;
      end if;

      if x_saldo_ah <= 0 then
        a_interes := 0;
        a_iva     := 0;
      else
        if (x_saldo_ah - (r_aai.interes + r_aai.iva_interes)) < 0 then
          a_interes   := (x_saldo_ah / (1 + r_aai.tasaiva))::numeric(12,2);
          a_iva       := x_saldo_ah - a_interes;
          x_saldo_ah  := 0;
        else
          x_saldo_ah  := x_saldo_ah - (r_aai.interes + r_aai.iva_interes);
          continue;
        end if;
      end if;

      update abono_adelantado_interes
      set    interes      = a_interes,
             iva_interes  = a_iva,
             estatus_ap   = 3
      where  idorigenp_p  = r_aai.idorigenp_p  and
             idproducto_p = r_aai.idproducto_p and
             idauxiliar_p = r_aai.idauxiliar_p and
             idorigenp_a  = r_aai.idorigenp_a  and
             idproducto_a = r_aai.idproducto_a and
             idauxiliar_a = r_aai.idauxiliar_a and
             fecha        = r_aai.fecha;
    end loop;
  end loop;

  return 1;
end;
$$ language 'plpgsql';

create or replace function
sai_abono_adelantado_a_interes_prestamos_pagados (integer, integer, date, integer, varchar) returns integer as $$
declare
  p_idusuario   alias for $1;
  p_prod_bonif  alias for $2;
  p_fecha_hoy   alias for $3;
  p_movs        alias for $4;
  p_sesion      alias for $5;

--  b_primera_vez       boolean;
--  b_difsob_a_capital  boolean;
--  b_usa_resumidero    boolean;
--  i_cont              integer;
  i_movs              integer;
  i_origenapl         integer;
  i_poliza            integer;
  i_orig_bonif        integer;
  i_auxi_bonif        integer;
  n_sai_aux_abono     numeric;
  n_sai_aux_ioeiva    numeric;  
  n_resto             numeric;
  n_paso              numeric;
  n_a_interes_ap      numeric;
  n_a_iva_interes_ap  numeric;
  n_monto_abono_paso  numeric;
  n_monto_abono       numeric;
  n_monto_cargo       numeric;
  n_monto_bonif       numeric;
  r_movs              record;
  r_movs_ant          record;
  r_ref               record;
  t_concepto          text;
  t_dim               text[];
  t_opa               text;
  t_periodo           text;
  t_resp              text;
  t_sai_aux           text;
  r_aux_ah            record;
  r_app               record;
  r_paso              record;
  r_opa_bonif         record;
  v_sesion            varchar;
  i_estatus_ap        integer;
begin

  i_movs := p_movs;

  for r_movs
  in
-- SE AGRUPO LA SUMA DE LOS ADELANTOS POR FECHA DE APLICACION (EN CASO DE ADELANTOS EN EL MISMO DIA)
      select    fecha,idorigenp_p,idproducto_p,idauxiliar_p,idorigenp_a,idproducto_a,idauxiliar_a,
                idorigen,idgrupo,idsocio,tipoamortizacion,saldo,
                sum(interes) as interes, sum(iva_interes) as iva_interes,sai_auxiliar(idorigenp_p,idproducto_p,idauxiliar_p,p_fecha_hoy) as aux
      from      (select aai.*,a.idorigen,a.idgrupo,a.idsocio,a.tipoamortizacion,a.saldo
                 from   abono_adelantado_interes as aai
                        inner join auxiliares as a on (a.idorigenp = aai.idorigenp_p and a.idproducto = aai.idproducto_p and a.idauxiliar = aai.idauxiliar_p)
                 where  fecha = p_fecha_hoy and not aplicado and interes > 0 and a.estatus = 3
                 union
                 select aai.*,ah.idorigen,ah.idgrupo,ah.idsocio,ah.tipoamortizacion,ah.saldo
                 from   abono_adelantado_interes as aai
                        inner join auxiliares_h as ah on (ah.idorigenp = aai.idorigenp_p and ah.idproducto = aai.idproducto_p and ah.idauxiliar = aai.idauxiliar_p)
                 where  fecha = p_fecha_hoy and not aplicado and interes > 0 and ah.estatus = 3) aai
      group by  fecha,idorigenp_p,idproducto_p,idauxiliar_p,idorigenp_a,idproducto_a,idauxiliar_a,
                idorigen,idgrupo,idsocio,tipoamortizacion,saldo
  loop
    n_a_interes_ap      := r_movs.interes;
    n_a_iva_interes_ap  := r_movs.iva_interes;
    i_estatus_ap        := 5;  -- Regreso por Liquidacion Prematura de Prestamo

    n_monto_cargo := r_movs.interes + r_movs.iva_interes;
    n_monto_bonif := n_monto_cargo;

    if n_monto_cargo > 0 then
      if i_movs = 0 then
        i_movs := 1;
      end if;

      /*--- CARGO ---*/
      t_sai_aux := sai_auxiliar(r_movs.idorigenp_a, r_movs.idproducto_a, r_movs.idauxiliar_a, p_fecha_hoy);

        -- TP|Int|Ret|Sdodiacum
      t_resp := '0'||  '|'  ||sai_token(2,t_sai_aux,'|')||  '|'  ||sai_token(4,t_sai_aux,'|')||  '|'  ||sai_token(5,t_sai_aux,'|');

      t_dim := array[text(r_movs.idorigen)     , text(r_movs.idgrupo)      , text(r_movs.idsocio)      ,
                     text(r_movs.idorigenp_a)  , text(r_movs.idproducto_a) , text(r_movs.idauxiliar_a) ,
                     text(p_fecha_hoy)         , 'f'                       , text(n_monto_cargo)       ,
                     text(i_movs)              , text(p_idusuario)         , text(0)                   ,
                     t_resp                    , t_sai_aux];

      i_movs := sai_abono_adelantado_a_interes_procesa (t_dim,p_sesion);

      /*--- ABONO A RESUMIDERO (cuando saldo pr. es mas bajo) ---*/ 
      t_sai_aux := NULL;
      select
      into   r_opa_bonif *
      from   auxiliares
      where  idorigen = r_movs.idorigen and idgrupo = r_movs.idgrupo and idsocio = r_movs.idsocio and
             idproducto = p_prod_bonif;
      if not found then
        -- Apertura
        t_dim := array[text(r_movs.idorigen) , text(r_movs.idgrupo)  ,
                       text(r_movs.idsocio)  , text(r_movs.idorigen) ,
                       text(p_prod_bonif)    , text(p_fecha_hoy)     ,
                       text(p_idusuario)     , text(0)];

        i_orig_bonif  := r_movs.idorigen;
        i_auxi_bonif  := sai_ahorro_crea_apertura (t_dim);
      else
        i_orig_bonif  := r_opa_bonif.idorigenp;
        i_auxi_bonif  := r_opa_bonif.idauxiliar;
      end if;

      t_sai_aux :=  sai_auxiliar(r_opa_bonif.idorigenp, r_opa_bonif.idproducto, r_opa_bonif.idauxiliar, p_fecha_hoy);
      t_resp := '0'||  '|'  ||sai_token(2,t_sai_aux,'|')||  '|'  ||sai_token(4,t_sai_aux,'|')||  '|'  ||sai_token(5,t_sai_aux,'|'); -- TP|Int|Ret|Sdodiacum

      t_dim := array[text(r_movs.idorigen) , text(r_movs.idgrupo)  , text(r_movs.idsocio) ,
                     text(i_orig_bonif)    , text(p_prod_bonif)    , text(i_auxi_bonif)   ,
                     text(p_fecha_hoy)     , 't'                   , text(n_monto_bonif)  ,
                     text(i_movs)          , text(p_idusuario)     , text(0)              ,
                     t_resp                , t_sai_aux];

      i_movs := sai_abono_adelantado_a_interes_procesa (t_dim,p_sesion);

      update abono_adelantado_interes
         set interes_ap     = n_a_interes_ap,
             iva_interes_ap = n_a_iva_interes_ap,
             aplicado       = TRUE,
             estatus_ap     = estatus_ap
       where idorigenp_p  = r_movs.idorigenp_p  and
             idproducto_p = r_movs.idproducto_p and
             idauxiliar_p = r_movs.idauxiliar_p and
             idorigenp_a  = r_movs.idorigenp_a  and
             idproducto_a = r_movs.idproducto_a and
             idauxiliar_a = r_movs.idauxiliar_a and
             fecha        = r_movs.fecha;
    end if;

    -- Avance del proceso ---
    raise notice '|MSG_AVANCE';

  end loop;

  return i_movs;
end;
$$ language 'plpgsql';

create or replace function
sai_abono_adelantado_a_interes (integer) returns integer as $$
declare
  p_idusuario   alias for $1;

  b_primera_vez       boolean;
  b_difsob_a_capital  boolean;
  b_usa_resumidero    boolean;
  b_bonif_por_pp      boolean;
  b_aaip_ok           boolean;
  d_fecha_hoy         date;
  i_cont              integer;
  i_movs              integer;
  i_origenapl         integer;
  i_poliza            integer;
  i_prod_app          integer; -- Producto abono adelantado a prestamos
  i_orig_bonif        integer;
  i_prod_bonif        integer;  
  i_auxi_bonif        integer;
  i_estatus_ap        integer;
  n_sai_aux_abono     numeric;
  n_sai_aux_ioeiva    numeric;  
  n_resto             numeric;
  n_paso              numeric;
  n_a_interes_ap      numeric;
  n_a_iva_interes_ap  numeric;
  n_monto_abono_paso  numeric;
  n_monto_abono       numeric;
  n_monto_cargo       numeric;
  n_monto_bonif       numeric;
  r_movs              record;
  r_movs_ant          record;
  r_ref               record;
  t_concepto          text;
  t_dim               text[];
  t_opa               text;
  t_periodo           text;
  t_resp              text;
  t_sai_aux           text;
  t_paso1             text;
  t_paso2             text;
  r_aux_ah            record;
  r_app               record;
  r_paso              record;
  r_opa_bonif         record;
  v_sesion            varchar;
  
begin

  /*--- Validar la tabla: abonos_adelantados_de_interes_a_prestamos ---*/
  select
  into   r_app *
  from   tablas
  where  idtabla = 'param' and idelemento = 'cobrar_interes_hasta_el_sig_pago';
  if not found or r_app.dato1 is NULL or trim(r_app.dato1) != '1' then
    t_resp := 'NO ESTA HABILITADO ABONO ADELANTADO DE INTERES A PRESTAMOS'||E'\012';
    raise notice '|MSG_AVISO|%',t_resp;
    return 1;
  end if;

  i_prod_app          := int4(r_app.dato2);
  b_difsob_a_capital  := case when r_app.dato4 is not NULL and trim(r_app.dato4) = '1'
                              then TRUE
                              else FALSE
                         end;
  i_prod_bonif        := case when r_app.dato5 is NULL or r_app.dato5 = '' or r_app.dato5 = '0'
                              then 0
                              else r_app.dato5::integer
                         end;

  select
  into   d_fecha_hoy date(fechatrabajo)
  from   origenes as o
  limit  1;

  /*--- origen de aplicacion ---------------------------*/
  select
  into   i_origenapl idorigen
  from   usuarios
  where  idusuario = p_idusuario;
  
  /*--- nombre de sesion ---------------------------*/
  v_sesion    := 'ABONO_ADELA_INT_PR';

  -- Conteo de los registros a leer ------------------------------
  select
  into   i_cont coalesce(count(*),0)
  from   (select   idorigenp_p,idproducto_p,idauxiliar_p
          from     abono_adelantado_interes as aai
                   inner join auxiliares    as a   on (a.idorigenp = idorigenp_p and a.idproducto = idproducto_p and a.idauxiliar = idauxiliar_p)
          where    aai.fecha = d_fecha_hoy and a.estatus in (2,3) and not aplicado
          union
          select   idorigenp_p,idproducto_p,idauxiliar_p
          from     abono_adelantado_interes as aai
                   inner join auxiliares_h  as ah  on (ah.idorigenp = idorigenp_p and ah.idproducto = idproducto_p and ah.idauxiliar = idauxiliar_p)
          where    aai.fecha = d_fecha_hoy and ah.estatus = 3 and not aplicado
          group by idorigenp_p,idproducto_p,idauxiliar_p) as z;
  if i_cont = 0 then
    t_resp := '|MSG_AVISO|NO HAY ABONOS ADELANTADOS DE INTERESES A PRESTAMOS PARA ESTE DIA ('||d_fecha_hoy||')'||E'\012';
    raise notice '%',t_resp;
    return 1;
  end if;

  -- Show me how many records there are ---
  raise notice '|MSG_CONTEO|%|1',i_cont;

  -- En caso de ajuste al producto tipo Ahorro, recalcula el monto interes
  perform sai_abono_adelantado_a_interes_caso_ajuste (d_fecha_hoy);

  i_movs := 0;
  -- Regreso de Adelanto en caso de Prestamos Liquidados Prematuramente
  if i_prod_bonif > 0 then
    i_movs := sai_abono_adelantado_a_interes_prestamos_pagados (p_idusuario, i_prod_bonif, d_fecha_hoy, i_movs, v_sesion);
  end if;
  b_bonif_por_pp := i_movs > 0;

  b_aaip_ok := FALSE;
  for r_movs
  in
-- SE AGRUPO LA SUMA DE LOS ADELANTOS POR FECHA DE APLICACION (EN CASO DE ADELANTOS EN EL MISMO DIA)
      select    fecha,idorigenp_p,idproducto_p,idauxiliar_p,idorigenp_a,idproducto_a,idauxiliar_a,
                idorigen,idgrupo,idsocio,tipoamortizacion,saldo,
                sum(interes) as interes, sum(iva_interes) as iva_interes,sai_auxiliar(idorigenp_p,idproducto_p,idauxiliar_p,d_fecha_hoy) as aux
      from      (select aai.*,a.idorigen,a.idgrupo,a.idsocio,a.tipoamortizacion,a.saldo
                 from   abono_adelantado_interes as aai
                        inner join auxiliares as a on (a.idorigenp = aai.idorigenp_p and a.idproducto = aai.idproducto_p and a.idauxiliar = aai.idauxiliar_p)
                 where  fecha = d_fecha_hoy and not aplicado and interes > 0 and a.estatus in (2,3)
                 union
                 select aai.*,ah.idorigen,ah.idgrupo,ah.idsocio,ah.tipoamortizacion,ah.saldo
                 from   abono_adelantado_interes as aai
                        inner join auxiliares_h as ah on (ah.idorigenp = aai.idorigenp_p and ah.idproducto = aai.idproducto_p and ah.idauxiliar = aai.idauxiliar_p)
                 where  fecha = d_fecha_hoy and not aplicado and interes > 0 and ah.estatus = 3) z
      group by  fecha,idorigenp_p,idproducto_p,idauxiliar_p,idorigenp_a,idproducto_a,idauxiliar_a,
                idorigen,idgrupo,idsocio,tipoamortizacion,saldo
  loop

    t_resp := sai_abono_adelantado_a_interes_cuanto (r_movs.idorigenp_p, r_movs.idproducto_p, r_movs.idauxiliar_p,
                                                     d_fecha_hoy, r_movs.tipoamortizacion, r_movs.aux);

    /*--- Abono Neto del Prestamo ---*/
    n_sai_aux_ioeiva  := sai_token(4,t_resp,'|')::numeric + sai_token(5,t_resp,'|')::numeric;

    -- Normalizador a la Baja: Interes Adelantado vs Interes sai_auxiliar
    n_paso := numeric_smaller((r_movs.interes + r_movs.iva_interes), n_sai_aux_ioeiva);

    b_usa_resumidero := FALSE;
    n_monto_bonif := 0;
    n_monto_abono := 0;
    n_monto_cargo := 0;
    if (n_paso = (r_movs.interes + r_movs.iva_interes)) then -- En este caso, NO hay sobrante
      n_a_interes_ap      := r_movs.interes;
      n_a_iva_interes_ap  := r_movs.iva_interes;
      i_estatus_ap        := 1;  -- Normal

      -- Bajar el monto abono
      n_monto_abono := n_paso;
      n_monto_cargo := n_monto_abono;
    else                                                     -- En este caso, SI hay sobrante
      n_a_interes_ap      := sai_token(4,t_resp,'|')::numeric;
      n_a_iva_interes_ap  := sai_token(5,t_resp,'|')::numeric;
      i_estatus_ap        := 2;  -- Adelanto Prematuro

      n_monto_abono := n_sai_aux_ioeiva;
      n_monto_cargo := n_sai_aux_ioeiva;
      
      if b_difsob_a_capital then    -- dato4 = 1
        n_monto_abono       := n_monto_abono + numeric_smaller(((r_movs.interes + r_movs.iva_interes) - n_sai_aux_ioeiva), r_movs.saldo);
        n_monto_cargo       := n_monto_abono;
      end if;
      
      if i_prod_bonif > 0 and       -- dato5 = 1
         n_monto_abono < (r_movs.interes + r_movs.iva_interes)
      then
        n_monto_bonif := (r_movs.interes + r_movs.iva_interes) - n_monto_abono;
        n_monto_cargo := n_monto_cargo + n_monto_bonif;
        b_usa_resumidero := TRUE;
      end if;
    end if;

    if i_movs = 0 then
      i_movs := 1;
    end if;

    if n_monto_abono > 0 then
      b_aaip_ok = TRUE;
      /*--- ABONO ---*/
      t_dim := array[text(r_movs.idorigen)     , text(r_movs.idgrupo)      , text(r_movs.idsocio)          ,
                     text(r_movs.idorigenp_p)  , text(r_movs.idproducto_p) , text(r_movs.idauxiliar_p)     ,
                     text(d_fecha_hoy)         , 't'                       , text(n_monto_abono)           ,
                     text(i_movs)              , text(p_idusuario)         , text(r_movs.tipoamortizacion) ,
                     t_resp                    , r_movs.aux];

      i_movs := sai_abono_adelantado_a_interes_procesa (t_dim,v_sesion);
    end if;

    if n_monto_cargo > 0 then
      /*--- CARGO ---*/
      t_sai_aux := sai_auxiliar(r_movs.idorigenp_a, r_movs.idproducto_a, r_movs.idauxiliar_a, d_fecha_hoy);

        -- TP|Int|Ret|Sdodiacum
      t_resp := '0'||  '|'  ||sai_token(2,t_sai_aux,'|')||  '|'  ||sai_token(4,t_sai_aux,'|')||  '|'  ||sai_token(5,t_sai_aux,'|');

      t_dim := array[text(r_movs.idorigen)     , text(r_movs.idgrupo)      , text(r_movs.idsocio)      ,
                     text(r_movs.idorigenp_a)  , text(r_movs.idproducto_a) , text(r_movs.idauxiliar_a) ,
                     text(d_fecha_hoy)         , 'f'                       , text(n_monto_cargo)       ,
                     text(i_movs)              , text(p_idusuario)         , text(0)                   ,
                     t_resp                    , t_sai_aux];

      i_movs := sai_abono_adelantado_a_interes_procesa (t_dim,v_sesion);
    end if;
      
    if n_monto_bonif > 0 then
      /*--- ABONO A RESUMIDERO (cuando saldo pr. es mas bajo) ---*/ 
      if b_usa_resumidero and i_prod_bonif > 0 then
        t_sai_aux := NULL;
        select
        into   r_opa_bonif *
        from   auxiliares
        where  idorigen = r_movs.idorigen and idgrupo = r_movs.idgrupo and idsocio = r_movs.idsocio and
               idproducto = i_prod_bonif;
        if not found then
          -- Apertura
          t_dim := array[text(r_movs.idorigen) , text(r_movs.idgrupo)  ,
                         text(r_movs.idsocio)  , text(r_movs.idorigen) ,
                         text(i_prod_bonif)    , text(d_fecha_hoy)     ,
                         text(p_idusuario)     , text(0)];

          i_orig_bonif  := r_movs.idorigen;
          i_auxi_bonif  := sai_ahorro_crea_apertura (t_dim);
        else
          i_orig_bonif  := r_opa_bonif.idorigenp;
          i_auxi_bonif  := r_opa_bonif.idauxiliar;
        end if;

        t_sai_aux :=  sai_auxiliar(r_opa_bonif.idorigenp, r_opa_bonif.idproducto, r_opa_bonif.idauxiliar, d_fecha_hoy);
        t_resp := '0'||  '|'  ||sai_token(2,t_sai_aux,'|')||  '|'  ||sai_token(4,t_sai_aux,'|')||  '|'  ||sai_token(5,t_sai_aux,'|'); -- TP|Int|Ret|Sdodiacum

        t_dim := array[text(r_movs.idorigen) , text(r_movs.idgrupo)  , text(r_movs.idsocio) ,
                       text(i_orig_bonif)    , text(i_prod_bonif)    , text(i_auxi_bonif)   ,
                       text(d_fecha_hoy)     , 't'                   , text(n_monto_bonif)  ,
                       text(i_movs)          , text(p_idusuario)     , text(0)              ,
                       t_resp                , t_sai_aux];

        i_movs := sai_abono_adelantado_a_interes_procesa (t_dim,v_sesion);
      end if;
    end if;

    update abono_adelantado_interes
    set    interes_ap     = n_a_interes_ap,
           iva_interes_ap = n_a_iva_interes_ap,
           aplicado       = TRUE,
           estatus_ap     = case when estatus_ap = 3 -- Caso Ajuste
                                 then estatus_ap
                                 else i_estatus_ap
                            end
    where  idorigenp_p  = r_movs.idorigenp_p  and
           idproducto_p = r_movs.idproducto_p and
           idauxiliar_p = r_movs.idauxiliar_p and
           idorigenp_a  = r_movs.idorigenp_a  and
           idproducto_a = r_movs.idproducto_a and
           idauxiliar_a = r_movs.idauxiliar_a and
           fecha        = r_movs.fecha;

    -- Avance del proceso ---
--    raise notice '|MSG_AVANCE';

  end loop;

  /*----------------------------------------------------------------------------
  -- GENERACION DE POLIZA
  ----------------------------------------------------------------------------*/
  if i_movs > 0 then
    t_paso1 := ''; t_paso2 := '';
    if b_aaip_ok then
      t_paso1 := 'ABONO ADELANTADO DE INTERES A PRESTAMOS';
    end if;
    if b_bonif_por_pp then
      t_paso2 := 'DEVOLUCION DEL ABONO ADELANTADO POR LIQUIDACION PREMATURA DEL PRESTAMO';
    end if;

    if t_paso1 != '' and t_paso2 != '' then
      t_concepto := t_paso1||' Y '||t_paso2;
    else
      t_concepto := t_paso1||t_paso2;
    end if;
    t_periodo   := to_char(date(d_fecha_hoy),'yyyymm');
    i_poliza    := sai_poliza_nueva (i_origenapl,t_periodo,3,0,d_fecha_hoy,
                                     t_concepto,''::varchar,TRUE,p_idusuario);

    i_cont := sai_temporal_procesa(p_idusuario,v_sesion,
                                   d_fecha_hoy,i_origenapl,i_poliza,3,
                                   t_concepto,FALSE,TRUE);

    if i_cont is NOT NULL and i_cont > 0 then
      update temporal
         set aplicado = TRUE
       where idusuario = p_idusuario and sesion = v_sesion;

      delete from temporal where idusuario = p_idusuario and
                                 sesion = v_sesion and aplicado;
    else
      raise exception 'HUBO UN ERROR AL APLICAR LA FUNCION SAI_TEMPORAL_PROCESA';
    end if;
  else
    t_resp := 'PARA EL DIA DE HOY, NO ENCONTRO MOVIMIENTOS QUE PROCESAR DE '||
              'ABONOS ADELANTADOS DE INTERESES A PRESTAMOS'||E'\012';
    raise notice '|MSG_AVISO|%', t_resp;
  end if;

  t_resp := 'ABONOS ADELANTADOS DE INTERESES A PRESTAMOS, TERMINO CORRECTAMENTE !';
  raise notice '|MSG_AVISO|%', t_resp;

  return i_cont;
end;
$$ language 'plpgsql';
/*------------------------------------------------------------------------------
::: ABONOS_ADELANTADOS_DE_INTERES_A_PRESTAMOS    ---- F I N A L ----
------------------------------------------------------------------------------*/


-- Utileria para calcular EPS
create or replace function
sai_evidencia_pago_sostenido (integer,integer,integer,date,date) returns date as $$
declare
  c_atiempo     integer;
  r_amort       record; 
  x_fecha_ceps  date;
begin
  c_atiempo    := 0;
  x_fecha_ceps := NULL;
  for r_amort
  in  select *
      from   amortizaciones
      where  idorigenp = $1 and idproducto = $2 and idauxiliar = $3 and vence between $4 and $5 and
             abono > 0
  loop
    if c_atiempo != 3 then
      c_atiempo := case when r_amort.atiempo is TRUE
                        then c_atiempo + 1
                        else 0
                   end;
      if c_atiempo = 3 then
        x_fecha_ceps := r_amort.vence;
        exit;
      end if;
    end if;

  end loop;

  return x_fecha_ceps;
end;
$$ language 'plpgsql';

-- Utileria para calcular el plazo en dias
create or replace function
sai_calcula_plazo_en_dias (integer, integer, integer, integer, date, date) returns integer as $$
declare
  p_idproducto      alias for $1;
  p_pagodiafijo     alias for $2;
  p_periodoabonos   alias for $3;
  p_plazo           alias for $4;
  p_fechaape        alias for $5;
  p_fechaprimerpago alias for $6;
  i_tpabonos        integer;
  i_plazo_dias      integer;
  d_fecha_paso      date;
begin
  if p_pagodiafijo = 0 then
    if p_periodoabonos > 0 then
      i_plazo_dias := p_plazo * p_periodoabonos;
    else 
      select
      into   i_tpabonos coalesce(dato1,'0')::integer
      from   tablas
      where  idtabla = 'param' and idelemento = 'periodoabono'||text(p_idproducto);
      if not found or i_tpabonos <= 0 then
        select
        into   i_tpabonos coalesce(dato1,'0')::integer
        from   tablas
        where  idtabla = 'param' and idelemento = 'periodoabono';
        if not found or i_tpabonos <= 0 then
          i_tpabonos := 30;
        end if;
      end if;
      
      i_plazo_dias := p_plazo * i_tpabonos;
    end if;
  else
    if p_fechaprimerpago is not null then
      d_fecha_paso := p_fechaprimerpago;
    else
      d_fecha_paso := p_fechaape;
    end if;

    if p_pagodiafijo = 2 then
      i_plazo_dias := date(d_fecha_paso + (text((p_plazo * 15.2)::integer)||' days')::interval) - d_fecha_paso;
    else
      -- i_plazo_dias := date(d_fecha_paso + (text(p_plazo)||' month')::interval) - d_fecha_paso;
      i_plazo_dias := date((case when p_fechaape is NULL then p_fechaprimerpago else p_fechaape end) +
                           (text(p_plazo)||' month')::interval) +
                    + (case when p_periodoabonos is NULL then 0 else p_periodoabonos end)
                    - (case when p_fechaape is NULL then p_fechaprimerpago else p_fechaape end);
    end if;
  end if;

  return i_plazo_dias;
end;
$$ language 'plpgsql';

-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- CONJUNTO DE FUNCIONES CORRESPONDIENTES A LA FUNCION: sai_valida_maximo_capital_neto_calculado :::::::::::::::::::::::
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
create or replace function
sai_valida_maximo_capital_neto_calculado_suma_los_pr (integer,integer,integer) returns numeric as $$
declare
  p_idorigen    alias for $1;
  p_idgrupo     alias for $2;
  p_idsocio     alias for $3;
  n_monto_tot   numeric;
begin
  select
  into   n_monto_tot
         coalesce(sum(saldo + case when a.estatus = 1 then a.montoautorizado else 0 end),0)
  from   auxiliares a
         inner join productos p using(idproducto)
  where  p.tipoproducto = 2 and a.idorigen = p_idorigen and a.idgrupo = p_idgrupo and a.idsocio = p_idsocio and
         a.estatus in (1,2);

  return n_monto_tot;
end;
$$ language 'plpgsql';

create or replace function
sai_valida_maximo_capital_neto_calculado_busca_prov_rec (integer,integer,integer,text,integer) returns numeric as $$
declare
  p_idorigen    alias for $1;
  p_idgrupo     alias for $2;
  p_idsocio     alias for $3;
  p_tiporef     alias for $4;
  p_nivel_r     alias for $5;
  i_cont        integer;
  n_monto_tot   numeric;
  r_ref         record;
begin

  n_monto_tot := 0; i_cont := 0;
  for r_ref
  in  select distinct idorigen,idgrupo,idsocio
      from   referencias
      where  (idorigenr,idgrupor,idsocior) = (p_idorigen,p_idgrupo,p_idsocio) and
             tiporeferencia in (select regexp_split_to_table(p_tiporef,'\\|')::integer)
  loop
    i_cont := i_cont + 1;
    -- Sus dependientes
    n_monto_tot := n_monto_tot +
                   sai_valida_maximo_capital_neto_calculado_suma_los_pr(r_ref.idorigen,r_ref.idgrupo,r_ref.idsocio);
  end loop;
  if i_cont > 0 then  -- Asi mismo
    n_monto_tot := n_monto_tot +
                   sai_valida_maximo_capital_neto_calculado_suma_los_pr(p_idorigen,p_idgrupo,p_idsocio);

    -- Hasta aqui llego
    return n_monto_tot;
  end if;
  
  -- No es Prov. de Recursos,talvez es dependiente de otro. Realiza recursividad nivel 2
  if i_cont = 0 and p_nivel_r = 1  then
    select
    into   r_ref distinct idorigen,idgrupo,idsocio
    from   referencias
    where  (idorigenr,idgrupor,idsocior) = (p_idorigen,p_idgrupo,p_idsocio) and
           tiporeferencia in (select regexp_split_to_table(p_tiporef,'\\|')::integer);
    if found then
      n_monto_tot := sai_valida_maximo_capital_neto_calculado_busca_prov_rec(r_ref.idorigen,r_ref.idgrupo,r_ref.idsocio,
                                                                             p_tiporef,2); -- recursividad nivel 2
    else -- No es Prov. de Recursos, ni es dependiente de otro, entonces calcula solo asi mismo.
      n_monto_tot := n_monto_tot +
                       sai_valida_maximo_capital_neto_calculado_suma_los_pr(p_idorigen,p_idgrupo,p_idsocio);
    end if;
  end if;

  return n_monto_tot;
end;
$$ language 'plpgsql';

create or replace function
sai_valida_maximo_capital_neto_calculado (integer,integer,integer,numeric) returns text as $$
declare
  p_idorigen    alias for $1;
  p_idgrupo     alias for $2;
  p_idsocio     alias for $3;
  p_monto_sol   alias for $4;
  r_tab         record;
  b_excedio     boolean;
  n_monto_tot   numeric;
  t_mensaje     text;
begin

  select   *
  into     r_tab
  from     tablas
  where    idtabla = 'monto_maximo_creditos' and idelemento like 'riesgo_comun%' and
           (dato1 is null or dato1 = '' or dato1::integer = p_idgrupo)
  order by idelemento
  limit    1;

  if not found then
    return NULL;
  end if;

  if r_tab.dato4::integer = 1 then
    b_excedio := p_monto_sol >= r_tab.dato3::numeric;
  else
    if r_tab.dato5 is not null and r_tab.dato5 != '' then
      n_monto_tot := sai_valida_maximo_capital_neto_calculado_busca_prov_rec(p_idorigen,p_idgrupo,p_idsocio,
                                                                             p_tiporef,1); -- recursividad nivel 1
    else
      n_monto_tot := sai_valida_maximo_capital_neto_calculado_suma_los_pr(p_idorigen,p_idgrupo,p_idsocio);
    end if;
    n_monto_tot := n_monto_tot + p_monto_sol;
    b_excedio := n_monto_tot >= r_tab.dato3::numeric;
  end if;

  if b_excedio then
    if r_tab.dato2 is NULL or trim(r_tab.dato2) = '' then
      t_mensaje := 'EL MONTO SOLICITADO, JUNTO CON EL SALDO DE LOS CREDITOS EXISTENTES PROPIOS,\n'||
                   'EXCEDE MAS DEL PORCENTAJE ESTABLECIDO DEL CAPITAL NETO DE LA ENTIDAD.';
    else
      t_mensaje := r_tab.dato2;
    end if;
  end if;
  
  return t_mensaje;
end;
$$ language 'plpgsql';
