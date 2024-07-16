package com.example.ex3_2_back.utils;


import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
@Slf4j
public class JwtUtilTests {
    private MyJwtUtil jwtUtil;

    @Autowired
    public void setJwtUtil(MyJwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Test
    public void testGenerateToken() {
        var token = jwtUtil.createToken("user", Integer.MAX_VALUE);
        log.info(token);
    }
}