import AVFoundation
import Vision
import UIKit
import Combine

struct FaceDetectionResult {
    let isValid: Bool
    let boundingBox: CGRect // En coordonnées Vision (0-1)
    let message: String?
}

final class RealtimeFaceDetector: NSObject, ObservableObject {
    
    @Published var detectionResult: FaceDetectionResult?
    @Published var isDetecting = false
    
    private weak var cameraManager: CameraManager?
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
    private let lastDetectionTimeLock = NSLock()
    private var _lastDetectionTime = Date.distantPast
    private let detectionInterval: TimeInterval = 0.3 // Détection toutes les 300ms
    
    nonisolated private var lastDetectionTime: Date {
        get {
            lastDetectionTimeLock.lock()
            defer { lastDetectionTimeLock.unlock() }
            return _lastDetectionTime
        }
        set {
            lastDetectionTimeLock.lock()
            _lastDetectionTime = newValue
            lastDetectionTimeLock.unlock()
        }
    }
    
    @MainActor
    func startDetecting(with manager: CameraManager) {
        guard !isDetecting else { return }
        
        cameraManager = manager
        manager.setVideoDataOutputDelegate(self, queue: videoDataOutputQueue)
        resetDetectionTimestamp()
        isDetecting = true
        
        print("✅ RealtimeFaceDetector: Started detecting")
    }
    
    @MainActor
    func stopDetecting() {
        guard isDetecting else { return }
        isDetecting = false
        
        cameraManager?.setVideoDataOutputDelegate(nil, queue: nil)
        cameraManager = nil
        resetDetectionTimestamp()
        detectionResult = nil
        
        print("🛑 RealtimeFaceDetector: Stopped detecting")
    }
    
    private func resetDetectionTimestamp() {
        lastDetectionTime = .distantPast
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension RealtimeFaceDetector: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
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
            
            Task { @MainActor [weak self] in
                self?.processDetection(observations)
            }
        }
        
        request.revision = VNDetectFaceRectanglesRequestRevision3
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("❌ RealtimeFaceDetector: Failed to perform detection: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func processDetection(_ observations: [VNFaceObservation]) {
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
