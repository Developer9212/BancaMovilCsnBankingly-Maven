/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.ResponseDTO;

/**
 *
 * @author wilmer
 */
public class WSEnviarOrdenSPEIDTO {
    private String cliente;
    private Double monto;
    private String conceptoPago;
    private String banco;
    private String beneficiario;
    private String rfcCurpBeneficiario;
    private String cuentaBeneficiario;

    public WSEnviarOrdenSPEIDTO() {
    }

    public String getCliente() {
        return cliente;
    }

    public void setCliente(String cliente) {
        this.cliente = cliente;
    }

    public Double getMonto() {
        return monto;
    }

    public void setMonto(Double monto) {
        this.monto = monto;
    }

    public String getConceptoPago() {
        return conceptoPago;
    }

    public void setConceptoPago(String conceptoPago) {
        this.conceptoPago = conceptoPago;
    }

    public String getBanco() {
        return banco;
    }

    public void setBanco(String banco) {
        this.banco = banco;
    }

    public String getBeneficiario() {
        return beneficiario;
    }

    public void setBeneficiario(String beneficiario) {
        this.beneficiario = beneficiario;
    }

    public String getRfcCurpBeneficiario() {
        return rfcCurpBeneficiario;
    }

    public void setRfcCurpBeneficiario(String rfcCurpBeneficiario) {
        this.rfcCurpBeneficiario = rfcCurpBeneficiario;
    }

    public String getCuentaBeneficiario() {
        return cuentaBeneficiario;
    }

    public void setCuentaBeneficiario(String cuentaBeneficiario) {
        this.cuentaBeneficiario = cuentaBeneficiario;
    }

    @Override
    public String toString() {
        return "WSEnviarOrdenSPEIDTO{" + "cliente=" + cliente + ", monto=" + monto + ", conceptoPago=" + conceptoPago + ", banco=" + banco + ", beneficiario=" + beneficiario + ", rfcCurpBeneficiario=" + rfcCurpBeneficiario + ", cuentaBeneficiario=" + cuentaBeneficiario + '}';
    }
    
    
    
}
