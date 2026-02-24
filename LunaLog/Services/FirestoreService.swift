import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    private init() {}

    // MARK: - References
    private func userDoc(_ userId: String) -> DocumentReference {
        db.collection("users").document(userId)
    }

    private func periodsCollection(_ userId: String) -> CollectionReference {
        userDoc(userId).collection("periods")
    }

    private func journalCollection(_ userId: String) -> CollectionReference {
        userDoc(userId).collection("journal")
    }

    private func chatCollection(_ userId: String) -> CollectionReference {
        userDoc(userId).collection("chat")
    }

    // MARK: - Periods
    func savePeriod(_ period: PeriodRecord, userId: String) async throws {
        try periodsCollection(userId)
            .document(period.id.uuidString)
            .setData(from: period, merge: true)
    }

    func saveAllPeriods(_ periods: [PeriodRecord], userId: String) async throws {
        let batch = db.batch()
        for period in periods {
            let ref = periodsCollection(userId).document(period.id.uuidString)
            try batch.setData(from: period, forDocument: ref, merge: true)
        }
        try await batch.commit()
    }

    func loadPeriods(userId: String) async throws -> [PeriodRecord] {
        let snapshot = try await periodsCollection(userId).getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: PeriodRecord.self)
        }.sorted { $0.startDate > $1.startDate }
    }

    func deletePeriod(_ periodId: UUID, userId: String) async throws {
        try await periodsCollection(userId).document(periodId.uuidString).delete()
    }

    func deleteAllPeriods(userId: String) async throws {
        let snapshot = try await periodsCollection(userId).getDocuments()
        let batch = db.batch()
        for doc in snapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        try await batch.commit()
    }

    // MARK: - Journal
    func saveJournalEntry(_ entry: JournalEntry, userId: String) async throws {
        try journalCollection(userId)
            .document(entry.id.uuidString)
            .setData(from: entry, merge: true)
    }

    func saveAllJournalEntries(_ entries: [JournalEntry], userId: String) async throws {
        let batch = db.batch()
        for entry in entries {
            let ref = journalCollection(userId).document(entry.id.uuidString)
            try batch.setData(from: entry, forDocument: ref, merge: true)
        }
        try await batch.commit()
    }

    func loadJournalEntries(userId: String) async throws -> [JournalEntry] {
        let snapshot = try await journalCollection(userId).getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: JournalEntry.self)
        }.sorted { $0.date > $1.date }
    }

    func deleteJournalEntry(_ entryId: UUID, userId: String) async throws {
        try await journalCollection(userId).document(entryId.uuidString).delete()
    }

    func deleteAllJournalEntries(userId: String) async throws {
        let snapshot = try await journalCollection(userId).getDocuments()
        let batch = db.batch()
        for doc in snapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        try await batch.commit()
    }

    // MARK: - Chat
    func saveChatMessage(_ message: ChatMessage, userId: String) async throws {
        try chatCollection(userId)
            .document(message.id.uuidString)
            .setData(from: message, merge: true)
    }

    func saveAllChatMessages(_ messages: [ChatMessage], userId: String) async throws {
        let batch = db.batch()
        for message in messages {
            let ref = chatCollection(userId).document(message.id.uuidString)
            try batch.setData(from: message, forDocument: ref, merge: true)
        }
        try await batch.commit()
    }

    func loadChatMessages(userId: String) async throws -> [ChatMessage] {
        let snapshot = try await chatCollection(userId).getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: ChatMessage.self)
        }.sorted { $0.date < $1.date }
    }

    func deleteAllChat(userId: String) async throws {
        let snapshot = try await chatCollection(userId).getDocuments()
        let batch = db.batch()
        for doc in snapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        try await batch.commit()
    }

    // MARK: - Settings
    func saveSettings(_ settings: UserSettings, userId: String) async throws {
        try userDoc(userId).setData(from: settings, merge: true)
    }

    func loadSettings(userId: String) async throws -> UserSettings? {
        let doc = try await userDoc(userId).getDocument()
        guard doc.exists else { return nil }
        return try doc.data(as: UserSettings.self)
    }
}
