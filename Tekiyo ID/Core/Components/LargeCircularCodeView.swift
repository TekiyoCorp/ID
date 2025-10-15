import SwiftUI
import CryptoKit
import UIKit

struct LargeCircularCodeView: View {
    let url: String
    let size: CGFloat
    let dotSize: CGFloat
    
    @Environment(\.displayScale) private var displayScale
    @State private var animationScale: CGFloat = 0.9
    @State private var animationOpacity: Double = 0.0
    @State private var didAnimate = false
    
    private static let imageCache = NSCache<NSString, UIImage>()
    
    init(url: String, size: CGFloat = 194, dotSize: CGFloat = 9) {
        self.url = url
        self.size = size
        self.dotSize = dotSize
    }
    
    var body: some View {
        let image = Self.cachedImage(
            for: url,
            size: size,
            dotSize: dotSize,
            scale: max(displayScale, 1.0)
        )
        
        return Image(uiImage: image)
            .resizable()
            .interpolation(.high)
            .antialiased(true)
            .frame(width: size, height: size)
            .scaleEffect(animationScale)
            .opacity(animationOpacity)
            .onAppear {
                guard !didAnimate else { return }
                didAnimate = true
                
                animationScale = 0.9
                animationOpacity = 0.0
                
                withAnimation(.easeOut(duration: 0.6)) {
                    animationScale = 1.0
                    animationOpacity = 1.0
                }
            }
            .accessibilityHidden(true)
            .debugRenders("LargeCircularCodeView")
    }
    
    private static func cachedImage(for url: String, size: CGFloat, dotSize: CGFloat, scale: CGFloat) -> UIImage {
        let cacheKey = "\(url)|\(size)|\(dotSize)|\(scale)" as NSString
        
        if let cached = imageCache.object(forKey: cacheKey) {
            return cached
        }
        
        let dots = generateDots(from: url, size: size)
        let image = renderImage(for: dots, size: size, dotSize: dotSize, scale: scale)
        imageCache.setObject(image, forKey: cacheKey)
        return image
    }
    
    private static func renderImage(for dots: [DotPosition], size: CGFloat, dotSize: CGFloat, scale: CGFloat) -> UIImage {
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = scale
        rendererFormat.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size), format: rendererFormat)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))
            let cgContext = context.cgContext
            
            // Background circle (white)
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.fillEllipse(in: rect)
            
            // Border circle (blue)
            cgContext.setStrokeColor(UIColor.systemBlue.cgColor)
            cgContext.setLineWidth(2)
            cgContext.strokeEllipse(in: rect.insetBy(dx: 1, dy: 1))
            
            let center = CGPoint(x: rect.midX, y: rect.midY)
            
            // Render dots
            cgContext.setFillColor(UIColor.systemBlue.cgColor)
            for dot in dots {
                let dotRect = CGRect(
                    x: center.x + dot.x - dotSize/2,
                    y: center.y + dot.y - dotSize/2,
                    width: dotSize,
                    height: dotSize
                )
                cgContext.fillEllipse(in: dotRect)
            }
            
            // Center logo (larger for 194px size)
            cgContext.fillEllipse(in: CGRect(x: center.x - 8, y: center.y - 8, width: 16, height: 16))
            cgContext.setStrokeColor(UIColor.systemBlue.cgColor)
            cgContext.setLineWidth(2)
            cgContext.strokeEllipse(in: CGRect(x: center.x - 14, y: center.y - 14, width: 28, height: 28))
            
            // Add highlighted dot with white ring (visible in Figma image)
            if !dots.isEmpty {
                let highlightedDot = dots[dots.count / 2] // Middle dot as highlight
                let highlightRadius: CGFloat = 6
                
                // White ring around highlighted dot
                cgContext.setStrokeColor(UIColor.white.cgColor)
                cgContext.setLineWidth(2)
                cgContext.strokeEllipse(in: CGRect(
                    x: center.x + highlightedDot.x - highlightRadius,
                    y: center.y + highlightedDot.y - highlightRadius,
                    width: highlightRadius * 2,
                    height: highlightRadius * 2
                ))
            }
        }
    }
    
    private static func generateDots(from url: String, size: CGFloat) -> [DotPosition] {
        let data = Data(url.utf8)
        let hash = SHA256.hash(data: data)
        let hashBytes = Array(hash)
        
        let maxRadius = (size / 2) - 20 // Plus d'espace pour les gros dots
        let minRadius: CGFloat = 25
        
        var dots: [DotPosition] = []
        let targetDotCount = 60 // Moins de dots pour les gros points
        
        for i in 0..<targetDotCount {
            let byteIndex = i % hashBytes.count
            let hashByte = hashBytes[byteIndex]
            let nextByte = hashBytes[(byteIndex + 1) % hashBytes.count]
            
            let angle = Double(hashByte) / 255.0 * 2 * .pi
            let progress = Double(i) / Double(targetDotCount - 1)
            let baseRadius = Double(minRadius) + (Double(maxRadius) - Double(minRadius)) * progress
            
            let variation = (Double(nextByte) / 255.0 - 0.5) * 2.0
            let finalRadius = max(Double(minRadius), min(Double(maxRadius), baseRadius + variation))
            
            let x = cos(angle) * finalRadius
            let y = sin(angle) * finalRadius
            
            let distance = sqrt(x * x + y * y)
            if distance <= Double(maxRadius) && distance >= Double(minRadius - 2) {
                dots.append(DotPosition(x: CGFloat(x), y: CGFloat(y)))
            }
        }
        
        return dots
    }
}

private struct DotPosition {
    let x: CGFloat
    let y: CGFloat
}

#Preview {
    VStack(spacing: 20) {
        LargeCircularCodeView(url: "https://tekiyo.fr/3A1B-7E21")
            .frame(width: 194, height: 194)
        
        Text("Ce code QR prouve ton humanité.")
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(.primary)
            .opacity(0.7)
    }
    .padding()
}
