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
public class FixedTermDepositBeneficiaryDTO {

    private DocumentId DocumentId;
    private String Name;
    private Integer Porcentage;

    public FixedTermDepositBeneficiaryDTO() {
    }

    public FixedTermDepositBeneficiaryDTO(DocumentId DocumentId, String Name, Integer Porcentage) {
        this.DocumentId = DocumentId;
        this.Name = Name;
        this.Porcentage = Porcentage;
    }

    public DocumentId getDocumentId() {
        return DocumentId;
    }

    public void setDocumentId(DocumentId DocumentId) {
        this.DocumentId = DocumentId;
    }

    public String getName() {
        return Name;
    }

    public void setName(String Name) {
        this.Name = Name;
    }

    public Integer getPorcentage() {
        return Porcentage;
    }

    public void setPorcentage(Integer Porcentage) {
        this.Porcentage = Porcentage;
    }

    @Override
    public String toString() {
        return "FixedTermDepositBeneficiaryDTO{" + "DocumentId=" + DocumentId + ", Name=" + Name + ", Porcentage=" + Porcentage + '}';
    }

}
