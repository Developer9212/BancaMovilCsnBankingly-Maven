/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package consumo_tdd;

import com.syc.ws.endpoint.siscoop.impl.SiscoopAlternativeEndpoint;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;
import javax.xml.ws.WebServiceException;

/**
 *
 * @author sistemas
 */
public class Siscoop_TDD {
    
    String hostLocal="",puertoLocal="",wsdlLocal="";
    public Siscoop_TDD(String usuario, String contraseña, String host, String puerto,String wsdl) {
        this.hostLocal=host;
        this.puertoLocal=puerto;
        this.wsdlLocal=wsdl;
        java.net.Authenticator.setDefault(new java.net.Authenticator() {
            // Pruebas: USUARIO: snicolas - PASSWORD: wsn4yc8ja$s
            // Produccion: USUARIO: ws_snicolas - PASSWORD: wu8K2SyJbjYc9rw
            @Override
            protected java.net.PasswordAuthentication getPasswordAuthentication() {
                // Credenciales SYC               
                return new java.net.PasswordAuthentication(usuario, contraseña.toCharArray());
            }
        });
    }

    // REALIZA UN PING A LA URL DEL WSDL
    private boolean pingURL(URL url, String tiempo) {
        try {
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setConnectTimeout(Integer.parseInt(tiempo));
            connection.setReadTimeout(Integer.parseInt(tiempo));
            int codigo = connection.getResponseCode();

            if (codigo == 200) {
                return true;
            }
        } catch (IOException ex) {
            System.out.println("Error al conectarse a SYC: " + ex.getMessage());
        }
        return false;
    }

    // GENERA EL PUERTO PARA SYC
    public SiscoopAlternativeEndpoint siscoop() {
        try {
            // Parametros SYC
            String wsdlLocation = "http://" + hostLocal + ":" + puertoLocal + "/syc/webservice/" + wsdlLocal+ "?wsdl";
            QName QNAME = new QName("http://impl.siscoop.endpoint.ws.syc.com/", "SiscoopAlternativeEndpointImplService");
            URL url = new URL(wsdlLocation);
            if (pingURL(url, "5000")) {                
                Service service = Service.create(url, QNAME);
                SiscoopAlternativeEndpoint port = service.getPort(SiscoopAlternativeEndpoint.class);
                return port;
            }else{
                
            }
        } catch (MalformedURLException | WebServiceException ex) {
            System.out.println(ex.getMessage());
        }
        return null;
    }

    // PUERTO
    public SiscoopAlternativeEndpoint getSiscoop() {
        return siscoop();
    }
}
