

/* ========================================Url SPEI Conexion STP:Aplicado================================*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='endpoint_stp';
INSERT INTO tablas(idtabla,idelemento,nombre,dato1)VALUES('bankingly_banca_movil','endpoint_stp','conexion a stp','https://demo.stpmex.com:7024/speiws/rest/');

/*============================================ Path enviar orden stp:Aplicado=========================================*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='path_registra_orden';
INSERT INTO tablas(idtabla,idelemento,nombre,dato1)VALUES('bankingly_banca_movil','path_registra_orden','complemento para url enviar orden','ordenPago/registra');

/*============== Empresa para generar ordenes SPEI:Aplicado===============================================*/
DELETE FROM tablas WHERE idtabla='spei_csn' AND idelemento='empresa';
INSERT INTO tablas(idtabla,idelemento,dato1)values('spei_csn','empresa','CSN795');

/*===================Cuenta contable para SPEI monto principal - comisiones :Aplicado======================*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='cuenta_spei';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','cuenta_spei','20407160101068');

/*====================Cuenta contable para comisiones:Aplicado==================================================*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='cuenta_spei_comisiones';
INSERT INTO tablas(idtabla,idelemento,dato1,dato2)VALUES('bankingly_banca_movil','cuenta_spei_comisiones','40309010101014','5.00');

/*====================Cuenta contable para comisiones:Aplicado==================================================*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='cuenta_spei_comisiones_iva';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','cuenta_spei_comisiones_iva','20407090101004');

/*===============================SMS para spei ordenes enviadas:Aplicado========================================*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='sms_actualizacion_estado_spei';
INSERT INTO tablas(idtabla,idelemento,dato2)values('bankingly_banca_movil','sms_actualizacion_estado_spei','@fechayHora@ @idorden@ @estado@ @folio@ @causadevolucion@');

/*===============================SMS para notificar que la cuenta a de alta en STP:Aplicado========================================*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='sms_notifica_creacion_cuenta';
INSERT INTO tablas(idtabla,idelemento,dato2)values('bankingly_banca_movil','sms_notifica_creacion_cuenta','@fechayHora@ @cuenta@ @estado@ @observacion@');

/*===============================SMS para spei ordenes enviadas========================================*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='path_registra_cuenta_persona_fisica';
INSERT INTO tablas(idtabla,idelemento,nombre,dato1)values('bankingly_banca_movil','path_registra_cuenta_persona_fisica','path para registra una cuenta fisica para spei','cuentaModule/fisica');

/*Path para actualizar el estatus de una orden SPEI:Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='ejecuta_orden_spei';
INSERT INTO tablas(idtabla,idelemento,nombre,dato2)VALUES('bankingly_banca_movil','ejecuta_orden_spei','actualizar el estado de una orden spei','http://192.168.15.127:7001/Banca/services/Transaction/ejecutaSpei');

/*Path para actualizar el registro de una clabe spei:Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='notifica_estado_cuenta_spei';
INSERT INTO tablas(idtabla,idelemento,nombre,dato2)VALUES('bankingly_banca_movil','notifica_estado_cuenta_spei','actualizar el registro de una cuenta spei','http://192.168.15.127:7001/Banca/services/Clients/notificaEstadoCuenta/');

/*Path para registrar una cuenta SPEI en STP White List :Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='registra_cuenta_spei';
INSERT INTO tablas(idtabla,idelemento,nombre,dato2)VALUES('bankingly_banca_movil','registra_cuenta_spei','registrar una cuenta spei white list','http://192.168.15.127:7001/csn/spei/v1.0/registraCuentaPersonaFisica');

/*Usuario para SPEI salida:Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='usuario_spei';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','usuario_spei','2222');

/*Montos maximo para spei:Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='spei_monto_maximo';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','spei_monto_maximo','20000');

DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='max_mxn_mensual';
INSERT INTO tablas(idtabla,idelemento,nombre,dato1)VALUES('bankingly_banca_movil','max_mxn_mensual','Maximo permitido en transferencias salida spei','100000');


/*Montos minimo para spei:Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='spei_monto_minimo';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','spei_monto_minimo','10');

/*Horario y dias activos para uso SPEI:Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='spei_horario_actividad';
INSERT INTO tablas(idtabla,idelemento,dato1,dato2,dato3)VALUES('bankingly_banca_movil','spei_horario_actividad','06:00','17:00','1|2|3|4|5');

/*Activa,desactiva uso ws registra cuentas persona fisica:Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='activa_desactiva_registra_cuenta';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','activa_desactiva_registra_cuenta','0');



DROP TABLE IF EXISTS clave_instituciones;

CREATE TABLE clave_instituciones(
idbanco INTEGER,
nombre TEXT,
PRIMARY KEY(idbanco));

INSERT INTO clave_instituciones VALUES(2001 ,'BANXICO');
INSERT INTO clave_instituciones VALUES(37006,'BANCOMEXT');
INSERT INTO clave_instituciones VALUES(37009,'BANOBRAS');
INSERT INTO clave_instituciones VALUES(37019,'BANJERCITO');
INSERT INTO clave_instituciones VALUES(37135,'NAFIN');
INSERT INTO clave_instituciones VALUES(37166,'BANSEFI');
INSERT INTO clave_instituciones VALUES(37168,'HIPOTECARIA FED');
INSERT INTO clave_instituciones VALUES(40002,'BANAMEX');
INSERT INTO clave_instituciones VALUES(40012,'BBVA BANCOMER');
INSERT INTO clave_instituciones VALUES(40014,'SANTANDER');
INSERT INTO clave_instituciones VALUES(40021,'HSBC');
INSERT INTO clave_instituciones VALUES(40030,'BAJIO');
INSERT INTO clave_instituciones VALUES(40036,'INBURSA');
INSERT INTO clave_instituciones VALUES(40042,'MIFEL');
INSERT INTO clave_instituciones VALUES(40044,'SCOTIABANK');
INSERT INTO clave_instituciones VALUES(40058,'BANREGIO');
INSERT INTO clave_instituciones VALUES(40059,'INVEX');
INSERT INTO clave_instituciones VALUES(40060,'BANSI');
INSERT INTO clave_instituciones VALUES(40062,'AFIRME');
INSERT INTO clave_instituciones VALUES(40072,'BANORTE');
INSERT INTO clave_instituciones VALUES(40102,'ACCENDO BANCO');
INSERT INTO clave_instituciones VALUES(40103,'AMERICAN EXPRES');
INSERT INTO clave_instituciones VALUES(40106,'BANK OF AMERICA');
INSERT INTO clave_instituciones VALUES(40108,'MUFG');
INSERT INTO clave_instituciones VALUES(40110,'JP MORGAN');
INSERT INTO clave_instituciones VALUES(40112,'BMONEX');
INSERT INTO clave_instituciones VALUES(40113,'VE POR MAS');
INSERT INTO clave_instituciones VALUES(40124,'DEUTSCHE');
INSERT INTO clave_instituciones VALUES(40126,'CREDIT SUISSE');
INSERT INTO clave_instituciones VALUES(40127,'AZTECA');
INSERT INTO clave_instituciones VALUES(40128,'AUTOFIN');
INSERT INTO clave_instituciones VALUES(40129,'BARCLAYS');
INSERT INTO clave_instituciones VALUES(40130,'COMPARTAMOS');
INSERT INTO clave_instituciones VALUES(40132,'MULTIVA BANCO');
INSERT INTO clave_instituciones VALUES(40133,'ACTINVER');
INSERT INTO clave_instituciones VALUES(40136,'INTERCAM BANCO');
INSERT INTO clave_instituciones VALUES(40137,'BANCOPPEL');
INSERT INTO clave_instituciones VALUES(40138,'ABC CAPITAL');
INSERT INTO clave_instituciones VALUES(40140,'CONSUBANCO');
INSERT INTO clave_instituciones VALUES(40141,'VOLKSWAGEN');
INSERT INTO clave_instituciones VALUES(40143,'CIBANCO');
INSERT INTO clave_instituciones VALUES(40145,'BBASE');
INSERT INTO clave_instituciones VALUES(40147,'BANKAOOL');
INSERT INTO clave_instituciones VALUES(40148,'PAGATODO');
INSERT INTO clave_instituciones VALUES(40150,'INMOBILIARIO');
INSERT INTO clave_instituciones VALUES(40151,'DONDE');
INSERT INTO clave_instituciones VALUES(40152,'BANCREA');
INSERT INTO clave_instituciones VALUES(40154,'BANCO FINTERRA');
INSERT INTO clave_instituciones VALUES(40155,'ICBC');
INSERT INTO clave_instituciones VALUES(40156,'SABADELL');
INSERT INTO clave_instituciones VALUES(40157,'SHINHAN');
INSERT INTO clave_instituciones VALUES(40158,'MIZUHO BANK');
INSERT INTO clave_instituciones VALUES(40160,'BANCO S3');
INSERT INTO clave_instituciones VALUES(90600,'MONEXCB');
INSERT INTO clave_instituciones VALUES(90601,'GBM');
INSERT INTO clave_instituciones VALUES(90602,'MASARI');
INSERT INTO clave_instituciones VALUES(90605,'VALUE');
INSERT INTO clave_instituciones VALUES(90606,'ESTRUCTURADORES');
INSERT INTO clave_instituciones VALUES(90608,'VECTOR');
INSERT INTO clave_instituciones VALUES(90613,'MULTIVA CBOLSA');
INSERT INTO clave_instituciones VALUES(90616,'FINAMEX');
INSERT INTO clave_instituciones VALUES(90617,'VALMEX');
INSERT INTO clave_instituciones VALUES(90620,'PROFUTURO');
INSERT INTO clave_instituciones VALUES(90630,'CB INTERCAM');
INSERT INTO clave_instituciones VALUES(90631,'CI BOLSA');
INSERT INTO clave_instituciones VALUES(90634,'FINCOMUN');
INSERT INTO clave_instituciones VALUES(90636,'HDI SEGUROS');
INSERT INTO clave_instituciones VALUES(90638,'AKALA');
INSERT INTO clave_instituciones VALUES(90642,'REFORMA');
INSERT INTO clave_instituciones VALUES(90646,'STP');
INSERT INTO clave_instituciones VALUES(90648,'EVERCORE');
INSERT INTO clave_instituciones VALUES(90652,'CREDICAPITAL');
INSERT INTO clave_instituciones VALUES(90653,'KUSPIT');
INSERT INTO clave_instituciones VALUES(90656,'UNAGRA');
INSERT INTO clave_instituciones VALUES(90659,'ASP INTEGRA OPC');
INSERT INTO clave_instituciones VALUES(90670,'LIBERTAD');
INSERT INTO clave_instituciones VALUES(90677,'CAJA POP MEXICA');
INSERT INTO clave_instituciones VALUES(90680,'CRISTOBAL COLON');
INSERT INTO clave_instituciones VALUES(90683,'CAJA TELEFONIST');
INSERT INTO clave_instituciones VALUES(90684,'TRANSFER');
INSERT INTO clave_instituciones VALUES(90685,'FONDO (FIRA)');
INSERT INTO clave_instituciones VALUES(90686,'INVERCAP');
INSERT INTO clave_instituciones VALUES(90689,'FOMPED');
INSERT INTO clave_instituciones VALUES(90902,'INDEVAL');
INSERT INTO clave_instituciones VALUES(90903,'CoDi Valida');
INSERT INTO clave_instituciones VALUES(90814,'SANTANDER2');
INSERT INTO clave_instituciones VALUES(846,'GEM-STP');


 DROP TABLE IF EXISTS historial_ordenes_spei;
CREATE TABLE historial_ordenes_spei(
 institucioncontraparte  numeric  ,
 empresa                 text     ,
 claverastreo            text     ,
 institucionoperante     numeric  ,
 monto                   numeric  ,
 tipopago                numeric  ,
 tipocuentaordenante     numeric  ,
 nombreordenante         text     ,
 cuentaordenante         text     ,
 rfccurpordenante        text     ,
 tipocuentabeneficiario  numeric  ,
 nombrebeneficiario      text     ,
 cuentabeneficiario      text     ,
 rfccurpbeneficiario     text     ,
 conceptopago            text     ,
 referencianumerica      numeric  ,
 fechaejecucion          timestamp,
 idorden                 numeric  ,
 estatus                 text     ,
 
 PRIMARY KEY (idorden, claverastreo));


 DROP TABLE IF EXISTS estados_ordenes_spei;
 CREATE TABLE estados_ordenes_spei(
 idorden          numeric  ,
 empresa          text     ,
 folioorigen      text     ,
 estado           text     ,
 causadevolucion  text     ,
 fhoraaplicado    timestamp,

 primary key(estado,idorden)
 );

DROP TABLE IF EXISTS ws_bankingly_clabe_activacion;
CREATE TABLE ws_bankingly_clabe_activacion(
  clabe text,
  empresa text,
  estado varchar(45),
  fecha_hora timestamp,
  observacion text,
  activa boolean default false,

  PRIMARY KEY(clabe)

);


