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
            
            // Dots pattern - using Canvas for better performance
            Canvas { context, size in
                let centerX = size.width / 2
                let centerY = size.height / 2
                
                for dot in dots {
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
            .opacity(animationOpacity)
            .scaleEffect(animationScale)
            
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
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
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
    
    let maxRadius = (size / 2) - 12 // Leave margin for border
    let minRadius: CGFloat = 18 // Start from center area
    
    var dots: [DotPosition] = []
    let targetDotCount = 120 // Slightly more dots for better coverage
    
    // Use hash bytes to generate deterministic positions
    for i in 0..<targetDotCount {
        let byteIndex = i % hashBytes.count
        let hashByte = hashBytes[byteIndex]
        let nextByte = hashBytes[(byteIndex + 1) % hashBytes.count]
        
        // Convert byte to angle (0 to 2π)
        let angle = Double(hashByte) / 255.0 * 2 * .pi
        
        // Create spiral pattern with increasing radius
        let progress = Double(i) / Double(targetDotCount - 1)
        let baseRadius = Double(minRadius) + (Double(maxRadius) - Double(minRadius)) * progress
        
        // Add variation using next hash byte
        let variation = (Double(nextByte) / 255.0 - 0.5) * 3.0 // -1.5 to 1.5
        let finalRadius = max(Double(minRadius), min(Double(maxRadius), baseRadius + variation))
        
        // Calculate position
        let x = cos(angle) * finalRadius
        let y = sin(angle) * finalRadius
        
        // Only add dots that fit within the circle
        let distance = sqrt(x*x + y*y)
        if distance <= Double(maxRadius) && distance >= Double(minRadius - 2) {
            dots.append(DotPosition(x: CGFloat(x), y: CGFloat(y)))
        }
    }
    
    // If we don't have enough dots, add some random ones based on hash
    while dots.count < 80 {
        let seed = hashBytes[dots.count % hashBytes.count]
        let angle = Double(seed) / 255.0 * 2 * .pi
        let radius = Double(minRadius + 5) + Double(dots.count % 20) * 2.0
        
        let x = cos(angle) * radius
        let y = sin(angle) * radius
        
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
