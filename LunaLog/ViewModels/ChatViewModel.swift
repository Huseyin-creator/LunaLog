import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isReady = false

    private let dataService = DataService.shared

    func loadMessages() {
        guard !isReady else { return }
        let loaded = dataService.loadChatMessagesLocal()
        if loaded.isEmpty {
            let welcome = ChatMessage(
                content: S.chatWelcome,
                isUser: false
            )
            messages = [welcome]
            dataService.saveChatMessages(messages)
        } else {
            messages = loaded
        }
        isReady = true
    }

    func syncFromCloud() {
        Task { @MainActor in
            let cloudMessages = await dataService.loadChatMessages()
            if !cloudMessages.isEmpty {
                self.messages = cloudMessages
            }
        }
    }

    func sendMessage(_ text: String, cycleManager: CycleManager) {
        let userMessage = ChatMessage(content: text, isUser: true)
        messages.append(userMessage)
        dataService.saveChatMessages(messages)
        isLoading = true
        errorMessage = nil

        let context = buildCycleContext(cycleManager)

        GeminiService.shared.sendMessage(
            userMessage: text,
            cycleContext: context,
            apiKey: cycleManager.settings.geminiApiKey
        ) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let reply):
                let botMessage = ChatMessage(content: reply, isUser: false)
                self.messages.append(botMessage)
                self.dataService.saveChatMessages(self.messages)

            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func clearChat() {
        messages.removeAll()
        let welcome = ChatMessage(
            content: S.chatWelcome,
            isUser: false
        )
        messages.append(welcome)
        dataService.saveChatMessages(messages)
    }

    private func buildCycleContext(_ cm: CycleManager) -> String {
        var context = ""

        context += S.contextCurrentPhase(cm.currentPhase.displayName) + "\n"
        context += S.contextAvgCycle(cm.calculatedAverageCycleLength) + "\n"
        context += S.contextAvgPeriod(cm.calculatedAveragePeriodLength) + "\n"

        if let day = cm.currentDayOfCycle {
            context += S.contextCycleDay(day) + "\n"
        }

        if let days = cm.daysUntilNextPeriod {
            context += S.contextDaysUntil(days) + "\n"
        }

        if let last = cm.lastPeriod {
            context += S.contextLastStart(cm.formatDate(last.startDate)) + "\n"
            if let end = last.endDate {
                context += S.contextLastEnd(cm.formatDate(end)) + "\n"
            }
            if !last.symptoms.isEmpty {
                context += S.contextSymptoms(last.symptoms.map { $0.displayName }.joined(separator: ", ")) + "\n"
            }
        }

        if let nextPeriod = cm.nextPeriodDate {
            context += S.contextNextPeriod(cm.formatDate(nextPeriod)) + "\n"
        }

        if let ovulation = cm.nextOvulationDate {
            context += S.contextOvulation(cm.formatDate(ovulation)) + "\n"
        }

        let recentJournals = cm.journalEntries.prefix(3)
        if !recentJournals.isEmpty {
            context += "\n" + S.contextRecentJournals + "\n"
            for entry in recentJournals {
                context += S.contextJournalEntry(cm.formatDate(entry.date), entry.mood.displayName)
                if !entry.note.isEmpty {
                    context += S.contextJournalNote(entry.note)
                }
                context += "\n"
            }
        }

        return context
    }
}
