/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.entidades;

import java.io.Serializable;
import java.util.Date;
import javax.persistence.Cacheable;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 *
 * @author wilmer
 */
@Entity
@Table(name = "polizas")
@Cacheable(false)
public class Polizas implements Serializable{
    
    @EmbeddedId
    private PolizasPK polizasPK;
    private Date fecha;
    private String concepto;
    private Integer estatus;
    private String referencia;
    private boolean esresumen;
    private Integer idusuario;

    public PolizasPK getPolizasPK() {
        return polizasPK;
    }

    public void setPolizasPK(PolizasPK polizasPK) {
        this.polizasPK = polizasPK;
    }

    public Date getFecha() {
        return fecha;
    }

    public void setFecha(Date fecha) {
        this.fecha = fecha;
    }

    public String getConcepto() {
        return concepto;
    }

    public void setConcepto(String concepto) {
        this.concepto = concepto;
    }

    public Integer getEstatus() {
        return estatus;
    }

    public void setEstatus(Integer estatus) {
        this.estatus = estatus;
    }

    public String getReferencia() {
        return referencia;
    }

    public void setReferencia(String referencia) {
        this.referencia = referencia;
    }

    public boolean isEsresumen() {
        return esresumen;
    }

    public void setEsresumen(boolean esresumen) {
        this.esresumen = esresumen;
    }

    public Integer getIdusuario() {
        return idusuario;
    }

    public void setIdusuario(Integer idusuario) {
        this.idusuario = idusuario;
    }
    
    private static final long serialVersionUID = 1L;
    
}
