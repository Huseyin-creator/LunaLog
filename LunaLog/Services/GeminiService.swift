import Foundation

class GeminiService {
    static let shared = GeminiService()
    private init() {}

    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    private let defaultApiKey: String = {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["GEMINI_API_KEY"] as? String else {
            return ""
        }
        return key
    }()

    func sendMessage(
        userMessage: String,
        cycleContext: String,
        apiKey: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let activeKey = apiKey.isEmpty ? defaultApiKey : apiKey

        guard !activeKey.isEmpty else {
            completion(.failure(GeminiError.noApiKey))
            return
        }

        guard let url = URL(string: "\(baseURL)?key=\(activeKey)") else {
            completion(.failure(GeminiError.invalidURL))
            return
        }

        let systemPrompt = S.geminiSystemPrompt(cycleContext)

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": systemPrompt + "\n\n" + S.geminiUserPrefix + userMessage]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 2048
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(GeminiError.noData)) }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let error = json["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        DispatchQueue.main.async { completion(.failure(GeminiError.apiError(message))) }
                        return
                    }

                    if let candidates = json["candidates"] as? [[String: Any]],
                       let first = candidates.first,
                       let content = first["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let text = parts.first?["text"] as? String {
                        DispatchQueue.main.async { completion(.success(text.trimmingCharacters(in: .whitespacesAndNewlines))) }
                    } else {
                        DispatchQueue.main.async { completion(.failure(GeminiError.parseError)) }
                    }
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}

enum GeminiError: LocalizedError {
    case noApiKey
    case invalidURL
    case noData
    case parseError
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .noApiKey:
            return S.errorNoApiKey
        case .invalidURL:
            return S.errorInvalidURL
        case .noData:
            return S.errorNoData
        case .parseError:
            return S.errorParseError
        case .apiError(let message):
            return S.errorApiError(message)
        }
    }
}
