//
//  ContentView.swift
//  GraphEQ
//
//  Created by Ashley Gray on 7/27/25.

import SwiftUI

/// The main content view of the GraphEQ app.
/// It orchestrates the layout of the GraphView and InputView.
struct ContentView: View {
    /// Observes the `GraphViewModel` for changes in its published properties.
    /// This allows the UI to react to changes in the model's state.
    @EnvironmentObject var viewModel: GraphViewModel

    var body: some View {
        VStack(spacing: 0) { // Use VStack to stack graph and input, with no spacing
            /// The top half of the UI, displaying the 2D Cartesian graph.
            GraphView()
                .environmentObject(viewModel) // Pass environment object to GraphView
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Graph takes all available space

            /// A divider line to visually separate the graph from the input controls.
            Divider()

            /// The bottom half of the UI, containing the text field, mode toggle, and buttons.
            InputView()
                .environmentObject(viewModel) // Pass environment object to InputView
                .padding() // Add some padding around the input view
                .frame(maxWidth: .infinity, alignment: .bottom) // Input view stretches horizontally
        }
        .edgesIgnoringSafeArea(.bottom) // Extend content to the bottom edge
    }
}

/// A preview provider for ContentView, useful for Xcode Previews.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(GraphViewModel()) // Provide a sample view model for preview
    }
}
