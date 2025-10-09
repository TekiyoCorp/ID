import Foundation
import Combine
import AVFoundation
import UIKit

@MainActor
final class PhotoCaptureViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    
    private let cameraManager = CameraManager()
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        cameraManager.previewLayer
    }
    
    func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionStatus = .authorized
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.cameraPermissionStatus = granted ? .authorized : .denied
                    if granted {
                        self?.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            cameraPermissionStatus = .denied
        @unknown default:
            cameraPermissionStatus = .denied
        }
    }
    
    func setupCamera() {
        cameraManager.setupCamera()
        cameraManager.startSession()
    }
    
    func capturePhoto() {
        cameraManager.capturePhoto { [weak self] image in
            self?.capturedImage = image
        }
    }
    
    func stopCamera() {
        cameraManager.stopSession()
    }
    
    func canAccessCamera() -> Bool {
        cameraPermissionStatus == .authorized
    }
}
