# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

**Build the app:**
```bash
xcodebuild -scheme GraphEQ -configuration Debug build
```

**Build for release:**
```bash
xcodebuild -scheme GraphEQ -configuration Release build
```

**Run tests:**
```bash
xcodebuild -scheme GraphEQ test -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Run specific test file:**
```bash
xcodebuild -scheme GraphEQ test -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:GraphEQTests/MathSolverTests
```

**Clean build artifacts:**
```bash
xcodebuild clean
```

## Project Architecture

GraphEQ is a SwiftUI-based iOS math solver application with graphing capabilities. The app combines mathematical problem solving with step-by-step solutions and function graphing.

### Core Architecture Pattern
- **MVVM**: Uses SwiftUI with `@StateObject` and `@EnvironmentObject` for state management
- **Shared ViewModel**: `GraphViewModel` is injected as an environment object from `GraphEQApp`
- **Service Layer**: Singleton services like `MathSolverService` handle business logic and API calls

### Key Components

**Main App Structure:**
- `GraphEQApp.swift`: App entry point that provides `GraphViewModel` to the environment
- `ContentView.swift`: Main interface combining graph display and input controls
- `MathSolverView.swift`: Dedicated math problem solver interface

**Math Solving System:**
- `MathSolverService.swift`: Handles Claude AI API integration for step-by-step solutions
- Uses specific prompt formatting to ensure consistent mathematical notation output
- Outputs solutions in format: `mathematical_expression ← step_description`

**Graphing System:**
- `GraphView.swift` & `GraphViewModel.swift`: Real-time function graphing
- `Graph3DModels.swift`: 3D graphing capabilities
- `CurveFitter.swift`: Mathematical curve fitting algorithms

**AI Integration:**
- `AIAssistantView.swift` & `AIAssistantViewModel.swift`: General AI assistant functionality
- Chat-like interface for mathematical problem solving

**Input System:**
- `InputView.swift`: Dedicated input component for mathematical expressions

### Dependencies
- **Expression**: Mathematical expression parsing library (v0.13.9 via Swift Package Manager)
- **Foundation/URLSession**: For Claude AI API calls
- **SwiftUI**: Modern declarative UI framework

### Mathematical Notation Requirements
The app requires specific Unicode mathematical symbols and formatting:
- Use proper symbols: √, ², ³, ln, |x|, d/dx, y', ∫, π, ∞, ±
- Monospaced font display for proper alignment
- Step-by-step format with arrow (←) separators

### Testing Structure
- `GraphEQTests/`: Unit tests for core functionality
  - `MathSolverTests.swift`: Tests for mathematical solving logic
  - `Graph3DTests.swift`: Tests for 3D graphing functionality
- `GraphEQUITests/`: UI automation tests

### Project Configuration
- **Target**: GraphEQ (iOS app)
- **Minimum iOS**: 18.5+
- **Swift**: 6.0+
- **Xcode**: 26.0 beta 4+ (Xcode 26.0 beta 4 required for Swift 6.0 compatibility)
- **Build Configurations**: Debug, Release
- **Package Dependencies**: Expression library for math parsing

### Development Notes
- **Security**: API keys are currently stored directly in `MathSolverService.swift:9` (should be moved to secure configuration)
- Dark theme throughout the application
- Uses SwiftUI navigation and sheet presentations
- Mathematical expressions require careful Unicode handling for proper display
- The app uses persistent state management with `@StateObject` and `@EnvironmentObject`