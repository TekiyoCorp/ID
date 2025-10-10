import SwiftUI

struct FingerprintCreationView: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Title
            LargeTitle("Création de ton empreinte..", alignment: .center)
            
            // Subtitle - 6px gap, 2 lines
            Text("Ton visage reste sur ton appareil.\nSeule une preuve mathématique est inscrite sur la blockchain.")
                .font(.system(size: 16, weight: .regular))
                .appTypography(fontSize: 16)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
                .padding(.top, 6)
            
            Spacer()
            
            // Animated checkcard icon at Y-351
            Image("checkcard")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 142, height: 179)
                .offset(y: animationOffset)
                .onAppear {
                    startAnimation()
                }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            startAnimation()
        }
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
