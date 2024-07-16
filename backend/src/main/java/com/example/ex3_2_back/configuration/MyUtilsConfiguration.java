package com.example.ex3_2_back.configuration;

import com.example.ex3_2_back.utils.MyJwtUtil;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MyUtilsConfiguration {
    @Bean
    public MyJwtUtil jwtUtil() {
        return new MyJwtUtil();
    }
}
