import AVFoundation
import Vision
import UIKit

struct FaceDetectionResult {
    let isValid: Bool
    let boundingBox: CGRect // En coordonnées Vision (0-1)
    let message: String?
}

@MainActor
final class RealtimeFaceDetector: NSObject, ObservableObject {
    @Published var detectionResult: FaceDetectionResult?
    @Published var isDetecting = false
    
    private var captureSession: AVCaptureSession?
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
    private var lastDetectionTime: Date = .distantPast
    private let detectionInterval: TimeInterval = 0.3 // Détection toutes les 300ms
    
    func startDetecting(session: AVCaptureSession) {
        guard !isDetecting else { return }
        
        self.captureSession = session
        
        // Configurer la sortie vidéo pour l'analyse
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            isDetecting = true
            print("✅ RealtimeFaceDetector: Started detecting")
        }
    }
    
    func stopDetecting() {
        guard isDetecting else { return }
        
        captureSession?.removeOutput(videoDataOutput)
        captureSession = nil
        isDetecting = false
        
        Task { @MainActor in
            detectionResult = nil
        }
        
        print("🛑 RealtimeFaceDetector: Stopped detecting")
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension RealtimeFaceDetector: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Limiter la fréquence de détection
        let now = Date()
        guard now.timeIntervalSince(lastDetectionTime) >= detectionInterval else { return }
        lastDetectionTime = now
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ RealtimeFaceDetector: Error: \(error.localizedDescription)")
                return
            }
            
            guard let observations = request.results as? [VNFaceObservation] else { return }
            
            self.processDetection(observations)
        }
        
        request.revision = VNDetectFaceRectanglesRequestRevision3
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("❌ RealtimeFaceDetector: Failed to perform detection: \(error.localizedDescription)")
        }
    }
    
    private func processDetection(_ observations: [VNFaceObservation]) {
        Task { @MainActor in
            // Aucun visage
            if observations.isEmpty {
                detectionResult = FaceDetectionResult(
                    isValid: false,
                    boundingBox: .zero,
                    message: "Positionnez votre visage"
                )
                return
            }
            
            // Plusieurs visages
            if observations.count > 1 {
                detectionResult = FaceDetectionResult(
                    isValid: false,
                    boundingBox: observations[0].boundingBox,
                    message: "Une seule personne"
                )
                return
            }
            
            // Un seul visage - valider
            let face = observations[0]
            let validation = validateFace(face)
            
            detectionResult = FaceDetectionResult(
                isValid: validation.isValid,
                boundingBox: face.boundingBox,
                message: validation.message
            )
        }
    }
    
    private func validateFace(_ face: VNFaceObservation) -> (isValid: Bool, message: String?) {
        // 1. Taille
        let faceArea = face.boundingBox.width * face.boundingBox.height
        if faceArea < 0.08 {
            return (false, "Rapprochez-vous")
        }
        
        // 2. Centrage
        let faceCenterX = face.boundingBox.midX
        let faceCenterY = face.boundingBox.midY
        
        if faceCenterX < 0.2 || faceCenterX > 0.8 {
            if faceCenterX < 0.5 {
                return (false, "← Déplacez à droite")
            } else {
                return (false, "Déplacez à gauche →")
            }
        }
        
        if faceCenterY < 0.2 || faceCenterY > 0.8 {
            if faceCenterY < 0.5 {
                return (false, "↑ Montez le téléphone")
            } else {
                return (false, "Baissez le téléphone ↓")
            }
        }
        
        // 3. Angle horizontal (yaw)
        if let yaw = face.yaw?.doubleValue {
            let yawDegrees = abs(yaw * 180 / .pi)
            if yawDegrees > 30 {
                if yaw > 0 {
                    return (false, "← Tournez à gauche")
                } else {
                    return (false, "Tournez à droite →")
                }
            }
        }
        
        // 4. Angle vertical (pitch)
        if let pitch = face.pitch?.doubleValue {
            let pitchDegrees = abs(pitch * 180 / .pi)
            if pitchDegrees > 35 {
                if pitch > 0 {
                    return (false, "↑ Levez la tête")
                } else {
                    return (false, "Baissez la tête ↓")
                }
            }
        }
        
        // Tout est OK !
        return (true, "✓ Parfait !")
    }
}

