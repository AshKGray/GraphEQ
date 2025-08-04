# Tech Stack

## Context

Global tech stack details for the GraphEQ project. This is a SwiftUI-based iOS mathematical graphing application with AI-powered step-by-step problem solving capabilities.

- App Framework: SwiftUI (iOS 15.0+)
- Language: Swift 5.7+
- Architecture Pattern: MVVM with ObservableObject and @EnvironmentObject
- Build Tool: Xcode 15.0+
- Import Strategy: Swift Package Manager (SPM), local modules
- Package Manager: Swift Package Manager
- Primary Database: None (in-memory only)
- ORM: None
- JavaScript Framework: None
- CSS Framework: None
- UI Components: SwiftUI Views, Canvas, custom button styles and animations
- UI Installation: Direct in app code
- Font Provider: Apple System Fonts (San Francisco), monospaced for mathematical notation
- Font Loading: SwiftUI font modifiers, system default
- Icons: SF Symbols, custom SwiftUI shapes, mathematical Unicode symbols
- Mathematical Library: Expression 0.13.9 (nicklockwood/Expression)
- AI Service: Claude AI API (Anthropic)
- API Integration: URLSession for Claude AI REST API calls
- Mathematical Parsing: Expression library with constants and evaluation
- Curve Fitting: Custom CurveFitter class with polynomial regression
- Graphics Framework: CoreGraphics for 2D rendering
- 3D Models: Custom CGPoint3D, Surface3D, Camera3D structures
- 3D Rendering: Basic 3D data structures (SceneKit integration planned)
- Performance Optimization: Optimized sampling algorithms for smooth curves
- Application Hosting: Apple App Store / TestFlight / Local Device
- Hosting Region: N/A
- Database Hosting: N/A
- Database Backups: N/A
- Asset Storage: App Bundle (no external asset hosting)
- CDN: N/A
- Asset Access: App Bundle
- CI/CD Platform: Not specified (Xcode Cloud or GitHub Actions recommended)
- CI/CD Trigger: N/A
- Tests: XCTest framework for unit and UI testing
- Production Environment: iOS device (iOS 15.0+)
- Staging Environment: iOS Simulator, Xcode Previews
- Code Repository URL: Local repository (not specified)