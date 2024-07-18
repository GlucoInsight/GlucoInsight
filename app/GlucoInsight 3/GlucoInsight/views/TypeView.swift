//
//  TypeView.swift
//  GlucoInsight
//
//  Created by Rong Han & Sichao He on 2024/7/18.
//

//  TypeView.swift
//  GlucoInsight
//
//  Created by Rong Han & Sichao He on 2024/7/18.
//

import SwiftUI

struct BloodSugarControlView: View {
    let gradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(hex: "FF4B4B"),  // 鲜红色
            Color(hex: "FFA534"),  // 橙色
            Color(hex: "FFDC4B"),  // 黄色
            Color(hex: "4BFF4B")   // 鲜绿色
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var level: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("血糖控制能力")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            if level == 0 {
                insufficientDataView
            } else {
                sufficientDataView
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
    
    private var insufficientDataView: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("数据不足")
                .font(.headline)
                .foregroundColor(.orange)
            
            Text("请继续使用一段时间后再查看")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var sufficientDataView: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景渐变
                    gradient
                    
                    // 选中指示器
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 3)
                        .background(Color.white.opacity(0.2))
                        .frame(width: geometry.size.width / 4 - 8, height: 44)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .offset(x: CGFloat(level - 1) * geometry.size.width / 4 + 4)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: level)
                    
                    // 分隔线
                    HStack(spacing: 0) {
                        ForEach(0..<3) { _ in
                            Spacer()
                            Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: 1, height: 30)
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            HStack {
                Text("差")
                    .font(.subheadline)
                Spacer()
                Text("好")
                    .font(.subheadline)
            }
        }
    }
}

struct ContentViewExample: View {
    @State private var level: Int = 0
    
    var body: some View {
        VStack {
            BloodSugarControlView(level: level)
                .padding()
            
            Picker("Select Level", selection: $level) {
                Text("Insufficient Data").tag(0)
                Text("Level 1").tag(1)
                Text("Level 2").tag(2)
                Text("Level 3").tag(3)
                Text("Level 4").tag(4)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
        }
    }
}

struct BloodSugarControlView_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewExample()
            .previewDisplayName("Blood Sugar Control View")
    }
}

// 辅助函数：从十六进制字符串创建颜色
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
