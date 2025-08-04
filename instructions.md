# GraphEQ - 3D Graphing Calculator

## Project Overview
GraphEQ is an advanced 3D graphing calculator iOS app that provides real-time mathematical visualization, interactive 3D plotting, and AI-powered mathematical assistance. The app supports both 2D and 3D graphing modes with comprehensive mathematical expression parsing.

## Core Functionalities

### 2D Graphing Features
- Real-time equation plotting with instant visualization
- Interactive zoom, pan, and exploration with touch gestures
- Freehand drawing mode with polynomial regression curve fitting
- Support for trigonometric, logarithmic, exponential, and polynomial functions
- Error handling and validation with helpful suggestions

### 3D Graphing Features
- **Explicit Functions**: Plot surfaces defined by z = f(x,y)
- **Implicit Equations**: Visualize surfaces defined by f(x,y,z) = 0
- **Interactive 3D Camera**: Rotation, zoom, and pan controls
- **3D Surface Rendering**: Wireframe mesh visualization with colored axes
- **Example Expressions**: Built-in examples for both explicit and implicit forms

### AI Integration
- Claude AI API integration for mathematical assistance
- Real-time problem solving and explanations
- Context-aware mathematical guidance

## Technical Stack

### Development Environment
- **Xcode Version**: Xcode Beta 26 (Build version 17A5285i)
- **iOS Deployment Target**: iOS 18.5+
- **Swift Version**: Swift 6
- **Platform**: iOS (iPhone & iPad)

### Key Libraries & Dependencies
- **Expression**: Mathematical expression parsing and evaluation
- **SwiftUI**: Modern declarative UI framework
- **Core Graphics**: Custom drawing and visualization
- **Claude AI API**: Mathematical assistance and problem solving

### Architecture
- **MVVM Pattern**: Model-View-ViewModel architecture
- **ObservableObject**: Reactive data binding with @Published properties
- **EnvironmentObject**: Dependency injection for view models
- **Modular Design**: Separated concerns with dedicated view models and services

## Current File Structure

```
GraphEQ/
├── GraphEQ/
│   ├── GraphEQApp.swift              # App entry point
│   ├── ContentView.swift             # Main UI container
│   ├── GraphView.swift               # 2D graphing view
│   ├── Graph3DView.swift             # 3D graphing view
│   ├── GraphViewModel.swift          # Shared view model
│   ├── Graph3DModels.swift           # 3D data structures
│   ├── InputView.swift               # Expression input interface
│   ├── MathAutoCompletion.swift      # Mathematical autocomplete
│   ├── MathSolverView.swift          # Math solver UI
│   ├── MathSolverService.swift       # Claude AI integration
│   ├── AIAssistantView.swift         # AI chat interface
│   ├── AIAssistantViewModel.swift    # AI assistant logic
│   ├── CurveFitter.swift             # Polynomial regression
│   └── Assets.xcassets/              # App resources
├── GraphEQTests/                     # Unit tests
├── GraphEQUITests/                   # UI tests
└── instructions.md                   # This file
```

## Development Guidelines

### Code Quality
- Follow SwiftUI best practices and modern Swift conventions
- Use descriptive naming and comprehensive documentation
- Implement proper error handling and user feedback
- Maintain clean separation of concerns

### Testing
- Write unit tests for mathematical functions and view models
- Include UI tests for critical user workflows
- Test both 2D and 3D graphing functionality
- Verify AI integration and error handling

### Performance
- Optimize 3D rendering for smooth interaction
- Implement efficient mathematical expression parsing
- Use appropriate data structures for large datasets
- Minimize memory usage in real-time calculations

## Build Instructions

1. **Prerequisites**: Xcode Beta 26 installed
2. **Clone**: Download the project repository
3. **Open**: Open `GraphEQ.xcodeproj` in Xcode Beta 26
4. **Build**: Select target device/simulator and build (⌘+B)
5. **Run**: Run the app (⌘+R) on iOS Simulator or device

## Key Features Status

### ✅ Completed
- Real-time 2D equation plotting
- Interactive 2D graphing controls
- Freehand drawing with curve fitting
- Mathematical expression parser
- Error handling and validation
- 3D expression parsing (explicit and implicit)
- 3D surface rendering
- 3D camera controls
- AI integration with Claude
- Multiple function type support

### 🚧 In Progress
- Parametric equations support
- Advanced 3D visualization features
- Enhanced AI mathematical assistance

### 📋 Planned
- Coordinate system switching (Cartesian, cylindrical, spherical)
- Level curves and traces visualization
- Interactive sliders for parameters
- Advanced annotation tools
- Export and sharing capabilities 