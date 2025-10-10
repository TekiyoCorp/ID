import Foundation
import Combine
import AVFoundation
import UIKit

@MainActor
final class PhotoCaptureViewModel: ObservableObject {
    @Published var capturedImage: UIImage? {
        didSet {
            guard isCameraConfigured else { return }
            if capturedImage != nil {
                cameraManager.stopSession()
            } else if cameraPermissionStatus == .authorized {
                cameraManager.startSessionIfNeeded()
            }
        }
    }
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
@Published var shouldNavigateToFingerprintCreation = false
    
    let identityData: IdentityData?
    
    private let cameraManager = CameraManager()
    private var isCameraConfigured = false
    
    init(identityData: IdentityData? = nil) {
        self.identityData = identityData
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        cameraManager.previewLayer
    }
    
    func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        print("PhotoCaptureViewModel: Camera permission status: \(status.rawValue)")
        
        switch status {
        case .authorized:
            cameraPermissionStatus = .authorized
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    print("PhotoCaptureViewModel: Camera permission request result: \(granted)")
                    self?.cameraPermissionStatus = granted ? .authorized : .denied
                    if granted {
                        self?.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            cameraPermissionStatus = .denied
            print("PhotoCaptureViewModel: Camera access denied or restricted")
        @unknown default:
            cameraPermissionStatus = .denied
            print("PhotoCaptureViewModel: Camera access unknown status")
        }
    }
    
    func setupCamera() {
        guard !isCameraConfigured else {
            cameraManager.startSessionIfNeeded()
            return
        }
        cameraManager.setupCamera()
        isCameraConfigured = true
    }
    
    func resumeCameraIfNeeded() {
        guard cameraPermissionStatus == .authorized else { return }
        setupCamera()
    }
    
    func handleCaptureCircleTap() {
        guard cameraPermissionStatus == .authorized else {
            requestCameraPermission()
            return
        }
        
        if capturedImage != nil {
            capturedImage = nil
            cameraManager.startSessionIfNeeded()
        } else {
            capturePhoto()
        }
    }
    
    func handlePrimaryButtonTap() {
        if capturedImage != nil {
            proceedToFingerprintCreation()
        } else {
            handleCaptureCircleTap()
        }
    }
    
    private func capturePhoto() {
        print("PhotoCaptureViewModel: capturePhoto called")
        cameraManager.startSessionIfNeeded()
        cameraManager.capturePhoto { [weak self] image in
            guard let self = self else { return }
            print("PhotoCaptureViewModel: Photo captured callback received: \(image != nil ? "Success" : "Failed")")
            self.capturedImage = image
        }
    }
    
    func stopCameraSession() {
        cameraManager.stopSession()
    }
    
    func canAccessCamera() -> Bool {
        cameraPermissionStatus == .authorized
    }
    
    func proceedToFingerprintCreation() {
        shouldNavigateToFingerprintCreation = true
    }
}
