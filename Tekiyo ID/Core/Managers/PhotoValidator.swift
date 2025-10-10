import Vision
import UIKit
import CoreImage

struct PhotoValidationResult {
    let isValid: Bool
    let errors: [PhotoValidationError]
    
    var errorMessage: String? {
        guard !errors.isEmpty else { return nil }
        return errors.map { $0.localizedDescription }.joined(separator: "\n")
    }
}

enum PhotoValidationError: Error {
    case noFaceDetected
    case multipleFacesDetected
    case faceNotFrontFacing
    case faceTooSmall
    case poorLighting
    case eyesClosed
    case wearingSunglasses
    case faceNotCentered
    case blurryImage
    
    var localizedDescription: String {
        switch self {
        case .noFaceDetected:
            return "❌ Aucun visage détecté"
        case .multipleFacesDetected:
            return "❌ Plusieurs visages détectés. Une seule personne doit apparaître"
        case .faceNotFrontFacing:
            return "❌ Regardez droit devant la caméra"
        case .faceTooSmall:
            return "❌ Visage trop petit. Rapprochez-vous"
        case .poorLighting:
            return "❌ Luminosité insuffisante. Trouvez un meilleur éclairage"
        case .eyesClosed:
            return "❌ Ouvrez les yeux"
        case .wearingSunglasses:
            return "❌ Retirez vos lunettes de soleil"
        case .faceNotCentered:
            return "❌ Centrez votre visage dans le cercle"
        case .blurryImage:
            return "❌ Image floue. Tenez l'appareil stable"
        }
    }
}

@MainActor
final class PhotoValidator {
    
    static let shared = PhotoValidator()
    
    private init() {}
    
    /// Valide une photo pour un usage administratif
    func validatePhoto(_ image: UIImage) async -> PhotoValidationResult {
        print("🔍 PhotoValidator: Starting validation...")
        
        guard let cgImage = image.cgImage else {
            print("❌ PhotoValidator: Cannot get CGImage")
            return PhotoValidationResult(isValid: false, errors: [.noFaceDetected])
        }
        
        var errors: [PhotoValidationError] = []
        
        // 1. Vérifier la luminosité
        if !checkBrightness(image: cgImage) {
            errors.append(.poorLighting)
        }
        
        // 2. Vérifier le flou
        if !checkSharpness(image: cgImage) {
            errors.append(.blurryImage)
        }
        
        // 3. Détecter et valider le visage
        let faceErrors = await validateFace(cgImage: cgImage)
        errors.append(contentsOf: faceErrors)
        
        let isValid = errors.isEmpty
        print(isValid ? "✅ PhotoValidator: Photo is valid" : "❌ PhotoValidator: Photo is invalid - \(errors.count) errors")
        
        return PhotoValidationResult(isValid: isValid, errors: errors)
    }
    
    // MARK: - Face Validation
    
    private func validateFace(cgImage: CGImage) async -> [PhotoValidationError] {
        return await withCheckedContinuation { continuation in
            var errors: [PhotoValidationError] = []
            
            let request = VNDetectFaceRectanglesRequest { request, error in
                if let error = error {
                    print("❌ PhotoValidator: Face detection error: \(error.localizedDescription)")
                    errors.append(.noFaceDetected)
                    continuation.resume(returning: errors)
                    return
                }
                
                guard let observations = request.results as? [VNFaceObservation] else {
                    print("❌ PhotoValidator: No face observations")
                    errors.append(.noFaceDetected)
                    continuation.resume(returning: errors)
                    return
                }
                
                // Vérifier le nombre de visages
                print("🔍 PhotoValidator: Detected \(observations.count) face(s)")
                
                if observations.isEmpty {
                    errors.append(.noFaceDetected)
                    continuation.resume(returning: errors)
                    return
                }
                
                if observations.count > 1 {
                    errors.append(.multipleFacesDetected)
                    continuation.resume(returning: errors)
                    return
                }
                
                // Analyser le visage unique
                let face = observations[0]
                errors.append(contentsOf: self.analyzeFace(face, imageSize: CGSize(width: cgImage.width, height: cgImage.height)))
                
                continuation.resume(returning: errors)
            }
            
            // Activer la détection de landmarks pour plus de détails
            request.revision = VNDetectFaceRectanglesRequestRevision3
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                print("❌ PhotoValidator: Failed to perform face detection: \(error.localizedDescription)")
                errors.append(.noFaceDetected)
                continuation.resume(returning: errors)
            }
        }
    }
    
    private func analyzeFace(_ face: VNFaceObservation, imageSize: CGSize) -> [PhotoValidationError] {
        var errors: [PhotoValidationError] = []
        
        // 1. Vérifier la taille du visage (doit occuper au moins 30% de l'image)
        let faceArea = face.boundingBox.width * face.boundingBox.height
        print("🔍 PhotoValidator: Face area: \(faceArea * 100)%")
        
        if faceArea < 0.15 { // 15% minimum
            errors.append(.faceTooSmall)
        }
        
        // 2. Vérifier le centrage (visage doit être au centre)
        let faceCenterX = face.boundingBox.midX
        let faceCenterY = face.boundingBox.midY
        print("🔍 PhotoValidator: Face center: x=\(faceCenterX), y=\(faceCenterY)")
        
        // Le visage doit être dans le tiers central horizontal et vertical
        if faceCenterX < 0.3 || faceCenterX > 0.7 || faceCenterY < 0.3 || faceCenterY > 0.7 {
            errors.append(.faceNotCentered)
        }
        
        // 3. Vérifier l'angle (yaw = rotation horizontale)
        if let yaw = face.yaw?.doubleValue {
            print("🔍 PhotoValidator: Face yaw: \(yaw)")
            // Yaw doit être proche de 0 (entre -15° et +15°)
            if abs(yaw) > 0.26 { // ~15 degrés en radians
                errors.append(.faceNotFrontFacing)
            }
        }
        
        // 4. Vérifier pitch (inclinaison tête)
        if let pitch = face.pitch?.doubleValue {
            print("🔍 PhotoValidator: Face pitch: \(pitch)")
            if abs(pitch) > 0.35 { // ~20 degrés
                errors.append(.faceNotFrontFacing)
            }
        }
        
        return errors
    }
    
    // MARK: - Brightness Check
    
    private func checkBrightness(image: CGImage) -> Bool {
        let ciImage = CIImage(cgImage: image)
        
        let extentVector = CIVector(x: ciImage.extent.origin.x,
                                     y: ciImage.extent.origin.y,
                                     z: ciImage.extent.size.width,
                                     w: ciImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage",
                                     parameters: [kCIInputImageKey: ciImage,
                                                 kCIInputExtentKey: extentVector]) else {
            return true // Si on ne peut pas vérifier, on considère OK
        }
        
        guard let outputImage = filter.outputImage else { return true }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage,
                      toBitmap: &bitmap,
                      rowBytes: 4,
                      bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                      format: .RGBA8,
                      colorSpace: nil)
        
        // Calculer la luminosité moyenne (0-255)
        let brightness = (Int(bitmap[0]) + Int(bitmap[1]) + Int(bitmap[2])) / 3
        print("🔍 PhotoValidator: Brightness: \(brightness)/255")
        
        // Luminosité minimale : 60/255 (assez sombre mais acceptable)
        return brightness >= 60
    }
    
    // MARK: - Sharpness Check (Laplacian variance)
    
    private func checkSharpness(image: CGImage) -> Bool {
        guard let ciImage = CIImage(image: UIImage(cgImage: image)) else { return true }
        
        // Convertir en niveaux de gris
        guard let grayFilter = CIFilter(name: "CIPhotoEffectMono") else { return true }
        grayFilter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let grayImage = grayFilter.outputImage else { return true }
        
        // Appliquer un filtre de détection de contours
        guard let edgeFilter = CIFilter(name: "CIEdges") else { return true }
        edgeFilter.setValue(grayImage, forKey: kCIInputImageKey)
        edgeFilter.setValue(1.0, forKey: kCIInputIntensityKey)
        guard let edgeImage = edgeFilter.outputImage else { return true }
        
        // Calculer la variance (mesure du flou)
        let extentVector = CIVector(x: edgeImage.extent.origin.x,
                                     y: edgeImage.extent.origin.y,
                                     z: edgeImage.extent.size.width,
                                     w: edgeImage.extent.size.height)
        
        guard let avgFilter = CIFilter(name: "CIAreaAverage",
                                       parameters: [kCIInputImageKey: edgeImage,
                                                   kCIInputExtentKey: extentVector]) else {
            return true
        }
        
        guard let outputImage = avgFilter.outputImage else { return true }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage,
                      toBitmap: &bitmap,
                      rowBytes: 4,
                      bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                      format: .RGBA8,
                      colorSpace: nil)
        
        let sharpness = Int(bitmap[0])
        print("🔍 PhotoValidator: Sharpness: \(sharpness)/255")
        
        // Seuil de netteté : 15/255 minimum
        return sharpness >= 15
    }
}

