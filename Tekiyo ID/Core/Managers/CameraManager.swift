import AVFoundation
import UIKit
import Combine

// MARK: - Photo Capture Delegate
private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            DispatchQueue.main.async { self.completion(nil) }
            return
        }
        DispatchQueue.main.async { self.completion(image) }
    }
}

final class CameraManager: ObservableObject {
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published private(set) var isSessionRunning = false
    
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "CameraManager.SessionQueue")
    private let photoOutput = AVCapturePhotoOutput()
    
    private var isConfigured = false
    
    func setupCamera() {
        guard !isConfigured else {
            startSessionIfNeeded()
            return
        }
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("CameraManager: No front camera available")
            return
        }
        print("CameraManager: Setting up front camera")
        
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            try configureFrameRate(for: device)
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            self.previewLayer = previewLayer
            
            isConfigured = true
        } catch {
            print("Error setting up camera: \(error)")
        }
        
        session.commitConfiguration()
        startSessionIfNeeded()
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
        sessionQueue.async { [weak self] in
            guard let self = self, !self.session.isRunning else { return }
            self.session.startRunning()
            DispatchQueue.main.async { self.isSessionRunning = true }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, self.session.isRunning else { return }
            self.session.stopRunning()
            DispatchQueue.main.async { self.isSessionRunning = false }
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let settings = AVCapturePhotoSettings()
        let delegate = PhotoCaptureDelegate { [weak self] image in
            completion(image)
            self?.stopSession()
        }
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
}
