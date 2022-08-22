/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.ResponseDTO;

/**
 *
 * @author nahum
 */
public class DocumentId {

    private String documentType;
    private String documentNumber;

    public DocumentId() {
    }

    public DocumentId(String documentType, String documentNumber) {
        this.documentType = documentType;
        this.documentNumber = documentNumber;
    }

    public String getDocumentType() {
        return documentType;
    }

    public void setDocumentType(String documentType) {
        this.documentType = documentType;
    }

    public String getDocumentNumber() {
        return documentNumber;
    }

    public void setDocumentNumber(String documentNumber) {
        this.documentNumber = documentNumber;
    }

    @Override
    public String toString() {
        return "DocumentId{" + "documentType=" + documentType + ", documentNumber=" + documentNumber + '}';
    }

}
