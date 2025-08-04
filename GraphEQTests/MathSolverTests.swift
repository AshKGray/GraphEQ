import XCTest
@testable import GraphEQ

final class MathSolverTests: XCTestCase {
    
    func testDemoSolutionGeneration() {
        // Test derivative solution
        let derivativeProblem = "find the derivative of y = (√x (x² - 1)⁵) / ((x + 2)(x - 4)³)"
        let derivativeSolution = DemoSolutionGenerator.generateDemoSolution(for: derivativeProblem)
        
        XCTAssertTrue(derivativeSolution.contains("y = (√x (x² - 1)⁵) / ((x + 2)(x - 4)³) ← set y = f(x)"))
        XCTAssertTrue(derivativeSolution.contains("ln |y| = ln |(√x (x² - 1)⁵) / ((x + 2)(x - 4)³)| ← apply ln |x|"))
        XCTAssertTrue(derivativeSolution.contains("d/dx (ln |y|) = d/dx"))
        XCTAssertTrue(derivativeSolution.contains("y' = y"))
        
        // Test integral solution
        let integralProblem = "integrate x² + 2x + 1"
        let integralSolution = DemoSolutionGenerator.generateDemoSolution(for: integralProblem)
        
        XCTAssertTrue(integralSolution.contains("∫ (x² + 2x + 1) dx ← set up integral"))
        XCTAssertTrue(integralSolution.contains("∫ x² dx + ∫ 2x dx + ∫ 1 dx ← split into separate integrals"))
        XCTAssertTrue(integralSolution.contains("(x³/3) + x² + x + C ← simplify"))
        
        // Test equation solution
        let equationProblem = "solve 2x² + 5x - 3 = 0"
        let equationSolution = DemoSolutionGenerator.generateDemoSolution(for: equationProblem)
        
        XCTAssertTrue(equationSolution.contains("2x² + 5x - 3 = 0 ← set equation to zero"))
        XCTAssertTrue(equationSolution.contains("x = (-5 ± √(25 - 4(2)(-3))) / (2(2)) ← quadratic formula"))
        XCTAssertTrue(equationSolution.contains("x = 1/2 or x = -3 ← final answer"))
    }
    
    func testMathNotationFormatting() {
        let formatter = MathNotationFormatter.self
        
        // Test basic replacements
        XCTAssertEqual(formatter.formatExpression("sqrt(x)"), "√(x)")
        XCTAssertEqual(formatter.formatExpression("pi"), "π")
        XCTAssertEqual(formatter.formatExpression("infinity"), "∞")
        XCTAssertEqual(formatter.formatExpression("theta"), "θ")
        
        // Test operator spacing
        XCTAssertEqual(formatter.formatExpression("x+y"), "x + y")
        XCTAssertEqual(formatter.formatExpression("x-y"), "x - y")
        XCTAssertEqual(formatter.formatExpression("x=y"), "x = y")
        
        // Test specific cases that should work
        XCTAssertEqual(formatter.formatExpression("times"), "×")
        XCTAssertEqual(formatter.formatExpression("leq"), "≤")
        XCTAssertEqual(formatter.formatExpression("geq"), "≥")
        
        // Test complex expression
        let complexExpression = "sqrt(x^2+y^2)<=infinity"
        let formatted = formatter.formatExpression(complexExpression)
        XCTAssertTrue(formatted.contains("√"))
        XCTAssertTrue(formatted.contains("∞"))
        
        // Test that the formatter handles the actual implementation correctly
        let testExpression = "sqrt(x) + pi times theta"
        let result = formatter.formatExpression(testExpression)
        XCTAssertTrue(result.contains("√"))
        XCTAssertTrue(result.contains("π"))
        XCTAssertTrue(result.contains("θ"))
        XCTAssertTrue(result.contains(" + "))
        XCTAssertTrue(result.contains(" × "))
        
        // Print actual results for debugging
        print("sqrt(x) formatted as: \(formatter.formatExpression("sqrt(x)"))")
        print("x+y formatted as: \(formatter.formatExpression("x+y"))")
        print("sqrt(x) + pi times theta formatted as: \(formatter.formatExpression("sqrt(x) + pi times theta"))")
    }
    
    func testStepParsing() {
        let solution = """
        y = (√x (x² - 1)⁵) / ((x + 2)(x - 4)³) ← set y = f(x)
        ln |y| = ln |(√x (x² - 1)⁵) / ((x + 2)(x - 4)³)| ← apply ln |x|
        ln |y| = ln |√x| + ln |(x² - 1)⁵| - ln |x + 2| - ln |(x - 4)³| ← algebra
        """
        
        let steps = parseSolutionSteps(solution)
        
        XCTAssertEqual(steps.count, 3)
        XCTAssertEqual(steps[0].expression, "y = (√x (x² - 1)⁵) / ((x + 2)(x - 4)³)")
        XCTAssertEqual(steps[0].description, "set y = f(x)")
        XCTAssertEqual(steps[1].expression, "ln |y| = ln |(√x (x² - 1)⁵) / ((x + 2)(x - 4)³)|")
        XCTAssertEqual(steps[1].description, "apply ln |x|")
        XCTAssertEqual(steps[2].expression, "ln |y| = ln |√x| + ln |(x² - 1)⁵| - ln |x + 2| - ln |(x - 4)³|")
        XCTAssertEqual(steps[2].description, "algebra")
    }
    
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
} 
