import Foundation

enum IdentityStep: Int, CaseIterable {
    case nom = 0
    case prenom
    case naissance
    case nationalite
    case metier
    case ville
    
    var title: String {
        switch self {
        case .nom: return "Nom"
        case .prenom: return "Prénom"
        case .naissance: return "Date de naissance"
        case .nationalite: return "Nationalité"
        case .metier: return "Métier"
        case .ville: return "Ville"
        }
    }
    
    var placeholder: String {
        title
    }
}

