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
public class TResult<T> {
    private boolean success;
    private String message;
    private T data;
    public final List<Object> errors = new ArrayList<>();

    public static <U> TResult<U> success() {
        return TResult.<U>builder().success(true).build();
    }

    public static <U> TResult<U> success(U data) {
        return TResult.<U>builder().success(true).data(data).build();
    }

    public static <U> TResult<U> error(String message) {
        return TResult.<U>builder().success(false).message(message).build();
    }

    public TResult<T> addErrors(Object error) {
        errors.add(error);
        return this;
    }
}
