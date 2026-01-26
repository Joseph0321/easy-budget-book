package com.budget.easybook.income.dto;

import com.budget.easybook.auth.entity.User;
import com.budget.easybook.category.entity.Category;
import com.budget.easybook.income.entity.Income;

public class IncomeMapper {
    
    public static IncomeDTO toDTO(Income income) {
        if (income == null) return null;
        
        IncomeDTO dto = new IncomeDTO();
        dto.setIncomeId(income.getIncomeId());
        dto.setUserId(income.getUser().getUserId());
        
        if (income.getCategory() != null) {
            dto.setCategoryId(income.getCategory().getCategoryId());
            dto.setCategoryName(income.getCategory().getName());
            dto.setCategoryColor(income.getCategory().getColor());
        }
        
        dto.setAmount(income.getAmount());
        dto.setDescription(income.getDescription());
        dto.setMerchantName(income.getMerchantName());
        dto.setMemo(income.getMemo());
        dto.setPaymentMethod(income.getPaymentMethod());
        dto.setReceiptImagePath(income.getReceiptImagePath());
        dto.setIncomeDate(income.getIncomeDate());
        dto.setCreatedAt(income.getCreatedAt());
        dto.setUpdatedAt(income.getUpdatedAt());
        return dto;
    }
    
    public static Income toEntity(IncomeCreateDTO dto, User user, Category category) {
        if (dto == null) return null;
        
        Income income = new Income();
        income.setUser(user);
        income.setCategory(category);
        income.setAmount(dto.getAmount());
        income.setDescription(dto.getDescription());
        income.setMerchantName(dto.getMerchantName());
        income.setMemo(dto.getMemo());
        income.setPaymentMethod(dto.getPaymentMethod());
        income.setReceiptImagePath(dto.getReceiptImagePath());
        income.setIncomeDate(dto.getIncomeDate());
        return income;
    }
    
    public static void updateEntity(Income income, IncomeUpdateDTO dto, Category category) {
        if (dto.getCategoryId() != null && category != null) {
            income.setCategory(category);
        }
        if (dto.getAmount() != null) {
            income.setAmount(dto.getAmount());
        }
        if (dto.getDescription() != null) {
            income.setDescription(dto.getDescription());
        }
        if (dto.getMerchantName() != null) {
            income.setMerchantName(dto.getMerchantName());
        }
        if (dto.getMemo() != null) {
            income.setMemo(dto.getMemo());
        }
        if (dto.getPaymentMethod() != null) {
            income.setPaymentMethod(dto.getPaymentMethod());
        }
        if (dto.getReceiptImagePath() != null) {
            income.setReceiptImagePath(dto.getReceiptImagePath());
        }
        if (dto.getIncomeDate() != null) {
            income.setIncomeDate(dto.getIncomeDate());
        }
    }
}
