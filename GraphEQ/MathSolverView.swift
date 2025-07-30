import SwiftUI

struct MathSolverView: View {
    @State private var mathProblem = ""
    @State private var solution = ""
    @State private var isLoading = false
    @State private var showingSolution = false
    
    var body: some View {
        ZStack {
            // Dark background to match your app
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header with app-style buttons
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
                        }
                        .buttonStyle(AppButtonStyle(color: .orange))
                        
                        Button("AI") {
                            solveProblem()
                        }
                        .buttonStyle(AppButtonStyle(color: .orange))
                        .disabled(mathProblem.isEmpty || isLoading)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Input Section - styled like your equation box
                VStack(spacing: 15) {
                    HStack {
                        Text("PROBLEM:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .tracking(1)
                        Spacer()
                    }
                    
                    TextField("Enter math problem...", text: $mathProblem)
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.15))
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                // Solve Button - matches your UI style
                if !mathProblem.isEmpty {
                    Button(action: solveProblem) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            }
                            Text(isLoading ? "Solving..." : "Solve Step by Step")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.orange)
                        )
                        .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    .disabled(isLoading)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Solution Display Area
                if showingSolution {
                    VStack(spacing: 15) {
                        HStack {
                            Text("SOLUTION:")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .tracking(1)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        ScrollView {
                            Text(solution)
                                .font(.system(size: 16, weight: .regular, design: .monospaced))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.15))
                                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .frame(maxHeight: 300)
                        .padding(.horizontal)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
                
                // Bottom symbols panel (similar to your math symbols)
                if !showingSolution && !mathProblem.isEmpty {
                    VStack(spacing: 12) {
                        Text("QUICK SYMBOLS")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                            .tracking(1)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                            ForEach(["x", "y", "²", "√", "+", "-", "×", "÷"], id: \.self) { symbol in
                                Button(symbol) {
                                    mathProblem += symbol
                                }
                                .font(.system(size: 18, weight: .medium))
                                .frame(width: 50, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                )
                                .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingSolution)
        .animation(.easeInOut(duration: 0.3), value: mathProblem.isEmpty)
    }
    
    private func solveProblem() {
        guard !mathProblem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isLoading = true
        showingSolution = false
        
        // Add haptic feedback like your app
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Call AI service
        MathSolverService.shared.solveMathProblem(mathProblem) { result in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.isLoading = false
                    switch result {
                    case .success(let solutionText):
                        self.solution = solutionText
                        self.showingSolution = true
                    case .failure(let error):
                        self.solution = "Error: \(error.localizedDescription)"
                        self.showingSolution = true
                    }
                }
            }
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