import SwiftUI

struct FaceDetectionOverlay: View {
    let detectionResult: FaceDetectionResult?
    let frameSize: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let result = detectionResult {
                    // Convertir les coordonnées Vision (0-1, origine bottom-left) en SwiftUI (pixels, origine top-left)
                    let rect = convertVisionRectToSwiftUI(result.boundingBox, in: geometry.size)
                    
                    // Rectangle autour du visage
                    Rectangle()
                        .stroke(result.isValid ? Color.green : Color.orange, lineWidth: 3)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
                        .animation(.easeInOut(duration: 0.2), value: result.isValid)
                    
                    // Message en haut du rectangle
                    if let message = result.message {
                        Text(message)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(result.isValid ? Color.green : Color.orange)
                            )
                            .position(x: rect.midX, y: rect.minY - 20)
                            .animation(.easeInOut(duration: 0.2), value: message)
                    }
                }
            }
        }
    }
    
    private func convertVisionRectToSwiftUI(_ visionRect: CGRect, in size: CGSize) -> CGRect {
        // Vision: origine en bas à gauche, coordonnées 0-1
        // SwiftUI: origine en haut à gauche, coordonnées en pixels
        
        let x = visionRect.origin.x * size.width
        let y = (1 - visionRect.origin.y - visionRect.height) * size.height
        let width = visionRect.width * size.width
        let height = visionRect.height * size.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

