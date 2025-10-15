import Foundation
import Combine
import AVFoundation

@MainActor
final class CallManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var activeCall: Call?
    @Published var isCallActive = false
    @Published var callState: CallState = .idle
    @Published var connectionState: String = "Disconnected"
    
    // MARK: - Managers
    private let webRTCManager = WebRTCManager()
    private let callKitManager = CallKitManager()
    private let pushKitManager: PushKitManager
    
    // MARK: - Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        self.pushKitManager = PushKitManager(callKitManager: callKitManager)
        
        setupBindings()
        setupCallbacks()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Bind WebRTC state to CallManager
        webRTCManager.$callState
            .assign(to: &$callState)
        
        webRTCManager.$connectionState
            .map { state in
                switch state {
                case .new: return "Connecting"
                case .checking: return "Checking"
                case .connected: return "Connected"
                case .completed: return "Connected"
                case .failed: return "Failed"
                case .disconnected: return "Disconnected"
                case .closed: return "Closed"
                case .count: return "Unknown"
                @unknown default: return "Unknown"
                }
            }
            .assign(to: &$connectionState)
        
        // Bind CallKit state
        callKitManager.$activeCall
            .assign(to: &$activeCall)
        
        callKitManager.$isCallActive
            .assign(to: &$isCallActive)
    }
    
    private func setupCallbacks() {
        // CallKit callbacks
        callKitManager.onCallStarted = { [weak self] call in
            self?.handleCallStarted(call)
        }
        
        callKitManager.onCallAnswered = { [weak self] call in
            self?.handleCallAnswered(call)
        }
        
        callKitManager.onCallEnded = { [weak self] call in
            self?.handleCallEnded(call)
        }
        
        callKitManager.onCallRejected = { [weak self] call in
            self?.handleCallRejected(call)
        }
        
        // PushKit callbacks
        pushKitManager.onIncomingCall = { [weak self] call in
            self?.handleIncomingCall(call)
        }
        
        pushKitManager.onPushTokenReceived = { [weak self] token in
            self?.handlePushTokenReceived(token)
        }
    }
    
    // MARK: - Call Management
    func startCall(to callerID: String, callerName: String, type: CallType) {
        // Request permissions first
        Task {
            do {
                try await requestPermissions()
                
                // Create peer connection
                _ = webRTCManager.createPeerConnection()
                
                // Start WebRTC setup
                webRTCManager.startCall()
                
                // Start CallKit call
                callKitManager.startCall(to: callerID, callerName: callerName, type: type)
                
            } catch {
                print("Failed to start call: \(error)")
            }
        }
    }
    
    func answerCall() {
        webRTCManager.answerCall()
        callKitManager.answerCall()
    }
    
    func endCall() {
        webRTCManager.endCall()
        callKitManager.endCall()
    }
    
    func rejectCall() {
        webRTCManager.rejectCall()
        callKitManager.rejectCall()
    }
    
    // MARK: - Media Controls
    func toggleMute() {
        webRTCManager.toggleAudio()
        callKitManager.muteCall(!webRTCManager.isAudioEnabled)
    }
    
    func toggleVideo() {
        webRTCManager.toggleVideo()
    }
    
    func toggleSpeaker() {
        webRTCManager.toggleSpeaker()
    }
    
    func switchCamera() {
        // Implementation for camera switching
        webRTCManager.toggleVideo()
    }
    
    // MARK: - Permissions
    private func requestPermissions() async throws {
        // Request microphone permission
        let micStatus = AVAudioSession.sharedInstance().recordPermission
        if micStatus == .undetermined {
            let granted = await AVAudioSession.sharedInstance().requestRecordPermission()
            if !granted {
                throw CallError.microphonePermissionDenied
            }
        } else if micStatus == .denied {
            throw CallError.microphonePermissionDenied
        }
        
        // Request camera permission for video calls
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if cameraStatus == .notDetermined {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if !granted {
                throw CallError.cameraPermissionDenied
            }
        } else if cameraStatus == .denied {
            throw CallError.cameraPermissionDenied
        }
    }
    
    // MARK: - Event Handlers
    private func handleCallStarted(_ call: Call) {
        print("Call started: \(call.callerName)")
        activeCall = call
        isCallActive = true
    }
    
    private func handleCallAnswered(_ call: Call) {
        print("Call answered: \(call.callerName)")
        webRTCManager.answerCall()
    }
    
    private func handleCallEnded(_ call: Call) {
        print("Call ended: \(call.callerName)")
        webRTCManager.endCall()
        activeCall = nil
        isCallActive = false
    }
    
    private func handleCallRejected(_ call: Call) {
        print("Call rejected: \(call.callerName)")
        webRTCManager.rejectCall()
        activeCall = nil
        isCallActive = false
    }
    
    private func handleIncomingCall(_ call: Call) {
        print("Incoming call from: \(call.callerName)")
        activeCall = call
        isCallActive = true
    }
    
    private func handlePushTokenReceived(_ token: Data) {
        print("Push token received: \(token.map { String(format: "%02.2hhx", $0) }.joined())")
        
        // Send token to your backend server
        sendPushTokenToServer(token)
    }
    
    // MARK: - Server Communication
    private func sendPushTokenToServer(_ token: Data) {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        
        // This would typically send the token to your backend
        // for storing and later use when initiating calls
        print("Sending push token to server: \(tokenString)")
        
        // Example implementation:
        /*
        let url = URL(string: "https://api.tekiyo.fr/register-push-token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["push_token": tokenString, "user_id": "current_user_id"]
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to send push token: \(error)")
            } else {
                print("Push token sent successfully")
            }
        }.resume()
        */
    }
    
    // MARK: - Testing Methods
    func simulateIncomingCall() {
        pushKitManager.simulateIncomingCall(
            from: "test_user_123",
            callerName: "Marie Dupont",
            type: .video
        )
    }
    
    // MARK: - Public Getters
    var localVideoTrack: RTCVideoTrack? {
        webRTCManager.localVideoTrack
    }
    
    var remoteVideoTrack: RTCVideoTrack? {
        webRTCManager.remoteVideoTrack
    }
    
    var isAudioEnabled: Bool {
        webRTCManager.isAudioEnabled
    }
    
    var isVideoEnabled: Bool {
        webRTCManager.isVideoEnabled
    }
    
    var isSpeakerEnabled: Bool {
        webRTCManager.isSpeakerEnabled
    }
    
    var pushToken: String? {
        pushKitManager.getPushToken()
    }
}
