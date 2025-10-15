import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var currentCity: String?
    @Published var isLoadingLocation = false
    @Published var locationError: String?
    
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    init(locationManager: LocationManager = LocationManager()) {
        self.locationManager = locationManager
        
        // Observer les changements de ville
        locationManager.$currentCity
            .receive(on: RunLoop.main)
            .sink { [weak self] city in
                self?.currentCity = city
                self?.isLoadingLocation = false
            }
            .store(in: &cancellables)
        
        // Observer les erreurs de localisation
        locationManager.$errorMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.locationError = error
                self?.isLoadingLocation = false
            }
            .store(in: &cancellables)
        
        // Observer le statut d'autorisation
        locationManager.$authorizationStatus
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    self?.isLoadingLocation = true
                case .denied, .restricted:
                    self?.locationError = "L'accès à la localisation a été refusé"
                    self?.isLoadingLocation = false
                case .notDetermined:
                    break
                @unknown default:
                    self?.locationError = "Statut de localisation inconnu"
                    self?.isLoadingLocation = false
                }
            }
            .store(in: &cancellables)
    }
    
    func requestLocation() {
        isLoadingLocation = true
        locationError = nil
        locationManager.requestLocationPermission()
    }
    
    func getDisplayCity() -> String {
        if let city = currentCity {
            return city
        } else if let error = locationError {
            return "Localisation indisponible"
        } else if isLoadingLocation {
            return "Chargement..."
        } else {
            return "Localisation inconnue"
        }
    }
}
