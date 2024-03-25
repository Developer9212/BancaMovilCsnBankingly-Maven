/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.entidades;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import javax.persistence.Cacheable;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 *
 * @author Elliot
 */
@Entity
@Table(name = "transferencias_bankingly")
@Cacheable(false)
public class Transferencias implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    private BigDecimal transactionid;
    private Integer subtransactiontypeid;
    private String currencyid;
    private String valuedate;
    private Integer transactiontypeid;
    private Integer transactionstatusid;
    private String clientbankidentifier;
    private String debitproductbankidentifier;
    private Integer debitproducttypeid;
    private String debitcurrencyid;
    private String creditproductbankidentifier;
    private Integer creditproducttypeid;
    private String creditcurrencyid;
    private Double amount;
    private String notifyto;
    private Integer notificationchannelid;    
    private String destinationname;
    private String destinationbank;
    private String description;
    private String bankroutingnumber;
    private String sourcename;
    private String sourcebank;
    private boolean regulationamountexceeded;
    private String sourcefunds;
    private String destinationfunds;
    private Double transactioncost;
    private String transactioncostcurrencyid;
    private Double exchangerate;
    private Date fechaejecucion;
    private String destinationdocumentid_documentnumber;
    private String destinationdocumentid_documenttype;
    private String sourcedocumentid_documentnumber;
    private String sourcedocumentid_documenttype;
    private String userdocumentid_documentnumber;
    private String userdocumentid_documenttype;
    private String ip;
    private String location;
    private String poliza;
    private Integer idorden;
    
    public Transferencias() {
    }

    public Integer getSubtransactiontypeid() {
        return subtransactiontypeid;
    }

    public void setSubtransactiontypeid(Integer subtransactiontypeid) {
        this.subtransactiontypeid = subtransactiontypeid;
    }

    public String getCurrencyid() {
        return currencyid;
    }

    public Integer getIdorden() {
        return idorden;
    }

    public void setIdorden(Integer idorden) {
        this.idorden = idorden;
    }

    
    public void setCurrencyid(String currencyid) {
        this.currencyid = currencyid;
    }

    public String getValuedate() {
        return valuedate;
    }

    public void setValuedate(String valuedate) {
        this.valuedate = valuedate;
    }

    public Integer getTransactiontypeid() {
        return transactiontypeid;
    }

    public void setTransactiontypeid(Integer transactiontypeid) {
        this.transactiontypeid = transactiontypeid;
    }

    public Integer getTransactionstatusid() {
        return transactionstatusid;
    }

    public void setTransactionstatusid(Integer transactionstatusid) {
        this.transactionstatusid = transactionstatusid;
    }

    public String getPoliza() {
        return poliza;
    }

    public void setPoliza(String poliza) {
        this.poliza = poliza;
    }

    public String getClientbankidentifier() {
        return clientbankidentifier;
    }

    public void setClientbankidentifier(String clientbankidentifier) {
        this.clientbankidentifier = clientbankidentifier;
    }

    public String getDebitproductbankidentifier() {
        return debitproductbankidentifier;
    }

    public void setDebitproductbankidentifier(String debitproductbankidentifier) {
        this.debitproductbankidentifier = debitproductbankidentifier;
    }

    public Integer getDebitproducttypeid() {
        return debitproducttypeid;
    }

    public void setDebitproducttypeid(Integer debitproducttypeid) {
        this.debitproducttypeid = debitproducttypeid;
    }

    public String getDebitcurrencyid() {
        return debitcurrencyid;
    }

    public void setDebitcurrencyid(String debitcurrencyid) {
        this.debitcurrencyid = debitcurrencyid;
    }

    public String getCreditproductbankidentifier() {
        return creditproductbankidentifier;
    }

    public void setCreditproductbankidentifier(String creditproductbankidentifier) {
        this.creditproductbankidentifier = creditproductbankidentifier;
    }

    public Integer getCreditproducttypeid() {
        return creditproducttypeid;
    }

    public void setCreditproducttypeid(Integer creditproducttypeid) {
        this.creditproducttypeid = creditproducttypeid;
    }

    public String getCreditcurrencyid() {
        return creditcurrencyid;
    }

    public void setCreditcurrencyid(String creditcurrencyid) {
        this.creditcurrencyid = creditcurrencyid;
    }

    public Double getAmount() {
        return amount;
    }

    public void setAmount(Double amount) {
        this.amount = amount;
    }

    public String getNotifyto() {
        return notifyto;
    }

    public void setNotifyto(String notifyto) {
        this.notifyto = notifyto;
    }

    public Integer getNotificationchannelid() {
        return notificationchannelid;
    }

    public void setNotificationchannelid(Integer notificationchannelid) {
        this.notificationchannelid = notificationchannelid;
    }

    public BigDecimal getTransactionid() {
        return transactionid;
    }

    public void setTransactionid(BigDecimal transactionid) {
        this.transactionid = transactionid;
    }

    public String getDestinationname() {
        return destinationname;
    }

    public void setDestinationname(String destinationname) {
        this.destinationname = destinationname;
    }

    public String getDestinationbank() {
        return destinationbank;
    }

    public void setDestinationbank(String destinationbank) {
        this.destinationbank = destinationbank;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getBankroutingnumber() {
        return bankroutingnumber;
    }

    public void setBankroutingnumber(String bankroutingnumber) {
        this.bankroutingnumber = bankroutingnumber;
    }

    public String getSourcename() {
        return sourcename;
    }

    public void setSourcename(String sourcename) {
        this.sourcename = sourcename;
    }

    public String getSourcebank() {
        return sourcebank;
    }

    public void setSourcebank(String sourcebank) {
        this.sourcebank = sourcebank;
    }

    public boolean isRegulationamountexceeded() {
        return regulationamountexceeded;
    }

    public void setRegulationamountexceeded(boolean regulationamountexceeded) {
        this.regulationamountexceeded = regulationamountexceeded;
    }

    public String getSourcefunds() {
        return sourcefunds;
    }

    public void setSourcefunds(String sourcefunds) {
        this.sourcefunds = sourcefunds;
    }

    public String getDestinationfunds() {
        return destinationfunds;
    }

    public void setDestinationfunds(String destinationfunds) {
        this.destinationfunds = destinationfunds;
    }

    public Double getTransactioncost() {
        return transactioncost;
    }

    public void setTransactioncost(Double transactioncost) {
        this.transactioncost = transactioncost;
    }

    public String getTransactioncostcurrencyid() {
        return transactioncostcurrencyid;
    }

    public void setTransactioncostcurrencyid(String transactioncostcurrencyid) {
        this.transactioncostcurrencyid = transactioncostcurrencyid;
    }

    public Double getExchangerate() {
        return exchangerate;
    }

    public void setExchangerate(Double exchangerate) {
        this.exchangerate = exchangerate;
    }

    public Date getFechaejecucion() {
        return fechaejecucion;
    }

    public void setFechaejecucion(Date fechaejecucion) {
        this.fechaejecucion = fechaejecucion;
    }

    public String getDestinationdocumentid_documentnumber() {
        return destinationdocumentid_documentnumber;
    }

    public void setDestinationdocumentid_documentnumber(String destinationdocumentid_documentnumber) {
        this.destinationdocumentid_documentnumber = destinationdocumentid_documentnumber;
    }

    public String getDestinationdocumentid_documenttype() {
        return destinationdocumentid_documenttype;
    }

    public void setDestinationdocumentid_documenttype(String destinationdocumentid_documenttype) {
        this.destinationdocumentid_documenttype = destinationdocumentid_documenttype;
    }

    public String getSourcedocumentid_documentnumber() {
        return sourcedocumentid_documentnumber;
    }

    public void setSourcedocumentid_documentnumber(String sourcedocumentid_documentnumber) {
        this.sourcedocumentid_documentnumber = sourcedocumentid_documentnumber;
    }

    public String getSourcedocumentid_documenttype() {
        return sourcedocumentid_documenttype;
    }

    public void setSourcedocumentid_documenttype(String sourcedocumentid_documenttype) {
        this.sourcedocumentid_documenttype = sourcedocumentid_documenttype;
    }

    public String getUserdocumentid_documentnumber() {
        return userdocumentid_documentnumber;
    }

    public void setUserdocumentid_documentnumber(String userdocumentid_documentnumber) {
        this.userdocumentid_documentnumber = userdocumentid_documentnumber;
    }

    public String getUserdocumentid_documenttype() {
        return userdocumentid_documenttype;
    }

    public void setUserdocumentid_documenttype(String userdocumentid_documenttype) {
        this.userdocumentid_documenttype = userdocumentid_documenttype;
    }

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

}
