from datetime import datetime

# 直接放到前端
def calculate_blood_glucose_metrics(glucose_data):
    # 定义血糖范围（单位: mg/dL）
    low_threshold = 70
    high_threshold = 180

    # 获取当前日期
    current_date = datetime.now().date()

    # 初始化计数器
    time_in_range = 0
    time_above_range = 0
    time_below_range = 0

    # 累计血糖值以计算平均值
    total_glucose = 0
    total_count = 0

    # 遍历血糖数据，计算各个范围的时间
    for timestamp, glucose in glucose_data:
        # 解析时间戳并检查是否为当日数据
        date = datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S').date()
        if date == current_date:
            total_glucose += glucose
            total_count += 1
            if glucose < low_threshold:
                time_below_range += 1
            elif glucose > high_threshold:
                time_above_range += 1
            else:
                time_in_range += 1

    if total_count == 0:
        return 0, 0, 0, 0

    # 计算TIR, TAR, TBR和MG
    TIR = (time_in_range / total_count) * 100
    TAR = (time_above_range / total_count) * 100
    TBR = (time_below_range / total_count) * 100
    MG = total_glucose / total_count

    return TIR, TAR, TBR, MG

# 示例输入
glucose_data = [
    ("2024-07-17 08:00:00", 100),
    ("2024-07-17 12:00:00", 85),
    ("2024-07-17 15:00:00", 140),
    ("2024-07-17 18:00:00", 200),
    ("2024-07-16 08:00:00", 180),  # 不是当日数据
    ("2024-07-17 20:00:00", 110),
    ("2024-07-17 22:00:00", 95)
]

TIR, TAR, TBR, MG = calculate_blood_glucose_metrics(glucose_data)

print(f"TIR: {TIR:.2f}%")
print(f"TAR: {TAR:.2f}%")
print(f"TBR: {TBR:.2f}%")
print(f"MG: {MG:.2f} mg/dL")
