import UIKit
import CoreImage

final class QRCodeGenerator {
    static let shared = QRCodeGenerator()
    
    private init() {}
    
    func generateQRCode(from string: String, size: CGFloat, color: UIColor = .black) -> UIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Scale the image to desired size
        let scale = size / outputImage.extent.size.width
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        // Apply color filter
        let colorFilter = CIFilter.colorMonochrome()
        colorFilter.setValue(scaledImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(color: color), forKey: "inputColor")
        colorFilter.setValue(1.0, forKey: "inputIntensity")
        
        guard let coloredImage = colorFilter.outputImage,
              let cgImage = context.createCGImage(coloredImage, from: coloredImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    func generateCircularQRCode(from string: String, size: CGFloat, color: UIColor = .black) -> UIImage? {
        guard let qrImage = generateQRCode(from: string, size: size, color: color) else {
            return nil
        }
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))
            
            // Fill with white background
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: rect)
            
            // Draw QR code in circular mask
            context.cgContext.saveGState()
            context.cgContext.addEllipse(in: rect)
            context.cgContext.clip()
            
            qrImage.draw(in: rect)
            context.cgContext.restoreGState()
            
            // Add border
            context.cgContext.setStrokeColor(color.cgColor)
            context.cgContext.setLineWidth(2)
            context.cgContext.strokeEllipse(in: rect)
        }
    }
}
