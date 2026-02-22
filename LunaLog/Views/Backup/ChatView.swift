import SwiftUI

struct ChatView: View {
    @EnvironmentObject var cycleManager: CycleManager
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.isReady {
                    chatContent
                } else {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            .onAppear {
                viewModel.loadMessages()
            }
            .navigationTitle("Asistan")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.clearChat() }) {
                        Image(systemName: "trash")
                            .foregroundColor(.pink)
                    }
                }
            }
        }
    }

    private var chatContent: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            messageBubble(message)
                                .id(message.id)
                        }

                        if viewModel.isLoading {
                            typingIndicator
                                .id("typing")
                        }

                        if let error = viewModel.errorMessage {
                            errorBubble(error)
                                .id("error")
                        }
                    }
                    .padding()
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let lastID = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.isLoading) { _, loading in
                    if loading {
                        withAnimation {
                            proxy.scrollTo("typing", anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            messageInputBar
        }
    }

    private func messageBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.isUser { Spacer() }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(message.isUser ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Group {
                            if message.isUser {
                                LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                            } else {
                                LinearGradient(colors: [Color(.systemGray6), Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                            }
                        }
                    )
                    .cornerRadius(18)

                Text(formatTime(message.date))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if !message.isUser { Spacer() }
        }
    }

    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .opacity(0.5)
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .opacity(0.5)
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .opacity(0.5)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(18)

            Spacer()
        }
    }

    private func errorBubble(_ error: String) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)

            Spacer()
        }
    }

    private var messageInputBar: some View {
        HStack(spacing: 12) {
            TextField("Mesajını yaz...", text: $messageText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .focused($isTextFieldFocused)

            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(
                        LinearGradient(
                            colors: messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading
                                ? [.gray, .gray]
                                : [.pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messageText = ""
        isTextFieldFocused = false
        viewModel.sendMessage(text, cycleManager: cycleManager)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    ChatView()
        .environmentObject(CycleManager())
}
