package com.example.ex3_2_back.controller;

import com.example.ex3_2_back.domain.Result;
import io.swagger.v3.oas.annotations.Operation;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MyErrorController implements ErrorController {
    @RequestMapping("/error")
    @Operation(summary = "返回error",description = "返回error")
    public Result error() {
        return Result.error("error from " + getClass().getName());
    }
}