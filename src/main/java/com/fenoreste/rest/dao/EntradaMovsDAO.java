/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.dao;

import com.fenoreste.rest.entidades.MovimientoEntrada;
import com.fenoreste.rest.entidades.Transferencia;

/**
 *
 * @author wilmer
 */
public class EntradaMovsDAO extends FacadeEntradaMovs<Transferencia>{
	 
    public EntradaMovsDAO() {
		    super(Transferencia.class);		  
     } 
}
