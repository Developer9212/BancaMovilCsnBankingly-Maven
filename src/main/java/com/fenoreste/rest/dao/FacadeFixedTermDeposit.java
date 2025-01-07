/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.dao;

import com.fenoreste.rest.DTO.OgsDTO;
import com.fenoreste.rest.DTO.OpaDTO;
import com.fenoreste.rest.Request.FixedTermMethodPaymentDTO;
import com.fenoreste.rest.Request.TermDataReqVo;
import com.fenoreste.rest.ResponseDTO.CatalogFixedTermDepositDTO;
import com.fenoreste.rest.ResponseDTO.DetallesInversionDTO;
import com.fenoreste.rest.ResponseDTO.DocumentId;
import com.fenoreste.rest.ResponseDTO.FixedTermDepositBeneficiaryDTO;
import com.fenoreste.rest.ResponseDTO.FixedTermMethodPaymentResponseDTO;
import com.fenoreste.rest.ResponseDTO.TermDataResVo;
import com.fenoreste.rest.Util.AbstractFacade;
import com.fenoreste.rest.Util.Utilidades;
import com.fenoreste.rest.Util.UtilidadesGenerales;
import com.fenoreste.rest.entidades.Auxiliares;
import com.fenoreste.rest.entidades.AuxiliaresPK;
import com.fenoreste.rest.entidades.Persona;
import com.fenoreste.rest.entidades.PersonasPK;
import com.fenoreste.rest.entidades.Productos;
import com.fenoreste.rest.entidades.Productos_bankingly;
import com.fenoreste.rest.entidades.Tabla;
import com.fenoreste.rest.entidades.TablaPK;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.Query;

/**
 *
 * @author nahum
 */
public abstract class FacadeFixedTermDeposit<T> {

    Utilidades util = new Utilidades();
    UtilidadesGenerales util2 = new UtilidadesGenerales();

    public FacadeFixedTermDeposit(Class<T> entiClass) {
    }

    public DetallesInversionDTO getDetallesInversion(String accountId) {
        EntityManager em = AbstractFacade.conexion();
        OpaDTO opa = util.opa(accountId);
        DetallesInversionDTO fixedTermDeposit = null;
        try {
            AuxiliaresPK auxpk = new AuxiliaresPK(opa.getIdorigenp(), opa.getIdproducto(), opa.getIdauxiliar());
            Auxiliares aux = em.find(Auxiliares.class, auxpk);
            PersonasPK ppk = new PersonasPK(aux.getIdorigen(), aux.getIdgrupo(), aux.getIdsocio());
            Persona per = em.find(Persona.class, ppk);
            Productos producto = em.find(Productos.class, aux.getAuxiliaresPK().getIdproducto());

            fixedTermDeposit = new DetallesInversionDTO();
            FixedTermDepositBeneficiaryDTO datosBeneficiario = new FixedTermDepositBeneficiaryDTO();
            DocumentId documentId = new DocumentId();
            CatalogFixedTermDepositDTO catalog = new CatalogFixedTermDepositDTO();
            //Formatear fecha
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

            fixedTermDeposit.setCdpName(producto.getNombre());
            fixedTermDeposit.setCdpNumber(producto.getIdproducto().toString());
            fixedTermDeposit.setCurrentBalance(aux.getSaldo().doubleValue());
            fixedTermDeposit.setDueDate(intervalo(aux.getFechaactivacion(), aux.getPlazo()));

            String sai_auxiliar = "SELECT sai_auxiliar(" + opa.getIdorigenp() + "," + opa.getIdproducto() + "," + opa.getIdauxiliar() + ",(SELECT date(fechatrabajo) FROM origenes LIMIT 1))";
            Query RsSai = em.createNativeQuery(sai_auxiliar);
            String sai = RsSai.getSingleResult().toString();
            String[] parts = sai.split("\\|");
            List datos_sai_auxiliar = Arrays.asList(parts);

            fixedTermDeposit.setInterestEarned(Double.parseDouble(datos_sai_auxiliar.get(1).toString()));
            fixedTermDeposit.setInterestPaid(0.0);
            fixedTermDeposit.setInterestPayingAccount(producto.getCuentaintord());
            fixedTermDeposit.setOriginalAmount(aux.getSaldo().doubleValue());
            fixedTermDeposit.setProductBankIdentifier(String.format("%06d", opa.getIdorigenp()) + "" + String.format("%05d", opa.getIdproducto()) + "" + String.format("%08d", opa.getIdauxiliar()));
            fixedTermDeposit.setRate(aux.getTasaio().doubleValue());
            fixedTermDeposit.setStartDate(sdf.format(aux.getFechaactivacion()));
            fixedTermDeposit.setTerm(String.valueOf(aux.getPlazo()));
            fixedTermDeposit.setDebitProductBankIdentifier(null);//PREGUNTAR

            Productos_bankingly tipo_cuenta_bankingly = em.find(Productos_bankingly.class, opa.getIdproducto());
            fixedTermDeposit.setFixedTermDepositType(tipo_cuenta_bankingly.getProductTypeId());

            catalog.setCode("3");
            catalog.setLanguajeId(null);
            catalog.setDescription("Ventanilla");
            fixedTermDeposit.setPaymentMethod(catalog);

            fixedTermDeposit.getInterestCreditProductBankIdentifier();//Preguntar a que cuenta se depositan los intereses generados
            fixedTermDeposit.getDepositCreditProductBankIdentifier();//Preguntar a donde va el pago de la inversion

            List<FixedTermDepositBeneficiaryDTO> lista_beneficiarios = new ArrayList<>();
            documentId.setDocumentNumber(per.getCurp());
            documentId.setDocumentType("3");

            datosBeneficiario.setDocumentId(documentId);
            datosBeneficiario.setName(per.getNombre() + " " + per.getAppaterno() + " " + per.getApmaterno());
            datosBeneficiario.setPorcentage(aux.getTasaio().intValue());

            lista_beneficiarios.add(datosBeneficiario);
            fixedTermDeposit.setFixedTermDepositBeneficiaries(lista_beneficiarios);
        } catch (Exception e) {
            System.out.println("Error en getDetallesInversion: " + e.getMessage());
        } finally {
            em.close();
        }

        return fixedTermDeposit;
    }
    
    public TermDataResVo condicionesInversion(TermDataReqVo resquest){
        TermDataResVo response = new TermDataResVo();
        try {
            
            
            
        } catch (Exception e) {
            System.out.println("::::::::Error al obtener condiciones de deposito a plazo::::::::::::::"+e.getMessage());
        }
        return null;
    }
    
    
    public FixedTermMethodPaymentResponseDTO metodosPago(FixedTermMethodPaymentDTO peticion){
        FixedTermMethodPaymentResponseDTO response = new FixedTermMethodPaymentResponseDTO();
        OpaDTO opa = util.opa(peticion.getDebitProductBankIdentifier());
        OgsDTO ogs = util.ogs(peticion.getClientBankIdentifier());
        try {
            EntityManager em = AbstractFacade.conexion();
            TablaPK tablaPK;
            Tabla tabla;
            AuxiliaresPK auxpk = new AuxiliaresPK(opa.getIdorigenp(), opa.getIdproducto(), opa.getIdauxiliar());
            Auxiliares aux = em.find(Auxiliares.class, auxpk);
            if(aux != null){
                tablaPK = new TablaPK("bankingly_banca_movil","producto_retiro");
                tabla = em.find(Tabla.class, tablaPK);
                int productoRetiro = Integer.parseInt(tabla.getDato1());
                if(aux.getAuxiliaresPK().getIdorigenp() == productoRetiro){
                    if(aux.getSaldo().doubleValue() - aux.getGarantia().doubleValue() >= peticion.getDepositAmount()){
                        //Vamos a consultar si el plazo elegido es compatible con el producto
                        Productos producto = em.find(Productos.class, aux.getAuxiliaresPK().getIdproducto());
                        String cnosulta = "SELECT count(*) FROM tablas WHERE idtabla='tasas' and idelemento like 'tasaiar%' AND order by idelemento;"
                        
                    }else{
                        System.out.println(":::::::::::::::::::El producto a retirar para invertir no tiene saldo suficiente::::::::::::::");
                    }
                }else{
                    System.out.println("::::::::::::::::Producto seleccionado para pago,no configurado para retiros:::::::::::::");
                }
            }else{
                System.out.println("::::::::::::No existe folio seleccionado para retiro::::::::::::::::::::::::");
            }
            
          
        } catch (Exception e) {
            System.out.println("::::::::::Error al obtener metodos de pago:::::::::::::::"+e.getMessage());
        }        
        return response;
        
    }

    public String intervalo(Date fecha, int numeroDias) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(fecha);
        cal.add(Calendar.DAY_OF_YEAR, numeroDias);
        SimpleDateFormat d = new SimpleDateFormat("yyyy-MM-dd");
        String date = null;
        date = d.format(cal.getTime());

        return date;
    }

    public boolean actividad_horario() {
        EntityManager em = AbstractFacade.conexion();
        boolean bandera_ = false;
        try {
            if (util2.actividad(em)) {
                bandera_ = true;
            }
        } catch (Exception e) {
            System.out.println("Error al verificar el horario de actividad");
        } finally {
            em.close();
        }

        return bandera_;
    }

}
