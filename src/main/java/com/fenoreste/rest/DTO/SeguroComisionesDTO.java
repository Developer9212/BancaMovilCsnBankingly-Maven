/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.DTO;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 *
 * @author wilmer
 */
public class SeguroComisionesDTO implements Serializable {
    
    private int idorigenp;
    private int idproducto;
    private int idauxiliar;
    private BigDecimal apagar;
    private BigDecimal ivaapagar;

    public SeguroComisionesDTO() {
    }

    public SeguroComisionesDTO(int idorigenp, int idproducto, int idauxiliar) {
        this.idorigenp = idorigenp;
        this.idproducto = idproducto;
        this.idauxiliar = idauxiliar;
    }

    public int getIdorigenp() {
        return idorigenp;
    }

    public void setIdorigenp(int idorigenp) {
        this.idorigenp = idorigenp;
    }

    public int getIdproducto() {
        return idproducto;
    }

    public void setIdproducto(int idproducto) {
        this.idproducto = idproducto;
    }

    public int getIdauxiliar() {
        return idauxiliar;
    }

    public void setIdauxiliar(int idauxiliar) {
        this.idauxiliar = idauxiliar;
    }

    public BigDecimal getApagar() {
        return apagar;
    }

    public void setApagar(BigDecimal apagar) {
        this.apagar = apagar;
    }

    public BigDecimal getIvaapagar() {
        return ivaapagar;
    }

    public void setIvaapagar(BigDecimal ivaapagar) {
        this.ivaapagar = ivaapagar;
    }

    @Override
    public int hashCode() {
        int hash = 5;
        hash = 79 * hash + this.idorigenp;
        hash = 79 * hash + this.idproducto;
        hash = 79 * hash + this.idauxiliar;
        return hash;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final SeguroComisionesDTO other = (SeguroComisionesDTO) obj;
        if (this.idorigenp != other.idorigenp) {
            return false;
        }
        if (this.idproducto != other.idproducto) {
            return false;
        }
        return this.idauxiliar == other.idauxiliar;
    }

    @Override
    public String toString() {
        return "SegurosComisionesDTO{" + "idorigenp=" + idorigenp + ", idproducto=" + idproducto + ", idauxiliar=" + idauxiliar + ", apagar=" + apagar + ", ivaapagar=" + ivaapagar + '}';
    }
    
}
