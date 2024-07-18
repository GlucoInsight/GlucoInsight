import SwiftUI

struct ChatView: View {
    @State private var recommendations: [String] = []
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    @State private var userInput: String = ""
    @State private var inputHeight: CGFloat = 100  // 初始高度

    @Binding var diet: Diet
    @Binding var glucoValue: [Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: -10) {
            Text("健康助理")
                .font(.headline)
                .foregroundColor(.primary)
                .padding()
            
            chatContent
        }
        .frame(minHeight: 170)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 1)
    }
    
    private var chatContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 15) {
                    GeometryReader { geometry in
                        AutoSizingTextView(text: $userInput, height: $inputHeight, maxWidth: geometry.size.width - 10)
                            .frame(height: max(100, min(inputHeight, 200)))
                            
                    }
                    .frame(height: max(20, min(inputHeight, 200)))
                    .padding(10)

                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                    .overlay(
                        Text(userInput.isEmpty ? "输入您的问题或关注点" : "")
                            .foregroundColor(.gray)
                            .padding(.leading, 5)
                            .font(.system(size: CGFloat(15)))
                            .padding(.top, 8),
                        alignment: .topLeading
                    )

                    HStack {
                        Spacer()
                        Button(action: {
                            fetchChats()
                        }) {
                            Text("提交")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]), startPoint: .top, endPoint: .bottom)
                                )
                                .cornerRadius(15)
                                .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        Spacer()
                    }
                }
                
                if isLoading {
                    HStack {
                        Spacer()
                        ChatLoadingView()
                        Spacer()
                    }
                    .frame(height: 160)
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(recommendations, id: \.self) { recommendation in
                            Text(recommendation)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.vertical, 5)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }


    private func fetchChats() {
        guard let url = URL(string: "http://glucoinsight.simolark.com:8080/flask/gpt_call_test") else {
            return
        }
        
        isLoading = true
        
        let prompt = """
            请用中文回复我的消息：现在，假设你是一名营养咨询师，为糖尿病人以及专业运动员提供饮食建议。现在，你的病人主要关注问题是：\(userInput)。
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
                    let chat = try JSONDecoder().decode(Chat.self, from: data)
                    let recommendationsArray = chat.data.split(separator: "\n").map { String($0) }
                    self.recommendations = recommendationsArray
                } catch {
                    self.errorMessage = "解析数据失败: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct AutoSizingTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    let maxWidth: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.frame.size.width = maxWidth
        DispatchQueue.main.async {
            let size = uiView.sizeThatFits(CGSize(width: self.maxWidth, height: .greatestFiniteMagnitude))
            if self.height != size.height {
                self.height = size.height
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: AutoSizingTextView

        init(_ parent: AutoSizingTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            let size = textView.sizeThatFits(CGSize(width: parent.maxWidth, height: .greatestFiniteMagnitude))
            parent.height = size.height
        }
    }
}
struct ChatRow: View {
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

struct ChatLoadingView: View {
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

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(diet: .constant(Diet(id: 1, startTime: "2024-07-18T12:00:00", endTime: "2024-07-18T13:00:00", carbohydrate: 200, fat: 50, protein: 100)),
                 glucoValue: .constant([5.5, 6.2, 5.8, 6.0, 5.7]))
    }
}

struct Chat: Codable {
    let data: String
}
