import SwiftUI

struct EventParticipant: Identifiable, Equatable {
    let id: String
    let avatarImage: String
    let avatarColor: Color
    
    init(id: String = UUID().uuidString, avatarImage: String = "person.fill", avatarColor: Color = .blue) {
        self.id = id
        self.avatarImage = avatarImage
        self.avatarColor = avatarColor
    }
}
