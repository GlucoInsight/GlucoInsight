//
//  ContentView.swift
//  GlucoInsight
//
//  Created by YI HE on 2024/7/17.
//

import SwiftUI

struct ContentView: View {
    
    @State private var userInfo: UserInfo = UserInfo(name: "XX", age: "XX", height: "XX", weight: "XX")
    @State private var glucoType: Int = 0
    @State private var trainingImage: UIImage? = nil
    @State private var dietData: Diet = Diet(id: 1, startTime: "2000-00-00T00:00:00", endTime: "2000-00-00T00:00:00", carbohydrate: 0.0, fat: 0.0, protein: 0.0)
    @State private var historyDiets: [Diet] = [Diet(id: 1, startTime: "2000-00-00T00:00:00", endTime: "2000-00-00T00:00:00", carbohydrate: 0.0, fat: 0.0, protein: 0.0), Diet(id: 1, startTime: "2000-00-00T00:00:00", endTime: "2000-00-00T00:00:00", carbohydrate: 0.0, fat: 0.0, protein: 0.0), Diet(id: 1, startTime: "2000-00-00T00:00:00", endTime: "2000-00-00T00:00:00", carbohydrate: 0.0, fat: 0.0, protein: 0.0)]
    @State private var motivationalQuote: String = "Every step counts towards your goal!"
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showingSportsView = false
    @State private var latestGlucoseLevel: Double = 0.0
    @State private var notificationStatus: String = "未知"
    @State private var glucoseData: [GlucoseReading] = []
    @State private var latest10GlucoseValues: [Double] = []
    @State private var showingUserPage = false
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                UserInfoView(userInfo: $userInfo)
                
                BloodGlucoseChartView(glucoseData: glucoseData)
                
                BloodSugarControlView(level: glucoType)
                
                CustomButton(action: {
                    // Action for the custom button
                    print("Custom button tapped")
                    showingSportsView = true
                })
                
                FoodDataView(diet: dietData, historyDiets: historyDiets)
                
                DietRecommendationView(diet: $dietData, glucoValue: $latest10GlucoseValues)
                
                Text(motivationalQuote)
                    .italic()
                    .foregroundColor(.secondary)
                    .padding()
                
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showingSportsView) {
            SportsView()
        }
        .onAppear {
            fetchUserInfo()
            fetchDietInfo()
            fetchGlucoseData()
            fetchLatest10GlucoseValues()
            fetchData()
            requestNotificationPermission()
            
        }
    }
    
    private func fetchLatest10GlucoseValues() {
        let glucoseService = GlucoseService()
        glucoseService.fetchLatest10GlucoseValues { values in
            if let values = values {
                DispatchQueue.main.async {
                    self.latest10GlucoseValues = values
                }
            }
        }
    }
    
    private func fetchGlucoseData() {
        let glucoseService = GlucoseService()
        glucoseService.fetchGlucoseData { readings in
            if let readings = readings {
                DispatchQueue.main.async {
                    self.glucoseData = readings
                        .filter { Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date() < $0.time }
                        .sorted(by: { $0.time < $1.time }) // 按时间顺序排序
                }
            }
        }
    }
    
    func fetchUserInfo() {
        isLoading = true
        errorMessage = nil
        
        UserInfoService().fetchLatestUserInfo { userDetail in
            DispatchQueue.main.async {
                isLoading = false
                if let userDetail = userDetail {
                    self.userInfo = userDetail.userInfo
                    self.glucoType = userDetail.glucoType
                } else {
                    self.errorMessage = "Failed to fetch user info"
                }
            }
        }
    }
    
    func fetchDietInfo()  {
        
        let dietService = DietService()
        
        dietService.fetchDietData { sortedDiets in
            guard let sortedDiets = sortedDiets else {
                print("Failed to fetch or decode data.")
                return
            }
            
            self.dietData = sortedDiets[0]
            self.historyDiets = sortedDiets
            
        }
        
        
    }
    
    
    
    func fetchData() {
        // Simulated API calls
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.trainingImage = UIImage(systemName: "figure.run")
        }
    }
    
    private func requestNotificationPermission() {
        NotificationManager.shared.requestAuthorization { granted in
            DispatchQueue.main.async {
                self.notificationStatus = granted ? "已授权" : "已拒绝"
            }
        }
    }
    
}




//MARK: - 运动模式按钮
struct CustomButton: View {
    let action: () -> Void
    
    var body: some View {
        ZStack {
            // Background container
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue.opacity(0.2))
                .frame(height: 50)
            
            // Text layers
            HStack {
                Spacer()
                Text("运动")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .italic()
                    .foregroundColor(.blue)
                Spacer()
                Spacer()
                Text("模式")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .italic()
                    .foregroundColor(.blue)
                Spacer()
            }
            .frame(height: 50)
            
            // Clickable circle button
            Button(action: action) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "figure.run")
                            .foregroundColor(.white)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(height: 50)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
