import Foundation
import CoreLocation

struct EventLocation: Identifiable, Equatable {
    let id: String
    let address: String
    let city: String
    let coordinates: CLLocationCoordinate2D
    
    init(id: String = UUID().uuidString, address: String, city: String, coordinates: CLLocationCoordinate2D) {
        self.id = id
        self.address = address
        self.city = city
        self.coordinates = coordinates
    }
}
