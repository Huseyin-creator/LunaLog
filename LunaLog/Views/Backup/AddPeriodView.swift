import SwiftUI

struct AddPeriodView: View {
    @EnvironmentObject var cycleManager: CycleManager
    @Environment(\.dismiss) var dismiss

    @State private var startDate = Date()
    @State private var hasEndDate = false
    @State private var endDate = Date()
    @State private var notes = ""
    @State private var selectedSymptoms: Set<Symptom> = []

    var body: some View {
        NavigationView {
            Form {
                // Tarih Bölümü
                Section(header: Label("Tarihler", systemImage: "calendar")) {
                    DatePicker("Başlangıç Tarihi",
                               selection: $startDate,
                               in: ...Date(),
                               displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "tr_TR"))

                    Toggle("Bitiş Tarihi Ekle", isOn: $hasEndDate)

                    if hasEndDate {
                        DatePicker("Bitiş Tarihi",
                                   selection: $endDate,
                                   in: startDate...Date(),
                                   displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "tr_TR"))
                    }
                }

                // Belirtiler
                Section(header: Label("Belirtiler", systemImage: "heart.text.square")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(Symptom.allCases) { symptom in
                            SymptomChip(
                                symptom: symptom,
                                isSelected: selectedSymptoms.contains(symptom)
                            ) {
                                if selectedSymptoms.contains(symptom) {
                                    selectedSymptoms.remove(symptom)
                                } else {
                                    selectedSymptoms.insert(symptom)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Notlar
                Section(header: Label("Notlar", systemImage: "note.text")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Yeni Regl Kaydı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveRecord()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                }
            }
        }
    }

    private func saveRecord() {
        cycleManager.addPeriod(
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            notes: notes,
            symptoms: Array(selectedSymptoms)
        )
        dismiss()
    }
}

// MARK: - Belirti Chip'i
struct SymptomChip: View {
    let symptom: Symptom
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(symptom.emoji)
                    .font(.caption)
                Text(symptom.rawValue)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.pink.opacity(0.2) : Color(.systemGray6))
            .foregroundColor(isSelected ? .pink : .primary)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Regl Düzenleme View
struct EditPeriodView: View {
    @EnvironmentObject var cycleManager: CycleManager
    @Environment(\.dismiss) var dismiss

    let period: PeriodRecord

    @State private var startDate: Date
    @State private var hasEndDate: Bool
    @State private var endDate: Date
    @State private var notes: String
    @State private var selectedSymptoms: Set<Symptom>

    init(period: PeriodRecord) {
        self.period = period
        _startDate = State(initialValue: period.startDate)
        _hasEndDate = State(initialValue: period.endDate != nil)
        _endDate = State(initialValue: period.endDate ?? Date())
        _notes = State(initialValue: period.notes)
        _selectedSymptoms = State(initialValue: Set(period.symptoms))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Label("Tarihler", systemImage: "calendar")) {
                    DatePicker("Başlangıç Tarihi",
                               selection: $startDate,
                               in: ...Date(),
                               displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "tr_TR"))

                    Toggle("Bitiş Tarihi", isOn: $hasEndDate)

                    if hasEndDate {
                        DatePicker("Bitiş Tarihi",
                                   selection: $endDate,
                                   in: startDate...Date(),
                                   displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "tr_TR"))
                    }
                }

                Section(header: Label("Belirtiler", systemImage: "heart.text.square")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(Symptom.allCases) { symptom in
                            SymptomChip(
                                symptom: symptom,
                                isSelected: selectedSymptoms.contains(symptom)
                            ) {
                                if selectedSymptoms.contains(symptom) {
                                    selectedSymptoms.remove(symptom)
                                } else {
                                    selectedSymptoms.insert(symptom)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Label("Notlar", systemImage: "note.text")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Kaydı Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Güncelle") {
                        var updated = period
                        updated.startDate = startDate
                        updated.endDate = hasEndDate ? endDate : nil
                        updated.notes = notes
                        updated.symptoms = Array(selectedSymptoms)
                        cycleManager.updatePeriod(updated)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                }
            }
        }
    }
}

// MARK: - Regl Bitti View
struct EndPeriodView: View {
    @EnvironmentObject var cycleManager: CycleManager
    @Environment(\.dismiss) var dismiss

    @State private var endDate = Date()

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                Text("Regl Ne Zaman Bitti?")
                    .font(.title2)
                    .fontWeight(.bold)

                if let last = cycleManager.lastPeriod {
                    Text("Başlangıç: \(cycleManager.formatDate(last.startDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                DatePicker(
                    "Bitiş Tarihi",
                    selection: $endDate,
                    in: (cycleManager.lastPeriod?.startDate ?? Date())...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "tr_TR"))
                .tint(.pink)

                Button(action: save) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Kaydet")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(14)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Regl Bitişi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { dismiss() }
                }
            }
        }
    }

    private func save() {
        guard var last = cycleManager.lastPeriod else { return }
        last.endDate = endDate
        cycleManager.updatePeriod(last)
        dismiss()
    }
}

#Preview("Yeni Kayıt") {
    AddPeriodView()
        .environmentObject(CycleManager())
}

#Preview("Düzenle") {
    EditPeriodView(period: PeriodRecord(startDate: Date(), endDate: nil))
        .environmentObject(CycleManager())
}

#Preview("Regl Bitti") {
    EndPeriodView()
        .environmentObject(CycleManager())
}
