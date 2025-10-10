import Foundation
import Combine

@MainActor
final class IdentityViewModel: ObservableObject {
    @Published var currentStep: IdentityStep = .nom
    @Published var nom = ""
    @Published var prenom = ""
    @Published var dateNaissance = Date()
    @Published var nationalite = ""
    @Published var metier = ""
    @Published var ville = ""
    @Published var showSuggestions = true
    @Published var shouldNavigateToPhotoCapture = false
    
    private let metiers: [String] = [
        "Développeur", "Développeuse", "Ingénieur", "Ingénieure", "Designer", "Chef de projet", "Cheffe de projet",
        "Marketing", "Commercial", "Commerciale", "Vendeur", "Vendeuse", "Comptable", "Secrétaire", "Assistant", "Assistante",
        "Médecin", "Infirmier", "Infirmière", "Pharmacien", "Pharmacienne", "Avocat", "Avocate", "Notaire",
        "Enseignant", "Enseignante", "Professeur", "Professeure", "Éducateur", "Éducatrice", "Formateur", "Formatrice",
        "Journaliste", "Rédacteur", "Rédactrice", "Photographe", "Vidéaste", "Graphiste", "Webdesigner", "UX Designer", "UI Designer",
        "Architecte", "Urbaniste", "Géomètre", "Ingénieur civil", "Ingénieure civile", "Chef de chantier", "Cheffe de chantier",
        "Cuisinier", "Cuisinière", "Serveur", "Serveuse", "Barman", "Barmaid", "Gérant", "Gérante", "Restaurateur", "Restauratrice",
        "Coiffeur", "Coiffeuse", "Esthéticien", "Esthéticienne", "Masseur", "Masseuse", "Kinésithérapeute", "Ostéopathe",
        "Psychologue", "Psychiatre", "Thérapeute", "Coach", "Consultant", "Consultante", "Conseiller", "Conseillère",
        "Banquier", "Banquière", "Assureur", "Assureuse", "Agent immobilier", "Agente immobilière", "Courtier", "Coutière",
        "Policier", "Policière", "Gendarme", "Pompier", "Pompière", "Militaire", "Agent de sécurité", "Agente de sécurité",
        "Artisan", "Artisane", "Électricien", "Électricienne", "Plombier", "Plombière", "Maçon", "Maçonne", "Peintre", "Carreleur", "Carreleuse",
        "Transporteur", "Transporteuse", "Chauffeur", "Chauffeuse", "Livreur", "Livreuse", "Facteur", "Factrice",
        "Agriculteur", "Agricultrice", "Éleveur", "Éleveuse", "Vétérinaire", "Technicien", "Technicienne", "Ouvrier", "Ouvrière",
        "Étudiant", "Étudiante", "Stagiaire", "Apprenti", "Apprentie", "Retraité", "Retraitée", "Autre"
    ]
    
    private let villes: [String] = [
        "Paris", "Lyon", "Marseille", "Toulouse", "Nice", "Nantes", "Montpellier", "Strasbourg", "Bordeaux", "Lille",
        "Rennes", "Reims", "Le Havre", "Saint-Étienne", "Toulon", "Angers", "Grenoble", "Dijon", "Nîmes", "Aix-en-Provence",
        "Saint-Denis", "Brest", "Le Mans", "Amiens", "Limoges", "Tours", "Annecy", "Perpignan", "Boulogne-Billancourt", "Orléans",
        "Mulhouse", "Rouen", "Caen", "Nancy", "Saint-Denis", "Argenteuil", "Montreuil", "Roubaix", "Tourcoing", "Nanterre",
        "Avignon", "Créteil", "Dunkirk", "Poitiers", "Asnières-sur-Seine", "Versailles", "Courbevoie", "Vitry-sur-Seine", "Colombes", "Aulnay-sous-Bois",
        "La Rochelle", "Rueil-Malmaison", "Antibes", "Saint-Maur-des-Fossés", "Champigny-sur-Marne", "Aubervilliers", "Béziers", "Cannes", "Colmar", "Drancy",
        "Mérignac", "Saint-Nazaire", "Issy-les-Moulineaux", "Noisy-le-Grand", "Évry", "Cergy", "Pessac", "Vénissieux", "Troyes", "Clichy",
        "Montauban", "Neuilly-sur-Seine", "Pantin", "Niort", "Le Tampon", "Sarcelles", "Levallois-Perret", "Antony", "Lorient", "Caluire-et-Cuire",
        "Boulogne-sur-Mer", "Beauvais", "Hyères", "Le Cannet", "Saint-Ouen", "Massy", "Villejuif", "Épinay-sur-Seine", "Meudon", "Chelles",
        "Cholet", "Pantin", "Belfort", "Évry-Courcouronnes", "Vincennes", "Laval", "Bobigny", "Saint-Priest", "Montrouge", "Bayonne",
        "Sartrouville", "Meaux", "Bourges", "Châteauroux", "Blois", "Châlons-en-Champagne", "Charleville-Mézières", "Tarbes", "Alès", "Saint-Germain-en-Laye",
        "Sète", "Aubagne", "Roanne", "Saint-Brieuc", "Châtelet", "Montbéliard", "Douai", "Tarbes", "Arles", "Mâcon",
        "Belfort", "Martigues", "Bayonne", "Évreux", "Vannes", "Brive-la-Gaillarde", "Châteauroux", "Saint-Malo", "Chalon-sur-Saône", "Agen",
        "Bastia", "Castres", "Thionville", "Montauban", "Albi", "Lannion", "Libourne", "Roanne", "Tulle", "Auch",
        "Cahors", "Foix", "Pamiers", "Saint-Gaudens", "Mirande", "Condom", "Lectoure", "Fleurance", "Vic-en-Bigorre", "Tarbes",
        "Lourdes", "Bagnères-de-Bigorre", "Argelès-Gazost", "Luz-Saint-Sauveur", "Cauterets", "Autre"
    ]
    
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
        currentStep == .ville && !ville.isEmpty
    }
    
    
    var countrySuggestions: [String] {
        guard !nationalite.isEmpty else { return [] }
        let prefix = nationalite.lowercased()
        return countries
            .filter { $0.lowercased().hasPrefix(prefix) }
            .prefix(5)
            .map { $0 }
    }
    
    var metierSuggestions: [String] {
        guard !metier.isEmpty else { return [] }
        let prefix = metier.lowercased()
        return metiers
            .filter { $0.lowercased().contains(prefix) }
            .prefix(8)
            .map { $0 }
    }
    
    var villeSuggestions: [String] {
        guard !ville.isEmpty else { return [] }
        let prefix = ville.lowercased()
        return villes
            .filter { $0.lowercased().contains(prefix) }
            .prefix(8)
            .map { $0 }
    }
    
    var isCurrentStepComplete: Bool {
        switch currentStep {
        case .nom: return !nom.isEmpty
        case .prenom: return !prenom.isEmpty
        case .naissance: return true
        case .nationalite: return !nationalite.isEmpty
        case .metier: return !metier.isEmpty
        case .ville: return !ville.isEmpty
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
        case .nationalite where !nationalite.isEmpty:
            currentStep = .metier
        case .metier where !metier.isEmpty:
            currentStep = .ville
        case .ville:
            break
        default:
            break
        }
    }
    
    func selectCountry(_ country: String) {
        nationalite = country
        showSuggestions = false
    }
    
    func selectMetier(_ metierSelected: String) {
        metier = metierSelected
        showSuggestions = false
    }
    
    func selectVille(_ villeSelected: String) {
        ville = villeSelected
        showSuggestions = false
    }
    
    func validate() -> Bool {
        !nom.isEmpty && !prenom.isEmpty && !nationalite.isEmpty && !metier.isEmpty && !ville.isEmpty
    }
    
    func buildIdentityData() -> IdentityData? {
        guard validate() else { return nil }
        return IdentityData(
            nom: nom,
            prenom: prenom,
            dateNaissance: dateNaissance,
            nationalite: nationalite,
            metier: metier,
            ville: ville
        )
    }
    
    func proceedToPhotoCapture() {
        shouldNavigateToPhotoCapture = true
    }
}

