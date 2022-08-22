/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.RESTservices;

import com.fenoreste.rest.ResponseDTO.DetallesInversionDTO;
import com.fenoreste.rest.dao.FixedTermDepositDAO;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import com.github.cliftonlabs.json_simple.JsonObject;

/**
 *
 * @author nahum
 */
@Path("/fixedTermDeposit")
public class FixedTermDepositResources {

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

}
