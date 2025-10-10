import SwiftUI
import CryptoKit
import UIKit

struct OptimizedCircularCodeView: View {
    let url: String
    let size: CGFloat
    let dotRadius: CGFloat
    
    @State private var animationScale: CGFloat = 0.9
    @State private var animationOpacity: Double = 0.0
    @State private var didAnimate = false
    
    private static let imageCache = NSCache<NSString, UIImage>()
    private let renderedImage: UIImage
    
    init(url: String, size: CGFloat = 120, dotRadius: CGFloat = 2.5) {
        self.url = url
        self.size = size
        self.dotRadius = dotRadius
        
        let cacheKey = "\(url)|\(size)|\(dotRadius)" as NSString
        if let cachedImage = Self.imageCache.object(forKey: cacheKey) {
            self.renderedImage = cachedImage
        } else {
            let dots = Self.generateDots(from: url, size: size)
            let image = Self.renderImage(for: dots, size: size, dotRadius: dotRadius)
            Self.imageCache.setObject(image, forKey: cacheKey)
            self.renderedImage = image
        }
    }
    
    var body: some View {
        Image(uiImage: renderedImage)
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
            .debugRenders("OptimizedCircularCodeView")
    }
    
    private static func renderImage(for dots: [DotPosition], size: CGFloat, dotRadius: CGFloat) -> UIImage {
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = UIScreen.main.scale
        rendererFormat.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size), format: rendererFormat)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))
            let cgContext = context.cgContext
            
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.fillEllipse(in: rect)
            
            cgContext.setStrokeColor(UIColor.systemBlue.cgColor)
            cgContext.setLineWidth(2)
            cgContext.strokeEllipse(in: rect.insetBy(dx: 1, dy: 1))
            
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let dotDiameter = dotRadius * 2
            
            cgContext.setFillColor(UIColor.systemBlue.cgColor)
            for dot in dots {
                let dotRect = CGRect(
                    x: center.x + dot.x - dotRadius,
                    y: center.y + dot.y - dotRadius,
                    width: dotDiameter,
                    height: dotDiameter
                )
                cgContext.fillEllipse(in: dotRect)
            }
            
            cgContext.fillEllipse(in: CGRect(x: center.x - 6, y: center.y - 6, width: 12, height: 12))
            cgContext.setStrokeColor(UIColor.systemBlue.cgColor)
            cgContext.setLineWidth(1.5)
            cgContext.strokeEllipse(in: CGRect(x: center.x - 10, y: center.y - 10, width: 20, height: 20))
        }
    }
    
    private static func generateDots(from url: String, size: CGFloat) -> [DotPosition] {
        let data = Data(url.utf8)
        let hash = SHA256.hash(data: data)
        let hashBytes = Array(hash)
        
        let maxRadius = (size / 2) - 12
        let minRadius: CGFloat = 18
        
        var dots: [DotPosition] = []
        let targetDotCount = 80
        
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
        OptimizedCircularCodeView(url: "https://tekiyo.fr/3A1B-7E21")
            .frame(width: 120, height: 120)
        
        Text("Ce code QR prouve ton humanité.")
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(.primary)
            .opacity(0.7)
    }
    .padding()
}
