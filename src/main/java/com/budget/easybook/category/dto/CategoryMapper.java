package com.budget.easybook.category.dto;

import com.budget.easybook.auth.entity.User;
import com.budget.easybook.category.entity.Category;

public class CategoryMapper {
    
    public static CategoryDTO toDTO(Category category) {
        if (category == null) return null;
        
        CategoryDTO dto = new CategoryDTO();
        dto.setCategoryId(category.getCategoryId());
        dto.setUserId(category.getUser().getUserId());
        dto.setName(category.getName());
        dto.setType(category.getType());
        dto.setColor(category.getColor());
        dto.setIcon(category.getIcon());
        dto.setCreatedAt(category.getCreatedAt());
        return dto;
    }
    
    public static Category toEntity(CategoryCreateDTO dto, User user) {
        if (dto == null) return null;
        
        Category category = new Category();
        category.setUser(user);
        category.setName(dto.getName());
        category.setType(dto.getType());
        category.setColor(dto.getColor());
        category.setIcon(dto.getIcon());
        return category;
    }
    
    public static void updateEntity(Category category, CategoryUpdateDTO dto) {
        if (dto.getName() != null) {
            category.setName(dto.getName());
        }
        if (dto.getType() != null) {
            category.setType(dto.getType());
        }
        if (dto.getColor() != null) {
            category.setColor(dto.getColor());
        }
        if (dto.getIcon() != null) {
            category.setIcon(dto.getIcon());
        }
    }
}
