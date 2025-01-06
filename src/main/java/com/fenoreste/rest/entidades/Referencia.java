/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.entidades;

import java.io.Serializable;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

/**
 *
 * @author Will
 */
@Entity
@Table(name = "referencias")
public class Referencia implements Serializable {

    @EmbeddedId
    private PersonasPK pk;
    private Integer tiporeferencia;
    private Integer idorigenr;
    private Integer idgrupor;
    private Integer idsocior;

    public Referencia(PersonasPK pk, Integer tiporeferencia, Integer idorigenr, Integer idgrupor, Integer idsocior) {
        this.pk = pk;
        this.tiporeferencia = tiporeferencia;
        this.idorigenr = idorigenr;
        this.idgrupor = idgrupor;
        this.idsocior = idsocior;
    }

    public Referencia() {
    }

    public PersonasPK getPk() {
        return pk;
    }

    public void setPk(PersonasPK pk) {
        this.pk = pk;
    }

    public Integer getTiporeferencia() {
        return tiporeferencia;
    }

    public void setTiporeferencia(Integer tiporeferencia) {
        this.tiporeferencia = tiporeferencia;
    }

    public Integer getIdorigenr() {
        return idorigenr;
    }

    public void setIdorigenr(Integer idorigenr) {
        this.idorigenr = idorigenr;
    }

    public Integer getIdgrupor() {
        return idgrupor;
    }

    public void setIdgrupor(Integer idgrupor) {
        this.idgrupor = idgrupor;
    }

    public Integer getIdsocior() {
        return idsocior;
    }

    public void setIdsocior(Integer idsocior) {
        this.idsocior = idsocior;
    }

    @Override
    public String toString() {
        return "Referencias{" + "pk=" + pk + ", tiporeferencia=" + tiporeferencia + ", idorigenr=" + idorigenr + ", idgrupor=" + idgrupor + ", idsocior=" + idsocior + '}';
    }
    
    
    private static final long serialVersionUID = 1L;

}
