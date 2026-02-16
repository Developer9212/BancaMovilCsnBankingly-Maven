/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.entidades;

import java.io.Serializable;
import java.util.Date;
import javax.persistence.Cacheable;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 *
 * @author wilmer
 */
@Entity
@Table(name = "productos_terceros_activacion")
@Cacheable(false)
public class TerceroActivacion implements Serializable{
    
    @EmbeddedId
    private TerceroActivacionPK Pk;
    @Temporal(TemporalType.TIMESTAMP)
    private Date fecharegistro;    
    @Column(name="idcuentaotrobanco")
    private String idcuentaOtroBanco;
    private String comentario;

    public TerceroActivacion() {
    }

    public TerceroActivacionPK getPk() {
        return Pk;
    }

    public void setPk(TerceroActivacionPK Pk) {
        this.Pk = Pk;
    }

    public Date getFecharegistro() {
        return fecharegistro;
    }

    public void setFecharegistro(Date fecharegistro) {
        this.fecharegistro = fecharegistro;
    }

    public String getIdcuentaOtroBanco() {
        return idcuentaOtroBanco;
    }

    public void setIdcuentaOtroBanco(String idcuentaOtroBanco) {
        this.idcuentaOtroBanco = idcuentaOtroBanco;
    }

    public String getComentario() {
        return comentario;
    }

    public void setComentario(String comentario) {
        this.comentario = comentario;
    }

    
    
    
    
    
    
    
    private static final long serialVersionUID = 1L;
    
}
