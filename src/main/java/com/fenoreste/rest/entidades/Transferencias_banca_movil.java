/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.entidades;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.Date;
import javax.persistence.Cacheable;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 *
 * @author Elliot
 */
@Entity
@Table(name = "transferencias_banca_movil_bankingly")
@Cacheable(false)
public class Transferencias_banca_movil implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    private Integer idtransaccion;
    private String referencia;
    private String tipotransferencia;
    private Date fecha;
    private String socio;
    private String opaorigen;
    private String opadestino;
    private Double monto;
    private Integer canal_transferencia;
    private String bancodestino;
    private String cuentadestino;
    private Integer idorden;
    
    
    
    public Transferencias_banca_movil() {
    }

    public Transferencias_banca_movil(Integer idtransaccion, String referencia, String tipotransferencia, Timestamp fecha, String socio, String opaorigen, String opadestino, Double monto, Integer canal_transferencia, String bancodestino, String cuentadestino, Integer idorden) {
        this.idtransaccion = idtransaccion;
        this.referencia = referencia;
        this.tipotransferencia = tipotransferencia;
        this.fecha = fecha;
        this.socio = socio;
        this.opaorigen = opaorigen;
        this.opadestino = opadestino;
        this.monto = monto;
        this.canal_transferencia = canal_transferencia;
        this.bancodestino = bancodestino;
        this.cuentadestino = cuentadestino;
        this.idorden = idorden;
    }

    public Integer getIdtransaccion() {
        return idtransaccion;
    }

    public void setIdtransaccion(Integer idtransaccion) {
        this.idtransaccion = idtransaccion;
    }

    public String getReferencia() {
        return referencia;
    }

    public void setReferencia(String referencia) {
        this.referencia = referencia;
    }

    public String getTipotransferencia() {
        return tipotransferencia;
    }

    public void setTipotransferencia(String tipotransferencia) {
        this.tipotransferencia = tipotransferencia;
    }

    public Date getfecha() {
        return fecha;
    }

    public void setfecha(Date fecha) {
        this.fecha = fecha;
    }

    public String getSocio() {
        return socio;
    }

    public void setSocio(String socio) {
        this.socio = socio;
    }

    public String getOpaorigen() {
        return opaorigen;
    }

    public void setOpaorigen(String opaorigen) {
        this.opaorigen = opaorigen;
    }

    public String getOpadestino() {
        return opadestino;
    }

    public void setOpadestino(String opadestino) {
        this.opadestino = opadestino;
    }

    public Double getMonto() {
        return monto;
    }

    public void setMonto(Double monto) {
        this.monto = monto;
    }

    public Integer getCanal_transferencia() {
        return canal_transferencia;
    }

    public void setCanal_transferencia(Integer canal_transferencia) {
        this.canal_transferencia = canal_transferencia;
    }

    public String getBancodestino() {
        return bancodestino;
    }

    public void setBancodestino(String bancodestino) {
        this.bancodestino = bancodestino;
    }

    public String getCuentadestino() {
        return cuentadestino;
    }

    public void setCuentadestino(String cuentadestino) {
        this.cuentadestino = cuentadestino;
    }

    public Integer getIdorden() {
        return idorden;
    }

    public void setIdorden(Integer idorden) {
        this.idorden = idorden;
    }

    @Override
    public String toString() {
        return "Transferencias_banca_movil{" + "idtransaccion=" + idtransaccion + ", referencia=" + referencia + ", tipotransferencia=" + tipotransferencia + ", fecha=" +fecha + ", socio=" + socio + ", opaorigen=" + opaorigen + ", opadestino=" + opadestino + ", monto=" + monto + ", canal_transferencia=" + canal_transferencia + ", bancodestino=" + bancodestino + ", cuentadestino=" + cuentadestino + ", idorden=" + idorden + '}';
    }
    
    
    
}
