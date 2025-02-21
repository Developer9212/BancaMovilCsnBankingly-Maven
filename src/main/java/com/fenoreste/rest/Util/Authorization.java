/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.Util;

import com.fenoreste.rest.entidades.Tabla;
import com.fenoreste.rest.entidades.TablaPK;
import java.io.IOException;
import javax.persistence.EntityManager;
import sun.misc.BASE64Decoder;

/**
 *
 * @author wilmer
 */
public class Authorization {

    public boolean isUserAuthenticated(String authString) {

        String decodedAuth = "";
        // Header is in the format "Basic 5tyc0uiDat4"
        // We need to extract data before decoding it back to original string
        if (authString != null) {
            try {

                String[] authParts = authString.split("\\s+");
                String authInfo = authParts[1];
                byte[] bytes = null;
                bytes = new BASE64Decoder().decodeBuffer(authInfo);
                decodedAuth = new String(bytes);
                String[] cadena = decodedAuth.split(":");
                String user = cadena[0];
                String pass = cadena[1];

                if (getUser().getDato1().equals(user) && getUser().getDato2().equals(pass)) {
                    return true;
                }
            } catch (IOException ex) {
                return false;

            }
        }
        return false;
    }

    private Tabla getUser() {
        TablaPK tbpk = new TablaPK("bankingly", "credenciales");
        boolean bandera = false;
        EntityManager em = AbstractFacade.conexion();
        Tabla tb = new Tabla();
        try {
            tb = em.find(Tabla.class, tbpk);
        } catch (Exception e) {
            System.out.println("error en busqueda tablas Auth:" + e.getMessage());
            return tb;
        }
        System.out.println("tb:"+tb);
        return tb;

    }

}
