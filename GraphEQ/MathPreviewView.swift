//
//  MathPreviewView.swift
//  GraphEQ
//
//  Created by Ashley Gray on 8/3/25.
//

import SwiftUI

/// Advanced mathematical preview view that renders true stacked fractions and proper mathematical notation
struct MathPreviewView: View {
    let equation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Render the mathematical expression with proper formatting
            MathExpressionRenderer(expression: equation)
        }
    }
}

/// Renders mathematical expressions with true stacked fractions and proper notation
struct MathExpressionRenderer: View {
    let expression: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(parseExpression(expression), id: \.id) { component in
                renderComponent(component)
            }
        }
    }
    
    @ViewBuilder
    private func renderComponent(_ component: MathComponent) -> some View {
        switch component.type {
        case .text:
            Text(component.content ?? "")
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.white)
        case .fraction:
            renderFraction(component)
        case .exponent:
            renderExponent(component)
        case .squareRoot:
            renderSquareRoot(component)
        case .absoluteValue:
            renderAbsoluteValue(component)
        case .function:
            renderFunction(component)
        }
    }
    
    private func renderFraction(_ component: MathComponent) -> some View {
        VStack(spacing: 1) {
            // Numerator
            HStack(spacing: 2) {
                ForEach(component.numerator ?? [], id: \.id) { subComponent in
                    renderComponent(subComponent)
                }
            }
            
            // Fraction line
            Rectangle()
                .fill(Color.white)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            
            // Denominator
            HStack(spacing: 2) {
                ForEach(component.denominator ?? [], id: \.id) { subComponent in
                    renderComponent(subComponent)
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    private func renderExponent(_ component: MathComponent) -> some View {
        HStack(alignment: .top, spacing: 0) {
            // Base
            HStack(spacing: 2) {
                ForEach(component.base ?? [], id: \.id) { subComponent in
                    renderComponent(subComponent)
                }
            }
            
            // Exponent (superscript)
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 2) {
                    ForEach(component.exponent ?? [], id: \.id) { subComponent in
                        renderComponent(subComponent)
                    }
                }
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white)
                .offset(y: -8)
            }
        }
    }
    
    private func renderSquareRoot(_ component: MathComponent) -> some View {
        HStack(spacing: 2) {
            // Square root symbol
            Text("√")
                .font(.system(size: 18, design: .monospaced))
                .foregroundColor(.white)
            
            // Radicand
            HStack(spacing: 2) {
                ForEach(component.radicand ?? [], id: \.id) { subComponent in
                    renderComponent(subComponent)
                }
            }
        }
    }
    
    private func renderAbsoluteValue(_ component: MathComponent) -> some View {
        HStack(spacing: 2) {
            // Left absolute value bar
            Text("|")
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.white)
            
            // Content
            if let content = component.content {
                Text(content)
                    .font(.system(size: 16, design: .monospaced))
                    .foregroundColor(.white)
            }
            
            // Right absolute value bar
            Text("|")
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.white)
        }
    }
    
    private func renderFunction(_ component: MathComponent) -> some View {
        HStack(spacing: 2) {
            // Function name
            Text(component.functionName ?? "")
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.cyan)
            
            // Opening parenthesis
            Text("(")
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.white)
            
            // Arguments
            HStack(spacing: 2) {
                ForEach(component.arguments ?? [], id: \.id) { subComponent in
                    renderComponent(subComponent)
                }
            }
            
            // Closing parenthesis
            Text(")")
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Expression Parsing
    
    private func parseExpression(_ expression: String) -> [MathComponent] {
        var components: [MathComponent] = []
        var currentIndex = 0
        
        while currentIndex < expression.count {
            let char = String(expression[expression.index(expression.startIndex, offsetBy: currentIndex)])
            
            if char == "(" && isFractionStart(expression, at: currentIndex) {
                // Parse fraction
                if let fraction = parseFraction(expression, startingAt: &currentIndex) {
                    components.append(fraction)
                }
            } else if char == "^" {
                // Parse exponent
                if let exponent = parseExponent(expression, startingAt: &currentIndex) {
                    components.append(exponent)
                }
            } else if char == "√" {
                // Parse square root
                if let squareRoot = parseSquareRoot(expression, startingAt: &currentIndex) {
                    components.append(squareRoot)
                }
            } else if char == "|" {
                // Parse absolute value
                if let absoluteValue = parseAbsoluteValue(expression, startingAt: &currentIndex) {
                    components.append(absoluteValue)
                }
            } else if isFunctionStart(expression, at: currentIndex) {
                // Parse function
                if let function = parseFunction(expression, startingAt: &currentIndex) {
                    components.append(function)
                }
            } else {
                // Regular text
                let textComponent = MathComponent(
                    id: UUID(),
                    type: .text,
                    content: char
                )
                components.append(textComponent)
                currentIndex += 1
            }
        }
        
        return components
    }
    
    private func isFractionStart(_ expression: String, at index: Int) -> Bool {
        // Check if this is the start of a fraction pattern like "(numerator)/(denominator)"
        guard index + 1 < expression.count else { return false }
        
        let nextChar = String(expression[expression.index(expression.startIndex, offsetBy: index + 1)])
        return nextChar != ")" // Simple heuristic - could be improved
    }
    
    private func parseFraction(_ expression: String, startingAt index: inout Int) -> MathComponent? {
        // Parse pattern: (numerator)/(denominator)
        let startIndex = index
        index += 1 // Skip opening parenthesis
        
        var numerator = ""
        var denominator = ""
        var inDenominator = false
        var parenCount = 0
        
        while index < expression.count {
            let char = String(expression[expression.index(expression.startIndex, offsetBy: index)])
            
            if char == "(" {
                parenCount += 1
            } else if char == ")" {
                parenCount -= 1
                if parenCount < 0 {
                    break
                }
            } else if char == "/" && parenCount == 0 {
                inDenominator = true
                index += 1
                continue
            }
            
            if inDenominator {
                denominator += char
            } else {
                numerator += char
            }
            
            index += 1
        }
        
        if !numerator.isEmpty && !denominator.isEmpty {
            return MathComponent(
                id: UUID(),
                type: .fraction,
                numerator: parseExpression(numerator),
                denominator: parseExpression(denominator)
            )
        }
        
        // If parsing failed, revert index and return nil
        index = startIndex
        return nil
    }
    
    private func parseExponent(_ expression: String, startingAt index: inout Int) -> MathComponent? {
        // Parse pattern: base^exponent
        let startIndex = index
        
        // Find the base (everything before ^)
        var base = ""
        var i = index - 1
        while i >= 0 {
            let char = String(expression[expression.index(expression.startIndex, offsetBy: i)])
            if char == " " || char == "+" || char == "-" || char == "*" || char == "/" {
                break
            }
            base = char + base
            i -= 1
        }
        
        index += 1 // Skip ^
        
        // Find the exponent
        var exponent = ""
        while index < expression.count {
            let char = String(expression[expression.index(expression.startIndex, offsetBy: index)])
            if char == " " || char == "+" || char == "-" || char == "*" || char == "/" {
                break
            }
            exponent += char
            index += 1
        }
        
        if !base.isEmpty && !exponent.isEmpty {
            return MathComponent(
                id: UUID(),
                type: .exponent,
                base: parseExpression(base),
                exponent: parseExpression(exponent)
            )
        }
        
        index = startIndex
        return nil
    }
    
    private func parseSquareRoot(_ expression: String, startingAt index: inout Int) -> MathComponent? {
        // Parse pattern: √(radicand)
        let startIndex = index
        index += 1 // Skip √
        
        if index < expression.count && String(expression[expression.index(expression.startIndex, offsetBy: index)]) == "(" {
            index += 1 // Skip opening parenthesis
            
            var radicand = ""
            var parenCount = 1
            
            while index < expression.count {
                let char = String(expression[expression.index(expression.startIndex, offsetBy: index)])
                
                if char == "(" {
                    parenCount += 1
                } else if char == ")" {
                    parenCount -= 1
                    if parenCount == 0 {
                        break
                    }
                }
                
                radicand += char
                index += 1
            }
            
            if !radicand.isEmpty {
                return MathComponent(
                    id: UUID(),
                    type: .squareRoot,
                    radicand: parseExpression(radicand)
                )
            }
        }
        
        index = startIndex
        return nil
    }
    
    private func parseAbsoluteValue(_ expression: String, startingAt index: inout Int) -> MathComponent? {
        // Parse pattern: |content|
        let startIndex = index
        index += 1 // Skip first |
        
        var content = ""
        while index < expression.count {
            let char = String(expression[expression.index(expression.startIndex, offsetBy: index)])
            if char == "|" {
                break
            }
            content += char
            index += 1
        }
        
        if !content.isEmpty {
            return MathComponent(
                id: UUID(),
                type: .absoluteValue,
                content: content
            )
        }
        
        index = startIndex
        return nil
    }
    
    private func isFunctionStart(_ expression: String, at index: Int) -> Bool {
        let functions = ["sin", "cos", "tan", "cot", "sec", "csc", "arcsin", "arccos", "arctan", "ln", "log", "exp", "sinh", "cosh", "tanh"]
        
        for function in functions {
            if index + function.count <= expression.count {
                let substring = String(expression[expression.index(expression.startIndex, offsetBy: index)..<expression.index(expression.startIndex, offsetBy: index + function.count)])
                if substring == function {
                    return true
                }
            }
        }
        return false
    }
    
    private func parseFunction(_ expression: String, startingAt index: inout Int) -> MathComponent? {
        let functions = ["sin", "cos", "tan", "cot", "sec", "csc", "arcsin", "arccos", "arctan", "ln", "log", "exp", "sinh", "cosh", "tanh"]
        
        for function in functions {
            if index + function.count <= expression.count {
                let substring = String(expression[expression.index(expression.startIndex, offsetBy: index)..<expression.index(expression.startIndex, offsetBy: index + function.count)])
                if substring == function {
                    index += function.count
                    
                    // Parse arguments
                    if index < expression.count && String(expression[expression.index(expression.startIndex, offsetBy: index)]) == "(" {
                        index += 1 // Skip opening parenthesis
                        
                        var arguments = ""
                        var parenCount = 1
                        
                        while index < expression.count {
                            let char = String(expression[expression.index(expression.startIndex, offsetBy: index)])
                            
                            if char == "(" {
                                parenCount += 1
                            } else if char == ")" {
                                parenCount -= 1
                                if parenCount == 0 {
                                    break
                                }
                            }
                            
                            arguments += char
                            index += 1
                        }
                        
                        return MathComponent(
                            id: UUID(),
                            type: .function,
                            functionName: function,
                            arguments: parseExpression(arguments)
                        )
                    }
                }
            }
        }
        
        return nil
    }
}

// MARK: - Supporting Types

struct MathComponent {
    let id: UUID
    let type: MathComponentType
    let content: String?
    let numerator: [MathComponent]?
    let denominator: [MathComponent]?
    let base: [MathComponent]?
    let exponent: [MathComponent]?
    let radicand: [MathComponent]?
    let functionName: String?
    let arguments: [MathComponent]?
    
    init(id: UUID = UUID(), type: MathComponentType, content: String? = nil, numerator: [MathComponent]? = nil, denominator: [MathComponent]? = nil, base: [MathComponent]? = nil, exponent: [MathComponent]? = nil, radicand: [MathComponent]? = nil, functionName: String? = nil, arguments: [MathComponent]? = nil) {
        self.id = id
        self.type = type
        self.content = content
        self.numerator = numerator
        self.denominator = denominator
        self.base = base
        self.exponent = exponent
        self.radicand = radicand
        self.functionName = functionName
        self.arguments = arguments
    }
}

enum MathComponentType {
    case text, fraction, exponent, squareRoot, absoluteValue, function
}

// MARK: - Format Conversion Utilities

extension MathPreviewView {
    /// Converts display format to AI-readable format
    static func toAIFormat(_ displayExpression: String) -> String {
        // Convert stacked fractions to parenthetical format
        var aiExpression = displayExpression
        
        // Replace fraction patterns: (numerator)/(denominator) → (numerator)/(denominator)
        // This is already in the correct format for AI processing
        
        return aiExpression
    }
    
    /// Converts AI-readable format to display format
    static func toDisplayFormat(_ aiExpression: String) -> String {
        // Convert parenthetical fractions to stacked display format
        var displayExpression = aiExpression
        
        // This would involve more complex parsing and rendering
        // For now, return the original expression
        return displayExpression
    }
} 