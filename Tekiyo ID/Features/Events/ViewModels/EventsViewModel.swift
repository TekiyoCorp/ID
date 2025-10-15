import SwiftUI
import Combine
import CoreLocation

@MainActor
final class EventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedEvent: Event?
    @Published var showEventDetail: Bool = false
    
    init() {
        loadEvents()
    }
    
    private func loadEvents() {
        // Mock data pour BNP - Paris
        let bnpOrganizer = EventOrganizer(
            name: "BNP - Paris Bas",
            logo: "building.columns.fill",
            logoColor: .green,
            isVerified: true
        )
        
        let parisLocation = EventLocation(
            address: "23 avenue Montaigne, Paris",
            city: "Paris",
            coordinates: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        )
        
        let bnpRequirements = EventRequirements(
            profileVerified: true,
            trustScoreMin: 90
        )
        
        let bnpParticipants = [
            EventParticipant(avatarImage: "person.fill", avatarColor: .blue),
            EventParticipant(avatarImage: "person.fill", avatarColor: .green),
            EventParticipant(avatarImage: "person.fill", avatarColor: .orange),
            EventParticipant(avatarImage: "person.fill", avatarColor: .purple),
            EventParticipant(avatarImage: "person.fill", avatarColor: .red)
        ]
        
        let bnpCapacity = EventCapacity(current: 12, max: 50)
        
        let bnpEvent = Event(
            title: "Soirée d'inauguration",
            organizer: bnpOrganizer,
            location: parisLocation,
            requirements: bnpRequirements,
            participants: bnpParticipants,
            capacity: bnpCapacity
        )
        
        // Mock data pour Tennis - Rennes
        let julienOrganizer = EventOrganizer(
            name: "Julien D.",
            logo: "person.fill",
            logoColor: .blue,
            isVerified: true
        )
        
        let rennesLocation = EventLocation(
            address: "12 Rue de la Boulnay, Rennes",
            city: "Rennes",
            coordinates: CLLocationCoordinate2D(latitude: 48.1173, longitude: -1.6778)
        )
        
        let tennisRequirements = EventRequirements(
            profileVerified: false,
            trustScoreMin: 20
        )
        
        let tennisParticipants = [
            EventParticipant(avatarImage: "person.fill", avatarColor: .blue),
            EventParticipant(avatarImage: "person.fill", avatarColor: .green),
            EventParticipant(avatarImage: "person.fill", avatarColor: .orange),
            EventParticipant(avatarImage: "person.fill", avatarColor: .purple),
            EventParticipant(avatarImage: "person.fill", avatarColor: .red)
        ]
        
        let tennisCapacity = EventCapacity(current: 5, max: 8)
        
        let tennisEvent = Event(
            title: "Tennis",
            organizer: julienOrganizer,
            location: rennesLocation,
            requirements: tennisRequirements,
            participants: tennisParticipants,
            capacity: tennisCapacity,
            emoji: "🎾"
        )
        
        events = [bnpEvent, tennisEvent]
    }
    
    func selectEvent(_ event: Event) {
        selectedEvent = event
        showEventDetail = true
    }
    
    func registerForEvent(_ eventId: String) {
        // Mock registration logic
        if let index = events.firstIndex(where: { $0.id == eventId }) {
            let event = events[index]
            let newCapacity = EventCapacity(current: event.capacity.current + 1, max: event.capacity.max)
            events[index] = Event(
                id: event.id,
                title: event.title,
                organizer: event.organizer,
                location: event.location,
                requirements: event.requirements,
                participants: event.participants,
                capacity: newCapacity,
                emoji: event.emoji
            )
        }
        showEventDetail = false
    }
}
