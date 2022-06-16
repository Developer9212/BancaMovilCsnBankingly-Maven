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
public class DistribucionPrestamoDTO implements Serializable {

    private BigDecimal segHip;
    private BigDecimal ComCob;
    private BigDecimal im;
    private BigDecimal ivaIm;
    private BigDecimal io;
    private BigDecimal ivaIo;
    private BigDecimal aCapital;

    public DistribucionPrestamoDTO() {
    }

    public BigDecimal getSegHip() {
        return segHip;
    }

    public void setSegHip(BigDecimal segHip) {
        this.segHip = segHip;
    }

    public BigDecimal getComCob() {
        return ComCob;
    }

    public void setComCob(BigDecimal ComCob) {
        this.ComCob = ComCob;
    }

    public BigDecimal getIm() {
        return im;
    }

    public void setIm(BigDecimal im) {
        this.im = im;
    }

    public BigDecimal getIvaIm() {
        return ivaIm;
    }

    public void setIvaIm(BigDecimal ivaIm) {
        this.ivaIm = ivaIm;
    }

    public BigDecimal getIo() {
        return io;
    }

    public void setIo(BigDecimal io) {
        this.io = io;
    }

    public BigDecimal getIvaIo() {
        return ivaIo;
    }

    public void setIvaIo(BigDecimal ivaIo) {
        this.ivaIo = ivaIo;
    }

    public BigDecimal getaCapital() {
        return aCapital;
    }

    public void setaCapital(BigDecimal aCapital) {
        this.aCapital = aCapital;
    }

    @Override
    public String toString() {
        return "DistribucionPrestamoDTO{" + "segHipb=" + segHip + ", ComCob=" + ComCob + ", im=" + im + ", ivaIm=" + ivaIm + ", io=" + io + ", ivaIo=" + ivaIo + ", aCapital=" + aCapital + '}';
    }

}
