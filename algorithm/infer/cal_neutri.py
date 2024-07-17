import pandas as pd
import numpy as np
from scipy.integrate import trapz
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import tensorflow as tf
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, LSTM, Dense
import pickle


# 加载模型和标准化器
def load_model():
    with open('model_weights.pkl', 'rb') as f:
        model_weights = pickle.load(f)

    with open('scaler_params.pkl', 'rb') as f:
        scaler_params = pickle.load(f)

    scaler = StandardScaler()
    scaler.mean_ = np.array(scaler_params['mean'])
    scaler.scale_ = np.array(scaler_params['scale'])

    input_layer = Input(shape=(10, 1))
    lstm_layer = LSTM(128, return_sequences=True)(input_layer)
    lstm_layer = LSTM(64)(lstm_layer)

    fat_output = Dense(1, name='fat')(lstm_layer)
    carb_output = Dense(1, name='carbohydrates')(lstm_layer)
    protein_output = Dense(1, name='protein')(lstm_layer)

    model = Model(inputs=input_layer, outputs=[fat_output, carb_output, protein_output])
    model.compile(optimizer='adam', loss='mse')
    model.set_weights(model_weights)

    return model, scaler

model, scaler = load_model()

# 清理血糖值的函数
def clean_glucose_values(glucose_values):
    cleaned_values = []
    valid_values = []

    for value in glucose_values:
        try:
            int_value = int(value)
            cleaned_values.append(int_value)
            valid_values.append(int_value)
        except ValueError:
            cleaned_values.append(None)
    
    mean_value = int(np.mean(valid_values))
    cleaned_values = [mean_value if v is None else v for v in cleaned_values]
    
    return cleaned_values

# 特征提取函数
def extract_features(glucose_values):
    if len(glucose_values) < 36:
        glucose_values.extend([glucose_values[-1]] * (36 - len(glucose_values)))
    elif len(glucose_values) > 36:
        glucose_values = glucose_values[:36]
    
    auc_0_15 = trapz(glucose_values[:6], dx=1)
    auc_15_30 = trapz(glucose_values[6:12], dx=1)
    auc_30_60 = trapz(glucose_values[12:24], dx=1)
    auc_60_120 = trapz(glucose_values[24:32], dx=1)
    auc_120_150 = trapz(glucose_values[32:36], dx=1)
    auc_150_180 = trapz(glucose_values[36:], dx=1)

    max_glucose = np.max(glucose_values)
    min_glucose = np.min(glucose_values)
    mean_glucose = np.mean(glucose_values)
    std_glucose = np.std(glucose_values)

    return [auc_0_15, auc_15_30, auc_30_60, auc_60_120, auc_120_150, auc_150_180, max_glucose, min_glucose, mean_glucose, std_glucose]

# 训练模型函数
def train_model(data_path):
    data = pd.read_csv(data_path, sep='\t')
    grouped_data = data.groupby(['userID', 'Meal']).agg({'GlucoseValue': list}).reset_index()
    grouped_data['GlucoseValue'] = grouped_data['GlucoseValue'].apply(clean_glucose_values)
    grouped_data['Features'] = grouped_data['GlucoseValue'].apply(extract_features)

    meal_nutrients_corrected = {
        'PB': [20, 51, 18],
        'CF': [18, 48, 9],
        'Bar': [25, 54, 11]
    }

    target_values = grouped_data[['Meal', 'userID']].copy()
    target_values[['Fat', 'Carbohydrates', 'Protein']] = target_values['Meal'].apply(lambda x: meal_nutrients_corrected[x.split()[0]]).tolist()
    combined_data = pd.concat([grouped_data[['userID', 'Features']], target_values[['Fat', 'Carbohydrates', 'Protein']]], axis=1)

    X = np.array(combined_data['Features'].tolist())
    y = combined_data[['Fat', 'Carbohydrates', 'Protein']].values

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    scaler = StandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_test = scaler.transform(X_test)

    X_train_lstm = X_train.reshape((X_train.shape[0], X_train.shape[1], 1))
    X_test_lstm = X_test.reshape((X_test.shape[0], X_test.shape[1], 1))

    input_layer = Input(shape=(X_train_lstm.shape[1], X_train_lstm.shape[2]))
    lstm_layer = LSTM(128, return_sequences=True)(input_layer)
    lstm_layer = LSTM(64)(lstm_layer)

    fat_output = Dense(1, name='fat')(lstm_layer)
    carb_output = Dense(1, name='carbohydrates')(lstm_layer)
    protein_output = Dense(1, name='protein')(lstm_layer)

    model = Model(inputs=input_layer, outputs=[fat_output, carb_output, protein_output])
    model.compile(optimizer='adam', loss='mse')

    model.fit(X_train_lstm, [y_train[:, 0], y_train[:, 1], y_train[:, 2]], epochs=300, batch_size=32, validation_split=0.2, verbose=1)

    # 保存模型权重
    with open('model_weights.pkl', 'wb') as f:
        pickle.dump(model.get_weights(), f)
    
    # 保存标准化器
    scaler_params = {'mean': scaler.mean_.tolist(), 'scale': scaler.scale_.tolist()}
    with open('scaler_params.pkl', 'wb') as f:
        pickle.dump(scaler_params, f)

    return model, scaler



# 预测函数
def nutrients_predict(glucose_values):
    glucose_values = clean_glucose_values(glucose_values)
    features = extract_features(glucose_values)
    features = scaler.transform([features])
    features_lstm = features.reshape((features.shape[0], features.shape[1], 1))
    predictions = model.predict(features_lstm)
    return predictions

# 示例应用
# if __name__ == "__main__":
#     start_time = '2021-01-01 08:00:00'
#     end_time = '2021-01-01 10:00:00'
#     glucose_values = [100, 105, 110, 120, 115, 108, 112, 115, 120, 130, 125, 128, 135, 140, 145, 142, 138, 135, 130, 128, 125, 120, 115, 110, 105, 102, 100, 98, 95, 92, 90, 88, 85, 82, 80, 78]
#
#     predictions = nutrients_predict(model, scaler, glucose_values)
#     print(f"预测的营养素: 蛋白质: {predictions[2][0][0]:.2f}g, 脂肪: {predictions[0][0][0]:.2f}g, 碳水化合物: {predictions[1][0][0]:.2f}g")
#
#     print("模型权重已保存为 'model_weights.pkl'")
#     print("标准化器参数已保存为 'scaler_params.pkl'")
