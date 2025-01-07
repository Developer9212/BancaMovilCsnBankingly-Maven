/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.dao;

import com.fenoreste.rest.entidades.Auxiliar;

/**
 *
 * @author Elliot
 */
public class TransactionDAO extends FacadeTransaction<Auxiliar>{
	 public TransactionDAO() {
		    super(Auxiliar.class);		  
     } 
	}
