/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.DTO;

import com.fenoreste.rest.entidades.TablasPK;
import java.io.Serializable;
import java.util.Objects;
import javax.xml.bind.annotation.XmlRootElement;

/**
 *
 * @author gerardo
 */
public class TablasDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    protected TablasPK tablasPK;
    private String nombre;
    private String dato1;
    private String dato2;
    private String dato3;
    private String dato4;
    private String dato5;
    private short tipo;

    public TablasDTO() {
    }

    public TablasPK getTablasPK() {
        return tablasPK;
    }

    public void setTablasPK(TablasPK tablasPK) {
        this.tablasPK = tablasPK;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDato1() {
        return dato1;
    }

    public void setDato1(String dato1) {
        this.dato1 = dato1;
    }

    public String getDato2() {
        return dato2;
    }

    public void setDato2(String dato2) {
        this.dato2 = dato2;
    }

    public String getDato3() {
        return dato3;
    }

    public void setDato3(String dato3) {
        this.dato3 = dato3;
    }

    public String getDato4() {
        return dato4;
    }

    public void setDato4(String dato4) {
        this.dato4 = dato4;
    }

    public String getDato5() {
        return dato5;
    }

    public void setDato5(String dato5) {
        this.dato5 = dato5;
    }

    public short getTipo() {
        return tipo;
    }

    public void setTipo(short tipo) {
        this.tipo = tipo;
    }

    @Override
    public int hashCode() {
        int hash = 3;
        hash = 79 * hash + Objects.hashCode(this.tablasPK);
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
        final TablasDTO other = (TablasDTO) obj;
        return Objects.equals(this.tablasPK, other.tablasPK);
    }

    @Override
    public String toString() {
        return "TablasDTO{" + "tablasPK=" + tablasPK + ", nombre=" + nombre + ", dato1=" + dato1 + ", dato2=" + dato2 + ", dato3=" + dato3 + ", dato4=" + dato4 + ", dato5=" + dato5 + ", tipo=" + tipo + '}';
    }

}
