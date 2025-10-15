import Foundation

struct Message: Identifiable, Equatable {
    let id: String
    let senderId: String
    let text: String
    let timestamp: Date
    let isFromCurrentUser: Bool
    
    init(id: String = UUID().uuidString, senderId: String, text: String, timestamp: Date = Date(), isFromCurrentUser: Bool) {
        self.id = id
        self.senderId = senderId
        self.text = text
        self.timestamp = timestamp
        self.isFromCurrentUser = isFromCurrentUser
    }
}

