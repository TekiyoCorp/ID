import LocalAuthentication
import Foundation

enum BiometricAuthResult {
    case success
    case failure(BiometricAuthError)
    case notAvailable
}

enum BiometricAuthError: Error {
    case userCancel
    case systemCancel
    case biometryNotEnrolled
    case biometryNotAvailable
    case passcodeNotSet
    case other(String)
    
    var localizedMessage: String {
        switch self {
        case .userCancel:
            return "Authentification annulée."
        case .systemCancel:
            return "Authentification interrompue par le système."
        case .biometryNotEnrolled:
            return "Face ID n'est pas configuré sur cet appareil."
        case .biometryNotAvailable:
            return "Face ID n'est pas disponible."
        case .passcodeNotSet:
            return "Aucun code de déverrouillage configuré."
        case .other(let message):
            return message
        }
    }
}

final class BiometricAuthManager {
    static let shared = BiometricAuthManager()
    
    private init() {}
    
    func authenticate(reason: String) async -> BiometricAuthResult {
        let context = LAContext()
        context.localizedCancelTitle = "Annuler"
        
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .failure(mapError(error))
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return success ? .success : .failure(.other("Échec de l'authentification."))
        } catch let error as LAError {
            return .failure(mapLAError(error))
        } catch {
            return .failure(.other(error.localizedDescription))
        }
    }
    
    func canUseBiometrics() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func biometricType() -> LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }
    
    private func mapError(_ error: NSError?) -> BiometricAuthError {
        guard let error = error else {
            return .biometryNotAvailable
        }
        
        switch error.code {
        case LAError.biometryNotAvailable.rawValue:
            return .biometryNotAvailable
        case LAError.biometryNotEnrolled.rawValue:
            return .biometryNotEnrolled
        case LAError.passcodeNotSet.rawValue:
            return .passcodeNotSet
        default:
            return .other(error.localizedDescription)
        }
    }
    
    private func mapLAError(_ error: LAError) -> BiometricAuthError {
        switch error.code {
        case .userCancel:
            return .userCancel
        case .systemCancel:
            return .systemCancel
        case .biometryNotEnrolled:
            return .biometryNotEnrolled
        case .biometryNotAvailable:
            return .biometryNotAvailable
        case .passcodeNotSet:
            return .passcodeNotSet
        default:
            return .other(error.localizedDescription)
        }
    }
}

