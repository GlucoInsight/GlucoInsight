

# 实现输入8小时CGM数据并返回是否存在饮食事件和重合度最高的3小时窗口的开始和结束时间
def identify_meal_event(cgm_readings, timestamps, model, scaler):
    step_size = 5
    best_probability = 0
    best_window = None

    for start in range(0, len(cgm_readings) - 36 + 1, step_size):
        end = start + 36
        sub_window = cgm_readings[start:end]
        sub_window_cleaned = clean_and_convert_to_float(sub_window)
        features = extract_features([sub_window_cleaned]).iloc[0].tolist()
        features_scaled = scaler.transform([features])
        probability = model.predict_proba(features_scaled)[0][1]
        
        if probability > best_probability:
            best_probability = probability
            best_window = (timestamps[start], timestamps[end-1])
                
    if best_probability > 0.5:
        return True, best_window
    else:
        return False, None

# 测试函数
cgm_readings = [80] * 96  # 示例CGM数据
timestamps = pd.date_range(start='2024-07-16 08:00:00', periods=96, freq='5T').tolist()
meal_event, window = identify_meal_event(cgm_readings, timestamps, best_rf_model, scaler)
print(f"Meal Event: {meal_event}, Window: {window}")
