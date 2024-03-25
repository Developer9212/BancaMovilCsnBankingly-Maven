

/*Otras tablas de configuracion especifica para CSN*/
DROP TABLE IF EXISTS historial_ordenes_spei;
create table historial_ordenes_spei(
    institucionContraparte numeric,
    empresa text,
    claveRastreo text,
    institucionOperante numeric,
    monto numeric,
    tipoPago numeric,
    tipoCuentaOrdenante numeric,
    nombreOrdenante text,
    cuentaOrdenante text,
    rfcCurpOrdenante text,
    tipoCuentaBeneficiario numeric,
    nombreBeneficiario text,
    cuentaBeneficiario text,
    rfcCurpBeneficiario text,
    conceptoPago text,
    referenciaNumerica numeric,
    fechaejecucion timestamp,
    idorden numeric,
    estatus text,
    
    PRIMARY KEY(idorden,claveRastreo)
);



DROP TABLE IF EXISTS estados_ordenes_spei;
create table estados_ordenes_spei(
    idorden numeric,
    empresa text,
    folioorigen text,
    estado text,
    causadevolucion text,
    fhoraaplicado timestamp,

    primary key(estado)
    
);


DROP TABLE IF EXISTS tipos_cuenta_bankingly;
create table tipos_cuenta_bankingly(
idproducto numeric,
producttypeid numeric,
producttypename text,
descripcion text,
PRIMARY KEY(idproducto)
);
   
     INSERT INTO  tipos_cuenta_bankingly VALUES(133,1,'CurrentAccount  ','Tarjeta de Debito CSN');
     INSERT INTO  tipos_cuenta_bankingly VALUES(125,2,'SavingsAccount  ','Ahorro Juvenil');
     INSERT INTO  tipos_cuenta_bankingly VALUES(110,2,'SavingsAccount  ','Ahorro Mayor');
     INSERT INTO  tipos_cuenta_bankingly VALUES(120,2,'SavingsAccount  ','Ahorro Menor');
     INSERT INTO  tipos_cuenta_bankingly VALUES(205,4,'FixedTermDeposit','Inverahorro');
     INSERT INTO  tipos_cuenta_bankingly VALUES(36754,5,'Loan','Credito Aniversario Elite Subsecuente Reestr');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34146,5,'Loan','Pmo AUTOcredito MxE');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33266,5,'Loan','Pmo. Elite s/aval Consumo Otros Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34490,5,'Loan','CrediCasa CSN Med y Res 20 Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33764,5,'Loan','Ordinario CSN Auto Credito Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33790,5,'Loan','Pmo AutoCredito CSN Consumo Otros Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33244,5,'Loan','Pmo. Elite s/aval Consumo Personal');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33264,5,'Loan','Pmo. Elite s/aval Consumo Personal Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33644,5,'Loan','Pmo LCR CrediJoven Consumo Personal');
     INSERT INTO  tipos_cuenta_bankingly VALUES(35491,5,'Loan','CrediCasa SustHipo + liq Med y Res Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33175,5,'Loan','Pmo. Elite c/aval a la Vievienda Int Soc');
     INSERT INTO  tipos_cuenta_bankingly VALUES(36854,5,'Loan','Credito Aniversario Elite s/aval Reestr');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33491,5,'Loan','CrediCasa Interes Social Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33164,5,'Loan','Pmo. Elite c/aval Consumo Personal Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33375,5,'Loan','SHF Interes Social');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33166,5,'Loan','Pmo. Elite c/aval Consumo Otros Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33144,5,'Loan','Pmo. Elite c/aval Consumo Personal');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34164,5,'Loan','Ordinario CSN Auto Credito MxE Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(30154,5,'Loan','Pmo. Ordinario Consumo Personal Reestr');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33475,5,'Loan','CrediCasa CSN Interes Social');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34374,5,'Loan','CrediCasa CSN Media y Residencial 15');
     INSERT INTO  tipos_cuenta_bankingly VALUES(32744,5,'Loan','LCR Confianza Consumo Personal');
     INSERT INTO  tipos_cuenta_bankingly VALUES(35244,5,'Loan','Crediplus CSN Consumo Personal');
     INSERT INTO  tipos_cuenta_bankingly VALUES(31290,5,'Loan','Pmo. Simple Comercial Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33374,5,'Loan','SHF Media y Residencial');
     INSERT INTO  tipos_cuenta_bankingly VALUES(36664,5,'Loan','Credito Aniversario Personal Renovado');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33275,5,'Loan','Pmo. Elite s/aval a la Vievienda Int Soc');
     INSERT INTO  tipos_cuenta_bankingly VALUES(32764,5,'Loan','LCR Confianza Consumo Personal Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34546,5,'Loan','LCR Gerencial Elite Consumo Otros');
     INSERT INTO  tipos_cuenta_bankingly VALUES(36690,5,'Loan','Credito Aniversario Personal Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34090,5,'Loan','Auto Seguro CSN Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34664,5,'Loan','Pmo. Elite Subsecuente Consumo Personal Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34644,5,'Loan','Pmo. Elite Subsecuente Consumo Personal');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34666,5,'Loan','Pmo. Elite Subsecuente Consumo Otros Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(35474,5,'Loan','CrediCasa SustHipoteca + Liquidez Med y Res');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34390,5,'Loan','CrediCasa CSN Media y Res 15 COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33154,5,'Loan','Pmo. Elite c/aval Consumo Personal Reestr');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33474,5,'Loan','CrediCasa CSN Media y Residencial');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33195,5,'Loan','Pmo. Elite c/aval a la Vievienda Int Soc Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34475,5,'Loan','CrediCasa CSN Interes Social 20');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33746,5,'Loan','Pmo AutoCredito CSN');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34690,5,'Loan','Pmo. Elite Subsecuente Consu Per Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34474,5,'Loan','CrediCasa CSN Media y Residencial 20');
     INSERT INTO  tipos_cuenta_bankingly VALUES(36790,5,'Loan','Credito Aniversario Elite Subs Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(36654,5,'Loan','Credito Aniversario Personal Reestr');
     INSERT INTO  tipos_cuenta_bankingly VALUES(32644,5,'Loan','LCR Gerencial Consumo Personal');
     INSERT INTO  tipos_cuenta_bankingly VALUES(35475,5,'Loan','CrediCasa SustHipoteca + Liquidez Int Soc');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34190,5,'Loan','Pmo. AUTOcredito MxE COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34566,5,'Loan','LCR Gerencial Elite Consumo Otros Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34544,5,'Loan','LCR Gerencial Elite Consumo Personal');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33044,5,'Loan','Credi-10 Consumo Personal');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33064,5,'Loan','Credi-10 Consumo Personal Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34044,5,'Loan','Auto Seguro CSN');
     INSERT INTO  tipos_cuenta_bankingly VALUES(35375,5,'Loan','Pmo. Simple Elite a la Vivienda Int Soc');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33844,5,'Loan','Seguro de AutoCredito CSN');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34564,5,'Loan','LCR Gerencial Elite Consumo Personal Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33964,5,'Loan','Credi10 Elite Consumo Personal Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33690,5,'Loan','Pmo LCR CrediJoven Consumo Personal Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33190,5,'Loan','Pmo. Elite c/aval Consumo Personal Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34391,5,'Loan','CrediCasa CSN De Interes Soc 15 Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33390,5,'Loan','SHF Media y Residencial Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33090,5,'Loan','Credi-10 Consumo Personal Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(31295,5,'Loan','Pmo. Simple a la Vivienda Int Soc Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(32790,5,'Loan','LCR Confianza Consumo Personal Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33490,5,'Loan','CrediCasa CSN Media y Res. Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33290,5,'Loan','Pmo. Elite s/aval Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(32674,5,'Loan','LCR Gerencial a la Vivienda Med y Res');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34375,5,'Loan','CrediCasa CSN De Interes Social 15');
     INSERT INTO  tipos_cuenta_bankingly VALUES(36864,5,'Loan','Credito Aniversario Elite s/aval Personal Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(30190,5,'Loan','Pmo. Ordinario Consumo Personal Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(36744,5,'Loan','Credito Aniversario Elite Subsecuente');
     INSERT INTO  tipos_cuenta_bankingly VALUES(36764,5,'Loan','Credito Aniversario Elite Subsecuente Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(36844,5,'Loan','Credito Aniversario Elite s/aval consumo Personal');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33391,5,'Loan','SHF Interes Social Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(30166,5,'Loan','Pmo. Ordinario Consumo Otros Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(32690,5,'Loan','LCR Gerencial Consumo Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(30175,5,'Loan','Pmo. Ordinario a la Vievienda Int Soc');
     INSERT INTO  tipos_cuenta_bankingly VALUES(30144,5,'Loan','Pmo. Ordinario Consumo Personal');
     INSERT INTO  tipos_cuenta_bankingly VALUES(30145,5,'Loan','Pmo. Ordinario Consumo ABCD');
     INSERT INTO  tipos_cuenta_bankingly VALUES(30146,5,'Loan','Pmo. Ordinario Consumo Otros');
     INSERT INTO  tipos_cuenta_bankingly VALUES(30114,5,'Loan','Pmo. Ordinario Comercial Quirografario');
     INSERT INTO  tipos_cuenta_bankingly VALUES(34590,5,'Loan','LCR Gerencial Elite Consumo Personal Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(30164,5,'Loan','Pmo. Ordinario Consumo Personal Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(36644,5,'Loan','Credito Aniversario Personal');
     INSERT INTO  tipos_cuenta_bankingly VALUES(32664,5,'Loan','LCR Gerencial Consumo Personal Renov');
     INSERT INTO  tipos_cuenta_bankingly VALUES(35390,5,'Loan','Pmo. Simple Elite a la Viv Int. Soc. Renov COVID19');
     INSERT INTO  tipos_cuenta_bankingly VALUES(33990,5,'Loan','Credi10 Elite Consumo Personal Renov COVID19');
