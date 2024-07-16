package com.example.ex3_2_back.repository;

import com.example.ex3_2_back.entity.Information;
import com.example.ex3_2_back.entity.User;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.data.rest.core.annotation.RestResource;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@RepositoryRestResource(path = "InformationRepository")
@Tag(name = "数据库Inforamtion接口")
public interface InformationRepository extends JpaRepository<Information, String> {

    @Operation(summary = "通过用户ID查找信息按时间戳从后到前排序")
    @RestResource(path = "findByUserId")
    @Query("SELECT i FROM Information i WHERE i.user = :user ORDER BY i.timestamp DESC")
    List<Information> findByUser(User user);

}
