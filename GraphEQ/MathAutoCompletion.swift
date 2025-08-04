//
//  MathAutoCompletion.swift
//  GraphEQ
//
//  Created by Ashley Gray on 8/3/25.
//

import SwiftUI

// MARK: - Math Auto-Completion Data Model
struct MathCompletion {
    let id = UUID()
    let display: String
    let insertion: String
    let cursorOffset: Int // Offset from end of insertion to place cursor
    let category: CompletionCategory
    
    enum CompletionCategory {
        case function
        case mathOperator
        case equation
        case symbol
    }
}

// MARK: - Math Auto-Completion Service
@MainActor
final class MathAutoCompletionService: ObservableObject {
    @Published var suggestions: [MathCompletion] = []
    @Published var showSuggestions = false
    
    private let completionMappings: [String: [MathCompletion]] = [
        // Function completions
        "s": [
            MathCompletion(display: "sin()", insertion: "sin()", cursorOffset: 1, category: .function),
            MathCompletion(display: "sqrt()", insertion: "√()", cursorOffset: 1, category: .function),
            MathCompletion(display: "sec()", insertion: "sec()", cursorOffset: 1, category: .function)
        ],
        "si": [
            MathCompletion(display: "sin()", insertion: "sin()", cursorOffset: 1, category: .function)
        ],
        "sq": [
            MathCompletion(display: "sqrt()", insertion: "√()", cursorOffset: 1, category: .function)
        ],
        "c": [
            MathCompletion(display: "cos()", insertion: "cos()", cursorOffset: 1, category: .function),
            MathCompletion(display: "cot()", insertion: "cot()", cursorOffset: 1, category: .function),
            MathCompletion(display: "csc()", insertion: "csc()", cursorOffset: 1, category: .function)
        ],
        "co": [
            MathCompletion(display: "cos()", insertion: "cos()", cursorOffset: 1, category: .function),
            MathCompletion(display: "cot()", insertion: "cot()", cursorOffset: 1, category: .function)
        ],
        "t": [
            MathCompletion(display: "tan()", insertion: "tan()", cursorOffset: 1, category: .function)
        ],
        "ta": [
            MathCompletion(display: "tan()", insertion: "tan()", cursorOffset: 1, category: .function)
        ],
        "l": [
            MathCompletion(display: "ln()", insertion: "ln()", cursorOffset: 1, category: .function),
            MathCompletion(display: "log()", insertion: "log()", cursorOffset: 1, category: .function)
        ],
        "ln": [
            MathCompletion(display: "ln()", insertion: "ln()", cursorOffset: 1, category: .function)
        ],
        "lo": [
            MathCompletion(display: "log()", insertion: "log()", cursorOffset: 1, category: .function)
        ],
        "log": [
            MathCompletion(display: "log()", insertion: "log()", cursorOffset: 1, category: .function)
        ],
        "a": [
            MathCompletion(display: "abs()", insertion: "abs()", cursorOffset: 1, category: .function),
            MathCompletion(display: "arcsin()", insertion: "arcsin()", cursorOffset: 1, category: .function),
            MathCompletion(display: "arccos()", insertion: "arccos()", cursorOffset: 1, category: .function),
            MathCompletion(display: "arctan()", insertion: "arctan()", cursorOffset: 1, category: .function)
        ],
        "ab": [
            MathCompletion(display: "abs()", insertion: "abs()", cursorOffset: 1, category: .function)
        ],
        "ar": [
            MathCompletion(display: "arcsin()", insertion: "arcsin()", cursorOffset: 1, category: .function),
            MathCompletion(display: "arccos()", insertion: "arccos()", cursorOffset: 1, category: .function),
            MathCompletion(display: "arctan()", insertion: "arctan()", cursorOffset: 1, category: .function)
        ],
        "arc": [
            MathCompletion(display: "arcsin()", insertion: "arcsin()", cursorOffset: 1, category: .function),
            MathCompletion(display: "arccos()", insertion: "arccos()", cursorOffset: 1, category: .function),
            MathCompletion(display: "arctan()", insertion: "arctan()", cursorOffset: 1, category: .function)
        ],
        "e": [
            MathCompletion(display: "exp()", insertion: "exp()", cursorOffset: 1, category: .function),
            MathCompletion(display: "e^()", insertion: "e^()", cursorOffset: 1, category: .function)
        ],
        "ex": [
            MathCompletion(display: "exp()", insertion: "exp()", cursorOffset: 1, category: .function)
        ],
        "exp": [
            MathCompletion(display: "exp()", insertion: "exp()", cursorOffset: 1, category: .function)
        ],
        
        // Equation helpers
        "in": [
            MathCompletion(display: "∫() dx", insertion: "∫() dx", cursorOffset: 5, category: .equation)
        ],
        "su": [
            MathCompletion(display: "∑()", insertion: "∑()", cursorOffset: 1, category: .equation)
        ],
        "li": [
            MathCompletion(display: "lim(x→)", insertion: "lim(x→)", cursorOffset: 1, category: .equation)
        ],
        "de": [
            MathCompletion(display: "d/dx()", insertion: "d/dx()", cursorOffset: 1, category: .equation)
        ],
        "pa": [
            MathCompletion(display: "∂/∂x()", insertion: "∂/∂x()", cursorOffset: 1, category: .equation)
        ],
        "cb": [
            MathCompletion(display: "∛()", insertion: "∛()", cursorOffset: 1, category: .function)
        ],
        "fr": [
            MathCompletion(display: "/", insertion: "/", cursorOffset: 0, category: .mathOperator)
        ]
    ]
    
    func updateSuggestions(for input: String) {
        let lowercased = input.lowercased()
        
        // Find matches based on prefixes
        var matches: [MathCompletion] = []
        
        for (prefix, completions) in completionMappings {
            if lowercased.hasSuffix(prefix) {
                matches.append(contentsOf: completions)
            }
        }
        
        // Remove duplicates and limit to 6 suggestions
        let uniqueMatches = Array(Set(matches.map { $0.display }))
            .compactMap { display in
                matches.first { $0.display == display }
            }
            .prefix(6)
        
        DispatchQueue.main.async {
            self.suggestions = Array(uniqueMatches)
            self.showSuggestions = !self.suggestions.isEmpty && !input.isEmpty
        }
    }
    
    func clearSuggestions() {
        DispatchQueue.main.async {
            self.suggestions = []
            self.showSuggestions = false
        }
    }
    
    func validateExpression(_ expression: String) -> Bool {
        // Simplified validation for basic mathematical expressions
        return isPartiallyValid(expression)
    }
    
    private func isPartiallyValid(_ expression: String) -> Bool {
        // Allow partial expressions that are being typed
        let allowedPartials = [
            "sin", "cos", "tan", "ln", "log", "exp", "abs", "sqrt",
            "arcsin", "arccos", "arctan", "sec", "csc", "cot",
            "d/dx", "∂/∂x", "lim", "∫", "∑"
        ]
        
        for partial in allowedPartials {
            if expression.lowercased().contains(partial.lowercased()) {
                return true
            }
        }
        
        return expression.allSatisfy { char in
            char.isLetter || char.isNumber || "()+-*/^=<>≤≥≠πθαβγδ∞∫∑∂√∛".contains(char) || char.isWhitespace
        }
    }
}

// MARK: - Math Auto-Completion View
struct MathAutoCompletionView: View {
    @ObservedObject var completionService: MathAutoCompletionService
    let onSelection: (MathCompletion) -> Void
    
    var body: some View {
        if completionService.showSuggestions && !completionService.suggestions.isEmpty {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(completionService.suggestions, id: \.id) { completion in
                            Button(action: {
                                onSelection(completion)
                            }) {
                                HStack(spacing: 4) {
                                    Text(completion.display)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    // Category indicator
                                    Image(systemName: iconForCategory(completion.category))
                                        .font(.system(size: 10))
                                        .foregroundColor(.cyan.opacity(0.7))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 35)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.9))
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .cyan.opacity(0.2), radius: 4)
            }
        }
    }
    
    private func iconForCategory(_ category: MathCompletion.CompletionCategory) -> String {
        switch category {
        case .function:
            return "function"
        case .mathOperator:
            return "plus.minus"
        case .equation:
            return "equal"
        case .symbol:
            return "textformat"
        }
    }
}

// MARK: - Enhanced Input View with Auto-Completion
struct EnhancedMathInputView: View {
    @Binding var text: String
    @ObservedObject var completionService: MathAutoCompletionService
    @State private var cursorPosition: Int = 0
    
    let placeholder: String
    let onTextChange: (String) -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            // Auto-completion suggestions (appears above input)
            MathAutoCompletionView(completionService: completionService) { completion in
                insertCompletion(completion)
            }
            
            // Main input field
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.pink)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: text) { oldValue, newValue in
                    onTextChange(newValue)
                    completionService.updateSuggestions(for: newValue)
                    
                    // Clear suggestions if text becomes empty
                    if newValue.isEmpty {
                        completionService.clearSuggestions()
                    }
                }
                .onSubmit {
                    completionService.clearSuggestions()
                }
        }
    }
    
    private func insertCompletion(_ completion: MathCompletion) {
        // Insert the completion at the current cursor position
        let insertion = completion.insertion
        text += insertion
        
        // Update suggestions based on new text
        completionService.updateSuggestions(for: text)
        
        // Call the text change handler
        onTextChange(text)
    }
}
