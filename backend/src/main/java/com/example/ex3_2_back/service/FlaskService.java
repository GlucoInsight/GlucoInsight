package com.example.ex3_2_back.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class FlaskService {

    @Autowired
    private RestTemplate restTemplate;

    private final String flaskUrl = "http://localhost:5000"; // Flask后端url

    public String callFlaskEndpoint(String requestData) {
        String url = flaskUrl + apiUrl;
        ResponseEntity<String> response = restTemplate.postForEntity(url, requestData, String.class);
        return response.getBody();
    }

}
