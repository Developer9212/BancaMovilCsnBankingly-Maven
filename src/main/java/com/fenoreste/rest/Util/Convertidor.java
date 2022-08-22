/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.Util;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.GregorianCalendar;
import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
/**
 *
 * @author wilmer
 */
public class Convertidor {
    
    public SimpleDateFormat formatoDeFecha;

    public Convertidor() {
        this.formatoDeFecha = new SimpleDateFormat("dd/MM/yyyy");
    }

    // a este metodo le pasas los tres valores del opa y te retorna el opa en
    // su formato de 32 caracteres
    public String getOPA32(int idorigenp, int idproducto, int idauxiliar) {
        return "0000000000000" // son 13 para completar los 32 digitos
                + String.format("%06d", idorigenp) // idorigenp
                + String.format("%05d", idproducto) // idproducto
                + String.format("%08d", idauxiliar); //idauxiliar
    }

    public int[] getOPA(String OPA32) {
        int[] opa = new int[3];
        if (OPA32.length() == 32) {
            opa[0] = Integer.parseInt(OPA32.substring(0, 19));
            opa[1] = Integer.parseInt(OPA32.substring(19, 24));
            opa[2] = Integer.parseInt(OPA32.substring(24, 32));
        }
        return opa;
    }

    public String getOGS32(int idorigen, int idgrupo, int idsocio) {
        return "000000000000000000" // son 18 para completar los 32 digitos
                + String.format("%06d", idorigen) // idorigen
                + String.format("%02d", idgrupo) // idgrupo
                + String.format("%06d", idsocio); // idsocio
    }

    // a este metodo le pasas como parametro tu cadena de 32 caracteres que
    // representa tu ogs y te retorna tu ogs en un arreglo de enteros
    public int[] getOGS(String OGS32) {
        int[] ogs = new int[3];
        if (OGS32.length() == 32) {
            ogs[0] = Integer.parseInt(OGS32.substring(0, 24)); //idorigen
            ogs[1] = Integer.parseInt(OGS32.substring(24, 26)); //idgrupo
            ogs[2] = Integer.parseInt(OGS32.substring(26, 32)); //idsocio
        }
        return ogs;
    }

    public String formatoFecha(XMLGregorianCalendar fecha, String formato) {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(formato);
        Date date = fecha.toGregorianCalendar().getTime();
        return simpleDateFormat.format(date);
    }

    public String formatoFecha(Date fecha, String formato) {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(formato);
        return simpleDateFormat.format(fecha);
    }

    public XMLGregorianCalendar aXMLGregorianCalendar(Date date) {
        GregorianCalendar gCalendar = new GregorianCalendar();
        gCalendar.setTime(date);
        XMLGregorianCalendar xmlCalendar = null;
        try {
            xmlCalendar = DatatypeFactory.newInstance().newXMLGregorianCalendar(gCalendar);
        } catch (DatatypeConfigurationException ex) {
            System.out.println("Error al transformar tipo Date a XmlGregorianCalendar: " + ex);
        }
        return xmlCalendar;
    }

    public String getFechaActual(String fe) {
        Date ahora = new Date();
        String salida;
        SimpleDateFormat formateador = new SimpleDateFormat("dd-MM-yyyy");
        String[] f = formateador.format(ahora).split("-");
        switch (fe) {
            case "dmy":
                salida = f[0] + f[1] + f[2].substring(2, 4);
                break;
            case "dmyyyy":
                salida = formateador.format(ahora);
                break;
            default:
                salida = f[2] + f[1];
                break;
        }
        return salida;
    }

    public Date aDate(XMLGregorianCalendar calendar) {
        if (calendar == null) {
            return null;
        }
        return calendar.toGregorianCalendar().getTime();
    }

    public String getOGSsesion(int idorigen, int idgrupo, int idsocio) {
        return String.format("%06d", idorigen) // idorigen
                + String.format("%02d", idgrupo) // idgrupo
                + String.format("%06d", idsocio); // idsocio
    }

    public String escapaCaracteresXmlNoValidos(Object in) {
        StringBuilder out = new StringBuilder();
        char current;
        if (in == null || ("".equals(in)) || in.toString().equals("|") || in.toString().equals("\\|")) {
            return "";
        }
        for (int i = 0; i < in.toString().length(); i++) {
            current = in.toString().charAt(i);
            if ((current == 0x9)
                    || (current == 0xA)
                    || (current == 0xD)
                    || ((current >= 0x20) && (current <= 0xD7FF))
                    || ((current >= 0xE000) && (current <= 0xFFFD))
                    || ((current >= 0x10000) && (current <= 0x10FFFF))) {
                out.append(current);
            }
        }
        return out.toString();
    }
}
