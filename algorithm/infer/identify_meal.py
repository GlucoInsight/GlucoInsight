import numpy as np
import pandas as pd
import joblib
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier

# 导入模型和标准化器
def load_models():
    scaler = joblib.load('scaler.pkl')
    lr_model = joblib.load('lr_model.pkl')
    rf_model = joblib.load('rf_model.pkl')
    return scaler, lr_model, rf_model

# 数据清理函数
def clean_and_convert_to_float(series):
    clean_series = []
    for value in series:
        try:
            clean_series.append(float(value))
        except ValueError:
            clean_series.append(np.nan)
    return clean_series

# 特征提取函数
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


# 识别饮食模式函数，支持返回多个非交叉的3小时窗口，至少间隔1小时
def meal_pattern_multiple_identify(cgm_readings, timestamps, model='rf'):
    """
    识别饮食模式，支持返回多个非交叉的3小时窗口，至少间隔1小时
    :param cgm_readings: CGM读数（8小时窗口，每5分钟一个读数，共96个读数）
    :param timestamps: 时间戳
    :param model: 使用的模型（'lr'或'rf'）
    :return: 饮食开始和结束时间的时间戳列表（3小时窗口）
    """
    window_size = 36  # 每3小时窗口包含36个读数（3小时 * 60分钟 / 5分钟）
    step_size = 5  # 滑动步长
    threshold = 0.5  # 预测概率阈值

    scaler, lr_model, rf_model = load_models()
    meal_windows = []

    for start in range(0, len(cgm_readings) - window_size + 1, step_size):
        end = start + window_size
        sub_window = cgm_readings[start:end]
        sub_timestamps = timestamps[start:end]
        
        # 提取特征并进行预测
        sub_window_cleaned = clean_and_convert_to_float(sub_window)
        features = np.array(extract_features([sub_window_cleaned])).reshape(1, -1)
        features = pd.DataFrame(features, columns=['mean', 'std', 'min', 'max', 'median', '25_percentile', '75_percentile'])
        features = scaler.transform(features)
        
        if model == 'lr':
            prediction = lr_model.predict_proba(features)[0][1]
        else:
            prediction = rf_model.predict_proba(features)[0][1]
        
        if prediction >= threshold:
            meal_windows.append((sub_timestamps[0], sub_timestamps[-1], prediction))
    
    # 去除重叠窗口，返回概率最高的非交叉窗口
    if meal_windows:
        meal_windows = sorted(meal_windows, key=lambda x: x[2], reverse=True)
        non_overlapping_windows = [meal_windows[0]]
        for current_window in meal_windows[1:]:
            overlap = False
            for selected_window in non_overlapping_windows:
                if not (current_window[0] >= selected_window[1] + pd.Timedelta(hours=1) or current_window[1] <= selected_window[0]):
                    overlap = True
                    break
            if not overlap:
                non_overlapping_windows.append(current_window)
        return [(win[0], win[1]) for win in non_overlapping_windows]

    return []

# 示例调用
if __name__ == "__main__":
    # 假设这是8小时的CGM时间序列数据
    cgm_readings = np.random.rand(96) * 100  # 示例数据
    timestamps = pd.date_range(start='2024-07-16 08:00:00', periods=96, freq='5T').tolist()
    
    # 调用识别函数
    meal_times = identify_meal_pattern_multiple(cgm_readings, timestamps, model='rf')
    print(meal_times)
