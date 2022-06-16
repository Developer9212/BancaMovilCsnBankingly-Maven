/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.ResponseDTO;


/**
 *
 * @author Elliot
 */
public class TransactionModel {

    private int subTransactionTypeId;
    private String currencyId;
    private String valueDate;
    private int transactionTypeId;
    private int transactionStatusId;
    private String clientBankIdentifier;
    private String debitProductBankIdentifier;
    private int debitProductTypeId;
    private String debitCurrencyId;
    private String creditProductBankIdentifier;
    private int creditProductTypeId;
    private String creditCurrencyId;
    private Double amount;
    private String notifyTo;
    private int notificationChannelId;
    private int transactionId;
    private DocumentIdTransaccionesDTO destinationDocumentId;
    private String destinationName;
    private String destinationBank;
    private String description;
    private String bankRoutingNumber;
    private String sourceName;
    private String sourceBank;
    private DocumentIdTransaccionesDTO sourceDocumentId;
    private boolean regulationAmountExceeded;
    private String sourceFunds;
    private String destinationFunds;
    private DocumentIdTransaccionesDTO userDocumentId;
    private Double transactionCost;
    private String transactionCostCurrencyId;
    private Double exchangeRate;
    private String countryIntermediaryInstitution;
    private String intermediaryInstitution;
    private String routeNumberIntermediaryInstitution;
    private String integrationParameters;
    private int canal;
    private String ip;
    private String location;
    

    public TransactionModel() {
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

    public int getSubTransactionTypeId() {
        return subTransactionTypeId;
    }

    public void setSubTransactionTypeId(int subTransactionTypeId) {
        this.subTransactionTypeId = subTransactionTypeId;
    }

    public String getCurrencyId() {
        return currencyId;
    }

    public void setCurrencyId(String currencyId) {
        this.currencyId = currencyId;
    }

    public String getValueDate() {
        return valueDate;
    }

    public void setValueDate(String valueDate) {
        this.valueDate = valueDate;
    }

    public int getTransactionTypeId() {
        return transactionTypeId;
    }

    public void setTransactionTypeId(int transactionTypeId) {
        this.transactionTypeId = transactionTypeId;
    }

    public int getTransactionStatusId() {
        return transactionStatusId;
    }

    public void setTransactionStatusId(int transactionStatusId) {
        this.transactionStatusId = transactionStatusId;
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

    public int getCanal() {
        return canal;
    }

    public void setCanal(int canal) {
        this.canal = canal;
    }

    public void setDebitProductBankIdentifier(String debitProductBankIdentifier) {
        this.debitProductBankIdentifier = debitProductBankIdentifier;
    }

    public int getDebitProductTypeId() {
        return debitProductTypeId;
    }

    public void setDebitProductTypeId(int debitProductTypeId) {
        this.debitProductTypeId = debitProductTypeId;
    }

    public String getDebitCurrencyId() {
        return debitCurrencyId;
    }

    public void setDebitCurrencyId(String debitCurrencyId) {
        this.debitCurrencyId = debitCurrencyId;
    }

    public String getCreditProductBankIdentifier() {
        return creditProductBankIdentifier;
    }

    public void setCreditProductBankIdentifier(String creditProductBankIdentifier) {
        this.creditProductBankIdentifier = creditProductBankIdentifier;
    }

    public int getCreditProductTypeId() {
        return creditProductTypeId;
    }

    public void setCreditProductTypeId(int creditProductTypeId) {
        this.creditProductTypeId = creditProductTypeId;
    }

    public String getCreditCurrencyId() {
        return creditCurrencyId;
    }

    public void setCreditCurrencyId(String creditCurrencyId) {
        this.creditCurrencyId = creditCurrencyId;
    }

    public Double getAmount() {
        return amount;
    }

    public void setAmount(Double amount) {
        this.amount = amount;
    }

    public String getNotifyTo() {
        return notifyTo;
    }

    public void setNotifyTo(String notifyTo) {
        this.notifyTo = notifyTo;
    }

    public int getNotificationChannelId() {
        return notificationChannelId;
    }

    public void setNotificationChannelId(int notificationChannelId) {
        this.notificationChannelId = notificationChannelId;
    }

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public DocumentIdTransaccionesDTO getDestinationDocumentId() {
        return destinationDocumentId;
    }

    public void setDestinationDocumentId(DocumentIdTransaccionesDTO destinationDocumentId) {
        this.destinationDocumentId = destinationDocumentId;
    }

    public String getDestinationName() {
        return destinationName;
    }

    public void setDestinationName(String destinationName) {
        this.destinationName = destinationName;
    }

    public String getDestinationBank() {
        return destinationBank;
    }

    public void setDestinationBank(String destinationBank) {
        this.destinationBank = destinationBank;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getBankRoutingNumber() {
        return bankRoutingNumber;
    }

    public void setBankRoutingNumber(String bankRoutingNumber) {
        this.bankRoutingNumber = bankRoutingNumber;
    }

    public String getSourceName() {
        return sourceName;
    }

    public void setSourceName(String sourceName) {
        this.sourceName = sourceName;
    }

    public String getSourceBank() {
        return sourceBank;
    }

    public void setSourceBank(String sourceBank) {
        this.sourceBank = sourceBank;
    }

    public DocumentIdTransaccionesDTO getSourceDocumentId() {
        return sourceDocumentId;
    }

    public void setSourceDocumentId(DocumentIdTransaccionesDTO sourceDocumentId) {
        this.sourceDocumentId = sourceDocumentId;
    }

    public boolean isRegulationAmountExceeded() {
        return regulationAmountExceeded;
    }

    public void setRegulationAmountExceeded(boolean regulationAmountExceeded) {
        this.regulationAmountExceeded = regulationAmountExceeded;
    }

    public String getSourceFunds() {
        return sourceFunds;
    }

    public void setSourceFunds(String sourceFunds) {
        this.sourceFunds = sourceFunds;
    }

    public String getDestinationFunds() {
        return destinationFunds;
    }

    public void setDestinationFunds(String destinationFunds) {
        this.destinationFunds = destinationFunds;
    }

    public DocumentIdTransaccionesDTO getUserDocumentId() {
        return userDocumentId;
    }

    public void setUserDocumentId(DocumentIdTransaccionesDTO userDocumentId) {
        this.userDocumentId = userDocumentId;
    }

    public Double getTransactionCost() {
        return transactionCost;
    }

    public void setTransactionCost(Double transactionCost) {
        this.transactionCost = transactionCost;
    }

    public String getTransactionCostCurrencyId() {
        return transactionCostCurrencyId;
    }

    public void setTransactionCostCurrencyId(String transactionCostCurrencyId) {
        this.transactionCostCurrencyId = transactionCostCurrencyId;
    }

    public Double getExchangeRate() {
        return exchangeRate;
    }

    public void setExchangeRate(Double exchangeRate) {
        this.exchangeRate = exchangeRate;
    }

    public String getCountryIntermediaryInstitution() {
        return countryIntermediaryInstitution;
    }

    public void setCountryIntermediaryInstitution(String countryIntermediaryInstitution) {
        this.countryIntermediaryInstitution = countryIntermediaryInstitution;
    }

    public String getIntermediaryInstitution() {
        return intermediaryInstitution;
    }

    public void setIntermediaryInstitution(String intermediaryInstitution) {
        this.intermediaryInstitution = intermediaryInstitution;
    }

    public String getRouteNumberIntermediaryInstitution() {
        return routeNumberIntermediaryInstitution;
    }

    public void setRouteNumberIntermediaryInstitution(String routeNumberIntermediaryInstitution) {
        this.routeNumberIntermediaryInstitution = routeNumberIntermediaryInstitution;
    }

    public String getIntegrationParameters() {
        return integrationParameters;
    }

    public void setIntegrationParameters(String integrationParameters) {
        this.integrationParameters = integrationParameters;
    }

    @Override
    public String toString() {
        return "TransactionToOwnAccountsDTO{" + "subTransactionTypeId=" + subTransactionTypeId + ", currencyId=" + currencyId + ", valueDate=" + valueDate + ", transactionTypeId=" + transactionTypeId + ", transactionStatusId=" + transactionStatusId + ", clientBankIdentifier=" + clientBankIdentifier + ", debitProductBankIdentifier=" + debitProductBankIdentifier + ", debitProductTypeId=" + debitProductTypeId + ", debitCurrencyId=" + debitCurrencyId + ", creditProductBankIdentifier=" + creditProductBankIdentifier + ", creditProductTypeId=" + creditProductTypeId + ", creditCurrencyId=" + creditCurrencyId + ", amount=" + amount + ", notifyTo=" + notifyTo + ", notificationChannelId=" + notificationChannelId + ", transactionId=" + transactionId + ", destinationDocumentId=" + destinationDocumentId + ", destinationName=" + destinationName + ", destinationBank=" + destinationBank + ", description=" + description + ", bankRoutingNumber=" + bankRoutingNumber + ", sourceName=" + sourceName + ", sourceBank=" + sourceBank + ", sourceDocumentId=" + sourceDocumentId + ", regulationAmountExceeded=" + regulationAmountExceeded + ", sourceFunds=" + sourceFunds + ", destinationFunds=" + destinationFunds + ", userDocumentId=" + userDocumentId + ", transactionCost=" + transactionCost + ", transactionCostCurrencyId=" + transactionCostCurrencyId + ", exchangeRate=" + exchangeRate + ", countryIntermediaryInstitution=" + countryIntermediaryInstitution + ", intermediaryInstitution=" + intermediaryInstitution + ", routeNumberIntermediaryInstitution=" + routeNumberIntermediaryInstitution + ", integrationParameters=" + integrationParameters + ", canal=" + canal + ", location=" + location + '}';
    }

 

}
