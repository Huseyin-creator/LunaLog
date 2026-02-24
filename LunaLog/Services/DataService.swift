import Foundation

class DataService {
    static let shared = DataService()
    private let local = StorageService.shared
    private let remote = FirestoreService.shared
    private let auth = AuthService.shared
    private init() {}

    private var shouldUseFirestore: Bool {
        auth.isAuthenticated && !auth.isGuest
    }

    private var userId: String? {
        auth.currentUser?.uid
    }

    // MARK: - Periods (Sync)
    func loadPeriodsLocal() -> [PeriodRecord] {
        local.loadPeriods()
    }

    func savePeriods(_ periods: [PeriodRecord]) {
        local.savePeriods(periods)
        guard shouldUseFirestore, let uid = userId else { return }
        Task { try? await remote.saveAllPeriods(periods, userId: uid) }
    }

    func addPeriod(_ period: PeriodRecord) {
        local.addPeriod(period)
        guard shouldUseFirestore, let uid = userId else { return }
        Task { try? await remote.savePeriod(period, userId: uid) }
    }

    func updatePeriod(_ period: PeriodRecord) {
        local.updatePeriod(period)
        guard shouldUseFirestore, let uid = userId else { return }
        Task { try? await remote.savePeriod(period, userId: uid) }
    }

    func deletePeriod(_ period: PeriodRecord) {
        local.deletePeriod(period)
        guard shouldUseFirestore, let uid = userId else { return }
        Task { try? await remote.deletePeriod(period.id, userId: uid) }
    }

    // MARK: - Periods (Async)
    func loadPeriods() async -> [PeriodRecord] {
        guard shouldUseFirestore, let uid = userId else {
            return local.loadPeriods()
        }
        do {
            let cloudPeriods = try await remote.loadPeriods(userId: uid)
            local.savePeriods(cloudPeriods)
            return cloudPeriods
        } catch {
            return local.loadPeriods()
        }
    }

    // MARK: - Journal (Sync)
    func loadJournalEntriesLocal() -> [JournalEntry] {
        local.loadJournalEntries()
    }

    func saveJournalEntries(_ entries: [JournalEntry]) {
        local.saveJournalEntries(entries)
        guard shouldUseFirestore, let uid = userId else { return }
        Task { try? await remote.saveAllJournalEntries(entries, userId: uid) }
    }

    func addJournalEntry(_ entry: JournalEntry) {
        var entries = local.loadJournalEntries()
        entries.append(entry)
        local.saveJournalEntries(entries)
        guard shouldUseFirestore, let uid = userId else { return }
        Task { try? await remote.saveJournalEntry(entry, userId: uid) }
    }

    func updateJournalEntry(_ entry: JournalEntry) {
        var entries = local.loadJournalEntries()
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            local.saveJournalEntries(entries)
        }
        guard shouldUseFirestore, let uid = userId else { return }
        Task { try? await remote.saveJournalEntry(entry, userId: uid) }
    }

    func deleteJournalEntry(_ entry: JournalEntry) {
        var entries = local.loadJournalEntries()
        entries.removeAll { $0.id == entry.id }
        local.saveJournalEntries(entries)
        guard shouldUseFirestore, let uid = userId else { return }
        Task { try? await remote.deleteJournalEntry(entry.id, userId: uid) }
    }

    // MARK: - Journal (Async)
    func loadJournalEntries() async -> [JournalEntry] {
        guard shouldUseFirestore, let uid = userId else {
            return local.loadJournalEntries()
        }
        do {
            let cloudEntries = try await remote.loadJournalEntries(userId: uid)
            local.saveJournalEntries(cloudEntries)
            return cloudEntries
        } catch {
            return local.loadJournalEntries()
        }
    }

    // MARK: - Chat (Sync)
    func loadChatMessagesLocal() -> [ChatMessage] {
        local.loadChatMessages()
    }

    func saveChatMessages(_ messages: [ChatMessage]) {
        local.saveChatMessages(messages)
        guard shouldUseFirestore, let uid = userId else { return }
        Task { try? await remote.saveAllChatMessages(messages, userId: uid) }
    }

    // MARK: - Chat (Async)
    func loadChatMessages() async -> [ChatMessage] {
        guard shouldUseFirestore, let uid = userId else {
            return local.loadChatMessages()
        }
        do {
            let cloudMessages = try await remote.loadChatMessages(userId: uid)
            local.saveChatMessages(cloudMessages)
            return cloudMessages
        } catch {
            return local.loadChatMessages()
        }
    }

    // MARK: - Settings (Sync)
    func loadSettingsLocal() -> UserSettings {
        local.loadSettings()
    }

    func saveSettings(_ settings: UserSettings) {
        local.saveSettings(settings)
        guard shouldUseFirestore, let uid = userId else { return }
        Task { try? await remote.saveSettings(settings, userId: uid) }
    }

    // MARK: - Settings (Async)
    func loadSettings() async -> UserSettings {
        guard shouldUseFirestore, let uid = userId else {
            return local.loadSettings()
        }
        do {
            if let cloudSettings = try await remote.loadSettings(userId: uid) {
                local.saveSettings(cloudSettings)
                return cloudSettings
            }
            return local.loadSettings()
        } catch {
            return local.loadSettings()
        }
    }

    // MARK: - Merge Local to Cloud
    func mergeLocalDataToCloud() {
        guard let uid = AuthService.shared.currentUser?.uid else { return }
        Task {
            let cloudSettings = try? await remote.loadSettings(userId: uid)

            if cloudSettings == nil {
                let localPeriods = local.loadPeriods()
                let localEntries = local.loadJournalEntries()
                let localMessages = local.loadChatMessages()
                let localSettings = local.loadSettings()

                try? await remote.saveSettings(localSettings, userId: uid)

                if !localPeriods.isEmpty {
                    try? await remote.saveAllPeriods(localPeriods, userId: uid)
                }
                if !localEntries.isEmpty {
                    try? await remote.saveAllJournalEntries(localEntries, userId: uid)
                }
                if !localMessages.isEmpty {
                    try? await remote.saveAllChatMessages(localMessages, userId: uid)
                }
            }
        }
    }

    // MARK: - Delete All
    func deleteAllData() {
        local.savePeriods([])
        local.saveJournalEntries([])
        local.saveChatMessages([])

        guard shouldUseFirestore, let uid = userId else { return }
        Task {
            try? await remote.deleteAllPeriods(userId: uid)
            try? await remote.deleteAllJournalEntries(userId: uid)
            try? await remote.deleteAllChat(userId: uid)
        }
    }
}
