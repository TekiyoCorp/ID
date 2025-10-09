import Foundation

struct IdentityData: Codable, Equatable {
    let nom: String
    let prenom: String
    let dateNaissance: Date
    let nationalite: String
    
    var isValid: Bool {
        !nom.isEmpty && !prenom.isEmpty && !nationalite.isEmpty
    }
    
    var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current
        return formatter.string(from: dateNaissance)
    }
}

