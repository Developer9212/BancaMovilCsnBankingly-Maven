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
public class CatalogFixedTermDepositDTO {

    private String Code;
    private Integer LanguajeId;
    private String Description;

    public CatalogFixedTermDepositDTO() {
    }

    public CatalogFixedTermDepositDTO(String Code, Integer LanguajeId, String Description) {
        this.Code = Code;
        this.LanguajeId = LanguajeId;
        this.Description = Description;
    }

    public String getCode() {
        return Code;
    }

    public void setCode(String Code) {
        this.Code = Code;
    }

    public Integer getLanguajeId() {
        return LanguajeId;
    }

    public void setLanguajeId(Integer LanguajeId) {
        this.LanguajeId = LanguajeId;
    }

    public String getDescription() {
        return Description;
    }

    public void setDescription(String Description) {
        this.Description = Description;
    }

    @Override
    public String toString() {
        return "CatalogFixedTermDepositDTO{" + "Code=" + Code + ", LanguajeId=" + LanguajeId + ", Description=" + Description + '}';
    }

}
