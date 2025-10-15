import SwiftUI
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var messageText: String = ""
    @Published var showTransactionBubble: Bool = true
    
    let conversationUser: ConversationUser
    
    init(conversationUser: ConversationUser) {
        self.conversationUser = conversationUser
        loadMockMessages()
    }
    
    private func loadMockMessages() {
        // Mock messages for Marie D. chat
        messages = [
            Message(
                senderId: conversationUser.id,
                text: "Avec plaisir c'était top",
                timestamp: Date().addingTimeInterval(-300),
                isFromCurrentUser: false
            ),
            Message(
                senderId: "currentUser",
                text: "Putin merci beaucoup !",
                timestamp: Date().addingTimeInterval(-200),
                isFromCurrentUser: true
            ),
            Message(
                senderId: "currentUser",
                text: "Grave !",
                timestamp: Date().addingTimeInterval(-100),
                isFromCurrentUser: true
            )
        ]
    }
    
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let newMessage = Message(
            senderId: "currentUser",
            text: messageText,
            isFromCurrentUser: true
        )
        
        messages.append(newMessage)
        messageText = ""
    }
}

