import SwiftUI
import WebRTC
import AVFoundation

struct CallView: View {
    @StateObject private var callManager = CallManager()
    @Environment(\.dismiss) var dismiss
    
    let conversation: Conversation
    let callType: CallType
    
    @State private var showControls = true
    @State private var hideControlsTimer: Timer?
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea(.all)
            
            // Video content
            videoContentView
            
            // Controls overlay
            if showControls {
                controlsOverlay
                    .transition(.opacity)
            }
            
            // Call state overlay
            callStateOverlay
        }
        .onAppear {
            startCall()
            setupHideControlsTimer()
        }
        .onDisappear {
            cleanup()
        }
        .onTapGesture {
            toggleControls()
        }
    }
    
    // MARK: - Video Content
    private var videoContentView: some View {
        ZStack {
            // Remote video (full screen)
            if let remoteVideoTrack = callManager.remoteVideoTrack {
                RemoteVideoView(videoTrack: remoteVideoTrack)
                    .ignoresSafeArea(.all)
            } else {
                // Placeholder when no remote video
                Color.black
            }
            
            // Local video (picture-in-picture)
            if let localVideoTrack = callManager.localVideoTrack {
                LocalVideoView(videoTrack: localVideoTrack)
                    .frame(width: 120, height: 160)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
    }
    
    // MARK: - Controls Overlay
    private var controlsOverlay: some View {
        VStack {
            // Top controls
            HStack {
                // Back button
                Button(action: {
                    endCallAndDismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Call info
                VStack(spacing: 4) {
                    Text(conversation.user.name)
                        .font(.custom("SF Pro Display", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(callManager.connectionState)
                        .font(.custom("SF Pro Display", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Call duration (if connected)
                if callManager.callState == .connected {
                    Text(callManager.activeCall?.formattedDuration ?? "00:00")
                        .font(.custom("SF Pro Display", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
            
            // Bottom controls
            VStack(spacing: 24) {
                // Caller info
                if callManager.callState != .connected {
                    callerInfoView
                }
                
                // Control buttons
                controlButtonsView
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
    
    // MARK: - Caller Info
    private var callerInfoView: some View {
        VStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(conversation.user.avatarColor)
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: conversation.user.avatarImage)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                )
            
            // Name and call type
            VStack(spacing: 4) {
                Text(conversation.user.name)
                    .font(.custom("SF Pro Display", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(callType == .video ? "Appel vidéo" : "Appel audio")
                    .font(.custom("SF Pro Display", size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    // MARK: - Control Buttons
    private var controlButtonsView: some View {
        HStack(spacing: 40) {
            // Mute button
            CallControlButton(
                icon: callManager.isAudioEnabled ? "mic.fill" : "mic.slash.fill",
                isActive: callManager.isAudioEnabled,
                action: {
                    callManager.toggleMute()
                }
            )
            
            // Video button (only for video calls)
            if callType == .video {
                CallControlButton(
                    icon: callManager.isVideoEnabled ? "video.fill" : "video.slash.fill",
                    isActive: callManager.isVideoEnabled,
                    action: {
                        callManager.toggleVideo()
                    }
                )
            }
            
            // Speaker button
            CallControlButton(
                icon: callManager.isSpeakerEnabled ? "speaker.wave.2.fill" : "speaker.wave.1.fill",
                isActive: callManager.isSpeakerEnabled,
                action: {
                    callManager.toggleSpeaker()
                }
            )
            
            // End call button
            CallControlButton(
                icon: "phone.down.fill",
                isActive: false,
                backgroundColor: .red,
                action: {
                    endCallAndDismiss()
                }
            )
        }
    }
    
    // MARK: - Call State Overlay
    private var callStateOverlay: some View {
        VStack {
            if callManager.callState == .connecting {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    
                    Text("Connexion en cours...")
                        .font(.custom("SF Pro Display", size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
            }
            
            if callManager.callState == .failed {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                    
                    Text("Échec de l'appel")
                        .font(.custom("SF Pro Display", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Button("Réessayer") {
                        startCall()
                    }
                    .font(.custom("SF Pro Display", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .fill(.ultraThinMaterial)
                    )
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
    }
    
    // MARK: - Actions
    private func startCall() {
        callManager.startCall(
            to: conversation.user.id.uuidString,
            callerName: conversation.user.name,
            type: callType
        )
    }
    
    private func endCallAndDismiss() {
        callManager.endCall()
        dismiss()
    }
    
    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showControls.toggle()
        }
        
        if showControls {
            setupHideControlsTimer()
        } else {
            hideControlsTimer?.invalidate()
        }
    }
    
    private func setupHideControlsTimer() {
        hideControlsTimer?.invalidate()
        hideControlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                showControls = false
            }
        }
    }
    
    private func cleanup() {
        hideControlsTimer?.invalidate()
        callManager.endCall()
    }
}

// MARK: - Call Control Button
struct CallControlButton: View {
    let icon: String
    let isActive: Bool
    var backgroundColor: Color = .white.opacity(0.2)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(isActive ? .white : .white.opacity(0.7))
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(isActive ? backgroundColor : backgroundColor.opacity(0.5))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Video Views
struct LocalVideoView: UIViewRepresentable {
    let videoTrack: RTCVideoTrack
    
    func makeUIView(context: Context) -> RTCMTLVideoView {
        let videoView = RTCMTLVideoView()
        videoView.videoContentMode = .scaleAspectFill
        return videoView
    }
    
    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
        videoTrack.add(uiView)
    }
}

struct RemoteVideoView: UIViewRepresentable {
    let videoTrack: RTCVideoTrack
    
    func makeUIView(context: Context) -> RTCMTLVideoView {
        let videoView = RTCMTLVideoView()
        videoView.videoContentMode = .scaleAspectFill
        return videoView
    }
    
    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
        videoTrack.add(uiView)
    }
}

// MARK: - Preview
#Preview {
    CallView(
        conversation: Conversation.mockConversations.first!,
        callType: .video
    )
}
