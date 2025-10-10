import Foundation
import Combine
import AVFoundation
import UIKit

@MainActor
final class PhotoCaptureViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var shouldNavigateToFingerprintCreation = false
    
    let identityData: IdentityData?
    
    private let cameraManager = CameraManager()
    
    init(identityData: IdentityData? = nil) {
        self.identityData = identityData
    }
    
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
        print("CapturePhoto called - Camera permission: \(cameraPermissionStatus)")
        cameraManager.capturePhoto { [weak self] image in
            print("Photo captured: \(image != nil)")
            self?.capturedImage = image
        }
    }
    
    func stopCamera() {
        cameraManager.stopSession()
    }
    
    func canAccessCamera() -> Bool {
        cameraPermissionStatus == .authorized
    }
    
    func proceedToFingerprintCreation() {
        shouldNavigateToFingerprintCreation = true
    }
}
