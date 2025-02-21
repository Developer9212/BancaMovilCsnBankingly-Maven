/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.RESTservices;

import com.fenoreste.rest.Request.RequestDataOrdenPagoDTO;
import com.fenoreste.rest.ResponseDTO.BackendOperationResultDTO;
import com.fenoreste.rest.ResponseDTO.DocumentIdTransaccionesDTO;
import com.fenoreste.rest.ResponseDTO.TransactionModel;
import com.fenoreste.rest.Util.Authorization;
import com.fenoreste.rest.dao.TransactionDAO;
import com.fenoreste.rest.ResponseDTO.VaucherDTO;
import com.fenoreste.rest.dao.EntradaMovsDAO;
import com.fenoreste.rest.entidades.MovimientoEntrada;
import com.fenoreste.rest.entidades.Tabla;
import com.fenoreste.rest.entidades.TablaPK;
import com.fenoreste.rest.entidades.TerceroActivacion;
import com.fenoreste.rest.entidades.Transferencia;
import com.github.cliftonlabs.json_simple.JsonObject;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.Normalizer;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.TimeUnit;
import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import org.json.JSONObject;

/**
 *
 * @author Elliot
 */
@Path("/Transaction")
public class TransactionResources {

    Authorization auth = new Authorization();

    //BasePath SPEI
    String basePath = "";
    TransactionDAO dao = new TransactionDAO();
    EntradaMovsDAO daoMovs = new EntradaMovsDAO();

    @Path("/Insert")
    @POST
    @Produces({MediaType.APPLICATION_JSON})
    @Consumes({MediaType.APPLICATION_JSON})
    public Response insertTransaction(String cadena) throws IOException {
        System.out.println("Cadena insert transaccion peticion:" + cadena);
        BackendOperationResultDTO backendOperationResult = new BackendOperationResultDTO();
        backendOperationResult.setBackendCode("2");
        backendOperationResult.setBackendMessage("Error en transaccion");
        backendOperationResult.setBackendReference(null);
        backendOperationResult.setIntegrationProperties("{}");
        backendOperationResult.setIsError(true);
        backendOperationResult.setTransactionIdenty("0");

        JsonObject response_json_principal = new JsonObject();
        /*================================================================
                Validamos las credenciales mediante la utenticacion basica
        =================================================================*/

        JSONObject jsonRecibido = new JSONObject(cadena.replace("null", "nulo"));
        /*================================================================
                Obtenemos el request y lo pasamos a DTO
        =================================================================*/
        TransactionModel dto = new TransactionModel();
        JsonObject response_json_secundario = new JsonObject();
        JsonObject response_json_3 = new JsonObject();

        try {

            JSONObject insertTransaction = jsonRecibido.getJSONObject("inserTransactionInput");
            JSONObject destinationDocumentId = insertTransaction.getJSONObject("destinationDocumentId");

            DocumentIdTransaccionesDTO dto1 = new DocumentIdTransaccionesDTO();
            dto1.setDocumentNumber(destinationDocumentId.getString("documentNumber"));
            dto1.setDocumentType(destinationDocumentId.getString("documentType"));

            DocumentIdTransaccionesDTO dto2 = new DocumentIdTransaccionesDTO();
            dto1.setDocumentNumber(destinationDocumentId.getString("documentNumber"));
            dto1.setDocumentType(destinationDocumentId.getString("documentType"));

            DocumentIdTransaccionesDTO dto3 = new DocumentIdTransaccionesDTO();
            dto1.setDocumentNumber(destinationDocumentId.getString("documentNumber"));
            dto1.setDocumentType(destinationDocumentId.getString("documentType"));

            dto.setSubTransactionTypeId(Integer.parseInt(insertTransaction.getString("subTransactionTypeId")));
            dto.setCurrencyId(insertTransaction.getString("currencyId"));
            dto.setValueDate(insertTransaction.getString("valueDate"));
            dto.setTransactionTypeId(insertTransaction.getInt("transactionTypeId"));
            dto.setTransactionStatusId(insertTransaction.getInt("transactionStatusId"));
            dto.setClientBankIdentifier(insertTransaction.getString("clientBankIdentifier"));
            dto.setDebitProductBankIdentifier(insertTransaction.getString("debitProductBankIdentifier"));
            dto.setDebitProductTypeId(insertTransaction.getInt("debitProductTypeId"));
            dto.setDebitCurrencyId(insertTransaction.getString("debitCurrencyId"));
            dto.setCreditProductBankIdentifier(insertTransaction.getString("creditProductBankIdentifier"));
            dto.setCreditProductTypeId(insertTransaction.getInt("creditProductTypeId"));
            dto.setCreditCurrencyId(insertTransaction.getString("creditCurrencyId"));
            dto.setAmount(insertTransaction.getDouble("amount"));
            dto.setNotifyTo(insertTransaction.getString("notifyTo"));
            dto.setNotificationChannelId(insertTransaction.getInt("notificationChannelId"));
            dto.setTransactionId(insertTransaction.getInt("transactionId"));
            dto.setDestinationDocumentId(dto1);
            dto.setDestinationName(insertTransaction.getString("destinationName"));
            dto.setDestinationBank(insertTransaction.getString("destinationBank"));
            dto.setDescription(insertTransaction.getString("description"));
            dto.setBankRoutingNumber(insertTransaction.getString("bankRoutingNumber"));
            dto.setSourceName(insertTransaction.getString("sourceName"));
            dto.setSourceBank(insertTransaction.getString("sourceBank"));
            dto.setSourceDocumentId(dto2);
            dto.setRegulationAmountExceeded(insertTransaction.getBoolean("regulationAmountExceeded"));
            dto.setSourceFunds(insertTransaction.getString("sourceFunds"));
            dto.setDestinationFunds(insertTransaction.getString("destinationFunds"));
            dto.setUserDocumentId(dto3);
            dto.setTransactionCost(insertTransaction.getDouble("transactionCost"));
            dto.setTransactionCostCurrencyId(insertTransaction.getString("transactionCostCurrencyId"));
            dto.setExchangeRate(insertTransaction.getDouble("exchangeRate"));
            dto.setCountryIntermediaryInstitution(insertTransaction.getString("countryIntermediaryInstitution"));
            dto.setRouteNumberIntermediaryInstitution("{}");
            dto.setIntegrationParameters("{}");
            dto.setCanal(jsonRecibido.getInt("ChannelId"));
            dto.setIp(jsonRecibido.getString("ip"));
            dto.setLocation(jsonRecibido.getString("location"));
            dto.setUsername(jsonRecibido.getString("userName"));

        } catch (Exception e) {
            backendOperationResult.setBackendCode("2");
            backendOperationResult.setBackendMessage(e.getMessage());
            response_json_3.put("integrationProperties", backendOperationResult.getIntegrationProperties());
            response_json_3.put("backendCode", backendOperationResult.getBackendCode());
            response_json_3.put("backendMessage", backendOperationResult.getBackendMessage());
            response_json_3.put("backendReference", null);
            response_json_3.put("isError", backendOperationResult.isIsError());
            response_json_3.put("transactionType", backendOperationResult.getTransactionIdenty());

            response_json_secundario.put("backendOperationResult", response_json_3);
            response_json_principal.put("InsertTransactionResult", response_json_secundario);
            return Response.status(Response.Status.BAD_REQUEST).entity(response_json_principal).build();
        }

        /*======================================================================
                Si el request que nos llego es el correcto procedemos
          ======================================================================*/
        try {
             if (!dao.actividad_horario()) {
                backendOperationResult.setBackendMessage("<html><body><b>VERIFIQUE SU HORARIO DE ACTIVIDAD FECHA,HORA O CONTACTE A SU PROVEEEDOR</b></body></html>");
            } else {
                System.out.println("Accediendo a trasnferencias con subTransactionType=" + dto.getSubTransactionTypeId() + ",TransactionId:" + dto.getTransactionTypeId());

                //Vamos a buscar la transaccion con el id
                MovimientoEntrada mov = new MovimientoEntrada();
                mov.setTransactionid(dto.getTransactionId());
                mov.setSubtransactiontypeid(dto.getSubTransactionTypeId());
                mov.setValuedate(fechaParser(dto.getValueDate()));
                mov.setTransactiontypeid(dto.getTransactionTypeId());
                mov.setTransactionstatusid(dto.getTransactionStatusId());
                mov.setClientbankidentifier(dto.getClientBankIdentifier());
                mov.setDebitproductbankidentifier(dto.getDebitProductBankIdentifier());
                mov.setDebitproducttypeid(dto.getDebitProductTypeId());
                mov.setCreditproductbankidentifier(dto.getCreditProductBankIdentifier());
                mov.setCreditproducttypeid(dto.getCreditProductTypeId());
                mov.setAmount(new BigDecimal(dto.getAmount()));
                mov.setDestinationname(dto.getDestinationName());
                mov.setDestinationbank(dto.getDestinationBank());
                mov.setDescription(dto.getDescription());

                //Vamos a buscar la transaccion con el id
                boolean bandera = false;
                
               
                    Transferencia transferencia = daoMovs.buscarUltimoMovimiento(dto.getClientBankIdentifier());
                    //daoMovs.guardar(mov);
                    if (transferencia.getTransactionid() != null) {
                        //convertimos la fecha 
                        Date hoy = new Date();//fechaParser(dto.getValueDate());
                        if (transferencia.getFechaejecucion().toGMTString().substring(0, 11).equals(hoy.toGMTString().substring(0, 11))) {
                            System.out.println("Transaccion en la misma fecha mov.:" + transferencia.getFechaejecucion().toGMTString().substring(0, 11) + ",hoy:" + hoy.toGMTString().substring(0, 11));
                            TimeUnit timeHora = TimeUnit.HOURS;
                            TimeUnit timeMinutos = TimeUnit.MINUTES;
                            TimeUnit timeSegundos = TimeUnit.SECONDS;
                            long diff = 0;
                            long differenceHour = 0;
                            long differenceMinutos = 0;
                            long differenceSegundos = 0;
                            System.out.println("Hora actual:" + hoy);
                            System.out.println("Hora ultimo mov:"+ transferencia.getFechaejecucion());
                            diff = hoy.getTime() - transferencia.getFechaejecucion().getTime();
                            differenceHour = timeHora.convert(diff, TimeUnit.MILLISECONDS);                            
                            differenceMinutos = timeMinutos.convert(diff, TimeUnit.MILLISECONDS);
                            differenceSegundos = timeSegundos.convert(diff, TimeUnit.MILLISECONDS);
                            System.out.println("total hora:" + differenceHour + ",Total Minuto:" + differenceMinutos + ",total segundos:" + differenceSegundos + " de la ultima transaccion...");
                            if (differenceHour > 0 || differenceMinutos > 0 || differenceSegundos > 4) {
                                System.out.println("Ya pasaron 2 o mas segundos de tu ultima transaccion.....");
                                bandera = true;
                            } else {
                                System.out.println("Error tu ultima transaccion fue hace 4 segundos");
                                backendOperationResult.setBackendMessage("<HTML>Tienes una transaccion con menos de 2 segundos.</HTML>");
                            }
                        } else {
                            bandera = true;
                        }
                    } else {
                        System.out.println("Primera transferencia.................");
                      
                        bandera = true;
                    }
                

                if (bandera) {
                    //Si subtransactionType es 1 y transactionType es 1: El tipo de transaccion es es entre mis cuentas
                    if (dto.getSubTransactionTypeId() == 1 && dto.getTransactionTypeId() == 1) {
                        backendOperationResult = dao.transferencias(dto, 1, null);
                    }

                    //Si subtransactionType es 2 y transactionType es 1: El tipo de transaccion es a terceros  dentro de la entidad
                    if (dto.getSubTransactionTypeId() == 2 && dto.getTransactionTypeId() == 1) {
                        //Descomentar cuando se le de su gana 
                        String mensaje = validarTerceroOperar(dto.getCreditProductBankIdentifier(), dto.getUsername());
                        //if (mensaje.toUpperCase().contains("EXITOSO")) {
                        backendOperationResult = dao.transferencias(dto, 2, null);
                        //} else {
                        // backendOperationResult.setBackendMessage(mensaje);
                        //}
                    }
                    //Si subtransactionType es 9 y transactionType es 6: El tipo de transaccion es es un pago a prestamos  propio
                    if (dto.getSubTransactionTypeId() == 9 && dto.getTransactionTypeId() == 6) {
                        backendOperationResult = dao.transferencias(dto, 3, null);
                    }
                    //Si es un pago a prestamo tercero 
                    if (dto.getSubTransactionTypeId() == 10 && dto.getTransactionTypeId() == 6) {
                        String mensaje = validarTerceroOperar(dto.getCreditProductBankIdentifier(), dto.getUsername());
                        //  if (mensaje.toUpperCase().contains("EXITOSO")) {
                        backendOperationResult = dao.transferencias(dto, 4, null);
                        //} else {
                        backendOperationResult.setBackendMessage(mensaje);
                        // }                    
                    }
                    //Si es una trasnferencia SPEI
                    if (dto.getSubTransactionTypeId() == 3 && dto.getTransactionTypeId() == 1) {

                        if (!dao.actividad_horario_spei()) {
                            backendOperationResult.setBackendMessage("<html><body><b>Horario para envío de SPEI fuera de horario de servicio</b></body></html>");
                        } else {
                            //Consumimos mis servicios de SPEI que tengo en otro proyecto(CSN0)
                            RequestDataOrdenPagoDTO ordenReque = new RequestDataOrdenPagoDTO();
                            ordenReque.setClienteClabe(dto.getDebitProductBankIdentifier());//Opa origen como cuenta clabe en el metodo spei se busca la clave
                            ordenReque.setConceptoPago(dto.getDescription());
                            ordenReque.setCuentaBeneficiario(dto.getCreditProductBankIdentifier());//La clabe del beneficiario
                            ordenReque.setInstitucionContraparte(dto.getDestinationBank());
                            ordenReque.setMonto(dto.getAmount());
                            ordenReque.setNombreBeneficiario(dto.getDestinationName());
                            ordenReque.setRfcCurpBeneficiario(dto.getDestinationDocumentId().getDocumentNumber());
                            ordenReque.setOrdernante(dto.getClientBankIdentifier());
                            String[] location = dto.getLocation().split(",");
                            ordenReque.setLongitud(location[1]);
                            ordenReque.setLatitud(location[0]);

                            backendOperationResult = dao.transferencias(dto, 5, ordenReque);
                        }

                    }
                }
            }  
            response_json_3.put("integrationProperties", null);
            response_json_3.put("backendCode", backendOperationResult.getBackendCode());
            response_json_3.put("backendMessage", backendOperationResult.getBackendMessage());
            response_json_3.put("backendReference", backendOperationResult.getBackendReference());
            response_json_3.put("isError", backendOperationResult.isIsError());
            response_json_3.put("transactionType", backendOperationResult.getTransactionIdenty());

            response_json_secundario.put("backendOperationResult", response_json_3);
            response_json_principal.put("InsertTransactionResult", response_json_secundario);
        } catch (Exception e) {
            backendOperationResult.setBackendMessage(e.getMessage());
            response_json_3.put("integrationProperties", null);
            response_json_3.put("backendCode", backendOperationResult.getBackendCode());
            response_json_3.put("backendMessage", backendOperationResult.getBackendMessage());
            response_json_3.put("backendReference", null);
            response_json_3.put("isError", backendOperationResult.isIsError());
            response_json_3.put("transactionType", backendOperationResult.getTransactionIdenty());

            response_json_secundario.put("backendOperationResult", response_json_3);
            response_json_principal.put("InsertTransactionResult", response_json_secundario);

            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(response_json_principal).build();
        }
        return Response.status(Response.Status.OK).entity(response_json_principal).build();
    }

    @POST
    @Path("/Voucher")
    @Produces({MediaType.APPLICATION_JSON})
    @Consumes({MediaType.APPLICATION_JSON})
    public VaucherDTO voucher(String cadena
    ) {
        JSONObject request = new JSONObject(cadena);
        String idTransaccion = "";
        VaucherDTO voucherDTO;
        try {
            idTransaccion = request.getString("transactionVoucherIdentifier");
        } catch (Exception e) {
            System.out.println("Error al obtener Json Request:" + e.getMessage());
            //return Response.status(Response.Status.BAD_REQUEST).entity(e.getMessage()).build();
        }
        TransactionDAO dao = new TransactionDAO();
        JsonObject jsonMessage = new JsonObject();

        voucherDTO = dao.vaucher(idTransaccion);

        return voucherDTO;
    }

    @POST
    @Path("/ejecutaSpei")
    @Produces({MediaType.APPLICATION_JSON})
    @Consumes({MediaType.APPLICATION_JSON})
    public Response ejecutarOrdenSPei(String cadena
    ) {
        JSONObject request_json = new JSONObject(cadena);
        int idorden = request_json.getInt("id");
        String folio = request_json.getString("folioOrigen");
        String estado = request_json.getString("estado");
        String causa = request_json.getString("causaDevolucion");
        TransactionDAO dao = new TransactionDAO();
        if (!dao.actividad_horario_spei()) {
            JsonObject obje = new JsonObject();
            obje.put("mensaje", "VERIFIQUE SU HORARIO DE ACTIVIDAD FECHA,HORA O CONTACTE A SU PROVEEEDOR");
            return Response.ok(obje).build();
        }

        String mensaje = dao.ejecutaOrdenSPEI(idorden, folio, estado, causa);
        JsonObject response = new JsonObject();
        response.put("mensaje", mensaje);
        return Response.ok(response).build();

    }

    public static Timestamp stringTodate(String fecha) {
        Timestamp time = null;

        Timestamp tm = Timestamp.valueOf(fecha);
        time = tm;
        System.out.println("date:" + time);
        return time;
    }

    public static String limpiarAcentos(String cadena) {
        String limpio = null;
        if (cadena != null) {
            String valor = cadena;
            valor = valor.toUpperCase();
            // Normalizar texto para eliminar acentos, dieresis, cedillas y tildes
            limpio = Normalizer.normalize(valor, Normalizer.Form.NFD);
            // Quitar caracteres no ASCII excepto la enie, interrogacion que abre, exclamacion que abre, grados, U con dieresis.
            limpio = limpio.replaceAll("[^\\p{ASCII}(ñ\u0303)(n\u0303)(\u00A1)(\u00BF)(\u00B0)(U\u0308)(u\u0308)]", "");
            // Regresar a la forma compuesta, para poder comparar la enie con la tabla de valores
            limpio = Normalizer.normalize(limpio, Normalizer.Form.NFC);
        }
        return limpio.toLowerCase();
    }

    private String validarTerceroOperar(String opa, String username) {
        String mensaje = "";
        try {
            TerceroActivacion tercero = null;
            TimeUnit timeDay = TimeUnit.DAYS;
            TimeUnit timeHora = TimeUnit.HOURS;
            TimeUnit timeMinutos = TimeUnit.MINUTES;

            long diff = 0;
            long differenceDay = 0;
            long differenceHour = 0;
            long differenceMinutos = 0;
            Tabla tabla = null;
            if (dao.validacionTerceroActivo(opa, username) != null) {
                tercero = dao.validacionTerceroActivo(opa, username);
                diff = dao.fechaServidorTimestamp().getTime() - tercero.getFecharegistro().getTime();
                differenceDay = timeDay.convert(diff, TimeUnit.MILLISECONDS);
                differenceHour = timeHora.convert(diff, TimeUnit.MILLISECONDS);
                differenceMinutos = timeMinutos.convert(diff, TimeUnit.MILLISECONDS);
                TablaPK pk = new TablaPK("bankingly_banca_movil", "timer_tercero_transaccion");
                tabla = dao.busquedaTabla(pk);

                System.out.println("El total de dias del registro tercero es: " + differenceDay + " el total de horas es: " + differenceHour + " el total de minutos es: " + differenceMinutos);
                if (differenceMinutos > Integer.parseInt(tabla.getDato1())) {
                    mensaje = "Exitoso";
                } else {
                    mensaje = "EL DESTINATARIO ESTARA ACTIVO EN: " + (Integer.parseInt(tabla.getDato1()) - differenceMinutos) + " Minutos";
                }

            } else {
                mensaje = "DESTINATARIO NO IDENTIFICADO EN EL CORE";
            }
        } catch (Exception e) {
            System.out.println("ERROR AL VALIDAR REGISTRO TERCERO:" + e.getMessage());
        }
        return mensaje;

    }

    private Date fechaParser(String fecha) {
        Date fechaR = null;
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
            fechaR = sdf.parse(fecha);
        } catch (Exception e) {
            System.out.println("Error al formaear fecha:" + e.getMessage());
        }
        return fechaR;
    }

}
