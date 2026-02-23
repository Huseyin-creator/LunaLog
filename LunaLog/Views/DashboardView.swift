import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var cycleManager: CycleManager
    @State private var showAddPeriod = false
    @State private var showEndPeriodSheet = false
    @State private var animateRing = false

    var body: some View {
        NavigationView {
            Group {
                if cycleManager.periods.isEmpty {
                    emptyStateView
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            heroCard

                            if let last = cycleManager.lastPeriod, last.endDate == nil {
                                endPeriodBanner
                            }

                            statsGrid

                            if cycleManager.nextPeriodDate != nil || cycleManager.nextOvulationDate != nil {
                                predictionsCard
                            }

                            if let fertileStart = cycleManager.fertileWindowStart,
                               let fertileEnd = cycleManager.fertileWindowEnd {
                                fertileWindowCard(start: fertileStart, end: fertileEnd)
                            }

                            if let last = cycleManager.lastPeriod {
                                lastPeriodCard(last)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 30)
                    }
                }
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle("LunaLog")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddPeriod = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(cycleManager.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showAddPeriod) {
                AddPeriodView()
                    .environmentObject(cycleManager)
            }
            .sheet(isPresented: $showEndPeriodSheet) {
                EndPeriodView()
                    .environmentObject(cycleManager)
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            Spacer()

            // Büyük daire buton
            Button(action: { showAddPeriod = true }) {
                ZStack {
                    // Dış halka - transparan gradient
                    Circle()
                        .stroke(
                            LinearGradient(colors: [cycleManager.accentGradient[0].opacity(0.3), cycleManager.accentGradient[1].opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2
                        )
                        .frame(width: 220, height: 220)

                    // Ana daire - stroke'un hemen içine oturuyor
                    Circle()
                        .fill(
                            LinearGradient(colors: [cycleManager.accentGradient[0].opacity(0.12), cycleManager.accentGradient[1].opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 216, height: 216)

                    // İçerik
                    VStack(spacing: 12) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 44))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(
                                LinearGradient(colors: cycleManager.accentGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                            )

                        Text(S.addFirstRecord)
                            .font(.system(size: 16, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(cycleManager.accentColor)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(spacing: 10) {
                Text(S.emptyHello)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(S.emptyDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Hero Card (Phase + Ring)
    private var heroCard: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(cycleManager.currentPhase.emoji)
                        .font(.system(size: 36))

                    Text(cycleManager.currentPhase.displayName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(cycleManager.currentPhase.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }

                Spacer()

                if let dayOfCycle = cycleManager.currentDayOfCycle {
                    cycleRing(day: dayOfCycle)
                }
            }

            if cycleManager.currentPhase == .menstruation {
                HStack {
                    Image(systemName: "drop.fill")
                        .font(.caption)
                    Text(S.currentlyOnPeriod)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial.opacity(0.3))
                .cornerRadius(12)
            } else if let days = cycleManager.daysUntilNextPeriod {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.caption)
                    Text(S.daysUntilPeriod(days))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial.opacity(0.3))
                .cornerRadius(12)
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: phaseGradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: phaseGradientColors.first?.opacity(0.35) ?? .clear, radius: 16, x: 0, y: 8)
    }

    private func cycleRing(day: Int) -> some View {
        let total = cycleManager.calculatedAverageCycleLength
        let progress = min(Double(day) / Double(total), 1.0)

        return ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 8)

            Circle()
                .trim(from: 0, to: animateRing ? progress : 0)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 0) {
                Text("\(day)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("/ \(total)")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(width: 80, height: 80)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animateRing = true
            }
        }
    }

    private var phaseGradientColors: [Color] {
        switch cycleManager.currentPhase {
        case .menstruation: return [Color(red: 0.85, green: 0.2, blue: 0.3), Color(red: 0.95, green: 0.4, blue: 0.5)]
        case .follicular: return [Color(red: 0.2, green: 0.7, blue: 0.5), Color(red: 0.3, green: 0.85, blue: 0.65)]
        case .ovulation: return [Color(red: 0.3, green: 0.5, blue: 0.9), Color(red: 0.4, green: 0.7, blue: 0.95)]
        case .luteal: return [Color(red: 0.9, green: 0.55, blue: 0.2), Color(red: 0.95, green: 0.7, blue: 0.3)]
        }
    }

    // MARK: - End Period Banner
    private var endPeriodBanner: some View {
        Button(action: { showEndPeriodSheet = true }) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white)

                Text(S.periodEnded)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: cycleManager.accentGradient, startPoint: .leading, endPoint: .trailing))
            )
            .shadow(color: cycleManager.accentColor.opacity(0.25), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            statCard(
                icon: cycleManager.currentPhase == .menstruation ? "drop.fill" : "calendar.badge.clock",
                iconColor: cycleManager.currentPhase == .menstruation ? .red : cycleManager.accentColor,
                value: cycleManager.currentPhase == .menstruation
                    ? (cycleManager.currentDayOfCycle.map { "\($0)" } ?? "-")
                    : (cycleManager.daysUntilNextPeriod.map { "\($0)" } ?? "-"),
                label: cycleManager.currentPhase == .menstruation ? S.periodDay : S.daysLeft
            )

            statCard(
                icon: "arrow.triangle.2.circlepath",
                iconColor: .purple,
                value: "\(cycleManager.calculatedAverageCycleLength)",
                label: S.cycleLength
            )

            statCard(
                icon: "drop.fill",
                iconColor: .red,
                value: "\(cycleManager.calculatedAveragePeriodLength)",
                label: S.periodLength
            )

            statCard(
                icon: "list.clipboard",
                iconColor: .orange,
                value: "\(cycleManager.periods.count)",
                label: S.totalRecords
            )
        }
    }

    private func statCard(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .padding(10)
                .background(iconColor.opacity(0.12))
                .cornerRadius(12)

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Predictions Card
    private var predictionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.blue)
                Text(S.predictions)
                    .font(.headline)
                Spacer()
            }

            VStack(spacing: 12) {
                if let endDate = cycleManager.estimatedEndDate {
                    predictionRow(
                        icon: "drop.fill",
                        color: .red,
                        title: S.estimatedPeriodEnd,
                        date: cycleManager.formatDate(endDate)
                    )
                }

                if let nextPeriod = cycleManager.nextPeriodDate {
                    predictionRow(
                        icon: "calendar",
                        color: cycleManager.accentColor,
                        title: S.nextPeriod,
                        date: cycleManager.formatDate(nextPeriod)
                    )
                }

                if let ovulation = cycleManager.nextOvulationDate {
                    predictionRow(
                        icon: "sparkle",
                        color: .blue,
                        title: S.ovulation,
                        date: cycleManager.formatDate(ovulation)
                    )
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func predictionRow(icon: String, color: Color, title: String, date: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(date)
                    .font(.body)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }

    // MARK: - Fertile Window
    private func fertileWindowCard(start: Date, end: Date) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundColor(cycleManager.accentColor)
                .padding(10)
                .background(cycleManager.accentColor.opacity(0.12))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(S.fertileWindow)
                    .font(.headline)
                Text("\(cycleManager.formatDate(start)) - \(cycleManager.formatDate(end))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(colors: [cycleManager.accentGradient[0].opacity(0.4), cycleManager.accentGradient[1].opacity(0.2)], startPoint: .leading, endPoint: .trailing),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Last Period Card
    private func lastPeriodCard(_ period: PeriodRecord) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundColor(.red)
                Text(S.lastPeriod)
                    .font(.headline)
                Spacer()
            }

            VStack(spacing: 10) {
                infoRow(label: S.start, value: cycleManager.formatDate(period.startDate))

                if let endDate = period.endDate {
                    infoRow(label: S.end, value: cycleManager.formatDate(endDate))

                    if let duration = period.duration {
                        infoRow(label: S.duration, value: S.daysUnit(duration), valueColor: cycleManager.accentColor)
                    }
                } else if let estimatedEnd = cycleManager.estimatedEndDate {
                    infoRow(label: S.estimatedEnd, value: "~\(cycleManager.formatDate(estimatedEnd))", valueColor: .orange)
                }
            }

            if !period.symptoms.isEmpty {
                Divider()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(period.symptoms) { symptom in
                            Text("\(symptom.emoji) \(symptom.displayName)")
                                .font(.caption2)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(cycleManager.accentColor.opacity(0.08))
                                .cornerRadius(8)
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

    private func infoRow(label: String, value: String, valueColor: Color = .primary) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(CycleManager())
}
