/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.DTO;

import java.io.Serializable;
import java.util.Objects;

/**
 *
 * @author wilmer
 */
public class SaiComisionCobranzaDTO implements Serializable {
    
    private double tasaComision;
    private double montoComision;
    private double montoFijo;
    private double tasaProporcional;
    private double proporcional;
    private Boolean esMontoModificado;

    public SaiComisionCobranzaDTO() {
    }

    public double getTasaComision() {
        return tasaComision;
    }

    public void setTasaComision(double tasaComision) {
        this.tasaComision = tasaComision;
    }

    public double getMontoComision() {
        return montoComision;
    }

    public void setMontoComision(double montoComision) {
        this.montoComision = montoComision;
    }

    public double getMontoFijo() {
        return montoFijo;
    }

    public void setMontoFijo(double montoFijo) {
        this.montoFijo = montoFijo;
    }

    public double getTasaProporcional() {
        return tasaProporcional;
    }

    public void setTasaProporcional(double tasaProporcional) {
        this.tasaProporcional = tasaProporcional;
    }

    public double getProporcional() {
        return proporcional;
    }

    public void setProporcional(double proporcional) {
        this.proporcional = proporcional;
    }

    public Boolean getEsMontoModificado() {
        return esMontoModificado;
    }

    public void setEsMontoModificado(Boolean esMontoModificado) {
        this.esMontoModificado = esMontoModificado;
    }

    @Override
    public int hashCode() {
        int hash = 5;
        hash = 97 * hash + (int) (Double.doubleToLongBits(this.tasaComision) ^ (Double.doubleToLongBits(this.tasaComision) >>> 32));
        hash = 97 * hash + (int) (Double.doubleToLongBits(this.montoComision) ^ (Double.doubleToLongBits(this.montoComision) >>> 32));
        hash = 97 * hash + (int) (Double.doubleToLongBits(this.montoFijo) ^ (Double.doubleToLongBits(this.montoFijo) >>> 32));
        hash = 97 * hash + (int) (Double.doubleToLongBits(this.tasaProporcional) ^ (Double.doubleToLongBits(this.tasaProporcional) >>> 32));
        hash = 97 * hash + (int) (Double.doubleToLongBits(this.proporcional) ^ (Double.doubleToLongBits(this.proporcional) >>> 32));
        hash = 97 * hash + Objects.hashCode(this.esMontoModificado);
        return hash;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final SaiComisionCobranzaDTO other = (SaiComisionCobranzaDTO) obj;
        if (Double.doubleToLongBits(this.tasaComision) != Double.doubleToLongBits(other.tasaComision)) {
            return false;
        }
        if (Double.doubleToLongBits(this.montoComision) != Double.doubleToLongBits(other.montoComision)) {
            return false;
        }
        if (Double.doubleToLongBits(this.montoFijo) != Double.doubleToLongBits(other.montoFijo)) {
            return false;
        }
        if (Double.doubleToLongBits(this.tasaProporcional) != Double.doubleToLongBits(other.tasaProporcional)) {
            return false;
        }
        if (Double.doubleToLongBits(this.proporcional) != Double.doubleToLongBits(other.proporcional)) {
            return false;
        }
        return Objects.equals(this.esMontoModificado, other.esMontoModificado);
    }

    @Override
    public String toString() {
        return "SaiComisionCobranzaDTO{" + "tasaComision=" + tasaComision + ", montoComision=" + montoComision + ", montoFijo=" + montoFijo + ", tasaProporcional=" + tasaProporcional + ", proporcional=" + proporcional + ", esMontoModificado=" + esMontoModificado + '}';
    }

}
