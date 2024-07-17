package com.example.ex3_2_back.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;

@Service
public class FlaskService {

    @Autowired
    private RestTemplate restTemplate;

    private final String flaskUrl = "http://localhost:5000/api"; // Flask后端url

    public ResponseEntity<String> callFlaskEndpoint(Object requestData, String apiUrl) throws IOException {
        String url = flaskUrl + apiUrl;

        // 使用ObjectMapper将对象转换为JSON字符串
        ObjectMapper objectMapper = new ObjectMapper();
        String jsonRequestData = objectMapper.writeValueAsString(requestData);

        // 设置请求头
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // 创建HttpEntity对象，包含请求头和请求体
        HttpEntity<String> requestEntity = new HttpEntity<>(jsonRequestData, headers);

        // 发送POST请求
        ResponseEntity<String> response = restTemplate.postForEntity(url, requestEntity, String.class);

        return response;
    }

}
