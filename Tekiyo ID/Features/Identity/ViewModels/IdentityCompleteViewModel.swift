import Foundation
import Combine
import UIKit

@MainActor
final class IdentityCompleteViewModel: ObservableObject {
    @Published var tekiyoID: String = ""
    @Published var username: String = ""
    @Published var recentActivities: [IdentityActivity] = []
    
    let identityData: IdentityData
    let profileImage: UIImage?
    
    init(identityData: IdentityData, profileImage: UIImage?) {
        self.identityData = identityData
        self.profileImage = profileImage
        
        generateData()
    }
    
    var fullName: String {
        "\(identityData.prenom) \(identityData.nom)"
    }
    
    var profileUIImage: UIImage? {
        profileImage
    }
    
    private func generateData() {
        tekiyoID = generateTekiyoID()
        username = generateUsername(from: identityData.prenom)
        recentActivities = generateRecentActivities()
    }
    
    private func generateTekiyoID() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let firstPart = String((0..<4).map { _ in characters.randomElement()! })
        let secondPart = String((0..<4).map { _ in characters.randomElement()! })
        return "\(firstPart)-\(secondPart)"
    }
    
    private func generateUsername(from firstName: String) -> String {
        let randomDigits = String(format: "%02d", Int.random(in: 10...99))
        return "@\(firstName.lowercased())\(randomDigits)"
    }
    
    private func generateRecentActivities() -> [IdentityActivity] {
        [
            IdentityActivity(
                icon: "faceid",
                title: "Reconnaissance faciale réussie",
                detail: "Connexion confirmée pour \(identityData.prenom)",
                timestamp: "Il y a 2 minutes"
            ),
            IdentityActivity(
                icon: "person.crop.circle.badge.checkmark",
                title: "Badge vérifié obtenu",
                detail: "Ton profil Tekiyo est désormais certifié",
                timestamp: "Il y a 1 heure"
            ),
            IdentityActivity(
                icon: "hand.raised.fill",
                title: "Nouvelle confiance reçue",
                detail: "\(identityData.prenom) \(identityData.nom) approuve ton identité",
                timestamp: "Hier"
            )
        ]
    }
}

struct IdentityActivity: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
    let timestamp: String
}
