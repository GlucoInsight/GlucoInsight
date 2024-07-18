import SwiftUI

struct DemoView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                NavigationLink(destination: EmptyContentView()) {
                    CardView(title: "首次登录且没有连接设备", gradientColors: [Color.gray.opacity(0.7), Color.gray])
                }
                .buttonStyle(PlainButtonStyle())

                NavigationLink(destination: ContentView()) {
                    CardView(title: "正常人群(已连接设备且初始化完成)", gradientColors: [Color.green.opacity(0.7), Color.green])
                }
                .buttonStyle(PlainButtonStyle())

                NavigationLink(destination: ContentView()) {
                    CardView(title: "高血糖人群(已连接设备且初始化完成)", gradientColors: [Color.red.opacity(0.7), Color.red])
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
            .padding(.top, 50)
            .navigationTitle("Demo Selection")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CardView: View {
    var title: String
    var gradientColors: [Color]
    
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(20)
            .shadow(color: .gray.opacity(0.6), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
    }
}

struct DestinationView: View {
    var body: some View {
        Text("Destination View")
            .font(.title)
            .padding()
    }
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        DemoView()
    }
}
