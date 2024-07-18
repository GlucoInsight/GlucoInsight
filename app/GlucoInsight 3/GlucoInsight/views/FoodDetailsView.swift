//
//  FoodDetails.swift
//  GlucoInsight
//
//  Created by Rong Han & Sichao He on 2024/7/17.
//

import SwiftUI

struct FoodDetailsView: View {
    
    let historyDiets: [Diet]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("饮食分析")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding([.top, .horizontal])
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(historyDiets) { diets in
                        FoodEntrySection(diet: diets)
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

struct FoodEntrySection: View {
    let diet: Diet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(diet.startDate)
                    .font(.headline)
                Spacer()
                Text("\(diet.startHourMinute) - \(diet.endHourMinute)")
            }
            
            HStack(spacing: 10) {
                NutrientCard(label: "碳水化合物", value: Int(diet.carbohydrate), color: .blue)
                NutrientCard(label: "蛋白质", value: Int(diet.protein), color: .green)
                NutrientCard(label: "脂肪", value: Int(diet.fat), color: .orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
    
}

struct NutrientCard: View {
    let label: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(value)g")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}


struct FoodDetails_Previews: PreviewProvider {
    static var previews: some View {
        FoodDetailsView(historyDiets: [Diet(id: 1, startTime: "2000-00-00T00:00:00", endTime: "2000-00-00T00:00:00", carbohydrate: 0.0, fat: 0.0, protein: 0.0), Diet(id: 1, startTime: "2000-00-00T00:00:00", endTime: "2000-00-00T00:00:00", carbohydrate: 0.0, fat: 0.0, protein: 0.0), Diet(id: 1, startTime: "2000-00-00T00:00:00", endTime: "2000-00-00T00:00:00", carbohydrate: 0.0, fat: 0.0, protein: 0.0)])
    }
}
