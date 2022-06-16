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
public class userDocumentIdDTO {
    
        
    private String integrationProperties;
    private Integer documentNumber;
    private Integer documentType;

    public userDocumentIdDTO() {
    }

    public userDocumentIdDTO(String integrationProperties, Integer documentNumber, Integer documentType) {
        this.integrationProperties = integrationProperties;
        this.documentNumber = documentNumber;
        this.documentType = documentType;
    }

    public String getIntegrationProperties() {
        return integrationProperties;
    }

    public void setIntegrationProperties(String integrationProperties) {
        this.integrationProperties = integrationProperties;
    }

    public Integer getDocumentNumber() {
        return documentNumber;
    }

    public void setDocumentNumber(Integer documentNumber) {
        this.documentNumber = documentNumber;
    }

    public Integer getDocumentType() {
        return documentType;
    }

    public void setDocumentType(Integer documentType) {
        this.documentType = documentType;
    }

        
}
