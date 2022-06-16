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
public class SaiAuxiliarAhorroDTO implements Serializable {

    private Integer tipoProducto;
    private BigDecimal montoIo;
    private BigDecimal saldoPromedioDiario;
    private BigDecimal retencion;
    private BigDecimal saldoDiarioAcumulado;
    private String fechaUpi;
    private BigDecimal gat;

    public SaiAuxiliarAhorroDTO() {
    }

    public Integer getTipoProducto() {
        return tipoProducto;
    }

    public void setTipoProducto(Integer tipoProducto) {
        this.tipoProducto = tipoProducto;
    }

    public BigDecimal getMontoIo() {
        return montoIo;
    }

    public void setMontoIo(BigDecimal montoIo) {
        this.montoIo = montoIo;
    }

    public BigDecimal getSaldoPromedioDiario() {
        return saldoPromedioDiario;
    }

    public void setSaldoPromedioDiario(BigDecimal saldoPromedioDiario) {
        this.saldoPromedioDiario = saldoPromedioDiario;
    }

    public BigDecimal getRetencion() {
        return retencion;
    }

    public void setRetencion(BigDecimal retencion) {
        this.retencion = retencion;
    }

    public BigDecimal getSaldoDiarioAcumulado() {
        return saldoDiarioAcumulado;
    }

    public void setSaldoDiarioAcumulado(BigDecimal saldoDiarioAcumulado) {
        this.saldoDiarioAcumulado = saldoDiarioAcumulado;
    }

    public String getFechaUpi() {
        return fechaUpi;
    }

    public void setFechaUpi(String fechaUpi) {
        this.fechaUpi = fechaUpi;
    }

    public BigDecimal getGat() {
        return gat;
    }

    public void setGat(BigDecimal gat) {
        this.gat = gat;
    }

    @Override
    public String toString() {
        return "SaiAuxiliarAhorroDTO{" + "tipoProducto=" + tipoProducto + ", montoIo=" + montoIo + ", saldoPromedioDiario=" + saldoPromedioDiario + ", retencion=" + retencion + ", saldoDiarioAcumulado=" + saldoDiarioAcumulado + ", fechaUpi=" + fechaUpi + ", gat=" + gat + '}';
    }

}
