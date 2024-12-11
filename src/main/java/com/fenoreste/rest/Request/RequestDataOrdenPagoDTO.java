/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.Request;

/**
 *
 * @author wilmer
 */
public class RequestDataOrdenPagoDTO {
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

    public RequestDataOrdenPagoDTO() {
    }

    public RequestDataOrdenPagoDTO(String clienteClabe, Double monto, String institucionContraparte, String nombreBeneficiario, String rfcCurpBeneficiario, String conceptoPago, String cuentaBeneficiario, String ordernante, String longitud, String latitud) {
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

    @Override
    public String toString() {
        return "RequestDataOrdenPagoDTO{" + "clienteClabe=" + clienteClabe + ", monto=" + monto + ", institucionContraparte=" + institucionContraparte + ", nombreBeneficiario=" + nombreBeneficiario + ", rfcCurpBeneficiario=" + rfcCurpBeneficiario + ", conceptoPago=" + conceptoPago + ", cuentaBeneficiario=" + cuentaBeneficiario + ", ordernante=" + ordernante + ", longitud=" + longitud + ", latitud=" + latitud + '}';
    }
     
    
    
}