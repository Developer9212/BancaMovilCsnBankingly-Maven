package com.fenoreste.rest.RESTservices;

import com.fenoreste.rest.DTO.OgsDTO;
import com.fenoreste.rest.ResponseDTO.ProductsConsolidatePositionDTO;
import com.fenoreste.rest.ResponseDTO.ProductsDTO;
import com.fenoreste.rest.Util.Authorization;
import java.util.List;
import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import com.fenoreste.rest.dao.ProductsDAO;
import com.github.cliftonlabs.json_simple.JsonObject;
import java.util.ArrayList;
import javax.ws.rs.HeaderParam;
import org.json.JSONArray;
import org.json.JSONObject;
import com.fenoreste.rest.ResponseDTO.*;
import com.fenoreste.rest.Util.AbstractFacade;
import com.fenoreste.rest.Util.ThreadEliminarArchivos;
import com.fenoreste.rest.Util.Utilidades;
import com.fenoreste.rest.Util.UtilidadesGenerales;
import java.io.File;
import java.io.FileFilter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Base64;
import javax.persistence.EntityManager;
import javax.persistence.Query;

/**
 *
 * @author Elliot
 */
@Path("/Products")
public class ProductsResources {

    Authorization auth = new Authorization();
    UtilidadesGenerales util = new UtilidadesGenerales();
    Utilidades util2 = new Utilidades();

    @POST
    @Produces({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    @Consumes({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    public Response GetPRoducts(String cadena, @HeaderParam("authorization") String authString) {
        String ClientBankIdentifiers = "";
        Integer ProductTypes = null;
        JsonObject jsonError = new JsonObject();
        
        controlaHiloElimnarPDF();
        

        //-------------------------Obtiene el request json---------------------*/
        try {
            JSONObject Object = new JSONObject(cadena);
            JSONArray jsonCB = Object.getJSONArray("clientBankIdentifiers");
            JSONArray jsonPB = Object.getJSONArray("productTypes");

            for (int i = 0; i < jsonCB.length(); i++) {
                JSONObject jCB = (JSONObject) jsonCB.get(i);
                ClientBankIdentifiers = jCB.getString("value");
            }
            for (int x = 0; x < jsonPB.length(); x++) {
                JSONObject jPB = (JSONObject) jsonPB.get(x);
                ProductTypes = jPB.getInt("value");
            }
        } catch (Exception e) {
            jsonError.put("Error", "Request Failed");
            return Response.status(Response.Status.BAD_REQUEST).entity(jsonError).build();

        }
        /*-------------------------------------------------------*/

       /*================================================================================================
          Si las credenciales son correctas avanza        
         ================================================================================================*/
        ProductsDAO dao = new ProductsDAO();

        if (!dao.actividad_horario()) {
            jsonError.put("ERROR", "VERIFIQUE SU HORARIO DE ACTIVIDAD FECHA,HORA O CONTACTE A SU PROVEEEDOR");
            return Response.status(Response.Status.BAD_REQUEST).entity(jsonError).build();
        }

        OgsDTO ogs = util2.ogs(ClientBankIdentifiers);
        if (util.validacionSopar(ogs.getIdorigen(), ogs.getIdgrupo(), ogs.getIdsocio(), 1)) {
            jsonError.put("ERROR", "SOCIO BLOQUEADO");
            return Response.status(Response.Status.BAD_REQUEST).entity(jsonError).build();
        }

        try {
            List<ProductsDTO> listaDTO = dao.getProductos(ClientBankIdentifiers, ProductTypes);
            if (listaDTO != null) {
                JsonObject jsonD = new JsonObject();
                jsonD.put("Products", listaDTO);
                return Response.status(Response.Status.OK).entity(jsonD).build();
            } else {
                jsonError.put("Error", "DATOS NO ENCONTRADOS");
                return Response.status(Response.Status.NO_CONTENT).entity(jsonError).build();
            }
        } catch (Exception e) {
            System.out.println("Error interno en el servidor");

        }

        return null;

    }

    @POST
    @Path("/ConsolidatedPosition")
    @Produces({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    @Consumes({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    public Response getProductsConsolidatedPosition(String cadena) {

        /*SOLO FALTA DEL CATALOGO CAN TRANSACT ID*/
        System.out.println("Cadena:" + cadena);
        String ClientBankIdentifiers = "", ProductBankIdentifiers = "";
        JsonObject jsonError = new JsonObject();
        List<String> productsBank = new ArrayList<String>();
        try {

            JSONObject Object = new JSONObject(cadena);
            JSONArray jsonCB = Object.getJSONArray("clientBankIdentifiers");
            JSONArray jsonPB = Object.getJSONArray("productBankIdentifiers");

            for (int i = 0; i < jsonCB.length(); i++) {
                JSONObject jCB = (JSONObject) jsonCB.get(i);
                ClientBankIdentifiers = jCB.getString("value");

                System.out.println("ClientBankIdentifiers:" + ClientBankIdentifiers);
            }
            for (int x = 0; x < jsonPB.length(); x++) {
                JSONObject jPB = jsonPB.getJSONObject(x);
                ProductBankIdentifiers = jPB.getString("value");

                System.out.println("ProductBankIdentifiers:" + ProductBankIdentifiers);
                productsBank.add(ProductBankIdentifiers);
            }
        } catch (Exception e) {
            System.out.println("Error al convertir Json:" + e.getMessage());
        }

        OgsDTO ogs = util2.ogs(ClientBankIdentifiers);
        if (util.validacionSopar(ogs.getIdorigen(), ogs.getIdgrupo(), ogs.getIdsocio(), 1)) {
            jsonError.put("ERROR", "SOCIO BLOQUEADO");
            return Response.status(Response.Status.BAD_REQUEST).entity(jsonError).build();
        }

        ProductsDAO dao = new ProductsDAO();

        if (!dao.actividad_horario()) {
            jsonError.put("ERROR", "VERIFIQUE SU HORARIO DE ACTIVIDAD FECHA,HORA O CONTACTE A SU PROVEEEDOR");
            return Response.status(Response.Status.BAD_REQUEST).entity(jsonError).build();
        }
        try {
            List<ProductsConsolidatePositionDTO> ListPC = dao.ProductsConsolidatePosition(ClientBankIdentifiers, productsBank);
            if (ListPC != null) {
                JsonObject k = new JsonObject();
                k.put("ConsolidatedPosition", ListPC);
                return Response.status(Response.Status.OK).entity(k).build();

            } else {
                jsonError.put("Error", "DATOS NO ENCONTRADOS");
                return Response.status(Response.Status.NO_CONTENT).entity(jsonError).build();
            }
        } catch (Exception e) {
            System.out.println("Error aqui:" + e.getMessage());

        }

        return null;

    }

    @POST
    @Path("/BankStatements")
    @Produces({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    @Consumes({MediaType.APPLICATION_JSON + ";charset=utf-8"})
    public Response bankStatements(String cadena) {
        JSONObject request_ = new JSONObject(cadena);
        String clientBankIdentifier_ = "";
        String productBankIdentifier_ = "";
        int productType_ = 0;
        JsonObject json = new JsonObject();
        //MetodosUtilDAO mt=new MetodosUtilDAO();
        /*if(mt.actividad()==false){
            JsonObject actividad=new JsonObject();
            actividad.put("Error","Su zona horaria no coincide con la del servidor.");
            return Response.status(Response.Status.GATEWAY_TIMEOUT).entity(actividad).build();
        }*/

        ProductsDAO dao = new ProductsDAO();
        if (!dao.actividad_horario()) {
            json.put("ERROR", "VERIFIQUE SU HORARIO DE ACTIVIDAD FECHA,HORA O CONTACTE A SU PROVEEEDOR");
            return Response.status(Response.Status.BAD_REQUEST).entity(json).build();
        }
        try {
            clientBankIdentifier_ = request_.getString("clientBankIdentifier");
            productBankIdentifier_ = request_.getString("productBankIdentifier");

            OgsDTO ogs = util2.ogs(clientBankIdentifier_);
            if (util.validacionSopar(ogs.getIdorigen(), ogs.getIdgrupo(), ogs.getIdsocio(), 1)) {
                json.put("ERROR", "SOCIO BLOQUEADO");
                return Response.status(Response.Status.BAD_REQUEST).entity(json).build();
            }

            productType_ = request_.getInt("productType");
            List<ProductBankStatementDTO> listaECuentas = dao.statements(clientBankIdentifier_, productBankIdentifier_, productType_);

            json.put("bankStatements", listaECuentas);

            eliminarPorExtension(ruta(), "txt");
            eliminarPorExtension(ruta(), "html");

            return Response.status(Response.Status.OK).entity(json).build();
        } catch (Exception e) {
            return Response.status(Response.Status.BAD_REQUEST).entity(e.getMessage()).build();
        }
    }

    //Metodo para eliminar todos los pdf 
    public static void eliminarPorExtension(String path, final String extension) {
        File[] archivos = new File(path).listFiles(new FileFilter() {
            public boolean accept(File archivo) {
                if (archivo.isFile()) {
                    return archivo.getName().endsWith('.' + extension);
                }
                return false;
            }
        });
        for (File archivo : archivos) {
            archivo.delete();
        }
    }

    @POST
    @Path("/BankStatementsFile")
    @Produces({MediaType.APPLICATION_JSON})
    @Consumes({MediaType.APPLICATION_JSON})
    public Response fileDownload(String cadena) {  
        
        JSONObject RequestData = new JSONObject(cadena);
        String fileId = "";
        try {
            fileId = RequestData.getString("productBankStatementId");
        } catch (Exception e) {
            return Response.status(Response.Status.BAD_REQUEST).entity(e.getMessage()).build();
        }
        JsonObject jsonMessage = new JsonObject();
        ProductsDAO dao = new ProductsDAO();

        if (!dao.actividad_horario()) {
            jsonMessage.put("ERROR", "VERIFIQUE SU HORARIO DE ACTIVIDAD FECHA,HORA O CONTACTE A SU PROVEEEDOR");
            return Response.status(Response.Status.BAD_REQUEST).entity(jsonMessage).build();
        }
        try {
            String filePath = ruta() + fileId + ".pdf";
            System.out.println("fiklePAth:" + filePath);
            File fileA = new File(filePath);
            if (fileA.exists()) {
                byte[] input_file = Files.readAllBytes(Paths.get(filePath));
                byte[] encodedBytesFile = Base64.getEncoder().encode(input_file);
                String bytesFileId = new String(encodedBytesFile);
                jsonMessage.put("productBankStatementFile", bytesFileId);
                jsonMessage.put("productBankStatementFileName", fileId + ".pdf");
            } else {
                jsonMessage.put("Error", "EL ARCHIVO QUE INTENTA DESCARGAR NO EXISTE");
            }

        } catch (Exception e) {
            jsonMessage.put("Error", e.getMessage());
            return Response.status(Response.Status.BAD_REQUEST).entity(jsonMessage).build();
        }

        return Response.status(Response.Status.OK).entity(jsonMessage).build();
    }

    //Parao obtener la ruta del servidor
    public static String ruta() {
        String home = System.getProperty("user.home");
        String separador = System.getProperty("file.separator");
        String actualRuta = home + separador + "Banca" + separador;
        return actualRuta;
    }

    public void controlaHiloElimnarPDF(){        
        EntityManager em = AbstractFacade.conexion();
        try {        
            String s = "";
            String fecha = "";
            String query = "SELECT * FROM enabled LIMIT 1";
            Query quer = em.createNativeQuery(query);  
            List<Object[]>lista = quer.getResultList();
            //s = String.valueOf(quer.getSingleResult());
            
            for(Object[] obj:lista){
                s = obj[0].toString();
                fecha = obj[1].toString();            
            }
            
            if(s.equals("apagado")){
                ThreadEliminarArchivos eliminar = new ThreadEliminarArchivos();
                em.getTransaction().begin();
                em.createNativeQuery("DELETE FROM enabled").executeUpdate();
                em.createNativeQuery("INSERT INTO enabled values('encendido',(SELECT date(fechatrabajo) FROM origenes limit 1))").executeUpdate();
                em.getTransaction().commit();                
                eliminar.start();
            }else{
                ThreadEliminarArchivos eli = new ThreadEliminarArchivos();
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                String fechaTrabajo = sdf.format(util.busquedaMatriz().getFechatrabajo());
                System.out.println("Fechatrabajo :"+fechaTrabajo+",FechaTb:"+fecha);
                if(!fechaTrabajo.equals(fecha)){
                    eli.removerTabla();
                }
                
            }
        } catch (Exception e) {
            if(e.getMessage().toUpperCase().contains("NO EXISTE LA RELA")){
                em.getTransaction().begin();
                em.createNativeQuery("CREATE table enabled (estatus_hilo varchar(45),fecha date)").executeUpdate();
                em.createNativeQuery("INSERT INTO enabled values('apagado',(SELECT date(fechatrabajo) FROM origenes limit 1))").executeUpdate();
                em.getTransaction().commit();
            }
        }
    }
}
