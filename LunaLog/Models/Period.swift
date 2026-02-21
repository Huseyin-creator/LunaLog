import Foundation

// MARK: - Döngü Fazları
enum CyclePhase: String, Codable, CaseIterable {
    case menstruation = "Regl Dönemi"
    case follicular = "Folliküler Faz"
    case ovulation = "Yumurtlama Dönemi"
    case luteal = "Luteal Faz"

    var description: String {
        switch self {
        case .menstruation:
            return "Regl kanaması devam ediyor"
        case .follicular:
            return "Vücut yeni yumurta hazırlıyor"
        case .ovulation:
            return "Yumurtlama dönemi - en verimli dönem"
        case .luteal:
            return "Bir sonraki regle hazırlık dönemi"
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

// MARK: - Kullanıcı Ayarları
struct UserSettings: Codable {
    var averageCycleLength: Int
    var averagePeriodLength: Int
    var reminderEnabled: Bool
    var reminderDaysBefore: Int
    var appearanceMode: AppearanceMode
    var geminiApiKey: String

    static let `default` = UserSettings(
        averageCycleLength: 28,
        averagePeriodLength: 5,
        reminderEnabled: false,
        reminderDaysBefore: 2,
        appearanceMode: .system,
        geminiApiKey: ""
    )
}
