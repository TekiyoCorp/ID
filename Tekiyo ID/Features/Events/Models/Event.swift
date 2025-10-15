import Foundation
import CoreLocation

struct Event: Identifiable, Equatable {
    let id: String
    let title: String
    let organizer: EventOrganizer
    let location: EventLocation
    let requirements: EventRequirements
    let participants: [EventParticipant]
    let capacity: EventCapacity
    let emoji: String? // Optional emoji (🎾)
    
    init(id: String = UUID().uuidString, title: String, organizer: EventOrganizer, location: EventLocation, requirements: EventRequirements, participants: [EventParticipant], capacity: EventCapacity, emoji: String? = nil) {
        self.id = id
        self.title = title
        self.organizer = organizer
        self.location = location
        self.requirements = requirements
        self.participants = participants
        self.capacity = capacity
        self.emoji = emoji
    }
}
