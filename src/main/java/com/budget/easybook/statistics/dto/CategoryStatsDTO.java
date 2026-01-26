package com.budget.easybook.statistics.dto;

import java.math.BigDecimal;

public class CategoryStatsDTO {
    private Long categoryId;
    private String categoryName;
    private String categoryIcon;
    private String categoryColor;
    private BigDecimal amount;
    private int count;
    private double percentage;
    
    public CategoryStatsDTO() {}
    
    public CategoryStatsDTO(Long categoryId, String categoryName, String categoryIcon, 
                           String categoryColor, BigDecimal amount, int count) {
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.categoryIcon = categoryIcon;
        this.categoryColor = categoryColor;
        this.amount = amount;
        this.count = count;
    }
    
    public Long getCategoryId() {
        return categoryId;
    }
    
    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }
    
    public String getCategoryName() {
        return categoryName;
    }
    
    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }
    
    public String getCategoryIcon() {
        return categoryIcon;
    }
    
    public void setCategoryIcon(String categoryIcon) {
        this.categoryIcon = categoryIcon;
    }
    
    public String getCategoryColor() {
        return categoryColor;
    }
    
    public void setCategoryColor(String categoryColor) {
        this.categoryColor = categoryColor;
    }
    
    public BigDecimal getAmount() {
        return amount;
    }
    
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }
    
    public int getCount() {
        return count;
    }
    
    public void setCount(int count) {
        this.count = count;
    }
    
    public double getPercentage() {
        return percentage;
    }
    
    public void setPercentage(double percentage) {
        this.percentage = percentage;
    }
}
