package com.budget.easybook.category.controller;

import com.budget.easybook.category.dto.CategoryCreateDTO;
import com.budget.easybook.category.dto.CategoryDTO;
import com.budget.easybook.category.dto.CategoryUpdateDTO;
import com.budget.easybook.category.service.CategoryService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/categories")
public class CategoryController {
    
    @Autowired
    private CategoryService categoryService;
    
    @GetMapping
    public ResponseEntity<List<CategoryDTO>> getCategories(
            @RequestParam(defaultValue = "9") Long userId,
            @RequestParam(required = false) String type) {
        List<CategoryDTO> categories = categoryService.getCategories(userId, type);
        return ResponseEntity.ok(categories);
    }
    
    @GetMapping("/{categoryId}")
    public ResponseEntity<CategoryDTO> getCategory(
            @PathVariable Long categoryId,
            @RequestParam(defaultValue = "9") Long userId) {
        CategoryDTO category = categoryService.getCategory(userId, categoryId);
        return ResponseEntity.ok(category);
    }
    
    @PostMapping
    public ResponseEntity<CategoryDTO> createCategory(
            @RequestParam(defaultValue = "9") Long userId,
            @Valid @RequestBody CategoryCreateDTO dto) {
        CategoryDTO category = categoryService.createCategory(userId, dto);
        return ResponseEntity.ok(category);
    }
    
    @PutMapping("/{categoryId}")
    public ResponseEntity<CategoryDTO> updateCategory(
            @PathVariable Long categoryId,
            @RequestParam(defaultValue = "9") Long userId,
            @Valid @RequestBody CategoryUpdateDTO dto) {
        CategoryDTO category = categoryService.updateCategory(userId, categoryId, dto);
        return ResponseEntity.ok(category);
    }
    
    @DeleteMapping("/{categoryId}")
    public ResponseEntity<Map<String, Object>> deleteCategory(
            @PathVariable Long categoryId,
            @RequestParam(defaultValue = "9") Long userId) {
        try {
            categoryService.deleteCategory(userId, categoryId);
            return ResponseEntity.ok(Map.of("success", true, "message", "Category deleted successfully"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    @GetMapping("/{categoryId}/check-usage")
    public ResponseEntity<Map<String, Object>> checkCategoryUsage(
            @PathVariable Long categoryId,
            @RequestParam(defaultValue = "9") Long userId) {
        boolean hasTransactions = categoryService.categoryHasTransactions(userId, categoryId);
        return ResponseEntity.ok(Map.of("hasTransactions", hasTransactions));
    }
}
