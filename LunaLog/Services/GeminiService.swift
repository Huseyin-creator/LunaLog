import Foundation

class GeminiService {
    static let shared = GeminiService()
    private init() {}

    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    // Varsayılan API anahtarı - ileride Firebase'e taşınacak
    private let defaultApiKey = "AIzaSyBpttZ-6NXrziR58jXaOI1nD8WX7i1VtP4"

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

        let systemPrompt = """
        Sen bir kadın sağlığı asistanısın. Regl döngüsü, belirtiler ve kadın sağlığı hakkında yardımcı bilgiler veriyorsun. \
        Türkçe konuş, samimi ve destekleyici ol. Kısa ve anlaşılır cevaplar ver. \
        Tıbbi teşhis koyma, gerektiğinde doktora yönlendir. \
        Kullanıcının döngü bilgileri şöyle:

        \(cycleContext)
        """

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": systemPrompt + "\n\nKullanıcı: " + userMessage]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 500
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

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
                    // Hata kontrolü
                    if let error = json["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        DispatchQueue.main.async { completion(.failure(GeminiError.apiError(message))) }
                        return
                    }

                    // Cevabı parse et
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
            return "API anahtarı girilmemiş. Ayarlar'dan Gemini API anahtarını gir."
        case .invalidURL:
            return "Geçersiz URL."
        case .noData:
            return "Sunucudan yanıt alınamadı."
        case .parseError:
            return "Yanıt işlenemedi."
        case .apiError(let message):
            return "API Hatası: \(message)"
        }
    }
}
