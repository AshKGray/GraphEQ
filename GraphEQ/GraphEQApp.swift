import SwiftUI

/// The main entry point for the GraphEQ application.
@main
struct GraphEQApp: App { // Renamed from RealTimeGraphApp
    /// Initializes a `GraphViewModel` as the shared environment object.
    /// This allows all views in the app to access the same view model instance.
    @StateObject var viewModel = GraphViewModel()
    
    /// Initializes a `MathAutoCompletionService` as the shared environment object.
    /// This prevents multiple instantiation issues that cause "invalid reuse after initialization failure".
    @StateObject var completionService = MathAutoCompletionService()

    var body: some Scene {
        WindowGroup {
            /// The primary content view of the application, combining the graph and input controls.
            ContentView()
                /// Makes the `GraphViewModel` available to all subviews in the environment.
                .environmentObject(viewModel)
                /// Makes the `MathAutoCompletionService` available to all subviews in the environment.
                .environmentObject(completionService)
        }
    }
}
