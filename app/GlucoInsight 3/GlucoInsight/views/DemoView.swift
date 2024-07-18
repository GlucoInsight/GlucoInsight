import SwiftUI

struct DemoView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: ContentView()) {
                    CardView(title: "demo 0", icon: "star.fill")
                        .padding(.horizontal)
                }
                .buttonStyle(PlainButtonStyle())

                NavigationLink(destination: DestinationView()) {
                    CardView(title: "demo 1", icon: "heart.fill")
                        .padding(.horizontal)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Demo Selection")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CardView: View {
    var title: String
    var icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.leading, 10)
            
            Text(title)
                .font(.title2)
                .foregroundColor(.white)
                .padding()
            
            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)
        )
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
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
