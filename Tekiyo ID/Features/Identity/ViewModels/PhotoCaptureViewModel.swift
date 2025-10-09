import Foundation
import Combine
import AVFoundation

@MainActor
final class PhotoCaptureViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    
    func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionStatus = .authorized
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.cameraPermissionStatus = granted ? .authorized : .denied
                }
            }
        case .denied, .restricted:
            cameraPermissionStatus = .denied
        @unknown default:
            cameraPermissionStatus = .denied
        }
    }
    
    func canAccessCamera() -> Bool {
        cameraPermissionStatus == .authorized
    }
}
