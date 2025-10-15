import SwiftUI

struct CallTestView: View {
    @StateObject private var callManager = CallManager()
    @State private var showPermissionRequest = false
    @State private var selectedCallType: CallType = .video
    @State private var testCallerName = "Marie Dupont"
    @State private var testCallerID = "test_user_123"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "111111")
                    .ignoresSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Text("Test d'appels Tekiyo ID")
                                .font(.custom("SF Pro Display", size: 28))
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("Simulation d'appels audio/vidéo")
                                .font(.custom("SF Pro Display", size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        // Call Type Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Type d'appel")
                                .font(.custom("SF Pro Display", size: 18))
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Picker("Type d'appel", selection: $selectedCallType) {
                                Text("Audio").tag(CallType.audio)
                                Text("Vidéo").tag(CallType.video)
                            }
                            .pickerStyle(.segmented)
                            .background(
                                RoundedRectangle(cornerRadius: 50)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                        
                        // Caller Information
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Informations de l'appelant")
                                .font(.custom("SF Pro Display", size: 18))
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.9))
                            
                            VStack(spacing: 16) {
                                TextField("Nom de l'appelant", text: $testCallerName)
                                    .font(.custom("SF Pro Display", size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 50)
                                            .fill(.ultraThinMaterial)
                                    )
                                
                                TextField("ID de l'appelant", text: $testCallerID)
                                    .font(.custom("SF Pro Display", size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 50)
                                            .fill(.ultraThinMaterial)
                                    )
                            }
                        }
                        
                        // Call Status
                        VStack(alignment: .leading, spacing: 12) {
                            Text("État de l'appel")
                                .font(.custom("SF Pro Display", size: 18))
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.9))
                            
                            VStack(spacing: 8) {
                                StatusRow(title: "État de l'appel", value: callManager.callState.rawValue)
                                StatusRow(title: "Connexion", value: callManager.connectionState)
                                StatusRow(title: "Audio activé", value: callManager.isAudioEnabled ? "Oui" : "Non")
                                StatusRow(title: "Vidéo activé", value: callManager.isVideoEnabled ? "Oui" : "Non")
                                StatusRow(title: "Haut-parleur", value: callManager.isSpeakerEnabled ? "Oui" : "Non")
                                
                                if let pushToken = callManager.pushToken {
                                    StatusRow(title: "Push Token", value: String(pushToken.prefix(16)) + "...")
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 50)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                        
                        // Test Actions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Actions de test")
                                .font(.custom("SF Pro Display", size: 18))
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.9))
                            
                            VStack(spacing: 12) {
                                // Start Outgoing Call
                                Button(action: {
                                    callManager.startCall(
                                        to: testCallerID,
                                        callerName: testCallerName,
                                        type: selectedCallType
                                    )
                                }) {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                        Text("Démarrer un appel sortant")
                                    }
                                    .font(.custom("SF Pro Display", size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 50)
                                            .fill(Color.green)
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                // Simulate Incoming Call
                                Button(action: {
                                    callManager.simulateIncomingCall()
                                }) {
                                    HStack {
                                        Image(systemName: "phone.badge.plus")
                                        Text("Simuler un appel entrant")
                                    }
                                    .font(.custom("SF Pro Display", size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 50)
                                            .fill(Color.blue)
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                // End Call
                                Button(action: {
                                    callManager.endCall()
                                }) {
                                    HStack {
                                        Image(systemName: "phone.down.fill")
                                        Text("Terminer l'appel")
                                    }
                                    .font(.custom("SF Pro Display", size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 50)
                                            .fill(Color.red)
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                // Media Controls
                                HStack(spacing: 12) {
                                    MediaControlButton(
                                        icon: callManager.isAudioEnabled ? "mic.fill" : "mic.slash.fill",
                                        isActive: callManager.isAudioEnabled,
                                        action: { callManager.toggleMute() }
                                    )
                                    
                                    MediaControlButton(
                                        icon: callManager.isVideoEnabled ? "video.fill" : "video.slash.fill",
                                        isActive: callManager.isVideoEnabled,
                                        action: { callManager.toggleVideo() }
                                    )
                                    
                                    MediaControlButton(
                                        icon: callManager.isSpeakerEnabled ? "speaker.wave.2.fill" : "speaker.wave.1.fill",
                                        isActive: callManager.isSpeakerEnabled,
                                        action: { callManager.toggleSpeaker() }
                                    )
                                }
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showPermissionRequest) {
            PermissionRequestView(
                callType: selectedCallType,
                onPermissionGranted: {
                    showPermissionRequest = false
                },
                onPermissionDenied: {
                    showPermissionRequest = false
                }
            )
        }
    }
}

// MARK: - Status Row
struct StatusRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("SF Pro Display", size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.custom("SF Pro Display", size: 14))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

// MARK: - Media Control Button
struct MediaControlButton: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isActive ? .white : .white.opacity(0.6))
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(isActive ? .ultraThinMaterial : .ultraThinMaterial.opacity(0.5))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Call State Extension
extension CallState {
    var rawValue: String {
        switch self {
        case .idle:
            return "Inactif"
        case .connecting:
            return "Connexion"
        case .connected:
            return "Connecté"
        case .disconnected:
            return "Déconnecté"
        case .failed:
            return "Échec"
        }
    }
}

// MARK: - Preview
#Preview {
    CallTestView()
}
