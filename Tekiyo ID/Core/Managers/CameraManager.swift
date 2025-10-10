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
            completion(nil)
            return
        }
        completion(image)
    }
}

final class CameraManager: ObservableObject {
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isSessionRunning = false
    
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("CameraManager: No front camera available")
            return
        }
        print("CameraManager: Setting up front camera")
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            self.previewLayer = previewLayer
            
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    func startSession() {
        print("CameraManager: Starting session")
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = true
                print("CameraManager: Session started - \(self?.isSessionRunning ?? false)")
            }
        }
    }
    
    func stopSession() {
        session.stopRunning()
        isSessionRunning = false
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let settings = AVCapturePhotoSettings()
        let delegate = PhotoCaptureDelegate { image in
            DispatchQueue.main.async {
                completion(image)
            }
        }
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
}
