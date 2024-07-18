import SwiftUI

struct DoubleWheelPickerView: View {
    @Binding var userInfo: UserInfo // 使用Binding来允许外部更新

    @State private var selectedCategory = 0
    @State private var selectedValueIndex = 0 // 使用索引来选择值
    
    let categories = ["年龄", "身高", "体重"]
    let values: [[Int]] = [
        Array(1...100), // 年龄范围
        Array(100...220), // 身高范围，单位cm
        Array(30...150) // 体重范围，单位kg
    ]
    
    var body: some View {
        VStack {
            HStack {
                Picker("类别", selection: $selectedCategory) {
                    ForEach(0..<categories.count, id: \.self) {
                        Text(self.categories[$0])
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .onChange(of: selectedCategory) { _ in
                    // 当选择的类别改变时，根据userInfo更新selectedValueIndex
                    updateSelectedValueIndex()
                }
                
                Picker("值", selection: $selectedValueIndex) {
                    ForEach(0..<values[selectedCategory].count, id: \.self) {
                        Text("\(self.values[self.selectedCategory][$0]) \(unit(for: selectedCategory))")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .onChange(of: selectedValueIndex) { newIndex in
                    // 当选择的值改变时，更新userInfo
                    updateUserInfo(with: newIndex)
                }
            }
            .frame(height: 200) // 设置合适的高度以确保轮盘显示完整
            .onAppear {
                // 初始化时设置selectedValueIndex
                updateSelectedValueIndex()
            }
        }
    }
    
    func unit(for category: Int) -> String {
        switch category {
        case 0:
            return "岁"
        case 1:
            return "cm"
        case 2:
            return "kg"
        default:
            return ""
        }
    }
    
    // 根据当前类别和userInfo更新selectedValueIndex
    private func updateSelectedValueIndex() {
        let currentValue: Int
        switch selectedCategory {
        case 0:
            currentValue = Int(userInfo.age) ?? 0
        case 1:
            currentValue = Int(userInfo.height) ?? 0
        case 2:
            currentValue = Int(userInfo.weight) ?? 0
        default:
            currentValue = 0
        }
        selectedValueIndex = values[selectedCategory].firstIndex(of: currentValue) ?? 0
    }
    
    // 根据选择的值更新userInfo
    private func updateUserInfo(with selectedIndex: Int) {
        let selectedValue = String(values[selectedCategory][selectedIndex])
        switch selectedCategory {
        case 0:
            userInfo.age = selectedValue
        case 1:
            userInfo.height = selectedValue
        case 2:
            userInfo.weight = selectedValue
        default:
            break
        }
    }
}
