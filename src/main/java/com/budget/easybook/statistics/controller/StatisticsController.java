package com.budget.easybook.statistics.controller;

import com.budget.easybook.expense.entity.Expense;
import com.budget.easybook.expense.repository.ExpenseRepository;
import com.budget.easybook.income.entity.Income;
import com.budget.easybook.income.repository.IncomeRepository;
import com.budget.easybook.statistics.dto.CategoryStatsDTO;
import com.budget.easybook.statistics.dto.MonthlyStatsDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/statistics")
public class StatisticsController {
    
    @Autowired
    private IncomeRepository incomeRepository;
    
    @Autowired
    private ExpenseRepository expenseRepository;
    
    @GetMapping("/monthly/{year}")
    public ResponseEntity<MonthlyStatsDTO> getMonthlyStats(
            @RequestParam Long userId,
            @PathVariable int year) {
        
        List<BigDecimal> income = new ArrayList<>();
        List<BigDecimal> expense = new ArrayList<>();
        
        for (int month = 1; month <= 12; month++) {
            LocalDate startDate = LocalDate.of(year, month, 1);
            LocalDate endDate = startDate.plusMonths(1).minusDays(1);
            
            BigDecimal monthlyIncome = incomeRepository.getTotalByUserIdAndDateBetween(userId, startDate, endDate);
            BigDecimal monthlyExpense = expenseRepository.getTotalByUserIdAndDateBetween(userId, startDate, endDate);
            
            income.add(monthlyIncome != null ? monthlyIncome : BigDecimal.ZERO);
            expense.add(monthlyExpense != null ? monthlyExpense : BigDecimal.ZERO);
        }
        
        return ResponseEntity.ok(new MonthlyStatsDTO(income, expense));
    }
    
    @GetMapping("/category")
    public ResponseEntity<List<CategoryStatsDTO>> getCategoryStats(
            @RequestParam Long userId,
            @RequestParam String start,
            @RequestParam String end,
            @RequestParam String type) {
        
        LocalDate startDate = LocalDate.parse(start);
        LocalDate endDate = LocalDate.parse(end);
        
        List<CategoryStatsDTO> stats = new ArrayList<>();
        
        if ("INCOME".equalsIgnoreCase(type)) {
            List<Income> incomes = incomeRepository.findByUserIdAndIncomeDateBetween(userId, startDate, endDate);
            stats = calculateIncomeStats(incomes);
        } else if ("EXPENSE".equalsIgnoreCase(type)) {
            List<Expense> expenses = expenseRepository.findByUserIdAndExpenseDateBetween(userId, startDate, endDate);
            stats = calculateExpenseStats(expenses);
        }
        
        return ResponseEntity.ok(stats);
    }
    
    private List<CategoryStatsDTO> calculateIncomeStats(List<Income> incomes) {
        Map<Long, CategoryStatsDTO> categoryMap = new HashMap<>();
        BigDecimal total = BigDecimal.ZERO;
        
        for (Income income : incomes) {
            if (income.getCategory() == null) continue;
            
            Long categoryId = income.getCategory().getCategoryId();
            CategoryStatsDTO dto = categoryMap.get(categoryId);
            
            if (dto == null) {
                dto = new CategoryStatsDTO();
                dto.setCategoryId(categoryId);
                dto.setCategoryName(income.getCategory().getName());
                dto.setCategoryIcon(income.getCategory().getIcon());
                dto.setCategoryColor(income.getCategory().getColor());
                dto.setAmount(BigDecimal.ZERO);
                dto.setCount(0);
                categoryMap.put(categoryId, dto);
            }
            
            dto.setAmount(dto.getAmount().add(income.getAmount()));
            dto.setCount(dto.getCount() + 1);
            total = total.add(income.getAmount());
        }
        
        List<CategoryStatsDTO> result = new ArrayList<>(categoryMap.values());
        
        for (CategoryStatsDTO dto : result) {
            if (total.compareTo(BigDecimal.ZERO) > 0) {
                double percentage = dto.getAmount()
                        .multiply(BigDecimal.valueOf(100))
                        .divide(total, 2, RoundingMode.HALF_UP)
                        .doubleValue();
                dto.setPercentage(percentage);
            }
        }
        
        result.sort((a, b) -> b.getAmount().compareTo(a.getAmount()));
        
        return result;
    }
    
    private List<CategoryStatsDTO> calculateExpenseStats(List<Expense> expenses) {
        Map<Long, CategoryStatsDTO> categoryMap = new HashMap<>();
        BigDecimal total = BigDecimal.ZERO;
        
        for (Expense expense : expenses) {
            if (expense.getCategory() == null) continue;
            
            Long categoryId = expense.getCategory().getCategoryId();
            CategoryStatsDTO dto = categoryMap.get(categoryId);
            
            if (dto == null) {
                dto = new CategoryStatsDTO();
                dto.setCategoryId(categoryId);
                dto.setCategoryName(expense.getCategory().getName());
                dto.setCategoryIcon(expense.getCategory().getIcon());
                dto.setCategoryColor(expense.getCategory().getColor());
                dto.setAmount(BigDecimal.ZERO);
                dto.setCount(0);
                categoryMap.put(categoryId, dto);
            }
            
            dto.setAmount(dto.getAmount().add(expense.getAmount()));
            dto.setCount(dto.getCount() + 1);
            total = total.add(expense.getAmount());
        }
        
        List<CategoryStatsDTO> result = new ArrayList<>(categoryMap.values());
        
        for (CategoryStatsDTO dto : result) {
            if (total.compareTo(BigDecimal.ZERO) > 0) {
                double percentage = dto.getAmount()
                        .multiply(BigDecimal.valueOf(100))
                        .divide(total, 2, RoundingMode.HALF_UP)
                        .doubleValue();
                dto.setPercentage(percentage);
            }
        }
        
        result.sort((a, b) -> b.getAmount().compareTo(a.getAmount()));
        
        return result;
    }
}
