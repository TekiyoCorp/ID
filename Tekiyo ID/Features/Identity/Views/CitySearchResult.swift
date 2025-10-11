import MapKit

struct CitySearchResult: Identifiable, Hashable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let city: String
    let displayName: String
    let country: String?
    let fullAddress: String?
    
    static func == (lhs: CitySearchResult, rhs: CitySearchResult) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init?(mapItem: MKMapItem) {
        if #available(iOS 26.0, *) {
            let location = mapItem.location
            let addressReps = mapItem.addressRepresentations
            let address = mapItem.address
            
            coordinate = location.coordinate
            let resolvedCity = addressReps?.cityName ?? address?.shortAddress ?? mapItem.name
            guard let resolvedCity else { return nil }
            city = resolvedCity
            displayName = mapItem.name ?? resolvedCity
            country = addressReps?.regionName
            fullAddress = addressReps?.fullAddress(includingRegion: true, singleLine: true) ?? address?.fullAddress
        } else {
            coordinate = mapItem.placemark.coordinate
            let resolvedCity = mapItem.placemark.locality ?? mapItem.name
            guard let resolvedCity else { return nil }
            city = resolvedCity
            displayName = mapItem.name ?? resolvedCity
            country = mapItem.placemark.country
            fullAddress = mapItem.placemark.title
        }
    }
}
