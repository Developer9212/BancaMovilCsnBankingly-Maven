

/*Secuencia para el autoincremento de usuarios que se van matriculando*/
DROP SEQUENCE sec_usuarios_bankingly CASCADE;
create sequence sec_usuarios_bankingly 
start with 1
increment by 1
maxvalue 99999
minvalue 1
cycle;

DROP TABLE IF EXISTS banca_movil_usuarios_bankingly;
    CREATE TABLE banca_movil_usuarios_bankingly(
    idorigen       integer   ,
    idgrupo        integer   ,
    idsocio        integer   ,
    alias_usuario  text,
    idorigenp      integer   ,
    idproducto     integer   ,
    idauxiliar     integer   ,
    estatus        boolean   ,

    PRIMARY KEY (alias_usuario),
    FOREIGN KEY (idorigen,idgrupo,idsocio) REFERENCES personas(idorigen,idgrupo,idsocio),
    FOREIGN KEY (idorigenp,idproducto,idauxiliar) REFERENCES auxiliares(idorigenp,idproducto,idauxiliar));



/*Tabla para saber que tipo de producto esta en la cuenta, catalogo proporcionado por Bankingly*/
DROP TABLE IF EXISTS tipos_cuenta_bankingly;
create table tipos_cuenta_bankingly(
idproducto numeric,
producttypeid numeric,
producttypename text,
descripcion text,
PRIMARY KEY(idproducto)
);


/*Tabla para validar estatus de OPAS, catalogo proporcionado por Bankingly*/
DROP TABLE IF EXISTS catalogo_status_bankingly;
create table catalogo_status_bankingly(
productstatusid numeric,
description     text,
descripcion     text,
statusdb        integer,

PRIMARY KEY(productstatusid)
);

INSERT INTO catalogo_status_bankingly VALUES(0,'Undefined','Indefinido',0);
INSERT INTO catalogo_status_bankingly VALUES(1,'Active','Activo',2);
INSERT INTO catalogo_status_bankingly VALUES(2,'Deleted','Eliminado',3);
INSERT INTO catalogo_status_bankingly VALUES(3,'Inactive','Inactivo',4);


/*Tabla para validar estatus de cuotas de prestamos, catalogo proporcionado por Bankingly*/
DROP TABLE IF EXISTS loan_fee_statusb;
CREATE TABLE loan_fee_statusb(
 id            integer,
 description   text,
 descripcion   text,
 PRIMARY KEY (id));


 INSERT INTO loan_fee_statusb VALUES(0,'Undefined','Indefinido');
 INSERT INTO loan_fee_statusb VALUES(1,'Active   ','Activo');
 INSERT INTO loan_fee_statusb VALUES(2,'Expired  ','Vencido');
 INSERT INTO loan_fee_statusb VALUES(3,'Paid     ','Pagado');

/*Secuencia para el autoincremento del indentificiador de las trnasaferencias*/
DROP SEQUENCE IF EXISTS sec_transfers_bankingly CASCADE;
create sequence sec_transfers_bankingly
increment by 1
maxvalue 9999999
minvalue 100
cycle;


/*Tabla donde se guardan las tranferencias que se hacen desde el canal o el aplicativo movil*/
DROP TABLE IF EXISTS transferencias_bankingly;
CREATE TABLE transferencias_bankingly(
 idtransaction               integer default nextval('sec_transfers_bankingly'),
 subtransactiontypeid        text ,
 currencyid                  text     ,
 valuedate                   text,
 transactiontypeid           text  ,
 transactionstatusid         text  ,
 clientbankidentifier        text     ,
 debitproductbankidentifier  text     ,
 debitproducttypeid          text  ,
 debitcurrencyid             text     ,
 creditproductbankidentifier text     ,
 creditproducttypeid         text  ,
 creditcurrencyid            text     ,
 amount                      text  ,
 notifyto                    text     ,
 notificationchannelid       text ,
 transactionid               text  ,
 destinationname             text     ,
 destinationbank             text     ,
 description                 text     ,
 bankroutingnumber           text     ,
 sourcename                  text     ,
 sourcebank                  text     ,
 regulationamountexceeded    boolean  ,
 sourcefunds                 text     ,
 destinationfunds            text     ,
 transactioncost             text  ,
 transactioncostcurrencyid   text     ,
 exchangerate                numeric  ,
 destinationdocumentid_documentnumber text,
 destinationdocumentid_documenttype text,
 sourcedocumentid_documentnumber text,
 sourcedocumentid_documenttype text,
 userdocumentid_documentnumber text,
 userdocumentid_documenttype text,
 fechaejecucion              timestamp);


/*Tabla para almacenar productos Terceros*/
DROP TABLE IF EXISTS productos_terceros_bankingly;
CREATE TABLE productos_terceros_bankingly(
     clientBankIdentifiers text,
     thirdPartyProductNumber text,
     thirdPartyProductBankIdentifier text,
     alias text,
     currencyId text,
     transactionSubType numeric,
     thirdPartyProductType numeric,
     productType numeric,
     ownerName text,
     ownerCountryId text,
     ownerEmail text,
     ownerCity text,
     ownerAddress text,
     ownerDocumentId_integrationProperties text,
     ownerDocumentId_documentNumber text,
     ownerDocumentId_documentType text,
     ownerPhoneNumber text,
     bank_bankId numeric,
     bank_description text,
     bank_routingCode text,
     bank_countryId text,
     bank_headQuartersAddress text,
     correspondentBank_bankId numeric,
     correspondentBank_description text,
     correspondentBank_routingCode text,
     correspondentBank_countryId text,
     correspondentBank_headQuartersAddress text,
     userDocumentId_integrationProperties text,
     userDocumentId_documentNumber text,
     userDocumentId_documentType text,
     
     primary key(thirdPartyProductBankIdentifier));  


DROP TABLE IF EXISTS amortizaciones_cubiertas_abonos;
CREATE TABLE amortizaciones_cubiertas_abonos(
idamortizacion  integer ,
 idorigenp      integer ,
 idproducto     integer ,
 idauxiliar     integer ,
 vence          date    ,
 todopag        boolean ,
 atiempo        boolean ,
 abono          numeric ,
 abonopag       numeric ,
 fecha_pago     date    ,
 monto_abonado  numeric ,
 diasvencidos   integer ,
 io             numeric ,
 im             numeric );


  




