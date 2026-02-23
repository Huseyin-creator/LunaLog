import SwiftUI

struct JournalView: View {
    @EnvironmentObject var cycleManager: CycleManager
    @State private var showAddEntry = false
    @State private var detailEntry: JournalEntry?
    @State private var editingEntry: JournalEntry?
    @State private var showDeleteAlert = false
    @State private var entryToDelete: JournalEntry?

    var body: some View {
        NavigationView {
            Group {
                if cycleManager.journalEntries.isEmpty {
                    emptyState
                } else {
                    journalList
                }
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle(S.journalTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddEntry = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(cycleManager.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showAddEntry) {
                AddJournalEntryView()
                    .environmentObject(cycleManager)
            }
            .sheet(item: $detailEntry) { entry in
                JournalDetailSheet(entry: entry, onEdit: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        editingEntry = entry
                    }
                })
                    .environmentObject(cycleManager)
            }
            .sheet(item: $editingEntry) { entry in
                EditJournalEntryView(entry: entry)
                    .environmentObject(cycleManager)
            }
            .alert(S.deleteEntry, isPresented: $showDeleteAlert) {
                Button(S.cancel, role: .cancel) {}
                Button(S.delete, role: .destructive) {
                    if let entry = entryToDelete {
                        withAnimation {
                            cycleManager.deleteJournalEntry(entry)
                        }
                    }
                }
            } message: {
                Text(S.deleteJournalConfirm)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [cycleManager.accentGradient[0].opacity(0.12), cycleManager.accentGradient[1].opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 130, height: 130)

                Image(systemName: "book.closed.fill")
                    .font(.system(size: 52))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(colors: cycleManager.accentGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }

            VStack(spacing: 10) {
                Text(S.journalEmpty)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(S.journalEmptyDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: { showAddEntry = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text(S.addFirstEntry)
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 36)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(LinearGradient(colors: cycleManager.accentGradient, startPoint: .leading, endPoint: .trailing))
                )
                .shadow(color: cycleManager.accentColor.opacity(0.3), radius: 12, x: 0, y: 6)
            }

            Spacer()
        }
        .padding()
    }

    private var journalList: some View {
        List {
            ForEach(cycleManager.journalEntries) { entry in
                Button {
                    detailEntry = entry
                } label: {
                    journalCard(entry)
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            entryToDelete = entry
                            showDeleteAlert = true
                        } label: {
                            Label(S.delete, systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            editingEntry = entry
                        } label: {
                            Label(S.edit, systemImage: "pencil")
                        }
                        .tint(cycleManager.accentColor)
                    }
                    .listRowInsets(EdgeInsets(top: 7, leading: 20, bottom: 7, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
    }

    private func journalCard(_ entry: JournalEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(entry.mood.emoji)
                    .font(.system(size: 36))

                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.mood.displayName)
                        .font(.headline)
                    Text(cycleManager.formatDate(entry.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let phase = cycleManager.phaseForDate(entry.date) {
                    Text(phase.emoji)
                        .font(.title3)
                        .padding(6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }

            if !entry.note.isEmpty {
                Text(entry.note)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 2)
            }

            if !entry.symptoms.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(entry.symptoms) { symptom in
                            HStack(spacing: 3) {
                                Text(symptom.emoji)
                                Text(symptom.displayName)
                            }
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
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(18)
    }
}

// MARK: - Günlük Detay Pop-up
struct JournalDetailSheet: View {
    @EnvironmentObject var cycleManager: CycleManager
    @Environment(\.dismiss) var dismiss
    let entry: JournalEntry
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack(spacing: 16) {
                        Text(entry.mood.emoji)
                            .font(.system(size: 52))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.mood.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(cycleManager.formatDate(entry.date))
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if let phase = cycleManager.phaseForDate(entry.date) {
                                HStack(spacing: 4) {
                                    Text(phase.emoji)
                                    Text(phase.displayName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(18)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(18)

                    // Note
                    if !entry.note.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(cycleManager.accentColor)
                                Text(S.note)
                                    .font(.headline)
                            }

                            Text(entry.note)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(18)
                    }

                    // Symptoms
                    if !entry.symptoms.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "heart.text.square")
                                    .foregroundColor(cycleManager.accentColor)
                                Text(S.symptoms)
                                    .font(.headline)
                            }

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(entry.symptoms) { symptom in
                                    HStack(spacing: 6) {
                                        Text(symptom.emoji)
                                        Text(symptom.displayName)
                                            .font(.subheadline)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(cycleManager.accentColor.opacity(0.08))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(18)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(18)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle(S.journalDetail)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let onEdit = onEdit {
                        Button {
                            dismiss()
                            onEdit()
                        } label: {
                            Label(S.edit, systemImage: "pencil")
                        }
                        .foregroundColor(cycleManager.accentColor)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(S.close) { dismiss() }
                        .foregroundColor(cycleManager.accentColor)
                }
            }
        }
        .presentationDetents([.medium, .large])
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
            ScrollView {
                journalForm
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle(S.addJournal)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(S.giveUp) { dismiss() }
                        .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(S.save) {
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
                    .foregroundColor(cycleManager.accentColor)
                }
            }
        }
    }

    private var journalForm: some View {
        VStack(spacing: 24) {
            moodSection
            noteSection
            symptomsSection
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(S.howDoYouFeel)
                .font(.headline)
                .padding(.horizontal, 4)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    VStack(spacing: 6) {
                        Text(mood.emoji)
                            .font(.system(size: 32))
                        Text(mood.displayName)
                            .font(.caption2)
                            .foregroundColor(selectedMood == mood ? cycleManager.accentColor : .secondary)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(selectedMood == mood ? cycleManager.accentColor.opacity(0.12) : Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(selectedMood == mood ? cycleManager.accentColor : Color.clear, lineWidth: 2)
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedMood = mood
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(18)
    }

    private var symptomsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(S.symptoms)
                .font(.headline)
                .padding(.horizontal, 4)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(Symptom.allCases) { symptom in
                    HStack(spacing: 5) {
                        Text(symptom.emoji)
                        Text(symptom.displayName)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        selectedSymptoms.contains(symptom)
                            ? cycleManager.accentColor.opacity(0.12)
                            : Color(.systemGray6)
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedSymptoms.contains(symptom) ? cycleManager.accentColor : Color.clear, lineWidth: 1.5)
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if selectedSymptoms.contains(symptom) {
                                selectedSymptoms.remove(symptom)
                            } else {
                                selectedSymptoms.insert(symptom)
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(18)
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(S.note)
                .font(.headline)
                .padding(.horizontal, 4)

            TextEditor(text: $note)
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(14)
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(18)
    }
}

// MARK: - Günlük Kaydı Düzenleme
struct EditJournalEntryView: View {
    @EnvironmentObject var cycleManager: CycleManager
    @Environment(\.dismiss) var dismiss

    let entry: JournalEntry

    @State private var selectedMood: Mood
    @State private var note: String
    @State private var selectedSymptoms: Set<Symptom>

    init(entry: JournalEntry) {
        self.entry = entry
        _selectedMood = State(initialValue: entry.mood)
        _note = State(initialValue: entry.note)
        _selectedSymptoms = State(initialValue: Set(entry.symptoms))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    moodSection
                    noteSection
                    symptomsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle(S.editJournal)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(S.giveUp) { dismiss() }
                        .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(S.save) {
                        var updated = entry
                        updated.mood = selectedMood
                        updated.note = note
                        updated.symptoms = Array(selectedSymptoms)
                        cycleManager.updateJournalEntry(updated)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(cycleManager.accentColor)
                }
            }
        }
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(S.howDoYouFeel)
                .font(.headline)
                .padding(.horizontal, 4)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    VStack(spacing: 6) {
                        Text(mood.emoji)
                            .font(.system(size: 32))
                        Text(mood.displayName)
                            .font(.caption2)
                            .foregroundColor(selectedMood == mood ? cycleManager.accentColor : .secondary)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(selectedMood == mood ? cycleManager.accentColor.opacity(0.12) : Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(selectedMood == mood ? cycleManager.accentColor : Color.clear, lineWidth: 2)
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedMood = mood
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(18)
    }

    private var symptomsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(S.symptoms)
                .font(.headline)
                .padding(.horizontal, 4)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(Symptom.allCases) { symptom in
                    HStack(spacing: 5) {
                        Text(symptom.emoji)
                        Text(symptom.displayName)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        selectedSymptoms.contains(symptom)
                            ? cycleManager.accentColor.opacity(0.12)
                            : Color(.systemGray6)
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedSymptoms.contains(symptom) ? cycleManager.accentColor : Color.clear, lineWidth: 1.5)
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if selectedSymptoms.contains(symptom) {
                                selectedSymptoms.remove(symptom)
                            } else {
                                selectedSymptoms.insert(symptom)
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(18)
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(S.note)
                .font(.headline)
                .padding(.horizontal, 4)

            TextEditor(text: $note)
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(14)
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(18)
    }
}

// MARK: - JournalEntry mutability fix
extension JournalEntry {
    var mutableCopy: JournalEntry {
        JournalEntry(id: id, date: date, mood: mood, note: note, symptoms: symptoms)
    }
}

#Preview {
    JournalView()
        .environmentObject(CycleManager())
}
