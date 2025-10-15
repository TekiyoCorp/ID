import Foundation
import CallKit
import UIKit
import Combine
import AVFoundation

@MainActor
final class CallKitManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var activeCall: Call?
    @Published var isCallActive = false
    
    // MARK: - Private Properties
    private let callController = CXCallController()
    private var provider: CXProvider?
    private let providerConfiguration: CXProviderConfiguration
    private var callObserver: CXCallObserver?
    
    // MARK: - Callbacks
    var onCallStarted: ((Call) -> Void)?
    var onCallEnded: ((Call) -> Void)?
    var onCallAnswered: ((Call) -> Void)?
    var onCallRejected: ((Call) -> Void)?
    
    // MARK: - Initialization
    override init() {
        // Configure CallKit provider
        providerConfiguration = CXProviderConfiguration(localizedName: CallConfiguration.localizedName)
        providerConfiguration.supportsVideo = CallConfiguration.supportVideo
        providerConfiguration.maximumCallGroups = CallConfiguration.maximumCallGroups
        providerConfiguration.maximumCallsPerCallGroup = CallConfiguration.maximumCallsPerCallGroup
        providerConfiguration.supportedHandleTypes = CallConfiguration.supportedHandleTypes
        
        // Set Tekiyo branding
        if let iconImage = UIImage(named: "AppIcon") {
            providerConfiguration.iconTemplateImageData = iconImage.pngData()
        }
        
        // Set ringtone
        providerConfiguration.ringtoneSound = "TekiyoRingtone.caf" // Custom ringtone
        
        super.init()
        
        setupCallKit()
        setupCallObserver()
    }
    
    // MARK: - Setup
    private func setupCallKit() {
        provider = CXProvider(configuration: providerConfiguration)
        provider?.setDelegate(self, queue: nil)
    }
    
    private func setupCallObserver() {
        callObserver = CXCallObserver()
        callObserver?.setDelegate(self, queue: nil)
    }
    
    // MARK: - Outgoing Calls
    func startCall(to callerID: String, callerName: String, type: CallType) {
        let handle = CXHandle(type: .generic, value: callerID)
        let startCallAction = CXStartCallAction(call: UUID(), handle: handle)
        startCallAction.isVideo = type == .video
        
        let transaction = CXTransaction(action: startCallAction)
        
        callController.request(transaction) { [weak self] error in
            if let error = error {
                print("Failed to start call: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                let call = Call(
                    callerID: callerID,
                    callerName: callerName,
                    type: type,
                    direction: .outgoing,
                    state: .connecting
                )
                self?.activeCall = call
                self?.isCallActive = true
                self?.onCallStarted?(call)
            }
        }
    }
    
    // MARK: - Incoming Calls
    func reportIncomingCall(
        from callerID: String,
        callerName: String,
        type: CallType,
        completion: @escaping (Error?) -> Void
    ) {
        let handle = CXHandle(type: .generic, value: callerID)
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = handle
        callUpdate.localizedCallerName = callerName
        callUpdate.hasVideo = type == .video
        callUpdate.supportsGrouping = false
        callUpdate.supportsUngrouping = false
        callUpdate.supportsHolding = false
        callUpdate.supportsDTMF = false
        
        let callUUID = UUID()
        
        provider?.reportNewIncomingCall(with: callUUID, update: callUpdate) { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(error)
                    return
                }
                
                let call = Call(
                    id: callUUID,
                    callerID: callerID,
                    callerName: callerName,
                    type: type,
                    direction: .incoming,
                    state: .connecting
                )
                self.activeCall = call
                self.isCallActive = true
                completion(nil)
            }
        }
    }
    
    // MARK: - Call Actions
    func answerCall() {
        guard let call = activeCall else { return }
        
        let answerAction = CXAnswerCallAction(call: call.cxCallUUID)
        let transaction = CXTransaction(action: answerAction)
        
        callController.request(transaction) { [weak self] error in
            if let error = error {
                print("Failed to answer call: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                self?.activeCall?.state = .connected
                self?.onCallAnswered?(call)
            }
        }
    }
    
    func endCall() {
        guard let call = activeCall else { return }
        
        let endAction = CXEndCallAction(call: call.cxCallUUID)
        let transaction = CXTransaction(action: endAction)
        
        callController.request(transaction) { [weak self] error in
            if let error = error {
                print("Failed to end call: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                self?.activeCall?.state = .disconnected
                self?.onCallEnded?(call)
                self?.activeCall = nil
                self?.isCallActive = false
            }
        }
    }
    
    func rejectCall() {
        guard let call = activeCall else { return }
        
        let endAction = CXEndCallAction(call: call.cxCallUUID)
        let transaction = CXTransaction(action: endAction)
        
        callController.request(transaction) { [weak self] error in
            if let error = error {
                print("Failed to reject call: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                self?.activeCall?.state = .disconnected
                self?.onCallRejected?(call)
                self?.activeCall = nil
                self?.isCallActive = false
            }
        }
    }
    
    // MARK: - Audio Controls
    func muteCall(_ isMuted: Bool) {
        guard let call = activeCall else { return }
        
        let muteAction = CXSetMutedCallAction(call: call.cxCallUUID, muted: isMuted)
        let transaction = CXTransaction(action: muteAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("Failed to mute call: \(error)")
            }
        }
    }
}

// MARK: - CXProviderDelegate
extension CallKitManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        print("CallKit provider did reset")
        DispatchQueue.main.async {
            self.activeCall = nil
            self.isCallActive = false
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("Start call action")
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("Answer call action")
        answerCall()
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("End call action")
        endCall()
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        print("Set muted action: \(action.isMuted)")
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        print("Set held action: \(action.isOnHold)")
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        print("Play DTMF action: \(action.digits)")
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print("Action timed out: \(action)")
        action.fail()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("Audio session activated")
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("Audio session deactivated")
    }
}

// MARK: - CXCallObserverDelegate
extension CallKitManager: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        print("Call changed: \(call.hasConnected) \(call.hasEnded) \(call.isOutgoing)")
        
        DispatchQueue.main.async {
            if call.hasEnded {
                self.isCallActive = false
                self.activeCall = nil
            }
        }
    }
}

// MARK: - UIColor Extension
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
}
