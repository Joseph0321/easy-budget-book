package com.budget.easybook.income.dto;

import com.budget.easybook.category.dto.CategoryDTO;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class IncomeDTO {
    private Long incomeId;
    private Long userId;
    private Long categoryId;
    private String categoryName;
    private String categoryColor;
    private BigDecimal amount;
    private String description;
    private String merchantName;
    private String memo;
    private String paymentMethod;
    private String receiptImagePath;
    private LocalDate incomeDate;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
