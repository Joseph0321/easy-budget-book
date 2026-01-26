package com.budget.easybook.category.repository;

import com.budget.easybook.category.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {
    
    /**
     * Find all categories for a specific user
     * @param userId user ID
     * @return list of categories
     */
    @Query("SELECT c FROM Category c WHERE c.user.userId = :userId ORDER BY c.name")
    List<Category> findByUserId(@Param("userId") Long userId);
    
    /**
     * Find categories by user and type (income/expense)
     * @param userId user ID
     * @param type category type (income or expense)
     * @return list of categories
     */
    @Query("SELECT c FROM Category c WHERE c.user.userId = :userId AND c.type = :type ORDER BY c.name")
    List<Category> findByUserIdAndType(@Param("userId") Long userId, @Param("type") String type);
    
    /**
     * Find category by ID and verify it belongs to user
     * @param categoryId category ID
     * @param userId user ID
     * @return Optional containing category if found and belongs to user
     */
    @Query("SELECT c FROM Category c WHERE c.categoryId = :categoryId AND c.user.userId = :userId")
    Optional<Category> findByIdAndUserId(@Param("categoryId") Long categoryId, @Param("userId") Long userId);
    
    /**
     * Check if category name already exists for user
     * @param userId user ID
     * @param name category name
     * @param type category type
     * @return true if exists
     */
    @Query("SELECT CASE WHEN COUNT(c) > 0 THEN true ELSE false END FROM Category c " +
           "WHERE c.user.userId = :userId AND c.name = :name AND c.type = :type")
    boolean existsByUserIdAndNameAndType(@Param("userId") Long userId, 
                                         @Param("name") String name, 
                                         @Param("type") String type);
    
    /**
     * Count categories for a user by type
     * @param userId user ID
     * @param type category type
     * @return count
     */
    @Query("SELECT COUNT(c) FROM Category c WHERE c.user.userId = :userId AND c.type = :type")
    long countByUserIdAndType(@Param("userId") Long userId, @Param("type") String type);
}
