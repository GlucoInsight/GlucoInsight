import pickle
import pandas as pd
import os

PATH = os.path.dirname(os.path.abspath(__file__))


# 加载模型
with open(os.path.join(PATH, 'clf_sensitivity.pkl'), 'rb') as f:
    clf_sensitivity = pickle.load(f)
with open(os.path.join(PATH, 'clf_beta.pkl'), 'rb') as f:
    clf_beta = pickle.load(f)

# 预处理输入数据
def preprocess_input(age, bmi, cgm_time_series):
    fbg = sum(cgm_time_series[:3]) / 3  # 取时序数据的前三个数据点做均值处理后当作FBG
    return [age, bmi, fbg]

# 加载模型并进行预测
def glucotype_predict(age, bmi, cgm_time_series):
    # 预处理输入
    processed_input = preprocess_input(age, bmi, cgm_time_series)
    input_df = pd.DataFrame([processed_input], columns=['Age_x', 'BMI_x', 'FBG_x'])
    

    # 预测 sensitivity_C_type 和 Beta_c_type
    sensitivity_pred = clf_sensitivity.predict(input_df)[0]
    beta_pred = clf_beta.predict(input_df)[0]
    
    # 组合预测结果
    if sensitivity_pred == 1 and beta_pred == 1:
        homa_type_pred = 0  # Low_Low
    elif sensitivity_pred == 1 and beta_pred == 0:
        homa_type_pred = 1  # Low_High
    elif sensitivity_pred == 0 and beta_pred == 1:
        homa_type_pred = 2  # High_Low
    else:
        homa_type_pred = 3  # High_High
    
    return homa_type_pred

# 示例测试
# age = 30
# bmi = 25
# cgm_time_series = [85, 90, 88]  # 示例CGM时序数据
# predicted_homa_type = load_models_and_predict(age, bmi, cgm_time_series)
# print("Predicted HOMA_type (binary):", predicted_homa_type)
