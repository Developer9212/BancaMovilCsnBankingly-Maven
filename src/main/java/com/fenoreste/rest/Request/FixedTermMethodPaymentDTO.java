/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.Request;

import java.util.Date;

/**
 *
 * @author wilmer
 */
public class FixedTermMethodPaymentDTO {

    private String clientBankIdentifier;
    private String debitProductBankIdentifier;
    private Integer fixedTermDepositType;
    private Double depositAmount;
    private Integer termLimit;
    private Date dueDate;

    public FixedTermMethodPaymentDTO() {
    }

    public String getClientBankIdentifier() {
        return clientBankIdentifier;
    }

    public void setClientBankIdentifier(String clientBankIdentifier) {
        this.clientBankIdentifier = clientBankIdentifier;
    }

    public String getDebitProductBankIdentifier() {
        return debitProductBankIdentifier;
    }

    public void setDebitProductBankIdentifier(String debitProductBankIdentifier) {
        this.debitProductBankIdentifier = debitProductBankIdentifier;
    }

    public Integer getFixedTermDepositType() {
        return fixedTermDepositType;
    }

    public void setFixedTermDepositType(Integer fixedTermDepositType) {
        this.fixedTermDepositType = fixedTermDepositType;
    }

    public Double getDepositAmount() {
        return depositAmount;
    }

    public void setDepositAmount(Double depositAmount) {
        this.depositAmount = depositAmount;
    }

    public Integer getTermLimit() {
        return termLimit;
    }

    public void setTermLimit(Integer termLimit) {
        this.termLimit = termLimit;
    }

    public Date getDueDate() {
        return dueDate;
    }

    public void setDueDate(Date dueDate) {
        this.dueDate = dueDate;
    }

    @Override
    public String toString() {
        return "FixedTermMethodPaymentDTO{" + "clientBankIdentifier=" + clientBankIdentifier + ", debitProductBankIdentifier=" + debitProductBankIdentifier + ", fixedTermDepositType=" + fixedTermDepositType + ", depositAmount=" + depositAmount + ", termLimit=" + termLimit + ", dueDate=" + dueDate + '}';
    }

}
