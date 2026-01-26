package com.budget.easybook.transaction.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MonthlySummaryDTO {
    private int year;
    private int month;
    private BigDecimal totalIncome;
    private BigDecimal totalExpense;
    private BigDecimal balance;
    private long incomeCount;
    private long expenseCount;
}
