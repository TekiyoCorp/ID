import SwiftUI

struct FingerprintCreationView: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
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
            
            Spacer()
            
            // Animated SF Symbol with gradient
            Image(systemName: "checkmark.seal.text.page.fill")
                .font(.system(size: 120, weight: .medium))
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
                }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            animationOffset = 8
        }
    }
}

#Preview {
    FingerprintCreationView()
}
