import SwiftUI
import CryptoKit

struct CircularCodeView: View {
    let url: String
    let size: CGFloat
    let dotRadius: CGFloat
    
    @State private var animationScale: CGFloat = 0.8
    @State private var animationOpacity: Double = 0.0
    
    private var dots: [DotPosition] {
        generateDots(from: url, size: size)
    }
    
    init(url: String, size: CGFloat = 120, dotRadius: CGFloat = 2.5) {
        self.url = url
        self.size = size
        self.dotRadius = dotRadius
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                )
            
            // Dots pattern
            ForEach(Array(dots.enumerated()), id: \.offset) { index, dot in
                Circle()
                    .fill(Color.blue)
                    .frame(width: dotRadius * 2, height: dotRadius * 2)
                    .position(
                        x: size/2 + dot.x,
                        y: size/2 + dot.y
                    )
                    .opacity(animationOpacity)
                    .scaleEffect(animationScale)
                    .animation(
                        .easeOut(duration: 0.6)
                        .delay(Double(index) * 0.002),
                        value: animationOpacity
                    )
            }
            
            // Center logo/placeholder
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
            .animation(.easeOut(duration: 0.8).delay(0.3), value: animationOpacity)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation {
                animationScale = 1.0
                animationOpacity = 1.0
            }
        }
    }
}

// MARK: - Dot Position Model
private struct DotPosition {
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Dot Generation Logic
private func generateDots(from url: String, size: CGFloat) -> [DotPosition] {
    // Hash the URL using SHA256
    let data = Data(url.utf8)
    let hash = SHA256.hash(data: data)
    let hashBytes = Array(hash)
    
    let center = size / 2
    let maxRadius = (size / 2) - 10 // Leave some margin for the border
    let minRadius = 15 // Start from center area
    
    var dots: [DotPosition] = []
    let targetDotCount = 100
    
    // Use hash bytes to generate deterministic positions
    for i in 0..<targetDotCount {
        let byteIndex = i % hashBytes.count
        let hashByte = hashBytes[byteIndex]
        
        // Convert byte to angle (0 to 2π)
        let angle = Double(hashByte) / 255.0 * 2 * .pi
        
        // Create spiral pattern with increasing radius
        let progress = Double(i) / Double(targetDotCount - 1)
        let radius = Double(minRadius) + (Double(maxRadius) - Double(minRadius)) * progress
        
        // Add some variation using adjacent hash bytes
        let variationByte = hashBytes[(byteIndex + 1) % hashBytes.count]
        let variation = (Double(variationByte) / 255.0 - 0.5) * 2.0 // -1 to 1
        let finalRadius = radius + variation * 2.0
        
        // Calculate position
        let x = cos(angle) * finalRadius
        let y = sin(angle) * finalRadius
        
        // Only add dots that fit within the circle
        if sqrt(x*x + y*y) <= Double(maxRadius) {
            dots.append(DotPosition(x: CGFloat(x), y: CGFloat(y)))
        }
    }
    
    return dots
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        CircularCodeView(url: "https://tekiyo.fr/3A1B-7E21")
            .frame(width: 120, height: 120)
        
        Text("Ce code QR prouve ton humanité.")
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(.primary)
            .opacity(0.7)
    }
    .padding()
}
