/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.dao;

import com.fenoreste.rest.DTO.OpaDTO;
import com.fenoreste.rest.ResponseDTO.CatalogFixedTermDepositDTO;
import com.fenoreste.rest.ResponseDTO.DetallesInversionDTO;
import com.fenoreste.rest.ResponseDTO.DocumentId;
import com.fenoreste.rest.ResponseDTO.FixedTermDepositBeneficiaryDTO;
import com.fenoreste.rest.Util.AbstractFacade;
import com.fenoreste.rest.Util.Utilidades;
import com.fenoreste.rest.Util.UtilidadesGenerales;
import com.fenoreste.rest.entidades.Auxiliares;
import com.fenoreste.rest.entidades.AuxiliaresPK;
import com.fenoreste.rest.entidades.Persona;
import com.fenoreste.rest.entidades.PersonasPK;
import com.fenoreste.rest.entidades.Productos;
import com.fenoreste.rest.entidades.Productos_bankingly;
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
