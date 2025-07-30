import SwiftUI

/// The main entry point for the GraphEQ application.
@main
struct GraphEQApp: App { // Renamed from RealTimeGraphApp
    /// Initializes a `GraphViewModel` as the shared environment object.
    /// This allows all views in the app to access the same view model instance.
    @StateObject var viewModel = GraphViewModel()

    var body: some Scene {
        WindowGroup {
            /// The primary content view of the application, combining the graph and input controls.
            ContentView()
                /// Makes the `GraphViewModel` available to all subviews in the environment.
                .environmentObject(viewModel)
        }
    }
}
