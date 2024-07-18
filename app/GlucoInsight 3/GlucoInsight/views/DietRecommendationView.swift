//
//  DietRecommendationView.swift
//  GlucoInsight
//
//  Created by YI HE on 2024/7/17.
//

import SwiftUI

struct DietRecommendation: Codable {
    let data: String
}

struct DietRecommendationView: View {
    @State private var isUnlocked = false
    @State private var recommendations: [String] = []
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    
    @Binding var diet: Diet
    @Binding var glucoValue: [Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("您的专属饮食建议")
                .font(.headline)
                .foregroundColor(.primary)
                .padding()
            
            if isUnlocked {
                unlockedContent
            } else {
                lockedContent
            }
        }
        .frame(minHeight: 200)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 1)
        .animation(.spring(), value: isUnlocked)
        .onChange(of: isUnlocked) { newValue in
            if newValue {
                fetchDietRecommendations()
            }
        }
    }
    
    private var lockedContent: some View {
        Button(action: {
            withAnimation {
                isUnlocked = true
                isLoading = true
            }
        }) {
            HStack {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("点击获取您的专属饮食推荐")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .frame(height: 160)
            .background(Color.white.opacity(0.5))
        }
    }
    
    private var unlockedContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isLoading {
                HStack {
                    Spacer()
                    LoadingView()
                    Spacer()
                }
                .frame(height: 160)
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(recommendations.indices, id: \.self) { index in
                            DietRecommendationRow(number: index + 1, text: recommendations[index])
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    private func fetchDietRecommendations() {
        guard let url = URL(string: "http://glucoinsight.simolark.com:8080/flask/gpt_call_test") else {
            return
        }
        
        let prompt = """
        请用中文回复我的消息：现在，假设你是一名营养咨询师，为糖尿病人以及专业运动员提供饮食建议。你需要根据用户的饮食历史记录以及血糖情况作出适合用户的饮食建议。你需要提出5点建议。格式为：增加XXX: 每天XXX,以此类推，内容需要为贴近现实的回复，如具体的多吃哪一类食物，不要只有营养成分，不要出现多余的回复，不要带序号，也不需要回复本条消息，回答需要详细一些每条40字左右。现在，你的病人最近一次的饮食为：碳水化合物\(diet.carbohydrate)，蛋白质\(diet.protein)，脂肪\(diet.fat)。血糖含量为：\(glucoValue.map { String(format: "%.1f", $0) }.joined(separator: ", "))
        """
        
        print("Prompt: \(prompt)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["prompt": prompt]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "请求失败: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "未收到数据"
                    return
                }
                
                do {
                    let recommendation = try JSONDecoder().decode(DietRecommendation.self, from: data)
                    let recommendationsArray = recommendation.data.split(separator: "\n").map { String($0) }
                    self.recommendations = recommendationsArray
                } catch {
                    self.errorMessage = "解析数据失败: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct DietRecommendationRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number).")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .leading)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                    .scaleEffect(self.isAnimating ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            self.isAnimating = true
        }
    }
}
