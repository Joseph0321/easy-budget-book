package com.budget.easybook.expense.dto;

import com.budget.easybook.auth.entity.User;
import com.budget.easybook.category.entity.Category;
import com.budget.easybook.expense.entity.Expense;
import com.budget.easybook.receipt.entity.Receipt;

public class ExpenseMapper {
    
    public static ExpenseDTO toDTO(Expense expense) {
        if (expense == null) return null;
        
        ExpenseDTO dto = new ExpenseDTO();
        dto.setExpenseId(expense.getExpenseId());
        dto.setUserId(expense.getUser().getUserId());
        
        if (expense.getCategory() != null) {
            dto.setCategoryId(expense.getCategory().getCategoryId());
            dto.setCategoryName(expense.getCategory().getName());
            dto.setCategoryColor(expense.getCategory().getColor());
        }
        
        dto.setAmount(expense.getAmount());
        dto.setDescription(expense.getDescription());
        dto.setMerchantName(expense.getMerchantName());
        dto.setMemo(expense.getMemo());
        dto.setPaymentMethod(expense.getPaymentMethod());
        dto.setReceiptImagePath(expense.getReceiptImagePath());
        dto.setExpenseDate(expense.getExpenseDate());
        
        if (expense.getReceipt() != null) {
            dto.setReceiptId(expense.getReceipt().getReceiptId());
            dto.setReceiptImageUrl(expense.getReceipt().getImageUrl());
        }
        
        dto.setCreatedAt(expense.getCreatedAt());
        dto.setUpdatedAt(expense.getUpdatedAt());
        return dto;
    }
    
    public static Expense toEntity(ExpenseCreateDTO dto, User user, Category category, Receipt receipt) {
        if (dto == null) return null;
        
        Expense expense = new Expense();
        expense.setUser(user);
        expense.setCategory(category);
        expense.setAmount(dto.getAmount());
        expense.setDescription(dto.getDescription());
        expense.setMerchantName(dto.getMerchantName());
        expense.setMemo(dto.getMemo());
        expense.setPaymentMethod(dto.getPaymentMethod());
        expense.setReceiptImagePath(dto.getReceiptImagePath());
        expense.setExpenseDate(dto.getExpenseDate());
        expense.setReceipt(receipt);
        return expense;
    }
    
    public static void updateEntity(Expense expense, ExpenseUpdateDTO dto, Category category, Receipt receipt) {
        if (dto.getCategoryId() != null && category != null) {
            expense.setCategory(category);
        }
        if (dto.getAmount() != null) {
            expense.setAmount(dto.getAmount());
        }
        if (dto.getDescription() != null) {
            expense.setDescription(dto.getDescription());
        }
        if (dto.getMerchantName() != null) {
            expense.setMerchantName(dto.getMerchantName());
        }
        if (dto.getMemo() != null) {
            expense.setMemo(dto.getMemo());
        }
        if (dto.getPaymentMethod() != null) {
            expense.setPaymentMethod(dto.getPaymentMethod());
        }
        if (dto.getReceiptImagePath() != null) {
            expense.setReceiptImagePath(dto.getReceiptImagePath());
        }
        if (dto.getExpenseDate() != null) {
            expense.setExpenseDate(dto.getExpenseDate());
        }
        if (dto.getReceiptId() != null) {
            expense.setReceipt(receipt);
        }
    }
}
