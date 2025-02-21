package com.fenoreste.rest.WsTDD;

import com.fenoreste.rest.Util.AbstractFacade;
import com.fenoreste.rest.Util.UtilidadesGenerales;
import com.fenoreste.rest.entidades.Tabla;
import com.fenoreste.rest.entidades.TablaPK;
import com.fenoreste.rest.entidades.WsSiscoopFoliosTarjetas1;
import com.fenoreste.rest.entidades.WsSiscoopFoliosTarjetasPK1;
import javax.persistence.EntityManager;
import com.syc.ws.endpoint.siscoop.BalanceQueryResponseDto;
import com.syc.ws.endpoint.siscoop.DoWithdrawalAccountResponse;
import com.syc.ws.endpoint.siscoop.LoadBalanceResponse;
import consumo_tdd.Siscoop_TDD;
import javax.persistence.Query;

/**
 *
 * @author Elliot
 */
public class TarjetaDeDebito {

    // CONSULTA Y ACTUALIZA EL SALDO DE LA TarjetaDeDebito
    public Tabla productoTddWS(EntityManager em) {
        try {
            TablaPK pkt = new TablaPK("identificador_uso_tdd", "activa");
            Tabla tb = em.find(Tabla.class, pkt);
            if (tb != null) {
                return tb;
            } else {
                return null;
            }
        } catch (Exception e) {
            System.out.println("No existe producto activo para tdd:" + e.getMessage());
        }
        return null;
    }

    // PRODUCTO VALIDO PARA LA TDD
    public Tabla productoTddwebservice(EntityManager em) {
        Tabla tabla = null;
        System.out.println("Llegando a buscar el producto para Tarjeta de debito....");
        try {
            EntityManager d = AbstractFacade.conexion();
            // Producto de la tdd

            TablaPK tablasPK = new TablaPK("bankingly_banca_movil", "producto_tdd");
            tabla = d.find(Tabla.class, tablasPK);

        } catch (NumberFormatException e) {
            System.out.println("Error en consultar producto en producto_para_webservice de TarjetaDeDebito." + e.getMessage());
            return tabla;
        }
        return tabla;
    }

    public WsSiscoopFoliosTarjetas1 buscaTarjetaTDD(int idorigenp, int idproducto, int idauxiliar, EntityManager em) {
        System.out.println("Buscando idtarjeta:"+idorigenp+",idproducto:"+idproducto+","+idauxiliar);
        WsSiscoopFoliosTarjetasPK1 foliosPK1 = new WsSiscoopFoliosTarjetasPK1(idorigenp, idproducto, idauxiliar);
        WsSiscoopFoliosTarjetas1 wsSiscoopFoliosTarjetas = new WsSiscoopFoliosTarjetas1();
        try {
            String consulta = " SELECT w.* "
                    + "         FROM ws_siscoop_folios_tarjetas w "
                    + "         INNER JOIN ws_siscoop_tarjetas td using(idtarjeta)"
                    + "         WHERE w.idorigenp = ? "
                    + "         AND w.idproducto = ?"
                    + "         AND w.idauxiliar = ?"
                    + "          AND td.fecha_vencimiento > (select distinct fechatrabajo from origenes limit 1)";
            System.out.println("Consulta tarjeta:"+consulta);
            Query query = em.createNativeQuery(consulta, WsSiscoopFoliosTarjetas1.class);
            query.setParameter(1, idorigenp);
            query.setParameter(2, idproducto);
            query.setParameter(3, idauxiliar);
            wsSiscoopFoliosTarjetas = (WsSiscoopFoliosTarjetas1) query.getSingleResult();
            if (wsSiscoopFoliosTarjetas != null) {
                wsSiscoopFoliosTarjetas.setActiva(wsSiscoopFoliosTarjetas.getActiva());
                wsSiscoopFoliosTarjetas.setAsignada(wsSiscoopFoliosTarjetas.getAsignada());
                wsSiscoopFoliosTarjetas.setBloqueada(wsSiscoopFoliosTarjetas.getBloqueada());
                wsSiscoopFoliosTarjetas.setWsSiscoopFoliosTarjetasPK(foliosPK1);
            }
        } catch (Exception e) {
            System.out.println("Error en buscaTarjetaTDD de WsSiscoopFoliosTarjetas: " + e.getMessage());
            return wsSiscoopFoliosTarjetas;
        }
        return wsSiscoopFoliosTarjetas;
    }

    public BalanceQueryResponseDto saldoTDD(WsSiscoopFoliosTarjetasPK1 foliosPK) {
        BalanceQueryResponseDto response = new BalanceQueryResponseDto();
        EntityManager em=AbstractFacade.conexion();
        WsSiscoopFoliosTarjetas1 tarjeta = em.find(WsSiscoopFoliosTarjetas1.class, foliosPK);
        System.out.println("Buscando el saldo para la tarjeta:"+tarjeta.getIdtarjeta());
        try {           
            if (tarjeta.getActiva()) { 
                /*response.setAvailableAmount(200000);                     
                response.setCode(1);
                response.setDescription("activa");*/
            
                response = conexionSiscoop().getSiscoop().getBalanceQuery(tarjeta.getIdtarjeta());
            } else {
                response.setDescription("La tarjeta esta inactiva: " + tarjeta.getIdtarjeta());
            }
        } catch (Exception e) {
            System.out.println("Error al buscar Saldo TDD:" + e.getMessage());
            response.setDescription("Tarjeta Inactiva");                        
        }        
        return response;
    }

    public boolean retiroTDD(WsSiscoopFoliosTarjetas1 tarjeta, Double monto) {
        LoadBalanceResponse.Return loadBalanceResponse = new LoadBalanceResponse.Return();
        DoWithdrawalAccountResponse.Return doWithdrawalAccountResponse = new DoWithdrawalAccountResponse.Return();
        System.out.println("Retirando de tarjeta:"+tarjeta.getIdtarjeta());
        boolean retiro = false;
        try {
            if (tarjeta.getActiva()) {
                /*doWithdrawalAccountResponse.setBalance(200);
                doWithdrawalAccountResponse.setCode(1);*/
                
               doWithdrawalAccountResponse = conexionSiscoop().getSiscoop().doWithdrawalAccount(tarjeta.getIdtarjeta(), monto);
                if (doWithdrawalAccountResponse.getCode() == 0) {
                    // 0 = Existe error
                    //retiro = false;
                    retiro=false;
                } else {
                    retiro = true;
                }
            }
        } catch (Exception e) {
            retiro =  errorRetiroDespositoSYC(loadBalanceResponse, e);
            e.getStackTrace();            
        }
        return true;//retiro;
    }

    // REALIZA EL DEPOSITO DE LA TARJETA TDD
    public boolean depositoTDD(WsSiscoopFoliosTarjetas1 tarjeta, Double monto) {
        System.out.println("Depositando a tarjeta:"+tarjeta.getIdtarjeta());
        LoadBalanceResponse.Return loadBalanceResponse = new LoadBalanceResponse.Return();
        boolean deposito = false;
        if (tarjeta.getActiva()) {
            try {                
                loadBalanceResponse = conexionSiscoop().getSiscoop().loadBalance(tarjeta.getIdtarjeta(), monto);
                //loadBalanceResponse.setCode(1);
                if (loadBalanceResponse.getCode() == 0) {
                    deposito = false;
                } else {
                    deposito = true;
                }
            } catch (Exception e) {
                deposito = errorRetiroDespositoSYC(loadBalanceResponse, e);
            }
        }
        return deposito;
    }

    public Siscoop_TDD conexionSiscoop() {
//        EntityManagerFactory emf = AbstractFacade.conexion();
        EntityManager em = AbstractFacade.conexion();//      EntityManager em = emf.createEntityManager();
        Siscoop_TDD conexionWSTDD = null;
        UtilidadesGenerales util = new UtilidadesGenerales();
        try {
            //Tabla para obtener usuario y contraseña
            Tabla crendenciales = util.busquedaTabla(em, "bankingly_banca_movil", "wsdl_credenciales");
            Tabla parametros = util.busquedaTabla(em, "bankingly_banca_movil", "wsdl_parametros");
            if (parametros != null) {
                System.out.println("Conectando ws ALestra....");
                //1.-Usuario,2.-contraseña,3.-host,4.-puerto,5.-wsdl
                conexionWSTDD = new consumo_tdd.Siscoop_TDD(crendenciales.getDato1(), crendenciales.getDato2(), parametros.getDato1(), parametros.getDato3(), parametros.getDato2());
                //conexionWSTDD = new (parametros.getDato1(), parametros.getDato2());

            }
        } catch (Exception e) {
            System.out.println("No existen parametros para conexion:" + e.getMessage());
        }
        return conexionWSTDD;
    }

    // ERROR AL CONSULTAR SYC TIEMPO AGOTADO
    public boolean errorRetiroDespositoSYC(LoadBalanceResponse.Return loadBalanceResponse, Exception e) {
        System.out.println("Error al consultar SYC, tiempo agotado. " + e.getMessage());
        loadBalanceResponse.setDescription("Connect timed out");
        return false;
    }

}
