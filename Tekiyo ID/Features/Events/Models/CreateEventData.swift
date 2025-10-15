import Foundation
import CoreLocation
import UIKit

struct CreateEventData {
    // 1. Informations de base
    var eventName: String = ""
    var category: EventCategory = .other
    var description: String = ""
    
    // 2. Lieu
    var location: EventLocation?
    var useCurrentLocation: Bool = false
    
    // 3. Date & heure
    var startDate: Date = Date()
    var endDate: Date = Date().addingTimeInterval(3600) // +1 heure par défaut
    var hasEndTime: Bool = false
    
    // 4. Image de couverture
    var coverImage: UIImage?
    
    // 5. Accès
    var isPublic: Bool = true
    
    // 6. Conditions d'accès
    var requiresVerifiedProfile: Bool = false
    var minimumTrustScore: Double = 0.0 // 0-10
    var isPaid: Bool = false
    var entryPrice: Double = 0.0
    var currency: String = "€"
    var hasCapacityLimit: Bool = false
    var maxCapacity: Int = 100
    
    // 7. Réductions
    var verifiedDiscount: Bool = false
    var verifiedDiscountPercent: Double = 10.0
    var mutualTrustDiscount: Bool = false
    var mutualTrustDiscountPercent: Double = 5.0
    
    // 8. Options sociales
    var createEventChat: Bool = true
    var allowSharing: Bool = true
    var appleMusicPlaylist: String = ""
    
    // Validation
    var isValid: Bool {
        !eventName.isEmpty &&
        !description.isEmpty &&
        description.count <= 200 &&
        location != nil &&
        (!hasEndTime || endDate > startDate) &&
        (!isPaid || entryPrice > 0) &&
        (!hasCapacityLimit || maxCapacity > 0)
    }
    
    var missingFields: [String] {
        var missing: [String] = []
        
        if eventName.isEmpty { missing.append("Nom de l'événement") }
        if description.isEmpty { missing.append("Description") }
        if description.count > 200 { missing.append("Description trop longue (max 200 caractères)") }
        if location == nil { missing.append("Lieu") }
        if hasEndTime && endDate <= startDate { missing.append("Heure de fin invalide") }
        if isPaid && entryPrice <= 0 { missing.append("Prix d'entrée invalide") }
        if hasCapacityLimit && maxCapacity <= 0 { missing.append("Capacité invalide") }
        
        return missing
    }
}
