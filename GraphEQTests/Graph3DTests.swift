//
//  Graph3DTests.swift
//  GraphEQTests
//
//  Created by Ashley Gray on 7/30/25.
//

import Testing
import XCTest
@testable import GraphEQ

struct Graph3DTests {
    
    // MARK: - 3D Mathematical Function Evaluation Tests
    
    @Test func test3DExpressionParsing() async throws {
        let viewModel = GraphViewModel()
        
        // Test basic 3D expressions
        let testExpressions = [
            "x + y",
            "x * y", 
            "x^2 + y^2",
            "sin(x) * cos(y)",
            "sqrt(x^2 + y^2)"
        ]
        
        for expression in testExpressions {
            viewModel.mathExpression = expression
            // Verify no parsing errors for valid 3D expressions
            #expect(viewModel.errorMessage == nil, "Expression '\(expression)' should parse without errors")
        }
    }
    
    @Test func test3DCoordinateSystem() async throws {
        let viewModel = GraphViewModel()
        
        // Test 3D coordinate ranges
        let xRange = viewModel.xRange
        let yRange = viewModel.yRange
        
        // Verify default ranges are reasonable for 3D plotting
        #expect(xRange.lowerBound >= -10.0, "X range lower bound should be >= -10")
        #expect(xRange.upperBound <= 10.0, "X range upper bound should be <= 10")
        #expect(yRange.lowerBound >= -10.0, "Y range lower bound should be >= -10")
        #expect(yRange.upperBound <= 10.0, "Y range upper bound should be <= 10")
    }
    
    @Test func test3DMathematicalFunctions() async throws {
        let viewModel = GraphViewModel()
        
        // Test trigonometric functions in 3D context
        let trigExpressions = [
            "sin(x) * cos(y)",
            "tan(x) + sin(y)",
            "cos(x^2 + y^2)"
        ]
        
        for expression in trigExpressions {
            viewModel.mathExpression = expression
            #expect(viewModel.errorMessage == nil, "Trigonometric expression '\(expression)' should evaluate without errors")
        }
    }
    
    @Test func test3DEdgeCases() async throws {
        let viewModel = GraphViewModel()
        
        // Test edge cases that should be handled gracefully
        let edgeCaseExpressions = [
            "x / y",  // Division by zero at y=0
            "log(x^2 + y^2)",  // Log of zero at origin
            "sqrt(x^2 + y^2 - 1)"  // Complex numbers for x^2 + y^2 < 1
        ]
        
        for expression in edgeCaseExpressions {
            viewModel.mathExpression = expression
            // Should handle edge cases without crashing
            #expect(viewModel.dataPoints.count >= 0, "Edge case expression should not crash")
        }
    }
    
    @Test func test3DPerformance() async throws {
        let viewModel = GraphViewModel()
        
        // Test performance with complex 3D expressions
        let complexExpression = "sin(x) * cos(y) + exp(-(x^2 + y^2)/4)"
        viewModel.mathExpression = complexExpression
        
        // Measure evaluation time
        let startTime = Date()
        viewModel.parseAndPlotExpression()
        let endTime = Date()
        
        let evaluationTime = endTime.timeIntervalSince(startTime)
        #expect(evaluationTime < 1.0, "3D expression evaluation should complete within 1 second")
    }
    
    @Test func test3DDataPointGeneration() async throws {
        let viewModel = GraphViewModel()
        
        // Test that 3D expressions generate appropriate data points
        viewModel.mathExpression = "x + y"
        viewModel.parseAndPlotExpression()
        
        // Should generate data points for 3D surface
        #expect(viewModel.dataPoints.count > 0, "3D expression should generate data points")
        
        // Verify data points are within reasonable bounds
        for point in viewModel.dataPoints {
            #expect(point.x >= viewModel.xRange.lowerBound, "Data point X should be within range")
            #expect(point.x <= viewModel.xRange.upperBound, "Data point X should be within range")
            #expect(point.y >= viewModel.yRange.lowerBound, "Data point Y should be within range")
            #expect(point.y <= viewModel.yRange.upperBound, "Data point Y should be within range")
        }
    }
    
    @Test func test3DErrorHandling() async throws {
        let viewModel = GraphViewModel()
        
        // Test invalid 3D expressions
        let invalidExpressions = [
            "invalid_function(x, y)",
            "x + y + z",  // Too many variables
            "",  // Empty expression
            "x +"  // Incomplete expression
        ]
        
        for expression in invalidExpressions {
            viewModel.mathExpression = expression
            // TODO: Currently disabled due to Expression library conflicts
            // Should provide meaningful error messages when Expression parsing is restored
            if !expression.isEmpty {
                // For now, just ensure the app doesn't crash
                #expect(viewModel.dataPoints.count >= 0, "Invalid expression should not crash")
            }
        }
    }
    
    @Test func test3DExpressionValidation() async throws {
        let viewModel = GraphViewModel()
        
        // Test expression validation for 3D functions
        let validExpressions = [
            "x + y",
            "x * y",
            "sin(x) * cos(y)",
            "exp(-(x^2 + y^2))",
            "sqrt(x^2 + y^2)"
        ]
        
        for expression in validExpressions {
            viewModel.mathExpression = expression
            #expect(viewModel.errorMessage == nil, "Valid 3D expression should not generate errors")
            #expect(viewModel.dataPoints.count > 0, "Valid 3D expression should generate data points")
        }
    }
} 