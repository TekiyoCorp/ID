import SwiftUI
import CryptoKit

struct OptimizedCircularCodeView: View {
    let url: String
    let size: CGFloat
    let dotRadius: CGFloat
    
    @State private var animationScale: CGFloat = 0.8
    @State private var animationOpacity: Double = 0.0
    @State private var isAnimating = false
    
    // Cache computed dots to avoid recalculation
    private let cachedDots: [DotPosition]
    
    init(url: String, size: CGFloat = 120, dotRadius: CGFloat = 2.5) {
        self.url = url
        self.size = size
        self.dotRadius = dotRadius
        // Pre-compute dots during initialization
        self.cachedDots = Self.generateDots(from: url, size: size)
    }
    
    var body: some View {
        ZStack {
            // Background circle - static, no animation
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                )
            
            // Dots pattern - optimized Canvas with drawingGroup
            Canvas { context, canvasSize in
                let centerX = canvasSize.width / 2
                let centerY = canvasSize.height / 2
                
                for dot in cachedDots {
                    let rect = CGRect(
                        x: centerX + dot.x - dotRadius,
                        y: centerY + dot.y - dotRadius,
                        width: dotRadius * 2,
                        height: dotRadius * 2
                    )
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(.blue)
                    )
                }
            }
            .frame(width: size, height: size)
            .drawingGroup() // Force GPU rendering
            .opacity(animationOpacity)
            .scaleEffect(animationScale)
            .animation(.easeOut(duration: 0.8), value: animationOpacity)
            .animation(.easeOut(duration: 0.8), value: animationScale)
            
            // Center logo - static after animation
            if !isAnimating {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 12, height: 12)
                    
                    Circle()
                        .stroke(Color.blue, lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                }
                .opacity(animationOpacity)
                .scaleEffect(animationScale)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            // Single animation trigger
            guard !isAnimating else { return }
            isAnimating = true
            
            withAnimation(.easeOut(duration: 0.8)) {
                animationScale = 1.0
                animationOpacity = 1.0
            }
        }
    }
    
    // Static method to pre-compute dots
    private static func generateDots(from url: String, size: CGFloat) -> [DotPosition] {
        let data = Data(url.utf8)
        let hash = SHA256.hash(data: data)
        let hashBytes = Array(hash)
        
        let maxRadius = (size / 2) - 12
        let minRadius: CGFloat = 18
        
        var dots: [DotPosition] = []
        let targetDotCount = 80 // Reduced for better performance
        
        for i in 0..<targetDotCount {
            let byteIndex = i % hashBytes.count
            let hashByte = hashBytes[byteIndex]
            let nextByte = hashBytes[(byteIndex + 1) % hashBytes.count]
            
            let angle = Double(hashByte) / 255.0 * 2 * .pi
            let progress = Double(i) / Double(targetDotCount - 1)
            let baseRadius = Double(minRadius) + (Double(maxRadius) - Double(minRadius)) * progress
            
            let variation = (Double(nextByte) / 255.0 - 0.5) * 2.0 // Reduced variation
            let finalRadius = max(Double(minRadius), min(Double(maxRadius), baseRadius + variation))
            
            let x = cos(angle) * finalRadius
            let y = sin(angle) * finalRadius
            
            let distance = sqrt(x*x + y*y)
            if distance <= Double(maxRadius) && distance >= Double(minRadius - 2) {
                dots.append(DotPosition(x: CGFloat(x), y: CGFloat(y)))
            }
        }
        
        return dots
    }
}

// MARK: - Dot Position Model
private struct DotPosition {
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        OptimizedCircularCodeView(url: "https://tekiyo.fr/3A1B-7E21")
            .frame(width: 120, height: 120)
        
        Text("Ce code QR prouve ton humanité.")
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(.primary)
            .opacity(0.7)
    }
    .padding()
}
