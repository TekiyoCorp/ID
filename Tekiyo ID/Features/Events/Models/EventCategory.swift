import SwiftUI

struct EventCategory: Identifiable, CaseIterable {
    let id: String
    let name: String
    let emoji: String
    let color: Color
    
    static let party = EventCategory(id: "party", name: "Fête", emoji: "🎉", color: .pink)
    static let concert = EventCategory(id: "concert", name: "Concert", emoji: "🎶", color: .purple)
    static let networking = EventCategory(id: "networking", name: "Networking", emoji: "💼", color: .blue)
    static let sport = EventCategory(id: "sport", name: "Sport", emoji: "🏋️", color: .green)
    static let restaurant = EventCategory(id: "restaurant", name: "Resto/Bar", emoji: "🍽️", color: .orange)
    static let gaming = EventCategory(id: "gaming", name: "Gaming", emoji: "🎮", color: .red)
    static let other = EventCategory(id: "other", name: "Autre", emoji: "📅", color: .gray)
    
    static var allCases: [EventCategory] {
        [party, concert, networking, sport, restaurant, gaming, other]
    }
}
