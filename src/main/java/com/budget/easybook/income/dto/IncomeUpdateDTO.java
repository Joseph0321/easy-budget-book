package com.budget.easybook.income.dto;

import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class IncomeUpdateDTO {
    
    private Long categoryId;
    
    @Positive(message = "Amount must be positive")
    private BigDecimal amount;
    
    private String description;
    
    private String merchantName;
    
    private String memo;
    
    private String paymentMethod;
    
    private String receiptImagePath;
    
    private LocalDate incomeDate;
}
