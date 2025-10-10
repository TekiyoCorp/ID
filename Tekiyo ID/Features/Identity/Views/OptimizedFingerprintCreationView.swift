import SwiftUI

struct OptimizedFingerprintCreationView: View {
    let identityData: IdentityData?
    let capturedImage: UIImage?
    
    @State private var animationOffset: CGFloat = 0
    @State private var shouldNavigateToComplete = false
    @State private var animationTask: Task<Void, Never>?
    @State private var navigationTask: Task<Void, Never>?
    
    // Pre-computed gradient to avoid recalculation
    private let iconGradient = LinearGradient(
        colors: [
            Color(red: 0.0, green: 0.18, blue: 1.0), // 002FFF
            Color(red: 0.0, green: 0.18, blue: 1.0).opacity(0.0) // 0%
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    init(identityData: IdentityData?, capturedImage: UIImage?) {
        self.identityData = identityData
        self.capturedImage = capturedImage
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Static text at fixed Y position - no animation
                StaticTextView()
                    .frame(width: geometry.size.width)
                    .position(x: geometry.size.width / 2, y: 210)
                
                // Animated icon - optimized animation
                AnimatedIconView(
                    gradient: iconGradient,
                    offset: animationOffset
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationDestination(isPresented: $shouldNavigateToComplete) {
            if let identityData = identityData {
                IdentityCompleteView(identityData: identityData, profileImage: capturedImage)
            }
        }
        .onAppear {
            startOptimizedAnimation()
        }
        .onDisappear {
            animationTask?.cancel()
            animationTask = nil
            navigationTask?.cancel()
            navigationTask = nil
            animationOffset = 0
        }
        .debugRenders("OptimizedFingerprintCreationView")
    }
    
    private func startOptimizedAnimation() {
        guard animationTask == nil else { return }
        
        let stepDuration: TimeInterval = 0.75
        let stepNanoseconds = UInt64(stepDuration * Double(NSEC_PER_SEC))
        let sequence: [CGFloat] = [8, -6, 4, 0]
        
        animationTask = Task {
            for target in sequence {
                if Task.isCancelled { break }
                
                await MainActor.run {
                    withAnimation(.easeInOut(duration: stepDuration)) {
                        animationOffset = target
                    }
                }
                
                try? await Task.sleep(nanoseconds: stepNanoseconds)
            }
            
            await MainActor.run {
                animationTask = nil
            }
        }
        
        navigationTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(3.5 * Double(NSEC_PER_SEC)))
            if Task.isCancelled { return }
            await MainActor.run {
                shouldNavigateToComplete = true
                navigationTask = nil
            }
        }
    }
}

// MARK: - Static Text Component
struct StaticTextView: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Création de ton empreinte..")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            
            Text("Ton visage reste sur ton appareil.\nSeule une preuve mathématique est inscrite sur la blockchain.")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
                .padding(.top, 6)
        }
    }
}

// MARK: - Animated Icon Component
struct AnimatedIconView: View {
    let gradient: LinearGradient
    let offset: CGFloat
    
    var body: some View {
        Image(systemName: "checkmark.seal.text.page.fill")
            .font(.system(size: 160, weight: .medium))
            .foregroundStyle(gradient)
            .offset(y: offset)
    }
}

// MARK: - Preview
#Preview {
    OptimizedFingerprintCreationView(
        identityData: IdentityData(
            nom: "Dupont",
            prenom: "Marie",
            dateNaissance: Date(),
            nationalite: "France"
        ),
        capturedImage: nil
    )
}
