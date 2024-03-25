/*

** NOTA: Subido al pa_proxversion.sql para la version 1.67.0 ****

drop table if exists bankingly_movimientos_ca cascade;
create table bankingly_movimientos_ca (
  fecha           timestamp,
  idusuario       integer,
  sesion          varchar,
  referencia      varchar,
  idorigen        integer,
  idgrupo         integer,
  idsocio         integer,
  idorigenp       integer,
  idproducto      integer,
  idauxiliar      integer,
  idcuenta        varchar(20) default '0',
  cargoabono      integer,
  monto           numeric,
  iva             numeric,
  io              numeric,
  ivaio           numeric,
  im              numeric,
  ivaim           numeric,
  tipo_amort      integer,
  aplicado        boolean default FALSE,
  sai_aux         text,
  idorden_spei    integer default 0,
  spei_cancelado  boolean default FALSE,
  primary key (fecha,idusuario,sesion,referencia,idorigenp,idproducto,idauxiliar),
  foreign key (idorigen,idgrupo,idsocio) references personas
);

drop trigger if exists t_i_bankingly_movimientos_ca on bankingly_movimientos_ca;
create or replace function t_i_bankingly_movimientos_ca() returns trigger as $$
declare
  r_prod  record;
  r_aux   record;
begin
  if tg_op = 'INSERT' then
    select
    into   r_prod *
    from   productos
    where  idproducto = new.idproducto;
    if r_prod.tipoproducto in (0,1,2,4,5,8) then
      select
      into   r_aux *
      from   auxiliares
      where  (idorigenp,idproducto,idauxiliar) = (new.idorigenp,new.idproducto,new.idauxiliar);
      if not found then
        raise exception 'Error: el O-P-A que se esta registrando en la tabla "bankingly_movimientos_ca" no es valido.';
      end if;
    end if;
  end if;
  
  return new;
end;
$$ language 'plpgsql';

create trigger t_i_bankingly_movimientos_ca
before         insert
on             bankingly_movimientos_ca
for each row   execute procedure t_i_bankingly_movimientos_ca();

drop table if exists bankingly_movimientos_spei cascade;
create table bankingly_movimientos_spei (
  idorden_spei    integer,
  fecha           timestamp,
  idusuario       integer,
  sesion          varchar,
  referencia      varchar,
  idorigen        integer,
  idgrupo         integer,
  idsocio         integer,
  idorigenp       integer,
  idproducto      integer,
  idauxiliar      integer,
  idcuenta        varchar(20) default '0',
  cargoabono      integer,
  monto           numeric,
  spei_cancelado  boolean,
  primary key (idorden_spei,fecha,idusuario,sesion,referencia,idorigenp,idproducto,idauxiliar),
  foreign key (idorigen,idgrupo,idsocio) references personas
);

*/

create or replace function
sai_bankingly_spei_rechazado (integer,varchar,varchar) returns numeric as $$
declare
  p_idorden_spei    alias for $1;
  p_new_sesion      alias for $2;
  p_new_referencia  alias for $3;
  d_fecha_hoy       date;
  r_spei            record;
  b_encontro        boolean;
begin
  select
  into   d_fecha_hoy date(fechatrabajo)
  from   origenes
  limit  1;

  b_encontro := FALSE;
  for r_spei
  in  select *
      from   bankingly_movimientos_spei
      where  idorden_spei = p_idorden_spei
  loop
    insert
    into   bankingly_movimientos_ca
           (fecha,sesion,idusuario,referencia,idorigen,idgrupo,idsocio,idorigenp,idproducto,idauxiliar,
            idcuenta,cargoabono,monto,idorden_spei,spei_cancelado)
    values (d_fecha_hoy + current_time, p_new_sesion, r_spei.idusuario, p_new_referencia,
            r_spei.idorigen,r_spei.idgrupo,r_spei.idsocio,r_spei.idorigenp,r_spei.idproducto,r_spei.idauxiliar,
            r_spei.idcuenta,case when r_spei.cargoabono = 0 then 1 else 0 end,r_spei.monto,r_spei.idorden_spei,TRUE);
    b_encontro := TRUE;
  end loop;

  return case when b_encontro then 1 else 0 end;
end;
$$ language 'plpgsql';

-- NOTA: ESTA FUNCION NO ES COMPATIBLE PARA PRESTAMOS HIPOTECARIOS, SOLO POR PERIODO Y CRECIENTES
create or replace function
sai_bankingly_monto_adelanto_interes (integer,integer,integer,date,text) returns numeric as $$
declare
  r_aux         record;
  t_adela       text;
  t_aux         text;
  n_io_iva_spai numeric;
begin
  n_io_iva_spai := 0.00;

  select
  into   r_aux *
  from   auxiliares
  where  (idorigenp,idproducto,idauxiliar) = ($1,$2,$3);

  if r_aux.tipoamortizacion = 5 then
    return 0.00;
  end if;

  if $5 is NULL or trim($5) = '' then
    t_aux := sai_auxiliar($1,$2,$3,$4);
  else
    t_aux := $5;
  end if;

  t_adela := monto_interes_para_siguiente_fecha_de_pago($1, $2, $3, $4, split_part(t_aux,'|',5)::numeric
                                                          + split_part(t_aux,'|',12)::numeric, r_aux.tasaiod);
  n_io_iva_spai  := split_part(t_adela,'|',3)::numeric;

  return n_io_iva_spai;
end;
$$ language 'plpgsql';

create or replace function
sai_bankingly_limite_adelanto (integer,integer,integer,date,numeric,text) returns numeric as $$
declare
  r_aux         record;
  t_distr       text;
  t_adela       text;
  t_aux         text;
  i_cont        integer;
  n_suma        numeric;
  i_tp_a        integer;
  i_max         integer;
  n_io_iva_spai numeric;
begin
  select
  into   r_aux *
  from   auxiliares
  where  (idorigenp,idproducto,idauxiliar) = ($1,$2,$3) and estatus = 2;
  if not found then
    raise 'PRESTAMO NO ACTIVO...';
    return 0.00;
  end if;
  
  i_tp_a := r_aux.tipoamortizacion;
  
  if $6 is NULL or trim($6) = '' then
    t_aux := sai_auxiliar($1,$2,$3,$4);
  else
    t_aux := $6;
  end if;
  t_distr := sai_distribucion_prestamo ($1,$2,$3,$4,$5,t_aux);

  i_max := sai_findstr(t_distr,'|') + 1;

  n_suma := 0;
  for i_cont in 1..i_max
  loop
    n_suma := n_suma + split_part(t_distr,'|',i_cont)::numeric;
  end loop;

  if i_tp_a != 5 then
    t_adela := monto_interes_para_siguiente_fecha_de_pago($1,$2,$3,$4,split_part(t_aux,'|',5)::numeric + split_part(t_aux,'|',12)::numeric,
                                                          r_aux.tasaiod);
    n_io_iva_spai  := split_part(t_adela,'|',3)::numeric;
    n_suma         := n_suma - split_part(t_distr,'|',i_max)::numeric + n_io_iva_spai + r_aux.saldo;
  else
    if n_suma = 0 then
      select
      into     n_suma coalesce(abono,0.00)
      from     amortizaciones
      where    (idorigenp,idproducto,idauxiliar) = ($1,$2,$3) and not todopag
      order by vence asc
      limit    1;
      if not found then
        n_suma := 0;
      end if;
    end if;
  end if;

  return n_suma;
end;
$$ language 'plpgsql';


create or replace function
sai_bankingly_servicio_activo_inactivo () returns boolean as $$
declare
  d_fecha_servidor  date;
  d_fecha_origenes  date;
  b_estatus_oper    boolean;
  t_hora_ini        text;
  t_hora_fin        text;
  t_dow_operables   text;
begin
  select
  into   t_hora_ini, t_hora_fin, t_dow_operables dato1, dato2, dato3
  from   tablas
  where  idtabla = 'bankingly_banca_movil' and idelemento = 'horario_actividad';
  
  if sai_findstr(t_hora_ini,':') = 0 or sai_findstr(t_hora_fin,':') = 0 or
     split_part(t_hora_ini,':',1) > split_part(t_hora_fin,':',1)
  then
    raise notice 'MAL DEFINIDAS LAS HORAS EN LA TABLA: bankingly_banca_movil / horario_actividad';
    return NULL;
  end if;

  d_fecha_servidor := date(now());
  
  select
  into   d_fecha_origenes, b_estatus_oper date(fechatrabajo), estatus
  from   origenes
  limit  1;

  if t_dow_operables is not null and trim(t_dow_operables) != ''
  then
    if (sai_findstr(t_dow_operables,'|') = 0 and es_numero(t_dow_operables)) or
       sai_findstr(t_dow_operables,'|') > 0
    then
      b_estatus_oper := sai_texto1_like_texto2(extract(dow from d_fecha_origenes)::text,NULL,t_dow_operables,'|') > 0;
    end if;
  end if;

  return not ( d_fecha_servidor != d_fecha_origenes or
               current_time::time not between t_hora_ini::time and t_hora_fin::time or
               not b_estatus_oper );
end;
$$ language 'plpgsql';

create or replace function
sai_bankingly_servicio_activo_inactivo_spei () returns boolean as $$
declare
  d_fecha_servidor  date;
  d_fecha_origenes  date;
  b_estatus_oper    boolean;
  t_hora_ini        text;
  t_hora_fin        text;
  t_dow_operables   text;
begin
  select
  into   t_hora_ini, t_hora_fin, t_dow_operables dato1, dato2, dato3
  from   tablas
  where  idtabla = 'bankingly_banca_movil' and idelemento = 'spei_horario_actividad';
  
  if sai_findstr(t_hora_ini,':') = 0 or sai_findstr(t_hora_fin,':') = 0 or
     split_part(t_hora_ini,':',1) > split_part(t_hora_fin,':',1)
  then
    raise notice 'MAL DEFINIDAS LAS HORAS EN LA TABLA: bankingly_banca_movil / spei_horario_actividad';
    return NULL;
  end if;

  d_fecha_servidor := date(now());
  
  select
  into   d_fecha_origenes, b_estatus_oper date(fechatrabajo), estatus
  from   origenes
  limit  1;

  if t_dow_operables is not null and trim(t_dow_operables) != ''
  then
    if (sai_findstr(t_dow_operables,'|') = 0 and es_numero(t_dow_operables)) or
       sai_findstr(t_dow_operables,'|') > 0
    then
      b_estatus_oper := sai_texto1_like_texto2(extract(dow from d_fecha_origenes)::text,NULL,t_dow_operables,'|') > 0;
    end if;
  end if;

  return not ( d_fecha_servidor != d_fecha_origenes or
               current_time::time not between t_hora_ini::time and t_hora_fin::time or
               not b_estatus_oper );
end;
$$ language 'plpgsql';

create or replace function
sai_bankingly_termina_transaccion (date,integer,varchar,varchar) returns integer as $$
declare
  p_fecha       alias for $1;
  p_idusuario   alias for $2; 
  p_sesion      alias for $3;
  p_referencia  alias for $4;
  d_fecha       date;
  r_mov         record;
  r_prod        record;
  r_paso        record;
  i_idusuario   integer;
  i_resp        integer;
  i_movs        integer;
  t_ca          text;
  t_resp        text;
  t_sai_aux     text;
  t_dim         _text;
begin

  if p_fecha is NULL then
    select
    into   d_fecha date(fechatrabajo)
    from   origenes
    limit  1;
  else
    d_fecha := p_fecha;
  end if;

  if p_idusuario is NULL then
    select
    into   i_idusuario dato1
    from   tablas
    where  idtabla = 'bankingly_banca_movil' and idelemento = 'usuario_banca_movil';
  else
    i_idusuario := p_idusuario;
  end if;
  
  select
  into   r_paso *
  from   usuarios
  where  idusuario = i_idusuario and activo;
  if not found then
    raise notice 'USUARIO NO EXISTE O ESTA INACTIVO';
    return NULL;
  end if;

  select
  into   r_paso *
  from   bankingly_movimientos_ca
  where  (fecha::date, idusuario, sesion, referencia) = (d_fecha, i_idusuario, p_sesion, p_referencia) and aplicado;
  if not found then
    return 0;
  end if;

  delete
  from   bankingly_movimientos_ca
  where  (fecha::date,idusuario,sesion,referencia) = (d_fecha,i_idusuario,$3,$4) and aplicado;

  return 1;

end;
$$ language 'plpgsql';


create or replace function
sai_bankingly_detalle_transaccion_aplicada (date,integer,varchar,varchar) returns varchar as $$
declare
  r_movs    record;
  n_montos  numeric[];
begin

  n_montos := array[0,0,0,0,0,0,0,0]::numeric(12,2)[];
  for r_movs
  in  select *
      from   bankingly_movimientos_ca
      where  (fecha::date,idusuario,sesion,referencia) = ($1,$2,$3,$4) and cargoabono = 1 and aplicado
  loop
    -- Seguros Hipotecarios -----------
    if r_movs.idproducto in
         (select distinct idproductor
          from   referenciasp
          where  tiporeferencia = 6 and
                 (idorigenp,idproducto,idauxiliar) = (r_movs.idorigenp,r_movs.idproducto,r_movs.idauxiliar))
    then
      n_montos[1]:= r_movs.monto + r_movs.iva;
    end if;

    -- Comisiones ---------------------
    if r_movs.idproducto in
         (select distinct idproducto_comision
          from   tabla_comisiones)
    then
      n_montos[2] := r_movs.monto + r_movs.iva;
    end if;

    -- Prestamos ----------------------
    if r_movs.idproducto in
         (select idproducto
          from   productos
          where  idproducto = r_movs.idproducto and tipoproducto = 2)
    then
      n_montos[3] := r_movs.im;
      n_montos[4] := r_movs.ivaim;
      n_montos[5] := r_movs.io;
      n_montos[6] := r_movs.ivaio;
      n_montos[7] := (r_movs.monto - r_movs.io - r_movs.ivaio - r_movs.im - r_movs.ivaim);
    end if;

    -- Adelanto Interes ---------------
    if r_movs.idproducto in
         (select dato2::integer
          from   tablas
          where  idtabla = 'param' and idelemento = 'cobrar_interes_hasta_el_sig_pago' and dato1 = '1')
    then
      n_montos[8] := r_movs.monto;
    end if;
  end loop;

  return array_to_string(n_montos::text[],'|');
end;
$$ language 'plpgsql';

drop function if exists sai_bankingly_aplica_movs (date,integer,varchar,varchar);
create or replace function 
sai_bankingly_aplica_movs (date,integer,varchar,varchar,integer,boolean) returns integer as $$
declare
  p_fecha           alias for $1;
  p_idusuario       alias for $2; 
  p_sesion          alias for $3;
  p_referencia      alias for $4;
  p_idorden_spei    alias for $5;
  p_spei_cancelado  alias for $6;

  t_pre_concepto    text;
  t_concepto        text;
  t_concepto_spei   text;
  i_origenapl       integer;
  t_periodo         varchar;
  i_poliza          integer;
  i_cont            integer;
  
begin
  select
  into   i_origenapl idorigen
  from   usuarios
  where  idusuario = p_idusuario;

  select
  into   t_pre_concepto dato2
  from   tablas
  where  idtabla = 'bankingly_banca_movil' and idelemento = 'prefijo_concepto_poliza';
  if not found or t_pre_concepto is NULL or trim(t_pre_concepto) = '' then
    raise notice 'WARNING: TABLA bankingly_banca_movil / prefijo_concepto_poliza NO ESTA DEFINIDIA.'
                 'SE USARA UN CONCEPTO DE POLIZA GENERICO';
    t_pre_concepto := 'Traspaso Generic Banca Movil';
  end if;

  i_cont := 0;

  t_concepto_spei := '';
  if p_idorden_spei > 0 then
    t_concepto_spei := case when p_spei_cancelado
                            then ' Rechazo SPEI, Ajuste'
                            else ' Movimiento SPEI'
                       end;
  end if;
  t_concepto  := t_pre_concepto||' Ref: '||p_referencia||t_concepto_spei;
  t_periodo   := to_char(date(p_fecha),'yyyymm');
  i_poliza    := sai_poliza_nueva (i_origenapl, t_periodo, 3, 0, p_fecha, t_concepto, ''::varchar, TRUE, p_idusuario);

  i_cont := sai_temporal_procesa(p_idusuario, p_sesion, p_fecha, i_origenapl, i_poliza, 3, t_concepto, FALSE, TRUE);

  if i_cont is NOT NULL and i_cont > 0 then
    update temporal
    set    aplicado = TRUE
    where  idusuario = p_idusuario and sesion = p_sesion;

    delete
    from   temporal
    where  idusuario = p_idusuario and sesion = p_sesion and aplicado;

    update bankingly_movimientos_ca
    set    aplicado = TRUE
    where  idusuario = p_idusuario and sesion = p_sesion and date(fecha) = p_fecha and referencia = p_referencia;
  else
    raise exception 'sai_procesa_movs_bm_aplica: HUBO UN ERROR AL APLICAR LA FUNCION SAI_TEMPORAL_PROCESA';
  end if;
  
  return i_cont;
end;
$$ language 'plpgsql';


create or replace function
sai_bankingly_procesa_movs (_text) returns integer as $$
declare
  p_mat               alias for $1;
  p_idusuario         integer;
  p_sesion            varchar;
  p_fecha             date;
  p_referencia        text;
  p_idorigen          integer;
  p_idgrupo           integer;
  p_idsocio           integer;
  p_idorigenp         integer;
  p_idproducto        integer;
  p_idauxiliar        integer;
  p_idcuenta          varchar(20);
  p_es                boolean;
  p_monto             numeric;
  p_mov               integer;
  p_tipoamort         integer;
  p_aux               text;
  p_dist              text;
  p_tipomov           integer;
  p_iva               numeric;
  p_tp                integer;
  paso_txt            text;
  x_acapital          numeric;
  x_io_pag            numeric;
  x_io_cal            numeric;
  x_im_pag            numeric;
  x_im_cal            numeric;
  x_ivaio_pag         numeric;
  x_ivaio_cal         numeric;
  x_ivaim_pag         numeric;
  x_ivaim_cal         numeric;
  x_cmnpag_pag        numeric;
  x_cmnpag_cal        numeric;
  x_montoseg          numeric;
  x_ret               numeric;
  x_saldodiacum       numeric;
  x_t_ivaio           numeric;
  x_t_ivaim           numeric;
  x_iva               numeric;
  x_t_iva             numeric;
  r_paso              record;
  folio               integer;
  impte_desglo        numeric;
  cta_reembolso       varchar(20);
  x_prod_ret          integer;
  i_tipo_dist         integer;
  t_dim               _text;
  io_x                numeric;
  x_acapital2         numeric;
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
  r_amort             record;
  i_idorigena         integer;

begin

  p_idusuario     := p_mat[1];
  p_sesion        := p_mat[2];
  p_fecha         := p_mat[3];
  p_referencia    := p_mat[4];
  p_idorigen      := p_mat[5];
  p_idgrupo       := p_mat[6];
  p_idsocio       := p_mat[7];
  p_idorigenp     := p_mat[8];
  p_idproducto    := p_mat[9];
  p_idauxiliar    := p_mat[10];
  p_idcuenta      := p_mat[11];
  p_es            := p_mat[12];
  p_monto         := p_mat[13];
  p_iva           := p_mat[14];
  p_tipomov       := p_mat[15];
  p_tipoamort     := p_mat[16];
  p_tp            := p_mat[17];
  p_aux           := p_mat[18];
  p_mov           := p_mat[19];

  x_acapital      := p_monto;
  x_io_pag        := 0;
  x_io_cal        := 0;
  x_im_pag        := 0;
  x_im_cal        := 0;
  x_ivaio_pag     := 0;
  x_ivaio_cal     := 0;
  x_ivaim_pag     := 0;
  x_ivaim_cal     := 0;
  x_montoseg      := 0;
  x_cmnpag_pag    := 0;
  x_cmnpag_cal    := 0;
  x_saldodiacum   := 0;
  x_ret           := 0;
  x_iva           := 0;
  i_idorigena     := NULL;

  x_t_ivaio := sai_iva_segun_sucursal(p_idorigenp,p_idproducto,0);
  x_t_ivaim := sai_iva_segun_sucursal(p_idorigenp,p_idproducto,1);
  x_t_iva   := x_t_ivaio;

  if p_tp = 2 then

    if p_es then
      x_io_cal      := split_part(p_aux,'|',7)::numeric;
      x_im_cal      := split_part(p_aux,'|',16)::numeric;
      x_ivaio_cal   := split_part(p_aux,'|',18)::numeric;
      x_ivaim_cal   := split_part(p_aux,'|',19)::numeric;
      x_io_pag      := split_part(p_aux,'|',7)::numeric;
      x_im_pag      := split_part(p_aux,'|',16)::numeric;
      x_ivaio_pag   := split_part(p_aux,'|',18)::numeric;
      x_ivaim_pag   := split_part(p_aux,'|',19)::numeric;

      if (x_im_pag + x_ivaim_pag) > x_acapital then
        x_im_pag    := x_acapital / ((x_t_ivaim / 100) + 1);
        x_ivaim_pag := x_acapital - x_im_pag;
        x_acapital  := 0;
      else
        x_acapital  := x_acapital - (x_im_pag + x_ivaim_pag);
      end if;

      if x_acapital > 0 then

        i_tipo_dist := 0;
        if p_tipoamort = 5 then
          select
          into   i_tipo_dist int4(dato1)
          from   tablas
          where  lower(idtabla) = 'param' and
                 lower(idelemento) = 'distribuye_abonos_hipotecarios';
          if not found then
            i_tipo_dist := 0;
          end if;
          if i_tipo_dist is null then i_tipo_dist := 0; end if;
        end if;

        -- PARA LAS AMORTIZACIONES HIPOTECARIAS, EL MONTO DEBE DISTRIBUIRSE --
        -- PRIMERO EN UN SOLO PAGO Y LUEGO EN LOS SIGUIENTES -----------------
        if i_tipo_dist = 1 then

          x_acapital2 := 0;
          x_io_pag    := 0;
          x_ivaio_pag := 0;
          monto_fijo  := 0;

          if p_tipoamort = 5 then
            select
            into   monto_fijo monto
            from   monto_pagos_fijos
            where  idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar;
            if not found or monto_fijo is NULL then
              monto_fijo := 0;
            end if;
          end if;

          if monto_fijo > 0 then
            if no_usar_monto_pagos_fijos(p_idorigenp, p_idproducto, p_idauxiliar, monto_fijo, x_t_ivaio) then
              monto_fijo := 0;
            end if;
          end if;

          -- HAY QUE BUSCAR SI EL PRESTAMO TIENE PAGOS ADELANTADOS PARA EVITAR
          -- QUE SE COBREN INTERESES EN UN PAGO ADELANTADO, SOLO DEBE ABONARSE
          -- A CAPITAL -------------------------------------------------------
          pagos_adelantados := FALSE;
          for r_amort
          in  select   a1.vence, a1.abono, a1.io, idorigenp, idproducto, idauxiliar,
                       a1.abono - a1.abonopag as abono_a_pag,
                       a1.io - a1.iopag       as io_a_pag,
                       case when idamortizacion > 1 and monto_fijo > 0
                             then round(((monto_fijo - a1.abono - a1.io) - a1.iopag * (x_t_ivaio / 100)), 2)
                             else round(((a1.io - a1.iopag) * (x_t_ivaio / 100)), 2)
                       end                    as iva_io_a_pag
              from     amortizaciones as a1
              where    a1.idorigenp  = p_idorigenp and a1.idproducto = p_idproducto and a1.idauxiliar = p_idauxiliar and
                       a1.abono != a1.abonopag and todopag = FALSE
              order by vence
          loop
            if x_acapital > 0 then
              -- Si el prestamo ya tiene PAGOS ADELANTADOS, no se ---
              -- considera el IO ni su IVA de los proximos pagos ----
              if r_amort.vence > p_fecha and not pagos_adelantados then
                select
                into     paso_fecha vence
                from     amortizaciones
                where    (idorigenp,idproducto,idauxiliar) = (r_amort.idorigenp,r_amort.idproducto,r_amort.idauxiliar) and
                         vence < r_amort.vence
                order by vence desc
                limit    1;
                if not found then
                  pagos_adelantados := FALSE;
                end if;
                pagos_adelantados := (p_fecha between paso_fecha and r_amort.vence) = FALSE;
              end if;

              if not pagos_adelantados then
                if x_acapital > (r_amort.io_a_pag + r_amort.iva_io_a_pag) then
                  x_io_pag    := x_io_pag     + r_amort.io_a_pag;
                  x_ivaio_pag := x_ivaio_pag  + r_amort.iva_io_a_pag;
                  x_acapital  := x_acapital   - (r_amort.io_a_pag + r_amort.iva_io_a_pag);
                else
                  io_x        := round((x_acapital / (1 + (x_t_ivaio / 100))), 2);
                  x_io_pag    := x_io_pag    + io_x;
                  x_ivaio_pag := x_ivaio_pag + (x_acapital - io_x);
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
          if x_acapital != 0 and abs(x_acapital) <= 0.02 and x_ivaio_pag > 0 then
            if x_acapital < 0 then
              if x_ivaio_pag >= 0.02 then
                x_ivaio_pag := x_ivaio_pag + x_acapital;
                x_acapital := 0.0;
              end if;
            else
              x_ivaio_pag := x_ivaio_pag + x_acapital;
              x_acapital := 0.0;
            end if;
          end if;

          x_acapital := x_acapital2;

        else
          if (x_io_pag + x_ivaio_pag) > x_acapital then
            x_io_pag    := round(x_acapital / ((x_t_ivaio / 100) + 1), 2);
            x_ivaio_pag := x_acapital - x_io_pag;
            x_acapital  := 0;
          else
            x_acapital  := x_acapital - (x_io_pag + x_ivaio_pag);
            x_acapital  := case when x_acapital <= 0 then 0 else x_acapital end;
          end if;
        end if;
      else
        x_io_pag    := 0.0;
        x_ivaio_pag := 0.0;
      end if;
    end if;

    update bankingly_movimientos_ca
    set    io = x_io_pag, ivaio = x_ivaio_pag, im = x_im_pag, ivaim = x_ivaim_pag
    where  fecha::date = p_fecha and idusuario = p_idusuario and sesion = p_sesion and referencia = p_referencia and
           idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar;

  end if;

  if p_tp = 0 then
    x_io_cal      := split_part(p_aux,'|',2)::numeric;
    x_saldodiacum := split_part(p_aux,'|',3)::numeric;
    x_ret         := split_part(p_aux,'|',4)::numeric;
    x_io_pag      := 0;
  end if;

  if p_tp = 3 then
    x_iva           := p_iva;
  end if;

  if p_tp = 5 then
    x_iva           := p_iva;
  end if;

  if p_tp = 7 then
    select
    into   i_idorigena
           case when dato3 is null or trim(dato3) = ''
                then '0'::integer
                else dato3::integer
           end
    from   tablas
    where  idtabla = 'bankingly_banca_movil' and idelemento = 'cuenta_spei';
  end if;

  if x_acapital > 0 or x_io_pag > 0 or x_im_pag > 0 or x_cmnpag_pag > 0 then
    INSERT INTO temporal(idusuario,sesion,idorigen,idgrupo,idsocio,idorigenp,
                         idproducto,idauxiliar,esentrada,acapital,io_pag,io_cal,
                         im_pag,im_cal,idcuenta,aplicado,aiva,abonifio,
                         saldodiacum,ivaio_pag,ivaio_cal,ivaim_pag,ivaim_cal,
                         tipomov,mov,cpnp_pag,cpnp_cal,sai_aux,idorigena)
                 VALUES (p_idusuario,p_sesion,p_idorigen,p_idgrupo,
                         p_idsocio,p_idorigenp,p_idproducto,p_idauxiliar,p_es,
                         x_acapital,x_io_pag,x_io_cal,x_im_pag,x_im_cal,p_idcuenta,
                         FALSE,x_iva,0,x_saldodiacum,x_ivaio_pag,x_ivaio_cal,
                         x_ivaim_pag,x_ivaim_cal,p_tipomov,p_mov,x_cmnpag_pag,
                         x_cmnpag_cal,p_aux,i_idorigena);
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
                 VALUES (p_idusuario,p_sesion,p_idorigen,p_idgrupo,
                         p_idsocio,p_idorigenp,x_prod_ret,folio,TRUE,x_ret,0,0,0,0,
                         p_idcuenta,FALSE,0,0,0,0,0,0,0,0,p_mov,p_aux);

    if cta_reembolso NOT like '0' then
      p_mov := p_mov + 1;
      INSERT INTO temporal(idusuario,sesion,idorigen,idgrupo,idsocio,idorigenp,
                         idproducto,idauxiliar,esentrada,acapital,io_pag,io_cal,
                         im_pag,im_cal,idcuenta,aplicado,aiva,abonifio,
                         saldodiacum,ivaio_pag,ivaio_cal,ivaim_pag,ivaim_cal,
                         tipomov,mov,sai_aux)
                 VALUES (p_idusuario,p_sesion,p_idorigen,p_idgrupo,
                         p_idsocio,p_idorigenp,1,0,FALSE,x_ret,0,0,0,0,
                         cta_reembolso,FALSE,0,0,0,0,0,0,0,0,p_mov,p_aux);
    end if;
  end if;

  p_mov := p_mov + 1;

  return p_mov;
end;
$$ language 'plpgsql';


create or replace function
sai_bankingly_prestamo_cuanto(integer,integer,integer,date,integer,text)
returns text as $$
declare
  p_idorigenp   alias for $1;
  p_idproducto  alias for $2;
  p_idauxiliar  alias for $3;
  p_fecha       alias for $4;
  p_ta          alias for $5;
  p_aux         alias for $6;

  r_paso        record;
  n_montoseg    numeric;
  n_montoven    numeric;
  n_io          numeric;
  n_ivaio       numeric;
  n_im          numeric;
  n_ivaim       numeric;
  n_proxabono   numeric;
  n_comnopag    numeric;
  n_suma        numeric;
  t_aux         text;

begin

  n_suma      := 0;
  n_montoven  := 0;
  n_io        := 0;
  n_ivaio     := 0;
  n_im        := 0;
  n_ivaim     := 0;
  n_proxabono := 0;
  n_montoseg  := 0;
  n_comnopag  := 0;

  -- Monto seguro hipotecario
  if p_ta = 5 then
    select
    into   n_montoseg coalesce(sum(apagar + ivaapagar), 0)
    from   sai_prestamos_hipotecarios_calcula_seguro_a_pagar (p_idorigenp, p_idproducto, p_idauxiliar, p_fecha);
  end if;

  if p_aux is NULL or trim(p_aux) = '' then
    t_aux := sai_auxiliar(p_idorigenp, p_idproducto, p_idauxiliar, p_fecha);
  else
    t_aux := p_aux;
  end if;

  n_montoven    := split_part(t_aux,'|',5)::numeric;
  n_io          := split_part(t_aux,'|',7)::numeric;
  n_ivaio       := split_part(t_aux,'|',18)::numeric;
  n_im          := split_part(t_aux,'|',16)::numeric;
  n_ivaim       := split_part(t_aux,'|',19)::numeric;
  n_proxabono   := split_part(t_aux,'|',12)::numeric;

  select
  into   r_paso *
  from   tablas
  where  idtabla = 'param' and idelemento = 'nueva_comision_por_atraso';
  if found then
    select
    into   n_comnopag coalesce(monto_comision,0)
    from   comision_por_atraso (p_idorigenp, p_idproducto, p_idauxiliar, p_fecha, t_aux);
    if not found then
      n_comnopag := 0;
    end if;
  end if;

  n_suma := n_montoseg + n_montoven + n_io + n_ivaio + n_im + n_ivaim +
            n_proxabono + n_comnopag;

  return text(n_suma)||'|'||text(n_montoseg)||'|'||text(n_montoven)||'|'||
         text(n_io)||'|'||text(n_ivaio)||'|'||text(n_im)||'|'||
         text(n_ivaim)||'|'||text(n_proxabono)||'|'||
         text(n_comnopag)||'|'||split_part(t_aux,'|',1);
end;
$$ language 'plpgsql';

create or replace function
sai_bankingly_prestamo_adelanto_exacto (integer,integer,integer,date,numeric,numeric) returns numeric as $$
declare
  p_idorigenp       alias for $1;
  p_idproducto      alias for $2;
  p_idauxiliar      alias for $3;
  p_fecha           alias for $4;
  p_monto_a_pagar   alias for $5;
  p_monto_a_cubrir  alias for $6;
  n_monto_extra     numeric;
  n_monto_anterior  numeric;
  n_suma_abonos     numeric;
  b_adelantado      boolean;
  b_todo_ok         boolean;
  b_primera_vez     boolean;
  i_cont            integer;
  r_amort           record;
begin

  --- El socio ha ADELANTADO pagos ?? ---
  select
  into   i_cont coalesce(count(*),0)
  from   amortizaciones
  where  idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and
         vence >= p_fecha and todopag = TRUE;
  b_adelantado := i_cont > 0 ;

  n_monto_extra := p_monto_a_pagar - p_monto_a_cubrir;

  b_todo_ok         := FALSE;
  b_primera_vez     := TRUE;
  n_suma_abonos     := 0;
  n_monto_anterior  := 0;
  for r_amort
  in  select   vence, round((abono - abonopag), 2) as debe
      from     amortizaciones
      where    idorigenp = p_idorigenp and idproducto = p_idproducto and idauxiliar = p_idauxiliar and
               vence >= p_fecha and todopag = FALSE
      order by vence
  loop
    -- SI NO ESTA ADELANTADO, La siguiente amortizacion ya esta incluida en
    -- el pago normal, por lo que no debe considerarse para la suma de los
    -- pagos extras -------------------------------------------------------
    if not b_adelantado and b_primera_vez then
      b_primera_vez := FALSE;
      continue;
    end if;

    n_suma_abonos := n_suma_abonos + r_amort.debe;

    b_todo_ok := abs(n_suma_abonos - n_monto_extra) = 0;
    exit when b_todo_ok or n_suma_abonos > n_monto_extra;

    n_monto_anterior := n_suma_abonos;
  end loop;
  
  if b_todo_ok then
    return 0;
  end if;

  return n_monto_extra - n_monto_anterior;
end;
$$ language 'plpgsql';


create or replace function
sai_bankingly_desglosa_prestamo (date,integer,varchar,varchar) returns integer as $$
declare
  p_fecha               alias for $1;
  p_idusuario           alias for $2; 
  p_sesion              alias for $3;
  p_referencia          alias for $4;
  r_mov                 record;
  r_tab                 record;
  r_paso                record;
  r_seg                 record;
  r_aux_ah              record;
  r_aux_pr              record;
  r_com                 record;
  t_aux                 text;
  t_cuanto              text;
  t_adelanto            text;
  t_nom_arch            text;
  b_hay_adelint         boolean;
  b_adelantar_a_int     boolean;
  b_reg_resultado       boolean;
  b_hay_detalles        boolean;
  n_suma_total          numeric;
  n_montoven            numeric;
  n_proxabono           numeric;
  n_sobrante            numeric;
  n_aio_spai            numeric;
  n_aivaio_spai         numeric;
  n_dif                 numeric;
  n_total_io_iva_spai   numeric;
  n_adelanto_capital    numeric;
  n_montoseg            numeric;
  n_a_monto_seguro      numeric;
  n_a_iva_seguro        numeric;
  n_monto_mov           numeric;
  n_tasa_iva_io         numeric;
  n_a_monto_comision    numeric;
  n_a_iva_comision      numeric;
  i_idorigenp           integer;
  i_idproducto          integer;
  i_idauxiliar          integer;
  i_prod_destino        integer;
  i_paso                integer;
  i_dv                  integer;
  n_comnopag            numeric;
  
begin

  select
  into   r_tab *
  from   tablas
  where  idtabla = 'param' and idelemento = 'cobrar_interes_hasta_el_sig_pago' and dato1 = '1' and
         dato2 is not NULL and dato2::integer > 0;
  b_hay_adelint := found;

  -- TERMINAN VALIDACIONES PREVIAS -----------------------------------------------------------------
  raise notice ' ';
  raise notice '-----------------------------------------------------------------------------------------------';
  raise notice ' ';
  raise notice 'SE COMENZARA A APLICAR MOVIMIENTOS BANKINGLY:';

  n_suma_total := 0;
  n_montoseg   := 0;
  n_montoven   := 0;
  n_proxabono  := 0;
  n_comnopag   := 0;

  for r_mov
  in  select   mca.*, a.tipoamortizacion as ta, a.tasaio, a.idorigen, a.idgrupo, a.idsocio, a.saldo
      from     bankingly_movimientos_ca mca
               inner join auxiliares a using(idorigenp,idproducto,idauxiliar)
               inner join productos  p using(idproducto)
      where    mca.fecha::date = p_fecha and mca.idusuario = p_idusuario and mca.sesion = p_sesion and mca.referencia = p_referencia and
               mca.idorigenp > 0 and mca.idproducto > 0 and mca.idauxiliar > 0 and
               mca.cargoabono = 1 and p.tipoproducto = 2
      order by cargoabono
  loop
    raise notice ' ';
    raise notice ' + CREDITO: %-%-%, IMPORTE DESTINADO: %',
                 r_mov.idorigenp, r_mov.idproducto, r_mov.idauxiliar, r_mov.monto;
  
    if r_mov.sai_aux is NULL or r_mov.sai_aux = '' then
      t_aux := sai_auxiliar(r_mov.idorigenp, r_mov.idproducto, r_mov.idauxiliar, p_fecha);
    else
      t_aux := r_mov.sai_aux;
    end if;

    -- CUANTO DEBE EL PRESTAMO -----------------------------
    --  retorna: n_suma|n_montoseg|n_montoven|n_io|n_ivaio|n_im|n_ivaim|n_proxabono|n_comnopag|split_part(p_aux,'|',1);

    t_cuanto := sai_bankingly_prestamo_cuanto(r_mov.idorigenp, r_mov.idproducto, r_mov.idauxiliar, p_fecha, r_mov.ta, t_aux);

    n_suma_total := split_part(t_cuanto,'|',1)::numeric;
    n_montoseg   := split_part(t_cuanto,'|',2)::numeric;
    n_montoven   := split_part(t_cuanto,'|',3)::numeric;
    n_proxabono  := split_part(t_cuanto,'|',8)::numeric;
    n_comnopag   := split_part(t_cuanto,'|',9)::numeric;
    
    -- ------------------------------------------------------

    n_monto_mov := r_mov.monto;
    n_a_monto_comision := 0;

    if n_comnopag > 0 then
      select
      into   r_paso *
      from   tablas
      where  idtabla = 'param' and idelemento = 'nueva_comision_por_atraso';
      if found then
        for r_com
        in  select idproducto_comision, monto_comision
            from   comision_por_atraso (r_mov.idorigenp, r_mov.idproducto, r_mov.idauxiliar, p_fecha, t_aux)
        loop
          n_tasa_iva_io := sai_iva_segun_sucursal(r_mov.idorigenp, r_com.idproducto_comision, 0); -- el nombre de la variable, no importa, NO son int. ordinarios
          if r_com.monto_comision >= n_monto_mov then
            n_a_monto_comision  := round(n_monto_mov / (1 + (n_tasa_iva_io / 100)), 2);
            n_a_iva_comision    := n_monto_mov - n_a_monto_comision;
          else
            n_a_monto_comision  := round(r_com.monto_comision / (1 + (n_tasa_iva_io / 100)), 2);
            n_a_iva_comision    := r_com.monto_comision - n_a_monto_comision;
          end if;
          n_monto_mov  := n_monto_mov  - (n_a_monto_comision + n_a_iva_comision);
          n_suma_total := n_suma_total - (n_a_monto_comision + n_a_iva_comision);

          insert
          into   bankingly_movimientos_ca
                 (fecha, idusuario, sesion, referencia, idorigen, idgrupo, idsocio, idorigenp, idproducto, idauxiliar, cargoabono, monto, iva,
                  tipo_amort, sai_aux)
          values (r_mov.fecha, r_mov.idusuario, r_mov.sesion, r_mov.referencia, r_mov.idorigen, r_mov.idgrupo, r_mov.idsocio,        
                  0, r_com.idproducto_comision, 0, 1, n_a_monto_comision, n_a_iva_comision, 0, '');
          
          exit when n_monto_mov = 0;
        end loop;

        if n_monto_mov = 0 then

          raise notice '   > TODO EL IMPORTE QUE ERA DESTINADO AL CREDITO, PASO A COMISIONES';

          -- Si seguro chupo importe, eliminar movimiento de prestamo ----------
          delete
          from   bankingly_movimientos_ca
          where  fecha::date = date(r_mov.fecha) and idusuario = r_mov.idusuario and sesion = r_mov.sesion and referencia = r_mov.referencia and
                 idorigenp = r_mov.idorigenp and idproducto = r_mov.idproducto and idauxiliar = r_mov.idauxiliar;

        else

          raise notice '   > POR LAS COMISIONES, EL IMPORTE ORIGINAL DEL CREDITO: % SE REDUJO A: %',
                       r_mov.monto, n_monto_mov;
          update bankingly_movimientos_ca
          set    monto = n_monto_mov, sai_aux = case when sai_aux is NULL or sai_aux = '' then t_aux else sai_aux end
          where  fecha::date = date(r_mov.fecha) and idusuario = r_mov.idusuario and sesion = r_mov.sesion and referencia = r_mov.referencia and
                 idorigenp = r_mov.idorigenp and idproducto = r_mov.idproducto and idauxiliar = r_mov.idauxiliar;
        end if;
      end if;
    end if;

    continue when n_monto_mov = 0;

    n_sobrante  := 0;
    if r_mov.ta = 5 then
      if n_montoseg > 0 then
        for r_seg
        in  select   *
            from     sai_prestamos_hipotecarios_calcula_seguro_a_pagar (r_mov.idorigenp, r_mov.idproducto, r_mov.idauxiliar, p_fecha)
            order by idorigenpr, idproductor, idauxiliarr
        loop
          if (r_seg.apagar + r_seg.ivaapagar) >= n_monto_mov then
            n_tasa_iva_io     := sai_iva_segun_sucursal(r_mov.idorigenp, r_seg.idproductor, 0); -- el nombre de la variable, no importa, NO son int. ordinarios
            n_a_monto_seguro  := round(n_monto_mov / (1 + (n_tasa_iva_io / 100)), 2);
            n_a_iva_seguro    := n_monto_mov - n_a_monto_seguro;
          else
            n_a_monto_seguro  := r_seg.apagar;
            n_a_iva_seguro    := r_seg.ivaapagar;
          end if;
          n_monto_mov  := n_monto_mov  - (n_a_monto_seguro + n_a_iva_seguro);
          n_suma_total := n_suma_total - (n_a_monto_seguro + n_a_iva_seguro);

          -- Inserta Seguro ----
          raise notice '   > DESTINANDO AL SEGURO HIPOTECARIO: %-%-%, IMPORTE DESTINADO: %',
                       r_seg.idorigenpr, r_seg.idproductor, r_seg.idauxiliarr, n_a_monto_seguro;
          insert
          into   bankingly_movimientos_ca
                 (fecha, idusuario, sesion, referencia, idorigen, idgrupo, idsocio, idorigenp, idproducto, idauxiliar, cargoabono, monto, iva,
                  tipo_amort, sai_aux)
          values (r_mov.fecha, r_mov.idusuario, r_mov.sesion, r_mov.referencia, r_mov.idorigen, r_mov.idgrupo, r_mov.idsocio,
                  r_seg.idorigenpr, r_seg.idproductor, r_seg.idauxiliarr, 1, n_a_monto_seguro, n_a_iva_seguro, 0, '');

          exit when n_monto_mov = 0;
        end loop;

        if n_monto_mov = 0 then

          raise notice '   > TODO EL IMPORTE QUE ERA DESTINADO AL CREDITO, PASO A SEGUROS';

          -- Si seguro chupo importe, eliminar movimiento de prestamo ----------
          delete
          from   bankingly_movimientos_ca
          where  fecha::date = date(r_mov.fecha) and idusuario = r_mov.idusuario and sesion = r_mov.sesion and referencia = r_mov.referencia and
                 idorigenp = r_mov.idorigenp and idproducto = r_mov.idproducto and idauxiliar = r_mov.idauxiliar;

        else
          -- Modifica el monto del prestamo, rebaja los seguros, deja lo que sobro
          if n_monto_mov > n_suma_total then
            n_sobrante := sai_bankingly_prestamo_adelanto_exacto (r_mov.idorigenp, r_mov.idproducto, r_mov.idauxiliar,
                                                                  p_fecha, n_monto_mov, n_suma_total);
          end if;

          raise notice '   > POR LOS SEGUROS, EL IMPORTE ORIGINAL DEL CREDITO: % SE REDUJO A: %',
                       r_mov.monto, n_monto_mov - n_sobrante;

          update bankingly_movimientos_ca
          set    monto = n_monto_mov - n_sobrante, sai_aux = case when sai_aux is NULL or sai_aux = '' then t_aux else sai_aux end
          where  date(fecha) = date(r_mov.fecha) and idusuario = r_mov.idusuario and sesion = r_mov.sesion and referencia = r_mov.referencia and
                 idorigenp = r_mov.idorigenp and idproducto = r_mov.idproducto and idauxiliar = r_mov.idauxiliar;
        end if;
      else

        if n_monto_mov > n_suma_total then
          n_sobrante := sai_bankingly_prestamo_adelanto_exacto (r_mov.idorigenp, r_mov.idproducto, r_mov.idauxiliar,
                                                                p_fecha, n_monto_mov, n_suma_total);
          update bankingly_movimientos_ca
          set    monto = n_monto_mov - n_sobrante, sai_aux = case when sai_aux is NULL or sai_aux = '' then t_aux else sai_aux end
          where  date(fecha) = date(r_mov.fecha) and idusuario = r_mov.idusuario and sesion = r_mov.sesion and referencia = r_mov.referencia and
                 idorigenp = r_mov.idorigenp and idproducto = r_mov.idproducto and idauxiliar = r_mov.idauxiliar;
        end if;
      end if;

      -- Es el sobrante que no se puede adelantar, por no completar el capital de una amortizacion
      continue when n_sobrante = 0;

    else  -- r_mov.ta != 5
      raise notice '   > CREDITO SIN MODIFICAR, PASA COMPLETO !!';

      -- Si no hay sobrante, brinca a otro registro --------
      continue when (n_monto_mov - n_suma_total) <= 0;
      -- ---------------------------------------------------

      -- Si el monto_movimiento es mas alla de lo que debe y su saldo total, ya no hagas adelato a interes
      -- sobrante va ahorro
      if n_monto_mov >= ((r_mov.saldo - (n_montoven + n_proxabono)) + n_suma_total) then
        b_adelantar_a_int := FALSE;
        raise notice '   > POR SU MONTO EXCEDENTE, PODRA LIQUIDARSE EN SU TOTALIDAD !!';
        n_sobrante := n_monto_mov - ((r_mov.saldo - (n_montoven + n_proxabono)) + n_suma_total);
      else
        b_adelantar_a_int := TRUE;
        n_sobrante := n_monto_mov - n_suma_total;
      end if;

      -- SI HAY SOBRANTE Y TIENE OPCION A ADELANTO DE INTERES:
      if b_hay_adelint and b_adelantar_a_int then

        t_adelanto := monto_interes_para_siguiente_fecha_de_pago(r_mov.idorigenp, r_mov.idproducto, r_mov.idauxiliar,
                                                                 p_fecha, n_montoven + n_proxabono, r_mov.tasaio);
        -- Total de adelanto a interes original (spai: siguiente pago a intereres)
        n_total_io_iva_spai  := split_part(t_adelanto,'|',3)::numeric;

        -- En caso de que no haber adelanto por ser la misma fecha u otra cosa, brinca a otro registro
        continue when n_total_io_iva_spai = 0;
        
        if (n_sobrante - n_total_io_iva_spai >= 0) then
          n_aio_spai          := split_part(t_adelanto,'|',1)::numeric;
          n_aivaio_spai       := split_part(t_adelanto,'|',2)::numeric;
        else
          n_tasa_iva_io       := sai_iva_segun_sucursal(r_mov.idorigenp, r_mov.idproducto, 0);
          n_aio_spai          := round(n_sobrante / ((n_tasa_iva_io / 100) + 1), 2);
          n_aivaio_spai       := round((n_sobrante - n_aio_spai), 2);
        end if;

        -- Actualiza el total de adelanto a interes
        n_total_io_iva_spai  := n_aio_spai + n_aivaio_spai;

        -- Busca si existe el folio adelanto, si no aperturalo
        select
        into   r_aux_ah * 
        from   auxiliares
        where  idorigen = r_mov.idorigen and idgrupo = r_mov.idgrupo and idsocio = r_mov.idsocio and
               idproducto = r_tab.dato2::integer;
        if not found then
          i_idorigenp  := r_mov.idorigen;
          i_idproducto := r_tab.dato2::integer;
          i_idauxiliar := sai_ahorro_crea_apertura(array[text(r_mov.idorigen), text(r_mov.idgrupo), text(r_mov.idsocio),
                                         text(r_mov.idorigen), r_tab.dato2, text(p_fecha), text(p_idusuario), '0.00']);
        else
          i_idorigenp  := r_aux_ah.idorigenp;
          i_idproducto := r_aux_ah.idproducto;
          i_idauxiliar := r_aux_ah.idauxiliar;
        end if;

        -- Inserta adelanto a interes
        raise notice '   > DESTINANDO AL ADELANTO A INTERES: %-%-%, IMPORTE DESTINADO: %',
                     i_idorigenp,i_idproducto,i_idauxiliar,n_total_io_iva_spai;
        insert
        into   bankingly_movimientos_ca
               (fecha, idusuario, sesion, referencia, idorigen, idgrupo, idsocio, idorigenp, idproducto, idauxiliar, cargoabono, monto, iva,
                tipo_amort, sai_aux)
        values (r_mov.fecha, r_mov.idusuario, r_mov.sesion, r_mov.referencia, r_mov.idorigen, r_mov.idgrupo, r_mov.idsocio,
                i_idorigenp, i_idproducto, i_idauxiliar, 1, n_total_io_iva_spai, 0, 0, '');

        -- Modifica el monto del prestamo, rebaja el adelanto a interes
        raise notice '   > POR EL ADELANTO A INTERES, EL IMPORTE ORIGINAL DEL CREDITO: % SE REDUJO A: %',
                     r_mov.monto, r_mov.monto - n_total_io_iva_spai;
        update bankingly_movimientos_ca
        set    monto = monto - n_total_io_iva_spai, sai_aux = case when sai_aux is NULL or sai_aux = '' then t_aux else sai_aux end
        where  fecha::date = date(r_mov.fecha) and idusuario = r_mov.idusuario and sesion = r_mov.sesion and referencia = r_mov.referencia and
               idorigenp = r_mov.idorigenp and idproducto = r_mov.idproducto and idauxiliar = r_mov.idauxiliar;

        n_sobrante := n_sobrante - n_total_io_iva_spai;
      end if;

      -- Valida que el sobrante se vaya a saldo como adelanto a capital 
      if n_sobrante > (r_mov.saldo - (n_montoven + n_proxabono)) then
        n_sobrante := n_sobrante - (r_mov.saldo - (n_montoven + n_proxabono));
      else
        n_sobrante := 0.00;
      end if;

    end if;

    if n_sobrante > 0 then  -- Sobrante ajustalo al mismo folio del cargo
      update bankingly_movimientos_ca
      set    monto = monto - n_sobrante 
      where  idusuario = p_idusuario and sesion = p_sesion and date(fecha) = date(p_fecha) and referencia = p_referencia and
             cargoabono = 0;
    end if;
  end loop;

  return 1;
end;
$$ language 'plpgsql';

/*--- FUNCION PRINCIPAL ----*/
/* NOTAS:
  p_fecha     is NULL : Toma la de origenes
  p_idusuario is NULL : Toma de la tabla de configuracion
  Si el idusuario no existe o esta inactivo retorna NULL
*/
create or replace function
sai_bankingly_aplica_transaccion (date,integer,varchar,varchar) returns integer as $$
declare
  p_fecha           alias for $1;
  p_idusuario       alias for $2; 
  p_sesion          alias for $3;
  p_referencia      alias for $4;
  d_fecha           date;
  r_mov             record;
  r_prod            record;
  r_paso            record;
  i_idusuario       integer;
  i_resp            integer;
  i_movs            integer;
  i_c1              integer;
  i_c2              integer;
  i_idorden_spei    integer;
  b_spei_cancelado  boolean;
  t_ca              text;
  t_resp            text;
  t_sai_aux         text;
  t_dim             _text;
  
begin

  if p_fecha is NULL then
    select
    into   d_fecha date(fechatrabajo)
    from   origenes
    limit  1;
  else
    d_fecha := p_fecha;
  end if;

  if p_idusuario is NULL then
    select
    into   i_idusuario dato1
    from   tablas
    where  idtabla = 'bankingly_banca_movil' and idelemento = 'usuario_banca_movil';
  else
    i_idusuario := p_idusuario;
  end if;
  
  select
  into   r_paso *
  from   usuarios
  where  idusuario = i_idusuario and activo;
  if not found then
    raise notice 'USUARIO NO EXISTE O ESTA INACTIVO';
    return NULL;
  end if;

  select
  into   r_paso *
  from   bankingly_movimientos_ca
  where  (fecha::date, idusuario, sesion, referencia) = (d_fecha, i_idusuario, p_sesion, p_referencia) and aplicado;
  if found then
    raise notice 'HAY UN ERROR: ESTA SESION YA SE HABIA INTENTADO APLICAR ANTERIORMENTE, PERO POR ALGUNA EXTRAÑA RAZON '
                 'NO SE APLICO Y QUEDARON AUN LOS MOVIMIENTOS SIN PROCESAR. !! LLAME A SISTEMAS...!!';
    return -1;
  end if;
  
  i_resp := sai_bankingly_desglosa_prestamo (d_fecha, i_idusuario, p_sesion, p_referencia);

  i_movs := 1;
  i_idorden_spei   := 0;
  b_spei_cancelado := FALSE;
  for r_mov
  in  select *
      from   bankingly_movimientos_ca
      where  (fecha::date, idusuario, sesion, referencia) = (d_fecha, i_idusuario, p_sesion, p_referencia) and
             not aplicado and (coalesce(monto,0.00) + coalesce(iva,0.00) + coalesce(io,0.00) + coalesce(ivaio,0.00)
              + coalesce(im,0.00) + coalesce(ivaim,0.00)) > 0
  loop
    t_ca := case when r_mov.cargoabono = 1
                 then 't'
                 else 'f'
            end;

    i_idorden_spei   := r_mov.idorden_spei;
    b_spei_cancelado := r_mov.spei_cancelado;

    select
    into   r_prod *
    from   productos
    where  idproducto = r_mov.idproducto;
    
    t_sai_aux := '';
    if r_prod.tipoproducto not in (3,7) then
      t_sai_aux := case when r_prod.tipoproducto in (0,1,2,4,5,8)
                        then case when r_mov.sai_aux is NULL or r_mov.sai_aux = ''
                                  then sai_auxiliar(r_mov.idorigenp, r_mov.idproducto, r_mov.idauxiliar, r_mov.fecha::date)
                                  else r_mov.sai_aux
                             end
                        else ''
                   end;
    end if;

    t_dim := array[ text(r_mov.idusuario)     , text(r_mov.sesion)     , text(date(r_mov.fecha)) , text(r_mov.referencia)   ,
                    text(r_mov.idorigen)      , text(r_mov.idgrupo)    , text(r_mov.idsocio)     , text(r_mov.idorigenp)    ,
                    text(r_mov.idproducto)    , text(r_mov.idauxiliar) , r_mov.idcuenta          , t_ca                     ,
                    text(r_mov.monto)         , text(r_mov.iva)        , '0'                     , text(r_mov.tipo_amort)   ,
                    text(r_prod.tipoproducto) , t_sai_aux              , text(i_movs) ];

    i_movs := sai_bankingly_procesa_movs (t_dim);
  end loop;

  if i_movs > 1 then
    i_resp := sai_bankingly_aplica_movs (d_fecha,i_idusuario,p_sesion,p_referencia,i_idorden_spei,b_spei_cancelado);

    if b_spei_cancelado = FALSE and i_idorden_spei > 0 then
      -- ** Auto limpieza ** ----
      delete
      from   bankingly_movimientos_spei
      where  date(fecha) <= d_fecha - 2;

      insert
      into   bankingly_movimientos_spei
             (select idorden_spei,fecha,idusuario,sesion,referencia,idorigen,idgrupo,idsocio,
                     idorigenp,idproducto,idauxiliar,idcuenta,cargoabono,monto,spei_cancelado
              from   bankingly_movimientos_ca
              where  (fecha::date, idusuario, sesion, referencia) = (d_fecha, i_idusuario, p_sesion, p_referencia) and
                     idorden_spei > 0);
    end if;
  end if;
  
  return i_resp;
end;
$$ language 'plpgsql';
