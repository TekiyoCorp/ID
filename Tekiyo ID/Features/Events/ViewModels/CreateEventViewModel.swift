import SwiftUI
import Combine
import CoreLocation

@MainActor
final class CreateEventViewModel: ObservableObject {
    @Published var eventData = CreateEventData()
    @Published var currentStep: Int = 0
    @Published var isLoading: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var showLocationSearch: Bool = false
    @Published var showPreview: Bool = false
    
    // Location
    @Published var currentLocation: CLLocation?
    @Published var searchResults: [String] = []
    
    private let locationManager = CLLocationManager()
    
    init() {
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestCurrentLocation() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse else {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        locationManager.requestLocation()
    }
    
    func searchLocation(_ query: String) {
        // Mock search results for now
        searchResults = [
            "23 avenue Montaigne, Paris, France",
            "12 Rue de la Boulnay, Rennes, France",
            "5 Place de la Concorde, Paris, France",
            "15 Rue de Rivoli, Paris, France"
        ].filter { $0.localizedCaseInsensitiveContains(query) }
    }
    
    func selectLocation(_ address: String) {
        // Mock location selection
        eventData.location = EventLocation(
            address: address,
            city: address.components(separatedBy: ",").first ?? address,
            coordinates: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        )
        showLocationSearch = false
    }
    
    func nextStep() {
        if currentStep < 4 {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func publishEvent() {
        guard eventData.isValid else { return }
        
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            self.showPreview = false
            // Here you would normally save the event and refresh the list
        }
    }
}
