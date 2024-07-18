package com.example.ex3_2_back.repository;

import com.example.ex3_2_back.controller.GlucoController;
import com.example.ex3_2_back.domain.PredictRequestAndReturn;
import com.example.ex3_2_back.entity.Gluco;
import com.example.ex3_2_back.entity.User;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.data.rest.core.annotation.RestResource;

import java.time.LocalDateTime;
import java.util.List;

@RepositoryRestResource(path = "GlucoRepository")
@Tag(name = "数据库Gluco接口")
public interface GlucoRepository extends JpaRepository<Gluco, String> {

    @Operation(summary = "通过用户查找血糖信息按时间戳从后到前排序")
    @RestResource(path = "findByUser")
    @Query("SELECT g FROM Gluco g WHERE g.user = :user ORDER BY g.timestamp DESC")
    List<Gluco> findByUser(User user);

    @Operation(summary = "通过用户和时间范围查找血糖信息按时间戳从后到前排序")
    @RestResource(path = "findByUserAndTimestampBetweenDesc")
    @Query("SELECT g FROM Gluco g WHERE g.user = :user AND g.timestamp BETWEEN :start AND :end ORDER BY g.timestamp DESC")
    List<Gluco> findByUserAndTimestampBetweenDesc(User user, LocalDateTime start, LocalDateTime end);

    @Operation(summary = "通过用户和时间范围查找血糖信息按时间戳从前到后排序")
    @RestResource(path = "findByUserAndTimestampBetween")
    @Query("SELECT g FROM Gluco g WHERE g.user = :user AND g.timestamp BETWEEN :start AND :end ORDER BY g.timestamp")
    List<Gluco> findByUserAndTimestampBetween(User user, LocalDateTime start, LocalDateTime end);


    @Operation(summary = "通过用户和时间范围查找血糖信息按时间戳从后到前排序")
    @RestResource(path = "findGlucoValueByUserAndTimestampBetweenDesc")
    @Query("SELECT new com.example.ex3_2_back.domain.PredictRequestAndReturn(g.timestamp, g.glucoValue) FROM Gluco g WHERE g.user = :user AND g.timestamp BETWEEN :yesterday AND :now ORDER BY g.timestamp DESC")
    List<PredictRequestAndReturn> findGlucoValueByUserAndTimestampBetweenDesc(User user, LocalDateTime yesterday, LocalDateTime now);

    @Operation(summary = "通过用户和时间范围查找血糖信息按时间戳从前到后排序")
    @RestResource(path = "findGlucoValueByUserAndTimestampBetween")
    @Query("SELECT new com.example.ex3_2_back.domain.PredictRequestAndReturn(g.timestamp, g.glucoValue) FROM Gluco g WHERE g.user = :user AND g.timestamp BETWEEN :yesterday AND :now ORDER BY g.timestamp")
    List<PredictRequestAndReturn> findGlucoValueByUserAndTimestampBetween(User user, LocalDateTime yesterday, LocalDateTime now);


    @Operation(summary = "通过用户查找血糖信息按时间戳从后到前排序")
    @RestResource(path = "findGlucoValueByUserDesc")
    @Query("SELECT new com.example.ex3_2_back.domain.PredictRequestAndReturn(g.timestamp, g.glucoValue) FROM Gluco g WHERE g.user = :user ORDER BY g.timestamp DESC")
    List<PredictRequestAndReturn> findGlucoValueByUserDesc(User user);

    @Operation(summary = "通过用户查找血糖信息按时间戳从前到后排序")
    @RestResource(path = "findGlucoValueByUser")
    @Query("SELECT new com.example.ex3_2_back.domain.PredictRequestAndReturn(g.timestamp, g.glucoValue) FROM Gluco g WHERE g.user = :user ORDER BY g.timestamp")
    List<PredictRequestAndReturn> findGlucoValueByUser(User user);
}
