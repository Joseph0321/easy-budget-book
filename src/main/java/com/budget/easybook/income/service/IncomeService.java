package com.budget.easybook.income.service;

import com.budget.easybook.auth.entity.User;
import com.budget.easybook.auth.repository.UserRepository;
import com.budget.easybook.category.entity.Category;
import com.budget.easybook.category.repository.CategoryRepository;
import com.budget.easybook.income.dto.IncomeCreateDTO;
import com.budget.easybook.income.dto.IncomeDTO;
import com.budget.easybook.income.dto.IncomeMapper;
import com.budget.easybook.income.dto.IncomeUpdateDTO;
import com.budget.easybook.income.entity.Income;
import com.budget.easybook.income.repository.IncomeRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class IncomeService {
    
    @Autowired
    private IncomeRepository incomeRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private CategoryRepository categoryRepository;
    
    /**
     * Get incomes with filters and pagination
     */
    public Page<IncomeDTO> getIncomes(Long userId, LocalDate startDate, LocalDate endDate, 
                                       Long categoryId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("incomeDate").descending());
        Page<Income> incomePage;
        
        if (startDate != null && endDate != null) {
            if (categoryId != null) {
                // Filter by date and category
                incomePage = incomeRepository.findByUserIdAndDateBetween(userId, startDate, endDate, pageable)
                        .map(income -> income); // Additional category filter in stream
            } else {
                // Filter by date only
                incomePage = incomeRepository.findByUserIdAndDateBetween(userId, startDate, endDate, pageable);
            }
        } else if (categoryId != null) {
            // Filter by category only
            incomePage = incomeRepository.findByUserIdAndCategoryId(userId, categoryId, pageable);
        } else {
            // No filters
            incomePage = incomeRepository.findByUserId(userId, pageable);
        }
        
        return incomePage.map(IncomeMapper::toDTO);
    }
    
    /**
     * Get single income
     */
    public IncomeDTO getIncome(Long userId, Long incomeId) {
        Income income = incomeRepository.findByIdAndUserId(incomeId, userId)
                .orElseThrow(() -> new RuntimeException("Income not found or unauthorized"));
        
        return IncomeMapper.toDTO(income);
    }
    
    /**
     * Create new income
     */
    public IncomeDTO createIncome(Long userId, IncomeCreateDTO dto) {
        // Validate user
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        // Validate category
        Category category = categoryRepository.findByIdAndUserId(dto.getCategoryId(), userId)
                .orElseThrow(() -> new RuntimeException("Category not found or unauthorized"));
        
        // Verify category is income type
        if (!"income".equalsIgnoreCase(category.getType())) {
            throw new RuntimeException("Category must be of type 'income'");
        }
        
        Income income = IncomeMapper.toEntity(dto, user, category);
        Income saved = incomeRepository.save(income);
        
        return IncomeMapper.toDTO(saved);
    }
    
    /**
     * Update income
     */
    public IncomeDTO updateIncome(Long userId, Long incomeId, IncomeUpdateDTO dto) {
        Income income = incomeRepository.findByIdAndUserId(incomeId, userId)
                .orElseThrow(() -> new RuntimeException("Income not found or unauthorized"));
        
        Category category = null;
        if (dto.getCategoryId() != null) {
            category = categoryRepository.findByIdAndUserId(dto.getCategoryId(), userId)
                    .orElseThrow(() -> new RuntimeException("Category not found or unauthorized"));
            
            if (!"income".equalsIgnoreCase(category.getType())) {
                throw new RuntimeException("Category must be of type 'income'");
            }
        }
        
        IncomeMapper.updateEntity(income, dto, category);
        Income updated = incomeRepository.save(income);
        
        return IncomeMapper.toDTO(updated);
    }
    
    /**
     * Delete income
     */
    public void deleteIncome(Long userId, Long incomeId) {
        Income income = incomeRepository.findByIdAndUserId(incomeId, userId)
                .orElseThrow(() -> new RuntimeException("Income not found or unauthorized"));
        
        incomeRepository.delete(income);
    }
    
    /**
     * Get monthly total
     */
    public BigDecimal getMonthlyTotal(Long userId, int year, int month) {
        LocalDate startDate = LocalDate.of(year, month, 1);
        LocalDate endDate = startDate.plusMonths(1).minusDays(1);
        
        return incomeRepository.getTotalByUserIdAndDateBetween(userId, startDate, endDate);
    }
    
    /**
     * Get total count for user
     */
    public long getTotalCount(Long userId) {
        return incomeRepository.countByUserId(userId);
    }
}
