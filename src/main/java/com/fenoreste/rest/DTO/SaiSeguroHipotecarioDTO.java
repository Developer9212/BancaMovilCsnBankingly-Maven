/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.DTO;

import com.fenoreste.rest.entidades.SaiSeguroHipotecarioPK;
import java.io.Serializable;
import java.util.Objects;

/**
 *
 * @author wilmer
 */
public class SaiSeguroHipotecarioDTO implements Serializable {

    protected SaiSeguroHipotecarioPK saiSeguroHipotecarioPK;
    private double tasa_iva;
    private double seguro;
    private double ivaseguro;
    private double pagado;
    private double ivapagado;
    private double apagar;
    private double ivaapagar;

    public SaiSeguroHipotecarioDTO() {
    }

    public SaiSeguroHipotecarioPK getSaiSeguroHipotecarioPK() {
        return saiSeguroHipotecarioPK;
    }

    public void setSaiSeguroHipotecarioPK(SaiSeguroHipotecarioPK saiSeguroHipotecarioPK) {
        this.saiSeguroHipotecarioPK = saiSeguroHipotecarioPK;
    }

    public double getTasa_iva() {
        return tasa_iva;
    }

    public void setTasa_iva(double tasa_iva) {
        this.tasa_iva = tasa_iva;
    }

    public double getSeguro() {
        return seguro;
    }

    public void setSeguro(double seguro) {
        this.seguro = seguro;
    }

    public double getIvaseguro() {
        return ivaseguro;
    }

    public void setIvaseguro(double ivaseguro) {
        this.ivaseguro = ivaseguro;
    }

    public double getPagado() {
        return pagado;
    }

    public void setPagado(double pagado) {
        this.pagado = pagado;
    }

    public double getIvapagado() {
        return ivapagado;
    }

    public void setIvapagado(double ivapagado) {
        this.ivapagado = ivapagado;
    }

    public double getApagar() {
        return apagar;
    }

    public void setApagar(double apagar) {
        this.apagar = apagar;
    }

    public double getIvaapagar() {
        return ivaapagar;
    }

    public void setIvaapagar(double ivaapagar) {
        this.ivaapagar = ivaapagar;
    }

    @Override
    public int hashCode() {
        int hash = 3;
        hash = 71 * hash + Objects.hashCode(this.saiSeguroHipotecarioPK);
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
        final SaiSeguroHipotecarioDTO other = (SaiSeguroHipotecarioDTO) obj;
        return Objects.equals(this.saiSeguroHipotecarioPK, other.saiSeguroHipotecarioPK);
    }

    @Override
    public String toString() {
        return "SaiSeguroHipotecarioDTO{" + "saiSeguroHipotecarioPK=" + saiSeguroHipotecarioPK + ", tasa_iva=" + tasa_iva + ", seguro=" + seguro + ", ivaseguro=" + ivaseguro + ", pagado=" + pagado + ", ivapagado=" + ivapagado + ", apagar=" + apagar + ", ivaapagar=" + ivaapagar + '}';
    }
  
}
