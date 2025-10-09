import AVFoundation
import UIKit

final class CameraManager: ObservableObject {
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isSessionRunning = false
    
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return
        }
        
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
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = true
            }
        }
    }
    
    func stopSession() {
        session.stopRunning()
        isSessionRunning = false
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings) { [weak self] photoSampleBuffer, _ in
            guard let photoSampleBuffer = photoSampleBuffer,
                  let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer),
                  let image = UIImage(data: imageData) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
