package com.budget.easybook.statistics.dto;

import java.math.BigDecimal;
import java.util.List;

public class MonthlyStatsDTO {
    private List<BigDecimal> income;
    private List<BigDecimal> expense;
    
    public MonthlyStatsDTO() {}
    
    public MonthlyStatsDTO(List<BigDecimal> income, List<BigDecimal> expense) {
        this.income = income;
        this.expense = expense;
    }
    
    public List<BigDecimal> getIncome() {
        return income;
    }
    
    public void setIncome(List<BigDecimal> income) {
        this.income = income;
    }
    
    public List<BigDecimal> getExpense() {
        return expense;
    }
    
    public void setExpense(List<BigDecimal> expense) {
        this.expense = expense;
    }
}
