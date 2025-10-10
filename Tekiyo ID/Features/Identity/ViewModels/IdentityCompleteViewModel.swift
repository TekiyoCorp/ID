import Foundation
import Combine
import UIKit

@MainActor
final class IdentityCompleteViewModel: ObservableObject {
    @Published var tekiyoID: String = ""
    @Published var username: String = ""
    @Published var qrCodeImage: UIImage?
    
    private let identityData: IdentityData
    private let profileImage: UIImage?
    private let qrGenerator = QRCodeGenerator.shared
    
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
        generateQRCode()
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
    
    private func generateQRCode() {
        let url = "https://tekiyo.fr/\(tekiyoID)"
        qrCodeImage = qrGenerator.generateCircularQRCode(
            from: url,
            size: 120,
            color: UIColor(red: 0.0, green: 0.18, blue: 1.0, alpha: 1.0) // #002FFF
        )
    }
}
