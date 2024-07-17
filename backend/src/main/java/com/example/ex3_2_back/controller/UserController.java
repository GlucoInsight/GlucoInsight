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

    @GetMapping("/login")
    @Operation(summary = "通过id登录, 没有则添加id在登录返回其ID", description = "通过id登录, 没有则添加id在登录返回其ID")
    public Result login(@RequestBody User user) {
        if (userRepository.existsByOpenId(user.getOpenId())) {
            return Result.success(user.getId());
        } else {
            try {
                userRepository.save(user);
                return Result.success(user.getId());
            } catch (Exception e) {
                return Result.error(e.getMessage()).addErrors(e);
            }
        }
    }

    @PostMapping("/update")
    @Operation(summary = "更新用户信息", description = "更新用户信息")
    public Result update(@RequestBody User user) {
        try {
            userRepository.update(user.getId(), user.getName(), user.getAge(), user.getGender());
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage()).addErrors(e);
        }
    }
}
