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
@Table(name = "information")
@Schema(description = "information of user")
public class Information {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "information_id")
    Integer id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    User user;

    @Column(name = "timestamp", nullable = false)
    LocalDateTime timestamp;

    @Column(name = "heart_rate")
    Integer heartRate;

    @Column(name = "sao2")
    Integer sao2;

    @Column(name = "height")
    Float height;

    @Column(name = "weight")
    Float weight;

    @Column(name = "pressure")
    Float pressure;

    @Column(name = "gluco_type")
    Integer glucoType;


}
