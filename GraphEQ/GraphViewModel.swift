import Foundation
import SwiftUI
import Combine
import Expression // <-- Ensure this import is present after adding the package



/// GraphViewModel manages the state and logic for the graph and input.
/// It acts as the bridge between the View and the underlying data/logic.
class GraphViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The mathematical expression entered by the user.
    @Published var mathExpression: String = "sin(x)" {
        didSet {
            // Re-evaluate the graph whenever the expression changes (in typing mode)
            if !isDrawingMode {
                parseAndPlotExpression()
            }
        }
    }

    /// The array of points to be rendered on the graph.
    /// These are either computed from `expression` or derived from user drawing.
    @Published var dataPoints: [CGPoint] = []
    
    /// The array of 3D points to be rendered on the graph.
    /// These are computed from multivariable expressions (z = f(x,y)).
    @Published var dataPoints3D: [CGPoint3D] = []

    /// A boolean indicating whether the app is in drawing mode (`true`) or typing mode (`false`).
    @Published var isDrawingMode: Bool = false {
        didSet {
            if isDrawingMode {
                // Clear expression when entering drawing mode, ready for a new draw
                mathExpression = ""
                // Also clear any previous drawing points for a fresh start
                drawnPoints = []
            } else {
                // Re-evaluate the graph based on the current expression when switching back to typing mode
                parseAndPlotExpression()
            }
        }
    }
    
    /// A boolean indicating whether the app is in 3D mode (`true`) or 2D mode (`false`).
    @Published var is3DMode: Bool = false {
        didSet {
            if is3DMode {
                // Switch to 3D mode - clear 2D data and prepare for 3D
                dataPoints = []
                // TODO: Initialize 3D data structures
            } else {
                // Switch back to 2D mode
                parseAndPlotExpression()
            }
        }

    }

    /// Stores the raw points captured during a freehand drawing gesture.
    @Published var drawnPoints: [CGPoint] = [] {
        didSet {
            // If in drawing mode and points are added/changed, try to fit a curve and update expression
            if isDrawingMode && !drawnPoints.isEmpty {
                fitCurveToDrawnPoints()
            } else if isDrawingMode && drawnPoints.isEmpty {
                // If drawn points are cleared in drawing mode, clear expression too
                mathExpression = ""
                dataPoints = []
            }
        }
    }

    /// The current error message, if any, for validation or parsing failures.
    @Published var errorMessage: String? = nil

    /// The current translation (pan) offset for the graph.
    @Published var translation: CGSize = .zero

    /// The current zoom scale for the graph.
    @Published var scale: CGFloat = 1.0
    
    /// The currently selected input tab.
    @Published var selectedTab: InputTab = .equation
    
    /// Whether to show the symbols popup.
    @Published var showSymbolsPopup: Bool = false

    // MARK: - Internal State for Graph View

    /// The visible X-range of the graph, considering scale and translation.
    @Published var xRange: ClosedRange<CGFloat> = -5.0...5.0
    /// The visible Y-range of the graph, considering scale and translation.
    @Published var yRange: ClosedRange<CGFloat> = -5.0...5.0
    
    /// X-axis minimum value for UI binding
    @Published var xMin: CGFloat = -5.0
    /// X-axis maximum value for UI binding
    @Published var xMax: CGFloat = 5.0
    /// Y-axis minimum value for UI binding
    @Published var yMin: CGFloat = -5.0
    /// Y-axis maximum value for UI binding
    @Published var yMax: CGFloat = 5.0

    // MARK: - Initializer

    init() {
        // Set a default expression that should work
        mathExpression = "sin(x)"
        // Initial parsing when the ViewModel is created
        parseAndPlotExpression()
    }

    // MARK: - Public Methods
    
    /// Inserts a mathematical symbol into the current expression.
    func insertSymbol(_ symbol: MathSymbol) {
        switch symbol {
        case .sin, .cos, .tan, .log, .ln, .exp:
            mathExpression += "\(symbol.display)()"
        case .xSquared:
            mathExpression += "x^2"
        case .xCubed:
            mathExpression += "x^3"
        case .xPowerN:
            mathExpression += "x^n"
        case .xInverse:
            mathExpression += "x^-1"
        case .x1:
            mathExpression += "x_1"
        case .x2:
            mathExpression += "x_2"
        case .xN:
            mathExpression += "x_n"
        case .xI:
            mathExpression += "x_i"
        default:
            mathExpression += symbol.display
        }
    }

    /// Resets the graph view to its default scale, translation, and clears drawing/expression.
    func resetView() {
        mathExpression = "sin(x)" // Default expression
        drawnPoints = []
        isDrawingMode = false // Ensure we are back in typing mode
        translation = .zero
        scale = 1.0
        xRange = -5.0...5.0
        yRange = -5.0...5.0
        errorMessage = nil
        parseAndPlotExpression() // Re-parse the default expression
    }

    /// Updates the graph ranges based on current scale and translation.
    /// This should be called whenever `scale` or `translation` changes.
    func updateGraphRanges(viewSize: CGSize) {
        let defaultXRange: ClosedRange<CGFloat> = -5.0...5.0
        let defaultYRange: ClosedRange<CGFloat> = -5.0...5.0

        // Adjust for scale
        let scaledWidth = defaultXRange.upperBound * 2 / scale
        let scaledHeight = defaultYRange.upperBound * 2 / scale

        // Calculate current center in graph coordinates
        let currentCenterX = (defaultXRange.lowerBound + defaultXRange.upperBound) / 2.0
        let currentCenterY = (defaultYRange.lowerBound + defaultYRange.upperBound) / 2.0

        // Convert translation from points to graph units.
        // Assuming defaultXRange.upperBound * 2 corresponds to viewSize.width
        let xTranslationInGraphUnits = translation.width / viewSize.width * (defaultXRange.upperBound * 2) / scale
        let yTranslationInGraphUnits = translation.height / viewSize.height * (defaultYRange.upperBound * 2) / scale

        // Apply translation to the center
        let newCenterX = currentCenterX - xTranslationInGraphUnits
        let newCenterY = currentCenterY + yTranslationInGraphUnits // Y-axis is inverted in SwiftUI vs. Cartesian

        xRange = (newCenterX - scaledWidth / 2.0)...(newCenterX + scaledWidth / 2.0)
        yRange = (newCenterY - scaledHeight / 2.0)...(newCenterY + scaledHeight / 2.0)
    }
    
    /// Zooms in by reducing the visible range (showing less of the graph).
    func zoomIn() {
        let zoomFactor: CGFloat = 0.8
        let centerX = (xRange.lowerBound + xRange.upperBound) / 2
        let centerY = (yRange.lowerBound + yRange.upperBound) / 2
        let newWidth = (xRange.upperBound - xRange.lowerBound) * zoomFactor
        let newHeight = (yRange.upperBound - yRange.lowerBound) * zoomFactor
        
        xRange = (centerX - newWidth / 2)...(centerX + newWidth / 2)
        yRange = (centerY - newHeight / 2)...(centerY + newHeight / 2)
        
        // Update UI bindings
        xMin = xRange.lowerBound
        xMax = xRange.upperBound
        yMin = yRange.lowerBound
        yMax = yRange.upperBound
    }
    
    /// Zooms out by increasing the visible range (showing more of the graph).
    func zoomOut() {
        let zoomFactor: CGFloat = 1.25
        let centerX = (xRange.lowerBound + xRange.upperBound) / 2
        let centerY = (yRange.lowerBound + yRange.upperBound) / 2
        let newWidth = (xRange.upperBound - xRange.lowerBound) * zoomFactor
        let newHeight = (yRange.upperBound - yRange.lowerBound) * zoomFactor
        
        xRange = (centerX - newWidth / 2)...(centerX + newWidth / 2)
        yRange = (centerY - newHeight / 2)...(centerY + newHeight / 2)
        
        // Update UI bindings
        xMin = xRange.lowerBound
        xMax = xRange.upperBound
        yMin = yRange.lowerBound
        yMax = yRange.upperBound
    }

    // MARK: - Private Methods (Expression Parsing & Plotting)

    /// Parses the `expression` string and populates `dataPoints` for plotting.
    /// Now uses ExpressionKit for robust parsing.
    internal func parseAndPlotExpression() {
        if is3DMode {
            parseAndPlot3DExpression()
        } else {
            parseAndPlot2DExpression()
        }
    }
    
    /// Parses 2D expressions (y = f(x)) and populates `dataPoints`.
    private func parseAndPlot2DExpression() {
        errorMessage = nil // Clear previous errors
        guard !mathExpression.isEmpty else {
            dataPoints = []
            return
        }

        var points: [CGPoint] = []
        let numSamples: Int = 200 // Number of points to plot for smoothness

        // Determine a reasonable X range for plotting based on current view range
        let plotXMin = xRange.lowerBound
        let plotXMax = xRange.upperBound
        let xStep = (plotXMax - plotXMin) / CGFloat(numSamples - 1)

        // Use Expression library for robust parsing
        for i in 0..<numSamples {
            let x = plotXMin + CGFloat(i) * xStep
            
            do {
                let expression = Expression(mathExpression, constants: ["x": Double(x)])
                let y = try expression.evaluate()
                
                if y.isFinite {
                    points.append(CGPoint(x: x, y: CGFloat(y)))
                }
            } catch {
                // Skip this point if evaluation fails
                continue
            }
        }
        dataPoints = points
    }
    
    /// Parses 3D expressions (z = f(x,y)) and populates `dataPoints3D`.
    private func parseAndPlot3DExpression() {
        errorMessage = nil // Clear previous errors
        guard !mathExpression.isEmpty else {
            dataPoints3D = []
            return
        }
        
        // TODO: Implement 3D expression parsing
        // For now, create a simple surface for testing
        var points3D: [CGPoint3D] = []
        let gridSize = 20
        let xStep = (xRange.upperBound - xRange.lowerBound) / CGFloat(gridSize - 1)
        let yStep = (yRange.upperBound - yRange.lowerBound) / CGFloat(gridSize - 1)
        
        for i in 0..<gridSize {
            for j in 0..<gridSize {
                let x = xRange.lowerBound + CGFloat(i) * xStep
                let y = yRange.lowerBound + CGFloat(j) * yStep
                
                // Simple test surface: z = x + y
                let z = x + y
                
                points3D.append(CGPoint3D(x: x, y: y, z: z))
            }
        }
        
        dataPoints3D = points3D
    }
    
    /// Evaluates mathematical expressions using the Expression library
    private func evaluateExpression(_ expression: String, x: CGFloat) -> CGFloat? {
        do {
            let expr = Expression(expression, constants: ["x": Double(x)])
            let result = try expr.evaluate()
            return result.isFinite ? CGFloat(result) : nil
        } catch {
            return nil
        }
    }

    // MARK: - Private Methods (Drawing & Curve Fitting)

    /// Attempts to fit a curve to the `drawnPoints` and update the `expression`.
    /// This is a very basic polynomial regression for demonstration.
    /// For robust curve fitting, consider a dedicated numerical library.
    func fitCurveToDrawnPoints() {
        errorMessage = nil
        guard drawnPoints.count > 1 else {
            mathExpression = "" // Not enough points to fit a curve
            return
        }

        // Convert drawnPoints to arrays of Doubles for the fitting algorithm
        let xs = drawnPoints.map { Double($0.x) }
        let ys = drawnPoints.map { Double($0.y) }

        // Use a simple polynomial regression (e.g., degree 1 for linear, 2 for quadratic)
        // For demonstration, let's try a linear fit if points are few, otherwise quadratic.
        let degree = drawnPoints.count > 3 ? 2 : 1 // Try quadratic if enough points, else linear

        if let coefficients = CurveFitter.polynomialRegression(x: xs, y: ys, degree: degree) {
            // Construct the equation string from coefficients
            var equation = ""
            for (index, coef) in coefficients.enumerated() {
                let sign = coef >= 0 ? "+" : ""
                let term = abs(coef).format(f: ".3") // Format to 3 decimal places

                if index == 0 {
                    equation += "\(term)" // Constant term
                } else if index == 1 {
                    equation += "\(sign)\(term)*x" // Linear term
                } else {
                    // Higher degree terms
                    equation += "\(sign)\(term)*x^\(index)"
                }
            }
            mathExpression = equation.replacingOccurrences(of: "+-", with: "-") // Clean up double signs
            // The `expression` setter will automatically call parseAndPlotExpression()
        } else {
            errorMessage = "Unable to fit curve. Try drawing more smoothly."
            mathExpression = ""
            dataPoints = []
        }
    }
}

// Helper extension for formatting doubles
extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
