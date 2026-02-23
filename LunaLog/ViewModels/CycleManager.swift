import Foundation
import SwiftUI
import WidgetKit

class CycleManager: ObservableObject {
    @Published var periods: [PeriodRecord] = []
    @Published var settings: UserSettings
    @Published var currentPhase: CyclePhase = .follicular
    @Published var journalEntries: [JournalEntry] = []

    private let storage = StorageService.shared
    private let calendar = Calendar.current

    var accentColor: Color { settings.accentColor.color }
    var accentGradient: [Color] { settings.accentColor.gradientColors }

    init() {
        self.settings = StorageService.shared.loadSettings()
        self.periods = StorageService.shared.loadPeriods()
        self.journalEntries = StorageService.shared.loadJournalEntries()
        // Sync language to UserDefaults for S struct
        UserDefaults.standard.set(settings.language.rawValue, forKey: "appLanguage")
        updateCurrentPhase()
    }

    // MARK: - CRUD İşlemleri
    func addPeriod(startDate: Date, endDate: Date? = nil, notes: String = "", symptoms: [Symptom] = []) {
        let record = PeriodRecord(startDate: startDate, endDate: endDate, notes: notes, symptoms: symptoms)
        periods.append(record)
        periods.sort { $0.startDate > $1.startDate }
        storage.savePeriods(periods)
        updateCurrentPhase()
        scheduleNotificationsIfNeeded()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func updatePeriod(_ period: PeriodRecord) {
        if let index = periods.firstIndex(where: { $0.id == period.id }) {
            periods[index] = period
            storage.savePeriods(periods)
            updateCurrentPhase()
            scheduleNotificationsIfNeeded()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func deletePeriod(_ period: PeriodRecord) {
        periods.removeAll { $0.id == period.id }
        storage.savePeriods(periods)
        updateCurrentPhase()
        scheduleNotificationsIfNeeded()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func saveSettings() {
        storage.saveSettings(settings)
        updateCurrentPhase()
        scheduleNotificationsIfNeeded()
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Sadece gorunum ayarlarini kaydeder (tema, API key gibi donguyü etkilemeyen ayarlar)
    func saveAppearanceSettings() {
        storage.saveSettings(settings)
    }

    /// Dil değiştirildiğinde çağrılır
    func changeLanguage(_ language: AppLanguage) {
        settings.language = language
        UserDefaults.standard.set(language.rawValue, forKey: "appLanguage")
        storage.saveSettings(settings)
        objectWillChange.send()
    }

    // MARK: - Günlük CRUD
    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.append(entry)
        journalEntries.sort { $0.date > $1.date }
        storage.saveJournalEntries(journalEntries)
    }

    func updateJournalEntry(_ entry: JournalEntry) {
        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
            journalEntries[index] = entry
            storage.saveJournalEntries(journalEntries)
        }
    }

    func deleteJournalEntry(_ entry: JournalEntry) {
        journalEntries.removeAll { $0.id == entry.id }
        storage.saveJournalEntries(journalEntries)
    }

    func journalEntryForToday() -> JournalEntry? {
        let today = Calendar.current.startOfDay(for: Date())
        return journalEntries.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    // MARK: - Hesaplamalar

    /// Son regl kaydı
    var lastPeriod: PeriodRecord? {
        periods.first
    }

    /// Ortalama döngü uzunluğu (geçmiş verilerden)
    var calculatedAverageCycleLength: Int {
        let sorted = periods.sorted { $0.startDate < $1.startDate }
        guard sorted.count >= 2 else { return settings.averageCycleLength }

        var totalDays = 0
        var count = 0

        for i in 1..<sorted.count {
            let days = calendar.dateComponents([.day], from: sorted[i - 1].startDate, to: sorted[i].startDate).day ?? 0
            if days > 15 && days < 50 { // Makul aralık
                totalDays += days
                count += 1
            }
        }

        return count > 0 ? totalDays / count : settings.averageCycleLength
    }

    /// Ortalama regl süresi (geçmiş verilerden)
    var calculatedAveragePeriodLength: Int {
        let withEnd = periods.filter { $0.endDate != nil }
        guard !withEnd.isEmpty else { return settings.averagePeriodLength }

        let total = withEnd.compactMap { $0.duration }.reduce(0, +)
        return total / withEnd.count
    }

    /// Tahmini regl bitiş tarihi
    var estimatedEndDate: Date? {
        guard let last = lastPeriod else { return nil }

        if let endDate = last.endDate {
            return endDate
        }

        return calendar.date(byAdding: .day, value: calculatedAveragePeriodLength - 1, to: last.startDate)
    }

    /// Bir sonraki regl tahmini
    var nextPeriodDate: Date? {
        guard let last = lastPeriod else { return nil }
        return calendar.date(byAdding: .day, value: calculatedAverageCycleLength, to: last.startDate)
    }

    /// Bir sonraki yumurtlama tahmini
    var nextOvulationDate: Date? {
        guard let last = lastPeriod else { return nil }
        // Yumurtlama genellikle döngünün ortasında, bir sonraki reglden ~14 gün önce
        let ovulationDay = calculatedAverageCycleLength - 14
        return calendar.date(byAdding: .day, value: ovulationDay, to: last.startDate)
    }

    /// Verimli (doğurgan) pencere
    var fertileWindowStart: Date? {
        guard let ovulation = nextOvulationDate else { return nil }
        return calendar.date(byAdding: .day, value: -5, to: ovulation)
    }

    var fertileWindowEnd: Date? {
        guard let ovulation = nextOvulationDate else { return nil }
        return calendar.date(byAdding: .day, value: 1, to: ovulation)
    }

    /// Döngünün kaçıncı günü
    var currentDayOfCycle: Int? {
        guard let last = lastPeriod else { return nil }
        let days = calendar.dateComponents([.day], from: last.startDate, to: Date()).day ?? 0
        return days + 1
    }

    /// Bir sonraki regle kalan gün
    var daysUntilNextPeriod: Int? {
        guard let nextDate = nextPeriodDate else { return nil }
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: nextDate)).day
        return days
    }

    /// Şu anki döngü fazını güncelle
    func updateCurrentPhase() {
        guard let last = lastPeriod, let dayOfCycle = currentDayOfCycle else {
            currentPhase = .follicular
            return
        }

        let periodLength = last.endDate != nil
            ? (last.duration ?? settings.averagePeriodLength)
            : settings.averagePeriodLength

        let cycleLength = calculatedAverageCycleLength
        let ovulationDay = cycleLength - 14

        if dayOfCycle <= periodLength {
            // Regl bitiş tarihi girilmemişse ve tahmini süre geçtiyse reglde sayma
            if last.endDate == nil {
                currentPhase = .menstruation
            } else {
                currentPhase = .menstruation
            }
        } else if dayOfCycle <= ovulationDay - 5 {
            currentPhase = .follicular
        } else if dayOfCycle <= ovulationDay + 1 {
            currentPhase = .ovulation
        } else if dayOfCycle <= cycleLength {
            currentPhase = .luteal
        } else {
            // Döngü süresini aştıysa muhtemelen yeni döngü başlamış ama kaydedilmemiş
            currentPhase = .luteal
        }
    }

    /// Belirli bir tarih için döngü fazını hesapla
    func phaseForDate(_ date: Date) -> CyclePhase? {
        let sorted = periods.sorted { $0.startDate < $1.startDate }
        guard !sorted.isEmpty else { return nil }

        // En yakın önceki regl kaydını bul
        var relevantPeriod: PeriodRecord?
        for period in sorted.reversed() {
            if period.startDate <= date {
                relevantPeriod = period
                break
            }
        }

        guard let period = relevantPeriod else { return nil }

        let dayOfCycle = (calendar.dateComponents([.day], from: period.startDate, to: date).day ?? 0) + 1
        let periodLength = period.duration ?? settings.averagePeriodLength
        let cycleLength = calculatedAverageCycleLength
        let ovulationDay = cycleLength - 14

        if dayOfCycle <= periodLength {
            return .menstruation
        } else if dayOfCycle <= ovulationDay - 5 {
            return .follicular
        } else if dayOfCycle <= ovulationDay + 1 {
            return .ovulation
        } else if dayOfCycle <= cycleLength {
            return .luteal
        }

        return nil
    }

    /// Tahmini regl günleri (gelecek 3 döngü)
    func predictedPeriodDates(months: Int = 3) -> [(start: Date, end: Date)] {
        guard let last = lastPeriod else { return [] }

        var predictions: [(start: Date, end: Date)] = []
        let cycleLen = calculatedAverageCycleLength
        let periodLen = calculatedAveragePeriodLength

        for i in 1...months {
            guard let start = calendar.date(byAdding: .day, value: cycleLen * i, to: last.startDate),
                  let end = calendar.date(byAdding: .day, value: periodLen - 1, to: start) else { continue }
            predictions.append((start: start, end: end))
        }

        return predictions
    }

    // MARK: - Tarih Formatlama
    func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = S.locale
        f.dateFormat = "d MMMM yyyy"
        return f.string(from: date)
    }

    func formatShortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = S.locale
        f.dateFormat = "d MMM"
        return f.string(from: date)
    }

    // MARK: - Bildirimler
    func scheduleNotificationsIfNeeded() {
        guard settings.reminderEnabled else {
            NotificationService.shared.cancelAllNotifications()
            return
        }

        NotificationService.shared.scheduleNotifications(
            nextPeriodDate: nextPeriodDate,
            estimatedEndDate: estimatedEndDate,
            daysBefore: settings.reminderDaysBefore
        )
    }

    func enableNotifications(completion: @escaping (Bool) -> Void) {
        NotificationService.shared.requestPermission { [weak self] granted in
            guard let self = self else { return }
            self.settings.reminderEnabled = granted
            self.saveSettings()
            completion(granted)
        }
    }

    func disableNotifications() {
        settings.reminderEnabled = false
        saveSettings()
    }
}
