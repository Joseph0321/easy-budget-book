package com.budget.easybook.expense.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ExpenseCreateDTO {
    
    @NotNull(message = "Category is required")
    private Long categoryId;
    
    @NotNull(message = "Amount is required")
    @Positive(message = "Amount must be positive")
    private BigDecimal amount;
    
    private String description;
    
    private String merchantName;
    
    private String memo;
    
    private String paymentMethod;
    
    private String receiptImagePath;
    
    @NotNull(message = "Expense date is required")
    private LocalDate expenseDate;
    
    private Long receiptId; // Optional: link to receipt
}
