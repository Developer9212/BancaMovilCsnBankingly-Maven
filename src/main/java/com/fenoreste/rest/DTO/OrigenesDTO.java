/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.DTO;

import java.io.Serializable;
import java.util.Date;
import java.util.Objects;


/**
 *
 * @author wilmer
 */
public class OrigenesDTO implements Serializable {

    private Integer idorigen;
    private int matriz;
    private String nombre;
    private String calle;
    private String numeroext;
    private String numeroint;
    private String telefono1;
    private String telefono2;
    private String codigopostal;
    private boolean estatus;
    private Date fechatrabajo;
    private String ctaRendimientos;
    private String ctaQuebrantos;
    private String ctaEfectivo;
    private String ctaDocumentos1;
    private String ctaDocumentos2;
    private String ctaDocumentos3;
    private String ctaDocumentos4;
    private String ctaDocumentos5;
    private boolean enlinea;
    private String ctaDocumentos6;
    private String ctaDocumentos7;

    public OrigenesDTO() {
    }

    public Integer getIdorigen() {
        return idorigen;
    }

    public void setIdorigen(Integer idorigen) {
        this.idorigen = idorigen;
    }

    public int getMatriz() {
        return matriz;
    }

    public void setMatriz(int matriz) {
        this.matriz = matriz;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getCalle() {
        return calle;
    }

    public void setCalle(String calle) {
        this.calle = calle;
    }

    public String getNumeroext() {
        return numeroext;
    }

    public void setNumeroext(String numeroext) {
        this.numeroext = numeroext;
    }

    public String getNumeroint() {
        return numeroint;
    }

    public void setNumeroint(String numeroint) {
        this.numeroint = numeroint;
    }

    public String getTelefono1() {
        return telefono1;
    }

    public void setTelefono1(String telefono1) {
        this.telefono1 = telefono1;
    }

    public String getTelefono2() {
        return telefono2;
    }

    public void setTelefono2(String telefono2) {
        this.telefono2 = telefono2;
    }

    public String getCodigopostal() {
        return codigopostal;
    }

    public void setCodigopostal(String codigopostal) {
        this.codigopostal = codigopostal;
    }

    public boolean isEstatus() {
        return estatus;
    }

    public void setEstatus(boolean estatus) {
        this.estatus = estatus;
    }

    public Date getFechatrabajo() {
        return fechatrabajo;
    }

    public void setFechatrabajo(Date fechatrabajo) {
        this.fechatrabajo = fechatrabajo;
    }

    public String getCtaRendimientos() {
        return ctaRendimientos;
    }

    public void setCtaRendimientos(String ctaRendimientos) {
        this.ctaRendimientos = ctaRendimientos;
    }

    public String getCtaQuebrantos() {
        return ctaQuebrantos;
    }

    public void setCtaQuebrantos(String ctaQuebrantos) {
        this.ctaQuebrantos = ctaQuebrantos;
    }

    public String getCtaEfectivo() {
        return ctaEfectivo;
    }

    public void setCtaEfectivo(String ctaEfectivo) {
        this.ctaEfectivo = ctaEfectivo;
    }

    public String getCtaDocumentos1() {
        return ctaDocumentos1;
    }

    public void setCtaDocumentos1(String ctaDocumentos1) {
        this.ctaDocumentos1 = ctaDocumentos1;
    }

    public String getCtaDocumentos2() {
        return ctaDocumentos2;
    }

    public void setCtaDocumentos2(String ctaDocumentos2) {
        this.ctaDocumentos2 = ctaDocumentos2;
    }

    public String getCtaDocumentos3() {
        return ctaDocumentos3;
    }

    public void setCtaDocumentos3(String ctaDocumentos3) {
        this.ctaDocumentos3 = ctaDocumentos3;
    }

    public String getCtaDocumentos4() {
        return ctaDocumentos4;
    }

    public void setCtaDocumentos4(String ctaDocumentos4) {
        this.ctaDocumentos4 = ctaDocumentos4;
    }

    public String getCtaDocumentos5() {
        return ctaDocumentos5;
    }

    public void setCtaDocumentos5(String ctaDocumentos5) {
        this.ctaDocumentos5 = ctaDocumentos5;
    }

    public boolean isEnlinea() {
        return enlinea;
    }

    public void setEnlinea(boolean enlinea) {
        this.enlinea = enlinea;
    }

    public String getCtaDocumentos6() {
        return ctaDocumentos6;
    }

    public void setCtaDocumentos6(String ctaDocumentos6) {
        this.ctaDocumentos6 = ctaDocumentos6;
    }

    public String getCtaDocumentos7() {
        return ctaDocumentos7;
    }

    public void setCtaDocumentos7(String ctaDocumentos7) {
        this.ctaDocumentos7 = ctaDocumentos7;
    }

    @Override
    public int hashCode() {
        int hash = 7;
        hash = 59 * hash + Objects.hashCode(this.idorigen);
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
        final OrigenesDTO other = (OrigenesDTO) obj;
        return Objects.equals(this.idorigen, other.idorigen);
    }

    @Override
    public String toString() {
        return "OrigenesDTO{" + "idorigen=" + idorigen + ", matriz=" + matriz + ", nombre=" + nombre + ", calle=" + calle + ", numeroext=" + numeroext + ", numeroint=" + numeroint + ", telefono1=" + telefono1 + ", telefono2=" + telefono2 + ", codigopostal=" + codigopostal + ", estatus=" + estatus + ", fechatrabajo=" + fechatrabajo + ", ctaRendimientos=" + ctaRendimientos + ", ctaQuebrantos=" + ctaQuebrantos + ", ctaEfectivo=" + ctaEfectivo + ", ctaDocumentos1=" + ctaDocumentos1 + ", ctaDocumentos2=" + ctaDocumentos2 + ", ctaDocumentos3=" + ctaDocumentos3 + ", ctaDocumentos4=" + ctaDocumentos4 + ", ctaDocumentos5=" + ctaDocumentos5 + ", enlinea=" + enlinea + ", ctaDocumentos6=" + ctaDocumentos6 + ", ctaDocumentos7=" + ctaDocumentos7 + '}';
    }
    
}
