package com.budget.easybook.transaction.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TransactionDTO {
    private Long id;
    private String type;
    private Long userId;
    private Long categoryId;
    private String categoryName;
    private String categoryColor;
    private String categoryIcon;
    private BigDecimal amount;
    private String description;
    private String merchantName;
    private String memo;
    private String paymentMethod;
    private String receiptImagePath;
    private LocalDate transactionDate;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
