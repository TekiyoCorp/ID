import Foundation
import Combine

@MainActor
final class FaceIDViewModel: ObservableObject {
    @Published var isRequesting = false
    @Published var authMessage: String?
    @Published var shouldNavigateToIdentity = false
    
    private let authManager: BiometricAuthManager
    private let hapticManager: HapticManager
    
    init(
        authManager: BiometricAuthManager? = nil,
        hapticManager: HapticManager? = nil
    ) {
        self.authManager = authManager ?? BiometricAuthManager.shared
        self.hapticManager = hapticManager ?? HapticManager.shared
    }
    
    func requestAuthentication() async {
        guard !isRequesting else { return }
        
        isRequesting = true
        authMessage = nil
        
        let result = await authManager.authenticate(
            reason: "Autoriser l'application à utiliser Face ID."
        )
        
        isRequesting = false
        
        switch result {
        case .success:
            authMessage = "Face ID activé avec succès."
            hapticManager.success()
            shouldNavigateToIdentity = true
            
        case .failure(let error):
            hapticManager.error()
            authMessage = error.localizedMessage
            
        case .notAvailable:
            hapticManager.error()
            authMessage = "Face ID non disponible sur cet appareil."
        }
    }
    
    #if DEBUG
    func simulateSuccess() {
        authMessage = "Face ID activé avec succès (simulé)."
        hapticManager.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.shouldNavigateToIdentity = true
        }
    }
    
    func skipFaceID() {
        shouldNavigateToIdentity = true
    }
    #endif
}

