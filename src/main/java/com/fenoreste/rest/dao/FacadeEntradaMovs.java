/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.dao;

import com.fenoreste.rest.DTO.OgsDTO;
import com.fenoreste.rest.DTO.OpaDTO;
import com.fenoreste.rest.Util.AbstractFacade;
import com.fenoreste.rest.Util.Utilidades;
import com.fenoreste.rest.Util.UtilidadesGenerales;
import com.fenoreste.rest.entidades.Auxiliares;
import com.fenoreste.rest.entidades.AuxiliaresPK;
import com.fenoreste.rest.entidades.MovimientoEntrada;
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

    public boolean guardar(MovimientoEntrada mov) {
        boolean bandera = false;
        try {
            EntityManager em = AbstractFacade.conexion();
            em.getTransaction().begin();
            em.persist(mov);
            em.getTransaction().commit();
            em.clear();
            em.close();
            bandera = true;
        } catch (Exception e) {
            System.out.println("Error al persistir el movimiento:" + e.getMessage());
        }
        return bandera;
    }

    public MovimientoEntrada buscarUltimoMovimiento(MovimientoEntrada mov) {
        MovimientoEntrada movimiento = new MovimientoEntrada();
        try {
            EntityManager em = AbstractFacade.conexion();
            String sql = "SELECT * FROM movimientos_entrada_bankingly WHERE clientbankidentifier='" + mov.getClientbankidentifier() + "' ORDER BY valuedate DESC LIMIT 1";
            Query query = em.createNativeQuery(sql, MovimientoEntrada.class);
            movimiento = (MovimientoEntrada) query.getSingleResult();

        } catch (Exception e) {
            System.out.println("Error al buscar movimiento:" + e.getMessage());
        }
        return movimiento;
    }

    public boolean buscarPorId(MovimientoEntrada mov) {
        boolean bandera = false;
        try {
            EntityManager em = AbstractFacade.conexion();
            //Primero buscamos registro por ID 
            MovimientoEntrada movimiento = em.find(MovimientoEntrada.class, mov.getTransactionid());
            if (movimiento != null) {
                System.out.println("Ya existe el movimiento con el id:" + mov.getTransactionid());
                bandera = true;
            }
        } catch (Exception e) {
            System.out.println("Error al buscar movimiento por id:" + e.getMessage());
        }
        return bandera;
    }
}
