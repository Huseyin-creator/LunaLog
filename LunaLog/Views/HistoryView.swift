import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var cycleManager: CycleManager
    @State private var selectedPeriod: PeriodRecord?
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var periodToDelete: PeriodRecord?

    var body: some View {
        NavigationView {
            Group {
                if cycleManager.periods.isEmpty {
                    emptyState
                } else {
                    List {
                        // İstatistikler
                        Section {
                            statisticsCard
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)

                        // Geçmiş Kayıtlar
                        Section(header: Text(S.pastRecords)) {
                            ForEach(cycleManager.periods) { period in
                                periodRow(period)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            periodToDelete = period
                                            showDeleteAlert = true
                                        } label: {
                                            Label(S.delete, systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            selectedPeriod = period
                                            showEditSheet = true
                                        } label: {
                                            Label(S.edit, systemImage: "pencil")
                                        }
                                        .tint(.blue)
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle(S.historyTitle)
            .sheet(isPresented: $showEditSheet) {
                if let period = selectedPeriod {
                    EditPeriodView(period: period)
                        .environmentObject(cycleManager)
                }
            }
            .alert(S.deleteRecord, isPresented: $showDeleteAlert) {
                Button(S.cancel, role: .cancel) {}
                Button(S.delete, role: .destructive) {
                    if let period = periodToDelete {
                        withAnimation {
                            cycleManager.deletePeriod(period)
                        }
                    }
                }
            } message: {
                Text(S.deletePeriodConfirm)
            }
        }
    }

    // MARK: - Boş Durum
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(cycleManager.accentColor.opacity(0.5))

            Text(S.noRecordsYet)
                .font(.title2)
                .fontWeight(.medium)

            Text(S.noRecordsDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - İstatistikler
    private var statisticsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(cycleManager.accentColor)
                Text(S.statistics)
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 16) {
                statItem(
                    value: "\(cycleManager.calculatedAverageCycleLength)",
                    label: S.avgCycle,
                    unit: S.day
                )

                Divider().frame(height: 40)

                statItem(
                    value: "\(cycleManager.calculatedAveragePeriodLength)",
                    label: S.avgPeriod,
                    unit: S.day
                )

                Divider().frame(height: 40)

                statItem(
                    value: "\(cycleManager.periods.count)",
                    label: S.total,
                    unit: S.record
                )
            }

            // Döngü uzunluğu değişkenliği
            if cycleManager.periods.count >= 3 {
                let lengths = calculateCycleLengths()
                if let shortest = lengths.min(), let longest = lengths.max() {
                    HStack {
                        Text(S.cycleRange)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(S.daysRange(shortest, longest))
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func statItem(value: String, label: String, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(cycleManager.accentColor)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Kayıt Satırı
    private func periodRow(_ period: PeriodRecord) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(cycleManager.formatDate(period.startDate))
                        .font(.body)
                        .fontWeight(.medium)

                    if let endDate = period.endDate {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.right")
                                .font(.caption2)
                            Text(cycleManager.formatDate(endDate))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                if let duration = period.duration {
                    Text(S.daysUnit(duration))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(cycleManager.accentColor.opacity(0.1))
                        .foregroundColor(cycleManager.accentColor)
                        .cornerRadius(8)
                } else {
                    Text(S.ongoing)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                }
            }

            // Belirtiler
            if !period.symptoms.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(period.symptoms) { symptom in
                            Text("\(symptom.emoji) \(symptom.displayName)")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color(.systemGray6))
                                .cornerRadius(6)
                        }
                    }
                }
            }

            // Notlar
            if !period.notes.isEmpty {
                Text(period.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Yardımcı
    private func calculateCycleLengths() -> [Int] {
        let sorted = cycleManager.periods.sorted { $0.startDate < $1.startDate }
        var lengths: [Int] = []

        for i in 1..<sorted.count {
            let days = Calendar.current.dateComponents([.day], from: sorted[i - 1].startDate, to: sorted[i].startDate).day ?? 0
            if days > 15 && days < 50 {
                lengths.append(days)
            }
        }

        return lengths
    }
}

#Preview {
    HistoryView()
        .environmentObject(CycleManager())
}
