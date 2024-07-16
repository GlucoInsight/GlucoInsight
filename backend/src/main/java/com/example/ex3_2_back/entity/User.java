package com.example.ex3_2_back.entity;

import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import lombok.*;

@Builder
@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Entity
@Table(name = "user")
@Schema(description = "User")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "user_id")  // 修改为数据库中对应的列名
    Integer id;

    @Column(name = "user_name", nullable = false)  // 修改为数据库中对应的列名
    @Schema(defaultValue = "Not set")
    String name;


    @Column(name = "user_age")  // 添加年龄字段，假设为整数类型
    @Schema(defaultValue = "0")
    Integer age;

    @Column(name = "user_gender")  // 修改为数据库中对应的列名
    @Schema(defaultValue = "0")
    Integer gender;

}
