# GraphEQ Project Specification

## 1. Project Overview

**GraphEQ** is a sophisticated mathematical graphing application built in SwiftUI for iOS/macOS that provides both 2D and 3D mathematical function visualization. The app allows users to input mathematical expressions, draw freehand curves, and visualize complex mathematical relationships in real-time.

**Primary Goals:**
- Provide intuitive mathematical function plotting in both 2D and 3D modes
- Enable freehand drawing with automatic curve fitting to mathematical expressions
- Support comprehensive trigonometric and mathematical function libraries
- Deliver smooth, responsive 60fps performance for complex mathematical visualizations
- Create an elegant, modern UI with dark theme optimized for mathematical work

## 2. Core Functionalities

### 2.1 Mathematical Expression Processing
- **2D Function Plotting**: Plot y = f(x) functions with real-time evaluation
- **3D Surface Plotting**: Plot z = f(x,y) surfaces with mesh generation
- **Expression Parsing**: Robust mathematical expression parsing using Expression library
- **Real-time Evaluation**: Dynamic function evaluation as users type
- **Error Handling**: Graceful handling of invalid expressions and mathematical errors

### 2.2 Interactive Drawing Mode
- **Freehand Drawing**: Capture user-drawn curves with touch/pointer input
- **Curve Fitting**: Automatic polynomial regression to fit mathematical expressions to drawn curves
- **Real-time Feedback**: Instant equation generation as users draw
- **Smooth Interpolation**: High-quality curve generation from discrete points

### 2.3 3D Visualization System
- **3D Coordinate System**: Full 3D Cartesian coordinate system with proper axes
- **Surface Mesh Generation**: Triangular mesh generation for 3D surfaces
- **Camera Controls**: Interactive 3D camera with rotation, zoom, and pan
- **Performance Optimization**: Metal shader integration for efficient 3D rendering

### 2.4 User Interface Features
- **Mode Switching**: Seamless transition between 2D and 3D modes
- **Zoom and Pan**: Intuitive gesture-based navigation
- **Symbol Input**: Quick access to mathematical symbols and functions
- **Range Controls**: Adjustable X and Y axis ranges
- **Dark Theme**: Professional dark interface optimized for mathematical visualization

### 2.5 Mathematical Function Library
- **Trigonometric Functions**: sin, cos, tan with inverse functions
- **Exponential Functions**: exp, log, ln
- **Power Functions**: x^n, sqrt, cbrt
- **Advanced Functions**: Support for complex mathematical expressions
- **Domain Validation**: Proper handling of function domains and asymptotes

## 3. Documentation and Libraries

### 3.1 Primary Dependencies
- **Expression Library**: Mathematical expression parsing and evaluation
- **SwiftUI**: Modern declarative UI framework
- **CoreGraphics**: 2D graphics and coordinate transformations
- **SceneKit**: 3D graphics rendering (planned)
- **Metal**: GPU-accelerated rendering (planned)

### 3.2 Testing Framework
- **Testing Framework**: Apple's new Testing framework for unit tests
- **XCTest**: Traditional iOS testing framework for UI tests
- **Performance Testing**: Automated performance validation

### 3.3 Key Documentation References
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Expression Library](https://github.com/nicklockwood/Expression)
- [SceneKit Programming Guide](https://developer.apple.com/documentation/scenekit)
- [Metal Programming Guide](https://developer.apple.com/documentation/metal)

## 4. Current File Structure

```
GraphEQ/
├── GraphEQ/
│   ├── GraphEQApp.swift              # Main app entry point
│   ├── ContentView.swift             # Primary UI layout and navigation
│   ├── GraphView.swift               # 2D graph rendering and gestures
│   ├── GraphViewModel.swift          # Core business logic and state management
│   ├── InputView.swift               # Mathematical input interface
│   ├── SymbolsPopupView.swift        # Mathematical symbol selection
│   ├── CurveFitter.swift             # Polynomial regression algorithms
│   ├── Graph3DModels.swift           # 3D data structures and models
│   └── Assets.xcassets/              # App icons and visual assets
├── GraphEQTests/
│   ├── GraphEQTests.swift            # Core functionality tests
│   └── Graph3DTests.swift            # 3D functionality tests
├── GraphEQUITests/
│   ├── GraphEQUITests.swift          # UI automation tests
│   └── GraphEQUITestsLaunchTests.swift
└── GraphEQ.xcodeproj/                # Xcode project configuration
```

## 5. Current Implementation Status

### 5.1 Completed Features ✅
- Basic 2D function plotting with Expression library
- Freehand drawing with polynomial curve fitting
- Zoom and pan gesture handling
- Dark theme UI with modern design
- Mathematical symbol input system
- Basic 3D data structures and models
- Comprehensive test suite for 3D functionality

### 5.2 In Progress 🔄
- 3D mode toggle in user interface
- 3D expression parsing and evaluation
- 3D surface mesh generation
- SceneKit integration for 3D rendering

### 5.3 Planned Features 📋
- 3D camera controls and gesture handling
- Enhanced trigonometric function support
- Comprehensive error handling and validation
- Performance optimization with Metal shaders
- Battery optimization for 3D mode
- Save/load functionality for graphs

## 6. Technical Architecture

### 6.1 Architecture Pattern
- **MVVM (Model-View-ViewModel)**: Clean separation of concerns
- **ObservableObject**: Reactive state management with SwiftUI
- **Environment Objects**: Shared state across view hierarchy

### 6.2 Key Design Principles
- **Reliability First**: Robust error handling and validation
- **Performance Focus**: 60fps target for all interactions
- **Clean Code**: Simple, readable, and maintainable code
- **Test-Driven**: Comprehensive test coverage for all features
- **User Experience**: Intuitive and responsive interface

### 6.3 Data Flow
1. User input → GraphViewModel
2. Expression parsing → Mathematical evaluation
3. Data point generation → Graph rendering
4. Gesture handling → View transformations
5. State updates → UI refresh

## 7. Development Priorities

### 7.1 Immediate (Current Sprint)
1. Complete 3D mode UI toggle implementation
2. Finish 3D expression parsing and evaluation
3. Implement basic 3D surface rendering
4. Add 3D camera controls

### 7.2 Short Term (Next 2 Sprints)
1. Enhance trigonometric function support
2. Implement comprehensive error handling
3. Add performance optimization
4. Complete 3D interaction controls

### 7.3 Long Term (Future Releases)
1. Metal shader integration
2. Advanced mathematical functions
3. Export and sharing features
4. Cloud synchronization

## 8. Quality Assurance

### 8.1 Testing Strategy
- **Unit Tests**: All mathematical functions and business logic
- **Integration Tests**: End-to-end functionality validation
- **Performance Tests**: 60fps rendering validation
- **UI Tests**: User interaction automation

### 8.2 Code Quality Standards
- **File Size**: Keep files under 200 lines
- **Function Complexity**: Simple, focused functions
- **Documentation**: Comprehensive inline documentation
- **Error Handling**: Graceful degradation for all edge cases

### 8.3 Performance Requirements
- **Rendering**: 60fps for all interactions
- **Memory**: Efficient memory usage for large datasets
- **Battery**: Optimized power consumption
- **Responsiveness**: Sub-100ms response to user input 