import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published var currentCity: String?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            errorMessage = "L'accès à la localisation a été refusé. Veuillez l'activer dans les Réglages."
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            errorMessage = "Statut de localisation inconnu"
        }
    }
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    private func fetchCurrentCity(from location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Erreur de géocodage: \(error.localizedDescription)"
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    self?.errorMessage = "Aucune information de localisation trouvée"
                    return
                }
                
                // Priorité: locality > subAdministrativeArea > administrativeArea
                if let city = placemark.locality {
                    self?.currentCity = city
                } else if let city = placemark.subAdministrativeArea {
                    self?.currentCity = city
                } else if let city = placemark.administrativeArea {
                    self?.currentCity = city
                } else {
                    self?.currentCity = "Localisation inconnue"
                }
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            fetchCurrentCity(from: location)
            stopLocationUpdates() // Arrêter après avoir obtenu la localisation
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            errorMessage = "Erreur de localisation: \(error.localizedDescription)"
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            authorizationStatus = status
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                startLocationUpdates()
            case .denied, .restricted:
                errorMessage = "L'accès à la localisation a été refusé"
            case .notDetermined:
                break
            @unknown default:
                errorMessage = "Statut de localisation inconnu"
            }
        }
    }
}
