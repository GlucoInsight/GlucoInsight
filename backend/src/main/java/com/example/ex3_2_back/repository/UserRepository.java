package com.example.ex3_2_back.repository;

import com.example.ex3_2_back.entity.User;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.data.rest.core.annotation.RestResource;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;


@RepositoryRestResource(path = "UserRepository")
@Tag(name = "数据库User接口")
public interface UserRepository extends JpaRepository<User, String> {

    @Operation(summary = "通过ID查找User")
    @RestResource(path = "findById")
    Optional<User> findById(Integer id);

    @Operation(summary = "是否存在ID")
    @RestResource(path = "existsById")
    boolean existsById(Integer id);

    @Operation(summary = "通过id更新用户")
    @RestResource(path = "update")
    @Modifying
    @Transactional
    @Query("UPDATE User SET name = :name, age = :age, gender = :gender WHERE id = :id")
    void update(Integer id, String name, Integer age, Integer gender);

    @Operation(summary = "通过ID查找User的openid")
    @RestResource(path = "findOpenidByUserId")
    @Query("SELECT openId FROM User WHERE id = :id")
    String findOpenidByUserId(Integer id);

    @Operation(summary = "是否存在openid")
    @RestResource(path = "existsByOpenId")
    boolean existsByOpenId(String openid);
}
