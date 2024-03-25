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