//
//  StructuredMathInputView.swift
//  GraphEQ
//
//  Created by Ashley Gray on 8/3/25.
//

import SwiftUI

/// Structured mathematical input system with true stacked fractions and template-based input
struct StructuredMathInputView: View {
    let isVisible: Bool
    @Binding var equation: String
    
    // Input state management
    @State private var currentMode: KeyboardMode = .main
    @State private var isFractionOverlayActive: Bool = false
    @State private var incompleteTemplates: [MathTemplate] = []
    @State private var previewEquation: String = ""
    
    // Fraction template state
    @State private var fractionNumerator: String = ""
    @State private var fractionDenominator: String = ""
    @State private var activeFractionBox: FractionBox = .numerator
    
    var body: some View {
        VStack(spacing: 0) {
            // Equation preview area
            equationPreviewArea
            
            // Mode selector tabs
            modeSelectorTabs
            
            // Main keyboard content
            keyboardContent
            
            // Fraction input overlay (when active)
            if isFractionOverlayActive {
                fractionInputOverlay
            }
        }
        .background(Color.black)
        .onChange(of: equation) { _ in
            updatePreview()
        }
        .onAppear {
            updatePreview()
        }
    }
    
    // MARK: - Equation Preview Area
    
    private var equationPreviewArea: some View {
        VStack(spacing: 8) {
            // Live equation preview
            VStack(alignment: .leading, spacing: 4) {
                Text("EQUATION:")
                    .font(.caption)
                    .foregroundColor(.white)
                
                if !previewEquation.isEmpty {
                    Text(previewEquation)
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundColor(.white)
                        .frame(minHeight: 40)
                } else {
                    Text("Enter mathematical expression...")
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Error display
            if !incompleteTemplates.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Complete all templates before proceeding")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Mode Selector Tabs
    
    private var modeSelectorTabs: some View {
        HStack(spacing: 0) {
            ForEach(KeyboardMode.allCases, id: \.self) { mode in
                Button(action: {
                    currentMode = mode
                }) {
                    Text(mode.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(currentMode == mode ? .black : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(currentMode == mode ? Color.cyan : Color.clear)
                        .cornerRadius(6)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - Keyboard Content
    
    @ViewBuilder
    private var keyboardContent: some View {
        switch currentMode {
        case .main:
            mainKeyboard
        case .numbers:
            numberKeyboard
        case .functions:
            functionKeyboard
        case .variables:
            variableKeyboard
        case .symbols:
            symbolKeyboard
        }
    }
    
    // MARK: - Main Keyboard
    
    private var mainKeyboard: some View {
        VStack(spacing: 8) {
            // Row 1: Numbers and Functions
            HStack(spacing: 8) {
                KeyboardButton(title: "123", action: { currentMode = .numbers })
                KeyboardButton(title: "f(x)", action: { currentMode = .functions })
                KeyboardButton(title: "ABC", action: { currentMode = .variables })
                KeyboardButton(title: "#", action: { currentMode = .symbols })
            }
            
            // Row 2: Common Variables
            HStack(spacing: 8) {
                KeyboardButton(title: "x", action: { insertText("x") })
                KeyboardButton(title: "y", action: { insertText("y") })
                KeyboardButton(title: "π", action: { insertText("π") })
                KeyboardButton(title: "e", action: { insertText("e") })
            }
            
            // Row 3: Math Templates (KEY FEATURE)
            HStack(spacing: 8) {
                KeyboardButton(title: "□²", action: { insertExponentTemplate() })
                KeyboardButton(title: "□ⁿ", action: { insertPowerTemplate() })
                KeyboardButton(title: "√□", action: { insertSquareRootTemplate() })
                KeyboardButton(title: "|□|", action: { insertAbsoluteValueTemplate() })
            }
            
            // Row 4: Comparison & Stacked Fractions
            HStack(spacing: 8) {
                KeyboardButton(title: "<", action: { insertText("<") })
                KeyboardButton(title: ">", action: { insertText(">") })
                KeyboardButton(title: "□/□", action: { insertFractionTemplate() })
                KeyboardButton(title: "=", action: { insertText("=") })
            }
            
            // Row 5: Basic Functions
            HStack(spacing: 8) {
                KeyboardButton(title: "ans", action: { insertText("ans") })
                KeyboardButton(title: ",", action: { insertText(",") })
                KeyboardButton(title: "(", action: { insertText("(") })
                KeyboardButton(title: ")", action: { insertText(")") })
            }
            
            // Row 6: Basic Operators
            HStack(spacing: 8) {
                KeyboardButton(title: "+", action: { insertText("+") })
                KeyboardButton(title: "-", action: { insertText("-") })
                KeyboardButton(title: "×", action: { insertText("*") })
                KeyboardButton(title: "÷", action: { insertText("/") })
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Number Keyboard
    
    private var numberKeyboard: some View {
        VStack(spacing: 8) {
            // Numbers 1-9
            ForEach(0..<3) { row in
                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { col in
                        let number = row * 3 + col
                        KeyboardButton(title: "\(number)", action: { insertText("\(number)") })
                    }
                }
            }
            
            // Bottom row: 0, decimal, backspace
            HStack(spacing: 8) {
                KeyboardButton(title: "0", action: { insertText("0") })
                KeyboardButton(title: ".", action: { insertText(".") })
                KeyboardButton(title: "⌫", action: { deleteLastCharacter() })
                KeyboardButton(title: "Done", action: { currentMode = .main })
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Function Keyboard
    
    private var functionKeyboard: some View {
        VStack(spacing: 8) {
            // Trigonometric functions
            HStack(spacing: 8) {
                KeyboardButton(title: "sin", action: { insertFunction("sin") })
                KeyboardButton(title: "cos", action: { insertFunction("cos") })
                KeyboardButton(title: "tan", action: { insertFunction("tan") })
                KeyboardButton(title: "cot", action: { insertFunction("cot") })
            }
            
            HStack(spacing: 8) {
                KeyboardButton(title: "sec", action: { insertFunction("sec") })
                KeyboardButton(title: "csc", action: { insertFunction("csc") })
                KeyboardButton(title: "arcsin", action: { insertFunction("arcsin") })
                KeyboardButton(title: "arccos", action: { insertFunction("arccos") })
            }
            
            // Logarithmic and exponential
            HStack(spacing: 8) {
                KeyboardButton(title: "ln", action: { insertFunction("ln") })
                KeyboardButton(title: "log", action: { insertFunction("log") })
                KeyboardButton(title: "exp", action: { insertFunction("exp") })
                KeyboardButton(title: "e^x", action: { insertText("e^x") })
            }
            
            // Hyperbolic functions
            HStack(spacing: 8) {
                KeyboardButton(title: "sinh", action: { insertFunction("sinh") })
                KeyboardButton(title: "cosh", action: { insertFunction("cosh") })
                KeyboardButton(title: "tanh", action: { insertFunction("tanh") })
                KeyboardButton(title: "Done", action: { currentMode = .main })
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Variable Keyboard
    
    private var variableKeyboard: some View {
        VStack(spacing: 8) {
            // Variables a-z
            ForEach(0..<4) { row in
                HStack(spacing: 8) {
                    ForEach(0..<6) { col in
                        let index = row * 6 + col
                        if index < 26 {
                            let letter = String(Character(UnicodeScalar(97 + index)!))
                            KeyboardButton(title: letter, action: { insertText(letter) })
                        }
                    }
                }
            }
            
            // Greek letters
            HStack(spacing: 8) {
                KeyboardButton(title: "α", action: { insertText("α") })
                KeyboardButton(title: "β", action: { insertText("β") })
                KeyboardButton(title: "γ", action: { insertText("γ") })
                KeyboardButton(title: "δ", action: { insertText("δ") })
                KeyboardButton(title: "θ", action: { insertText("θ") })
                KeyboardButton(title: "π", action: { insertText("π") })
            }
            
            HStack(spacing: 8) {
                KeyboardButton(title: "λ", action: { insertText("λ") })
                KeyboardButton(title: "μ", action: { insertText("μ") })
                KeyboardButton(title: "σ", action: { insertText("σ") })
                KeyboardButton(title: "φ", action: { insertText("φ") })
                KeyboardButton(title: "ψ", action: { insertText("ψ") })
                KeyboardButton(title: "ω", action: { insertText("ω") })
            }
            
            // Constants and Done
            HStack(spacing: 8) {
                KeyboardButton(title: "e", action: { insertText("e") })
                KeyboardButton(title: "∞", action: { insertText("∞") })
                KeyboardButton(title: "Done", action: { currentMode = .main })
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Symbol Keyboard
    
    private var symbolKeyboard: some View {
        VStack(spacing: 8) {
            // Calculus symbols
            HStack(spacing: 8) {
                KeyboardButton(title: "∫", action: { insertText("∫") })
                KeyboardButton(title: "∂", action: { insertText("∂") })
                KeyboardButton(title: "∑", action: { insertText("∑") })
                KeyboardButton(title: "∏", action: { insertText("∏") })
            }
            
            HStack(spacing: 8) {
                KeyboardButton(title: "lim", action: { insertText("lim") })
                KeyboardButton(title: "Δ", action: { insertText("Δ") })
                KeyboardButton(title: "∇", action: { insertText("∇") })
                KeyboardButton(title: "∞", action: { insertText("∞") })
            }
            
            // Comparison symbols
            HStack(spacing: 8) {
                KeyboardButton(title: "≤", action: { insertText("≤") })
                KeyboardButton(title: "≥", action: { insertText("≥") })
                KeyboardButton(title: "≠", action: { insertText("≠") })
                KeyboardButton(title: "≈", action: { insertText("≈") })
            }
            
            // Set theory and other symbols
            HStack(spacing: 8) {
                KeyboardButton(title: "∈", action: { insertText("∈") })
                KeyboardButton(title: "∉", action: { insertText("∉") })
                KeyboardButton(title: "∅", action: { insertText("∅") })
                KeyboardButton(title: "∪", action: { insertText("∪") })
            }
            
            HStack(spacing: 8) {
                KeyboardButton(title: "∩", action: { insertText("∩") })
                KeyboardButton(title: "±", action: { insertText("±") })
                KeyboardButton(title: "Done", action: { currentMode = .main })
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Fraction Input Overlay
    
    private var fractionInputOverlay: some View {
        VStack(spacing: 16) {
            Text("Enter Fraction")
                .font(.headline)
                .foregroundColor(.white)
            
            // Stacked fraction input
            VStack(spacing: 2) {
                // Numerator
                TextField("numerator", text: $fractionNumerator)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(activeFractionBox == .numerator ? Color.cyan.opacity(0.2) : Color.gray.opacity(0.1))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(activeFractionBox == .numerator ? Color.cyan : Color.clear, lineWidth: 2)
                    )
                    .frame(height: 40)
                    .onTapGesture {
                        activeFractionBox = .numerator
                    }
                
                // Fraction line
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 2)
                
                // Denominator
                TextField("denominator", text: $fractionDenominator)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(activeFractionBox == .denominator ? Color.cyan.opacity(0.2) : Color.gray.opacity(0.1))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(activeFractionBox == .denominator ? Color.cyan : Color.clear, lineWidth: 2)
                    )
                    .frame(height: 40)
                    .onTapGesture {
                        activeFractionBox = .denominator
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            
            // Action buttons
            HStack(spacing: 16) {
                Button("Cancel") {
                    cancelFraction()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Insert") {
                    insertFraction()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(fractionNumerator.isEmpty || fractionDenominator.isEmpty)
            }
        }
        .padding(24)
        .background(Color.black.opacity(0.95))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Helper Methods
    
    private func insertText(_ text: String) {
        equation += text
        updatePreview()
    }
    
    private func deleteLastCharacter() {
        if !equation.isEmpty {
            equation.removeLast()
            updatePreview()
        }
    }
    
    private func insertFunction(_ function: String) {
        equation += "\(function)("
        updatePreview()
    }
    
    private func insertExponentTemplate() {
        let template = MathTemplate(type: .exponent, placeholder: "base^exponent")
        incompleteTemplates.append(template)
        equation += "[base]^[exponent]"
        updatePreview()
    }
    
    private func insertPowerTemplate() {
        let template = MathTemplate(type: .power, placeholder: "base^n")
        incompleteTemplates.append(template)
        equation += "[base]^[power]"
        updatePreview()
    }
    
    private func insertSquareRootTemplate() {
        let template = MathTemplate(type: .squareRoot, placeholder: "√(expression)")
        incompleteTemplates.append(template)
        equation += "√([expression])"
        updatePreview()
    }
    
    private func insertAbsoluteValueTemplate() {
        let template = MathTemplate(type: .absoluteValue, placeholder: "|expression|")
        incompleteTemplates.append(template)
        equation += "|[expression]|"
        updatePreview()
    }
    
    private func insertFractionTemplate() {
        isFractionOverlayActive = true
        activeFractionBox = .numerator
    }
    
    private func insertFraction() {
        let fractionText = "(\(fractionNumerator))/(\(fractionDenominator))"
        equation += fractionText
        isFractionOverlayActive = false
        fractionNumerator = ""
        fractionDenominator = ""
        updatePreview()
    }
    
    private func cancelFraction() {
        isFractionOverlayActive = false
        fractionNumerator = ""
        fractionDenominator = ""
    }
    
    private func updatePreview() {
        // Convert equation to display format
        previewEquation = equation
        // TODO: Add proper mathematical formatting conversion
    }
}

// MARK: - Supporting Types

enum KeyboardMode: CaseIterable {
    case main, numbers, functions, variables, symbols
    
    var displayName: String {
        switch self {
        case .main: return "Main"
        case .numbers: return "123"
        case .functions: return "f(x)"
        case .variables: return "ABC"
        case .symbols: return "#"
        }
    }
}

enum FractionBox {
    case numerator, denominator
}

struct MathTemplate: Identifiable {
    let id: UUID
    let type: TemplateType
    let placeholder: String
    
    init(type: TemplateType, placeholder: String, id: UUID = UUID()) {
        self.type = type
        self.placeholder = placeholder
        self.id = id
    }
}

enum TemplateType {
    case exponent, power, squareRoot, absoluteValue
}

// MARK: - Supporting Views

struct KeyboardButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.cyan)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

 
