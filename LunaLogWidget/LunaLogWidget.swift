import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct CycleEntry: TimelineEntry {
    let date: Date
    let currentDayOfCycle: Int?
    let totalCycleLength: Int
    let daysUntilNextPeriod: Int?
    let currentPhase: CyclePhase
    let phaseEmoji: String
    let phaseName: String
    let nextPeriodDate: Date?
    let nextOvulationDate: Date?
    let estimatedEndDate: Date?
    let hasPeriods: Bool
}

// MARK: - Timeline Provider
struct CycleTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> CycleEntry {
        CycleEntry(
            date: Date(),
            currentDayOfCycle: 14,
            totalCycleLength: 28,
            daysUntilNextPeriod: 14,
            currentPhase: .follicular,
            phaseEmoji: "🌱",
            phaseName: "Folliküler Faz",
            nextPeriodDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()),
            nextOvulationDate: nil,
            estimatedEndDate: nil,
            hasPeriods: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CycleEntry) -> Void) {
        completion(createEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CycleEntry>) -> Void) {
        let entry = createEntry()
        // Her gün gece yarısı güncelle
        let tomorrow = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }

    private func createEntry() -> CycleEntry {
        let calc = WidgetCalculator()

        return CycleEntry(
            date: Date(),
            currentDayOfCycle: calc.currentDayOfCycle,
            totalCycleLength: calc.cycleLength,
            daysUntilNextPeriod: calc.daysUntilNextPeriod,
            currentPhase: calc.currentPhase,
            phaseEmoji: calc.currentPhase.emoji,
            phaseName: calc.currentPhase.rawValue,
            nextPeriodDate: calc.nextPeriodDate,
            nextOvulationDate: calc.nextOvulationDate,
            estimatedEndDate: calc.estimatedEndDate,
            hasPeriods: calc.hasPeriods
        )
    }
}

// MARK: - Widget Hesaplayıcı (StorageService'den bağımsız, hafif)
struct WidgetCalculator {
    let periods: [PeriodRecord]
    let settings: UserSettings
    private let calendar = Calendar.current

    init() {
        let defaults = UserDefaults(suiteName: "group.com.seros.LunaLog") ?? UserDefaults.standard
        let decoder = JSONDecoder()

        if let data = defaults.data(forKey: "savedPeriods"),
           let decoded = try? decoder.decode([PeriodRecord].self, from: data) {
            self.periods = decoded.sorted { $0.startDate > $1.startDate }
        } else {
            self.periods = []
        }

        if let data = defaults.data(forKey: "userSettings"),
           let decoded = try? decoder.decode(UserSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = .default
        }
    }

    var hasPeriods: Bool { !periods.isEmpty }

    var lastPeriod: PeriodRecord? { periods.first }

    var cycleLength: Int {
        let sorted = periods.sorted { $0.startDate < $1.startDate }
        guard sorted.count >= 2 else { return settings.averageCycleLength }
        var total = 0, count = 0
        for i in 1..<sorted.count {
            let days = calendar.dateComponents([.day], from: sorted[i-1].startDate, to: sorted[i].startDate).day ?? 0
            if days > 15 && days < 50 { total += days; count += 1 }
        }
        return count > 0 ? total / count : settings.averageCycleLength
    }

    var periodLength: Int {
        let withEnd = periods.filter { $0.endDate != nil }
        guard !withEnd.isEmpty else { return settings.averagePeriodLength }
        let total = withEnd.compactMap { $0.duration }.reduce(0, +)
        return total / withEnd.count
    }

    var currentDayOfCycle: Int? {
        guard let last = lastPeriod else { return nil }
        return (calendar.dateComponents([.day], from: last.startDate, to: Date()).day ?? 0) + 1
    }

    var nextPeriodDate: Date? {
        guard let last = lastPeriod else { return nil }
        return calendar.date(byAdding: .day, value: cycleLength, to: last.startDate)
    }

    var daysUntilNextPeriod: Int? {
        guard let next = nextPeriodDate else { return nil }
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: next)).day
    }

    var nextOvulationDate: Date? {
        guard let last = lastPeriod else { return nil }
        return calendar.date(byAdding: .day, value: cycleLength - 14, to: last.startDate)
    }

    var estimatedEndDate: Date? {
        guard let last = lastPeriod else { return nil }
        if let end = last.endDate { return end }
        return calendar.date(byAdding: .day, value: periodLength - 1, to: last.startDate)
    }

    var currentPhase: CyclePhase {
        guard let last = lastPeriod, let day = currentDayOfCycle else { return .follicular }
        let pLen = last.endDate != nil ? (last.duration ?? settings.averagePeriodLength) : settings.averagePeriodLength
        let ovDay = cycleLength - 14

        if day <= pLen { return .menstruation }
        else if day <= ovDay - 5 { return .follicular }
        else if day <= ovDay + 1 { return .ovulation }
        else { return .luteal }
    }
}

// MARK: - Tarih Formatlama
private let trDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "tr_TR")
    f.dateFormat = "d MMM"
    return f
}()

private func formatDate(_ date: Date) -> String {
    trDateFormatter.string(from: date)
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: CycleEntry

    var body: some View {
        if entry.hasPeriods {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 6)

                    if let day = entry.currentDayOfCycle {
                        Circle()
                            .trim(from: 0, to: min(Double(day) / Double(entry.totalCycleLength), 1.0))
                            .stroke(phaseColor(entry.currentPhase), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                    }

                    VStack(spacing: 0) {
                        Text(entry.phaseEmoji)
                            .font(.system(size: 20))
                        if let day = entry.currentDayOfCycle {
                            Text("\(day)")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                            Text("gün")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(width: 80, height: 80)

                if let daysLeft = entry.daysUntilNextPeriod, daysLeft > 0 {
                    Text("\(daysLeft) gün kaldı")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.pink)
                } else {
                    Text(entry.phaseName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .containerBackground(for: .widget) {
                Color(.systemBackground)
            }
        } else {
            VStack(spacing: 8) {
                Image(systemName: "heart.circle")
                    .font(.system(size: 36))
                    .foregroundColor(.pink)
                Text("Kayıt Ekle")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .containerBackground(for: .widget) {
                Color(.systemBackground)
            }
        }
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: CycleEntry

    var body: some View {
        if entry.hasPeriods {
            HStack(spacing: 16) {
                // Sol: Dairesel gösterge
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 6)

                    if let day = entry.currentDayOfCycle {
                        Circle()
                            .trim(from: 0, to: min(Double(day) / Double(entry.totalCycleLength), 1.0))
                            .stroke(phaseColor(entry.currentPhase), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                    }

                    VStack(spacing: 0) {
                        Text(entry.phaseEmoji)
                            .font(.system(size: 18))
                        if let day = entry.currentDayOfCycle {
                            Text("\(day)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                        }
                    }
                }
                .frame(width: 80, height: 80)

                // Sağ: Bilgiler
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.phaseName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(phaseColor(entry.currentPhase))

                    if let daysLeft = entry.daysUntilNextPeriod, daysLeft > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 11))
                                .foregroundColor(.pink)
                            Text("\(daysLeft) gün sonra regl")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }

                    if let next = entry.nextPeriodDate {
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                            Text("Sonraki: \(formatDate(next))")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }

                    if let day = entry.currentDayOfCycle {
                        Text("Döngünün \(day). günü / \(entry.totalCycleLength)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 4)
            .containerBackground(for: .widget) {
                Color(.systemBackground)
            }
        } else {
            HStack {
                Image(systemName: "heart.circle")
                    .font(.system(size: 40))
                    .foregroundColor(.pink)
                VStack(alignment: .leading) {
                    Text("Döngü Takibi")
                        .font(.headline)
                    Text("İlk kaydını eklemek için uygulamayı aç")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .containerBackground(for: .widget) {
                Color(.systemBackground)
            }
        }
    }
}

// MARK: - Large Widget View
struct LargeWidgetView: View {
    let entry: CycleEntry

    var body: some View {
        if entry.hasPeriods {
            VStack(alignment: .leading, spacing: 12) {
                // Üst: Faz + Döngü Günü
                HStack {
                    Text(entry.phaseEmoji)
                        .font(.system(size: 32))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.phaseName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(phaseColor(entry.currentPhase))

                        if let day = entry.currentDayOfCycle {
                            Text("Döngünün \(day). günü")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    // Mini dairesel gösterge
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 5)
                        if let day = entry.currentDayOfCycle {
                            Circle()
                                .trim(from: 0, to: min(Double(day) / Double(entry.totalCycleLength), 1.0))
                                .stroke(phaseColor(entry.currentPhase), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                            Text("\(day)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                    }
                    .frame(width: 50, height: 50)
                }

                Divider()

                // Kalan gün vurgusu
                if let daysLeft = entry.daysUntilNextPeriod, daysLeft > 0 {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.pink)
                            .frame(width: 24)
                        VStack(alignment: .leading) {
                            Text("Sonraki Regl")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text("\(daysLeft) gün kaldı")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.pink)
                        }
                        Spacer()
                        if let next = entry.nextPeriodDate {
                            Text(formatDate(next))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Yumurtlama
                if let ovulation = entry.nextOvulationDate {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        VStack(alignment: .leading) {
                            Text("Yumurtlama Tahmini")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(formatDate(ovulation))
                                .font(.system(size: 13, weight: .medium))
                        }
                        Spacer()
                        let daysToOv = Calendar.current.dateComponents([.day], from: Date(), to: ovulation).day ?? 0
                        if daysToOv > 0 {
                            Text("\(daysToOv) gün")
                                .font(.system(size: 11, weight: .medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                }

                // Regl bitiş tahmini (devam ediyorsa)
                if let endDate = entry.estimatedEndDate,
                   entry.currentPhase == .menstruation {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        VStack(alignment: .leading) {
                            Text("Tahmini Bitiş")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(formatDate(endDate))
                                .font(.system(size: 13, weight: .medium))
                        }
                        Spacer()
                    }
                }

                Spacer()

                // Alt: Döngü fazları bar
                HStack(spacing: 2) {
                    ForEach(CyclePhase.allCases, id: \.self) { phase in
                        HStack(spacing: 3) {
                            Circle()
                                .fill(phaseColor(phase))
                                .frame(width: 6, height: 6)
                            Text(phase.rawValue)
                                .font(.system(size: 8))
                                .foregroundColor(phase == entry.currentPhase ? phaseColor(phase) : .secondary)
                                .fontWeight(phase == entry.currentPhase ? .bold : .regular)
                        }
                        if phase != .luteal { Spacer() }
                    }
                }
            }
            .containerBackground(for: .widget) {
                Color(.systemBackground)
            }
        } else {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "heart.circle")
                    .font(.system(size: 50))
                    .foregroundColor(.pink)
                Text("Döngü Takibi")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("İlk regl kaydını eklemek için\nuygulamayı aç")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .containerBackground(for: .widget) {
                Color(.systemBackground)
            }
        }
    }
}

// MARK: - Faz Renkleri
private func phaseColor(_ phase: CyclePhase) -> Color {
    switch phase {
    case .menstruation: return .red
    case .follicular: return .green
    case .ovulation: return .blue
    case .luteal: return .orange
    }
}

// MARK: - Widget Tanımı
struct LunaLogWidget: Widget {
    let kind: String = "LunaLogWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CycleTimelineProvider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("Döngü Takibi")
        .description("Regl döngünü ana ekranından takip et")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Boyuta Göre View Seçici
struct WidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: CycleEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Previews
#Preview("Small", as: .systemSmall) {
    LunaLogWidget()
} timeline: {
    CycleEntry(
        date: Date(),
        currentDayOfCycle: 14,
        totalCycleLength: 28,
        daysUntilNextPeriod: 14,
        currentPhase: .follicular,
        phaseEmoji: "🌱",
        phaseName: "Folliküler Faz",
        nextPeriodDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()),
        nextOvulationDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
        estimatedEndDate: nil,
        hasPeriods: true
    )
}

#Preview("Medium", as: .systemMedium) {
    LunaLogWidget()
} timeline: {
    CycleEntry(
        date: Date(),
        currentDayOfCycle: 14,
        totalCycleLength: 28,
        daysUntilNextPeriod: 14,
        currentPhase: .follicular,
        phaseEmoji: "🌱",
        phaseName: "Folliküler Faz",
        nextPeriodDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()),
        nextOvulationDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
        estimatedEndDate: nil,
        hasPeriods: true
    )
}

#Preview("Large", as: .systemLarge) {
    LunaLogWidget()
} timeline: {
    CycleEntry(
        date: Date(),
        currentDayOfCycle: 3,
        totalCycleLength: 28,
        daysUntilNextPeriod: 25,
        currentPhase: .menstruation,
        phaseEmoji: "🩸",
        phaseName: "Regl Dönemi",
        nextPeriodDate: Calendar.current.date(byAdding: .day, value: 25, to: Date()),
        nextOvulationDate: Calendar.current.date(byAdding: .day, value: 11, to: Date()),
        estimatedEndDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
        hasPeriods: true
    )
}
