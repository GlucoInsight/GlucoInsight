package com.example.ex3_2_back.service;

import com.example.ex3_2_back.entity.Diet;
import com.example.ex3_2_back.entity.Gluco;
import com.example.ex3_2_back.entity.User;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class DietService {

    private final FlaskService flaskService;
    private final ObjectMapper objectMapper;

    public DietService(FlaskService flaskService, ObjectMapper objectMapper) {
        this.flaskService = flaskService;
        this.objectMapper = objectMapper;
    }

    public List<Diet> predictDiet(List<Gluco> glucoList, Integer userId) throws IOException {
        ResponseEntity<String> response = flaskService.callFlaskEndpoint(glucoList, "/predict_nutrients");
        String responseBody = response.getBody();

        List<Diet> dietList = new ArrayList<>();
        JsonNode rootNode = objectMapper.readTree(responseBody);

        if (rootNode.isArray()) {
            for (JsonNode node : rootNode) {
                LocalDateTime startTime = LocalDateTime.parse(node.get("timestamp_start").asText());
                LocalDateTime endTime = LocalDateTime.parse(node.get("timestamp_end").asText());
                Float protein = Float.parseFloat(node.get("protein").asText());
                Float fat = Float.parseFloat(node.get("fat").asText());
                Float carbohydrate = Float.parseFloat(node.get("carbohydrate").asText());

                User user = new User();
                user.setId(userId);

                Diet diet = Diet.builder()
                        .user(user)
                        .startTime(startTime)
                        .endTime(endTime)
                        .protein(protein)
                        .fat(fat)
                        .carbohydrate(carbohydrate)
                        .build();

                dietList.add(diet);
            }
        }

        return dietList;
    }
}