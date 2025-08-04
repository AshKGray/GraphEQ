//
//  GraphView.swift
//  GraphEQ
//
//  Created by Ashley Gray on 7/30/25.
//

import SwiftUI

/// GraphView is responsible for rendering the 2D Cartesian graph, grid, axes,
/// and user-drawn paths or function plots. It also handles gestures.
struct GraphView: View {
    /// Observes the `GraphViewModel` to react to changes in data, mode, scale, and translation.
    @EnvironmentObject var viewModel: GraphViewModel

    /// Internal state to track the drag gesture's active translation.
    @State private var currentTranslation: CGSize = .zero
    /// Internal state to track the pinch gesture's active scale.
    @State private var currentScale: CGFloat = 1.0

    /// The size of the `Canvas`, used for coordinate transformations.
    @State private var viewSize: CGSize = .zero

    var body: some View {
        ZStack {
            // Background for the graph
            Color.black
                .contentShape(Rectangle()) // Make the whole area tappable/draggable
                .gesture(
                    // MARK: - Drawing or Panning Gesture
                    DragGesture(minimumDistance: 0) // Allows for single taps to register too
                        .onChanged { value in
                            if viewModel.isDrawingMode {
                                // In drawing mode, append point; converted to graph coordinates
                                let graphPoint = viewToGraph(point: value.location, in: viewSize)
                                // Avoid adding duplicate points if too close
                                if let lastPoint = viewModel.drawnPoints.last,
                                   distance(from: lastPoint, to: graphPoint) < 0.1 {
                                    return
                                }
                                viewModel.drawnPoints.append(graphPoint)
                                // Real-time fitting is handled by didSet in viewModel.drawnPoints
                            } else {
                                // In typing/panning mode, update translation for panning
                                currentTranslation = value.translation
                                viewModel.translation = currentTranslation
                                viewModel.updateGraphRanges(viewSize: viewSize)
                            }
                        }
                        .onEnded { value in
                            if viewModel.isDrawingMode {
                                // Drawing ended, final curve fitting handled by viewModel observer
                                // No additional action needed here
                            } else {
                                // Panning ended: reset currentTranslation and commit final translation
                                currentTranslation = .zero
                                viewModel.translation = value.translation
                                viewModel.updateGraphRanges(viewSize: viewSize)
                            }
                        }
                )
                .simultaneousGesture(
                    // MARK: - Zoom Gesture
                    MagnificationGesture()
                        .onChanged { value in
                            currentScale = value // Store the current gesture scale
                            // Apply the gesture scale to the overall view model scale
                            viewModel.scale = currentScale * viewModel.scale // This logic might need refinement for consecutive zooms
                            viewModel.updateGraphRanges(viewSize: viewSize)
                        }
                        .onEnded { value in
                            // When zoom ends, commit the new scale and reset currentScale
                            viewModel.scale *= value
                            currentScale = 1.0 // Reset for the next gesture
                            viewModel.updateGraphRanges(viewSize: viewSize)
                        }
                )

            /// The main drawing canvas for the graph.
            Canvas { context, size in
                // Store the canvas size for coordinate transformations
                DispatchQueue.main.async {
                    if self.viewSize != size {
                        self.viewSize = size
                        viewModel.updateGraphRanges(viewSize: size)
                    }
                }

                // Clear the background
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))

                // MARK: - Draw Grid Lines
                drawGrid(context: context, size: size)

                // MARK: - Draw Axes
                drawAxes(context: context, size: size)

                // MARK: - Draw Function/Drawn Curve
                if !viewModel.dataPoints.isEmpty {
                    var path = Path()
                    // Start path with the first point, adjusted to canvas coordinates
                    let firstPoint = graphToView(point: viewModel.dataPoints[0], in: size)
                    path.move(to: firstPoint)
                    
                    // Add lines for the rest of the points
                    for i in 1..<viewModel.dataPoints.count {
                        let point = graphToView(point: viewModel.dataPoints[i], in: size)
                        path.addLine(to: point)
                    }

                    // Draw with neon pink glow effect
                    context.stroke(path, with: .color(.pink), lineWidth: 3)
                    
                    // Add glow effect by drawing multiple strokes with decreasing opacity
                    for i in 1...3 {
                        context.stroke(path, with: .color(.pink.opacity(0.3 / Double(i))), lineWidth: 3 + CGFloat(i * 2))
                    }
                }

                // MARK: - Draw Live Stroke in Drawing Mode
                if viewModel.isDrawingMode && !viewModel.drawnPoints.isEmpty {
                    var path = Path()
                    let firstDrawnPoint = graphToView(point: viewModel.drawnPoints[0], in: size)
                    path.move(to: firstDrawnPoint)

                    for i in 1..<viewModel.drawnPoints.count {
                        let point = graphToView(point: viewModel.drawnPoints[i], in: size)
                        path.addLine(to: point)
                    }
                    
                    // Draw with neon red glow effect
                    context.stroke(path, with: .color(.red), lineWidth: 3)
                    
                    // Add glow effect
                    for i in 1...3 {
                        context.stroke(path, with: .color(.red.opacity(0.3 / Double(i))), lineWidth: 3 + CGFloat(i * 2))
                    }
                }
            }
            .background(Color.black) // Pure black background
            .clipShape(Rectangle()) // Ensure drawing doesn't go outside the canvas bounds
        }
    }

    // MARK: - Drawing Helper Functions

    /// Draws the grid lines on the canvas with neon green glow.
    private func drawGrid(context: GraphicsContext, size: CGSize) {
        let lineColor = Color.green.opacity(0.3) // Neon green grid lines
        let lineWidth: CGFloat = 0.5

        // Calculate grid spacing based on current view range
        let rangeWidth = viewModel.xRange.upperBound - viewModel.xRange.lowerBound
        let rangeHeight = viewModel.yRange.upperBound - viewModel.yRange.lowerBound
        
        // Determine grid spacing (show grid lines every 1 unit)
        let gridSpacingX = size.width / rangeWidth
        let gridSpacingY = size.height / rangeHeight
        
        // Draw vertical grid lines
        let startX = viewModel.xRange.lowerBound
        let endX = viewModel.xRange.upperBound
        var x = ceil(startX)
        while x <= endX {
            let screenX = (x - startX) * gridSpacingX
            let path = Path { path in
                path.move(to: CGPoint(x: screenX, y: 0))
                path.addLine(to: CGPoint(x: screenX, y: size.height))
            }
            context.stroke(path, with: .color(lineColor), lineWidth: lineWidth)
            x += 1
        }

        // Draw horizontal grid lines
        let startY = viewModel.yRange.lowerBound
        let endY = viewModel.yRange.upperBound
        var y = ceil(startY)
        while y <= endY {
            let screenY = size.height - (y - startY) * gridSpacingY // Flip Y
            let path = Path { path in
                path.move(to: CGPoint(x: 0, y: screenY))
                path.addLine(to: CGPoint(x: size.width, y: screenY))
            }
            context.stroke(path, with: .color(lineColor), lineWidth: lineWidth)
            y += 1
        }
    }

    /// Draws the X and Y axes with neon cyan glow effect.
    private func drawAxes(context: GraphicsContext, size: CGSize) {
        let axisColor = Color.cyan // Neon cyan axes
        let axisWidth: CGFloat = 2.0

        // Calculate grid spacing based on current view range
        let xRange = viewModel.xRange.upperBound - viewModel.xRange.lowerBound
        let yRange = viewModel.yRange.upperBound - viewModel.yRange.lowerBound
        
        let gridSpacingX = size.width / xRange
        let gridSpacingY = size.height / yRange

        // X-Axis (horizontal line at y=0)
        let xAxisY = size.height - (0 - viewModel.yRange.lowerBound) * gridSpacingY // Flip Y
        let xAxisPath = Path { path in
            path.move(to: CGPoint(x: 0, y: xAxisY))
            path.addLine(to: CGPoint(x: size.width, y: xAxisY))
        }
        
        // Draw axis with glow effect
        context.stroke(xAxisPath, with: .color(axisColor), lineWidth: axisWidth)
        for i in 1...2 {
            context.stroke(xAxisPath, with: .color(axisColor.opacity(0.4 / Double(i))), lineWidth: axisWidth + CGFloat(i))
        }

        // Y-Axis (vertical line at x=0)
        let yAxisX = (0 - viewModel.xRange.lowerBound) * gridSpacingX
        let yAxisPath = Path { path in
            path.move(to: CGPoint(x: yAxisX, y: 0))
            path.addLine(to: CGPoint(x: yAxisX, y: size.height))
        }
        
        // Draw axis with glow effect
        context.stroke(yAxisPath, with: .color(axisColor), lineWidth: axisWidth)
        for i in 1...2 {
            context.stroke(yAxisPath, with: .color(axisColor.opacity(0.4 / Double(i))), lineWidth: axisWidth + CGFloat(i))
        }

        // Draw axis labels with neon glow
        let labelColor = Color.cyan

        // Calculate grid spacing based on current view range
        let rangeWidth = viewModel.xRange.upperBound - viewModel.xRange.lowerBound
        let rangeHeight = viewModel.yRange.upperBound - viewModel.yRange.lowerBound
        
        let axisSpacingX = size.width / rangeWidth
        let axisSpacingY = size.height / rangeHeight

        // Origin label
        let originX = (0 - viewModel.xRange.lowerBound) * axisSpacingX
        let originY = size.height - (0 - viewModel.yRange.lowerBound) * axisSpacingY
        let originText = Text("0").font(.caption).foregroundColor(labelColor)
        context.draw(originText, at: CGPoint(x: originX - 10, y: originY + 10))

        // X-axis labels (1 and -1)
        let x1X = (1 - viewModel.xRange.lowerBound) * axisSpacingX
        let x1Y = size.height - (0 - viewModel.yRange.lowerBound) * axisSpacingY
        let x1Text = Text("1").font(.caption).foregroundColor(labelColor)
        context.draw(x1Text, at: CGPoint(x: x1X, y: x1Y + 10))
        
        let xNeg1X = (-1 - viewModel.xRange.lowerBound) * axisSpacingX
        let xNeg1Text = Text("-1").font(.caption).foregroundColor(labelColor)
        context.draw(xNeg1Text, at: CGPoint(x: xNeg1X, y: x1Y + 10))

        // Y-axis labels (1 and -1)
        let y1X = (0 - viewModel.xRange.lowerBound) * axisSpacingX
        let y1Y = size.height - (1 - viewModel.yRange.lowerBound) * axisSpacingY
        let y1Text = Text("1").font(.caption).foregroundColor(labelColor)
        context.draw(y1Text, at: CGPoint(x: y1X - 15, y: y1Y))
        
        let yNeg1Y = size.height - (-1 - viewModel.yRange.lowerBound) * axisSpacingY
        let yNeg1Text = Text("-1").font(.caption).foregroundColor(labelColor)
        context.draw(yNeg1Text, at: CGPoint(x: y1X - 15, y: yNeg1Y))
    }

    // MARK: - Coordinate Transformation Helpers

    /// Converts a point from graph coordinates (mathematical x,y) to view coordinates (SwiftUI points).
    /// - Parameters:
    ///   - point: The `CGPoint` in graph coordinates.
    ///   - size: The size of the `Canvas` view.
    /// - Returns: The `CGPoint` in view coordinates.
    private func graphToView(point: CGPoint, in size: CGSize) -> CGPoint {
        // Calculate the range of graph units represented by the view
        let rangeWidth = viewModel.xRange.upperBound - viewModel.xRange.lowerBound
        let rangeHeight = viewModel.yRange.upperBound - viewModel.yRange.lowerBound

        // Calculate scaling factors from graph units to view points
        let scaleX = size.width / rangeWidth
        let scaleY = size.height / rangeHeight

        // Adjust point relative to the lower-left corner of the graph's visible range
        let adjustedX = point.x - viewModel.xRange.lowerBound
        let adjustedY = point.y - viewModel.yRange.lowerBound

        // Apply scaling and flip Y-axis (SwiftUI origin is top-left, Cartesian is bottom-left)
        let viewX = adjustedX * scaleX
        let viewY = size.height - (adjustedY * scaleY) // Flip Y

        return CGPoint(x: viewX, y: viewY)
    }

    /// Converts a point from view coordinates (SwiftUI points) to graph coordinates (mathematical x,y).
    /// - Parameters:
    ///   - point: The `CGPoint` in view coordinates.
    ///   - size: The size of the `Canvas` view.
    /// - Returns: The `CGPoint` in graph coordinates.
    private func viewToGraph(point: CGPoint, in size: CGSize) -> CGPoint {
        let rangeWidth = viewModel.xRange.upperBound - viewModel.xRange.lowerBound
        let rangeHeight = viewModel.yRange.upperBound - viewModel.yRange.lowerBound

        let scaleX = size.width / rangeWidth
        let scaleY = size.height / rangeHeight

        // Flip Y-axis back
        let adjustedViewY = size.height - point.y

        // Apply inverse scaling and adjust relative to the graph's visible range
        let graphX = (point.x / scaleX) + viewModel.xRange.lowerBound
        let graphY = (adjustedViewY / scaleY) + viewModel.yRange.lowerBound

        return CGPoint(x: graphX, y: graphY)
    }

    /// Calculates the Euclidean distance between two points.
    private func distance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
    }
}
