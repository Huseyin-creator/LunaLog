import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var cycleManager: CycleManager
    @State private var showResetAlert = false
    @State private var notificationDenied = false
    @State private var selectedPhase: CyclePhase?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Bildirim Ayarları
                    settingsSection(title: S.notifications, icon: "bell.fill", iconColor: .red) {
                        VStack(spacing: 14) {
                            Toggle(isOn: Binding(
                                get: { cycleManager.settings.reminderEnabled },
                                set: { newValue in
                                    if newValue {
                                        cycleManager.enableNotifications { granted in
                                            if !granted {
                                                notificationDenied = true
                                            }
                                        }
                                    } else {
                                        cycleManager.disableNotifications()
                                    }
                                }
                            )) {
                                Text(S.notifications)
                                    .font(.body)
                            }
                            .tint(cycleManager.accentColor)

                            if cycleManager.settings.reminderEnabled {
                                Divider()

                                HStack {
                                    Text(S.remindDaysBefore(cycleManager.settings.reminderDaysBefore))
                                        .font(.subheadline)
                                    Spacer()
                                    Stepper(S.daysUnit(cycleManager.settings.reminderDaysBefore),
                                            value: $cycleManager.settings.reminderDaysBefore,
                                            in: 1...7)
                                        .onChange(of: cycleManager.settings.reminderDaysBefore) { _ in
                                            cycleManager.saveSettings()
                                        }
                                }

                                VStack(alignment: .leading, spacing: 6) {
                                    Label(S.notificationsYouWillGet, systemImage: "info.circle")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Group {
                                        Text(S.notifPeriodReminder(cycleManager.settings.reminderDaysBefore))
                                        Text(S.notifPeriodStart)
                                        Text(S.notifPeriodEnd)
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    // Döngü Ayarları
                    settingsSection(title: S.cycleSettings, icon: "gear", iconColor: .gray) {
                        VStack(spacing: 14) {
                            HStack {
                                Text(S.defaultCycleLength)
                                    .font(.subheadline)
                                Spacer()
                                Stepper(S.daysUnit(cycleManager.settings.averageCycleLength),
                                        value: $cycleManager.settings.averageCycleLength,
                                        in: 20...45)
                                    .onChange(of: cycleManager.settings.averageCycleLength) { _ in
                                        cycleManager.saveSettings()
                                    }
                            }

                            Divider()

                            HStack {
                                Text(S.defaultPeriodLength)
                                    .font(.subheadline)
                                Spacer()
                                Stepper(S.daysUnit(cycleManager.settings.averagePeriodLength),
                                        value: $cycleManager.settings.averagePeriodLength,
                                        in: 2...10)
                                    .onChange(of: cycleManager.settings.averagePeriodLength) { _ in
                                        cycleManager.saveSettings()
                                    }
                            }
                        }
                    }

                    // Hesaplanan Değerler
                    if cycleManager.periods.count >= 2 {
                        settingsSection(title: S.calculatedValues, icon: "function", iconColor: .teal) {
                            VStack(spacing: 12) {
                                HStack {
                                    Text(S.avgCycleFull)
                                        .font(.subheadline)
                                    Spacer()
                                    Text(S.daysUnit(cycleManager.calculatedAverageCycleLength))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(cycleManager.accentColor)
                                }

                                Divider()

                                HStack {
                                    Text(S.avgPeriodFull)
                                        .font(.subheadline)
                                    Spacer()
                                    Text(S.daysUnit(cycleManager.calculatedAveragePeriodLength))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(cycleManager.accentColor)
                                }
                            }
                        }
                    }

                    // Döngü Fazları Bilgisi
                    settingsSection(title: S.cyclePhases, icon: "info.circle", iconColor: .indigo) {
                        VStack(spacing: 14) {
                            ForEach(CyclePhase.allCases, id: \.self) { phase in
                                Button {
                                    selectedPhase = phase
                                } label: {
                                    HStack(spacing: 14) {
                                        Text(phase.emoji)
                                            .font(.title2)

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(phase.displayName)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                            Text(phase.description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .buttonStyle(.plain)

                                if phase != CyclePhase.allCases.last {
                                    Divider()
                                }
                            }
                        }
                    }

                    // Veri Yönetimi
                    settingsSection(title: S.dataManagement, icon: "externaldrive", iconColor: .orange) {
                        VStack(spacing: 14) {
                            HStack {
                                Text(S.savedCycles)
                                    .font(.subheadline)
                                Spacer()
                                Text(S.recordCount(cycleManager.periods.count))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Divider()

                            Button(role: .destructive) {
                                showResetAlert = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text(S.deleteAllData)
                                }
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.red.opacity(0.08))
                                .cornerRadius(10)
                            }
                        }
                    }

                    // Dil Seçimi
                    settingsSection(title: S.language, icon: "globe", iconColor: .blue) {
                        VStack(spacing: 14) {
                            ForEach(AppLanguage.allCases, id: \.self) { language in
                                Button {
                                    cycleManager.changeLanguage(language)
                                } label: {
                                    HStack {
                                        Text(language.displayName)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)

                                        Spacer()

                                        if cycleManager.settings.language == language {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(cycleManager.accentColor)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)

                                if language != AppLanguage.allCases.last {
                                    Divider()
                                }
                            }
                        }
                    }

                    // Uygulama Bilgisi
                    settingsSection(title: S.appSection, icon: "app", iconColor: cycleManager.accentColor) {
                        VStack(spacing: 12) {
                            HStack {
                                Text(S.version)
                                    .font(.subheadline)
                                Spacer()
                                Text("1.0.0")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Divider()

                            HStack {
                                Text(S.developer)
                                    .font(.subheadline)
                                Spacer()
                                Text("Huseyin")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle(S.settingsTitle)
            .alert(S.notifPermissionRequired, isPresented: $notificationDenied) {
                Button(S.ok, role: .cancel) {}
            } message: {
                Text(S.notifPermissionMessage)
            }
            .sheet(item: $selectedPhase) { phase in
                PhaseDetailSheet(phase: phase)
                    .environmentObject(cycleManager)
            }
            .alert(S.deleteAllTitle, isPresented: $showResetAlert) {
                Button(S.cancel, role: .cancel) {}
                Button(S.delete, role: .destructive) {
                    cycleManager.periods.removeAll()
                    StorageService.shared.savePeriods([])
                    cycleManager.settings = .default
                    cycleManager.saveSettings()
                }
            } message: {
                Text(S.deleteAllMessage)
            }
        }
    }

    // MARK: - Settings Section Builder
    private func settingsSection<Content: View>(
        title: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundColor(iconColor)
                    .frame(width: 22)
                Text(title)
                    .font(.headline)
            }

            content()
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Faz Detay Pop-up
struct PhaseDetailSheet: View {
    @EnvironmentObject var cycleManager: CycleManager
    @Environment(\.dismiss) var dismiss
    let phase: CyclePhase

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Emoji + Baslik
                    VStack(spacing: 12) {
                        Text(phase.emoji)
                            .font(.system(size: 60))

                        Text(phase.displayName)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(phase.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)

                    Divider()
                        .padding(.horizontal)

                    // Detayli Aciklama
                    Text(phase.detailedDescription)
                        .font(.body)
                        .lineSpacing(6)
                        .padding(.horizontal, 4)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(S.close) { dismiss() }
                        .foregroundColor(cycleManager.accentColor)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    SettingsView()
        .environmentObject(CycleManager())
}
