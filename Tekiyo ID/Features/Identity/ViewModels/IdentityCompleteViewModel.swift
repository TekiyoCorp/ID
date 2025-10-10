import Foundation
import Combine
import UIKit

@MainActor
final class IdentityCompleteViewModel: ObservableObject {
    @Published var tekiyoID: String = ""
    @Published var username: String = ""
    
    private let identityData: IdentityData
    private let profileImage: UIImage?
    
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
    
}
