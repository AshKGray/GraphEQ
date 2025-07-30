import SwiftUI

struct MathSolverView: View {
    @State private var currentProblem = "" // Single input field that never gets cleared
    @State private var isLoading = false
    @State private var chatHistory: [ChatMessage] = []
    @State private var showInputAfterSolution = false
    
    var body: some View {
        ZStack {
            // Dark background to match your app
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Main Content Area
                mainContentView
                
                // Bottom Input Area (always visible after first solution)
                if showInputAfterSolution {
                    bottomInputView
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isLoading)
        .animation(.easeInOut(duration: 0.3), value: showInputAfterSolution)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button("Back") {
                // Dismiss view
            }
            .foregroundColor(.cyan)
            
            Spacer()
            
            Text("AI Math Solver")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.cyan)
                .glow(color: .cyan, radius: 2)
            
            Spacer()
            
            Button("Clear") {
                chatHistory.removeAll()
                currentProblem = ""
                showInputAfterSolution = false
            }
            .foregroundColor(.cyan)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.black)
    }
    
    // MARK: - Main Content View
    private var mainContentView: some View {
        VStack(spacing: 0) {
            if chatHistory.isEmpty {
                // Initial state - show problem input
                initialInputView
            } else {
                // Show chat history with solutions
                chatHistoryView
            }
        }
    }
    
    // MARK: - Initial Input View
    private var initialInputView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Enter a Math Problem")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.cyan)
                .glow(color: .cyan, radius: 2)
            
            VStack(spacing: 16) {
                // Quick symbols row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(quickSymbols, id: \.self) { symbol in
                            Button(symbol) {
                                currentProblem += symbol
                            }
                            .font(.title2)
                            .foregroundColor(.cyan)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Problem input field
                TextField("Enter a math problem to solve step by step...", text: $currentProblem, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.white)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .lineLimit(1...4)
                    .padding(.horizontal, 16)
                
                // Solve button
                Button(action: solveProblem) {
                    if isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(0.8)
                            Text("Solving...")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                        }
                    } else {
                        Text("Solve Step by Step")
                            .foregroundColor(.black)
                            .fontWeight(.semibold)
                    }
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(isLoading ? Color.gray : Color.cyan)
                .cornerRadius(12)
                .disabled(currentProblem.isEmpty || isLoading)
                .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Chat History View
    private var chatHistoryView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(chatHistory.indices, id: \.self) { index in
                        let message = chatHistory[index]
                        
                        if message.isUser {
                            // User message bubble
                            HStack {
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(message.content)
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color.cyan)
                                        .cornerRadius(18)
                                    
                                    Text(message.timestamp)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 16)
                        } else {
                            // AI response with step-by-step solution
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("AI Assistant")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text(message.timestamp)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    // Parse and display step-by-step solution
                                    stepByStepSolutionView(message.content)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(18)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .onChange(of: chatHistory.count) { _ in
                if let lastIndex = chatHistory.indices.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastIndex, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Step by Step Solution View
    private func stepByStepSolutionView(_ solution: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            let steps = parseSolutionSteps(solution)
            
            ForEach(steps.indices, id: \.self) { index in
                let step = steps[index]
                HStack(alignment: .top, spacing: 12) {
                    // Mathematical expression (left side)
                    Text(step.expression)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.green)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Arrow and description (right side)
                    HStack(spacing: 4) {
                        Text("←")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Text(step.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.trailing)
                    }
                    .frame(width: 120, alignment: .trailing)
                }
                .padding(.vertical, 2)
            }
        }
    }
    
    // MARK: - Parse Solution Steps
    private func parseSolutionSteps(_ solution: String) -> [(expression: String, description: String)] {
        let lines = solution.components(separatedBy: .newlines)
        var steps: [(expression: String, description: String)] = []
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if !trimmedLine.isEmpty {
                // Look for the pattern: expression ← description
                if let arrowRange = trimmedLine.range(of: " ← ") {
                    let expression = String(trimmedLine[..<arrowRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                    let description = String(trimmedLine[arrowRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                    
                    if !expression.isEmpty && !description.isEmpty {
                        steps.append((expression: expression, description: description))
                    }
                } else {
                    // If no arrow found, treat as a single step
                    steps.append((expression: trimmedLine, description: "step"))
                }
            }
        }
        
        return steps
    }
    
    // MARK: - Bottom Input View (always shown after first solution)
    private var bottomInputView: some View {
        VStack(spacing: 0) {
            // Quick symbols row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quickSymbols, id: \.self) { symbol in
                        Button(symbol) {
                            currentProblem += symbol
                        }
                        .font(.title2)
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
            
            // Input field and send button
            HStack(spacing: 12) {
                TextField("Edit problem and solve again...", text: $currentProblem, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.white)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .lineLimit(1...4)
                
                Button(action: solveProblem) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                            .scaleEffect(0.8)
                    } else {
                        Text("Solve")
                            .foregroundColor(.black)
                            .fontWeight(.semibold)
                    }
                }
                .frame(width: 60, height: 44)
                .background(isLoading ? Color.gray : Color.cyan)
                .cornerRadius(12)
                .disabled(currentProblem.isEmpty || isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.black)
    }
    
    // MARK: - Quick Symbols
    private let quickSymbols = [
        "√", "²", "³", "⁴", "⁵", "×", "÷", "π", "∞", "∫", "d/dx", "ln", "sin", "cos", "tan", "(", ")", "+", "-", "="
    ]
    
    // MARK: - Solve Problem (single function for both initial and bottom inputs)
    private func solveProblem() {
        guard !currentProblem.isEmpty else { return }
        
        let userMessage = ChatMessage(
            content: currentProblem,
            isUser: true,
            timestamp: formatTimestamp(Date())
        )
        
        chatHistory.append(userMessage)
        
        isLoading = true
        
        MathSolverService.shared.solveMathProblem(currentProblem) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let solution):
                    let aiMessage = ChatMessage(
                        content: solution,
                        isUser: false,
                        timestamp: formatTimestamp(Date())
                    )
                    chatHistory.append(aiMessage)
                    
                    // Show input after solution is displayed (only once)
                    if !showInputAfterSolution {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showInputAfterSolution = true
                        }
                    }
                    
                case .failure(let error):
                    let errorMessage = ChatMessage(
                        content: "Error: \(error.localizedDescription)",
                        isUser: false,
                        timestamp: formatTimestamp(Date())
                    )
                    chatHistory.append(errorMessage)
                    
                    // Show input even if there's an error (only once)
                    if !showInputAfterSolution {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showInputAfterSolution = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Format Timestamp
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Chat Message Model
struct ChatMessage {
    let content: String
    let isUser: Bool
    let timestamp: String
}

// MARK: - Glow Modifier
extension View {
    func glow(color: Color, radius: CGFloat) -> some View {
        self
            .shadow(color: color, radius: radius)
            .shadow(color: color, radius: radius)
    }
}

#Preview {
    MathSolverView()
}