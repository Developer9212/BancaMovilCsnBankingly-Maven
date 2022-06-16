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
public class sourceDocumentIdDTO {
    
        
    private String integrationProperties;
    private Integer documentNumber=0;
    private Integer documentType=0;

    public sourceDocumentIdDTO() {
    }

    public sourceDocumentIdDTO(String integrationProperties) {
        this.integrationProperties = integrationProperties;
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
