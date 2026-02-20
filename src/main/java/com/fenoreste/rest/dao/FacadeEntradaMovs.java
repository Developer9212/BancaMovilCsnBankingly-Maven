/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.dao;

import com.fenoreste.rest.Util.AbstractFacade;
import com.fenoreste.rest.Util.Utilidades;
import com.fenoreste.rest.Util.UtilidadesGenerales;
import com.fenoreste.rest.entidades.Transferencia;
import javax.persistence.EntityManager;
import javax.persistence.Query;

/**
 *
 * @author wilmer
 */
public abstract class FacadeEntradaMovs<T> {

    UtilidadesGenerales util2 = new UtilidadesGenerales();
    Utilidades util = new Utilidades();

    public FacadeEntradaMovs(Class<T> entityClass) {

    }

   

    public Transferencia buscarUltimoMovimiento(String ogs) {
        Transferencia movimiento = new Transferencia();
        
        try {
            EntityManager em = AbstractFacade.conexion();
            String sql = "SELECT * FROM transferencias_bankingly WHERE clientbankidentifier='" + ogs + "' ORDER BY fechaejecucion DESC LIMIT 1";
            Query query = em.createNativeQuery(sql, Transferencia.class);
            movimiento = (Transferencia) query.getSingleResult();
            System.out.println("Ultimo Movimiento recuperado:"+movimiento);
        } catch (Exception e) {
            System.out.println("Error al buscar movimiento:" + e.getMessage());
        }
        return movimiento;
    }
}
