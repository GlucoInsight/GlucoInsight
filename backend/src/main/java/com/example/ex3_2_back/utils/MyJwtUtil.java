package com.example.ex3_2_back.utils;


import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.*;

@Component
@Slf4j
public class MyJwtUtil {
    private final Algorithm algorithm = Algorithm.HMAC256("secret");

    public String createToken(String username) {
        return createToken(username, 60 * 1000);
    }

    private static final String identityKey = "t-username";

    public Optional<String> decodeToken(String token) {
        try {
            var verifier = JWT.require(algorithm).build();
            var jwt = verifier.verify(token);
            String username = jwt.getClaim(identityKey).asString();
            return Optional.of(username);
        } catch (Exception e) {
            log.error(String.format("Error decoding token: %s", e.getMessage()));
            return Optional.empty();
        }
    }

    public String createToken(String username, int seconds) {

        var calendar = Calendar.getInstance();
        var currentTime = calendar.getTime();
        calendar.add(Calendar.SECOND, seconds);
        var expirationTime = calendar.getTime();

        return JWT.create()
                .withSubject("authentication")
                .withIssuer("issuer")
                .withClaim(identityKey, username)
                .withIssuedAt(currentTime)
                .withExpiresAt(expirationTime)
                .sign(algorithm);
    }
}