/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.ResponseDTO;

import java.util.List;

/**
 *
 * @author wilmer
 */
public class FixedTermMethodPaymentResponseDTO {
    
    private List<CatalogFixedTermDepositDTO> paymentMethods;
    private BackendOperationResultDTO backendOperationResult;

    public FixedTermMethodPaymentResponseDTO() {
    }

    public List<CatalogFixedTermDepositDTO> getPaymentMethods() {
        return paymentMethods;
    }

    public void setPaymentMethods(List<CatalogFixedTermDepositDTO> paymentMethods) {
        this.paymentMethods = paymentMethods;
    }

    public BackendOperationResultDTO getBackendOperationResult() {
        return backendOperationResult;
    }

    public void setBackendOperationResult(BackendOperationResultDTO backendOperationResult) {
        this.backendOperationResult = backendOperationResult;
    }
    
    
    
    
    
}
