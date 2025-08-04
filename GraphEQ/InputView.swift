//
//  InputView.swift
//  GraphEQ
//
//  Created by Ashley Gray on 7/30/25.
//

import SwiftUI

struct InputView: View {
    @EnvironmentObject var viewModel: GraphViewModel
    @EnvironmentObject var completionService: MathAutoCompletionService
    @State private var expressionInput: String = ""
    @State private var showSymbolsPopup: Bool = false
    @State private var showStructuredInput: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Auto-completion suggestions (appears above input field)
            if completionService.showSuggestions {
                MathAutoCompletionView(completionService: completionService) { completion in
                    insertCompletion(completion)
                }
                .padding(.horizontal, 16)
            }
            
            // Equation input field with structured input toggle
            HStack {
                Text("Equation:")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(1)
                
                TextField(viewModel.is3DMode ? "z = " : "y = ", text: $expressionInput)
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(.pink)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: expressionInput) { oldValue, newValue in
                        print("📝 Input changed from '\(oldValue)' to '\(newValue)'")
                        
                        // Update auto-completion suggestions
                        completionService.updateSuggestions(for: newValue)
                        
                        if !viewModel.isDrawingMode {
                            // Convert to lowercase for case-insensitive function names
                            let normalizedValue = normalizeExpression(newValue)
                            viewModel.mathExpression = normalizedValue
                            print("🔄 Updated viewModel.mathExpression to '\(normalizedValue)'")
                        }
                    }
                    .onChange(of: viewModel.mathExpression) { oldValue, newValue in
                        print("🔄 ViewModel expression changed from '\(oldValue)' to '\(newValue)'")
                        // Sync the input field when the view model changes
                        if expressionInput != newValue {
                            expressionInput = newValue
                            print("🔄 Synced input field to '\(newValue)'")
                        }
                    }
                    .onAppear {
                        expressionInput = viewModel.mathExpression
                        print("📱 InputView appeared with expression: '\(viewModel.mathExpression)'")
                    }
                    .onSubmit {
                        print("✅ TextField submitted with value: '\(expressionInput)'")
                        completionService.clearSuggestions()
                        if !viewModel.isDrawingMode {
                            let normalizedValue = normalizeExpression(expressionInput)
                            viewModel.mathExpression = normalizedValue
                            print("🔄 Submitted expression: '\(normalizedValue)'")
                        }
                    }
                
                // Structured input toggle button
                Button(action: {
                    showStructuredInput.toggle()
                }) {
                    Image(systemName: "keyboard")
                        .foregroundColor(.cyan)
                        .font(.system(size: 16, weight: .medium))
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(red: 0.067, green: 0.067, blue: 0.067))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(red: 0.267, green: 0.267, blue: 0.267), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            
            // Error message with SwiftMath validation
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption2)
                    .padding(.horizontal)
            } else if !expressionInput.isEmpty && !completionService.validateExpression(expressionInput) {
                Text("Expression may be incomplete or invalid")
                    .foregroundColor(.orange)
                    .font(.caption2)
                    .padding(.horizontal)
            }
            
            // Structured math input overlay
            if showStructuredInput {
                StructuredMathInputView(
                    isVisible: showStructuredInput,
                    equation: $expressionInput
                )
                .onChange(of: expressionInput) { _, newValue in
                    // Update view model when structured input changes
                    if !viewModel.isDrawingMode {
                        let normalizedValue = normalizeExpression(newValue)
                        viewModel.mathExpression = normalizedValue
                    }
                }
            }
        }
    }
    
    private func insertCompletion(_ completion: MathCompletion) {
        // Find the last word/prefix to replace
        let words = expressionInput.components(separatedBy: CharacterSet.alphanumerics.inverted)
        if let lastWord = words.last, !lastWord.isEmpty {
            // Replace the last word with the completion
            let range = expressionInput.range(of: lastWord, options: .backwards)
            if let range = range {
                expressionInput.replaceSubrange(range, with: completion.insertion)
            } else {
                expressionInput += completion.insertion
            }
        } else {
            expressionInput += completion.insertion
        }
        
        // Clear suggestions after insertion
        completionService.clearSuggestions()
        
        // Update the view model
        if !viewModel.isDrawingMode {
            let normalizedValue = normalizeExpression(expressionInput)
            viewModel.mathExpression = normalizedValue
        }
    }
    
    /// Normalizes expression to handle case sensitivity for function names
    private func normalizeExpression(_ expression: String) -> String {
        var normalized = expression
        
        // Convert common function names to lowercase
        let functionMappings = [
            "Tan": "tan",
            "TAN": "tan",
            "Sin": "sin", 
            "SIN": "sin",
            "Cos": "cos",
            "COS": "cos",
            "Log": "log",
            "LOG": "log",
            "Ln": "ln",
            "LN": "ln",
            "Exp": "exp",
            "EXP": "exp",
            "Sqrt": "sqrt",
            "SQRT": "sqrt",
            "Abs": "abs",
            "ABS": "abs"
        ]
        
        for (upper, lower) in functionMappings {
            normalized = normalized.replacingOccurrences(of: upper, with: lower)
        }
        
        return normalized
    }
}

// MARK: - TextField Style

struct EquationInputStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16, weight: .medium, design: .monospaced))
            .foregroundColor(.cyan)
            .padding(10)
            .background(Color(red: 0.133, green: 0.133, blue: 0.133))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(red: 0.4, green: 0.4, blue: 0.4), lineWidth: 1)
            )
            .cornerRadius(6)
    }
}

#Preview {
    InputView()
        .environmentObject(GraphViewModel())
}
