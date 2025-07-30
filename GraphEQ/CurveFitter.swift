//
//  CurveFitter.swift
//  GraphEQ
//
//  Created by Ashley Gray on 7/27/25.
//


import Foundation
import CoreGraphics // For CGPoint

/// A utility class for performing basic curve fitting operations.
/// This implementation provides a simplified polynomial regression.
/// For production-grade applications, consider more robust numerical libraries.
class CurveFitter {

    /// Performs polynomial regression to find coefficients for a given set of points.
    ///
    /// - Parameters:
    ///   - x: An array of x-coordinates.
    ///   - y: An array of y-coordinates.
    ///   - degree: The degree of the polynomial to fit (e.g., 1 for linear, 2 for quadratic).
    /// - Returns: An array of coefficients [c0, c1, c2, ...] where y = c0 + c1*x + c2*x^2 + ...
    ///            Returns `nil` if fitting fails (e.g., insufficient data points or matrix singularity).
    static func polynomialRegression(x: [Double], y: [Double], degree: Int) -> [Double]? {
        guard x.count == y.count, x.count > degree else {
            // Need at least (degree + 1) points to fit a polynomial of 'degree'.
            // For example, for a linear (degree 1) fit, you need at least 2 points.
            return nil
        }

        let n = x.count // Number of data points
        let m = degree + 1 // Number of coefficients (degree + 1)

        // Construct the design matrix A (Vandermonde matrix)
        // A[i][j] = x[i]^j
        var A = Array(repeating: Array(repeating: 0.0, count: m), count: n)
        for i in 0..<n {
            for j in 0..<m {
                A[i][j] = pow(x[i], Double(j))
            }
        }

        // Calculate A_transpose * A (ATA)
        // This forms a symmetric matrix (m x m)
        var ATA = Array(repeating: Array(repeating: 0.0, count: m), count: m)
        for i in 0..<m {
            for j in 0..<m {
                for k in 0..<n {
                    ATA[i][j] += A[k][i] * A[k][j]
                }
            }
        }

        // Calculate A_transpose * y (ATY)
        // This forms a vector (m x 1)
        var ATY = Array(repeating: 0.0, count: m)
        for i in 0..<m {
            for k in 0..<n {
                ATY[i] += A[k][i] * y[k]
                }
            }

        // Solve the linear system (ATA) * coefficients = ATY for 'coefficients'
        // Using Gaussian elimination for solving. This is a simplified approach
        // and can be unstable for ill-conditioned matrices. For robustness,
        // consider a dedicated linear algebra library (e.g., using LAPACK or Accelerate).
        guard let coefficients = solveLinearSystem(matrix: ATA, vector: ATY) else {
            return nil
        }

        return coefficients
    }

    /// Solves a system of linear equations Ax = b using Gaussian elimination.
    /// - Parameters:
    ///   - matrix: The square matrix A.
    ///   - vector: The vector b.
    /// - Returns: The solution vector x, or `nil` if the matrix is singular.
    private static func solveLinearSystem(matrix: [[Double]], vector: [Double]) -> [Double]? {
        let n = matrix.count
        guard n == matrix[0].count, n == vector.count else { return nil }

        var M = matrix // Augment matrix with vector b
        for i in 0..<n {
            M[i].append(vector[i])
        }

        // Forward elimination
        for i in 0..<n {
            // Find pivot
            var maxRow = i
            for k in i + 1..<n {
                if abs(M[k][i]) > abs(M[maxRow][i]) {
                    maxRow = k
                }
            }
            M.swapAt(i, maxRow) // Swap current row with row with max pivot

            // Check for singular matrix
            if M[i][i] == 0 { return nil }

            for k in i + 1..<n {
                let factor = M[k][i] / M[i][i]
                for j in i..<n + 1 { // Iterate through augmented columns
                    M[k][j] -= factor * M[i][j]
                }
            }
        }

        // Back substitution
        var x = Array(repeating: 0.0, count: n)
        for i in (0..<n).reversed() {
            var sum = 0.0
            for j in i + 1..<n {
                sum += M[i][j] * x[j]
            }
            if M[i][i] == 0 { return nil } // Should have been caught earlier, but an extra check
            x[i] = (M[i][n] - sum) / M[i][i]
        }

        return x
    }
}
