/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fenoreste.rest.ResponseDTO;

import java.util.Date;
import java.util.List;

/**
 *
 * @author nahum
 */
public class DetallesInversionDTO {

    private String CdpName;
    private String CdpNumber;
    private Double CurrentBalance;
    private String DueDate;
    private Double InterestEarned;
    private Double InterestPaid;
    private String InterestPayingAccount;
    private Double OriginalAmount;
    private String ProductBankIdentifier;
    private Double Rate;
    private Date RenewalDate;
    private String StartDate;
    private String Term;
    private String DebitProductBankIdentifier;
    private Integer FixedTermDepositType;
    private CatalogFixedTermDepositDTO PaymentMethod;
    private Double TotalInterestAmount;
    private CatalogFixedTermDepositDTO RenewalType;
    private String InterestCreditProductBankIdentifier;
    private String DepositCreditProductBankIdentifier;
    private List<FixedTermDepositBeneficiaryDTO> FixedTermDepositBeneficiaries;

    public DetallesInversionDTO() {
    }

    public DetallesInversionDTO(String CdpName, String CdpNumber, Double CurrentBalance, String DueDate, Double InterestEarned, Double InterestPaid, String InterestPayingAccount, Double OriginalAmount, String ProductBankIdentifier, Double Rate, Date RenewalDate, String StartDate, String Term, String DebitProductBankIdentifier, Integer FixedTermDepositType, CatalogFixedTermDepositDTO PaymentMethod, Double TotalInterestAmount, CatalogFixedTermDepositDTO RenewalType, String InterestCreditProductBankIdentifier, String DepositCreditProductBankIdentifier, List<FixedTermDepositBeneficiaryDTO> FixedTermDepositBeneficiaries) {
        this.CdpName = CdpName;
        this.CdpNumber = CdpNumber;
        this.CurrentBalance = CurrentBalance;
        this.DueDate = DueDate;
        this.InterestEarned = InterestEarned;
        this.InterestPaid = InterestPaid;
        this.InterestPayingAccount = InterestPayingAccount;
        this.OriginalAmount = OriginalAmount;
        this.ProductBankIdentifier = ProductBankIdentifier;
        this.Rate = Rate;
        this.RenewalDate = RenewalDate;
        this.StartDate = StartDate;
        this.Term = Term;
        this.DebitProductBankIdentifier = DebitProductBankIdentifier;
        this.FixedTermDepositType = FixedTermDepositType;
        this.PaymentMethod = PaymentMethod;
        this.TotalInterestAmount = TotalInterestAmount;
        this.RenewalType = RenewalType;
        this.InterestCreditProductBankIdentifier = InterestCreditProductBankIdentifier;
        this.DepositCreditProductBankIdentifier = DepositCreditProductBankIdentifier;
        this.FixedTermDepositBeneficiaries = FixedTermDepositBeneficiaries;
    }

    public String getCdpName() {
        return CdpName;
    }

    public void setCdpName(String CdpName) {
        this.CdpName = CdpName;
    }

    public String getCdpNumber() {
        return CdpNumber;
    }

    public void setCdpNumber(String CdpNumber) {
        this.CdpNumber = CdpNumber;
    }

    public Double getCurrentBalance() {
        return CurrentBalance;
    }

    public void setCurrentBalance(Double CurrentBalance) {
        this.CurrentBalance = CurrentBalance;
    }

    public String getDueDate() {
        return DueDate;
    }

    public void setDueDate(String DueDate) {
        this.DueDate = DueDate;
    }

    public Double getInterestEarned() {
        return InterestEarned;
    }

    public void setInterestEarned(Double InterestEarned) {
        this.InterestEarned = InterestEarned;
    }

    public Double getInterestPaid() {
        return InterestPaid;
    }

    public void setInterestPaid(Double InterestPaid) {
        this.InterestPaid = InterestPaid;
    }

    public String getInterestPayingAccount() {
        return InterestPayingAccount;
    }

    public void setInterestPayingAccount(String InterestPayingAccount) {
        this.InterestPayingAccount = InterestPayingAccount;
    }

    public Double getOriginalAmount() {
        return OriginalAmount;
    }

    public void setOriginalAmount(Double OriginalAmount) {
        this.OriginalAmount = OriginalAmount;
    }

    public String getProductBankIdentifier() {
        return ProductBankIdentifier;
    }

    public void setProductBankIdentifier(String ProductBankIdentifier) {
        this.ProductBankIdentifier = ProductBankIdentifier;
    }

    public Double getRate() {
        return Rate;
    }

    public void setRate(Double Rate) {
        this.Rate = Rate;
    }

    public Date getRenewalDate() {
        return RenewalDate;
    }

    public void setRenewalDate(Date RenewalDate) {
        this.RenewalDate = RenewalDate;
    }

    public String getStartDate() {
        return StartDate;
    }

    public void setStartDate(String StartDate) {
        this.StartDate = StartDate;
    }

    public String getTerm() {
        return Term;
    }

    public void setTerm(String Term) {
        this.Term = Term;
    }

    public String getDebitProductBankIdentifier() {
        return DebitProductBankIdentifier;
    }

    public void setDebitProductBankIdentifier(String DebitProductBankIdentifier) {
        this.DebitProductBankIdentifier = DebitProductBankIdentifier;
    }

    public Integer getFixedTermDepositType() {
        return FixedTermDepositType;
    }

    public void setFixedTermDepositType(Integer FixedTermDepositType) {
        this.FixedTermDepositType = FixedTermDepositType;
    }

    public CatalogFixedTermDepositDTO getPaymentMethod() {
        return PaymentMethod;
    }

    public void setPaymentMethod(CatalogFixedTermDepositDTO PaymentMethod) {
        this.PaymentMethod = PaymentMethod;
    }

    public Double getTotalInterestAmount() {
        return TotalInterestAmount;
    }

    public void setTotalInterestAmount(Double TotalInterestAmount) {
        this.TotalInterestAmount = TotalInterestAmount;
    }

    public CatalogFixedTermDepositDTO getRenewalType() {
        return RenewalType;
    }

    public void setRenewalType(CatalogFixedTermDepositDTO RenewalType) {
        this.RenewalType = RenewalType;
    }

    public String getInterestCreditProductBankIdentifier() {
        return InterestCreditProductBankIdentifier;
    }

    public void setInterestCreditProductBankIdentifier(String InterestCreditProductBankIdentifier) {
        this.InterestCreditProductBankIdentifier = InterestCreditProductBankIdentifier;
    }

    public String getDepositCreditProductBankIdentifier() {
        return DepositCreditProductBankIdentifier;
    }

    public void setDepositCreditProductBankIdentifier(String DepositCreditProductBankIdentifier) {
        this.DepositCreditProductBankIdentifier = DepositCreditProductBankIdentifier;
    }

    public List<FixedTermDepositBeneficiaryDTO> getFixedTermDepositBeneficiaries() {
        return FixedTermDepositBeneficiaries;
    }

    public void setFixedTermDepositBeneficiaries(List<FixedTermDepositBeneficiaryDTO> FixedTermDepositBeneficiaries) {
        this.FixedTermDepositBeneficiaries = FixedTermDepositBeneficiaries;
    }

    @Override
    public String toString() {
        return "DetallesInversionDTO{" + "CdpName=" + CdpName + ", CdpNumber=" + CdpNumber + ", CurrentBalance=" + CurrentBalance + ", DueDate=" + DueDate + ", InterestEarned=" + InterestEarned + ", InterestPaid=" + InterestPaid + ", InterestPayingAccount=" + InterestPayingAccount + ", OriginalAmount=" + OriginalAmount + ", ProductBankIdentifier=" + ProductBankIdentifier + ", Rate=" + Rate + ", RenewalDate=" + RenewalDate + ", StartDate=" + StartDate + ", Term=" + Term + ", DebitProductBankIdentifier=" + DebitProductBankIdentifier + ", FixedTermDepositType=" + FixedTermDepositType + ", PaymentMethod=" + PaymentMethod + ", TotalInterestAmount=" + TotalInterestAmount + ", RenewalType=" + RenewalType + ", InterestCreditProductBankIdentifier=" + InterestCreditProductBankIdentifier + ", DepositCreditProductBankIdentifier=" + DepositCreditProductBankIdentifier + ", FixedTermDepositBeneficiaries=" + FixedTermDepositBeneficiaries + '}';
    }

}
