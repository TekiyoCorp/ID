import Foundation

struct Conversation: Identifiable, Equatable {
    let id: String
    let user: ConversationUser
    let lastMessage: String
    let timestamp: Date
    let isUnread: Bool
    
    init(id: String = UUID().uuidString, user: ConversationUser, lastMessage: String, timestamp: Date, isUnread: Bool = false) {
        self.id = id
        self.user = user
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.isUnread = isUnread
    }
    
    var timeString: String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: timestamp, to: now)
        
        if let minutes = components.minute, minutes < 60 {
            if minutes == 0 {
                return "À l'instant"
            }
            return "Il y a \(minutes) min"
        } else if let hours = components.hour, hours < 24 {
            return "Il y a \(hours)h"
        } else {
            return "Hier"
        }
    }
}

