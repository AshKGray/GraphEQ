import SwiftUI

struct MathSolverView: View {
    @State private var mathProblem = ""
    @State private var solution = ""
    @State private var isLoading = false
    @State private var showingSolution = false
    @State private var chatHistory: [ChatMessage] = []
    
    var body: some View {
        ZStack {
            // Dark background to match your app
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Chat History Area
                chatHistoryView
                
                // Bottom Input Area (like iPhone Messages)
                bottomInputView
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingSolution)
        .animation(.easeInOut(duration: 0.3), value: mathProblem.isEmpty)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Text("AI Math Solver")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.cyan)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button("Clear") {
                    mathProblem = ""
                    solution = ""
                    showingSolution = false
                    chatHistory.removeAll()
                }
                .buttonStyle(AppButtonStyle(color: .orange))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(red: 0.067, green: 0.067, blue: 0.067))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2)),
            alignment: .bottom
        )
    }
    
    // MARK: - Chat History View
    private var chatHistoryView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(chatHistory) { message in
                    ChatBubbleView(message: message)
                }
                
                if isLoading {
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 8) {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                                Text("Solving...")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Bottom Input View
    private var bottomInputView: some View {
        VStack(spacing: 0) {
            // Quick Symbols Row
            if !mathProblem.isEmpty {
                quickSymbolsRow
            }
            
            // Input Row
            HStack(spacing: 12) {
                // Text Field
                TextField("Enter math problem...", text: $mathProblem)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.15))
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .onSubmit {
                        solveProblem()
                    }
                
                // Send Button
                Button(action: solveProblem) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(mathProblem.isEmpty || isLoading ? .gray : .cyan)
                }
                .disabled(mathProblem.isEmpty || isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(red: 0.067, green: 0.067, blue: 0.067))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2)),
                alignment: .top
            )
        }
    }
    
    // MARK: - Quick Symbols Row
    private var quickSymbolsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["x", "y", "²", "√", "+", "-", "×", "÷", "=", "(", ")", "π"], id: \.self) { symbol in
                    Button(symbol) {
                        mathProblem += symbol
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(Color(red: 0.067, green: 0.067, blue: 0.067))
    }
    
    private func solveProblem() {
        guard !mathProblem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            id: UUID(),
            content: mathProblem,
            isUser: true,
            timestamp: Date()
        )
        
        chatHistory.append(userMessage)
        let currentProblem = mathProblem
        mathProblem = ""
        isLoading = true
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Call AI service
        MathSolverService.shared.solveMathProblem(currentProblem) { result in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.isLoading = false
                    
                    let aiMessage = ChatMessage(
                        id: UUID(),
                        content: result.success ?? "Error: \(result.failure?.localizedDescription ?? "Unknown error")",
                        isUser: false,
                        timestamp: Date()
                    )
                    
                    self.chatHistory.append(aiMessage)
                }
            }
        }
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
}

// MARK: - Chat Bubble View
struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                userBubble
            } else {
                aiBubble
                Spacer()
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var userBubble: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(message.content)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.cyan)
                )
            
            Text(formatTime(message.timestamp))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
    }
    
    private var aiBubble: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("AI Assistant")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.cyan)
                .padding(.horizontal, 4)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(message.content)
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.gray.opacity(0.15))
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
            )
            
            Text(formatTime(message.timestamp))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .padding(.horizontal, 4)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Result Extension
extension Result {
    var success: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    var failure: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

// Custom button style to match your app
struct AppButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}