import SwiftUI

struct TransactionUser: Identifiable, Equatable {
    let id: String
    let name: String
    let avatarImage: String // SF Symbol or placeholder
    let avatarColor: Color
    
    init(id: String = UUID().uuidString, name: String, avatarImage: String = "person.fill", avatarColor: Color = .blue) {
        self.id = id
        self.name = name
        self.avatarImage = avatarImage
        self.avatarColor = avatarColor
    }
}

