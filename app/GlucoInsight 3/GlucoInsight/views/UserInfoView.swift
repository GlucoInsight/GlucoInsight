import SwiftUI
// 假设 UserInfo 是从另一个模块导入的
// import YourAppModule

struct UserInfoView: View {
    @Binding var userInfo: UserInfo
    @State private var showingUserDetail = false // 添加状态变量
    
    var body: some View {
        HStack(spacing: 20) {
            Image("avator")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(.systemGray5), lineWidth: 2))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(userInfo.name)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("年龄: \(userInfo.age)岁")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(alignment: .top, spacing: 4) {
                VStack(alignment: .trailing, spacing: 10) {
                    Text("身高:")
                        .frame(width: 42, alignment: .trailing)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("体重:")
                        .frame(width: 42, alignment: .trailing)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(userInfo.height)cm")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("\(userInfo.weight)kg")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        .onTapGesture {
            showingUserDetail = true // 设置为true以显示详细信息页面
        }
        .sheet(isPresented: $showingUserDetail) {
            // 这里是用户详细信息页面的视图，你可以根据需要自定义
            UserDetailView(userInfo: $userInfo)
        }
    }
}

struct UserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        // 使用您项目中已定义的 UserInfo 类型
        @State var userInfo = UserInfo(name: "HAN RONG", age: "21", height: "173", weight: "70")
        UserInfoView(userInfo: $userInfo)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemGroupedBackground))
    }
}

// 注意：不要在这里重新定义 UserInfo 结构体
// 假设 UserInfo 已在您的项目其他地方定义
