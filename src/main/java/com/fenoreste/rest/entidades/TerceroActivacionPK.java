/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.entidades;

import java.io.Serializable;
import java.util.Objects;
import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 *
 * @author wilmer
 */
@Embeddable
public class TerceroActivacionPK implements Serializable {

    @Column(name = "idorigenpt", nullable = false)
    private Integer idorigenpt;
    @Column(name = "idproductot")
    private Integer idproductot;
    @Column(name = "idauxiliart")
    private Integer idauxiliart;
    @Column(name = "usuariobanca")
    private String usuariobanca;

    public TerceroActivacionPK() {
    }

    public TerceroActivacionPK(Integer idorigenpt, Integer idproductot, Integer idauxiliart, String usuariobanca) {
        this.idorigenpt = idorigenpt;
        this.idproductot = idproductot;
        this.idauxiliart = idauxiliart;
        this.usuariobanca = usuariobanca;
    }
    
    

    public Integer getIdorigenpt() {
        return idorigenpt;
    }

    public void setIdorigenpt(Integer idorigenpt) {
        this.idorigenpt = idorigenpt;
    }

    public Integer getIdproductot() {
        return idproductot;
    }

    public void setIdproductot(Integer idproductot) {
        this.idproductot = idproductot;
    }

    public Integer getIdauxiliart() {
        return idauxiliart;
    }

    public void setIdauxiliart(Integer idauxiliart) {
        this.idauxiliart = idauxiliart;
    }

    public String getUsuariobanca() {
        return usuariobanca;
    }

    public void setUsuariobanca(String usuariobanca) {
        this.usuariobanca = usuariobanca;
    }
    
    @Override public boolean equals(Object o) { if (this == o) return true; if (!(o instanceof TerceroActivacionPK)) return false; TerceroActivacionPK that = (TerceroActivacionPK) o; return idorigenpt.equals(that.idorigenpt) && idproductot.equals(that.idproductot) && idauxiliart.equals(that.idauxiliart) && usuariobanca.equals(that.usuariobanca); } @Override public int hashCode() { return Objects.hash(idorigenpt, idproductot, idauxiliart, usuariobanca); }
    
}
