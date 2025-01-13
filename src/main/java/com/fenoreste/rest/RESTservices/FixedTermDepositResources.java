/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.RESTservices;

import com.fenoreste.rest.Request.FixedTermMethodPaymentDTO;
import com.fenoreste.rest.Request.TermDataReqVo;
import com.fenoreste.rest.ResponseDTO.DetallesInversionDTO;
import com.fenoreste.rest.dao.FixedTermDepositDAO;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import com.github.cliftonlabs.json_simple.JsonObject;
import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import com.fenoreste.rest.ResponseDTO.FixedTermMethodPaymentResponseDTO;

/**
 *
 * @author nahum
 */
@Path("/fixedTermDeposit")
public class FixedTermDepositResources {
    
    
    //fixedTermDeposit/fixedTermDepositTermsData
    @GET
    @Path("/details/{productBankIdentifier}")
    @Produces({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    public Response getfixedTermDeposit(@PathParam("productBankIdentifier") String productBankIdentifier) {

        FixedTermDepositDAO metodos = new FixedTermDepositDAO();
        JsonObject Json_De_Error = new JsonObject();

        if (!metodos.actividad_horario()) {
            Json_De_Error.put("ERROR", "VERIFIQUE SU HORARIO DE ACTIVIDAD FECHA,HORA O CONTACTE A SU PROVEEEDOR");
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(Json_De_Error).build();
        }

        String accountId = productBankIdentifier;
        DetallesInversionDTO info_cuenta = null;

        try {
            info_cuenta = metodos.getDetallesInversion(accountId);
            if (info_cuenta != null) {
                return Response.status(Response.Status.OK).entity(info_cuenta).build();
            } else {
                Json_De_Error.put("Error", "ERROR PRODUCTO NO ENCONTRADO");
                return Response.status(Response.Status.BAD_REQUEST).entity(Json_De_Error).build();
            }
        } catch (Exception e) {
            return Response.status(Response.Status.BAD_REQUEST).entity(Json_De_Error).build();
        }
    }

    @POST
    @Path("/GetFixedTermDepositTermsData/")
    @Produces({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    @Consumes({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    public Response fixedTermDepositTermsData(TermDataReqVo request) {
        FixedTermDepositDAO fixedTermDepositDAO = new FixedTermDepositDAO();
        System.out.println("La peticion fixed Term Deposit Terms Data:" + request);
        JsonObject json = new JsonObject();

        if (!fixedTermDepositDAO.actividad_horario()) {
            json.put("ERROR", "VERIFIQUE SU HORARIO DE ACTIVIDAD FECHA,HORA O CONTACTE A SU PROVEEEDOR");
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(json).build();
        }

        try {

        } catch (Exception e) {
            System.out.println("::::::::Error al ejecutar condiciones de deposito a plazo::::::::::::");
        }

        return null;
    }

    @POST
    @Path("/GetFixedTermDepositPaymentMethods")
    @Produces({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    @Consumes({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    public Response methodPayment(FixedTermMethodPaymentDTO request) {

        System.out.println("La peticion Fixed Term Method Payment :" + request);
        FixedTermDepositDAO metodos = new FixedTermDepositDAO();
        JsonObject Json_De_Error = new JsonObject();
        FixedTermMethodPaymentResponseDTO response = new FixedTermMethodPaymentResponseDTO();

        if (!metodos.actividad_horario()) {
            Json_De_Error.put("ERROR", "VERIFIQUE SU HORARIO DE ACTIVIDAD FECHA,HORA O CONTACTE A SU PROVEEEDOR");
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(Json_De_Error).build();
        }

        try {

        } catch (Exception e) {

        }
        return null;

        /*
        
        try {
            info_cuenta = metodos.getDetallesInversion(accountId);
            if (info_cuenta != null) {
                return Response.status(Response.Status.OK).entity(info_cuenta).build();
            } else {
                Json_De_Error.put("Error", "ERROR PRODUCTO NO ENCONTRADO");
                return Response.status(Response.Status.BAD_REQUEST).entity(Json_De_Error).build();
            }
        } catch (Exception e) {
            return Response.status(Response.Status.BAD_REQUEST).entity(Json_De_Error).build();
        }*/
    }

    @POST
    @Path("/GetFixedTermDepositInterestData")
    @Produces({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    @Consumes({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    public Response interesesDepositoPlazo(String cadena) {

        System.out.println("La peticion Fixed Term Deposit Interest Data :" + cadena);

        return null;
    }

    @POST
    @Path("/InsertFixedTermDeposit")
    @Produces({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    @Consumes({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    public Response terminarDepositoPlazo(String cadena) {

        System.out.println("La peticion Insert Fixed Term Deposit :" + cadena);

        return null;
    }

    @POST
    @Path("/GetRenewalTypesFixedTermDeposit")
    @Produces({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    @Consumes({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    public Response condicionesRenovacionDepositoPlazo(String cadena) {

        System.out.println("La peticion renewal Types Fixed Term Deposit :" + cadena);

        return null;
    }

}
