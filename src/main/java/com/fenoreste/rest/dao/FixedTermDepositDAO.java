/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.dao;

import com.fenoreste.rest.entidades.Auxiliar;

/**
 *
 * @author nahum
 */
public class FixedTermDepositDAO extends FacadeFixedTermDeposit<Auxiliar>{
    public FixedTermDepositDAO() {
        super(Auxiliar.class);
    }
}
