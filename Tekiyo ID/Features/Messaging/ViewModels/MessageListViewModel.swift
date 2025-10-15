import SwiftUI
import Combine

enum MessageSegment: String, CaseIterable {
    case messages = "Messages"
    case notifications = "Notifications"
}

@MainActor
final class MessageListViewModel: ObservableObject {
    @Published var selectedSegment: MessageSegment = .messages
    @Published var conversations: [Conversation] = []
    @Published var eventsCount: Int = 1
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        // Marie D. - Online, unread
        let marie = ConversationUser(
            name: "Marie D.",
            avatarImage: "person.fill",
            avatarColor: Color(red: 0.4, green: 0.6, blue: 0.9),
            isOnline: true,
            isVerified: false
        )
        
        // Thomas S. - Black & white photo, unread
        let thomas = ConversationUser(
            name: "Thomas S.",
            avatarImage: "person.fill",
            avatarColor: Color.gray,
            isOnline: false,
            isVerified: false
        )
        
        // Julie F. - Profile photo
        let julie = ConversationUser(
            name: "Julie F.",
            avatarImage: "person.fill",
            avatarColor: Color(red: 0.9, green: 0.6, blue: 0.5),
            isOnline: false,
            isVerified: false
        )
        
        // BNP - Verified badge
        let bnp = ConversationUser(
            name: "BNP",
            avatarImage: "building.columns.fill",
            avatarColor: Color.green,
            isOnline: false,
            isVerified: true
        )
        
        conversations = [
            Conversation(
                user: marie,
                lastMessage: "Salut, tu peux me dire si tu viens cette après-....",
                timestamp: Date().addingTimeInterval(-10),
                isUnread: true
            ),
            Conversation(
                user: thomas,
                lastMessage: "Merci pour aujourd'hui",
                timestamp: Date().addingTimeInterval(-120),
                isUnread: true
            ),
            Conversation(
                user: julie,
                lastMessage: "Vous a envoyé 50€",
                timestamp: Date().addingTimeInterval(-86400),
                isUnread: false
            ),
            Conversation(
                user: bnp,
                lastMessage: "Vous a envoyé un document.",
                timestamp: Date().addingTimeInterval(-86400),
                isUnread: false
            )
        ]
    }
    
    var filteredConversations: [Conversation] {
        // For now, all conversations are in Messages
        // Notifications would be filtered separately
        conversations
    }
}

