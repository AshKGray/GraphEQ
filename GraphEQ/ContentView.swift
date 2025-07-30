//
//  ContentView.swift
//  GraphEQ
//
//  Created by Ashley Gray on 7/30/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GraphViewModel()
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // App Header
                appHeader
                
                // Graph Container
                graphContainer
                
                // Equation Display
                equationDisplay
                
                // Input Section
                inputSection
            }
        }
        .environmentObject(viewModel)
    }
    
    // MARK: - App Header
    private var appHeader: some View {
        HStack {
            Text("GraphIt Pro")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.cyan)
                .shadow(color: .cyan.opacity(0.5), radius: 4)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button("Clear") {
                    viewModel.resetView()
                }
                .buttonStyle(HeaderButtonStyle())
                
                Button("Save") {
                    // TODO: Implement save functionality
                }
                .buttonStyle(HeaderButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.067, green: 0.067, blue: 0.067))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2)),
            alignment: .bottom
        )
    }
    
    // MARK: - Graph Container
    private var graphContainer: some View {
        ZStack {
            // Graph background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.067, green: 0.067, blue: 0.067))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.267, green: 0.267, blue: 0.267), lineWidth: 2)
                )
            
            // Graph content
            GraphView()
                .environmentObject(viewModel)
            
            // Mode tabs overlay
            VStack {
                HStack {
                    graphModeTabs
                    Spacer()
                    modeToggle
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
                
                Spacer()
                
                HStack {
                    Spacer()
                    zoomControls
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .frame(height: 400)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - Graph Mode Tabs
    private var graphModeTabs: some View {
        HStack(spacing: 0) {
            Button("2D") {
                viewModel.is3DMode = false
            }
            .buttonStyle(GraphModeTabStyle(isActive: !viewModel.is3DMode))
            
            Button("3D") {
                viewModel.is3DMode = true
            }
            .buttonStyle(GraphModeTabStyle(isActive: viewModel.is3DMode))
        }
        .background(Color(red: 0.133, green: 0.133, blue: 0.133).opacity(0.9))
        .cornerRadius(8)
    }
    
    // MARK: - Mode Toggle
    private var modeToggle: some View {
        Button(viewModel.isDrawingMode ? "Draw" : "Type") {
            viewModel.isDrawingMode.toggle()
        }
        .buttonStyle(ModeToggleStyle())
    }
    
    // MARK: - Zoom Controls
    private var zoomControls: some View {
        HStack(spacing: 4) {
            Button("-") {
                viewModel.scale = max(0.5, viewModel.scale - 0.2)
            }
            .buttonStyle(ZoomButtonStyle())
            
            Button("+") {
                viewModel.scale = min(3.0, viewModel.scale + 0.2)
            }
            .buttonStyle(ZoomButtonStyle())
        }
    }
    
    // MARK: - Equation Display
    private var equationDisplay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Generated/Current Equation")
                .font(.caption)
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(1)
            
            Text(viewModel.is3DMode ? "z = \(viewModel.mathExpression.isEmpty ? "0" : viewModel.mathExpression)" : "y = \(viewModel.mathExpression.isEmpty ? "0" : viewModel.mathExpression)")
                .font(.system(size: 20, weight: .semibold, design: .monospaced))
                .foregroundColor(.pink)
                .shadow(color: .pink.opacity(0.4), radius: 6)
                .frame(minHeight: 25, alignment: .leading)
        }
        .padding(16)
        .background(Color(red: 0.067, green: 0.067, blue: 0.067))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.267, green: 0.267, blue: 0.267), lineWidth: 2)
        )
        .padding(.horizontal, 16)
    }
    
    // MARK: - Input Section
    private var inputSection: some View {
        VStack(spacing: 0) {
            // Input tabs
            inputTabs
            
            // Tab content
            TabView(selection: $viewModel.selectedTab) {
                equationTab
                    .tag(InputTab.equation)
                
                symbolsTab
                    .tag(InputTab.symbols)
                
                axisTab
                    .tag(InputTab.axis)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .background(Color(red: 0.067, green: 0.067, blue: 0.067))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.267, green: 0.267, blue: 0.267), lineWidth: 2)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Input Tabs
    private var inputTabs: some View {
        HStack(spacing: 0) {
            ForEach(InputTab.allCases, id: \.self) { tab in
                Button(tab.rawValue) {
                    viewModel.selectedTab = tab
                }
                .buttonStyle(InputTabStyle(isActive: viewModel.selectedTab == tab))
            }
        }
        .background(Color(red: 0.133, green: 0.133, blue: 0.133))
        .cornerRadius(8)
        .padding(16)
    }
    
    // MARK: - Equation Tab
    private var equationTab: some View {
        VStack(spacing: 12) {
            InputView()
                .environmentObject(viewModel)
            
            // Equation preview
            HStack {
                Text(viewModel.is3DMode ? "z = " : "y = ")
                    .foregroundColor(.cyan)
                + Text(viewModel.mathExpression.isEmpty ? "Enter equation..." : viewModel.mathExpression)
                    .foregroundColor(.cyan.opacity(0.8))
                
                Spacer()
            }
            .font(.system(size: 14, design: .monospaced))
            .padding(8)
            .background(Color(red: 0.102, green: 0.102, blue: 0.102))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(red: 0.267, green: 0.267, blue: 0.267), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Symbols Tab
    private var symbolsTab: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Math Symbols")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Spacer()
                
                Button("More") {
                    // TODO: Toggle symbols expansion
                }
                .buttonStyle(SymbolsToggleStyle())
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 6) {
                ForEach(MathSymbol.allCases, id: \.self) { symbol in
                    Button(symbol.display) {
                        viewModel.insertSymbol(symbol)
                    }
                    .buttonStyle(SymbolButtonStyle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Axis Tab
    private var axisTab: some View {
        VStack(spacing: 12) {
            if viewModel.is3DMode {
                axisControls3D
            } else {
                axisControls2D
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - 2D Axis Controls
    private var axisControls2D: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            AxisInputGroup(label: "X Min", value: $viewModel.xMin)
            AxisInputGroup(label: "X Max", value: $viewModel.xMax)
            AxisInputGroup(label: "Y Min", value: $viewModel.yMin)
            AxisInputGroup(label: "Y Max", value: $viewModel.yMax)
        }
    }
    
    // MARK: - 3D Axis Controls
    private var axisControls3D: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
            AxisRangeGroup(label: "X Range")
            AxisRangeGroup(label: "Y Range")
            AxisRangeGroup(label: "Z Range")
        }
    }
}

// MARK: - Supporting Views

struct AxisInputGroup: View {
    let label: String
    @Binding var value: CGFloat
    @State private var textValue: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            TextField("", text: $textValue)
                .textFieldStyle(AxisInputStyle())
                .onAppear {
                    textValue = String(format: "%.1f", value)
                }
                .onChange(of: textValue) { oldValue, newValue in
                    if let newValue = Double(newValue) {
                        value = CGFloat(newValue)
                    }
                }
        }
        .padding(12)
        .background(Color(red: 0.133, green: 0.133, blue: 0.133))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 0.333, green: 0.333, blue: 0.333), lineWidth: 1)
        )
    }
}

struct AxisRangeGroup: View {
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("-5 to 5")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.green)
        }
        .padding(12)
        .background(Color(red: 0.133, green: 0.133, blue: 0.133))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 0.333, green: 0.333, blue: 0.333), lineWidth: 1)
        )
    }
}

// MARK: - Button Styles

struct HeaderButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(configuration.isPressed ? .black : .orange)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(configuration.isPressed ? .orange : Color(red: 0.133, green: 0.133, blue: 0.133))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.orange, lineWidth: 1)
            )
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct GraphModeTabStyle: ButtonStyle {
    let isActive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(isActive ? .black : .gray)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isActive ? .cyan : Color.clear)
            .cornerRadius(6)
    }
}

struct ModeToggleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.cyan)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(red: 0.133, green: 0.133, blue: 0.133))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.cyan, lineWidth: 1)
            )
            .cornerRadius(8)
    }
}

struct ZoomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.cyan)
            .frame(width: 32, height: 32)
            .background(Color(red: 0.133, green: 0.133, blue: 0.133))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.cyan, lineWidth: 1)
            )
            .cornerRadius(6)
    }
}

struct InputTabStyle: ButtonStyle {
    let isActive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(isActive ? .black : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isActive ? .orange : Color.clear)
            .cornerRadius(6)
    }
}

struct SymbolsToggleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .foregroundColor(.cyan)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.gray, lineWidth: 1)
            )
            .cornerRadius(4)
    }
}

struct SymbolButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16))
            .foregroundColor(.white)
            .frame(minHeight: 32)
            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(red: 0.333, green: 0.333, blue: 0.333), lineWidth: 1)
            )
            .cornerRadius(4)
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct AxisInputStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.green)
            .background(Color.clear)
    }
}

// MARK: - Supporting Types

enum InputTab: String, CaseIterable {
    case equation = "Equation"
    case symbols = "Symbols"
    case axis = "Axis"
}

enum MathSymbol: String, CaseIterable {
    case pi = "π"
    case alpha = "α"
    case beta = "β"
    case gamma = "γ"
    case delta = "δ"
    case theta = "θ"
    case infinity = "∞"
    case sum = "∑"
    case integral = "∫"
    case partial = "∂"
    case delta2 = "∆"
    case sqrt = "√"
    case leq = "≤"
    case geq = "≥"
    case neq = "≠"
    case approx = "≈"
    case plusMinus = "±"
    case divide = "÷"
    case sin = "sin"
    case cos = "cos"
    case tan = "tan"
    case log = "log"
    case ln = "ln"
    case exp = "exp"
    case xSquared = "x²"
    case xCubed = "x³"
    case xPowerN = "xⁿ"
    case xInverse = "x⁻¹"
    case x1 = "x₁"
    case x2 = "x₂"
    case xN = "xₙ"
    case xI = "xᵢ"
    
    var display: String {
        return rawValue
    }
}

#Preview {
    ContentView()
}
