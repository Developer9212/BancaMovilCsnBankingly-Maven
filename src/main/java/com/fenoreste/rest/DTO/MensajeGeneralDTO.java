/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.DTO;

/**
 *
 * @author wilmer
 */
public class MensajeGeneralDTO {
    private String mensaje;
    private String codigoError;

    public MensajeGeneralDTO() {
    }

    public MensajeGeneralDTO(String mensaje, String codigoError) {
        this.mensaje = mensaje;
        this.codigoError = codigoError;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    public String getCodigoError() {
        return codigoError;
    }

    public void setCodigoError(String codigoError) {
        this.codigoError = codigoError;
    }
    
    
}
