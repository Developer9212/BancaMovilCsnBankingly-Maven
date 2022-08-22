/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.entidades;

import java.io.Serializable;
import java.math.BigInteger;
import javax.persistence.Cacheable;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 *
 * @author wilmer
 */

@Entity
@Table(name = "municipios")
public class Municipios implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idmunicipio;
    private String nombre;
    private Integer idestado;
    private Integer poblacion;
    private BigInteger localidad_siti;
    private String de_cp;
    private String a_cp;

    public Municipios() {
    } 

    public Municipios(Integer idmunicipio, String nombre, Integer idestado, Integer poblacion, BigInteger localidad_siti, String de_cp, String a_cp) {
        this.idmunicipio = idmunicipio;
        this.nombre = nombre;
        this.idestado = idestado;
        this.poblacion = poblacion;
        this.localidad_siti = localidad_siti;
        this.de_cp = de_cp;
        this.a_cp = a_cp;
    }

    public Integer getIdmunicipio() {
        return idmunicipio;
    }

    public void setIdmunicipio(Integer idmunicipio) {
        this.idmunicipio = idmunicipio;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public Integer getIdestado() {
        return idestado;
    }

    public void setIdestado(Integer idestado) {
        this.idestado = idestado;
    }

    public Integer getPoblacion() {
        return poblacion;
    }

    public void setPoblacion(Integer poblacion) {
        this.poblacion = poblacion;
    }

    public BigInteger getLocalidad_siti() {
        return localidad_siti;
    }

    public void setLocalidad_siti(BigInteger localidad_siti) {
        this.localidad_siti = localidad_siti;
    }

    public String getDe_cp() {
        return de_cp;
    }

    public void setDe_cp(String de_cp) {
        this.de_cp = de_cp;
    }

    public String getA_cp() {
        return a_cp;
    }

    public void setA_cp(String a_cp) {
        this.a_cp = a_cp;
    }
    
    
    @Override
    public String toString() {
        return "Municipios{" + "idmunicipio=" + idmunicipio + ", nombre=" + nombre + ", idestado=" + idestado + ", poblacion=" + poblacion + ", localidad_citi=" + localidad_siti + ", d_cp=" + de_cp + ", a_cp=" + a_cp + '}';
    }
    
    
}
