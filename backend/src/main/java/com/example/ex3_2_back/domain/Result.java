package com.example.ex3_2_back.domain;

import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Builder
@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
@EqualsAndHashCode
public class Result {
    private boolean success;
    private String message;
    private Object data;
    public final List<Object> errors = new ArrayList<>();
    public final List<Object> devMessages = new ArrayList<>();

    public static Result success() {
        return Result.builder().success(true).build();
    }

    public static Result success(Object data) {
        return Result.builder().success(true).data(data).build();
    }

    public static Result error(String message) {
        return Result.builder().success(false).message(message).build();
    }

    public Result addErrors(Object error) {
        errors.add(error);
        return this;
    }

    public Result addDevMessages(Object devMessage) {
        devMessages.add(devMessage);
        return this;
    }

}
