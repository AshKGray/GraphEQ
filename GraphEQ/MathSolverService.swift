import Foundation

// MARK: - Real AI Math Solver Service
final class MathSolverService: @unchecked Sendable {
    static let shared = MathSolverService()
    private init() {}
    
    // API key should be loaded from environment variables or secure configuration
    // For development, set ANTHROPIC_API_KEY environment variable
    private var apiKey: String {
        // First try to get from environment variable
        if let envKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] {
            return envKey
        }
        
        // Fallback for development - replace with your actual API key
        // TODO: Remove this fallback in production
        return "YOUR_API_KEY_HERE"
    }
    
    func solveMathProblem(_ problem: String, completion: @escaping (Result<String, Error>) -> Void) {
        let prompt = createMathPrompt(for: problem)
        callClaude(prompt: prompt, completion: completion)
    }
    
    private func createMathPrompt(for problem: String) -> String {
        return """
        You are an expert mathematics tutor. Solve this math problem step by step in the EXACT format shown below.
        
        REQUIRED OUTPUT FORMAT:
        Each step must be: `mathematical_expression ← step_description`
        
        EXAMPLE FORMAT:
        y = (√x (x² - 1)⁵) / ((x + 2)(x - 4)³) ← set y = f(x)
        ln |y| = ln |(√x (x² - 1)⁵) / ((x + 2)(x - 4)³)| ← apply ln |x|
        ln |y| = ln |√x| + ln |(x² - 1)⁵| - ln |x + 2| - ln |(x - 4)³| ← algebra
        ln |y| = (1/2) ln |x| + 5 ln |x² - 1| - ln |x + 2| - 3 ln |x - 4| ← algebra
        d/dx (ln |y|) = d/dx ((1/2) ln |x| + 5 ln |x² - 1| - ln |x + 2| - 3 ln |x - 4|) ← differentiate
        (1/y) y' = (1/(2x)) + (5(2x))/(x² - 1) - (1)/(x + 2) - (3)/(x - 4) ← derivative rules
        y' = y ((1/(2x)) + (10x)/(x² - 1) - (1)/(x + 2) - (3)/(x - 4)) ← solve for y'
        
        REQUIREMENTS:
        1. Show ACTUAL mathematical work, not descriptions
        2. Use proper symbols: √, ², ³, ⁴, ⁵, ln, |x|, d/dx, y', ∫, π, ∞, ±
        3. Each line shows mathematical progression
        4. Brief arrow descriptions: "algebra", "differentiate", "apply power rule", "factor", "substitute", etc.
        5. Show every step of the mathematical transformation
        
        PROBLEM TO SOLVE: \(problem)
        
        Solve this step by step using the exact format above. Show all mathematical work.
        """
    }
    
    // MARK: - Claude API Call
    private func callClaude(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            completion(.failure(MathSolverError.invalidURL))
            return
        }
        
        let requestBody: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 4000,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { [completion = completion] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(MathSolverError.noData))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let content = json["content"] as? [[String: Any]],
                       let firstContent = content.first,
                       let text = firstContent["text"] as? String {
                        completion(.success(text))
                    } else {
                        completion(.failure(MathSolverError.noResponse))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// MARK: - Error Types
enum MathSolverError: Error, LocalizedError {
    case invalidURL
    case noData
    case noResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .noResponse:
            return "No response from AI"
        }
    }
} 