



/*1.- REGLA: para poder usar banca movil el socio debe tener producto 141 capturado y en el producto 133 debe tener un saldo minimo de 50:Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='producto_banca_movil';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','producto_banca_movil','141');

/*2.- REGLA: Horario activo para banca movil:aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='horario_actividad';
INSERT INTO tablas(idtabla,idelemento,dato1,dato2)VALUES('bankingly_banca_movil','horario_actividad','06:00','21:00');

/*3.- REGLA: Grupo al que se le permite retirar de su producto configurado : Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='grupo_retiro';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','grupo_retiro','10'); 

/*4.- REGLA: Grupo al cual se le puede hacer una transferencia : Aplicado */
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='grupo_deposito';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','grupo_deposito','10|20|25');

/*6.- REGLA: Productos que pueden recibir transferencias::Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='productos_deposito';
INSERT INTO tablas(idtabla,idelemento,dato2)VALUES('bankingly_banca_movil','productos_deposito','110|120|125|171|133|33164|32664|32674|30114|30145|30154|30166|30175|31295|32744|33144|33154|33166|33175|33044|33064|32644|33244|33474|33264|34474|34374|33195|33374|33375|33475|34375|33474|34546|34474|34475|33746|33747|33844|34146|34544|34564|34566|34666|30164|34664|33266|33275|35475|35475|35244|35375|34044|35474|36644|36654|36664|36744|36754|36764|36844|36854|36864|34564|33964');
/*7.- REGLA: Lista negra(Socios bloqueados) existe ya una tabla llamada sopar donde el idelemento de esta tabla lo asociaremos al tipo*:Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='sopar';
INSERT INTO tablas(idtabla,idelemento,dato2)VALUES('bankingly_banca_movil','sopar','banca_movil_lista_negra');

/*9.- REGLA: Producto para retiro:Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='producto_retiro';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','producto_retiro','133');

/*10.- REGLA: Parametros para envio de sms:Aplicada*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='liga_envio_mensajes';
INSERT INTO tablas(idtabla,idelemento,dato2)VALUES('bankingly_banca_movil','liga_envio_mensajes','http://192.168.15.50/CSNsms/action.php?mensaje=_mensaje&numero=_numero');

/*11.- REGLA: Activacion o desactivacion de SMS:Aplicado 1:-Si 0.-No*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='smsactivo';
INSERT INTO tablas(idtabla,idelemento,nombre,dato1)VALUES('bankingly_banca_movil','smsactivo','activa los sms de csn movil','1');

/*12.- REGLA: Minimo para envio de sms:Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='monto_minimo_sms';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','monto_minimo_sms','1000');

/*13.- REGLA: Mensaje para retiro de cuenta propia:Aplicada*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='sms_retiro_cuenta_propia';
INSERT INTO tablas(idtabla,idelemento,dato2)VALUES('bankingly_banca_movil','sms_retiro_cuenta_propia','RETIRO: @productoOrigen@ @monto@ @fechayHora@ @autorizacionOrigen@');

/*14.- REGLA: Mensaje para retiro de cuenta de tercero:Aplicada*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='sms_retiro_cuenta_tercero';
INSERT INTO tablas(idtabla,idelemento,dato2)VALUES('bankingly_banca_movil','sms_retiro_cuenta_tercero','RETIRO: @productoOrigen@ @monto@ @fechayHora@ @autorizacionOrigen@');

/*15.- REGLA: Monto diario permitido en transferencias a menores */
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='monto_diario_menores';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','monto_diario_menores','5000');

/*16.- REGLA: Monto mensual permitido a menores */
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='monto_mensual_menores';
INSERT INTO tablas(idtabla,idelemento,nombre,dato1)VALUES('bankingly_banca_movil','monto_mensual_menores','Monto maximo por mes en UDIS','8907');

/*17.- REGLA: Mensaje para pago prestamo:Verificar */
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='mensaje_abono_prestamo';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','mensaje_abono_prestamo','tu mensaje');

/*18.- REGLA: Mensaje para operacion minima:verificar */
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='monto_operacion_minima_mensaje';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','monto_operacion_minima_mensaje','tu mensaje');

/*19.- REGLA: Usuario para banca movil:Aplicado*/    
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='usuario_banca_movil';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','usuario_banca_movil','1100');

/*20.- REGLA: Configuracion para saber el total de estados de cuenta que se mostrara en banca movil 
 1.-dato1:total  : Aplicado*/
 DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='total_estados_cuenta';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','total_estados_cuenta','3');

/*21.- REGLA: Los montos maximos y minimos que se pueden tranferir desde banca movil: Aplicado*/

/*DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='montomaximominimo';
INSERT INTO tablas(idtabla,idelemento,dato1,dato2,tipo)VALUES('bankingly_banca_movil','montomaximominimo','5000','0.1',0);*/

/*22.- REGLA: Monto maximo para transferencia banca movil por dia: Aplicado*/
/*DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='montomaximo';
INSERT INTO tablas(idtabla,idelemento,dato1,tipo)VALUES('bankingly_banca_movil','montomaximo','6000',0);*/

/*23.- REGLA: Mensaje para concepto de una poliza : Aplicado*/ 
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='prefijo_concepto_poliza';    
INSERT INTO tablas(idtabla,idelemento,dato2)VALUES('bankingly_banca_movil','prefijo_concepto_poliza','Transferencia Banca Movil Bankingly');


/*25.- REGLA: Activar o descativar uso de TDD:Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='activa_tdd';
INSERT INTO tablas(idtabla,idelemento,dato2)VALUES('bankingly_banca_movil','activa_tdd','1');

/*26.- REGLA: Producto para TDD: Aplicado*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='producto_tdd';
INSERT INTO tablas(idtabla,idelemento,dato1,dato2)VALUES('bankingly_banca_movil','producto_tdd','133','50.0');

/*27.- REGLA: Path SPEI Conexion de proyecto bankingly a ws SPEI(Propio)
dato1:URL(Se separo esta parte para poder hacer ping)
dato2: complemento path
dato3: tiempo que tarda en intentar hacer ping
: Aplicado */
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='speipath';
INSERT INTO tablas(idtabla,idelemento,dato1,dato2,dato3)VALUES('bankingly_banca_movil','speipath','http://192.168.15.128:7001/csn/','spei/v1.0/','6000');

/*28.- REGLA: credenciales para conectar al ws de Alestra
       dato1= usuario
       dato2= contraseña*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='wsdl_credenciales';
INSERT INTO tablas(idtabla,idelemento,dato1,dato2)VALUES('bankingly_banca_movil','wsdl_credenciales','ws_sanNico','wZ4XTX8GmNh');

/*29.- REGLA: Parametros para conectar al ws de Alestra
       dato1= host
       dato2= endpoint-wsdl
       dato3= port*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='wsdl_parametros';
INSERT INTO tablas(idtabla,idelemento,dato1,dato2,dato3)VALUES('bankingly_banca_movil','wsdl_parametros','200.15.1.143','siscoopAlternativeService','8080');


/*30.- REGLA: Validacion de UDIS minimo para menores en mes:*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='total_udis_mensual_menores';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','total_udis_mensual_menores','5000');

/*30.- REGLA: Validacion de pesos diarios menores :*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='total_deposito_diario_menores';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','total_deposito_diario_menores','5000');


/*30.- REGLA: Validacion de UDIS minimo para menores juveniles:*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='total_udis_mensual_juveniles';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','total_udis_mensual_juveniles','5000');

/*30.- REGLA: Validacion de pesos diarios menores:*/
DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='total_deposito_diario_juveniles';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','total_deposito_diario_juveniles','5000');


DELETE FROM tablas WHERE idtabla='bankingly_banca_movil' AND idelemento='total_deposito_diario_juveniles';
INSERT INTO tablas(idtabla,idelemento,dato1)VALUES('bankingly_banca_movil','total_deposito_diario_juveniles','5000');

/*31.-Validacion para minutos maximos a operar un tercero : Aplicado */
DELETE FROM tablas WHERE idtabla = 'bankingly_banca_movil' AND idelemento = 'timer_tercero_transaccion';
INSERT INTO tablas(idtabla,idelemento,nombre,dato1)VALUES('bankingly_banca_movil','timer_tercero_transaccion','Tiempo minimo para poder operar un tercecero','30');



