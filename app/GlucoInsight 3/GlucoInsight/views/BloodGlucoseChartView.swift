import SwiftUI

struct BloodGlucoseChartView: View {
    var glucoseData: [GlucoseReading]
    
    let normalRangeLower: Double = 3.9
    let normalRangeUpper: Double = 7.8
    let yAxisWidth: CGFloat = 40
    
    var filteredAndSortedData: [GlucoseReading] {
        let threeHoursAgo = Date().addingTimeInterval(-3 * 60 * 60)
        return glucoseData
            .filter { $0.time > threeHoursAgo }
            .sorted { $0.time < $1.time }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("近三小时血糖曲线")
                .font(.headline)
            
            HStack(alignment: .top, spacing: 0) {
                // Y轴标签
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach([15, 12, 9, 6, 3, 0], id: \.self) { value in
                        Text("\(value)")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .frame(height: 33) // 200 / 6
                    }
                }
                .frame(width: yAxisWidth)
                
                // 图表
                GeometryReader { geometry in
                    ZStack {
                        // 背景和网格线
                        VStack(spacing: 0) {
                            ForEach(0..<6) { i in
                                Divider()
                                if i < 5 {
                                    Spacer()
                                }
                            }
                        }
                        
                        // 正常范围区域
                        Path { path in
                            let lowerY = CGFloat(1 - (normalRangeLower / 15.0)) * geometry.size.height
                            let upperY = CGFloat(1 - (normalRangeUpper / 15.0)) * geometry.size.height
                            path.addRect(CGRect(x: 0, y: upperY, width: geometry.size.width, height: lowerY - upperY))
                        }
                        .fill(Color.green.opacity(0.1))
                        
                        // 平滑数据线
                        if !filteredAndSortedData.isEmpty {
                            Path { path in
                                let startTime = filteredAndSortedData[0].time
                                let endTime = filteredAndSortedData.last!.time
                                let timeRange = endTime.timeIntervalSince(startTime)
                                
                                path.move(to: CGPoint(x: 0, y: CGFloat(1 - (filteredAndSortedData[0].value / 15.0)) * geometry.size.height))
                                
                                for reading in filteredAndSortedData.dropFirst() {
                                    let point = CGPoint(
                                        x: CGFloat(reading.time.timeIntervalSince(startTime) / timeRange) * geometry.size.width,
                                        y: CGFloat(1 - (reading.value / 15.0)) * geometry.size.height
                                    )
                                    path.addLine(to: point)
                                }
                            }
                            .stroke(Color.orange, lineWidth: 2)
                        }
                        
                        // 数据点
                        ForEach(filteredAndSortedData) { reading in
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 6, height: 6)
                                .position(
                                    x: CGFloat(reading.time.timeIntervalSince(filteredAndSortedData[0].time) / filteredAndSortedData.last!.time.timeIntervalSince(filteredAndSortedData[0].time)) * geometry.size.width,
                                    y: CGFloat(1 - (reading.value / 15.0)) * geometry.size.height
                                )
                        }
                    }
                }
                .frame(height: 200)
            }
            
            // X轴标签
            HStack {
                Spacer().frame(width: yAxisWidth)
                if !filteredAndSortedData.isEmpty {
                    ForEach(0..<5) { i in
                        let date = filteredAndSortedData[0].time.addingTimeInterval(Double(i) * 45 * 60)
                        Text(formatDate(date))
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                        if i < 4 {
                            Spacer()
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 10) {
                HStack {
                    StatView(title: "最大血糖波动幅度", value: String(format: "%.1f", maxFluctuation()), unit: "mmol/L")
                    Spacer()
                    StatView(title: "最高血糖", value: String(format: "%.1f", maxGlucose()), unit: "mmol/L")
                    Spacer()
                    StatView(title: "最低血糖", value: String(format: "%.1f", minGlucose()), unit: "mmol/L")
                }
            }
            .padding()
            .background(Color.teal.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func maxFluctuation() -> Double {
        guard let max = filteredAndSortedData.map({ $0.value }).max(),
              let min = filteredAndSortedData.map({ $0.value }).min() else {
            return 0
        }
        return max - min
    }
    
    private func maxGlucose() -> Double {
        return filteredAndSortedData.map { $0.value }.max() ?? 0
    }
    
    private func minGlucose() -> Double {
        return filteredAndSortedData.map { $0.value }.min() ?? 0
    }
}

struct StatView: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

