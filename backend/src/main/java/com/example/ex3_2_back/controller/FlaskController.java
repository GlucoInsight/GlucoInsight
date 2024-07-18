package com.example.ex3_2_back.controller;

import cn.hutool.json.JSONObject;
import com.example.ex3_2_back.service.FlaskService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;

@RestController
@RequestMapping("/flask")
public class FlaskController {

    @Autowired
    private FlaskService flaskService;

    @PostMapping("/test")
    public ResponseEntity<String> callFlask(@RequestBody String requestData) throws IOException {
        return flaskService.callFlaskEndpoint(requestData, "/test");
    }

    @PostMapping("/gpt_call_test")
    public ResponseEntity<String> callFlaskGpt(@RequestBody String requestData) throws IOException {
        return flaskService.callFlaskEndpoint(requestData, "/chatgpt");
    }
}