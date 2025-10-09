import SwiftUI
import LocalAuthentication

struct FaceIDSetupView: View {
    @State private var showAlert = false
    @State private var isRequesting = false
    @State private var authMessage: String? = nil
    @State private var goToIdentitySetup = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)

            // Title and subtitle, centered
            VStack(spacing: 12) {
                Text("Active FaceID.")
                    .font(.system(size: 36, weight: .medium))
                    .appTypography(fontSize: 36)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                Text("Pas la surveillance.")
                    .font(.system(size: 22, weight: .medium))
                    .appTypography(fontSize: 22)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 48)

            // Face ID symbol centered
            Image(systemName: "faceid")
                .font(.system(size: 63, weight: .medium))
                .foregroundStyle(.black)
                .padding(.top, 32)

            Spacer()

            // Bottom button
            Button(action: { requestFaceID() }) {
                Text("Autoriser")
                    .font(.system(size: 17, weight: .semibold))
                    .appTypography(fontSize: 17)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 293, style: .continuous)
                    .fill(Color.black)
            )
            .padding(.horizontal, 48)
            .padding(.bottom, 24)
            .disabled(isRequesting)
            .opacity(isRequesting ? 0.7 : 1)

            if let authMessage {
                Text(authMessage)
                    .font(.system(size: 13, weight: .regular))
                    .appTypography(fontSize: 13)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationDestination(isPresented: $goToIdentitySetup) {
            IdentitySetupView()
        }
    }

    private func requestFaceID() {
        guard !isRequesting else { return }
        isRequesting = true
        authMessage = nil

        let context = LAContext()
        context.localizedCancelTitle = "Annuler"

        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Autoriser l’application à utiliser Face ID."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    isRequesting = false
                    if success {
                        authMessage = "Face ID activé avec succès."
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        goToIdentitySetup = true
                    } else {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
                        authMessage = (authError as NSError?)?.localizedDescription ?? "Échec de l’authentification."
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                isRequesting = false
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                authMessage = error?.localizedDescription ?? "Face ID non disponible sur cet appareil."
            }
        }
    }
}

#Preview {
    FaceIDSetupView()
}
