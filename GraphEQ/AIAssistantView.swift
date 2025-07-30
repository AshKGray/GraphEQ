//
//  AIAssistantView.swift
//  GraphEQ
//
//  Created by Ashley Gray on 7/30/25.
//

import SwiftUI

struct AIAssistantView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var aiViewModel = AIAssistantViewModel()
    @State private var problemInput: String = ""
    @State private var isAskingQuestion: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button("Back") {
                            dismiss()
                        }
                        .foregroundColor(.cyan)
                        .font(.headline)
                        
                        Spacer()
                        
                        Text("AI Assistant")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.cyan)
                            .shadow(color: .cyan.opacity(0.8), radius: 4)
                        
                        Spacer()
                        
                        Button("Clear") {
                            aiViewModel.clearAll()
                            problemInput = ""
                        }
                        .foregroundColor(.cyan)
                        .font(.headline)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    
                    // Main content area
                    ScrollView {
                        VStack(spacing: 16) {
                            // Problem input area
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Enter Problem")
                                    .font(.headline)
                                    .foregroundColor(.cyan)
                                    .shadow(color: .cyan.opacity(0.6), radius: 2)
                                
                                TextField("Enter a math problem to solve step by step...", text: $problemInput, axis: .vertical)
                                    .textFieldStyle(AIAssistantTextFieldStyle())
                                    .lineLimit(3...6)
                                    .onSubmit {
                                        if !problemInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            aiViewModel.solveProblem(problemInput)
                                            problemInput = ""
                                        }
                                    }
                                
                                HStack {
                                    Spacer()
                                    
                                    Button("Solve") {
                                        if !problemInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            aiViewModel.solveProblem(problemInput)
                                            problemInput = ""
                                        }
                                    }
                                    .buttonStyle(AIAssistantButtonStyle())
                                    .disabled(problemInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || aiViewModel.isProcessing)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            
                            // Solution display
                            if !aiViewModel.solutions.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Solution")
                                        .font(.headline)
                                        .foregroundColor(.cyan)
                                        .shadow(color: .cyan.opacity(0.6), radius: 2)
                                        .padding(.horizontal, 16)
                                    
                                    ForEach(Array(aiViewModel.solutions.enumerated()), id: \.offset) { index, solution in
                                        SolutionStepView(
                                            step: solution,
                                            stepNumber: index + 1,
                                            onExplanationRequested: {
                                                aiViewModel.requestExplanation(for: index)
                                            }
                                        )
                                    }
                                }
                            }
                            
                            // General question area
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ask Any Question")
                                    .font(.headline)
                                    .foregroundColor(.cyan)
                                    .shadow(color: .cyan.opacity(0.6), radius: 2)
                                
                                TextField("Ask any math question...", text: $aiViewModel.generalQuestion, axis: .vertical)
                                    .textFieldStyle(AIAssistantTextFieldStyle())
                                    .lineLimit(2...4)
                                    .onSubmit {
                                        if !aiViewModel.generalQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            aiViewModel.askGeneralQuestion()
                                        }
                                    }
                                
                                HStack {
                                    Spacer()
                                    
                                    Button("Ask") {
                                        if !aiViewModel.generalQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            aiViewModel.askGeneralQuestion()
                                        }
                                    }
                                    .buttonStyle(AIAssistantButtonStyle())
                                    .disabled(aiViewModel.generalQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || aiViewModel.isProcessing)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                            
                            // General answer display
                            if !aiViewModel.generalAnswer.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Answer")
                                        .font(.headline)
                                        .foregroundColor(.cyan)
                                        .shadow(color: .cyan.opacity(0.6), radius: 2)
                                    
                                    Text(aiViewModel.generalAnswer)
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct SolutionStepView: View {
    let step: SolutionStep
    let stepNumber: Int
    let onExplanationRequested: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text("Step \(stepNumber)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.cyan)
                    .frame(width: 60, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(step.description)
                        .foregroundColor(.white)
                        .font(.body)
                    
                    if let result = step.result {
                        Text("= \(result)")
                            .foregroundColor(.green)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                Button(action: onExplanationRequested) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.cyan)
                        .font(.system(size: 20))
                }
                .disabled(step.explanation != nil)
            }
            
            if let explanation = step.explanation {
                Text(explanation)
                    .foregroundColor(.gray)
                    .font(.caption)
                    .padding(.leading, 60)
                    .padding(.top, 4)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }
}

struct AIAssistantTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16))
            .foregroundColor(.white)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}

struct AIAssistantButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cyan)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    AIAssistantView()
} 