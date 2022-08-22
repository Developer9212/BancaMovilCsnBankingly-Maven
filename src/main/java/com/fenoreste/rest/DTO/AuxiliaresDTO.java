/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.DTO;

import com.fenoreste.rest.entidades.AuxiliaresPK;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.Objects;

/**
 *
 * @author wilmer
 */
public class AuxiliaresDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    protected AuxiliaresPK auxiliaresPK;
    private Integer idorigen;
    private Integer idgrupo;
    private Integer idsocio;
    private Date fechaape;
    private Integer elaboro;
    private Integer autorizo;
    private Short estatus;
    private BigDecimal tasaio;
    private BigDecimal tasaim;
    private BigDecimal tasaiod;
    private BigDecimal montosolicitado;
    private BigDecimal montoautorizado;
    private BigDecimal montoprestado;
    private Integer idfinalidad;
    private short plazo;
    private short periodoabonos;
    private BigDecimal saldoinicial;
    private BigDecimal saldo;
    private BigDecimal io;
    private BigDecimal idnc;
    private BigDecimal ieco;
    private BigDecimal im;
    private BigDecimal iva;
    private Date fechaactivacion;
    private Date fechaumi;
    private String idnotas;
    private short tipoprestamo;
    private String cartera;
    private BigDecimal contaidnc;
    private BigDecimal contaieco;
    private BigDecimal reservaidnc;
    private BigDecimal reservacapital;
    private Short tipoamortizacion;
    private BigDecimal saldodiacum;
    private Date fechacartera;
    private Date fechauma;
    private BigDecimal ivaidnccalc;
    private BigDecimal ivaidncpag;
    private Short tiporeferencia;
    private Integer calificacion;
    private Short pagodiafijo;
    private BigDecimal iodif;
    private BigDecimal garantia;
    private BigDecimal saldodiacummi;
    private BigDecimal comision;
    private Date fechasdiacum;
    private BigDecimal prcComision;
    private BigDecimal sobreprecio;
    private BigDecimal comisionNp;
    private Boolean pagosDiaUltimo;
    private Integer tipoDv;
    private Date fechaSolicitud;
    private Date fechaAutorizacion;
    private BigDecimal idncm;
    private BigDecimal iecom;
    private BigDecimal reservaidncm;

    public AuxiliaresDTO() {
    }

    public Integer getIdorigen() {
        return idorigen;
    }

    public void setIdorigen(Integer idorigen) {
        this.idorigen = idorigen;
    }

    public Integer getIdgrupo() {
        return idgrupo;
    }

    public void setIdgrupo(Integer idgrupo) {
        this.idgrupo = idgrupo;
    }

    public Integer getIdsocio() {
        return idsocio;
    }

    public void setIdsocio(Integer idsocio) {
        this.idsocio = idsocio;
    }

    public AuxiliaresPK getAuxiliaresPK() {
        return auxiliaresPK;
    }

    public void setAuxiliaresPK(AuxiliaresPK auxiliaresPK) {
        this.auxiliaresPK = auxiliaresPK;
    }

    public Date getFechaape() {
        return fechaape;
    }

    public void setFechaape(Date fechaape) {
        this.fechaape = fechaape;
    }

    public Integer getElaboro() {
        return elaboro;
    }

    public void setElaboro(Integer elaboro) {
        this.elaboro = elaboro;
    }

    public Integer getAutorizo() {
        return autorizo;
    }

    public void setAutorizo(Integer autorizo) {
        this.autorizo = autorizo;
    }

    public Short getEstatus() {
        return estatus;
    }

    public void setEstatus(Short estatus) {
        this.estatus = estatus;
    }

    public BigDecimal getTasaio() {
        return tasaio;
    }

    public void setTasaio(BigDecimal tasaio) {
        this.tasaio = tasaio;
    }

    public BigDecimal getTasaim() {
        return tasaim;
    }

    public void setTasaim(BigDecimal tasaim) {
        this.tasaim = tasaim;
    }

    public BigDecimal getTasaiod() {
        return tasaiod;
    }

    public void setTasaiod(BigDecimal tasaiod) {
        this.tasaiod = tasaiod;
    }

    public BigDecimal getMontosolicitado() {
        return montosolicitado;
    }

    public void setMontosolicitado(BigDecimal montosolicitado) {
        this.montosolicitado = montosolicitado;
    }

    public BigDecimal getMontoautorizado() {
        return montoautorizado;
    }

    public void setMontoautorizado(BigDecimal montoautorizado) {
        this.montoautorizado = montoautorizado;
    }

    public BigDecimal getMontoprestado() {
        return montoprestado;
    }

    public void setMontoprestado(BigDecimal montoprestado) {
        this.montoprestado = montoprestado;
    }

    public Integer getIdfinalidad() {
        return idfinalidad;
    }

    public void setIdfinalidad(Integer idfinalidad) {
        this.idfinalidad = idfinalidad;
    }

    public short getPlazo() {
        return plazo;
    }

    public void setPlazo(short plazo) {
        this.plazo = plazo;
    }

    public short getPeriodoabonos() {
        return periodoabonos;
    }

    public void setPeriodoabonos(short periodoabonos) {
        this.periodoabonos = periodoabonos;
    }

    public BigDecimal getSaldoinicial() {
        return saldoinicial;
    }

    public void setSaldoinicial(BigDecimal saldoinicial) {
        this.saldoinicial = saldoinicial;
    }

    public BigDecimal getSaldo() {
        return saldo;
    }

    public void setSaldo(BigDecimal saldo) {
        this.saldo = saldo;
    }

    public BigDecimal getIo() {
        return io;
    }

    public void setIo(BigDecimal io) {
        this.io = io;
    }

    public BigDecimal getIdnc() {
        return idnc;
    }

    public void setIdnc(BigDecimal idnc) {
        this.idnc = idnc;
    }

    public BigDecimal getIeco() {
        return ieco;
    }

    public void setIeco(BigDecimal ieco) {
        this.ieco = ieco;
    }

    public BigDecimal getIm() {
        return im;
    }

    public void setIm(BigDecimal im) {
        this.im = im;
    }

    public BigDecimal getIva() {
        return iva;
    }

    public void setIva(BigDecimal iva) {
        this.iva = iva;
    }

    public Date getFechaactivacion() {
        return fechaactivacion;
    }

    public void setFechaactivacion(Date fechaactivacion) {
        this.fechaactivacion = fechaactivacion;
    }

    public Date getFechaumi() {
        return fechaumi;
    }

    public void setFechaumi(Date fechaumi) {
        this.fechaumi = fechaumi;
    }

    public String getIdnotas() {
        return idnotas;
    }

    public void setIdnotas(String idnotas) {
        this.idnotas = idnotas;
    }

    public short getTipoprestamo() {
        return tipoprestamo;
    }

    public void setTipoprestamo(short tipoprestamo) {
        this.tipoprestamo = tipoprestamo;
    }

    public String getCartera() {
        return cartera;
    }

    public void setCartera(String cartera) {
        this.cartera = cartera;
    }

    public BigDecimal getContaidnc() {
        return contaidnc;
    }

    public void setContaidnc(BigDecimal contaidnc) {
        this.contaidnc = contaidnc;
    }

    public BigDecimal getContaieco() {
        return contaieco;
    }

    public void setContaieco(BigDecimal contaieco) {
        this.contaieco = contaieco;
    }

    public BigDecimal getReservaidnc() {
        return reservaidnc;
    }

    public void setReservaidnc(BigDecimal reservaidnc) {
        this.reservaidnc = reservaidnc;
    }

    public BigDecimal getReservacapital() {
        return reservacapital;
    }

    public void setReservacapital(BigDecimal reservacapital) {
        this.reservacapital = reservacapital;
    }

    public Short getTipoamortizacion() {
        return tipoamortizacion;
    }

    public void setTipoamortizacion(Short tipoamortizacion) {
        this.tipoamortizacion = tipoamortizacion;
    }

    public BigDecimal getSaldodiacum() {
        return saldodiacum;
    }

    public void setSaldodiacum(BigDecimal saldodiacum) {
        this.saldodiacum = saldodiacum;
    }

    public Date getFechacartera() {
        return fechacartera;
    }

    public void setFechacartera(Date fechacartera) {
        this.fechacartera = fechacartera;
    }

    public Date getFechauma() {
        return fechauma;
    }

    public void setFechauma(Date fechauma) {
        this.fechauma = fechauma;
    }

    public BigDecimal getIvaidnccalc() {
        return ivaidnccalc;
    }

    public void setIvaidnccalc(BigDecimal ivaidnccalc) {
        this.ivaidnccalc = ivaidnccalc;
    }

    public BigDecimal getIvaidncpag() {
        return ivaidncpag;
    }

    public void setIvaidncpag(BigDecimal ivaidncpag) {
        this.ivaidncpag = ivaidncpag;
    }

    public Short getTiporeferencia() {
        return tiporeferencia;
    }

    public void setTiporeferencia(Short tiporeferencia) {
        this.tiporeferencia = tiporeferencia;
    }

    public Integer getCalificacion() {
        return calificacion;
    }

    public void setCalificacion(Integer calificacion) {
        this.calificacion = calificacion;
    }

    public Short getPagodiafijo() {
        return pagodiafijo;
    }

    public void setPagodiafijo(Short pagodiafijo) {
        this.pagodiafijo = pagodiafijo;
    }

    public BigDecimal getIodif() {
        return iodif;
    }

    public void setIodif(BigDecimal iodif) {
        this.iodif = iodif;
    }

    public BigDecimal getGarantia() {
        return garantia;
    }

    public void setGarantia(BigDecimal garantia) {
        this.garantia = garantia;
    }

    public BigDecimal getSaldodiacummi() {
        return saldodiacummi;
    }

    public void setSaldodiacummi(BigDecimal saldodiacummi) {
        this.saldodiacummi = saldodiacummi;
    }

    public BigDecimal getComision() {
        return comision;
    }

    public void setComision(BigDecimal comision) {
        this.comision = comision;
    }

    public Date getFechasdiacum() {
        return fechasdiacum;
    }

    public void setFechasdiacum(Date fechasdiacum) {
        this.fechasdiacum = fechasdiacum;
    }

    public BigDecimal getPrcComision() {
        return prcComision;
    }

    public void setPrcComision(BigDecimal prcComision) {
        this.prcComision = prcComision;
    }

    public BigDecimal getSobreprecio() {
        return sobreprecio;
    }

    public void setSobreprecio(BigDecimal sobreprecio) {
        this.sobreprecio = sobreprecio;
    }

    public BigDecimal getComisionNp() {
        return comisionNp;
    }

    public void setComisionNp(BigDecimal comisionNp) {
        this.comisionNp = comisionNp;
    }

    public Boolean getPagosDiaUltimo() {
        return pagosDiaUltimo;
    }

    public void setPagosDiaUltimo(Boolean pagosDiaUltimo) {
        this.pagosDiaUltimo = pagosDiaUltimo;
    }

    public Integer getTipoDv() {
        return tipoDv;
    }

    public void setTipoDv(Integer tipoDv) {
        this.tipoDv = tipoDv;
    }

    public Date getFechaSolicitud() {
        return fechaSolicitud;
    }

    public void setFechaSolicitud(Date fechaSolicitud) {
        this.fechaSolicitud = fechaSolicitud;
    }

    public Date getFechaAutorizacion() {
        return fechaAutorizacion;
    }

    public void setFechaAutorizacion(Date fechaAutorizacion) {
        this.fechaAutorizacion = fechaAutorizacion;
    }

    public BigDecimal getIdncm() {
        return idncm;
    }

    public void setIdncm(BigDecimal idncm) {
        this.idncm = idncm;
    }

    public BigDecimal getIecom() {
        return iecom;
    }

    public void setIecom(BigDecimal iecom) {
        this.iecom = iecom;
    }

    public BigDecimal getReservaidncm() {
        return reservaidncm;
    }

    public void setReservaidncm(BigDecimal reservaidncm) {
        this.reservaidncm = reservaidncm;
    }

    @Override
    public int hashCode() {
        int hash = 7;
        hash = 83 * hash + Objects.hashCode(this.auxiliaresPK);
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
        final AuxiliaresDTO other = (AuxiliaresDTO) obj;
        return Objects.equals(this.auxiliaresPK, other.auxiliaresPK);
    }

    @Override
    public String toString() {
        return "AuxiliaresDTO{" + "idorigen=" + idorigen + ", idgrupo=" + idgrupo + ", idsocio=" + idsocio + ", auxiliaresPK=" + auxiliaresPK + ", fechaape=" + fechaape + ", elaboro=" + elaboro + ", autorizo=" + autorizo + ", estatus=" + estatus + ", tasaio=" + tasaio + ", tasaim=" + tasaim + ", tasaiod=" + tasaiod + ", montosolicitado=" + montosolicitado + ", montoautorizado=" + montoautorizado + ", montoprestado=" + montoprestado + ", idfinalidad=" + idfinalidad + ", plazo=" + plazo + ", periodoabonos=" + periodoabonos + ", saldoinicial=" + saldoinicial + ", saldo=" + saldo + ", io=" + io + ", idnc=" + idnc + ", ieco=" + ieco + ", im=" + im + ", iva=" + iva + ", fechaactivacion=" + fechaactivacion + ", fechaumi=" + fechaumi + ", idnotas=" + idnotas + ", tipoprestamo=" + tipoprestamo + ", cartera=" + cartera + ", contaidnc=" + contaidnc + ", contaieco=" + contaieco + ", reservaidnc=" + reservaidnc + ", reservacapital=" + reservacapital + ", tipoamortizacion=" + tipoamortizacion + ", saldodiacum=" + saldodiacum + ", fechacartera=" + fechacartera + ", fechauma=" + fechauma + ", ivaidnccalc=" + ivaidnccalc + ", ivaidncpag=" + ivaidncpag + ", tiporeferencia=" + tiporeferencia + ", calificacion=" + calificacion + ", pagodiafijo=" + pagodiafijo + ", iodif=" + iodif + ", garantia=" + garantia + ", saldodiacummi=" + saldodiacummi + ", comision=" + comision + ", fechasdiacum=" + fechasdiacum + ", prcComision=" + prcComision + ", sobreprecio=" + sobreprecio + ", comisionNp=" + comisionNp + ", pagosDiaUltimo=" + pagosDiaUltimo + ", tipoDv=" + tipoDv + ", fechaSolicitud=" + fechaSolicitud + ", fechaAutorizacion=" + fechaAutorizacion + ", idncm=" + idncm + ", iecom=" + iecom + ", reservaidncm=" + reservaidncm + '}';
    }

}
