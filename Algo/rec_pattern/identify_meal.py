import numpy as np
import pandas as pd
from scipy.integrate import trapz
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import joblib


# 将'Low'值替换为前后数据点的平均值
def clean_and_convert_to_float(series):
  clean_series = []
  for i in range(len(series)):
    if series[i] == 'Low':
      if i == 0:
        clean_series.append(float(series[i + 1]))
      elif i == len(series) - 1:
        clean_series.append(float(series[i - 1]))
      else:
        clean_series.append((float(series[i - 1]) + float(series[i + 1])) / 2)
    else:
      clean_series.append(float(series[i]))
  return clean_series


# 特征提取函数，确保特征数量与训练时一致
def extract_features(data):
    features = []
    for series in data:
        series = np.array(series, dtype=float)
        series = series[~np.isnan(series)]
        if len(series) > 0:
            features.append([
                np.mean(series),
                np.std(series),
                np.min(series),
                np.max(series),
                np.median(series),
                np.percentile(series, 25),
                np.percentile(series, 75)
            ])
        else:
            features.append([np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan])
    return pd.DataFrame(features, columns=['mean', 'std', 'min', 'max', 'median', '25_percentile', '75_percentile'])
    # return np.array(features)

# 加载模型和标准化器
best_rf_model = joblib.load('best_rf_model.pkl')
scaler = joblib.load('scaler.pkl')


# 实现输入8小时CGM数据并返回是否存在饮食事件和重合度最高的3小时窗口的开始和结束时间
def identify_meal_event(cgm_readings, timestamps, model, scaler):
  step_size = 5
  best_probability = 0
  best_window = None

  for start in range(0, len(cgm_readings) - 36 + 1, step_size):
    end = start + 36
    sub_window = cgm_readings[start:end]
    sub_window_cleaned = clean_and_convert_to_float(sub_window)
    features = extract_features(sub_window_cleaned)
    features_scaled = scaler.transform([features])
    probability = model.predict_proba(features_scaled)[0][1]

    if probability > best_probability:
      best_probability = probability
      best_window = (timestamps[start], timestamps[end - 1])

  if best_probability > 0.5:
    return True, best_window
  else:
    return False, None


# 测试函数
cgm_readings = [80] * 96  # 示例CGM数据
timestamps = pd.date_range(start='2024-07-16 08:00:00', periods=96, freq='5T').tolist()
meal_event, window = identify_meal_event(cgm_readings, timestamps, best_rf_model, scaler)
print(f"Meal Event: {meal_event}, Window: {window}")
