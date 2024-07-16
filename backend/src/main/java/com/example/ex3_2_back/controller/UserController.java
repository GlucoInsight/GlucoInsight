package com.example.ex3_2_back.controller;

import com.example.ex3_2_back.entity.User;
import com.example.ex3_2_back.domain.Result;
import com.example.ex3_2_back.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/user")
public class UserController {
    private UserRepository userRepository;

    @Autowired
    @Operation(summary = "setUserRepository", description = "setUserRepository")
    public void setUserRepository(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping
    @Operation(summary = "查询所有用户", description = "查询所有用户")
    public Result all() {
        return Result.success(userRepository.findAll());
    }

    @GetMapping("/{name}")
    @Operation(summary = "查询单个用户", description = "查询单个用户")
    public Result one(@PathVariable String name) {
        return Result.success(userRepository.findByName(name));
    }

    @PostMapping
    @Operation(summary = "创建用户", description = "创建用户")
    public Result create(@RequestBody User user) {
        try {
            userRepository.save(user);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage()).addErrors(e);
        }
    }

    @DeleteMapping("/{name}")
    @Operation(summary = "删除用户",description = "删除用户")
    public Result delete(@PathVariable String name) {
        try {
            userRepository.deleteByName(name);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage()).addErrors(e);
        }
    }

}
