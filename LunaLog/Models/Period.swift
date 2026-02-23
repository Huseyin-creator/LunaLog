import Foundation

// MARK: - Döngü Fazları
enum CyclePhase: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case menstruation = "Regl Dönemi"
    case follicular = "Folliküler Faz"
    case ovulation = "Ovülasyon"
    case luteal = "Luteal Faz"

    var description: String {
        switch self {
        case .menstruation:
            return "Regl kanaması devam ediyor"
        case .follicular:
            return "Vücut yeni yumurta hazırlıyor"
        case .ovulation:
            return "Ovülasyon dönemi - en verimli dönem"
        case .luteal:
            return "Bir sonraki regle hazırlık dönemi"
        }
    }

    var detailedDescription: String {
        switch self {
        case .menstruation:
            return "Regl dönemi, döngünün başlangıcıdır. Rahim iç tabakası dökülür ve kanama oluşur. Genellikle 3-7 gün sürer. Bu dönemde karın ağrısı, yorgunluk ve ruh hali değişimleri yaşanabilir. Bol su içmek, sıcak kompres uygulamak ve hafif egzersiz yapmak rahatlama sağlayabilir."
        case .follicular:
            return "Folliküler faz, reglin bitmesiyle başlar ve yumurtlamaya kadar devam eder. Vücudunuz östrojen üreterek rahim iç tabakasını yeniden oluşturur. Enerji seviyeniz artar, kendinizi daha enerjik ve motive hissedebilirsiniz. Bu dönem genellikle 7-10 gün sürer ve yeni projeler başlatmak için ideal bir zamandır."
        case .ovulation:
            return "Ovülasyon, bir yumurtanın yumurtalıktan serbest bırakıldığı zamandır. Genellikle döngünün 14. günü civarında gerçekleşir ve 24-48 saat sürer. Bu dönem en verimli dönemdir. Enerji ve özgüven en yüksek seviyededir. Hafif karın ağrısı (mittelschmerz) hissedilebilir."
        case .luteal:
            return "Luteal faz, yumurtlamadan sonra başlayıp bir sonraki regle kadar sürer. Progesteron seviyesi yükselir. PMS belirtileri (sivilce, şişkinlik, göğüs hassasiyeti, ruh hali değişimleri) bu dönemde ortaya çıkabilir. Genellikle 10-14 gün sürer. Dengeli beslenme ve düzenli uyku bu belirtileri hafifletebilir."
        }
    }

    var emoji: String {
        switch self {
        case .menstruation: return "🩸"
        case .follicular: return "🌱"
        case .ovulation: return "🥚"
        case .luteal: return "🌙"
        }
    }

    var color: String {
        switch self {
        case .menstruation: return "phaseRed"
        case .follicular: return "phaseGreen"
        case .ovulation: return "phaseBlue"
        case .luteal: return "phaseYellow"
        }
    }
}

// MARK: - Regl Kaydı
struct PeriodRecord: Identifiable, Codable {
    let id: UUID
    var startDate: Date
    var endDate: Date?
    var notes: String
    var symptoms: [Symptom]

    init(id: UUID = UUID(), startDate: Date, endDate: Date? = nil, notes: String = "", symptoms: [Symptom] = []) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.symptoms = symptoms
    }

    var duration: Int? {
        guard let endDate = endDate else { return nil }
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day.map { $0 + 1 }
    }
}

// MARK: - Belirtiler
enum Symptom: String, Codable, CaseIterable, Identifiable {
    case cramps = "Kramp"
    case headache = "Baş Ağrısı"
    case bloating = "Şişkinlik"
    case fatigue = "Yorgunluk"
    case moodSwings = "Ruh Hali Değişimi"
    case backPain = "Bel Ağrısı"
    case acne = "Sivilce"
    case breastTenderness = "Göğüs Hassasiyeti"
    case nausea = "Bulantı"
    case insomnia = "Uykusuzluk"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .cramps: return "😣"
        case .headache: return "🤕"
        case .bloating: return "🫧"
        case .fatigue: return "😴"
        case .moodSwings: return "🎭"
        case .backPain: return "💆‍♀️"
        case .acne: return "😖"
        case .breastTenderness: return "💗"
        case .nausea: return "🤢"
        case .insomnia: return "🌙"
        }
    }
}

// MARK: - Günlük Kaydı
struct JournalEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var mood: Mood
    var note: String
    var symptoms: [Symptom]

    init(id: UUID = UUID(), date: Date = Date(), mood: Mood = .neutral, note: String = "", symptoms: [Symptom] = []) {
        self.id = id
        self.date = date
        self.mood = mood
        self.note = note
        self.symptoms = symptoms
    }
}

enum Mood: String, Codable, CaseIterable {
    case veryHappy = "Harika"
    case happy = "Mutlu"
    case neutral = "Normal"
    case sad = "Kötü"
    case verySad = "Çok Kötü"
    case anxious = "Kaygılı"
    case angry = "Sinirli"
    case tired = "Yorgun"

    var emoji: String {
        switch self {
        case .veryHappy: return "😍"
        case .happy: return "😊"
        case .neutral: return "😐"
        case .sad: return "😢"
        case .verySad: return "😭"
        case .anxious: return "😰"
        case .angry: return "😡"
        case .tired: return "😴"
        }
    }
}

// MARK: - Chat Mesajı
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    var content: String
    var isUser: Bool
    var date: Date

    init(id: UUID = UUID(), content: String, isUser: Bool, date: Date = Date()) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.date = date
    }
}

// MARK: - Görünüm Modu
enum AppearanceMode: String, Codable, CaseIterable {
    case system = "Sistem"
    case light = "Açık"
    case dark = "Koyu"
}

// MARK: - Uygulama Accent Rengi
import SwiftUI

enum AppAccentColor: String, Codable, CaseIterable {
    case pink = "Pembe"
    case purple = "Mor"
    case blue = "Mavi"
    case teal = "Turkuaz"
    case red = "Kırmızı"
    case orange = "Turuncu"
    case green = "Yeşil"
    case indigo = "Lacivert"

    var color: Color {
        switch self {
        case .pink: return .pink
        case .purple: return .purple
        case .blue: return .blue
        case .teal: return .teal
        case .red: return .red
        case .orange: return .orange
        case .green: return .green
        case .indigo: return .indigo
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .pink: return [.pink, .purple]
        case .purple: return [.purple, .pink]
        case .blue: return [.blue, .cyan]
        case .teal: return [.teal, .blue]
        case .red: return [.red, .orange]
        case .orange: return [.orange, .yellow]
        case .green: return [.green, .teal]
        case .indigo: return [.indigo, .purple]
        }
    }
}

// MARK: - Kullanıcı Ayarları
struct UserSettings: Codable {
    var averageCycleLength: Int
    var averagePeriodLength: Int
    var reminderEnabled: Bool
    var reminderDaysBefore: Int
    var appearanceMode: AppearanceMode
    var geminiApiKey: String
    var accentColor: AppAccentColor

    static let `default` = UserSettings(
        averageCycleLength: 28,
        averagePeriodLength: 5,
        reminderEnabled: false,
        reminderDaysBefore: 2,
        appearanceMode: .system,
        geminiApiKey: "",
        accentColor: .pink
    )

    init(averageCycleLength: Int = 28, averagePeriodLength: Int = 5, reminderEnabled: Bool = false, reminderDaysBefore: Int = 2, appearanceMode: AppearanceMode = .system, geminiApiKey: String = "", accentColor: AppAccentColor = .pink) {
        self.averageCycleLength = averageCycleLength
        self.averagePeriodLength = averagePeriodLength
        self.reminderEnabled = reminderEnabled
        self.reminderDaysBefore = reminderDaysBefore
        self.appearanceMode = appearanceMode
        self.geminiApiKey = geminiApiKey
        self.accentColor = accentColor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        averageCycleLength = try container.decode(Int.self, forKey: .averageCycleLength)
        averagePeriodLength = try container.decode(Int.self, forKey: .averagePeriodLength)
        reminderEnabled = try container.decode(Bool.self, forKey: .reminderEnabled)
        reminderDaysBefore = try container.decode(Int.self, forKey: .reminderDaysBefore)
        appearanceMode = try container.decode(AppearanceMode.self, forKey: .appearanceMode)
        geminiApiKey = try container.decode(String.self, forKey: .geminiApiKey)
        accentColor = try container.decodeIfPresent(AppAccentColor.self, forKey: .accentColor) ?? .pink
    }
}
