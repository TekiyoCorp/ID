import SwiftUI

struct FaceIDSetupView: View {
    @StateObject private var viewModel = FaceIDViewModel()
    #if DEBUG
    @State private var showDebugControls = false
    #endif
    
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
        #if DEBUG
        .overlay(alignment: .topTrailing) {
            VStack {
                Button(action: {
                    showDebugControls.toggle()
                }) {
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
                
                if showDebugControls {
                    VStack(spacing: 8) {
                        Button("Simuler succès") {
                            viewModel.simulateSuccess()
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .clipShape(Capsule())
                        
                        Button("Passer FaceID") {
                            viewModel.skipFaceID()
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .clipShape(Capsule())
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        #endif
    }
}

#Preview {
    FaceIDSetupView()
}
