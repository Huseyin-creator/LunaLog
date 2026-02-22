import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var cycleManager: CycleManager
    @State private var showResetAlert = false
    @State private var notificationDenied = false

    var body: some View {
        NavigationView {
            Form {
                // Bildirim Ayarları
                Section(header: Label("Bildirimler", systemImage: "bell.fill")) {
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
                        HStack {
                            Image(systemName: "bell.badge")
                                .foregroundColor(.pink)
                            Text("Hatırlatıcılar")
                        }
                    }

                    if cycleManager.settings.reminderEnabled {
                        HStack {
                            Text("Kaç gün önceden haber ver")
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

                            Text("  Regl \(cycleManager.settings.reminderDaysBefore) gün sonra başlayacak")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("  Tahmini regl başlangıç günü")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("  Tahmini regl bitiş günü")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Görünüm Ayarları
                Section(header: Label("Görünüm", systemImage: "paintbrush.fill")) {
                    Picker(selection: Binding(
                        get: { cycleManager.settings.appearanceMode },
                        set: { newValue in
                            cycleManager.settings.appearanceMode = newValue
                            cycleManager.saveSettings()
                        }
                    )) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "moon.circle.fill")
                                .foregroundColor(.pink)
                            Text("Tema")
                        }
                    }
                }

                // Chatbot API Ayarları
                Section(header: Label("Chatbot (Gemini AI)", systemImage: "bubble.left.fill")) {
                    SecureField("Gemini API Anahtarı", text: Binding(
                        get: { cycleManager.settings.geminiApiKey },
                        set: { newValue in
                            cycleManager.settings.geminiApiKey = newValue
                            cycleManager.saveSettings()
                        }
                    ))

                    if cycleManager.settings.geminiApiKey.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.orange)
                            Text("aistudio.google.com adresinden ücretsiz API anahtarı alabilirsin")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("API anahtarı ayarlandı")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Döngü Ayarları
                Section(header: Label("Döngü Ayarları", systemImage: "gear")) {
                    HStack {
                        Text("Varsayılan Döngü Süresi")
                        Spacer()
                        Stepper("\(cycleManager.settings.averageCycleLength) gün",
                                value: $cycleManager.settings.averageCycleLength,
                                in: 20...45)
                            .onChange(of: cycleManager.settings.averageCycleLength) { _ in
                                cycleManager.saveSettings()
                            }
                    }

                    HStack {
                        Text("Varsayılan Regl Süresi")
                        Spacer()
                        Stepper("\(cycleManager.settings.averagePeriodLength) gün",
                                value: $cycleManager.settings.averagePeriodLength,
                                in: 2...10)
                            .onChange(of: cycleManager.settings.averagePeriodLength) { _ in
                                cycleManager.saveSettings()
                            }
                    }
                }

                // Hesaplanan Değerler
                if cycleManager.periods.count >= 2 {
                    Section(header: Label("Hesaplanan Değerler", systemImage: "function")) {
                        HStack {
                            Text("Ortalama Döngü (verilerden)")
                            Spacer()
                            Text("\(cycleManager.calculatedAverageCycleLength) gün")
                                .foregroundColor(.pink)
                                .fontWeight(.medium)
                        }

                        HStack {
                            Text("Ortalama Regl Süresi")
                            Spacer()
                            Text("\(cycleManager.calculatedAveragePeriodLength) gün")
                                .foregroundColor(.pink)
                                .fontWeight(.medium)
                        }
                    }
                }

                // Döngü Fazları Bilgisi
                Section(header: Label("Döngü Fazları Bilgisi", systemImage: "info.circle")) {
                    ForEach(CyclePhase.allCases, id: \.self) { phase in
                        HStack(spacing: 12) {
                            Text(phase.emoji)
                                .font(.title2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(phase.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(phase.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Döngü Hesaplama Bilgisi
                Section(header: Label("Nasıl Hesaplanır?", systemImage: "questionmark.circle")) {
                    VStack(alignment: .leading, spacing: 12) {
                        infoRow(
                            title: "Döngü Uzunluğu",
                            text: "Son regl başlangıcından bir sonraki regl başlangıcına kadar geçen gün sayısı."
                        )
                        infoRow(
                            title: "Yumurtlama",
                            text: "Bir sonraki tahmini regl tarihinden 14 gün önce hesaplanır."
                        )
                        infoRow(
                            title: "Verimli Pencere",
                            text: "Yumurtlamadan 5 gün önce başlar ve 1 gün sonra biter."
                        )
                        infoRow(
                            title: "Tahminler",
                            text: "Ne kadar çok kayıt girerseniz tahminler o kadar doğru olur."
                        )
                    }
                    .padding(.vertical, 4)
                }

                // Veri Yönetimi
                Section(header: Label("Veri Yönetimi", systemImage: "externaldrive")) {
                    HStack {
                        Text("Kayıtlı Döngü")
                        Spacer()
                        Text("\(cycleManager.periods.count) kayıt")
                            .foregroundColor(.secondary)
                    }

                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Tüm Verileri Sil")
                        }
                    }
                }

                // Uygulama Bilgisi
                Section(header: Label("Uygulama", systemImage: "app")) {
                    HStack {
                        Text("Sürüm")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Geliştirici")
                        Spacer()
                        Text("Huseyin")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Ayarlar")
            .alert("Bildirim İzni Gerekli", isPresented: $notificationDenied) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text("Bildirim göndermek için izin gerekli. Ayarlar > LunaLog > Bildirimler kısmından izin verebilirsin.")
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

    private func infoRow(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(CycleManager())
}
