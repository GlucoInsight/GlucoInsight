package com.example.ex3_2_back.repository;

import com.example.ex3_2_back.entity.Diet;
import com.example.ex3_2_back.entity.User;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.data.rest.core.annotation.RestResource;

import java.util.List;

@RepositoryRestResource(path = "DietRepository")
@Tag(name = "数据库Diet接口")
public interface DietRepository extends JpaRepository<Diet, String> {

    @Operation(summary = "通过用户查找所有饮食信息, 从后到前排序")
    @RestResource(path = "findByUser")
    @Query("SELECT d FROM Diet d WHERE d.user = :user ORDER BY d.endTime DESC")
    List<Diet> findByUser(User user);
}
