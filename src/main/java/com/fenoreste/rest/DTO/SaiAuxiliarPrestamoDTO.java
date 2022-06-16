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
public class SaiAuxiliarPrestamoDTO implements Serializable {

    private Integer tipoProducto;
    private String fechaUmi;
    private BigDecimal abonosVencidos;
    private Integer diasVencidos;
    private BigDecimal montoVencido;
    private Integer diasVencidosIntord;
    private BigDecimal montoIoTotal;
    private BigDecimal montoBonificacion;
    private String fechaVencimiento;
    private BigDecimal imCalculado;
    private String fechaSigAbono;
    private BigDecimal montoPorVencer;
    private BigDecimal ioCalculado;
    private String estatusCartera;
    private BigDecimal idncCalculado;
    private BigDecimal montoImTotal;
    private String fechaLimite;
    private BigDecimal ivaIoTotal;
    private BigDecimal ivaImTotal;
    private BigDecimal difDesctoIo;
    private BigDecimal comisionNpCalc;
    private BigDecimal comisionNpTotal;
    private Integer diasVencidosCapital;

    public SaiAuxiliarPrestamoDTO() {
    }

    public Integer getTipoProducto() {
        return tipoProducto;
    }

    public void setTipoProducto(Integer tipoProducto) {
        this.tipoProducto = tipoProducto;
    }

    public String getFechaUmi() {
        return fechaUmi;
    }

    public void setFechaUmi(String fechaUmi) {
        this.fechaUmi = fechaUmi;
    }

    public BigDecimal getAbonosVencidos() {
        return abonosVencidos;
    }

    public void setAbonosVencidos(BigDecimal abonosVencidos) {
        this.abonosVencidos = abonosVencidos;
    }

    public Integer getDiasVencidos() {
        return diasVencidos;
    }

    public void setDiasVencidos(Integer diasVencidos) {
        this.diasVencidos = diasVencidos;
    }

    public BigDecimal getMontoVencido() {
        return montoVencido;
    }

    public void setMontoVencido(BigDecimal montoVencido) {
        this.montoVencido = montoVencido;
    }

    public Integer getDiasVencidosIntord() {
        return diasVencidosIntord;
    }

    public void setDiasVencidosIntord(Integer diasVencidosIntord) {
        this.diasVencidosIntord = diasVencidosIntord;
    }

    public BigDecimal getMontoIoTotal() {
        return montoIoTotal;
    }

    public void setMontoIoTotal(BigDecimal montoIoTotal) {
        this.montoIoTotal = montoIoTotal;
    }

    public BigDecimal getMontoBonificacion() {
        return montoBonificacion;
    }

    public void setMontoBonificacion(BigDecimal montoBonificacion) {
        this.montoBonificacion = montoBonificacion;
    }

    public String getFechaVencimiento() {
        return fechaVencimiento;
    }

    public void setFechaVencimiento(String fechaVencimiento) {
        this.fechaVencimiento = fechaVencimiento;
    }

    public BigDecimal getImCalculado() {
        return imCalculado;
    }

    public void setImCalculado(BigDecimal imCalculado) {
        this.imCalculado = imCalculado;
    }

    public String getFechaSigAbono() {
        return fechaSigAbono;
    }

    public void setFechaSigAbono(String fechaSigAbono) {
        this.fechaSigAbono = fechaSigAbono;
    }

    public BigDecimal getMontoPorVencer() {
        return montoPorVencer;
    }

    public void setMontoPorVencer(BigDecimal montoPorVencer) {
        this.montoPorVencer = montoPorVencer;
    }

    public BigDecimal getIoCalculado() {
        return ioCalculado;
    }

    public void setIoCalculado(BigDecimal ioCalculado) {
        this.ioCalculado = ioCalculado;
    }

    public String getEstatusCartera() {
        return estatusCartera;
    }

    public void setEstatusCartera(String estatusCartera) {
        this.estatusCartera = estatusCartera;
    }

    public BigDecimal getIdncCalculado() {
        return idncCalculado;
    }

    public void setIdncCalculado(BigDecimal idncCalculado) {
        this.idncCalculado = idncCalculado;
    }

    public BigDecimal getMontoImTotal() {
        return montoImTotal;
    }

    public void setMontoImTotal(BigDecimal montoImTotal) {
        this.montoImTotal = montoImTotal;
    }

    public String getFechaLimite() {
        return fechaLimite;
    }

    public void setFechaLimite(String fechaLimite) {
        this.fechaLimite = fechaLimite;
    }

    public BigDecimal getIvaIoTotal() {
        return ivaIoTotal;
    }

    public void setIvaIoTotal(BigDecimal ivaIoTotal) {
        this.ivaIoTotal = ivaIoTotal;
    }

    public BigDecimal getIvaImTotal() {
        return ivaImTotal;
    }

    public void setIvaImTotal(BigDecimal ivaImTotal) {
        this.ivaImTotal = ivaImTotal;
    }

    public BigDecimal getDifDesctoIo() {
        return difDesctoIo;
    }

    public void setDifDesctoIo(BigDecimal difDesctoIo) {
        this.difDesctoIo = difDesctoIo;
    }

    public BigDecimal getComisionNpCalc() {
        return comisionNpCalc;
    }

    public void setComisionNpCalc(BigDecimal comisionNpCalc) {
        this.comisionNpCalc = comisionNpCalc;
    }

    public BigDecimal getComisionNpTotal() {
        return comisionNpTotal;
    }

    public void setComisionNpTotal(BigDecimal comisionNpTotal) {
        this.comisionNpTotal = comisionNpTotal;
    }

    public Integer getDiasVencidosCapital() {
        return diasVencidosCapital;
    }

    public void setDiasVencidosCapital(Integer diasVencidosCapital) {
        this.diasVencidosCapital = diasVencidosCapital;
    }

    @Override
    public String toString() {
        return "SaiAuxiliarPrestamoDTO{" + "tipoProducto=" + tipoProducto + ", fechaUmi=" + fechaUmi + ", abonosVencidos=" + abonosVencidos + ", diasVencidos=" + diasVencidos + ", montoVencido=" + montoVencido + ", diasVencidosIntord=" + diasVencidosIntord + ", montoIoTotal=" + montoIoTotal + ", montoBonificacion=" + montoBonificacion + ", fechaVencimiento=" + fechaVencimiento + ", imCalculado=" + imCalculado + ", fechaSigAbono=" + fechaSigAbono + ", montoPorVencer=" + montoPorVencer + ", ioCalculado=" + ioCalculado + ", estatusCartera=" + estatusCartera + ", idncCalculado=" + idncCalculado + ", montoImTotal=" + montoImTotal + ", fechaLimite=" + fechaLimite + ", ivaIoTotal=" + ivaIoTotal + ", ivaImTotal=" + ivaImTotal + ", difDesctoIo=" + difDesctoIo + ", comisionNpCalc=" + comisionNpCalc + ", comisionNpTotal=" + comisionNpTotal + ", diasVencidosCapital=" + diasVencidosCapital + '}';
    }

}
