import SwiftUI

struct ConversationUser: Identifiable, Equatable {
    let id: String
    let name: String
    let avatarImage: String // SF Symbol or placeholder
    let avatarColor: Color
    let isOnline: Bool
    let isVerified: Bool
    
    init(id: String = UUID().uuidString, name: String, avatarImage: String = "person.fill", avatarColor: Color = .blue, isOnline: Bool = false, isVerified: Bool = false) {
        self.id = id
        self.name = name
        self.avatarImage = avatarImage
        self.avatarColor = avatarColor
        self.isOnline = isOnline
        self.isVerified = isVerified
    }
}

