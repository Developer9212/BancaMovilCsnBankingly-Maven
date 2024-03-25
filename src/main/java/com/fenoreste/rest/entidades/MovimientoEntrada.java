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
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 *
 * @author wilmer
 */
@Entity
@Table(name = "movimientos_entrada_bankingly")
@Cacheable(false)
public class MovimientoEntrada implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    private Integer transactionid;
    private Integer subtransactiontypeid;
    @Temporal(TemporalType.TIMESTAMP)
    private Date valuedate;
    private Integer transactiontypeid;
    private Integer transactionstatusid;
    private String clientbankidentifier;
    private String debitproductbankidentifier;
    private Integer debitproducttypeid;
    private String creditproductbankidentifier;
    private Integer creditproducttypeid;
    private BigDecimal amount;
    private String destinationname;
    private String destinationbank;
    private String description;

    public MovimientoEntrada() {
    }

    public MovimientoEntrada(Integer transactionid, Integer subtransactiontypeid, Date valuedate, Integer transactiontypeid, Integer transactionstatusid, String clientbankidentifier, String debitproductbankidentifier, Integer debitproducttypeid, String creditproductbankidentifier, Integer creditproducttypeid, BigDecimal amount, String destinationname, String destinationbank, String description) {
        this.transactionid = transactionid;
        this.subtransactiontypeid = subtransactiontypeid;
        this.valuedate = valuedate;
        this.transactiontypeid = transactiontypeid;
        this.transactionstatusid = transactionstatusid;
        this.clientbankidentifier = clientbankidentifier;
        this.debitproductbankidentifier = debitproductbankidentifier;
        this.debitproducttypeid = debitproducttypeid;
        this.creditproductbankidentifier = creditproductbankidentifier;
        this.creditproducttypeid = creditproducttypeid;
        this.amount = amount;
        this.destinationname = destinationname;
        this.destinationbank = destinationbank;
        this.description = description;
    }

    public Integer getTransactionid() {
        return transactionid;
    }

    public void setTransactionid(Integer transactionid) {
        this.transactionid = transactionid;
    }

    public Integer getSubtransactiontypeid() {
        return subtransactiontypeid;
    }

    public void setSubtransactiontypeid(Integer subtransactiontypeid) {
        this.subtransactiontypeid = subtransactiontypeid;
    }

    public Date getValuedate() {
        return valuedate;
    }

    public void setValuedate(Date valuedate) {
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

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
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

    @Override
    public String toString() {
        return "MovimientoEntrada{" + "transactionid=" + transactionid + ", subtransactiontypeid=" + subtransactiontypeid + ", valuedate=" + valuedate + ", transactiontypeid=" + transactiontypeid + ", transactionstatusid=" + transactionstatusid + ", clientbankidentifier=" + clientbankidentifier + ", debitproductbankidentifier=" + debitproductbankidentifier + ", debitproducttypeid=" + debitproducttypeid + ", creditproductbankidentifier=" + creditproductbankidentifier + ", creditproducttypeid=" + creditproducttypeid + ", amount=" + amount + ", destinationname=" + destinationname + ", destinationbank=" + destinationbank + ", description=" + description + '}';
    }

}
