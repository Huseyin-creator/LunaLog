import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var cycleManager: CycleManager
    @State private var showAddPeriod = false
    @State private var showEndPeriodSheet = false

    var body: some View {
        NavigationView {
            Group {
                if cycleManager.periods.isEmpty {
                    // Hiç kayıt yokken hoş geldin ekranı
                    emptyStateView
                } else {
                    // Kayıt varken dashboard
                    ScrollView {
                        VStack(spacing: 20) {
                            currentPhaseCard

                            if let last = cycleManager.lastPeriod {
                                lastPeriodCard(last)
                            }

                            if let dayOfCycle = cycleManager.currentDayOfCycle {
                                cycleDayIndicator(day: dayOfCycle)
                            }

                            HStack(spacing: 12) {
                                infoCard(
                                    title: "Kalan Gün",
                                    value: cycleManager.daysUntilNextPeriod.map { "\($0)" } ?? "-",
                                    subtitle: "Sonraki regl",
                                    icon: "calendar.badge.clock",
                                    color: .pink
                                )

                                infoCard(
                                    title: "Döngü Süresi",
                                    value: "\(cycleManager.calculatedAverageCycleLength)",
                                    subtitle: "gün ortalama",
                                    icon: "arrow.triangle.2.circlepath",
                                    color: .purple
                                )
                            }

                            HStack(spacing: 12) {
                                infoCard(
                                    title: "Regl Süresi",
                                    value: "\(cycleManager.calculatedAveragePeriodLength)",
                                    subtitle: "gün ortalama",
                                    icon: "drop.fill",
                                    color: .red
                                )

                                infoCard(
                                    title: "Toplam Kayıt",
                                    value: "\(cycleManager.periods.count)",
                                    subtitle: "regl kaydı",
                                    icon: "list.clipboard",
                                    color: .orange
                                )
                            }

                            predictionsSection

                            if let fertileStart = cycleManager.fertileWindowStart,
                               let fertileEnd = cycleManager.fertileWindowEnd {
                                fertileWindowCard(start: fertileStart, end: fertileEnd)
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .navigationTitle("Döngü Takibi")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddPeriod = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.pink)
                    }
                }
            }
            .sheet(isPresented: $showAddPeriod) {
                AddPeriodView()
            }
            .sheet(isPresented: $showEndPeriodSheet) {
                EndPeriodView()
            }
        }
    }

    // MARK: - Boş Durum (İlk Açılış)
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "heart.circle")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            Text("Hoş Geldin!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Döngünü takip etmeye başlamak için\nilk regl kaydını ekle")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: { showAddPeriod = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("İlk Kaydını Ekle")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(16)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Son Regl Bilgi Kartı
    private func lastPeriodCard(_ period: PeriodRecord) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundColor(.red)
                    .font(.title3)
                Text("Son Regl Bilgisi")
                    .font(.headline)
                Spacer()
            }

            VStack(spacing: 10) {
                HStack {
                    Text("Başlangıç")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(cycleManager.formatDate(period.startDate))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                if let endDate = period.endDate {
                    HStack {
                        Text("Bitiş")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(cycleManager.formatDate(endDate))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Süre")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(period.duration ?? 0) gün")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.pink)
                    }
                } else {
                    if let estimatedEnd = cycleManager.estimatedEndDate {
                        HStack {
                            Text("Tahmini Bitiş")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            HStack(spacing: 4) {
                                Text("~")
                                    .foregroundColor(.orange)
                                Text(cycleManager.formatDate(estimatedEnd))
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                        }
                    }

                    Divider()

                    Button(action: { showEndPeriodSheet = true }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Reglim Bitti")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [.pink, .red], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                    }
                }

                if !period.symptoms.isEmpty {
                    Divider()
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(period.symptoms) { symptom in
                                Text("\(symptom.emoji) \(symptom.rawValue)")
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.pink.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Döngü Fazı Kartı
    private var currentPhaseCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text(cycleManager.currentPhase.emoji)
                    .font(.system(size: 44))

                VStack(alignment: .leading, spacing: 4) {
                    Text(cycleManager.currentPhase.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(cycleManager.currentPhase.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                }

                Spacer()
            }

            if let dayOfCycle = cycleManager.currentDayOfCycle {
                HStack {
                    Text("Döngünün \(dayOfCycle). günü")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    Text("\(cycleManager.calculatedAverageCycleLength) günlük döngü")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: phaseGradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: phaseGradientColors.first?.opacity(0.3) ?? .clear, radius: 10, x: 0, y: 5)
    }

    private var phaseGradientColors: [Color] {
        switch cycleManager.currentPhase {
        case .menstruation: return [Color.red, Color.pink]
        case .follicular: return [Color.green, Color.mint]
        case .ovulation: return [Color.blue, Color.cyan]
        case .luteal: return [Color.orange, Color.yellow]
        }
    }

    // MARK: - Döngü Günü Göstergesi
    private func cycleDayIndicator(day: Int) -> some View {
        let total = cycleManager.calculatedAverageCycleLength
        let progress = min(Double(day) / Double(total), 1.0)

        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: phaseGradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: progress)

                VStack(spacing: 2) {
                    Text("\(day)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("/ \(total) gün")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 130, height: 130)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Bilgi Kartı
    private func infoCard(title: String, value: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Spacer()
            }

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Tahminler
    private var predictionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tahminler")
                .font(.headline)
                .padding(.horizontal, 4)

            VStack(spacing: 10) {
                if let endDate = cycleManager.estimatedEndDate {
                    predictionRow(
                        icon: "drop.fill",
                        color: .red,
                        title: "Tahmini Regl Bitişi",
                        date: cycleManager.formatDate(endDate)
                    )
                }

                if let nextPeriod = cycleManager.nextPeriodDate {
                    predictionRow(
                        icon: "calendar",
                        color: .pink,
                        title: "Sonraki Regl Tahmini",
                        date: cycleManager.formatDate(nextPeriod)
                    )
                }

                if let ovulation = cycleManager.nextOvulationDate {
                    predictionRow(
                        icon: "sparkles",
                        color: .blue,
                        title: "Yumurtlama Tahmini",
                        date: cycleManager.formatDate(ovulation)
                    )
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }

    private func predictionRow(icon: String, color: Color, title: String, date: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(date)
                    .font(.body)
                    .fontWeight(.medium)
            }

            Spacer()
        }
    }

    // MARK: - Verimli Pencere
    private func fertileWindowCard(start: Date, end: Date) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                Text("Verimli Pencere")
                    .font(.headline)
            }

            Text("\(cycleManager.formatDate(start)) - \(cycleManager.formatDate(end))")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.pink.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.pink.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    DashboardView()
        .environmentObject(CycleManager())
}
