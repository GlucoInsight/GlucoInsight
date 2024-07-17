package com.example.ex3_2_back.controller;

import cn.hutool.json.JSONObject;
import com.example.ex3_2_back.domain.PredictRequestAndReturn;
import com.example.ex3_2_back.domain.Result;
import com.example.ex3_2_back.entity.Diet;
import com.example.ex3_2_back.entity.Gluco;
import com.example.ex3_2_back.entity.Information;
import com.example.ex3_2_back.entity.User;
import com.example.ex3_2_back.repository.DietRepository;
import com.example.ex3_2_back.repository.GlucoRepository;
import com.example.ex3_2_back.repository.InformationRepository;
import com.example.ex3_2_back.repository.UserRepository;
import com.example.ex3_2_back.service.FlaskService;
import io.swagger.v3.oas.annotations.Operation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;

@RestController
@RequestMapping("/gluco")
public class GlucoController {
    private UserRepository userRepository;
    private GlucoRepository glucoRepository;
    private InformationRepository informationRepository;
    private DietRepository dietRepository;

    @Autowired
    private FlaskService flaskService;

    @Autowired
    public void setUserRepository(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Autowired
    public void setGlucoRepository(GlucoRepository glucoRepository) {
        this.glucoRepository = glucoRepository;
    }

    @Autowired
    public void setInformationRepository(InformationRepository informationRepository) {
        this.informationRepository = informationRepository;
    }

    @Autowired
    public void setDietRepository(DietRepository dietRepository) {
        this.dietRepository = dietRepository;
    }

    @GetMapping
    @Operation(summary = "通过用户获取所有血糖信息", description = "通过用户获取所有血糖信息")
    public Result getGluco(@RequestParam("user_id") Integer userId) {
        User user = userRepository.findById(userId).orElse(null);
        try {
            return Result.success(glucoRepository.findByUser(user));
        } catch (Exception e) {
            return Result.error(e.getMessage()).addErrors(e);
        }
    }

    @GetMapping("/latest")
    @Operation(summary = "通过用户获取最新24h内的血糖信息", description = "通过用户获取最新24h内的血糖信息")
    public Result getLatestGluco(@RequestParam("user_id") Integer userId) {
        User user = userRepository.findById(userId).orElse(null);
        try {
            // 获取当前时间
            LocalDateTime now = LocalDateTime.now().atZone(ZoneId.systemDefault()).toLocalDateTime();
            // 获取24h前的时间
            LocalDateTime yesterday = now.minusDays(1);
            return Result.success(glucoRepository.findByUserAndTimestampBetween(user, yesterday, now));
        } catch (Exception e) {
            return Result.error(e.getMessage()).addErrors(e);
        }
    }

    @GetMapping("/day")
    @Operation(summary = "通过用户和精确到日期的时间获取当天血糖信息", description = "通过用户和精确到日期的时间获取当天血糖信息")
    public Result getGlucoByDay(@RequestParam("user_id") Integer userId, @RequestParam("day") String day) {
        User user = userRepository.findById(userId).orElse(null);
        try {
            // 将精确到日期的时间转换为当天的时间段范围
            LocalDateTime[] range = getTimestampRange(day);
            return Result.success(glucoRepository.findByUserAndTimestampBetween(user, range[0], range[1]));
        } catch (Exception e) {
            return Result.error(e.getMessage()).addErrors(e);
        }
    }

    public static LocalDateTime[] getTimestampRange(String dateString) {
        // 定义日期格式
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");

        // 将字符串解析为LocalDate
        LocalDate date = LocalDate.parse(dateString, formatter);

        // 获取当天的开始时间（00:00:00）
        LocalDateTime startOfDay = date.atStartOfDay();

        // 获取当天的结束时间（23:59:59.999999999）
        LocalDateTime endOfDay = date.atTime(23, 59, 59, 999_999_999);

        // 将LocalDateTime转换为时间戳
        LocalDateTime startTimestamp = startOfDay.atZone(ZoneId.systemDefault()).toLocalDateTime();
        LocalDateTime endTimestamp = endOfDay.atZone(ZoneId.systemDefault()).toLocalDateTime();

        return new LocalDateTime[]{startTimestamp, endTimestamp};
    }

    @GetMapping("/predict")
    @Operation(summary = "通过用户获取血糖预测接下来6小时内的血糖", description = "通过用户获取血糖预测接下来6小时内的血糖")
    public Result getGlucoPredict(@RequestParam("user_id") Integer userId) {
        User user = userRepository.findById(userId).orElse(null);
        try {
            // 获取当前时间
            LocalDateTime now = LocalDateTime.now().atZone(ZoneId.systemDefault()).toLocalDateTime();
            // 获取24小时内的数据
            LocalDateTime yesterday = now.minusDays(1);
            List<PredictRequestAndReturn> yestdayGluco = glucoRepository.findGlucoValueByUserAndTimestampBetween(user, yesterday, now);
            List<PredictRequestAndReturn> predictGluco = predict(yestdayGluco);
            return Result.success(predictGluco);
        } catch (Exception e) {
            return Result.error(e.getMessage()).addErrors(e);
        }
    }


    public List<PredictRequestAndReturn> predict(List<PredictRequestAndReturn> glucoList) throws IOException {
        ResponseEntity<String> response = flaskService.callFlaskEndpoint(glucoList, "/predict_gluco");
        JSONObject jsonObject = new JSONObject(response.getBody());
        List<PredictRequestAndReturn> predictGluco = jsonObject.getJSONArray("predict_gluco").toList(PredictRequestAndReturn.class);
        return predictGluco;
    }

    @GetMapping("/gluco_type")
    @Operation(summary = "通过用户获取血糖类型", description = "通过用户获取血糖类型")
    public Result getGlucoType(@RequestParam("user_id") Integer userId) {
        User user = userRepository.findById(userId).orElse(null);
        try {
            // 获取24小时内的数据
            LocalDateTime now = LocalDateTime.now().atZone(ZoneId.systemDefault()).toLocalDateTime();
            LocalDateTime yesterday = now.minusDays(1);
            List<PredictRequestAndReturn> glucoList = glucoRepository.findGlucoValueByUser(user);
            Information lastInformation = informationRepository.findByUser(user).get(0);
            // predict gluco type
            Integer glucoType = predictGlucoType(user.getAge(), lastInformation.getWeight(), lastInformation.getHeight(), glucoList);
            // 添加Information

            Information information = Information.builder()
                    .user(user)
                    .timestamp(now)
                    .heartRate(lastInformation.getHeartRate())
                    .sao2(lastInformation.getSao2())
                    .height(lastInformation.getHeight())
                    .weight(lastInformation.getWeight())
                    .pressure(lastInformation.getPressure())
                    .glucoType(glucoType)
                    .build();
            informationRepository.save(information);

            return Result.success(glucoType);
        } catch (Exception e) {
            return Result.error(e.getMessage()).addErrors(e);
        }
    }

    private Integer predictGlucoType(Integer age, Float weight, Float height, List<PredictRequestAndReturn> glucoList) throws IOException {
        Float bmi = weight / (height * height);
        // 将age, bmi和glucoList合并在一起为一个JSON
        JSONObject requestBody = new JSONObject();
        requestBody.put("age", age);
        requestBody.put("bmi", bmi);
        requestBody.put("glucoList", glucoList);
        ResponseEntity<String> response = flaskService.callFlaskEndpoint(requestBody, "/predict_gluco_type");

        JSONObject jsonObject = new JSONObject(response.getBody());
        Integer glucoType = jsonObject.getInt("data");
        return glucoType;
    }


    @PostMapping("/add")
    @Operation(summary = "添加血糖信息", description = "添加血糖信息")
    public Result addGluco(@RequestParam("user_id") Integer userId,
                           @RequestParam("raw_data") String rawData) {
        User user = userRepository.findById(userId).orElse(null);
        try {
            // 解析原始数据
            List<Gluco> glucoList = parseRawData(user, rawData);
            assert glucoList != null;
            glucoRepository.saveAll(glucoList);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage()).addErrors(e);
        }
    }

    private List<Gluco> parseRawData(User user, String rawData) {
        // TODO: Parse Raw Data
        return null;
    }

    @PostMapping("/predict_diet")
    @Operation(summary = "通过用户获取饮食", description = "通过用户获取饮食")
    public Result addDiet(@RequestParam("user_id") Integer userId) {
        User user = userRepository.findById(userId).orElse(null);
        try {
            LocalDateTime lastEndTime = null;
            // 如果存在，获取上次饮食信息，没有则设为时间戳最开始
            if (dietRepository.findByUser(user).isEmpty()) {
                lastEndTime = LocalDateTime.of(1970, 1, 1, 0, 0, 0);
            }
            lastEndTime = dietRepository.findByUser(user).get(0).getEndTime();
            // 获取当前时间
            LocalDateTime now = LocalDateTime.now().atZone(ZoneId.systemDefault()).toLocalDateTime();

            List<Gluco> glucoList = glucoRepository.findByUserAndTimestampBetween(user, lastEndTime, now);
            // predict diet
            List<Diet> dietList = predictDiet(glucoList);
            // 添加Diet
            dietRepository.saveAll(dietList);
            return Result.success(dietList);
        } catch (Exception e) {
            return Result.error(e.getMessage()).addErrors(e);
        }
    }

    private List<Diet> predictDiet(List<Gluco> glucoList) throws IOException {
        ResponseEntity<String> response = flaskService.callFlaskEndpoint(glucoList, "/predict_diet");
        JSONObject jsonObject = new JSONObject(response.getBody());
        List<Diet> dietList = jsonObject.getJSONArray("predict_diet").toList(Diet.class);
        return dietList;
    }
}
