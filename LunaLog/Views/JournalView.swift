import SwiftUI

struct JournalView: View {
    @EnvironmentObject var cycleManager: CycleManager
    @State private var showAddEntry = false

    var body: some View {
        NavigationView {
            Group {
                if cycleManager.journalEntries.isEmpty {
                    emptyState
                } else {
                    journalList
                }
            }
            .navigationTitle("Günlük")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddEntry = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.pink)
                    }
                }
            }
            .sheet(isPresented: $showAddEntry) {
                AddJournalEntryView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "book.closed")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            Text("Günlüğün Boş")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Her gün ruh halini ve notlarını\nkaydetmeye başla")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: { showAddEntry = true }) {
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

    private var journalList: some View {
        List {
            ForEach(cycleManager.journalEntries) { entry in
                journalRow(entry)
            }
            .onDelete(perform: deleteEntry)
        }
        .listStyle(.plain)
    }

    private func journalRow(_ entry: JournalEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.mood.emoji)
                    .font(.title)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.mood.rawValue)
                        .font(.headline)
                    Text(cycleManager.formatDate(entry.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let phase = cycleManager.phaseForDate(entry.date) {
                    Text(phase.emoji)
                        .font(.title3)
                }
            }

            if !entry.note.isEmpty {
                Text(entry.note)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }

            if !entry.symptoms.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(entry.symptoms) { symptom in
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
        .padding(.vertical, 4)
    }

    private func deleteEntry(at offsets: IndexSet) {
        for index in offsets {
            cycleManager.deleteJournalEntry(cycleManager.journalEntries[index])
        }
    }
}

// MARK: - Yeni Günlük Kaydı Ekleme
struct AddJournalEntryView: View {
    @EnvironmentObject var cycleManager: CycleManager
    @Environment(\.dismiss) var dismiss

    @State private var selectedMood: Mood = .neutral
    @State private var note = ""
    @State private var selectedSymptoms: Set<Symptom> = []

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nasıl Hissediyorsun?")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            VStack(spacing: 4) {
                                Text(mood.emoji)
                                    .font(.system(size: 32))
                                Text(mood.rawValue)
                                    .font(.caption2)
                                    .foregroundColor(selectedMood == mood ? .pink : .secondary)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedMood == mood ? Color.pink.opacity(0.15) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedMood == mood ? Color.pink : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                selectedMood = mood
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Belirtiler")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(Symptom.allCases) { symptom in
                            HStack {
                                Text(symptom.emoji)
                                Text(symptom.rawValue)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                selectedSymptoms.contains(symptom)
                                    ? Color.pink.opacity(0.15)
                                    : Color(.systemGray6)
                            )
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedSymptoms.contains(symptom) ? Color.pink : Color.clear, lineWidth: 1.5)
                            )
                            .onTapGesture {
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

                Section(header: Text("Not")) {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Günlük Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let entry = JournalEntry(
                            date: Date(),
                            mood: selectedMood,
                            note: note,
                            symptoms: Array(selectedSymptoms)
                        )
                        cycleManager.addJournalEntry(entry)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                }
            }
        }
    }
}

#Preview {
    JournalView()
        .environmentObject(CycleManager())
}
