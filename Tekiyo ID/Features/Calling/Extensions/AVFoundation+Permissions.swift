import Foundation
import AVFoundation
import Combine

// MARK: - Permission Status
enum PermissionStatus {
    case granted
    case denied
    case notDetermined
}

// MARK: - AVFoundation Permissions Manager
@MainActor
final class AVFoundationPermissionsManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var microphonePermission: PermissionStatus = .notDetermined
    @Published var cameraPermission: PermissionStatus = .notDetermined
    
    // MARK: - Initialization
    init() {
        checkPermissions()
    }
    
    // MARK: - Permission Checking
    func checkPermissions() {
        microphonePermission = getMicrophonePermissionStatus()
        cameraPermission = getCameraPermissionStatus()
    }
    
    private func getMicrophonePermissionStatus() -> PermissionStatus {
        let status = AVAudioSession.sharedInstance().recordPermission
        switch status {
        case .granted:
            return .granted
        case .denied:
            return .denied
        case .undetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    
    private func getCameraPermissionStatus() -> PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return .granted
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    
    // MARK: - Permission Requesting
    func requestMicrophonePermission() async -> PermissionStatus {
        let granted = await AVAudioSession.sharedInstance().requestRecordPermission()
        let status: PermissionStatus = granted ? .granted : .denied
        
        await MainActor.run {
            self.microphonePermission = status
        }
        
        return status
    }
    
    func requestCameraPermission() async -> PermissionStatus {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        let status: PermissionStatus = granted ? .granted : .denied
        
        await MainActor.run {
            self.cameraPermission = status
        }
        
        return status
    }
    
    // MARK: - Permission Validation
    func hasRequiredPermissions(for callType: CallType) -> Bool {
        let hasMic = microphonePermission == .granted
        let hasCamera = callType == .audio ? true : cameraPermission == .granted
        
        return hasMic && hasCamera
    }
    
    func getMissingPermissions(for callType: CallType) -> [String] {
        var missing: [String] = []
        
        if microphonePermission != .granted {
            missing.append("Microphone")
        }
        
        if callType == .video && cameraPermission != .granted {
            missing.append("Camera")
        }
        
        return missing
    }
}

// MARK: - Permission Request View
struct PermissionRequestView: View {
    let callType: CallType
    let onPermissionGranted: () -> Void
    let onPermissionDenied: () -> Void
    
    @StateObject private var permissionsManager = AVFoundationPermissionsManager()
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: callType == .video ? "video.fill" : "mic.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            // Title
            Text("Permission requise")
                .font(.custom("SF Pro Display", size: 24))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Description
            Text("Tekiyo ID a besoin d'accéder à votre \(callType == .video ? "caméra et microphone" : "microphone") pour les appels \(callType == .video ? "vidéo" : "audio").")
                .font(.custom("SF Pro Display", size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Permission status
            VStack(spacing: 12) {
                PermissionStatusRow(
                    icon: "mic.fill",
                    title: "Microphone",
                    status: permissionsManager.microphonePermission
                )
                
                if callType == .video {
                    PermissionStatusRow(
                        icon: "video.fill",
                        title: "Caméra",
                        status: permissionsManager.cameraPermission
                    )
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button("Autoriser") {
                    requestPermissions()
                }
                .font(.custom("SF Pro Display", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.blue)
                )
                .disabled(isRequesting)
                
                Button("Annuler") {
                    onPermissionDenied()
                }
                .font(.custom("SF Pro Display", size: 16))
                .foregroundColor(.secondary)
                .disabled(isRequesting)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 20)
        .background(Color(.systemBackground).ignoresSafeArea())
        .onAppear {
            permissionsManager.checkPermissions()
        }
    }
    
    private func requestPermissions() {
        isRequesting = true
        
        Task {
            // Request microphone permission
            let micStatus = await permissionsManager.requestMicrophonePermission()
            
            // Request camera permission for video calls
            let cameraStatus: PermissionStatus
            if callType == .video {
                cameraStatus = await permissionsManager.requestCameraPermission()
            } else {
                cameraStatus = .granted
            }
            
            await MainActor.run {
                isRequesting = false
                
                if micStatus == .granted && cameraStatus == .granted {
                    onPermissionGranted()
                } else {
                    onPermissionDenied()
                }
            }
        }
    }
}

// MARK: - Permission Status Row
struct PermissionStatusRow: View {
    let icon: String
    let title: String
    let status: PermissionStatus
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.custom("SF Pro Display", size: 16))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: statusIcon)
                .font(.system(size: 16))
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 50)
                .fill(Color(.systemGray6))
        )
    }
    
    private var statusIcon: String {
        switch status {
        case .granted:
            return "checkmark.circle.fill"
        case .denied:
            return "xmark.circle.fill"
        case .notDetermined:
            return "questionmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .granted:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        }
    }
}
