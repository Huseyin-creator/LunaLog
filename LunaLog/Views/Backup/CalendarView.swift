import SwiftUI

struct CycleCalendarView: View {
    @EnvironmentObject var cycleManager: CycleManager
    @State private var displayedMonth = Date()

    private let calendar = Calendar.current
    private let daysOfWeek = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Ay Navigasyonu
                    monthNavigation

                    // Takvim
                    calendarGrid

                    // Renk Açıklaması
                    legendSection

                    // Gelecek Tahminler
                    upcomingPredictions
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Takvim")
        }
    }

    // MARK: - Ay Navigasyonu
    private var monthNavigation: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundColor(.pink)
            }

            Spacer()

            Text(monthYearString)
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            Button(action: nextMonth) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.pink)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Takvim Izgarası
    private var calendarGrid: some View {
        VStack(spacing: 8) {
            // Gün başlıkları
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Günler
            let days = generateDaysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Text("")
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private func dayCell(for date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let phase = cycleManager.phaseForDate(date)
        let isPeriodDay = isPeriodDate(date)
        let isPredicted = isPredictedPeriodDate(date)

        return VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 14, weight: isToday ? .bold : .regular))
                .foregroundColor(isToday ? .white : .primary)
                .frame(width: 32, height: 32)
                .background(
                    Group {
                        if isToday {
                            Circle().fill(Color.pink)
                        } else if isPeriodDay {
                            Circle().fill(Color.red.opacity(0.3))
                        } else if isPredicted {
                            Circle().strokeBorder(Color.red.opacity(0.5), lineWidth: 1.5)
                        } else if let phase = phase {
                            Circle().fill(phaseColor(phase).opacity(0.15))
                        }
                    }
                )

            if let phase = phase, !isToday {
                Circle()
                    .fill(phaseColor(phase))
                    .frame(width: 4, height: 4)
            }
        }
        .frame(height: 40)
    }

    private func phaseColor(_ phase: CyclePhase) -> Color {
        switch phase {
        case .menstruation: return .red
        case .follicular: return .green
        case .ovulation: return .blue
        case .luteal: return .orange
        }
    }

    // MARK: - Renk Açıklaması
    private var legendSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Açıklama")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(CyclePhase.allCases, id: \.self) { phase in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(phaseColor(phase))
                            .frame(width: 10, height: 10)
                        Text(phase.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }

                HStack(spacing: 6) {
                    Circle()
                        .strokeBorder(Color.red.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 10, height: 10)
                    Text("Tahmini Regl")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Gelecek Tahminler
    private var upcomingPredictions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gelecek Tahminler")
                .font(.headline)

            let predictions = cycleManager.predictedPeriodDates(months: 3)

            if predictions.isEmpty {
                Text("Tahmin için regl kaydı ekleyin")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(Array(predictions.enumerated()), id: \.offset) { index, prediction in
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.red.opacity(0.7))

                        VStack(alignment: .leading, spacing: 2) {
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
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.pink.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 4)

                    if index < predictions.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Yardımcı Fonksiyonlar
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private func previousMonth() {
        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
    }

    private func nextMonth() {
        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
    }

    private func generateDaysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }

        // Pazartesi = 2 (Calendar'da), biz 0-indexed istiyoruz
        var weekday = calendar.component(.weekday, from: firstDay)
        // Pazartesi başlangıçlı: Pzt=0, Sal=1, ..., Paz=6
        weekday = (weekday + 5) % 7

        var days: [Date?] = Array(repeating: nil, count: weekday)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }

        return days
    }

    private func isPeriodDate(_ date: Date) -> Bool {
        for period in cycleManager.periods {
            let end = period.endDate ?? calendar.date(byAdding: .day, value: cycleManager.calculatedAveragePeriodLength - 1, to: period.startDate)!
            if date >= calendar.startOfDay(for: period.startDate) && date <= calendar.startOfDay(for: end) {
                return true
            }
        }
        return false
    }

    private func isPredictedPeriodDate(_ date: Date) -> Bool {
        let predictions = cycleManager.predictedPeriodDates(months: 3)
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
