import AVFoundation
import UIKit
import Combine

@MainActor
final class CameraManager: ObservableObject {
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isSessionRunning = false
    @Published var errorMessage: String?
    
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var captureDelegate: PhotoCaptureDelegate?
    
    private var isConfigured = false
    
    func setupCamera() {
        print("🎥 CameraManager: setupCamera called")
        
        guard !isConfigured else {
            print("🎥 CameraManager: Already configured, starting session")
            startSessionIfNeeded()
            return
        }
        
        Task { @MainActor in
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                print("❌ CameraManager: No front camera available")
                errorMessage = "Caméra frontale non disponible"
                return
            }
            print("✅ CameraManager: Front camera found")
            
            session.beginConfiguration()
            session.sessionPreset = .photo
            
            do {
                // Remove existing inputs
                session.inputs.forEach { session.removeInput($0) }
                session.outputs.forEach { session.removeOutput($0) }
                
                // Add input
                let input = try AVCaptureDeviceInput(device: device)
                guard session.canAddInput(input) else {
                    print("❌ CameraManager: Cannot add input")
                    errorMessage = "Impossible d'ajouter l'entrée caméra"
                    return
                }
                session.addInput(input)
                print("✅ CameraManager: Input added")
                
                // Add output
                guard session.canAddOutput(photoOutput) else {
                    print("❌ CameraManager: Cannot add output")
                    errorMessage = "Impossible d'ajouter la sortie photo"
                    return
                }
                session.addOutput(photoOutput)
                print("✅ CameraManager: Output added")
                
                // Configure frame rate
                try? configureFrameRate(for: device)
                
                // Configure video data output for real-time processing
                videoDataOutput.alwaysDiscardsLateVideoFrames = true
                videoDataOutput.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
                ]
                
                if session.canAddOutput(videoDataOutput) {
                    session.addOutput(videoDataOutput)
                    
                    if let connection = videoDataOutput.connection(with: .video) {
                        if connection.isVideoOrientationSupported {
                            connection.videoOrientation = .portrait
                        }
                        if connection.isVideoMirroringSupported {
                            connection.automaticallyAdjustsVideoMirroring = false
                            connection.isVideoMirrored = true
                        }
                    }
                } else {
                    print("❌ CameraManager: Cannot add video output")
                }
                
                // Create preview layer
                let layer = AVCaptureVideoPreviewLayer(session: session)
                layer.videoGravity = .resizeAspectFill
                layer.connection?.videoOrientation = .portrait
                if layer.connection?.isVideoMirroringSupported == true {
                    layer.connection?.automaticallyAdjustsVideoMirroring = false
                    layer.connection?.isVideoMirrored = true
                }
                self.previewLayer = layer
                print("✅ CameraManager: Preview layer created")
                
                session.commitConfiguration()
                isConfigured = true
                
                // Start session
                startSessionIfNeeded()
                
            } catch {
                print("❌ CameraManager: Setup error: \(error.localizedDescription)")
                errorMessage = "Erreur de configuration: \(error.localizedDescription)"
                session.commitConfiguration()
            }
        }
    }
    
    private func configureFrameRate(for device: AVCaptureDevice) throws {
        let targetFrameRate: Double = 30
        guard device.activeFormat.videoSupportedFrameRateRanges.contains(where: { $0.minFrameRate <= targetFrameRate && targetFrameRate <= $0.maxFrameRate }) else {
            return
        }
        
        try device.lockForConfiguration()
        let timescale = CMTimeScale(Int32(targetFrameRate))
        let frameDuration = CMTime(value: 1, timescale: timescale)
        device.activeVideoMinFrameDuration = frameDuration
        device.activeVideoMaxFrameDuration = frameDuration
        device.unlockForConfiguration()
    }
    
    func startSessionIfNeeded() {
        guard !session.isRunning else {
            print("🎥 CameraManager: Session already running")
            return
        }
        
        print("🎥 CameraManager: Starting session...")
        let sessionToStart = session
        Task.detached(priority: .userInitiated) { [weak self] in
            sessionToStart.startRunning()
            await MainActor.run { [weak self] in
                self?.isSessionRunning = true
                print("✅ CameraManager: Session started successfully")
            }
        }
    }
    
    func stopSession() {
        guard session.isRunning else {
            print("🎥 CameraManager: Session already stopped")
            return
        }
        
        print("🎥 CameraManager: Stopping session...")
        let sessionToStop = session
        Task.detached(priority: .userInitiated) { [weak self] in
            sessionToStop.stopRunning()
            await MainActor.run { [weak self] in
                self?.isSessionRunning = false
                print("✅ CameraManager: Session stopped")
            }
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        print("📸 CameraManager: capturePhoto called")
        
        guard isSessionRunning else {
            print("⚠️ CameraManager: Session not running, starting...")
            startSessionIfNeeded()
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                self.capturePhoto(completion: completion)
            }
            return
        }
        
        guard isConfigured else {
            print("❌ CameraManager: Camera not configured")
            completion(nil)
            return
        }
        
        print("📸 CameraManager: Capturing photo...")
        let settings = AVCapturePhotoSettings()
        
        // IMPORTANT: Retain the delegate strongly
        self.captureDelegate = PhotoCaptureDelegate { [weak self] image in
            Task { @MainActor in
                print("📸 CameraManager: Photo captured: \(image != nil ? "✅ Success" : "❌ Failed")")
                completion(image)
                self?.captureDelegate = nil // Release delegate after use
            }
        }
        
        photoOutput.capturePhoto(with: settings, delegate: captureDelegate!)
    }
    
    func setVideoDataOutputDelegate(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate?, queue: DispatchQueue?) {
        if let delegate = delegate, let queue = queue {
            videoDataOutput.setSampleBufferDelegate(delegate, queue: queue)
        } else {
            videoDataOutput.setSampleBufferDelegate(nil, queue: nil)
        }
        
        if let connection = videoDataOutput.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true
            }
        }
    }
    
    var captureSession: AVCaptureSession {
        session
    }
}

// MARK: - Photo Capture Delegate
private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        super.init()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("❌ PhotoCaptureDelegate: Error: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("❌ PhotoCaptureDelegate: No image data")
            completion(nil)
            return
        }
        
        guard let image = UIImage(data: imageData) else {
            print("❌ PhotoCaptureDelegate: Cannot create UIImage")
            completion(nil)
            return
        }
        
        print("✅ PhotoCaptureDelegate: Image created successfully")
        completion(image)
    }
}
