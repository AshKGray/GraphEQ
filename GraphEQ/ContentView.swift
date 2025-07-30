//
//  ContentView.swift
//  GraphEQ
//
//  Created by Ashley Gray on 7/30/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: GraphViewModel
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // App Header
                appHeader
                
                // Graph Container - Takes remaining space
                graphContainer
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Scrollable bottom section
                ScrollView {
                    VStack(spacing: 4) {
                        // Equation Display
                        equationDisplay
                        
                        // Input Section
                        inputSection
                    }
                    .padding(.bottom, 20) // Add extra padding at bottom for scrolling
                }
                .frame(height: 300) // Increased height to ensure all content is visible
            }
        }
    }
    
    // MARK: - App Header
    private var appHeader: some View {
        HStack {
            Text("GraphIt Pro")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.cyan)
                .shadow(color: .cyan.opacity(0.8), radius: 8)
                .shadow(color: .cyan.opacity(0.4), radius: 16)
            
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                viewModel.zoomOut()
            }
            .buttonStyle(ZoomButtonStyle())
            
            Button("+") {
                viewModel.zoomIn()
            }
            .buttonStyle(ZoomButtonStyle())
        }
    }
    
    // MARK: - Equation Display
    private var equationDisplay: some View {
        HStack {
            Text("Equation:")
                .font(.caption)
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(1)
            
            TextField(viewModel.is3DMode ? "z = " : "y = ", text: $viewModel.mathExpression)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.pink)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: viewModel.mathExpression) { oldValue, newValue in
                    if !viewModel.isDrawingMode {
                        viewModel.parseAndPlotExpression()
                    }
                }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(red: 0.067, green: 0.067, blue: 0.067))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 0.267, green: 0.267, blue: 0.267), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
    
    // MARK: - Input Section
    private var inputSection: some View {
        VStack(spacing: 0) {
            // Input tabs
            inputTabs
            
            // Tab content
            Group {
                switch viewModel.selectedTab {
                case .symbols:
                    symbolsTab
                case .axis:
                    axisTab
                }
            }
        }
        .background(Color(red: 0.067, green: 0.067, blue: 0.067))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 0.267, green: 0.267, blue: 0.267), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
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
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    

    
    // MARK: - Symbols Tab
    private var symbolsTab: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Quick Symbols")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Spacer()
                
                Button("All Symbols") {
                    viewModel.showSymbolsPopup = true
                }
                .buttonStyle(SymbolsToggleStyle())
            }
            
            // Quick symbols row
            HStack(spacing: 8) {
                ForEach(Array(MathSymbol.allCases.prefix(8)), id: \.self) { symbol in
                    Button(symbol.display) {
                        viewModel.insertSymbol(symbol)
                    }
                    .buttonStyle(QuickSymbolButtonStyle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .sheet(isPresented: $viewModel.showSymbolsPopup) {
            SymbolsPopupView()
                .environmentObject(viewModel)
        }
    }
    
    // MARK: - Axis Tab
    private var axisTab: some View {
        VStack(spacing: 8) {
            if viewModel.is3DMode {
                axisControls3D
            } else {
                axisControls2D
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - 2D Axis Controls
    private var axisControls2D: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 6) {
            AxisInputGroup(label: "X Min", value: $viewModel.xMin)
            AxisInputGroup(label: "X Max", value: $viewModel.xMax)
            AxisInputGroup(label: "Y Min", value: $viewModel.yMin)
            AxisInputGroup(label: "Y Max", value: $viewModel.yMax)
        }
    }
    
    // MARK: - 3D Axis Controls
    private var axisControls3D: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 6) {
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
    @EnvironmentObject var viewModel: GraphViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
            
            TextField("", text: $textValue)
                .textFieldStyle(AxisInputStyle())
                .onAppear {
                    textValue = String(format: "%.1f", value)
                }
                .onChange(of: textValue) { oldValue, newValue in
                    if let newValue = Double(newValue) {
                        value = CGFloat(newValue)
                        // Update the corresponding range in the view model
                        switch label {
                        case "X Min":
                            viewModel.xRange = value...viewModel.xRange.upperBound
                        case "X Max":
                            viewModel.xRange = viewModel.xRange.lowerBound...value
                        case "Y Min":
                            viewModel.yRange = value...viewModel.yRange.upperBound
                        case "Y Max":
                            viewModel.yRange = viewModel.yRange.lowerBound...value
                        default:
                            break
                        }
                        // Recalculate the plot with new ranges
                        if !viewModel.isDrawingMode && !viewModel.is3DMode {
                            viewModel.parseAndPlotExpression()
                        }
                    }
                }
        }
        .padding(8)
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
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
            
            Text("-5 to 5")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.green)
        }
        .padding(8)
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
            .shadow(color: .orange.opacity(0.6), radius: 4)
            .shadow(color: .orange.opacity(0.3), radius: 8)
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
            .shadow(color: .cyan.opacity(0.6), radius: 4)
            .shadow(color: .cyan.opacity(0.3), radius: 8)
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
            .shadow(color: .white.opacity(0.3), radius: 2)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct QuickSymbolButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14))
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(red: 0.333, green: 0.333, blue: 0.333), lineWidth: 1)
            )
            .cornerRadius(4)
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
            .shadow(color: .white.opacity(0.3), radius: 2)
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
