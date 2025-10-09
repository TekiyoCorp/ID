import Foundation
import Combine

@MainActor
final class IdentityViewModel: ObservableObject {
    @Published var currentStep: IdentityStep = .nom
    @Published var nom = ""
    @Published var prenom = ""
    @Published var dateNaissance = Date()
    @Published var nationalite = ""
    @Published var showSuggestions = true
    
    private let countries: [String] = {
        let locale = Locale(identifier: "fr_FR")
        if #available(iOS 16, *) {
            return Locale.Region.isoRegions
                .compactMap { locale.localizedString(forRegionCode: $0.identifier) }
                .sorted()
        } else {
            return Locale.isoRegionCodes
                .compactMap { locale.localizedString(forRegionCode: $0) }
                .sorted()
        }
    }()
    
    var progress: Double {
        let total = Double(IdentityStep.allCases.count)
        let completed = Double(currentStep.rawValue) + (isCurrentStepComplete ? 1.0 : 0.0)
        return min(1.0, completed / total)
    }
    
    var isComplete: Bool {
        currentStep == .nationalite && !nationalite.isEmpty
    }
    
    var shouldShowProgress: Bool {
        !isComplete
    }
    
    var countrySuggestions: [String] {
        guard !nationalite.isEmpty else { return [] }
        let prefix = nationalite.lowercased()
        return countries
            .filter { $0.lowercased().hasPrefix(prefix) }
            .prefix(5)
            .map { $0 }
    }
    
    private var isCurrentStepComplete: Bool {
        switch currentStep {
        case .nom: return !nom.isEmpty
        case .prenom: return !prenom.isEmpty
        case .naissance: return true
        case .nationalite: return !nationalite.isEmpty
        }
    }
    
    func advance() {
        switch currentStep {
        case .nom where !nom.isEmpty:
            currentStep = .prenom
        case .prenom where !prenom.isEmpty:
            currentStep = .naissance
        case .naissance:
            currentStep = .nationalite
        case .nationalite:
            break
        default:
            break
        }
    }
    
    func selectCountry(_ country: String) {
        nationalite = country
        showSuggestions = false
    }
    
    func validate() -> Bool {
        !nom.isEmpty && !prenom.isEmpty && !nationalite.isEmpty
    }
    
    func buildIdentityData() -> IdentityData? {
        guard validate() else { return nil }
        return IdentityData(
            nom: nom,
            prenom: prenom,
            dateNaissance: dateNaissance,
            nationalite: nationalite
        )
    }
}

