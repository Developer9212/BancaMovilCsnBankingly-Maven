/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenorest.rest.EnviarSMS;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 *
 * @author wilmer
 */
public class EnviarSMS {
    /*
    // PARAMETROS: host, numero, mensaje
    public void enviar(String host, String numero, String mensaje) {
        ThreadEnviarSMS threadEnviarSMS = new ThreadEnviarSMS(host, numero, mensaje);
        threadEnviarSMS.start();
    }

    class ThreadEnviarSMS extends Thread {

        String host, numero, mensaje;

        // PARAMETROS: host, puerto, usuario, password, email, destinatario, tipo SSL o TLS, titulo del correo, mensaje
        public ThreadEnviarSMS(String host, String numero, String mensaje) {
            this.host = host;
            this.numero = numero;
            this.mensaje = mensaje;
        }

        @Override
        public void run() {
            enviarSMS(host, numero, mensaje);
        }

    }*/

    // PARAMETROS: host, numero, mensaje
    public String enviarSMS(String host, String numero, String mensaje) {
        String r = "";
        System.out.println("Enviando SMS al host"+host+", Numero:"+numero+",mensaje:"+mensaje);
        
        if (host != null && numero != null && mensaje != null) {
            numero = numero.replace(" ", "");
            numero = numero.trim();
            mensaje = mensaje.replace(" ", "%20");
            mensaje = mensaje.trim();
            if (numero.length() == 10) {
                System.out.println("le numero es correcto");
                if (mensaje.length() <= 160) {
                    System.out.println("el mensaje tambine");
                    //WsConnExternos wsConnExternos = new WsConnExternos();//esta es la clase en donde se genera una conexion y se lee lo que retorna
                    host = host.replace("_mensaje", mensaje);
                    host = host.replace("_numero", numero);
                    r = simpleConeccionURL(host);
                } else {
                    r = "Error: Mensaje mayor a 160 caracteres en EnvioSMS";
                    System.out.println("Error: Mensaje mayor a 160 caracteres en EnvioSMS" + r);//mensaje mayor a 160 caracteres
                }
            } else {
                    r = "Error: Numero invalido en EnvioSMS.";
                System.out.println("Error: Numero invalido en EnvioSMS. " + r); //numero invalido
            }
        } else {
            r = "URL para envio SMS invalida";
            System.out.println("url: " + host + "\nnumero: " + numero + "\nmensaje: " + mensaje);
        }
        return r;
    }

    public String simpleConeccionURL(String urlString) {
        String mensaje_ok_envio = "";
        try {
            // Creo un objeto url con la cadena
            URL url = new URL(urlString);
            System.out.println("URL:"+url);
            // Creo un objeto HttpURLConnection para conectarme
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            // El tiempo de espera para que se conecte
            con.setConnectTimeout(6000);
            // Este es el tiempo de espera de la lectura de lo que retorno en caso de que retorne
            con.setReadTimeout(3000);
            //Si la conexion fue exitosa
            if (con.getResponseCode() != HttpURLConnection.HTTP_OK) {
                System.out.println("No se envio el mensaje, error en conexion.");
                mensaje_ok_envio="Error desconocido no se pudo enviar el SMS";
            }else{
                mensaje_ok_envio="SMS enviado con exito";
                System.out.println("Enviado");
            }
        } catch (Exception e) {
            mensaje_ok_envio = "Error desconocido no se pudo enviar el SMS:"+e.getMessage();
            return mensaje_ok_envio;// "Exception en WsConnExternos.simpleConeccionURL " + e.getMessage();
        }
        return mensaje_ok_envio;
    }

}
