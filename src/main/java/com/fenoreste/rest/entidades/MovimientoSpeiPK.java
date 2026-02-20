/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.entidades;

/**
 *
 * @author wilmer
 */
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Embeddable;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 *
 * @author Will
 */
@Embeddable
public class MovimientoSpeiPK implements java.io.Serializable{
    
    @Column(name="fecha")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fecha;    
    private Integer idusuario;
    private String sesion;
    private String referencia;

    public MovimientoSpeiPK() {
    }

    public MovimientoSpeiPK(Date fecha, Integer idusuario, String sesion, String referencia) {
        this.fecha = fecha;
        this.idusuario = idusuario;
        this.sesion = sesion;
        this.referencia = referencia;
    }

    public Date getFecha() {
        return fecha;
    }

    public void setFecha(Date fecha) {
        this.fecha = fecha;
    }

    public Integer getIdusuario() {
        return idusuario;
    }

    public void setIdusuario(Integer idusuario) {
        this.idusuario = idusuario;
    }

    public String getSesion() {
        return sesion;
    }

    public void setSesion(String sesion) {
        this.sesion = sesion;
    }

    public String getReferencia() {
        return referencia;
    }

    public void setReferencia(String referencia) {
        this.referencia = referencia;
    }

    @Override
    public String toString() {
        return "MovimientoSpeiPK{" + "fecha=" + fecha + ", idusuario=" + idusuario + ", sesion=" + sesion + ", referencia=" + referencia + '}';
    }
    
    
    
}
