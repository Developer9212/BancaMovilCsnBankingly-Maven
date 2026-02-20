/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.Request;

import java.io.Serializable;
import java.util.Objects;

/**
 *
 * @author wilmer
 */
public class RequestDataOrdenPagoDTO implements Serializable {

    String clienteClabe;
    Double monto;
    String institucionContraparte;
    String nombreBeneficiario;
    String rfcCurpBeneficiario;
    String conceptoPago;
    String cuentaBeneficiario;
    String ordernante;
    String longitud;
    String latitud;
    String claveRastreo;

    public RequestDataOrdenPagoDTO() {
    }

    public RequestDataOrdenPagoDTO(String clienteClabe, Double monto, String institucionContraparte, String nombreBeneficiario, String rfcCurpBeneficiario, String conceptoPago, String cuentaBeneficiario, String ordernante, String longitud, String latitud, String claveRastreo) {
        this.clienteClabe = clienteClabe;
        this.monto = monto;
        this.institucionContraparte = institucionContraparte;
        this.nombreBeneficiario = nombreBeneficiario;
        this.rfcCurpBeneficiario = rfcCurpBeneficiario;
        this.conceptoPago = conceptoPago;
        this.cuentaBeneficiario = cuentaBeneficiario;
        this.ordernante = ordernante;
        this.longitud = longitud;
        this.latitud = latitud;
        this.claveRastreo = claveRastreo;
    }

    public String getClienteClabe() {
        return clienteClabe;
    }

    public void setClienteClabe(String clienteClabe) {
        this.clienteClabe = clienteClabe;
    }

    public Double getMonto() {
        return monto;
    }

    public void setMonto(Double monto) {
        this.monto = monto;
    }

    public String getInstitucionContraparte() {
        return institucionContraparte;
    }

    public void setInstitucionContraparte(String institucionContraparte) {
        this.institucionContraparte = institucionContraparte;
    }

    public String getNombreBeneficiario() {
        return nombreBeneficiario;
    }

    public void setNombreBeneficiario(String nombreBeneficiario) {
        this.nombreBeneficiario = nombreBeneficiario;
    }

    public String getRfcCurpBeneficiario() {
        return rfcCurpBeneficiario;
    }

    public void setRfcCurpBeneficiario(String rfcCurpBeneficiario) {
        this.rfcCurpBeneficiario = rfcCurpBeneficiario;
    }

    public String getConceptoPago() {
        return conceptoPago;
    }

    public void setConceptoPago(String conceptoPago) {
        this.conceptoPago = conceptoPago;
    }

    public String getCuentaBeneficiario() {
        return cuentaBeneficiario;
    }

    public void setCuentaBeneficiario(String cuentaBeneficiario) {
        this.cuentaBeneficiario = cuentaBeneficiario;
    }

    public String getOrdernante() {
        return ordernante;
    }

    public void setOrdernante(String ordernante) {
        this.ordernante = ordernante;
    }

    public String getLongitud() {
        return longitud;
    }

    public void setLongitud(String longitud) {
        this.longitud = longitud;
    }

    public String getLatitud() {
        return latitud;
    }

    public void setLatitud(String latitud) {
        this.latitud = latitud;
    }

    public String getClaveRastreo() {
        return claveRastreo;
    }

    public void setClaveRastreo(String claveRastreo) {
        this.claveRastreo = claveRastreo;
    }

    @Override
    public String toString() {
        return "RequestDataOrdenPagoDTO{" + "clienteClabe=" + clienteClabe + ", monto=" + monto + ", institucionContraparte=" + institucionContraparte + ", nombreBeneficiario=" + nombreBeneficiario + ", rfcCurpBeneficiario=" + rfcCurpBeneficiario + ", conceptoPago=" + conceptoPago + ", cuentaBeneficiario=" + cuentaBeneficiario + ", ordernante=" + ordernante + ", longitud=" + longitud + ", latitud=" + latitud + ", claveRastreo=" + claveRastreo + '}';
    }

    @Override
    public int hashCode() {
        int hash = 5;
        hash = 29 * hash + Objects.hashCode(this.clienteClabe);
        hash = 29 * hash + Objects.hashCode(this.monto);
        hash = 29 * hash + Objects.hashCode(this.institucionContraparte);
        hash = 29 * hash + Objects.hashCode(this.nombreBeneficiario);
        hash = 29 * hash + Objects.hashCode(this.rfcCurpBeneficiario);
        hash = 29 * hash + Objects.hashCode(this.conceptoPago);
        hash = 29 * hash + Objects.hashCode(this.cuentaBeneficiario);
        hash = 29 * hash + Objects.hashCode(this.ordernante);
        hash = 29 * hash + Objects.hashCode(this.longitud);
        hash = 29 * hash + Objects.hashCode(this.latitud);
        hash = 29 * hash + Objects.hashCode(this.claveRastreo);
        return hash;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final RequestDataOrdenPagoDTO other = (RequestDataOrdenPagoDTO) obj;
        if (!Objects.equals(this.clienteClabe, other.clienteClabe)) {
            return false;
        }
        if (!Objects.equals(this.institucionContraparte, other.institucionContraparte)) {
            return false;
        }
        if (!Objects.equals(this.nombreBeneficiario, other.nombreBeneficiario)) {
            return false;
        }
        if (!Objects.equals(this.rfcCurpBeneficiario, other.rfcCurpBeneficiario)) {
            return false;
        }
        if (!Objects.equals(this.conceptoPago, other.conceptoPago)) {
            return false;
        }
        if (!Objects.equals(this.cuentaBeneficiario, other.cuentaBeneficiario)) {
            return false;
        }
        if (!Objects.equals(this.ordernante, other.ordernante)) {
            return false;
        }
        if (!Objects.equals(this.longitud, other.longitud)) {
            return false;
        }
        if (!Objects.equals(this.latitud, other.latitud)) {
            return false;
        }
        if (!Objects.equals(this.claveRastreo, other.claveRastreo)) {
            return false;
        }
        if (!Objects.equals(this.monto, other.monto)) {
            return false;
        }
        return true;
    }
    
    

    private static final long serialVersionUID = 1L;

}
