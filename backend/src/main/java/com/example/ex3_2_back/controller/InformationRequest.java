package com.example.ex3_2_back.controller;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;

public class InformationRequest {
    private Integer userId;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime timestamp;

    private Integer heartRate;
    private Integer sao2;
    private Float height;
    private Float weight;
    private Float pressure;
    private Integer glucoType;

    // Getters and setters
    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public Integer getHeartRate() {
        return heartRate;
    }

    public void setHeartRate(Integer heartRate) {
        this.heartRate = heartRate;
    }

    public Integer getSao2() {
        return sao2;
    }

    public void setSao2(Integer sao2) {
        this.sao2 = sao2;
    }

    public Float getHeight() {
        return height;
    }

    public void setHeight(Float height) {
        this.height = height;
    }

    public Float getWeight() {
        return weight;
    }

    public void setWeight(Float weight) {
        this.weight = weight;
    }

    public Float getPressure() {
        return pressure;
    }

    public void setPressure(Float pressure) {
        this.pressure = pressure;
    }

    public Integer getGlucoType() {
        return glucoType;
    }

    public void setGlucoType(Integer glucoType) {
        this.glucoType = glucoType;
    }
}
