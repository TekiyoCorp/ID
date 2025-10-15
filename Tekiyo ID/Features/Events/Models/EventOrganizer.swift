import SwiftUI

struct EventOrganizer: Identifiable, Equatable {
    let id: String
    let name: String
    let logo: String // SF Symbol ou asset
    let logoColor: Color
    let isVerified: Bool
    
    init(id: String = UUID().uuidString, name: String, logo: String = "building.columns.fill", logoColor: Color = .blue, isVerified: Bool = false) {
        self.id = id
        self.name = name
        self.logo = logo
        self.logoColor = logoColor
        self.isVerified = isVerified
    }
}
