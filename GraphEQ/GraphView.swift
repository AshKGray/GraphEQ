//
//  GraphView.swift
//  GraphEQ
//
//  Created by Ashley Gray on 7/27/25.


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
            Color.clear
                .contentShape(Rectangle()) // Make the whole area tappable/draggable
                .gesture(
                    // MARK: - Drawing Gesture
                    DragGesture(minimumDistance: 0) // Allows for single taps to register too
                        .onChanged { value in
                            if viewModel.isDrawingMode {
                                // Add new point to drawnPoints, converting from view coordinates to graph coordinates
                                let graphPoint = viewToGraph(point: value.location, in: viewSize)
                                if let lastPoint = viewModel.drawnPoints.last,
                                   distance(from: lastPoint, to: graphPoint) < 0.001 {
                                    // Avoid adding duplicate points if very close
                                    return
                                }
                                viewModel.drawnPoints.append(graphPoint)
                            } else {
                                // Panning gesture for typing mode
                                currentTranslation = value.translation
                                viewModel.translation = currentTranslation
                                viewModel.updateGraphRanges(viewSize: viewSize)
                            }
                        }
                        .onEnded { value in
                            if viewModel.isDrawingMode {
                                // When drawing ends, attempt to fit a curve
                                // The `drawnPoints` didSet in ViewModel will trigger fitting
                            } else {
                                // When panning ends, reset currentTranslation and commit to viewModel.translation
                                currentTranslation = .zero
                                viewModel.translation = value.translation // Store final translation
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

                context.translateBy(x: size.width / 2 + viewModel.translation.width, y: size.height / 2 + viewModel.translation.height)
                context.scaleBy(x: viewModel.scale, y: viewModel.scale)


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

                    context.stroke(path, with: .color(.blue), lineWidth: 2)
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
                    context.stroke(path, with: .color(.red), lineWidth: 2)
                }
            }
            .background(Color(.systemBackground)) // Adapts to light/dark mode
            .clipShape(Rectangle()) // Ensure drawing doesn't go outside the canvas bounds
        }
    }

    // MARK: - Drawing Helper Functions

    /// Draws the grid lines on the canvas.
    private func drawGrid(context: GraphicsContext, size: CGSize) {
        let lineColor = Color(.systemGray4).opacity(0.7) // Lighter grid lines
        let lineWidth: CGFloat = 0.5

        // Determine visible range in graph coordinates
        let xMin = viewModel.xRange.lowerBound
        let xMax = viewModel.xRange.upperBound
        let yMin = viewModel.yRange.lowerBound
        let yMax = viewModel.yRange.upperBound

        // Calculate grid spacing based on current scale
        let minGridInterval: CGFloat = 1.0 // Start with 1 unit spacing
        var xInterval = minGridInterval
        var yInterval = minGridInterval

        // Adjust interval dynamically for zoom
        while (xMax - xMin) / xInterval > 20 { xInterval *= 2 } // Too many lines, double interval
        while (xMax - xMin) / xInterval < 5 && xInterval > 0.1 { xInterval /= 2 } // Too few lines, halve interval

        while (yMax - yMin) / yInterval > 20 { yInterval *= 2 }
        while (yMax - yMin) / yInterval < 5 && yInterval > 0.1 { yInterval /= 2 }


        // Draw vertical grid lines
        var xGrid = ceil(xMin / xInterval) * xInterval
        while xGrid <= xMax {
            let start = graphToView(point: CGPoint(x: xGrid, y: yMin), in: size)
            let end = graphToView(point: CGPoint(x: xGrid, y: yMax), in: size)
            var path = Path()
            path.move(to: start)
            path.addLine(to: end)
            context.stroke(path, with: .color(lineColor), lineWidth: lineWidth)
            xGrid += xInterval
        }

        // Draw horizontal grid lines
        var yGrid = ceil(yMin / yInterval) * yInterval
        while yGrid <= yMax {
            let start = graphToView(point: CGPoint(x: xMin, y: yGrid), in: size)
            let end = graphToView(point: CGPoint(x: xMax, y: yGrid), in: size)
            var path = Path()
            path.move(to: start)
            path.addLine(to: end)
            context.stroke(path, with: .color(lineColor), lineWidth: lineWidth)
            yGrid += yInterval
        }
    }

    /// Draws the X and Y axes and their labels.
    private func drawAxes(context: GraphicsContext, size: CGSize) {
        let axisColor = Color(.label) // Adapts to light/dark mode
        let axisWidth: CGFloat = 1.0

        // X-Axis
        let xAxisStart = graphToView(point: CGPoint(x: viewModel.xRange.lowerBound, y: 0), in: size)
        let xAxisEnd = graphToView(point: CGPoint(x: viewModel.xRange.upperBound, y: 0), in: size)
        var xAxisPath = Path()
        xAxisPath.move(to: xAxisStart)
        xAxisPath.addLine(to: xAxisEnd)
        context.stroke(xAxisPath, with: .color(axisColor), lineWidth: axisWidth)

        // Y-Axis
        let yAxisStart = graphToView(point: CGPoint(x: 0, y: viewModel.yRange.lowerBound), in: size)
        let yAxisEnd = graphToView(point: CGPoint(x: 0, y: viewModel.yRange.upperBound), in: size)
        var yAxisPath = Path()
        yAxisPath.move(to: yAxisStart)
        yAxisPath.addLine(to: yAxisEnd)
        context.stroke(yAxisPath, with: .color(axisColor), lineWidth: axisWidth)

        // Draw axis labels (simplified for brevity, showing origin and a few points)
        // You would typically draw labels for each grid line interval.
        _ = Color(.secondaryLabel)

        // Origin label
        let originPoint = graphToView(point: .zero, in: size)
        context.draw(Text("0").font(.caption), at: CGPoint(x: originPoint.x - 10, y: originPoint.y + 10))

        // X-axis label (e.g., at 1, -1)
        if viewModel.xRange.contains(1) {
            let x1Point = graphToView(point: CGPoint(x: 1, y: 0), in: size)
            context.draw(Text("1").font(.caption), at: CGPoint(x: x1Point.x, y: x1Point.y + 10))
        }
        if viewModel.xRange.contains(-1) {
            let xNeg1Point = graphToView(point: CGPoint(x: -1, y: 0), in: size)
            context.draw(Text("-1").font(.caption), at: CGPoint(x: xNeg1Point.x, y: xNeg1Point.y + 10))
        }

        // Y-axis label (e.g., at 1, -1)
        if viewModel.yRange.contains(1) {
            let y1Point = graphToView(point: CGPoint(x: 0, y: 1), in: size)
            context.draw(Text("1").font(.caption), at: CGPoint(x: y1Point.x - 15, y: y1Point.y))
        }
        if viewModel.yRange.contains(-1) {
            let yNeg1Point = graphToView(point: CGPoint(x: 0, y: -1), in: size)
            context.draw(Text("-1").font(.caption), at: CGPoint(x: yNeg1Point.x - 15, y: yNeg1Point.y))
        }
    }


    // MARK: - Coordinate Transformation Helpers

    /// Converts a point from graph coordinates (mathematical x,y) to view coordinates (SwiftUI points).
    /// - Parameters:
    ///   - point: The `CGPoint` in graph coordinates.
    ///   - size: The size of the `Canvas` view.
    /// - Returns: The `CGPoint` in view coordinates.
    private func graphToView(point: CGPoint, in size: CGSize) -> CGPoint {
        // Calculate the range of graph units represented by the view
        let graphWidth = viewModel.xRange.upperBound - viewModel.xRange.lowerBound
        let graphHeight = viewModel.yRange.upperBound - viewModel.yRange.lowerBound

        // Calculate scaling factors from graph units to view points
        let scaleX = size.width / graphWidth
        let scaleY = size.height / graphHeight

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
        let graphWidth = viewModel.xRange.upperBound - viewModel.xRange.lowerBound
        let graphHeight = viewModel.yRange.upperBound - viewModel.yRange.lowerBound

        let scaleX = size.width / graphWidth
        let scaleY = size.height / graphHeight

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
