package com.budget.easybook.category.service;

import com.budget.easybook.auth.entity.User;
import com.budget.easybook.auth.repository.UserRepository;
import com.budget.easybook.category.dto.CategoryCreateDTO;
import com.budget.easybook.category.dto.CategoryDTO;
import com.budget.easybook.category.dto.CategoryMapper;
import com.budget.easybook.category.dto.CategoryUpdateDTO;
import com.budget.easybook.category.entity.Category;
import com.budget.easybook.category.repository.CategoryRepository;
import com.budget.easybook.income.repository.IncomeRepository;
import com.budget.easybook.expense.repository.ExpenseRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class CategoryService {
    
    @Autowired
    private CategoryRepository categoryRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private IncomeRepository incomeRepository;
    
    @Autowired
    private ExpenseRepository expenseRepository;
    
    /**
     * Get all categories for a user
     */
    public List<CategoryDTO> getCategories(Long userId, String type) {
        List<Category> categories;
        
        if (type != null && !type.isEmpty()) {
            categories = categoryRepository.findByUserIdAndType(userId, type);
        } else {
            categories = categoryRepository.findByUserId(userId);
        }
        
        return categories.stream()
                .map(CategoryMapper::toDTO)
                .collect(Collectors.toList());
    }
    
    /**
     * Get single category
     */
    public CategoryDTO getCategory(Long userId, Long categoryId) {
        Category category = categoryRepository.findByIdAndUserId(categoryId, userId)
                .orElseThrow(() -> new RuntimeException("Category not found or unauthorized"));
        
        return CategoryMapper.toDTO(category);
    }
    
    /**
     * Create new category
     */
    public CategoryDTO createCategory(Long userId, CategoryCreateDTO dto) {
        // Validate user exists
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        // Check if category name already exists for this user and type
        if (categoryRepository.existsByUserIdAndNameAndType(userId, dto.getName(), dto.getType())) {
            throw new RuntimeException("Category with this name already exists for " + dto.getType());
        }
        
        // Create category
        Category category = CategoryMapper.toEntity(dto, user);
        Category saved = categoryRepository.save(category);
        
        return CategoryMapper.toDTO(saved);
    }
    
    /**
     * Update category
     */
    public CategoryDTO updateCategory(Long userId, Long categoryId, CategoryUpdateDTO dto) {
        Category category = categoryRepository.findByIdAndUserId(categoryId, userId)
                .orElseThrow(() -> new RuntimeException("Category not found or unauthorized"));
        
        // Check for duplicate name if name is being changed
        if (dto.getName() != null && !dto.getName().equals(category.getName())) {
            if (categoryRepository.existsByUserIdAndNameAndType(userId, dto.getName(), category.getType())) {
                throw new RuntimeException("Category with this name already exists");
            }
        }
        
        CategoryMapper.updateEntity(category, dto);
        Category updated = categoryRepository.save(category);
        
        return CategoryMapper.toDTO(updated);
    }
    
    /**
     * Delete category - only if no transactions exist for this category
     */
    public void deleteCategory(Long userId, Long categoryId) {
        Category category = categoryRepository.findByIdAndUserId(categoryId, userId)
                .orElseThrow(() -> new RuntimeException("Category not found or unauthorized"));
        
        if (categoryHasTransactions(userId, categoryId)) {
            throw new RuntimeException("이 카테고리에 거래 내역이 있어 삭제할 수 없습니다.");
        }
        
        categoryRepository.delete(category);
    }
    
    /**
     * Check if a category has any transactions (income or expense)
     */
    public boolean categoryHasTransactions(Long userId, Long categoryId) {
        Category category = categoryRepository.findByIdAndUserId(categoryId, userId)
                .orElseThrow(() -> new RuntimeException("Category not found"));
        
        if ("income".equals(category.getType())) {
            return incomeRepository.existsByUserIdAndCategoryId(userId, categoryId);
        } else {
            return expenseRepository.existsByUserIdAndCategoryId(userId, categoryId);
        }
    }
    
    /**
     * Create default categories for a new user
     */
    public List<CategoryDTO> createDefaultCategories(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        // Default income categories
        createDefaultCategory(user, "급여", "income", "#4CAF50", "💰");
        createDefaultCategory(user, "부수입", "income", "#8BC34A", "💵");
        createDefaultCategory(user, "기타수입", "income", "#CDDC39", "🏦");
        
        // Default expense categories
        createDefaultCategory(user, "식비", "expense", "#F44336", "🍔");
        createDefaultCategory(user, "교통비", "expense", "#E91E63", "🚗");
        createDefaultCategory(user, "쇼핑", "expense", "#9C27B0", "🛍️");
        createDefaultCategory(user, "주거비", "expense", "#673AB7", "🏠");
        createDefaultCategory(user, "의료비", "expense", "#3F51B5", "🏥");
        createDefaultCategory(user, "문화생활", "expense", "#2196F3", "🎬");
        createDefaultCategory(user, "기타지출", "expense", "#FF9800", "📦");
        
        return getCategories(userId, null);
    }
    
    private void createDefaultCategory(User user, String name, String type, String color, String icon) {
        Category category = new Category();
        category.setUser(user);
        category.setName(name);
        category.setType(type);
        category.setColor(color);
        category.setIcon(icon);
        categoryRepository.save(category);
    }
}
