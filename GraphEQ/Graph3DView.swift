//
//  Graph3DView.swift
//  GraphEQ
//
//  Created by Ashley Gray on 7/30/25.
//

import SwiftUI
import CoreGraphics

/// Graph3DView is responsible for rendering 3D surfaces and handling 3D camera controls
struct Graph3DView: View {
    /// Observes the `GraphViewModel` to react to changes in 3D data and camera
    @EnvironmentObject var viewModel: GraphViewModel
    
    /// Internal state for 3D camera controls
    @State private var camera: Camera3D = Camera3D()
    @State private var rotationX: Double = 0.0
    @State private var rotationY: Double = 0.0
    @State private var zoom: Double = 1.0
    
    /// The size of the Canvas, used for coordinate transformations
    @State private var viewSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Background for the 3D graph
            Color.black
                .contentShape(Rectangle())
                .gesture(
                    // 3D rotation gesture
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            let sensitivity: Double = 0.01
                            rotationY += Double(value.translation.width) * sensitivity
                            rotationX += Double(value.translation.height) * sensitivity
                            
                            // Update camera position based on rotation
                            updateCameraPosition()
                        }
                )
                .simultaneousGesture(
                    // 3D zoom gesture
                    MagnificationGesture()
                        .onChanged { value in
                            zoom = Double(value)
                            updateCameraPosition()
                        }
                )
            
            /// The main 3D rendering canvas
            Canvas { context, size in
                // Store the canvas size for coordinate transformations
                DispatchQueue.main.async {
                    if self.viewSize != size {
                        self.viewSize = size
                    }
                }
                
                // Clear the background
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))
                
                // Draw 3D grid
                draw3DGrid(context: context, size: size)
                
                // Draw 3D axes
                draw3DAxes(context: context, size: size)
                
                // Draw 3D surface
                if !viewModel.dataPoints3D.isEmpty {
                    draw3DSurface(context: context, size: size)
                }
            }
            .background(Color.black)
            .clipShape(Rectangle())
        }
        .onAppear {
            // Initialize camera position
            updateCameraPosition()
        }
    }
    
    // MARK: - 3D Drawing Functions
    
    /// Draws a 3D grid on the canvas
    private func draw3DGrid(context: GraphicsContext, size: CGSize) {
        let gridColor = Color.green.opacity(0.2)
        let lineWidth: CGFloat = 0.5
        
        let gridSize = 10
        let step = (viewModel.xRange.upperBound - viewModel.xRange.lowerBound) / CGFloat(gridSize)
        
        // Draw X-Y grid lines
        for i in 0...gridSize {
            let x = viewModel.xRange.lowerBound + CGFloat(i) * step
            let y = viewModel.yRange.lowerBound + CGFloat(i) * step
            
            // X-direction lines
            let startPoint = project3DTo2D(CGPoint3D(x: x, y: viewModel.yRange.lowerBound, z: 0), size: size)
            let endPoint = project3DTo2D(CGPoint3D(x: x, y: viewModel.yRange.upperBound, z: 0), size: size)
            
            let xPath = Path { path in
                path.move(to: startPoint)
                path.addLine(to: endPoint)
            }
            context.stroke(xPath, with: .color(gridColor), lineWidth: lineWidth)
            
            // Y-direction lines
            let yStartPoint = project3DTo2D(CGPoint3D(x: viewModel.xRange.lowerBound, y: y, z: 0), size: size)
            let yEndPoint = project3DTo2D(CGPoint3D(x: viewModel.xRange.upperBound, y: y, z: 0), size: size)
            
            let yPath = Path { path in
                path.move(to: yStartPoint)
                path.addLine(to: yEndPoint)
            }
            context.stroke(yPath, with: .color(gridColor), lineWidth: lineWidth)
        }
    }
    
    /// Draws 3D axes with labels
    private func draw3DAxes(context: GraphicsContext, size: CGSize) {
        let axisWidth: CGFloat = 2.0
        
        // X-axis (red)
        let xAxisStart = project3DTo2D(CGPoint3D(x: viewModel.xRange.lowerBound, y: 0, z: 0), size: size)
        let xAxisEnd = project3DTo2D(CGPoint3D(x: viewModel.xRange.upperBound, y: 0, z: 0), size: size)
        
        let xAxisPath = Path { path in
            path.move(to: xAxisStart)
            path.addLine(to: xAxisEnd)
        }
        context.stroke(xAxisPath, with: .color(.red), lineWidth: axisWidth)
        
        // Y-axis (green)
        let yAxisStart = project3DTo2D(CGPoint3D(x: 0, y: viewModel.yRange.lowerBound, z: 0), size: size)
        let yAxisEnd = project3DTo2D(CGPoint3D(x: 0, y: viewModel.yRange.upperBound, z: 0), size: size)
        
        let yAxisPath = Path { path in
            path.move(to: yAxisStart)
            path.addLine(to: yAxisEnd)
        }
        context.stroke(yAxisPath, with: .color(.green), lineWidth: axisWidth)
        
        // Z-axis (blue)
        let zAxisStart = project3DTo2D(CGPoint3D(x: 0, y: 0, z: -5), size: size)
        let zAxisEnd = project3DTo2D(CGPoint3D(x: 0, y: 0, z: 5), size: size)
        
        let zAxisPath = Path { path in
            path.move(to: zAxisStart)
            path.addLine(to: zAxisEnd)
        }
        context.stroke(zAxisPath, with: .color(.blue), lineWidth: axisWidth)
        
        // Draw axis labels
        let labelColor = Color.white
        let originPoint = project3DTo2D(CGPoint3D(x: 0, y: 0, z: 0), size: size)
        
        let originText = Text("O").font(.caption).foregroundColor(labelColor)
        context.draw(originText, at: CGPoint(x: originPoint.x - 5, y: originPoint.y - 10))
        
        let xLabelPoint = project3DTo2D(CGPoint3D(x: viewModel.xRange.upperBound + 0.5, y: 0, z: 0), size: size)
        let xLabelText = Text("X").font(.caption).foregroundColor(.red)
        context.draw(xLabelText, at: xLabelPoint)
        
        let yLabelPoint = project3DTo2D(CGPoint3D(x: 0, y: viewModel.yRange.upperBound + 0.5, z: 0), size: size)
        let yLabelText = Text("Y").font(.caption).foregroundColor(.green)
        context.draw(yLabelText, at: yLabelPoint)
        
        let zLabelPoint = project3DTo2D(CGPoint3D(x: 0, y: 0, z: 5.5), size: size)
        let zLabelText = Text("Z").font(.caption).foregroundColor(.blue)
        context.draw(zLabelText, at: zLabelPoint)
    }
    
    /// Draws the 3D surface as a wireframe mesh
    private func draw3DSurface(context: GraphicsContext, size: CGSize) {
        let surfaceColor = Color.pink
        let lineWidth: CGFloat = 1.0
        
        // Calculate grid dimensions from 3D points
        let gridSize = Int(sqrt(Double(viewModel.dataPoints3D.count)))
        guard gridSize > 1 else { return }
        
        // Draw wireframe mesh
        for i in 0..<(gridSize - 1) {
            for j in 0..<(gridSize - 1) {
                let index = i * gridSize + j
                let nextIndex = i * gridSize + (j + 1)
                let belowIndex = (i + 1) * gridSize + j
                let diagonalIndex = (i + 1) * gridSize + (j + 1)
                
                guard index < viewModel.dataPoints3D.count,
                      nextIndex < viewModel.dataPoints3D.count,
                      belowIndex < viewModel.dataPoints3D.count,
                      diagonalIndex < viewModel.dataPoints3D.count else { continue }
                
                let p1 = viewModel.dataPoints3D[index]
                let p2 = viewModel.dataPoints3D[nextIndex]
                let p3 = viewModel.dataPoints3D[belowIndex]
                let p4 = viewModel.dataPoints3D[diagonalIndex]
                
                // Project 3D points to 2D
                let screenP1 = project3DTo2D(p1, size: size)
                let screenP2 = project3DTo2D(p2, size: size)
                let screenP3 = project3DTo2D(p3, size: size)
                let screenP4 = project3DTo2D(p4, size: size)
                
                // Draw grid lines for this cell
                let path1 = Path { path in
                    path.move(to: screenP1)
                    path.addLine(to: screenP2)
                }
                context.stroke(path1, with: .color(surfaceColor), lineWidth: lineWidth)
                
                let path2 = Path { path in
                    path.move(to: screenP1)
                    path.addLine(to: screenP3)
                }
                context.stroke(path2, with: .color(surfaceColor), lineWidth: lineWidth)
                
                let path3 = Path { path in
                    path.move(to: screenP2)
                    path.addLine(to: screenP4)
                }
                context.stroke(path3, with: .color(surfaceColor), lineWidth: lineWidth)
                
                let path4 = Path { path in
                    path.move(to: screenP3)
                    path.addLine(to: screenP4)
                }
                context.stroke(path4, with: .color(surfaceColor), lineWidth: lineWidth)
            }
        }
    }
    
    // MARK: - 3D Projection and Camera Functions
    
    /// Projects a 3D point to 2D screen coordinates using perspective projection
    private func project3DTo2D(_ point3D: CGPoint3D, size: CGSize) -> CGPoint {
        // Apply camera rotation
        let rotatedPoint = rotatePoint(point3D, rotationX: rotationX, rotationY: rotationY)
        
        // Apply camera zoom
        let zoomedPoint = CGPoint3D(
            x: rotatedPoint.x * zoom,
            y: rotatedPoint.y * zoom,
            z: rotatedPoint.z * zoom
        )
        
        // Simple perspective projection
        let distance: CGFloat = 10.0
        let scale = distance / (distance + zoomedPoint.z)
        
        let screenX = size.width / 2 + zoomedPoint.x * scale * 50
        let screenY = size.height / 2 - zoomedPoint.y * scale * 50 // Flip Y for screen coordinates
        
        return CGPoint(x: screenX, y: screenY)
    }
    
    /// Applies rotation to a 3D point
    private func rotatePoint(_ point: CGPoint3D, rotationX: Double, rotationY: Double) -> CGPoint3D {
        // Rotate around Y-axis
        let cosY = cos(rotationY)
        let sinY = sin(rotationY)
        let x1 = point.x * cosY - point.z * sinY
        let z1 = point.x * sinY + point.z * cosY
        
        // Rotate around X-axis
        let cosX = cos(rotationX)
        let sinX = sin(rotationX)
        let y2 = point.y * cosX - z1 * sinX
        let z2 = point.y * sinX + z1 * cosX
        
        return CGPoint3D(x: x1, y: y2, z: z2)
    }
    
    /// Updates camera position based on current rotation and zoom
    private func updateCameraPosition() {
        // Camera position is handled by rotation and zoom parameters
        // The actual projection is done in project3DTo2D
    }
} 