package com.budget.easybook.transaction.controller;

import com.budget.easybook.expense.dto.ExpenseDTO;
import com.budget.easybook.expense.dto.ExpenseCreateDTO;
import com.budget.easybook.expense.dto.ExpenseUpdateDTO;
import com.budget.easybook.expense.entity.Expense;
import com.budget.easybook.expense.repository.ExpenseRepository;
import com.budget.easybook.income.dto.IncomeDTO;
import com.budget.easybook.income.dto.IncomeCreateDTO;
import com.budget.easybook.income.dto.IncomeUpdateDTO;
import com.budget.easybook.income.entity.Income;
import com.budget.easybook.income.repository.IncomeRepository;
import com.budget.easybook.income.service.IncomeService;
import com.budget.easybook.expense.service.ExpenseService;
import com.budget.easybook.transaction.dto.MonthlySummaryDTO;
import com.budget.easybook.transaction.dto.TransactionDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/transactions")
public class TransactionController {
    
    @Autowired
    private IncomeRepository incomeRepository;
    
    @Autowired
    private ExpenseRepository expenseRepository;
    
    @Autowired
    private IncomeService incomeService;
    
    @Autowired
    private ExpenseService expenseService;
    
    @GetMapping("/period")
    public ResponseEntity<List<TransactionDTO>> getTransactionsByPeriod(
            @RequestParam Long userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end) {
        
        List<TransactionDTO> transactions = new ArrayList<>();
        
        List<Income> incomes = incomeRepository.findByUserIdAndIncomeDateBetween(userId, start, end);
        for (Income income : incomes) {
            transactions.add(mapIncomeToTransaction(income));
        }
        
        List<Expense> expenses = expenseRepository.findByUserIdAndExpenseDateBetween(userId, start, end);
        for (Expense expense : expenses) {
            transactions.add(mapExpenseToTransaction(expense));
        }
        
        transactions.sort(Comparator.comparing(TransactionDTO::getTransactionDate).reversed());
        
        return ResponseEntity.ok(transactions);
    }
    
    @GetMapping("/category/{categoryId}")
    public ResponseEntity<List<TransactionDTO>> getTransactionsByCategory(
            @RequestParam Long userId,
            @PathVariable Long categoryId) {
        
        List<TransactionDTO> transactions = new ArrayList<>();
        
        List<Income> incomes = incomeRepository.findByUserIdAndCategoryId(userId, categoryId);
        for (Income income : incomes) {
            transactions.add(mapIncomeToTransaction(income));
        }
        
        List<Expense> expenses = expenseRepository.findByUserIdAndCategoryId(userId, categoryId);
        for (Expense expense : expenses) {
            transactions.add(mapExpenseToTransaction(expense));
        }
        
        transactions.sort(Comparator.comparing(TransactionDTO::getTransactionDate).reversed());
        
        return ResponseEntity.ok(transactions);
    }
    
    @GetMapping("/type/{type}")
    public ResponseEntity<List<TransactionDTO>> getTransactionsByType(
            @RequestParam Long userId,
            @PathVariable String type,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        List<TransactionDTO> transactions = new ArrayList<>();
        LocalDate startDate = LocalDate.of(2020, 1, 1);
        LocalDate endDate = LocalDate.of(2030, 12, 31);
        
        if ("INCOME".equalsIgnoreCase(type)) {
            List<Income> incomes = incomeRepository.findByUserIdAndIncomeDateBetween(userId, startDate, endDate);
            int start = page * size;
            int end = Math.min(start + size, incomes.size());
            if (start < incomes.size()) {
                for (Income income : incomes.subList(start, end)) {
                    transactions.add(mapIncomeToTransaction(income));
                }
            }
        } else if ("EXPENSE".equalsIgnoreCase(type)) {
            List<Expense> expenses = expenseRepository.findByUserIdAndExpenseDateBetween(userId, startDate, endDate);
            int start = page * size;
            int end = Math.min(start + size, expenses.size());
            if (start < expenses.size()) {
                for (Expense expense : expenses.subList(start, end)) {
                    transactions.add(mapExpenseToTransaction(expense));
                }
            }
        }
        
        return ResponseEntity.ok(transactions);
    }
    
    @GetMapping("/monthly/{year}/{month}/summary")
    public ResponseEntity<MonthlySummaryDTO> getMonthlySummary(
            @RequestParam Long userId,
            @PathVariable int year,
            @PathVariable int month) {
        
        LocalDate startDate = LocalDate.of(year, month, 1);
        LocalDate endDate = startDate.plusMonths(1).minusDays(1);
        
        BigDecimal totalIncome = incomeRepository.getTotalByUserIdAndDateBetween(userId, startDate, endDate);
        BigDecimal totalExpense = expenseRepository.getTotalByUserIdAndDateBetween(userId, startDate, endDate);
        
        if (totalIncome == null) totalIncome = BigDecimal.ZERO;
        if (totalExpense == null) totalExpense = BigDecimal.ZERO;
        
        long incomeCount = incomeRepository.countByUserIdAndIncomeDateBetween(userId, startDate, endDate);
        long expenseCount = expenseRepository.countByUserIdAndExpenseDateBetween(userId, startDate, endDate);
        
        BigDecimal balance = totalIncome.subtract(totalExpense);
        
        MonthlySummaryDTO summary = new MonthlySummaryDTO();
        summary.setYear(year);
        summary.setMonth(month);
        summary.setTotalIncome(totalIncome);
        summary.setTotalExpense(totalExpense);
        summary.setBalance(balance);
        summary.setIncomeCount(incomeCount);
        summary.setExpenseCount(expenseCount);
        
        return ResponseEntity.ok(summary);
    }
    
    private TransactionDTO mapIncomeToTransaction(Income income) {
        TransactionDTO dto = new TransactionDTO();
        dto.setId(income.getIncomeId());
        dto.setType("INCOME");
        dto.setUserId(income.getUser().getUserId());
        if (income.getCategory() != null) {
            dto.setCategoryId(income.getCategory().getCategoryId());
            dto.setCategoryName(income.getCategory().getName());
            dto.setCategoryColor(income.getCategory().getColor());
            dto.setCategoryIcon(income.getCategory().getIcon());
        }
        dto.setAmount(income.getAmount());
        dto.setDescription(income.getDescription());
        dto.setMerchantName(income.getMerchantName());
        dto.setMemo(income.getMemo());
        dto.setPaymentMethod(income.getPaymentMethod());
        dto.setReceiptImagePath(income.getReceiptImagePath());
        dto.setTransactionDate(income.getIncomeDate());
        dto.setCreatedAt(income.getCreatedAt());
        dto.setUpdatedAt(income.getUpdatedAt());
        return dto;
    }
    
    private TransactionDTO mapExpenseToTransaction(Expense expense) {
        TransactionDTO dto = new TransactionDTO();
        dto.setId(expense.getExpenseId());
        dto.setType("EXPENSE");
        dto.setUserId(expense.getUser().getUserId());
        if (expense.getCategory() != null) {
            dto.setCategoryId(expense.getCategory().getCategoryId());
            dto.setCategoryName(expense.getCategory().getName());
            dto.setCategoryColor(expense.getCategory().getColor());
            dto.setCategoryIcon(expense.getCategory().getIcon());
        }
        dto.setAmount(expense.getAmount());
        dto.setDescription(expense.getDescription());
        dto.setMerchantName(expense.getMerchantName());
        dto.setMemo(expense.getMemo());
        dto.setPaymentMethod(expense.getPaymentMethod());
        dto.setReceiptImagePath(expense.getReceiptImagePath());
        dto.setTransactionDate(expense.getExpenseDate());
        dto.setCreatedAt(expense.getCreatedAt());
        dto.setUpdatedAt(expense.getUpdatedAt());
        return dto;
    }
    
    @PostMapping("/income")
    public ResponseEntity<IncomeDTO> createIncome(
            @RequestParam Long userId,
            @RequestBody IncomeCreateDTO dto) {
        IncomeDTO income = incomeService.createIncome(userId, dto);
        return ResponseEntity.ok(income);
    }
    
    @PostMapping("/expense")
    public ResponseEntity<ExpenseDTO> createExpense(
            @RequestParam Long userId,
            @RequestBody ExpenseCreateDTO dto) {
        ExpenseDTO expense = expenseService.createExpense(userId, dto);
        return ResponseEntity.ok(expense);
    }
    
    @PutMapping("/income/{id}")
    public ResponseEntity<IncomeDTO> updateIncome(
            @PathVariable Long id,
            @RequestParam Long userId,
            @RequestBody IncomeUpdateDTO dto) {
        IncomeDTO income = incomeService.updateIncome(userId, id, dto);
        return ResponseEntity.ok(income);
    }
    
    @PutMapping("/expense/{id}")
    public ResponseEntity<ExpenseDTO> updateExpense(
            @PathVariable Long id,
            @RequestParam Long userId,
            @RequestBody ExpenseUpdateDTO dto) {
        ExpenseDTO expense = expenseService.updateExpense(userId, id, dto);
        return ResponseEntity.ok(expense);
    }
    
    @DeleteMapping("/income/{id}")
    public ResponseEntity<Void> deleteIncome(
            @PathVariable Long id,
            @RequestParam Long userId) {
        incomeService.deleteIncome(userId, id);
        return ResponseEntity.noContent().build();
    }
    
    @DeleteMapping("/expense/{id}")
    public ResponseEntity<Void> deleteExpense(
            @PathVariable Long id,
            @RequestParam Long userId) {
        expenseService.deleteExpense(userId, id);
        return ResponseEntity.noContent().build();
    }
}
