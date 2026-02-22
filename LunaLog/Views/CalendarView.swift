import SwiftUI

struct CycleCalendarView: View {
    @EnvironmentObject var cycleManager: CycleManager
    @State private var displayedMonth = Date()

    private let calendar = Calendar.current
    private let daysOfWeek = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    calendarCard

                    legendCard

                    upcomingPredictions
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle("Takvim")
        }
    }

    // MARK: - Calendar Card
    private var calendarCard: some View {
        VStack(spacing: 16) {
            // Month Navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundColor(cycleManager.accentColor)
                        .padding(8)
                        .background(cycleManager.accentColor.opacity(0.1))
                        .cornerRadius(10)
                }

                Spacer()

                Text(monthYearString)
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundColor(cycleManager.accentColor)
                        .padding(8)
                        .background(cycleManager.accentColor.opacity(0.1))
                        .cornerRadius(10)
                }
            }

            // Day Headers
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar Grid
            let days = generateDaysInMonth()
            let predictions = cycleManager.predictedPeriodDates(months: 3)
            let avgPeriodLength = cycleManager.calculatedAveragePeriodLength
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                ForEach(days.indices, id: \.self) { index in
                    if let date = days[index] {
                        dayCell(for: date, predictions: predictions, avgPeriodLength: avgPeriodLength)
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func dayCell(for date: Date, predictions: [(start: Date, end: Date)], avgPeriodLength: Int) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isPeriodDay = isPeriodDate(date, avgPeriodLength: avgPeriodLength)
        let isPredicted = isPredictedPeriodDate(date, predictions: predictions)
        let phase = cycleManager.phaseForDate(date)

        return VStack(spacing: 3) {
            ZStack {
                if isToday {
                    Circle()
                        .fill(
                            LinearGradient(colors: cycleManager.accentGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                } else if isPeriodDay {
                    Circle()
                        .fill(Color.red.opacity(0.25))
                } else if isPredicted {
                    Circle()
                        .strokeBorder(
                            LinearGradient(colors: [.red.opacity(0.5), .pink.opacity(0.5)], startPoint: .top, endPoint: .bottom),
                            lineWidth: 1.5
                        )
                } else if let phase = phase {
                    Circle()
                        .fill(phaseColor(phase).opacity(0.12))
                }

                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 14, weight: isToday ? .bold : .regular, design: .rounded))
                    .foregroundColor(isToday ? .white : .primary)
            }
            .frame(width: 34, height: 34)

            if let phase = phase, !isToday {
                Circle()
                    .fill(phaseColor(phase))
                    .frame(width: 4, height: 4)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(height: 44)
    }

    private func phaseColor(_ phase: CyclePhase) -> Color {
        switch phase {
        case .menstruation: return .red
        case .follicular: return .green
        case .ovulation: return .blue
        case .luteal: return .orange
        }
    }

    // MARK: - Legend Card
    private var legendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Renk Açıklaması")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(CyclePhase.allCases, id: \.self) { phase in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(phaseColor(phase))
                            .frame(width: 10, height: 10)
                        Text(phase.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }

                HStack(spacing: 8) {
                    Circle()
                        .strokeBorder(Color.red.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 10, height: 10)
                    Text("Tahmini Regl")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }

                HStack(spacing: 8) {
                    Circle()
                        .fill(
                            LinearGradient(colors: cycleManager.accentGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 10, height: 10)
                    Text("Bugün")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Upcoming Predictions
    private var upcomingPredictions: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.blue)
                Text("Gelecek Tahminler")
                    .font(.headline)
                Spacer()
            }

            let predictions = cycleManager.predictedPeriodDates(months: 3)

            if predictions.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Tahmin için regl kaydı ekleyin")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 12)
                    Spacer()
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(predictions.enumerated()), id: \.offset) { index, prediction in
                        HStack(spacing: 12) {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.red.opacity(0.7))
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 3) {
                                Text("\(index + 1). Sonraki Regl")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("\(cycleManager.formatDate(prediction.start)) - \(cycleManager.formatDate(prediction.end))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            let daysUntil = calendar.dateComponents([.day], from: Date(), to: prediction.start).day ?? 0
                            if daysUntil > 0 {
                                Text("\(daysUntil) gün")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(cycleManager.accentColor.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }

                        if index < predictions.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Helpers
    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    private var monthYearString: String {
        Self.monthYearFormatter.string(from: displayedMonth)
    }

    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
        }
    }

    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
        }
    }

    private func generateDaysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }

        var weekday = calendar.component(.weekday, from: firstDay)
        weekday = (weekday + 5) % 7

        var days: [Date?] = Array(repeating: nil, count: weekday)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }

        return days
    }

    private func isPeriodDate(_ date: Date, avgPeriodLength: Int) -> Bool {
        for period in cycleManager.periods {
            let end = period.endDate ?? calendar.date(byAdding: .day, value: avgPeriodLength - 1, to: period.startDate)!
            if date >= calendar.startOfDay(for: period.startDate) && date <= calendar.startOfDay(for: end) {
                return true
            }
        }
        return false
    }

    private func isPredictedPeriodDate(_ date: Date, predictions: [(start: Date, end: Date)]) -> Bool {
        for prediction in predictions {
            if date >= calendar.startOfDay(for: prediction.start) && date <= calendar.startOfDay(for: prediction.end) {
                return true
            }
        }
        return false
    }
}

#Preview {
    CycleCalendarView()
        .environmentObject(CycleManager())
}
