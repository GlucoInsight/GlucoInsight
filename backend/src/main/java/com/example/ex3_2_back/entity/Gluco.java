package com.example.ex3_2_back.entity;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Builder
@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Entity
@Table(name = "gluco")
@Schema(description = "information of user")
public class Gluco {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "gluco_id")
    Integer id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    User user;

    @Column(name = "timestamp", nullable = false)
    LocalDateTime timestamp;

    @Column(name = "gluco_value")
    Integer glucoValue;

}
