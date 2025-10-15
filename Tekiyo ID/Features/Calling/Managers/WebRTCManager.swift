import Foundation
import AVFoundation
import Combine

#if !targetEnvironment(simulator)
import WebRTC

@MainActor
final class WebRTCManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var localVideoTrack: RTCVideoTrack?
    @Published var remoteVideoTrack: RTCVideoTrack?
    @Published var isAudioEnabled = true
    @Published var isVideoEnabled = true
    @Published var isSpeakerEnabled = false
    @Published var connectionState: RTCIceConnectionState = .new
    @Published var callState: CallState = .idle
    
    // MARK: - Private Properties
    private let peerConnectionFactory: RTCPeerConnectionFactory
    private var peerConnection: RTCPeerConnection?
    private var localVideoCapturer: RTCVideoCapturer?
    private var localAudioTrack: RTCAudioTrack?
    private var localVideoSource: RTCVideoSource?
    private var dataChannel: RTCDataChannel?
    
    // MARK: - Configuration
    private let rtcConfiguration: RTCConfiguration = {
        let config = RTCConfiguration()
        config.iceServers = [
            RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"]),
            RTCIceServer(urlStrings: ["stun:stun1.l.google.com:19302"])
        ]
        config.continualGatheringPolicy = .gatherContinually
        config.sdpSemantics = .unifiedPlan
        return config
    }()
    
    private let mediaConstraints = RTCMediaConstraints(
        mandatoryConstraints: [
            "OfferToReceiveAudio": "true",
            "OfferToReceiveVideo": "true"
        ],
        optionalConstraints: nil
    )
    
    // MARK: - Initialization
    override init() {
        // Initialize WebRTC
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        
        peerConnectionFactory = RTCPeerConnectionFactory(
            encoderFactory: videoEncoderFactory,
            decoderFactory: videoDecoderFactory
        )
        
        super.init()
        
        setupAudioSession()
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Peer Connection Management
    func createPeerConnection() -> RTCPeerConnection? {
        let peerConnection = peerConnectionFactory.peerConnection(
            with: rtcConfiguration,
            constraints: mediaConstraints,
            delegate: self
        )
        
        self.peerConnection = peerConnection
        return peerConnection
    }
    
    func closePeerConnection() {
        peerConnection?.close()
        peerConnection = nil
        localVideoCapturer = nil
        localAudioTrack = nil
        localVideoSource = nil
        localVideoTrack = nil
        remoteVideoTrack = nil
        dataChannel = nil
    }
    
    // MARK: - Media Setup
    func setupLocalMedia() async throws {
        // Setup audio track
        let audioConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        localAudioTrack = peerConnectionFactory.audioTrack(withTrackId: "ARDAMSAudioTrack")
        
        // Setup video track
        localVideoSource = peerConnectionFactory.videoSource()
        localVideoTrack = peerConnectionFactory.videoTrack(with: localVideoSource!, trackId: "ARDAMSVideoTrack")
        
        // Add tracks to peer connection
        guard let peerConnection = peerConnection else { return }
        
        peerConnection.add(localAudioTrack!, streamIds: ["ARDAMS"])
        peerConnection.add(localVideoTrack!, streamIds: ["ARDAMS"])
        
        // Setup video capturer
        await setupVideoCapturer()
        
        callState = .connecting
    }
    
    private func setupVideoCapturer() async {
        guard let videoSource = localVideoSource else { return }
        
        // Request camera permission
        await requestCameraPermission()
        
        // Create video capturer
        localVideoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        
        // Start capturing
        guard let capturer = localVideoCapturer as? RTCCameraVideoCapturer else { return }
        
        let devices = RTCCameraVideoCapturer.captureDevices()
        guard let device = devices.first else { return }
        
        let formats = RTCCameraVideoCapturer.supportedFormats(for: device)
        guard let format = formats.first else { return }
        
        let fps = format.videoSupportedFrameRateRanges.first?.maxFrameRate ?? 30
        capturer.startCapture(with: device, format: format, fps: Int(fps))
    }
    
    private func requestCameraPermission() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            return
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if !granted {
                throw CallError.cameraPermissionDenied
            }
        case .denied, .restricted:
            throw CallError.cameraPermissionDenied
        @unknown default:
            throw CallError.cameraPermissionDenied
        }
    }
    
    // MARK: - Media Controls
    func toggleAudio() {
        isAudioEnabled.toggle()
        localAudioTrack?.isEnabled = isAudioEnabled
    }
    
    func toggleVideo() {
        isVideoEnabled.toggle()
        localVideoTrack?.isEnabled = isVideoEnabled
        
        if isVideoEnabled {
            setupVideoCapturer()
        } else {
            localVideoCapturer?.stopCapture()
        }
    }
    
    func toggleSpeaker() {
        isSpeakerEnabled.toggle()
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if isSpeakerEnabled {
                try audioSession.overrideOutputAudioPort(.speaker)
            } else {
                try audioSession.overrideOutputAudioPort(.none)
            }
        } catch {
            print("Failed to toggle speaker: \(error)")
        }
    }
    
    // MARK: - Call Management
    func startCall() {
        callState = .connecting
        Task {
            do {
                try await setupLocalMedia()
            } catch {
                callState = .failed
                print("Failed to start call: \(error)")
            }
        }
    }
    
    func endCall() {
        callState = .disconnected
        localVideoCapturer?.stopCapture()
        closePeerConnection()
    }
    
    func answerCall() {
        callState = .connected
    }
    
    func rejectCall() {
        callState = .disconnected
        closePeerConnection()
    }
}

// MARK: - RTCPeerConnectionDelegate
extension WebRTCManager: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("Signaling state changed: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("Remote stream added")
        remoteVideoTrack = stream.videoTracks.first
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("Remote stream removed")
        remoteVideoTrack = nil
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        DispatchQueue.main.async {
            self.connectionState = newState
            
            switch newState {
            case .connected, .completed:
                self.callState = .connected
            case .failed, .disconnected:
                self.callState = .disconnected
            case .closed:
                self.callState = .disconnected
            default:
                break
            }
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("ICE gathering state changed: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        print("ICE candidate generated")
        // Send candidate to remote peer via signaling
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print("ICE candidates removed")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("Data channel opened")
        self.dataChannel = dataChannel
    }
}

#endif
