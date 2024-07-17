package com.example.ex3_2_back.domain;

import java.time.LocalDateTime;

public class PredictRequestAndReturn {
        LocalDateTime timestamp;
        Float predictGluco;

        public PredictRequestAndReturn(LocalDateTime timestamp, Float predictGluco) {
            this.timestamp = timestamp;
            this.predictGluco = predictGluco;
        }

        public LocalDateTime getTimestamp() {
            return timestamp;
        }

        public void setTimestamp(LocalDateTime timestamp) {
            this.timestamp = timestamp;
        }

        public Float getPredictGluco() {
            return predictGluco;
        }

        public void setPredictGluco(Float predictGluco) {
            this.predictGluco = predictGluco;
        }
    }