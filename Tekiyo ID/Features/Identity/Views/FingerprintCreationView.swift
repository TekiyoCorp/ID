import SwiftUI

struct FingerprintCreationView: View {
    let identityData: IdentityData?
    let capturedImage: UIImage?
    
    @State private var animationOffset: CGFloat = 0
    @State private var shouldNavigateToComplete = false
    
    init(identityData: IdentityData?, capturedImage: UIImage?) {
        self.identityData = identityData
        self.capturedImage = capturedImage
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Static text at fixed Y position
                VStack(spacing: 0) {
                    // Title - 28px
                    Text("Création de ton empreinte..")
                        .font(.system(size: 28, weight: .medium))
                        .appTypography(fontSize: 28)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                    
                    // Subtitle - 6px gap, reduced lineSpacing
                    Text("Ton visage reste sur ton appareil.\nSeule une preuve mathématique est inscrite sur la blockchain.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 48)
                        .padding(.top, 6)
                }
                .frame(width: geometry.size.width)
                .position(x: geometry.size.width / 2, y: 210)
                
                // Animated icon centered
                Image(systemName: "checkmark.seal.text.page.fill")
                    .font(.system(size: 160, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.18, blue: 1.0), // 002FFF
                                Color(red: 0.0, green: 0.18, blue: 1.0).opacity(0.0) // 0%
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(y: animationOffset)
                    .onAppear {
                        startAnimation()
                        // Auto-navigate after 3.5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                            shouldNavigateToComplete = true
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationDestination(isPresented: $shouldNavigateToComplete) {
            if let identityData = identityData {
                IdentityCompleteView(identityData: identityData, profileImage: capturedImage)
            }
        }
    }
    
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            animationOffset = 8
        }
    }
}

#Preview {
    FingerprintCreationView(
        identityData: IdentityData(
            nom: "Dupont",
            prenom: "Marie",
            dateNaissance: Date(),
            nationalite: "France"
        ),
        capturedImage: nil
    )
}
