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
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published private(set) var isSessionRunning = false
    @Published var validationError: String?
    @Published var isValidating = false
    @Published var faceDetectionResult: FaceDetectionResult?
    
    let identityData: IdentityData?
    
    private let cameraManager = CameraManager()
    private let photoValidator = PhotoValidator.shared
    private let faceDetector = RealtimeFaceDetector()
    private var isCameraConfigured = false
    private var cancellables = Set<AnyCancellable>()
    
    init(identityData: IdentityData? = nil) {
        self.identityData = identityData
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        // Observer le statut de la session caméra
        cameraManager.$isSessionRunning
            .receive(on: RunLoop.main)
            .sink { [weak self] running in
                guard let self = self else { return }
                self.isSessionRunning = running
                
                // Démarrer/arrêter la détection en temps réel
                if running {
                    self.faceDetector.startDetecting(with: self.cameraManager)
                } else {
                    self.faceDetector.stopDetecting()
                }
            }
            .store(in: &cancellables)
        
        // Observer les résultats de détection
        faceDetector.$detectionResult
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                self?.faceDetectionResult = result
            }
            .store(in: &cancellables)
    }
    var cameraPermissionMessage: String {
        switch cameraPermissionStatus {
        case .notDetermined:
            return "L'accès à la caméra n'a pas encore été autorisé. Appuyez sur le bouton ci-dessous pour autoriser."
        case .denied:
            return "L'accès à la caméra a été refusé. Veuillez l'activer dans les Réglages de votre iPhone."
        case .restricted:
            return "L'accès à la caméra est restreint sur cet appareil."
        case .authorized:
            return "Caméra autorisée"
        @unknown default:
            return "Statut de la caméra inconnu"
        }
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
        print("📱 PhotoCaptureViewModel: setupCamera called")
        guard !isCameraConfigured else {
            print("📱 PhotoCaptureViewModel: Already configured, starting session")
            cameraManager.startSessionIfNeeded()
            return
        }
        print("📱 PhotoCaptureViewModel: Setting up camera...")
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
            
            guard let image = image else {
                self.validationError = "Échec de la capture photo"
                return
            }
            
            // Valider la photo
            self.validateCapturedPhoto(image)
        }
    }
    
    private func validateCapturedPhoto(_ image: UIImage) {
        print("🔍 PhotoCaptureViewModel: Starting photo validation...")
        isValidating = true
        validationError = nil
        
        Task {
            let result = await photoValidator.validatePhoto(image)
            
            await MainActor.run {
                isValidating = false
                
                if result.isValid {
                    print("✅ PhotoCaptureViewModel: Photo is valid!")
                    self.capturedImage = image
                    HapticManager.shared.success()
                } else {
                    print("❌ PhotoCaptureViewModel: Photo is invalid")
                    self.validationError = result.errorMessage
                    HapticManager.shared.error()
                    
                    // Redémarrer la caméra pour reprendre une photo
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.validationError = nil
                        self.cameraManager.startSessionIfNeeded()
                    }
                }
            }
        }
    }
    
    @MainActor func stopCameraSession() {
        faceDetector.stopDetecting()
        cameraManager.stopSession()
    }
    
    deinit {
        // Cleanup synchrone pour éviter les captures de self
        Task { [faceDetector] in
            await MainActor.run {
                faceDetector.stopDetecting()
            }
        }
    }
    
    func proceedToFingerprintCreation() {
        shouldNavigateToFingerprintCreation = true
    }
}
