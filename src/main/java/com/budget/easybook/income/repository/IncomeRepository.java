package com.budget.easybook.income.repository;

import com.budget.easybook.income.entity.Income;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface IncomeRepository extends JpaRepository<Income, Long> {
    
    /**
     * Find all incomes for a user with pagination
     * @param userId user ID
     * @param pageable pagination info
     * @return page of incomes
     */
    @Query("SELECT i FROM Income i WHERE i.user.userId = :userId ORDER BY i.incomeDate DESC")
    Page<Income> findByUserId(@Param("userId") Long userId, Pageable pageable);
    
    /**
     * Find income by ID and verify ownership
     * @param incomeId income ID
     * @param userId user ID
     * @return Optional containing income if found and owned by user
     */
    @Query("SELECT i FROM Income i WHERE i.incomeId = :incomeId AND i.user.userId = :userId")
    Optional<Income> findByIdAndUserId(@Param("incomeId") Long incomeId, @Param("userId") Long userId);
    
    /**
     * Find incomes within date range
     * @param userId user ID
     * @param startDate start date
     * @param endDate end date
     * @param pageable pagination info
     * @return page of incomes
     */
    @Query("SELECT i FROM Income i WHERE i.user.userId = :userId " +
           "AND i.incomeDate BETWEEN :startDate AND :endDate ORDER BY i.incomeDate DESC")
    Page<Income> findByUserIdAndDateBetween(@Param("userId") Long userId,
                                             @Param("startDate") LocalDate startDate,
                                             @Param("endDate") LocalDate endDate,
                                             Pageable pageable);
    
    /**
     * Find incomes by category
     * @param userId user ID
     * @param categoryId category ID
     * @param pageable pagination info
     * @return page of incomes
     */
    @Query("SELECT i FROM Income i WHERE i.user.userId = :userId " +
           "AND i.category.categoryId = :categoryId ORDER BY i.incomeDate DESC")
    Page<Income> findByUserIdAndCategoryId(@Param("userId") Long userId,
                                            @Param("categoryId") Long categoryId,
                                            Pageable pageable);
    
    /**
     * Calculate total income for a user in date range
     * @param userId user ID
     * @param startDate start date
     * @param endDate end date
     * @return total amount
     */
    @Query("SELECT COALESCE(SUM(i.amount), 0) FROM Income i " +
           "WHERE i.user.userId = :userId AND i.incomeDate BETWEEN :startDate AND :endDate")
    BigDecimal getTotalByUserIdAndDateBetween(@Param("userId") Long userId,
                                               @Param("startDate") LocalDate startDate,
                                               @Param("endDate") LocalDate endDate);
    
    /**
     * Get monthly totals for a year
     * @param userId user ID
     * @param year year
     * @return list of month and total pairs
     */
    @Query("SELECT FUNCTION('MONTH', i.incomeDate), SUM(i.amount) " +
           "FROM Income i WHERE i.user.userId = :userId " +
           "AND FUNCTION('YEAR', i.incomeDate) = :year " +
           "GROUP BY FUNCTION('MONTH', i.incomeDate) " +
           "ORDER BY FUNCTION('MONTH', i.incomeDate)")
    List<Object[]> getMonthlyTotals(@Param("userId") Long userId, @Param("year") int year);
    
    /**
     * Get category-wise totals for a period
     * @param userId user ID
     * @param startDate start date
     * @param endDate end date
     * @return list of category and total pairs
     */
    @Query("SELECT i.category.categoryId, i.category.name, i.category.color, SUM(i.amount) " +
           "FROM Income i WHERE i.user.userId = :userId " +
           "AND i.incomeDate BETWEEN :startDate AND :endDate " +
           "GROUP BY i.category.categoryId, i.category.name, i.category.color " +
           "ORDER BY SUM(i.amount) DESC")
    List<Object[]> getCategoryTotals(@Param("userId") Long userId,
                                      @Param("startDate") LocalDate startDate,
                                      @Param("endDate") LocalDate endDate);
    
    /**
     * Count incomes for a user
     * @param userId user ID
     * @return count
     */
    @Query("SELECT COUNT(i) FROM Income i WHERE i.user.userId = :userId")
    long countByUserId(@Param("userId") Long userId);
    
    /**
     * Find incomes by date range (list version) with eager fetch
     */
    @Query("SELECT i FROM Income i LEFT JOIN FETCH i.category LEFT JOIN FETCH i.user WHERE i.user.userId = :userId " +
           "AND i.incomeDate BETWEEN :startDate AND :endDate ORDER BY i.incomeDate DESC")
    List<Income> findByUserIdAndIncomeDateBetween(@Param("userId") Long userId,
                                                   @Param("startDate") LocalDate startDate,
                                                   @Param("endDate") LocalDate endDate);
    
    /**
     * Find incomes by category (list version) with eager fetch
     */
    @Query("SELECT i FROM Income i LEFT JOIN FETCH i.category LEFT JOIN FETCH i.user WHERE i.user.userId = :userId " +
           "AND i.category.categoryId = :categoryId ORDER BY i.incomeDate DESC")
    List<Income> findByUserIdAndCategoryId(@Param("userId") Long userId,
                                            @Param("categoryId") Long categoryId);
    
    /**
     * Count incomes for a user in date range
     */
    @Query("SELECT COUNT(i) FROM Income i WHERE i.user.userId = :userId " +
           "AND i.incomeDate BETWEEN :startDate AND :endDate")
    long countByUserIdAndIncomeDateBetween(@Param("userId") Long userId,
                                            @Param("startDate") LocalDate startDate,
                                            @Param("endDate") LocalDate endDate);
    
    /**
     * Check if any incomes exist for a category
     */
    @Query("SELECT CASE WHEN COUNT(i) > 0 THEN true ELSE false END FROM Income i " +
           "WHERE i.user.userId = :userId AND i.category.categoryId = :categoryId")
    boolean existsByUserIdAndCategoryId(@Param("userId") Long userId, @Param("categoryId") Long categoryId);
}
