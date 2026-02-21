import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let storage = StorageService.shared

    init() {
        messages = storage.loadChatMessages()
        if messages.isEmpty {
            let welcome = ChatMessage(
                content: "Merhaba! Ben döngü asistanın. Regl döngün, belirtilerin veya kadın sağlığı hakkında sorularını yanıtlayabilirim. Nasıl yardımcı olabilirim?",
                isUser: false
            )
            messages.append(welcome)
            storage.saveChatMessages(messages)
        }
    }

    func sendMessage(_ text: String, cycleManager: CycleManager) {
        let userMessage = ChatMessage(content: text, isUser: true)
        messages.append(userMessage)
        storage.saveChatMessages(messages)
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
                self.storage.saveChatMessages(self.messages)

            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func clearChat() {
        messages.removeAll()
        let welcome = ChatMessage(
            content: "Merhaba! Ben döngü asistanın. Regl döngün, belirtilerin veya kadın sağlığı hakkında sorularını yanıtlayabilirim. Nasıl yardımcı olabilirim?",
            isUser: false
        )
        messages.append(welcome)
        storage.saveChatMessages(messages)
    }

    private func buildCycleContext(_ cm: CycleManager) -> String {
        var context = ""

        context += "Mevcut döngü fazı: \(cm.currentPhase.rawValue)\n"
        context += "Ortalama döngü süresi: \(cm.calculatedAverageCycleLength) gün\n"
        context += "Ortalama regl süresi: \(cm.calculatedAveragePeriodLength) gün\n"

        if let day = cm.currentDayOfCycle {
            context += "Döngünün \(day). günü\n"
        }

        if let days = cm.daysUntilNextPeriod {
            context += "Sonraki regle \(days) gün kaldı\n"
        }

        if let last = cm.lastPeriod {
            context += "Son regl başlangıcı: \(cm.formatDate(last.startDate))\n"
            if let end = last.endDate {
                context += "Son regl bitişi: \(cm.formatDate(end))\n"
            }
            if !last.symptoms.isEmpty {
                context += "Son belirtiler: \(last.symptoms.map { $0.rawValue }.joined(separator: ", "))\n"
            }
        }

        if let nextPeriod = cm.nextPeriodDate {
            context += "Tahmini sonraki regl: \(cm.formatDate(nextPeriod))\n"
        }

        if let ovulation = cm.nextOvulationDate {
            context += "Tahmini yumurtlama: \(cm.formatDate(ovulation))\n"
        }

        // Son günlük kayıtları
        let recentJournals = cm.journalEntries.prefix(3)
        if !recentJournals.isEmpty {
            context += "\nSon günlük kayıtları:\n"
            for entry in recentJournals {
                context += "- \(cm.formatDate(entry.date)): Ruh hali: \(entry.mood.rawValue)"
                if !entry.note.isEmpty {
                    context += ", Not: \(entry.note)"
                }
                context += "\n"
            }
        }

        return context
    }
}
