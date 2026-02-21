import Foundation

class StorageService {
    static let shared = StorageService()

    private let periodsKey = "savedPeriods"
    private let settingsKey = "userSettings"
    private let journalKey = "journalEntries"
    private let chatKey = "chatMessages"
    static let appGroupID = "group.com.seros.LunaLog"
    private let defaults = UserDefaults(suiteName: "group.com.seros.LunaLog") ?? UserDefaults.standard
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {}

    // MARK: - Period Records
    func savePeriods(_ periods: [PeriodRecord]) {
        if let data = try? encoder.encode(periods) {
            defaults.set(data, forKey: periodsKey)
        }
    }

    func loadPeriods() -> [PeriodRecord] {
        guard let data = defaults.data(forKey: periodsKey),
              let periods = try? decoder.decode([PeriodRecord].self, from: data) else {
            return []
        }
        return periods.sorted { $0.startDate > $1.startDate }
    }

    func addPeriod(_ period: PeriodRecord) {
        var periods = loadPeriods()
        periods.append(period)
        savePeriods(periods)
    }

    func updatePeriod(_ period: PeriodRecord) {
        var periods = loadPeriods()
        if let index = periods.firstIndex(where: { $0.id == period.id }) {
            periods[index] = period
            savePeriods(periods)
        }
    }

    func deletePeriod(_ period: PeriodRecord) {
        var periods = loadPeriods()
        periods.removeAll { $0.id == period.id }
        savePeriods(periods)
    }

    // MARK: - Journal Entries
    func saveJournalEntries(_ entries: [JournalEntry]) {
        if let data = try? encoder.encode(entries) {
            defaults.set(data, forKey: journalKey)
        }
    }

    func loadJournalEntries() -> [JournalEntry] {
        guard let data = defaults.data(forKey: journalKey),
              let entries = try? decoder.decode([JournalEntry].self, from: data) else {
            return []
        }
        return entries.sorted { $0.date > $1.date }
    }

    // MARK: - Chat Messages
    func saveChatMessages(_ messages: [ChatMessage]) {
        if let data = try? encoder.encode(messages) {
            defaults.set(data, forKey: chatKey)
        }
    }

    func loadChatMessages() -> [ChatMessage] {
        guard let data = defaults.data(forKey: chatKey),
              let messages = try? decoder.decode([ChatMessage].self, from: data) else {
            return []
        }
        return messages
    }

    // MARK: - User Settings
    func saveSettings(_ settings: UserSettings) {
        if let data = try? encoder.encode(settings) {
            defaults.set(data, forKey: settingsKey)
        }
    }

    func loadSettings() -> UserSettings {
        guard let data = defaults.data(forKey: settingsKey),
              let settings = try? decoder.decode(UserSettings.self, from: data) else {
            return .default
        }
        return settings
    }
}
