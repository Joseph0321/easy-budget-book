package com.budget.easybook.category.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CategoryCreateDTO {
    
    @NotBlank(message = "Category name is required")
    private String name;
    
    @NotBlank(message = "Type is required")
    @Pattern(regexp = "income|expense", message = "Type must be 'income' or 'expense'")
    private String type;
    
    @Pattern(regexp = "^#[0-9A-Fa-f]{6}$", message = "Color must be valid hex code (e.g., #4CAF50)")
    private String color;
    
    private String icon;
}
