import SwiftUI

struct UserDetailView: View {
    @Binding var userInfo: UserInfo // 添加userInfo变量
    @State private var showingEditSheet = false // 控制编辑视图的显示
    
    @State private var isEditingAge = false
    @State private var isEditingHeight = false
    @State private var isEditingWeight = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("基本信息")) {
                    HStack {
                        Text("姓名")
                        Spacer()
                        Text(userInfo.name)
                    }
                    HStack {
                        Text("年龄")
                        Spacer()
                        Text("\(userInfo.age)")
                            .onTapGesture {
                                isEditingAge = true
                            }
                    }
                }
                
                Section(header: Text("身体信息")) {
                    HStack {
                        Text("身高")
                        Spacer()
                        Text("\(userInfo.height) cm")
                            .onTapGesture {
                                isEditingHeight = true
                            }
                    }
                    HStack {
                        Text("体重")
                        Spacer()
                        Text("\(userInfo.weight) kg")
                            .onTapGesture {
                                isEditingWeight = true
                            }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .pickerStyle(WheelPickerStyle())
            .onAppear {
                // Set the initial values for height and weight
                userInfo.age = "\(userInfo.age)"
                userInfo.height = "\(userInfo.height)"
                userInfo.weight = "\(userInfo.weight)"
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Image(systemName: "pencil")
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                DoubleWheelPickerView(userInfo: $userInfo)
            }
            // .sheet(isPresented: $isEditingHeight) {
            //     SliderView(value: $userInfo.height, title: "身高")
            // }
            // .sheet(isPresented: $isEditingWeight) {
            //     SliderView(value: $userInfo.weight, title: "体重")
            // }
            // .sheet(isPresented: $isEditingAge) {
            //     SliderView(value: $userInfo.age, title: "年龄")
            // }
        }
    }
}

// struct SliderView: View {
//     @Binding var value: String
//     var title: String
    
//     var body: some View {
//         VStack {
//             Text(title)
//                 .font(.title)
//                 .padding()
            
//             if title == "体重" {
//                 VStack {
//                     Slider(value: Binding<Double>(
//                         get: { Double(value) ?? 0 },
//                         set: { value = String(Int($0)) }
//                     ), in: 0...150, step: 1)
//                         .padding()
                    
//                     Text("\(value) kg")
//                         .font(.title)
//                 }
//                 .padding()
//                 .background(Color(.systemBackground))
//                 .cornerRadius(10)
//                 .shadow(radius: 5)
                
//             } else if title == "身高" {
//                 VStack {
//                     Slider(value: Binding<Double>(
//                         get: { Double(value) ?? 0 },
//                         set: { value = String(Int($0)) }
//                     ), in: 0...300, step: 1)
//                         .padding()
                    
//                     Text("\(value) cm")
//                         .font(.title)
//                 }
//                 .padding()
//                 .background(Color(.systemBackground))
//                 .cornerRadius(10)
//                 .shadow(radius: 5)
                
//             } else if title == "年龄" {
//                 VStack {
//                     Slider(value: Binding<Double>(
//                         get: { Double(value) ?? 0 },
//                         set: { value = String(Int($0)) }
//                     ), in: 0...150, step: 1)
//                         .padding()
                    
//                     Text("\(value)")
//                         .font(.title)
//                 }
//                 .padding()
//                 .background(Color(.systemBackground))
//                 .cornerRadius(10)
//                 .shadow(radius: 5)
//             }
//         }
//     }
// }

struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // 创建一个示例UserInfo对象用于预览
        var userInfo = UserInfo(name: "HAN RONG", age: "21", height: "173", weight: "70")
        UserDetailView(userInfo: userInfo)
    }
}
