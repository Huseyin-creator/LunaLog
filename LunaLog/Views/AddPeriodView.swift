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
                Section(header: Label(S.dates, systemImage: "calendar")) {
                    DatePicker(S.startDate,
                               selection: $startDate,
                               in: ...Date(),
                               displayedComponents: .date)
                        .environment(\.locale, S.locale)

                    Toggle(S.addEndDate, isOn: $hasEndDate)

                    if hasEndDate {
                        DatePicker(S.endDate,
                                   selection: $endDate,
                                   in: startDate...Date(),
                                   displayedComponents: .date)
                            .environment(\.locale, S.locale)
                    }
                }

                // Belirtiler
                Section(header: Label(S.symptoms, systemImage: "heart.text.square")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(Symptom.allCases) { symptom in
                            SymptomChip(
                                symptom: symptom,
                                isSelected: selectedSymptoms.contains(symptom),
                                accentColor: cycleManager.accentColor
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
                Section(header: Label(S.notes, systemImage: "note.text")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(S.newPeriodRecord)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(S.cancel) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(S.save) {
                        saveRecord()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(cycleManager.accentColor)
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
    var accentColor: Color = .pink
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(symptom.emoji)
                    .font(.caption)
                Text(symptom.displayName)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isSelected ? accentColor.opacity(0.2) : Color(.systemGray6))
            .foregroundColor(isSelected ? accentColor : .primary)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? accentColor : Color.clear, lineWidth: 1.5)
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
                Section(header: Label(S.dates, systemImage: "calendar")) {
                    DatePicker(S.startDate,
                               selection: $startDate,
                               in: ...Date(),
                               displayedComponents: .date)
                        .environment(\.locale, S.locale)

                    Toggle(S.endDate, isOn: $hasEndDate)

                    if hasEndDate {
                        DatePicker(S.endDate,
                                   selection: $endDate,
                                   in: startDate...Date(),
                                   displayedComponents: .date)
                            .environment(\.locale, S.locale)
                    }
                }

                Section(header: Label(S.symptoms, systemImage: "heart.text.square")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(Symptom.allCases) { symptom in
                            SymptomChip(
                                symptom: symptom,
                                isSelected: selectedSymptoms.contains(symptom),
                                accentColor: cycleManager.accentColor
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

                Section(header: Label(S.notes, systemImage: "note.text")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(S.editRecord)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(S.cancel) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(S.update) {
                        var updated = period
                        updated.startDate = startDate
                        updated.endDate = hasEndDate ? endDate : nil
                        updated.notes = notes
                        updated.symptoms = Array(selectedSymptoms)
                        cycleManager.updatePeriod(updated)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(cycleManager.accentColor)
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

                Text(S.whenDidPeriodEnd)
                    .font(.title2)
                    .fontWeight(.bold)

                if let last = cycleManager.lastPeriod {
                    Text(S.periodStart(cycleManager.formatDate(last.startDate)))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                DatePicker(
                    S.endDate,
                    selection: $endDate,
                    in: (cycleManager.lastPeriod?.startDate ?? Date())...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .environment(\.locale, S.locale)
                .tint(cycleManager.accentColor)

                Button(action: save) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(S.save)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: cycleManager.accentGradient, startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(14)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle(S.periodEndTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(S.cancel) { dismiss() }
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
