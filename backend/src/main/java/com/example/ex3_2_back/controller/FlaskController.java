package com.example.ex3_2_back.controller;

import com.example.ex3_2_back.service.FlaskService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class FlaskController {

    @Autowired
    private FlaskService flaskService;

    @PostMapping("/call-flask")
    public String callFlask(@RequestBody String requestData) {
        return flaskService.callFlaskEndpoint(requestData);
    }
}