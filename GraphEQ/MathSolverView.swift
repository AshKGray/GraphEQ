import SwiftUI

// MARK: - Enhanced Mathematical Notation Formatter
struct EnhancedMathNotationFormatter {
    static func formatExpression(_ expression: String) -> String {
        // Use manual formatting for mathematical expressions
        return formatManually(expression)
    }
    
    private static func formatManually(_ expression: String) -> String {
        var formatted = expression
        
        // Replace common mathematical symbols with proper Unicode
        let replacements = [
            "sqrt": "√",
            "cbrt": "∛",
            "infinity": "∞",
            "pi": "π",
            "theta": "θ",
            "alpha": "α",
            "beta": "β",
            "gamma": "γ",
            "delta": "δ",
            "partial": "∂",
            "sum": "∑",
            "product": "∏",
            "integral": "∫",
            "leq": "≤",
            "geq": "≥",
            "neq": "≠",
            "approx": "≈",
            "plusminus": "±",
            "times": "×",
            "div": "÷"
        ]
        
        for (key, value) in replacements {
            formatted = formatted.replacingOccurrences(of: key, with: value)
        }
        
        return formatted.trimmingCharacters(in: .whitespaces)
    }
    
    static func validateExpression(_ expression: String) -> Bool {
        // Basic validation - check if expression contains valid mathematical characters
        let validChars = "0123456789+-*/()^=<>≤≥≠πθαβγδ∞∫∑∂√∛abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ,."
        return expression.allSatisfy { validChars.contains($0) || $0.isWhitespace }
    }
}

struct MathSolverView: View {
    @State private var currentProblem = ""
    @State private var isLoading = false
    @State private var chatHistory: [ChatMessage] = []
    @State private var showInputAfterSolution = false
    @EnvironmentObject var completionService: MathAutoCompletionService
    
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
                .shadow(color: .cyan, radius: 2)
            
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
    
    // MARK: - Initial Input View (FIXED)
    private var initialInputView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Enter a Math Problem")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.cyan)
                .shadow(color: .cyan, radius: 2)
            
            VStack(spacing: 16) {
                // Auto-completion suggestions
                if completionService.showSuggestions {
                    MathAutoCompletionView(completionService: completionService) { completion in
                        insertCompletion(completion)
                    }
                    .padding(.horizontal, 16)
                }
                
                // Quick symbols row - FIXED scrolling
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(quickSymbols, id: \.self) { symbol in
                            Button(symbol) {
                                currentProblem += symbol
                                completionService.updateSuggestions(for: currentProblem)
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)  // WHITE text for visibility
                            .frame(width: 40, height: 35)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.3))
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 50)
                
                // Problem input field with SwiftMath validation
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Enter math problem like: x^2 + 5x - 6 = 0", text: $currentProblem)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)  // WHITE text
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                        )
                        .lineLimit(1...4)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: currentProblem) { oldValue, newValue in
                            completionService.updateSuggestions(for: newValue)
                        }
                        .onSubmit {
                            completionService.clearSuggestions()
                        }
                    
                    // Expression validation feedback
                    if !currentProblem.isEmpty && !EnhancedMathNotationFormatter.validateExpression(currentProblem) {
                        Text("Expression may be incomplete or invalid")
                            .font(.caption2)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal, 16)
                
                // Solve button
                Button(action: solveProblem) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(0.8)
                            Text("Solving...")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                        } else {
                            Text("Solve Step by Step")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(currentProblem.isEmpty || isLoading ? Color.gray : Color.cyan)
                    )
                }
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
                                        .font(.system(size: 16, weight: .medium))
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
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.gray.opacity(0.2))
                                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                                )
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .onChange(of: chatHistory.count) { oldValue, newValue in
                if let lastIndex = chatHistory.indices.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastIndex, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Step by Step Solution View (SIDE-BY-SIDE LAYOUT)
    private func stepByStepSolutionView(_ solution: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            let steps = parseSolutionSteps(solution)
            
            ForEach(steps.indices, id: \.self) { index in
                let step = steps[index]
                
                // Full-width mathematical expression with enhanced formatting
                Text(EnhancedMathNotationFormatter.formatExpression(step.expression))
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.3))
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
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
                } else if let arrowRange = trimmedLine.range(of: "←") {
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
    
    // MARK: - Bottom Input View with Auto-Completion
    private var bottomInputView: some View {
        VStack(spacing: 8) {
            // Auto-completion suggestions for bottom input
            if completionService.showSuggestions {
                MathAutoCompletionView(completionService: completionService) { completion in
                    insertCompletion(completion)
                }
                .padding(.horizontal, 16)
            }
            
            // Quick symbols row - FIXED
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickSymbols, id: \.self) { symbol in
                        Button(symbol) {
                            currentProblem += symbol
                            completionService.updateSuggestions(for: currentProblem)
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)  // WHITE text
                        .frame(width: 35, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.3))
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 40)
            
            // Input field and send button with validation
            VStack(spacing: 4) {
                HStack(spacing: 12) {
                    TextField("Edit problem and solve again...", text: $currentProblem)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)  // WHITE text
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                        )
                        .lineLimit(1...4)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: currentProblem) { oldValue, newValue in
                            completionService.updateSuggestions(for: newValue)
                        }
                        .onSubmit {
                            completionService.clearSuggestions()
                        }
                
                Button(action: solveProblem) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            .scaleEffect(0.8)
                    } else {
                        Text("Solve")
                            .foregroundColor(.black)
                            .fontWeight(.semibold)
                    }
                }
                .frame(width: 60, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(currentProblem.isEmpty || isLoading ? Color.gray : Color.cyan)
                )
                .disabled(currentProblem.isEmpty || isLoading)
            }
            
            // Expression validation feedback for bottom input  
            if !currentProblem.isEmpty && !EnhancedMathNotationFormatter.validateExpression(currentProblem) {
                HStack {
                    Text("Expression may be incomplete or invalid")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 4)
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        }
        .background(Color.black)
    }
    
    // MARK: - Quick Symbols (REDUCED for better fit)
    private let quickSymbols = [
        "√", "²", "³", "×", "÷", "π", "∫", "ln", "sin", "cos", "tan",
        "(", ")", "+", "-", "=", "|", "y'", "∂", "±", "≤", "≥"
    ]
    
    // MARK: - Insert Completion
    private func insertCompletion(_ completion: MathCompletion) {
        // Find the last word/prefix to replace
        let words = currentProblem.components(separatedBy: CharacterSet.alphanumerics.inverted)
        if let lastWord = words.last, !lastWord.isEmpty {
            // Replace the last word with the completion
            let range = currentProblem.range(of: lastWord, options: .backwards)
            if let range = range {
                currentProblem.replaceSubrange(range, with: completion.insertion)
            } else {
                currentProblem += completion.insertion
            }
        } else {
            currentProblem += completion.insertion
        }
        
        // Clear suggestions after insertion
        completionService.clearSuggestions()
    }
    
    // MARK: - Solve Problem
    private func solveProblem() {
        guard !currentProblem.isEmpty else { return }
        
        // Validate expression with Expression library before sending to AI
        if !EnhancedMathNotationFormatter.validateExpression(currentProblem) {
            // Show warning but still allow sending to AI for better error handling
            print("⚠️ Expression validation warning: \(currentProblem)")
        }
        
        let userMessage = ChatMessage(
            content: currentProblem,
            isUser: true,
            timestamp: formatTimestamp(Date())
        )
        
        chatHistory.append(userMessage)
        
        isLoading = true
        
        // Clear auto-completion suggestions when solving
        completionService.clearSuggestions()
        
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

#Preview {
    MathSolverView()
}
