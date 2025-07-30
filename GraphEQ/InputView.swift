//
//  InputView.swift
//  GraphEQ
//
//  Created by Ashley Gray on 7/30/25.
//

import SwiftUI

struct InputView: View {
    @EnvironmentObject var viewModel: GraphViewModel
    @State private var expressionInput: String = ""
    
    var body: some View {
        VStack(spacing: 12) {
            // Equation input field
            TextField("2D: y = x^2, 3D: z = sin(x)*cos(y)", text: $expressionInput)
                .textFieldStyle(EquationInputStyle())
                .onChange(of: expressionInput) { oldValue, newValue in
                    if !viewModel.isDrawingMode {
                        viewModel.mathExpression = newValue
                    }
                }
                .onAppear {
                    expressionInput = viewModel.mathExpression
                }
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
        }
    }
}

// MARK: - TextField Style

struct EquationInputStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 18, weight: .medium, design: .monospaced))
            .foregroundColor(.cyan)
            .padding(14)
            .background(Color(red: 0.133, green: 0.133, blue: 0.133))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(red: 0.4, green: 0.4, blue: 0.4), lineWidth: 2)
            )
            .cornerRadius(8)
    }
}

#Preview {
    InputView()
        .environmentObject(GraphViewModel())
}
