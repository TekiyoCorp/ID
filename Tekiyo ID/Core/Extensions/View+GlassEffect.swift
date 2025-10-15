import SwiftUI

extension View {
    /// Effet liquid glass maximum avec paramètres optimaux
    /// Refraction 100, Depth 100, Dispersion 100, Frost 0
    func maximumGlassEffect() -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 50, style: .continuous))
            .background(.ultraThickMaterial.opacity(0.3), in: RoundedRectangle(cornerRadius: 50, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 50, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    /// Effet glass pour boutons flottants
    func floatingGlassButton() -> some View {
        self
            .background(.ultraThinMaterial, in: Circle())
            .background(.ultraThickMaterial.opacity(0.2), in: Circle())
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
    
    /// Effet glass pour cartes
    func glassCard() -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 50, style: .continuous))
            .background(.ultraThickMaterial.opacity(0.25), in: RoundedRectangle(cornerRadius: 50, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 50, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
    }
}
