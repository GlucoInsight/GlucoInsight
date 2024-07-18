//
//  SportsView.swift
//  GlucoInsight
//
//  Created by YI HE on 2024/7/18.
//

import SwiftUI
import Foundation

struct SportsView: View {
    @State private var glucoseLevel: Double?
    @State private var animation: Bool = false
    @State private var isLoading: Bool = true
    @Environment(\.colorScheme) var colorScheme
    
    let circleCount = 6
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("运动模式")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                ZStack {
                    ForEach(0..<circleCount, id: \.self) { index in
                        Circle()
                            .fill(circleColor(for: index))
                            .frame(width: 200, height: 200)
                            .offset(offset(for: index))
                            .scaleEffect(animation ? 0.7 : 1.3)
                            .rotationEffect(Angle(degrees: animation ? 360 : 0))
                            .animation(
                                Animation.easeInOut(duration: 4)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                value: animation
                            )
                    }
                    
                    VStack(spacing: 5) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                .scaleEffect(1.5)
                        } else if let level = glucoseLevel {
                            Text(String(format: "%.1f", Float(level)))
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundColor(textColor)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.5), value: level)
                            Text("mg/dL")
                                .font(.subheadline)
                                .foregroundColor(Color.secondary)
                        }
                    }
                    .frame(width: 150, height: 150)
                    .background(Circle().fill(Color(UIColor.systemBackground)))
                }
                .frame(width: 300, height: 300)
                
                VStack(spacing: 10) {
                    if let level = glucoseLevel {
                        Text(glucoseLevelStatus(for: level))
                            .font(.headline)
                            .foregroundColor(textColor)
                        
                        Text(glucoseLevelDescription(for: level))
                            .font(.subheadline)
                            .foregroundColor(Color.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                animation = true
            }
            self.glucoseLevel = 3.9
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isLoading = false
                startGlucoseLevelUpdates()
            }
        }
    }
    
    func circleColor(for index: Int) -> Color {
        let baseColor = (glucoseLevel ?? 0) < 3.9 ? Color.red : ((glucoseLevel ?? 0) > 7.8 ? Color.orange : Color.green)
        return baseColor.opacity(1.0 - Double(index) * 0.15)
    }
    
    func offset(for index: Int) -> CGSize {
        let angle = CGFloat(index) / CGFloat(circleCount) * 2 * .pi
        let radius: CGFloat = 30
        return CGSize(width: radius * CGFloat(cos(angle)), height: radius * CGFloat(sin(angle)))
    }
    
    var textColor: Color {
        if (glucoseLevel ?? 0) < 3.9 || (glucoseLevel ?? 0) > 7.8 {
            return colorScheme == .dark ? Color.red.opacity(0.8) : Color.red
        } else {
            return colorScheme == .dark ? Color.green.opacity(0.8) : Color.green
        }
    }
    
    func glucoseLevelStatus(for level: Double) -> String {
        if level < 3.9 {
            return "血糖偏低"
        } else if level > 7.8 {
            return "血糖偏高"
        } else {
            return "血糖正常"
        }
    }
    
    func glucoseLevelDescription(for level: Double) -> String {
        if level < 3.9 {
            return "建议适度补充碳水化合物，如水果或果汁。"
        } else if level > 7.8 {
            return "建议进行一些轻度运动，如散步，以帮助降低血糖。"
        } else {
            return "您的血糖水平在理想范围内，继续保持良好的生活习惯。"
        }
    }
    
    private func startGlucoseLevelUpdates() {
        // Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
        //     let newLevel = Double.random(in: 3.0...7.0)
        //     withAnimation {
        //         self.glucoseLevel = newLevel
        //     }
        // }
        // 设置定时器每0.1秒更新一次血糖值，来逐渐更新self.glucoseLevel以接近newLevel，这里需要分别设置+0.1和-0.1的概率，当数值小于3.5时，+0.1概率变大，
        // 当数值大于6.5时，-0.1概率变大
        var newLevel = 3.9
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let random = Double.random(in: 0...1)
            if newLevel < 3.5 {
                if random < 0.8 {
                    newLevel += 0.05
                } else {
                    newLevel -= 0.05
                }
            } else if newLevel > 6.5 {
                if random < 0.8 {
                    newLevel -= 0.05
                } else {
                    newLevel += 0.05
                }
            } else {
                if random < 0.5 {
                    newLevel += 0.05
                } else {
                    newLevel -= 0.05
                }
            }
            withAnimation {
                self.glucoseLevel = newLevel
            }
        }
    }
}

struct SportsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SportsView()
            SportsView().preferredColorScheme(.dark)
        }
    }
}