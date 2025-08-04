//
//  AIAssistantViewModel.swift
//  GraphEQ
//
//  Created by Ashley Gray on 7/30/25.
//

import Foundation
import SwiftUI

@MainActor
final class AIAssistantViewModel: ObservableObject {
    @Published var solutions: [SolutionStep] = []
    @Published var generalQuestion: String = ""
    @Published var generalAnswer: String = ""
    @Published var isProcessing: Bool = false
    
    func solveProblem(_ problem: String) {
    isProcessing = true
    solutions = [] // Clear old solutions
    
    MathSolverService.shared.solveMathProblem(problem) { result in
        DispatchQueue.main.async {
            self.isProcessing = false
            switch result {
            case .success(let solution):
                self.parseAISolution(solution)
            case .failure(let error):
                // Handle error
                self.solutions = [SolutionStep(description: "Error: \(error.localizedDescription)", result: nil, explanation: nil)]
            }
        }
    }
}

private func parseAISolution(_ solution: String) {
    // Parse the AI solution into your SolutionStep format
    let lines = solution.components(separatedBy: .newlines)
    var steps: [SolutionStep] = []
    
    for line in lines {
        if line.contains("←") {
            let parts = line.components(separatedBy: "←")
            if parts.count == 2 {
                let expression = parts[0].trimmingCharacters(in: .whitespaces)
                let description = parts[1].trimmingCharacters(in: .whitespaces)
                steps.append(SolutionStep(description: description, result: expression, explanation: nil))
            }
        }
    }
    
    self.solutions = steps
}
    
    func askGeneralQuestion() {
        isProcessing = true
        
        // Simulate AI processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.generateGeneralAnswer(for: self.generalQuestion)
            self.generalQuestion = ""
            self.isProcessing = false
        }
    }
    
    func requestExplanation(for stepIndex: Int) {
        guard stepIndex < solutions.count else { return }
        
        isProcessing = true
        
        // Simulate AI processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.generateExplanation(for: stepIndex)
            self.isProcessing = false
        }
    }
    
    func clearAll() {
        solutions = []
        generalAnswer = ""
        generalQuestion = ""
    }
    
    // MARK: - Private Methods
    
    private func generateStepByStepSolution(for problem: String) {
        // This is a mock implementation - in a real app, you'd integrate with an AI service
        let lowercasedProblem = problem.lowercased()
        
        if lowercasedProblem.contains("solve") && lowercasedProblem.contains("equation") {
            solutions = [
                SolutionStep(description: "First, let's identify the equation to solve", result: nil, explanation: nil),
                SolutionStep(description: "Move all terms to one side of the equation", result: "x² + 2x - 3 = 0", explanation: nil),
                SolutionStep(description: "Factor the quadratic equation", result: "(x + 3)(x - 1) = 0", explanation: nil),
                SolutionStep(description: "Set each factor equal to zero", result: "x + 3 = 0 or x - 1 = 0", explanation: nil),
                SolutionStep(description: "Solve for x", result: "x = -3 or x = 1", explanation: nil)
            ]
        } else if lowercasedProblem.contains("derivative") || lowercasedProblem.contains("differentiate") {
            solutions = [
                SolutionStep(description: "Identify the function to differentiate", result: "f(x) = x³ + 2x² - 5x + 3", explanation: nil),
                SolutionStep(description: "Apply the power rule to each term", result: "f'(x) = 3x² + 4x - 5", explanation: nil),
                SolutionStep(description: "The derivative is complete", result: "f'(x) = 3x² + 4x - 5", explanation: nil)
            ]
        } else if lowercasedProblem.contains("integral") || lowercasedProblem.contains("integrate") {
            solutions = [
                SolutionStep(description: "Identify the function to integrate", result: "∫(2x + 3) dx", explanation: nil),
                SolutionStep(description: "Apply the power rule for integration", result: "x² + 3x + C", explanation: nil),
                SolutionStep(description: "Add the constant of integration", result: "x² + 3x + C", explanation: nil)
            ]
        } else if lowercasedProblem.contains("limit") {
            solutions = [
                SolutionStep(description: "Identify the limit to evaluate", result: "lim(x→2) (x² - 4)/(x - 2)", explanation: nil),
                SolutionStep(description: "Factor the numerator", result: "lim(x→2) (x + 2)(x - 2)/(x - 2)", explanation: nil),
                SolutionStep(description: "Cancel common factors", result: "lim(x→2) (x + 2)", explanation: nil),
                SolutionStep(description: "Substitute x = 2", result: "4", explanation: nil)
            ]
        } else {
            // Generic solution for other problems
            solutions = [
                SolutionStep(description: "Analyze the problem", result: nil, explanation: nil),
                SolutionStep(description: "Apply relevant mathematical principles", result: nil, explanation: nil),
                SolutionStep(description: "Perform calculations", result: "Result calculated", explanation: nil),
                SolutionStep(description: "Verify the solution", result: "Solution verified", explanation: nil)
            ]
        }
    }
    
    private func generateGeneralAnswer(for question: String) {
        let lowercasedQuestion = question.lowercased()
        
        if lowercasedQuestion.contains("what is") && lowercasedQuestion.contains("derivative") {
            generalAnswer = "A derivative measures how a function changes as its input changes. It represents the rate of change or slope of the function at any given point. For example, if f(x) = x², then f'(x) = 2x, meaning the slope at any point x is 2x."
        } else if lowercasedQuestion.contains("how to") && lowercasedQuestion.contains("integrate") {
            generalAnswer = "To integrate a function, you're essentially finding the antiderivative. For basic functions: ∫xⁿ dx = xⁿ⁺¹/(n+1) + C (where n ≠ -1). For more complex functions, you might need techniques like substitution, integration by parts, or partial fractions."
        } else if lowercasedQuestion.contains("what is") && lowercasedQuestion.contains("limit") {
            generalAnswer = "A limit describes the value that a function approaches as the input approaches some value. For example, lim(x→0) sin(x)/x = 1. Limits are fundamental to calculus and help us understand behavior at points where functions might not be defined."
        } else if lowercasedQuestion.contains("quadratic") && lowercasedQuestion.contains("formula") {
            generalAnswer = "The quadratic formula is x = (-b ± √(b² - 4ac))/(2a) for the equation ax² + bx + c = 0. This formula gives you the solutions (roots) of any quadratic equation. The discriminant (b² - 4ac) tells you about the nature of the roots."
        } else {
            generalAnswer = "I can help you with various mathematical concepts including calculus, algebra, trigonometry, and more. Please ask a specific question and I'll provide a detailed explanation!"
        }
    }
    
    private func generateExplanation(for stepIndex: Int) {
        guard stepIndex < solutions.count else { return }
        
        _ = solutions[stepIndex]
        let explanations = [
            "This step involves identifying the core problem and understanding what needs to be solved.",
            "Here we apply mathematical principles to transform the problem into a more manageable form.",
            "This calculation step uses specific formulas or methods to arrive at the intermediate result.",
            "We verify our work by checking if the result makes sense and satisfies the original problem.",
            "This step simplifies the expression or equation to make it easier to work with.",
            "We use algebraic manipulation to isolate the variable or simplify the expression.",
            "This involves applying a specific mathematical rule or theorem to solve the problem.",
            "We substitute known values or expressions to evaluate the result."
        ]
        
        let explanation = explanations[stepIndex % explanations.count]
        solutions[stepIndex].explanation = explanation
    }
}

struct SolutionStep {
    let description: String
    let result: String?
    var explanation: String?
    
    init(description: String, result: String?, explanation: String?) {
        self.description = description
        self.result = result
        self.explanation = explanation
    }
} 
