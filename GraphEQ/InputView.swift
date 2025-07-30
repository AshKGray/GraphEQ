//  InputView.swift
//  GraphEQ
//
//  Created by Ashley Gray on 7/27/25.
//


import SwiftUI

/// InputView provides the user interface for entering expressions,
/// switching modes, and triggering actions like resetting the view.
struct InputView: View {
    /// Observes the `GraphViewModel` to bind UI elements to its published properties.
    @EnvironmentObject var viewModel: GraphViewModel

    /// A local state variable to hold the text field's content.
    /// This allows for immediate UI updates without waiting for the ViewModel's
    /// potentially rate-limited updates. `onCommit` or `onChange` will sync with ViewModel.
    @State private var expressionInput: String = "sin(x)"

    // Define calculator buttons for potential future implementation
    let calculatorButtons: [[String]] = [
        ["7", "8", "9", "+"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "×"],
        ["0", ".", "=", "÷"],
        ["^", "(", ")", "sin", "cos", "tan", "log", "sqrt"] // Extended functions
    ]

    var body: some View {
        VStack(spacing: 15) {
            // MARK: - Mode Toggle
            Picker("Mode", selection: $viewModel.isDrawingMode) {
                Text("Type").tag(false)
                Text("Draw").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .onChange(of: viewModel.isDrawingMode) { oldValue, newValue in
                // When mode changes, if switching to typing, ensure expressionInput reflects ViewModel
                if !newValue { // Switched to Typing Mode
                    expressionInput = viewModel.mathExpression
                } else { // Switched to Drawing Mode
                    expressionInput = "" // Clear input field when drawing
                }
            }


            // MARK: - Expression Text Field
            TextField("Enter expression (e.g., sin(x) + x^2)", text: $expressionInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: expressionInput) { oldValue, newValue in
                    // Only update the ViewModel's expression if in Typing Mode
                    if !viewModel.isDrawingMode {
                        viewModel.mathExpression = newValue
                    }
                }
                // Apply a red border if there's an error message
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(viewModel.errorMessage != nil ? Color.red : Color.clear, lineWidth: 2)
                )

            // MARK: - Error Message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            // MARK: - Optional Calculator Buttons (Placeholder)
            // This section is commented out as providing a full calculator parser
            // for these buttons is out of scope for the current request's complexity.
            // You would typically build a custom keyboard or use a programmatic approach
            // to insert characters into the `expressionInput` here.
            /*
            VStack(spacing: 8) {
                ForEach(calculatorButtons, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(row, id: \.self) { buttonLabel in
                            Button(action: {
                                // Append character to expressionInput
                                if !viewModel.isDrawingMode { // Only allow input in typing mode
                                    self.expressionInput += buttonLabel
                                    viewModel.mathExpression = self.expressionInput // Update VM immediately
                                }
                            }) {
                                Text(buttonLabel)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.accentColor.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            */

            // MARK: - Reset Button
            Button("Reset View") {
                viewModel.resetView()
                expressionInput = viewModel.mathExpression // Ensure text field updates to default
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 5)
        }
    }
}

/// A preview provider for InputView.
struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView()
            .environmentObject(GraphViewModel())
    }
}
