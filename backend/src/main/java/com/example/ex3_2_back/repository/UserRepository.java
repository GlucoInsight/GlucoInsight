package com.example.ex3_2_back.repository;

import com.example.ex3_2_back.entity.User;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.data.rest.core.annotation.RestResource;

import java.util.Optional;


@RepositoryRestResource(path = "UserRepository")
@Tag(name = "数据库User接口")
public interface UserRepository extends JpaRepository<User, String> {
    @Operation(summary = "通过用户名查找")
    @RestResource(path = "findByName")
    Optional<User> findByName(String name);


    @Operation(summary = "通过用户名删除用户")
    @RestResource(path = "deleteByName")
    void deleteByName(String name);
}
