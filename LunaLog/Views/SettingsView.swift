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
                    settingsSection(title: "Bildirimler", icon: "bell.fill", iconColor: .red) {
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
                                Text("Bildirimler")
                                    .font(.body)
                            }
                            .tint(cycleManager.accentColor)

                            if cycleManager.settings.reminderEnabled {
                                Divider()

                                HStack {
                                    Text("Kaç gün önceden haber ver")
                                        .font(.subheadline)
                                    Spacer()
                                    Stepper("\(cycleManager.settings.reminderDaysBefore) gün",
                                            value: $cycleManager.settings.reminderDaysBefore,
                                            in: 1...7)
                                        .onChange(of: cycleManager.settings.reminderDaysBefore) { _ in
                                            cycleManager.saveSettings()
                                        }
                                }

                                VStack(alignment: .leading, spacing: 6) {
                                    Label("Alacağın bildirimler:", systemImage: "info.circle")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Group {
                                        Text("  Regl \(cycleManager.settings.reminderDaysBefore) gün sonra başlayacak")
                                        Text("  Tahmini regl başlangıç günü")
                                        Text("  Tahmini regl bitiş günü")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    // Chatbot API
                    settingsSection(title: "Chatbot (Gemini AI)", icon: "sparkles", iconColor: .blue) {
                        VStack(spacing: 12) {
                            SecureField("Gemini API Anahtarı", text: Binding(
                                get: { cycleManager.settings.geminiApiKey },
                                set: { newValue in
                                    cycleManager.settings.geminiApiKey = newValue
                                    cycleManager.saveAppearanceSettings()
                                }
                            ))
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                            if cycleManager.settings.geminiApiKey.isEmpty {
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.orange)
                                    Text("aistudio.google.com adresinden ücretsiz API anahtarı alabilirsin")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("API anahtarı ayarlandı")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    // Döngü Ayarları
                    settingsSection(title: "Döngü Ayarları", icon: "gear", iconColor: .gray) {
                        VStack(spacing: 14) {
                            HStack {
                                Text("Varsayılan Döngü Süresi")
                                    .font(.subheadline)
                                Spacer()
                                Stepper("\(cycleManager.settings.averageCycleLength) gün",
                                        value: $cycleManager.settings.averageCycleLength,
                                        in: 20...45)
                                    .onChange(of: cycleManager.settings.averageCycleLength) { _ in
                                        cycleManager.saveSettings()
                                    }
                            }

                            Divider()

                            HStack {
                                Text("Varsayılan Regl Süresi")
                                    .font(.subheadline)
                                Spacer()
                                Stepper("\(cycleManager.settings.averagePeriodLength) gün",
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
                        settingsSection(title: "Hesaplanan Değerler", icon: "function", iconColor: .teal) {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Ortalama Döngü")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(cycleManager.calculatedAverageCycleLength) gün")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(cycleManager.accentColor)
                                }

                                Divider()

                                HStack {
                                    Text("Ortalama Regl Süresi")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(cycleManager.calculatedAveragePeriodLength) gün")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(cycleManager.accentColor)
                                }
                            }
                        }
                    }

                    // Döngü Fazları Bilgisi
                    settingsSection(title: "Döngü Fazları", icon: "info.circle", iconColor: .indigo) {
                        VStack(spacing: 14) {
                            ForEach(CyclePhase.allCases, id: \.self) { phase in
                                Button {
                                    selectedPhase = phase
                                } label: {
                                    HStack(spacing: 14) {
                                        Text(phase.emoji)
                                            .font(.title2)

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(phase.rawValue)
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
                    settingsSection(title: "Veri Yönetimi", icon: "externaldrive", iconColor: .orange) {
                        VStack(spacing: 14) {
                            HStack {
                                Text("Kayıtlı Döngü")
                                    .font(.subheadline)
                                Spacer()
                                Text("\(cycleManager.periods.count) kayıt")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Divider()

                            Button(role: .destructive) {
                                showResetAlert = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Tüm Verileri Sil")
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

                    // Uygulama Bilgisi
                    settingsSection(title: "Uygulama", icon: "app", iconColor: cycleManager.accentColor) {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Sürüm")
                                    .font(.subheadline)
                                Spacer()
                                Text("1.0.0")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Divider()

                            HStack {
                                Text("Geliştirici")
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
            .navigationTitle("Ayarlar")
            .alert("Bildirim İzni Gerekli", isPresented: $notificationDenied) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text("Bildirim göndermek için izin gerekli. Ayarlar > LunaLog > Bildirimler kısmından izin verebilirsin.")
            }
            .sheet(item: $selectedPhase) { phase in
                PhaseDetailSheet(phase: phase)
                    .environmentObject(cycleManager)
            }
            .alert("Tüm Verileri Sil", isPresented: $showResetAlert) {
                Button("İptal", role: .cancel) {}
                Button("Sil", role: .destructive) {
                    cycleManager.periods.removeAll()
                    StorageService.shared.savePeriods([])
                    cycleManager.settings = .default
                    cycleManager.saveSettings()
                }
            } message: {
                Text("Tüm regl kayıtlarınız ve ayarlarınız silinecek. Bu işlem geri alınamaz.")
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

                        Text(phase.rawValue)
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
                    Button("Kapat") { dismiss() }
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
