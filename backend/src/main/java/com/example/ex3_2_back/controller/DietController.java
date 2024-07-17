package com.example.ex3_2_back.controller;

import com.example.ex3_2_back.domain.Result;
import com.example.ex3_2_back.entity.User;
import com.example.ex3_2_back.repository.DietRepository;
import com.example.ex3_2_back.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/diet")
public class DietController {
    private DietRepository dietRepository;
    private UserRepository userRepository;

    @Autowired
    @Operation(summary = "setDietRepository", description = "setDietRepository")
    public void setDietRepository(DietRepository dietRepository) {
        this.dietRepository = dietRepository;
    }

    @Autowired
    @Operation(summary = "setUserRepository", description = "setUserRepository")
    public void setUserRepository(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping
    @Operation(summary = "通过用户获取所有饮食信息", description = "通过用户获取所有饮食信息")
    public Result getDiet(@RequestParam("user_id") Integer userId) {
        User user = userRepository.findById(userId).orElse(null);
        try {
            return Result.success(dietRepository.findByUser(user));
        } catch (Exception e) {
            return Result.error(e.getMessage()).addErrors(e);
        }
    }



}
