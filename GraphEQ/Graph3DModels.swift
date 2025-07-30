//
//  Graph3DModels.swift
//  GraphEQ
//
//  Created by Ashley Gray on 7/30/25.
//

import Foundation
import CoreGraphics

// MARK: - 3D Point Structure

/// A 3D point structure for representing points in 3D space
struct CGPoint3D {
    let x: CGFloat
    let y: CGFloat
    let z: CGFloat
    
    init(x: CGFloat, y: CGFloat, z: CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }
}

// MARK: - 3D Surface Data

/// Represents a 3D surface mesh for rendering
struct Surface3D {
    let vertices: [CGPoint3D]
    let indices: [Int] // Triangle indices
    
    init(vertices: [CGPoint3D], indices: [Int]) {
        self.vertices = vertices
        self.indices = indices
    }
}

// MARK: - 3D Camera Controls

/// Represents camera position and orientation for 3D viewing
struct Camera3D {
    var position: CGPoint3D
    var target: CGPoint3D
    var up: CGPoint3D
    
    init(position: CGPoint3D = CGPoint3D(x: 0, y: 0, z: 10),
         target: CGPoint3D = CGPoint3D(x: 0, y: 0, z: 0),
         up: CGPoint3D = CGPoint3D(x: 0, y: 1, z: 0)) {
        self.position = position
        self.target = target
        self.up = up
    }
} 