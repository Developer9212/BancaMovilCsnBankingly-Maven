/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.Request;

/**
 *
 * @author Will
 */
public class TermDataReqVo implements java.io.Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private String productBankIdentifier;
    private String clientBankIdentifier;
    private String debitProductBankIdentifier;
    private String debitCurrencyId;

    public TermDataReqVo() {
    }

    public String getProductBankIdentifier() {
        return productBankIdentifier;
    }

    public void setProductBankIdentifier(String productBankIdentifier) {
        this.productBankIdentifier = productBankIdentifier;
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

    public String getDebitCurrencyId() {
        return debitCurrencyId;
    }

    public void setDebitCurrencyId(String debitCurrencyId) {
        this.debitCurrencyId = debitCurrencyId;
    }

    @Override
    public String toString() {
        return "TermDataReqVo{" + "productBankIdentifier=" + productBankIdentifier + ", clientBankIdentifier=" + clientBankIdentifier + ", debitProductBankIdentifier=" + debitProductBankIdentifier + ", debitCurrencyId=" + debitCurrencyId + '}';
    }
    
    
    
    
}
