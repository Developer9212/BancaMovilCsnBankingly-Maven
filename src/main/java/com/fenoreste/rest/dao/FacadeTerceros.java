/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.dao;

import com.fenorest.rest.EnviarSMS.PreparaSMS;
import com.fenoreste.rest.DTO.OgsDTO;
import com.fenoreste.rest.Util.UtilidadesGenerales;
import com.fenoreste.rest.ResponseDTO.BackendOperationResultDTO;
import com.fenoreste.rest.ResponseDTO.Bank;
import com.fenoreste.rest.ResponseDTO.ThirdPartyProductDTO;
import com.fenoreste.rest.ResponseDTO.userDocumentIdDTO;
import com.fenoreste.rest.Util.AbstractFacade;
import com.fenoreste.rest.Util.Utilidades;
import com.fenoreste.rest.entidades.Auxiliar;
import com.fenoreste.rest.entidades.AuxiliarPK;
import com.fenoreste.rest.entidades.Colonias;
import com.fenoreste.rest.entidades.Estados;
import com.fenoreste.rest.entidades.Municipios;
import com.fenoreste.rest.entidades.Origenes;
import com.fenoreste.rest.entidades.Paises;
import com.fenoreste.rest.entidades.Persona;
import com.fenoreste.rest.entidades.PersonasPK;
import com.fenoreste.rest.entidades.Productos;
import com.fenoreste.rest.entidades.ProductosTercero;
import com.fenoreste.rest.entidades.ProductosTerceros;
import com.fenoreste.rest.entidades.Productos_bankingly;
import com.fenoreste.rest.entidades.Tabla;
import com.fenoreste.rest.entidades.TerceroActivacion;
import com.fenoreste.rest.entidades.TerceroActivacionPK;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.Query;

/**
 *
 * @author wilmer
 */
public abstract class FacadeTerceros<T> {

    UtilidadesGenerales util2 = new UtilidadesGenerales();
    Utilidades util = new Utilidades();

    public FacadeTerceros(Class<T> entityClass) {
    }

    public BackendOperationResultDTO validarProductoTerceros(ThirdPartyProductDTO dtoInput) {
        System.out.println("si." + dtoInput.getOwnerDocumentId().getDocumentNumber());
        EntityManager em = AbstractFacade.conexion();//EntityManager em = emf.createEntityManager();
        BackendOperationResultDTO dtoResult = new BackendOperationResultDTO();
        try {
            String backendMessage = "";
            ProductosTerceros productosTerceros = new ProductosTerceros();

            System.out.println("size:" + dtoInput.getClientBankIdentifiers().size());
            boolean b = false;
            ProductosTerceros prod = null;
            for (int i = 0; i < dtoInput.getClientBankIdentifiers().size(); i++) {
                String cvalidar = "SELECT * FROM productos_terceros_bankingly WHERE thirdpartyproductbankidentifier='" + dtoInput.getThirdPartyProductBankIdentifier() + "'";
                Query query = em.createNativeQuery(cvalidar, ProductosTerceros.class);
                try {
                    prod = (ProductosTerceros) query.getSingleResult();
                } catch (Exception e) {
                    System.out.println("Error al buscar producto tercero:" + e.getMessage());
                }
                if (prod != null) {
                    backendMessage = "Error,producto ya esta registrado...";
                    System.out.println("Error,producto ya esta registrado..." + backendMessage);
                } else {
                    productosTerceros.setThirdPartyProductBankIdentifier(dtoInput.getThirdPartyProductBankIdentifier());
                    productosTerceros.setClientBankIdentifiers(dtoInput.getClientBankIdentifiers().get(i));
                    productosTerceros.setThirdPartyProductNumber(dtoInput.getThirdPartyProductNumber());
                    productosTerceros.setAlias(dtoInput.getAlias());
                    productosTerceros.setCurrencyId(dtoInput.getCurrencyId());
                    productosTerceros.setTransactionSubType(dtoInput.getTransactionSubType());
                    productosTerceros.setThirdPartyProductType(dtoInput.getThirdPartyProductType());
                    productosTerceros.setProductType(dtoInput.getProductType());
                    productosTerceros.setOwnerName(dtoInput.getOwnerName());
                    productosTerceros.setOwnerCountryId(dtoInput.getOwnerCountryId());
                    productosTerceros.setOwnerEmail(dtoInput.getOwnerEmail());
                    productosTerceros.setOwnerCity(dtoInput.getOwnerCity());
                    productosTerceros.setOwnerAddress(dtoInput.getOwnerAddress());
                    productosTerceros.setOwnerDocumentId_integrationProperties(dtoInput.getOwnerDocumentId().getIntegrationProperties());
                    productosTerceros.setOwnerDocumentId_documentNumber(String.valueOf(dtoInput.getOwnerDocumentId().getDocumentNumber()));
                    productosTerceros.setOwnerDocumentId_documentType(String.valueOf(dtoInput.getOwnerDocumentId().getDocumentType()));
                    productosTerceros.setOwnerPhoneNumber(dtoInput.getOwnerPhoneNumber());
                    productosTerceros.setBank_bankId(dtoInput.getBank().getBankId());
                    productosTerceros.setBank_countryId(dtoInput.getBank().getCountryId());
                    productosTerceros.setBank_description(dtoInput.getBank().getDescription());
                    productosTerceros.setBank_headQuartersAddress(dtoInput.getBank().getHeadQuartersAddress());
                    productosTerceros.setBank_routingCode(dtoInput.getBank().getRoutingCode());
                    productosTerceros.setCorrespondentBank_bankId(dtoInput.getCorrespondentBank().getBankId());
                    productosTerceros.setCorrespondentBank_countryId(dtoInput.getCorrespondentBank().getCountryId());
                    productosTerceros.setCorrespondentBank_description(dtoInput.getCorrespondentBank().getDescription());
                    productosTerceros.setCorrespondentBank_headQuartersAddress(dtoInput.getCorrespondentBank().getHeadQuartersAddress());
                    productosTerceros.setCorrespondentBank_routingCode(dtoInput.getCorrespondentBank().getRoutingCode());
                    productosTerceros.setUserDocumentId_documentNumber(String.valueOf(dtoInput.getUserDocumentId().getDocumentNumber()));
                    productosTerceros.setUserDocumentId_documentType(String.valueOf(dtoInput.getUserDocumentId().getDocumentType()));
                    productosTerceros.setUserDocumentId_integrationProperties(dtoInput.getUserDocumentId().getIntegrationProperties());

                    try {
                        em.getTransaction().begin();
                        em.persist(productosTerceros);
                        em.getTransaction().commit();
                        /*if (!em.getTransaction().isActive()) {
                            em.clear();
                            em.getTransaction().begin();
                            em.persist(productosTerceros);

                        }
                        em.getTransaction().commit();*/
                    } catch (Exception e) {
                        /*if (em.getTransaction().isActive()) {
                            em.getTransaction().rollback();
                        }*/
                    }
                }
                /*if (i == dtoInput.getClientBankIdentifiers().size() - 1 && backendMessage.equals("")) {
                    b = true;
                    backendMessage = "Producto registrado con exito...";
                }*/
                if (dtoInput.getClientBankIdentifiers().size() >= 16) {
                    b = true;
                }

            }
            if (b == true) {
                dtoResult.setBackendCode("1");
                dtoResult.setBackendMessage(backendMessage);
                dtoResult.setBackendReference("null");
                dtoResult.setIntegrationProperties("null");
                dtoResult.setIsError(false);
                dtoResult.setTransactionIdenty(productosTerceros.getThirdPartyProductNumber());
            } else {
                dtoResult.setBackendCode("1");
                dtoResult.setBackendMessage(backendMessage);
                dtoResult.setBackendReference("null");
                dtoResult.setIntegrationProperties("null");
                dtoResult.setIsError(true);
                dtoResult.setTransactionIdenty(productosTerceros.getThirdPartyProductNumber());

            }

        } catch (Exception e) {
            e.printStackTrace();

            System.out.println("Error al validar tercero:" + e.getMessage());
        } finally {
            if (em.isOpen()) {
                em.close();
            }
        }
        return dtoResult;

    }

    public ThirdPartyProductDTO cosultaProductosTerceros(String productNumber, Integer productTypeId, userDocumentIdDTO documento, Integer thirdPartyProductType, String username, boolean isOtherBank) {
        EntityManager em = AbstractFacade.conexion();
        ThirdPartyProductDTO dto = new ThirdPartyProductDTO();
        try {

            Auxiliar a = null;
            if (!isOtherBank) {
                a = validarTercero(productNumber, productTypeId);
            }

            if (!isOtherBank) {
                if (a != null) {
                    if (a.getEstatus() == 2) {
                        userDocumentIdDTO userDocument = new userDocumentIdDTO();
                        Bank bancoProductoTercero = new Bank();
                        Bank corresponsalBank = new Bank();
                        Productos pr = em.find(Productos.class, a.getAuxiliaresPK().getIdproducto());
                        String ogs = String.format("%06d", a.getIdorigen()) + String.format("%02d", a.getIdgrupo()) + String.format("%06d", a.getIdsocio());
                        ArrayList<String> listaPt = new ArrayList<>();
                        listaPt.add(ogs);
                        dto.setClientBankIdentifiers(listaPt);
                        dto.setThirdPartyProductNumber(String.valueOf(thirdPartyProductType));
                        dto.setThirdPartyProductBankIdentifier(productNumber);
                        dto.setAlias(pr.getNombre());
                        dto.setCurrencyId("484");//Identificador de moneda 1 es local
                        dto.setTransactionSubType(2);
                        dto.setThirdPartyProductType(1);

                        Productos_bankingly prod = em.find(Productos_bankingly.class, a.getAuxiliaresPK().getIdproducto());
                        dto.setProductType(prod.getProductTypeId());//el tipo de producto

                        PersonasPK personaPK = new PersonasPK(a.getIdorigen(), a.getIdgrupo(), a.getIdsocio());
                        Persona p = em.find(Persona.class, personaPK);
                        dto.setOwnerName(p.getNombre() + " " + p.getAppaterno() + " " + p.getApmaterno());

                        //Otenemos el nombre del pais de la persona
                        Colonias c = em.find(Colonias.class, p.getIdcolonia());
                        dto.setOwnerCountryId("484");//Moneda nacional interncional cambia de codigo a 840
                        boolean bandera = true;
                        String email = "";
                        //Buscamos en la tabla infomracion de terceros para obtener el email
                        try {
                            //Para evitar cualquier error usamos el ciclo por si el tercero no esta en la lista es nuevo 
                            ProductosTercero tercero = em.find(ProductosTercero.class, productNumber);
                            email = tercero.getBeneficiaryemail();
                        } catch (Exception ex) {
                            bandera = false;
                            System.out.println("Error al buscar el tercero en el archivo bankingly:" + ex.getMessage());
                        }

                        if (!email.equals("")) {
                            dto.setOwnerEmail(email);//p.getEmail()); 
                        } else {
                            dto.setOwnerEmail(p.getEmail());
                        }
                        dto.setOwnerCity(c.getNombre());
                        dto.setOwnerAddress(c.getNombre() + "," + p.getNumeroext() + "," + p.getNumeroint());
                        //Creamos y llenamos documento para el titular del producto de tercero
                        userDocumentIdDTO ownerDocumentId = new userDocumentIdDTO();
                        ownerDocumentId.setDocumentNumber(p.getPersonasPK().getIdorigen() + p.getPersonasPK().getIdgrupo() + p.getPersonasPK().getIdsocio());//Se a solicitado a Bankingly
                        ownerDocumentId.setDocumentType(3);//Se a solicitado a Bankingly
                        dto.setOwnerDocumentId(ownerDocumentId);
                        dto.setOwnerPhoneNumber(p.getCelular());
                        //Llenamos user document Id
                        userDocument.setDocumentNumber(p.getPersonasPK().getIdorigen() + p.getPersonasPK().getIdgrupo() + p.getPersonasPK().getIdsocio());//
                        userDocument.setDocumentType(3);
                        dto.setUserDocumentId(userDocument);
                        //Llenamos el banco de tercero
                        bancoProductoTercero.setBankId(a.getAuxiliaresPK().getIdorigenp());
                        bancoProductoTercero.setCountryId("484");
                        Origenes o = em.find(Origenes.class, a.getAuxiliaresPK().getIdorigenp());
                        bancoProductoTercero.setDescription(o.getNombre());
                        bancoProductoTercero.setRoutingCode(null);
                        bancoProductoTercero.setHeadQuartersAddress(o.getCalle() + "," + o.getNumeroint() + "," + o.getNumeroext());
                        dto.setBank(bancoProductoTercero);
                        dto.setCorrespondentBank(corresponsalBank);

                        //Vamos a guardar el producto tercero para saber la fecha en la que se dio de alta
                        insertarTerceroActivado(productNumber, bandera, username, "TERCERO LOCAL", false);
                    }
                }
            } else {
                userDocumentIdDTO userDocument = new userDocumentIdDTO();
                Bank bancoProductoTercero = new Bank();
                Bank corresponsalBank = new Bank();
                ArrayList<String> listaPt = new ArrayList<>();
                listaPt.add(productNumber);
                dto.setClientBankIdentifiers(listaPt);
                dto.setThirdPartyProductNumber(String.valueOf(thirdPartyProductType));
                dto.setThirdPartyProductBankIdentifier(productNumber);
                dto.setAlias("DEBITO");
                dto.setCurrencyId("484");//Identificador de moneda 1 es local
                dto.setTransactionSubType(2);
                dto.setThirdPartyProductType(1);
                dto.setProductType(0);//el tipo de producto

                dto.setOwnerName("SIN NOMBRE");

                //Otenemos el nombre del pais de la persona
                dto.setOwnerCountryId("484");//Moneda nacional interncional cambia de codigo a 840
                boolean bandera = true;
                dto.setOwnerEmail("otrobanco@gmail.com");//p.getEmail()); 

                dto.setOwnerCity("MONTERREY NUEVO LEON");
                dto.setOwnerAddress("");
                //Creamos y llenamos documento para el titular del producto de tercero
                userDocumentIdDTO ownerDocumentId = new userDocumentIdDTO();
                ownerDocumentId.setDocumentNumber(0);//Se a solicitado a Bankingly
                ownerDocumentId.setDocumentType(3);//Se a solicitado a Bankingly
                dto.setOwnerDocumentId(ownerDocumentId);
                dto.setOwnerPhoneNumber("");
                //Llenamos user document Id
                userDocument.setDocumentNumber(0);//
                userDocument.setDocumentType(3);
                dto.setUserDocumentId(userDocument);
                //Llenamos el banco de tercero
                bancoProductoTercero.setBankId(0);
                bancoProductoTercero.setCountryId("484");
                bancoProductoTercero.setDescription("TERCERO FUERA DE LA ENTIDAD");
                bancoProductoTercero.setRoutingCode(null);
                bancoProductoTercero.setHeadQuartersAddress("");
                dto.setBank(bancoProductoTercero);
                dto.setCorrespondentBank(corresponsalBank);

                //Vamos a guardar el producto tercero para saber la fecha en la que se dio de alta
                insertarTerceroActivado(productNumber, bandera, username, "OTROS BANCOS", true);
            }

        } catch (Exception e) {
            System.out.println("::::::::::::::::::::::::Error en metodo validar tercero:::::::::::::::::::::" + e.getMessage());

        } finally {
            if (em.isOpen()) {
                em.close();
            }
        }
        return dto;

    }

    public Auxiliar validarTercero(String opaTercero, int productType) {
        System.out.println("productTypeId:" + productType);
        EntityManager em = AbstractFacade.conexion();
        String message = "";
        try {
            int o = Integer.parseInt(opaTercero.substring(0, 6));
            int p = Integer.parseInt(opaTercero.substring(6, 11));
            int a = Integer.parseInt(opaTercero.substring(11, 19));
            System.out.println(o + "-" + p + "-" + a);
            AuxiliarPK auxiPK = new AuxiliarPK(o, p, a);
            Auxiliar auxiliar = em.find(Auxiliar.class, auxiPK);
            if (auxiliar != null) {
                if (auxiliar.getEstatus() != null) {
                    Productos_bankingly pr = em.find(Productos_bankingly.class, p);
                    if (pr.getProductTypeId() == productType) {
                        return auxiliar;
                    } else {
                        message = "Tipo de producto tercero no coincide";
                    }
                } else {
                    message = "Producto no activo";
                }
            } else {
                message = "Producto tercero no encontrado para local";
            }
        } catch (Exception e) {
            System.out.println("Error validando producto de tercero :" + e.getMessage());
        } finally {
            if (em.isOpen()) {
                em.close();
            }
        }
        return null;

    }

    public boolean insertarTerceroActivado(String opaTercero, boolean existe, String usuario, String comentario, boolean isOtherBank) {//Existe bandera que sirve para saber si el tercero ya esta en la lista 
        boolean bandera = false;
        System.out.println("Guardando la activacion del tercero ::" + opaTercero + "," + usuario + "," + comentario);
        EntityManager em = AbstractFacade.conexion();
        try {
            TerceroActivacion tercero = new TerceroActivacion();
            TerceroActivacionPK pk = new TerceroActivacionPK();
            em.getTransaction().begin();
            if (!isOtherBank) {
                int o = Integer.parseInt(opaTercero.substring(0, 6));
                int p = Integer.parseInt(opaTercero.substring(6, 11));
                int a = Integer.parseInt(opaTercero.substring(11, 19));
                pk = new TerceroActivacionPK(o, p, a, usuario);

                if (!existe) {//Segundo filtro para no repetir usuario para un mismo socio
                    try {
                        tercero = em.find(TerceroActivacion.class, pk);
                        if (tercero != null) {
                            em.remove(tercero);
                        }

                    } catch (Exception e) {
                        System.out.println("::::::::::::::::No existe tercero registrado para usuario:" + tercero);
                    }
                }
            } else {
                pk = new TerceroActivacionPK(0, 0, 0, usuario);
                try {
                    String consulta = "SELECT * FROM productos_terceros_activacion WHERE idcuentaotrobanco = '"+opaTercero+"'";
                    Query terceroQuery = em.createNativeQuery(consulta, TerceroActivacion.class);                   
                    tercero = (TerceroActivacion) terceroQuery.getSingleResult();
                    em.remove(tercero);

                } catch (NoResultException e) {
                    System.out.println("::::::::No existe tercero registrado para la cuenta: " + opaTercero);
                } catch (Exception e) {
                    System.out.println("::::::::Error al eliminar tercero: " + e.getMessage());
                }
            }

            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");

            Date fecha = sdf.parse(em.createNativeQuery("SELECT to_char((SELECT now()), 'DD/MM/YYYY HH24:MI:SS')").getSingleResult().toString());
            //Pk = new TerceroActivacionPK(0, 0, 0, usuario);
            tercero = new TerceroActivacion();
            tercero.setPk(pk);
            tercero.setFecharegistro(fecha);
            tercero.setComentario(comentario);
            tercero.setIdcuentaOtroBanco(opaTercero);

            em.persist(tercero);
            em.getTransaction().commit();

        } catch (Exception e) {
            System.out.println(":::::::::Error al registrar activacion de tercero::::::::" + e.getMessage());
        } finally {
            if (em.isOpen()) {
                em.close();
            }
        }
        return bandera;

    }

    public BackendOperationResultDTO tokenSend(String clientBankIdentifier, String numero, String token) {
        BackendOperationResultDTO dto = new BackendOperationResultDTO();
        dto.setIsError(true);
        dto.setBackendMessage("Error");
        dto.setBackendReference(null);
        dto.setBackendCode("2");
        dto.setIntegrationProperties("");
        dto.setTransactionIdenty(null);

        try {
            EntityManager em = AbstractFacade.conexion();
            //Busco a la persona para comparar que los numeros sea el mismo
            OgsDTO ogs = util.ogs(clientBankIdentifier);
            PersonasPK personaPK = new PersonasPK(ogs.getIdorigen(), ogs.getIdgrupo(), ogs.getIdsocio());
            Persona p = em.find(Persona.class, personaPK);
            if (p.getCelular().trim().equals(numero.trim())) {
                Tabla tb_activo_sms = util2.busquedaTabla(em, "bankingly_banca_movil", "smsactivo");
                if (tb_activo_sms.getDato1().trim().equals("1")) {
                    PreparaSMS sendSms = new PreparaSMS();
                    String respuesta_envio_token = sendSms.enviarTokenAltaTerceros(em, numero, token);
                    dto.setIsError(false);
                    dto.setBackendMessage("Token enviado");
                    dto.setBackendCode("1");
                }
            } else {
                dto.setBackendMessage("El numero no coincide con nuestros registros");
            }

        } catch (Exception e) {
            System.out.println("Error al enviar sms token : " + e.getMessage());
        }
        return dto;
    }

    public boolean actividad_horario() {
        EntityManager em = AbstractFacade.conexion();
        boolean bandera_ = false;
        try {
            if (util2.actividad(em)) {
                bandera_ = true;
            }
        } catch (Exception e) {
            System.out.println("Error al verificar el horario de actividad");

        } finally {
            if (em.isOpen()) {
                em.close();
            }
        }

        return bandera_;
    }

}
