package com.example.ex3_2_back.controller;

import com.example.ex3_2_back.domain.Result;
import com.example.ex3_2_back.entity.Information;
import com.example.ex3_2_back.entity.User;
import com.example.ex3_2_back.repository.InformationRepository;
import com.example.ex3_2_back.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Optional;


@RestController
@RequestMapping("/information")
public class InformationController {
    private InformationRepository informationRepository;
    private UserRepository userRepository;

    @Autowired
    @Operation(summary = "setInformationRepository", description = "setInformationRepository")
    public void setInformationRepository(InformationRepository informationRepository) {
        this.informationRepository = informationRepository;
    }

    @Autowired
    @Operation(summary = "setUserRepository", description = "setUserRepository")
    public void setUserRepository(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping
    @Operation(summary = "通过用户获取所有信息", description = "通过用户获取所有信息")
    public Result getInformation(@RequestParam("user_id") Integer userId) {
        User user = userRepository.findById(userId).orElse(null);
        try {
            return Result.success(informationRepository.findByUser(user));
        } catch (Exception e) {
            return Result.error(e.getMessage()).addErrors(e);
        }
    }

    @GetMapping("/latest")
    @Operation(summary = "通过用户获取最新信息", description = "通过用户获取最新信息")
    public Result getLatestInformation(@RequestParam("user_id") Integer userId) {
        User user = userRepository.findById(userId).orElse(null);
        try {
            return Result.success(informationRepository.findByUser(user).get(0));
        } catch (Exception e) {
            return Result.error(e.getMessage()).addErrors(e);
        }
    }

    @PostMapping
    @Operation(summary = "添加信息", description = "添加信息")
    public Result addInformation(@RequestBody InformationRequest request) {
        try {
            Optional<User> userOptional = userRepository.findById(request.getUserId());
            if (!userOptional.isPresent()) {
                return Result.error("User not found").addErrors(new Exception("User not found"));
            }
            User user = userOptional.get();
            Information information = Information.builder()
                    .user(user)
                    .timestamp(request.getTimestamp())
                    .heartRate(request.getHeartRate())
                    .sao2(request.getSao2())
                    .height(request.getHeight())
                    .weight(request.getWeight())
                    .pressure(request.getPressure())
                    .glucoType(request.getGlucoType())
                    .build();
            informationRepository.save(information);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage()).addErrors(e);
        }
    }
}

