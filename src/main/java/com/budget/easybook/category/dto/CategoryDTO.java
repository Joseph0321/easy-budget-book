package com.budget.easybook.category.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CategoryDTO {
    private Long categoryId;
    private Long userId;
    private String name;
    private String type; // income or expense
    private String color;
    private String icon;
    private LocalDateTime createdAt;
}
