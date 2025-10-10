import SwiftUI

struct FaceIDSetupView: View {
    @StateObject private var viewModel = FaceIDViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)

            VStack(spacing: 12) {
                LargeTitle("Active FaceID.", alignment: .center)

                Text("Pas la surveillance.")
                    .font(.system(size: 22, weight: .medium))
                    .appTypography(fontSize: 22)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 48)

            Image(systemName: "faceid")
                .font(.system(size: 63, weight: .medium))
                .foregroundStyle(.black)
                .padding(.top, 32)

            Spacer()

            PrimaryButton(
                title: "Autoriser",
                isEnabled: !viewModel.isRequesting,
                action: {
                    Task {
                        await viewModel.requestAuthentication()
                    }
                }
            )
            .padding(.horizontal, 48)
            .padding(.bottom, 24)

            if let authMessage = viewModel.authMessage {
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
        .navigationDestination(isPresented: $viewModel.shouldNavigateToIdentity) {
            IdentitySetupView()
        }
        .debugRenders("FaceIDSetupView")
    }
}

#Preview {
    FaceIDSetupView()
}
