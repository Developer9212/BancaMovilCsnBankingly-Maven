/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.entidades;

import java.io.Serializable;
import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 *
 * @author wilmer
 */
@Embeddable
public class PolizasPK implements Serializable {

    @Column(name = "idorigenc", nullable = false)
    private Integer idorigenc;
    @Column(name = "periodo")
    private String periodo;
    @Column(name = "idtipo")
    private Integer idtipo;
    @Column(name = "idpoliza")
    private Integer idpoliza;

    public PolizasPK() {
    }

    public Integer getIdorigenc() {
        return idorigenc;
    }

    public void setIdorigenc(Integer idorigenc) {
        this.idorigenc = idorigenc;
    }

    public String getPeriodo() {
        return periodo;
    }

    public void setPeriodo(String periodo) {
        this.periodo = periodo;
    }

    public Integer getIdtipo() {
        return idtipo;
    }

    public void setIdtipo(Integer idtipo) {
        this.idtipo = idtipo;
    }

    public Integer getIdpoliza() {
        return idpoliza;
    }

    public void setIdpoliza(Integer idpoliza) {
        this.idpoliza = idpoliza;
    }
    
    private static final long serialVersionUID = 1L;
    

}
