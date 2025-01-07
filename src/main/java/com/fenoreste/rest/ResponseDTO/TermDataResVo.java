/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.ResponseDTO;

/**
 *
 * @author Will
 */
public class TermDataResVo implements java.io.Serializable {

    private static final long serialVersionUID = 1L;

    private Integer fixedTermDepositType;
    private boolean enableTermsFromBackend;
    private Double depositAmount;
    private Double minDepositAmount;
    private Integer termLimit;
    private String dueDate;

    public TermDataResVo() {
    }

    public TermDataResVo(Integer fixedTermDepositType, boolean enableTermsFromBackend, Double depositAmount, Double minDepositAmount, Integer termLimit, String dueDate) {
        this.fixedTermDepositType = fixedTermDepositType;
        this.enableTermsFromBackend = enableTermsFromBackend;
        this.depositAmount = depositAmount;
        this.minDepositAmount = minDepositAmount;
        this.termLimit = termLimit;
        this.dueDate = dueDate;
    }

    public Integer getFixedTermDepositType() {
        return fixedTermDepositType;
    }

    public void setFixedTermDepositType(Integer fixedTermDepositType) {
        this.fixedTermDepositType = fixedTermDepositType;
    }

    public boolean isEnableTermsFromBackend() {
        return enableTermsFromBackend;
    }

    public void setEnableTermsFromBackend(boolean enableTermsFromBackend) {
        this.enableTermsFromBackend = enableTermsFromBackend;
    }

    public Double getDepositAmount() {
        return depositAmount;
    }

    public void setDepositAmount(Double depositAmount) {
        this.depositAmount = depositAmount;
    }

    public Double getMinDepositAmount() {
        return minDepositAmount;
    }

    public void setMinDepositAmount(Double minDepositAmount) {
        this.minDepositAmount = minDepositAmount;
    }

    public Integer getTermLimit() {
        return termLimit;
    }

    public void setTermLimit(Integer termLimit) {
        this.termLimit = termLimit;
    }

    public String getDueDate() {
        return dueDate;
    }

    public void setDueDate(String dueDate) {
        this.dueDate = dueDate;
    }

}
