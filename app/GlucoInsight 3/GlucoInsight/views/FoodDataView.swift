//
//  FoodDataView.swift
//  GlucoInsight
//
//  Created by YI HE on 2024/7/17.
//

import SwiftUI

struct FoodDataView: View {
    @State private var showingDetail = false
    let diet: Diet
    let historyDiets: [Diet]
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            VStack {
                HStack {
                    Text("饮食分析")
                        .font(.headline)
                    Spacer()
                    Text(diet.startDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(diet.startHourMinute) - \(diet.endHourMinute)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }.padding(.horizontal)
                
                HStack(spacing: 20) {
                    CircularProgressView(progress: Double(diet.carbohydrate) / 50, color: .blue, label: "碳水", value: Int(diet.carbohydrate), unit: "g")
                    Spacer()
                    CircularProgressView(progress: Double(diet.protein) / 30, color: .green, label: "蛋白质", value: Int(diet.protein), unit: "g")
                    Spacer()
                    CircularProgressView(progress: Double(diet.fat) / 30, color: .orange, label: "脂肪", value: Int(diet.fat), unit: "g")
                }
                .padding()
            }
            .padding(.top, 10)
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            FoodDetailsView(historyDiets: historyDiets)
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    let label: String
    let value: Int
    let unit: String
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10.0)
                    .opacity(0.3)
                    .foregroundColor(color)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(color)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
                
                VStack {
                    Text("\(value)")
                        .font(.title2)
                        .bold()
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 80, height: 80)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}



struct FoodDataView_Previews: PreviewProvider {
    static var previews: some View {
        FoodDataView(diet: Diet(id: 1, startTime: "2023-01-01T00:00:00", endTime: "2023-01-01T02:55:00", carbohydrate: 51.0, fat: 16.0, protein: 20.0), historyDiets: [Diet(id: 1, startTime: "2000-00-00T00:00:00", endTime: "2000-00-00T00:00:00", carbohydrate: 0.0, fat: 0.0, protein: 0.0), Diet(id: 1, startTime: "2000-00-00T00:00:00", endTime: "2000-00-00T00:00:00", carbohydrate: 0.0, fat: 0.0, protein: 0.0), Diet(id: 1, startTime: "2000-00-00T00:00:00", endTime: "2000-00-00T00:00:00", carbohydrate: 0.0, fat: 0.0, protein: 0.0)])
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
