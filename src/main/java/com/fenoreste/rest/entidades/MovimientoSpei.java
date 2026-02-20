/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.entidades;

/**
 *
 * @author wilmer
 */
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

/**
 *
 * @author Will
 */
@Entity
@Table(name = "bankingly_movimientos_spei")
public class MovimientoSpei implements java.io.Serializable {
    
    @EmbeddedId
    private MovimientoSpeiPK movimientoSpeiPK;
    private Integer idorden_spei;    
    private Integer idorigen;
    private Integer idgrupo;
    private Integer idsocio;
    private Integer idorigenp;
    private Integer idproducto;
    private Integer idauxiliar;
    private String idcuenta;
    private Integer cargoabono;
    private Double monto;
    private boolean spei_cancelado;

    public MovimientoSpei(MovimientoSpeiPK movimientoSpeiPK, Integer idorden_spei, Integer idorigen, Integer idgrupo, Integer idsocio, Integer idorigenp, Integer idproducto, Integer idauxiliar, String idcuenta, Integer cargoabono, Double monto, boolean spei_cancelado) {
        this.movimientoSpeiPK = movimientoSpeiPK;
        this.idorden_spei = idorden_spei;
        this.idorigen = idorigen;
        this.idgrupo = idgrupo;
        this.idsocio = idsocio;
        this.idorigenp = idorigenp;
        this.idproducto = idproducto;
        this.idauxiliar = idauxiliar;
        this.idcuenta = idcuenta;
        this.cargoabono = cargoabono;
        this.monto = monto;
        this.spei_cancelado = spei_cancelado;
    }

    public MovimientoSpei() {
    }

    public MovimientoSpeiPK getMovimientoSpeiPK() {
        return movimientoSpeiPK;
    }

    public void setMovimientoSpeiPK(MovimientoSpeiPK movimientoSpeiPK) {
        this.movimientoSpeiPK = movimientoSpeiPK;
    }

    public Integer getIdorden_spei() {
        return idorden_spei;
    }

    public void setIdorden_spei(Integer idorden_spei) {
        this.idorden_spei = idorden_spei;
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

    public Integer getIdorigenp() {
        return idorigenp;
    }

    public void setIdorigenp(Integer idorigenp) {
        this.idorigenp = idorigenp;
    }

    public Integer getIdproducto() {
        return idproducto;
    }

    public void setIdproducto(Integer idproducto) {
        this.idproducto = idproducto;
    }

    public Integer getIdauxiliar() {
        return idauxiliar;
    }

    public void setIdauxiliar(Integer idauxiliar) {
        this.idauxiliar = idauxiliar;
    }

    public String getIdcuenta() {
        return idcuenta;
    }

    public void setIdcuenta(String idcuenta) {
        this.idcuenta = idcuenta;
    }

    public Integer getCargoabono() {
        return cargoabono;
    }

    public void setCargoabono(Integer cargoabono) {
        this.cargoabono = cargoabono;
    }

    public Double getMonto() {
        return monto;
    }

    public void setMonto(Double monto) {
        this.monto = monto;
    }

    public boolean isSpei_cancelado() {
        return spei_cancelado;
    }

    public void setSpei_cancelado(boolean spei_cancelado) {
        this.spei_cancelado = spei_cancelado;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("MovimientoSpei{movimientoSpeiPK=").append(movimientoSpeiPK);
        sb.append(", idorden_spei=").append(idorden_spei);
        sb.append(", idorigen=").append(idorigen);
        sb.append(", idgrupo=").append(idgrupo);
        sb.append(", idsocio=").append(idsocio);
        sb.append(", idorigenp=").append(idorigenp);
        sb.append(", idproducto=").append(idproducto);
        sb.append(", idauxiliar=").append(idauxiliar);
        sb.append(", idcuenta=").append(idcuenta);
        sb.append(", cargoabono=").append(cargoabono);
        sb.append(", monto=").append(monto);
        sb.append(", spei_cancelado=").append(spei_cancelado);
        sb.append('}');
        return sb.toString();
    }
    
    
    

    private static final long serialVersionUID = 1L;

}

