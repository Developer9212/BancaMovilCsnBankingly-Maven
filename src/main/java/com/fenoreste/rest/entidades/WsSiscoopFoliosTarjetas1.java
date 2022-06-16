/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.entidades;

import java.io.Serializable;
import java.util.Date;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 *
 * @author Elliot
 */
@Entity
@Table(name = "ws_siscoop_folios_tarjetas")
public class WsSiscoopFoliosTarjetas1 implements Serializable {

    private static final long serialVersionUID = 1L;

    @EmbeddedId
    protected WsSiscoopFoliosTarjetasPK1 wsFoliosTarjetasSyCPK;
    @Column(name = "asignada")
    private Boolean asignada;
    @Column(name = "activa")
    private Boolean activa;
    @Column(name = "bloqueada")
    private Boolean bloqueada;    
    @Column(name = "idtarjeta")
    private String idtarjeta;
    @Column(name = "fecha_hora")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaHora;
    
    public WsSiscoopFoliosTarjetas1() {
    }

    public WsSiscoopFoliosTarjetas1(WsSiscoopFoliosTarjetasPK1 wsFoliosTarjetasSyCPK) {
        this.wsFoliosTarjetasSyCPK = wsFoliosTarjetasSyCPK;
    }

    public WsSiscoopFoliosTarjetas1(int idorigenp, int idproducto,int idauxiliar) {
        this.wsFoliosTarjetasSyCPK = new WsSiscoopFoliosTarjetasPK1(idorigenp, idproducto, idauxiliar);
    }

    public WsSiscoopFoliosTarjetasPK1 getWsSiscoopFoliosTarjetasPK() {
        return wsFoliosTarjetasSyCPK;
    }

    public void setWsSiscoopFoliosTarjetasPK(WsSiscoopFoliosTarjetasPK1 wsFoliosTarjetasSyCPK) {
        this.wsFoliosTarjetasSyCPK = wsFoliosTarjetasSyCPK;
    }

    public Boolean getAsignada() {
        return asignada;
    }

    public void setAsignada(Boolean asignada) {
        this.asignada = asignada;
    }

    public Boolean getActiva() {
        return activa;
    }

    public void setActiva(Boolean activa) {
        this.activa = activa;
    }

    public Boolean getBloqueada() {
        return bloqueada;
    }

    public void setBloqueada(Boolean bloqueada) {
        this.bloqueada = bloqueada;
    }
    
     public String getIdtarjeta() {
        return idtarjeta;
    }

    public void setIdtarjeta(String idtarjeta) {
        this.idtarjeta = idtarjeta;
    }

    public Date getFechaHora() {
        return fechaHora;
    }

    public void setFechaHora(Date fechaHora) {
        this.fechaHora = fechaHora;
    }


    @Override
    public int hashCode() {
        int hash = 0;
        hash += (wsFoliosTarjetasSyCPK != null ? wsFoliosTarjetasSyCPK.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof WsSiscoopFoliosTarjetas1)) {
            return false;
        }
        WsSiscoopFoliosTarjetas1 other = (WsSiscoopFoliosTarjetas1) object;
        return !((this.wsFoliosTarjetasSyCPK == null && other.wsFoliosTarjetasSyCPK != null) || (this.wsFoliosTarjetasSyCPK != null && !this.wsFoliosTarjetasSyCPK.equals(other.wsFoliosTarjetasSyCPK)));
    }

    @Override
    public String toString() {
        return "WsSiscoopFoliosTarjetas1{" + "wsFoliosTarjetasSyCPK=" + wsFoliosTarjetasSyCPK + ", asignada=" + asignada + ", activa=" + activa + ", bloqueada=" + bloqueada + ", idtarjeta=" + idtarjeta + ", fechaHora=" + fechaHora + '}';
    }

    

}
