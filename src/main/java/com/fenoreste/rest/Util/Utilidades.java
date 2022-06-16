/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.Util;

import com.fenoreste.rest.DTO.OgsDTO;
import com.fenoreste.rest.DTO.OpaDTO;

/**
 *
 * @author wilmer
 */
public class Utilidades {
    
    public OpaDTO opa(String cadena){
        OpaDTO opa=new OpaDTO();
        try {
            opa.setIdorigenp(Integer.parseInt(cadena.substring(0, 6)));
            opa.setIdproducto(Integer.parseInt(cadena.substring(6, 11)));
            opa.setIdauxiliar(Integer.parseInt(cadena.substring(11, 19)));
        } catch (Exception e) {
            System.out.println("Error:"+e.getMessage());
        }
        return opa;
    }
    
    public OgsDTO ogs(String cadena){
        OgsDTO ogs=new OgsDTO();
        try {
            ogs.setIdorigen(Integer.parseInt(cadena.substring(0, 6)));
            ogs.setIdgrupo(Integer.parseInt(cadena.substring(6, 8)));
            ogs.setIdsocio(Integer.parseInt(cadena.substring(8, 14)));
        } catch (Exception e) {
            System.out.println("Error:"+e.getMessage());
        }
        return ogs;
    }
    
}
