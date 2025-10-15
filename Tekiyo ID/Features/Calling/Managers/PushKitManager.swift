import Foundation
import PushKit
import CallKit
import Combine

@MainActor
final class PushKitManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var incomingCall: Call?
    @Published var pushToken: Data?
    
    // MARK: - Private Properties
    private let pushRegistry = PKPushRegistry(queue: .main)
    private let callKitManager: CallKitManager
    
    // MARK: - Callbacks
    var onIncomingCall: ((Call) -> Void)?
    var onPushTokenReceived: ((Data) -> Void)?
    
    // MARK: - Initialization
    init(callKitManager: CallKitManager) {
        self.callKitManager = callKitManager
        super.init()
        
        setupPushKit()
    }
    
    // MARK: - Setup
    private func setupPushKit() {
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
        
        // Request push token
        requestPushToken()
    }
    
    private func requestPushToken() {
        pushRegistry.desiredPushTypes = [.voIP]
    }
    
    // MARK: - Token Management
    func getPushToken() -> String? {
        guard let token = pushToken else { return nil }
        return token.map { String(format: "%02.2hhx", $0) }.joined()
    }
    
    // MARK: - Incoming Call Handling
    func handleIncomingCall(
        from callerID: String,
        callerName: String,
        type: CallType,
        callUUID: UUID
    ) {
        let call = Call(
            id: callUUID,
            callerID: callerID,
            callerName: callerName,
            type: type,
            direction: .incoming,
            state: .connecting
        )
        
        incomingCall = call
        
        // Report to CallKit
        callKitManager.reportIncomingCall(
            from: callerID,
            callerName: callerName,
            type: type
        ) { [weak self] error in
            if let error = error {
                print("Failed to report incoming call: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                self?.onIncomingCall?(call)
            }
        }
    }
    
    // MARK: - Simulate Incoming Call (for testing)
    func simulateIncomingCall(
        from callerID: String = "test_user",
        callerName: String = "Test User",
        type: CallType = .video
    ) {
        let callUUID = UUID()
        handleIncomingCall(
            from: callerID,
            callerName: callerName,
            type: type,
            callUUID: callUUID
        )
    }
}

// MARK: - PKPushRegistryDelegate
extension PushKitManager: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        print("Push credentials updated for type: \(type)")
        
        if type == .voIP {
            DispatchQueue.main.async {
                self.pushToken = pushCredentials.token
                self.onPushTokenReceived?(pushCredentials.token)
            }
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("Received incoming push for type: \(type)")
        
        if type == .voIP {
            handleIncomingVoIPPush(payload: payload, completion: completion)
        } else {
            completion()
        }
    }
    
    private func handleIncomingVoIPPush(payload: PKPushPayload, completion: @escaping () -> Void) {
        // Parse push payload
        guard let aps = payload.dictionaryPayload["aps"] as? [String: Any],
              let alert = aps["alert"] as? [String: Any],
              let callerID = payload.dictionaryPayload["caller_id"] as? String,
              let callerName = payload.dictionaryPayload["caller_name"] as? String,
              let callTypeString = payload.dictionaryPayload["call_type"] as? String,
              let callUUIDString = payload.dictionaryPayload["call_uuid"] as? String,
              let callUUID = UUID(uuidString: callUUIDString) else {
            print("Invalid push payload")
            completion()
            return
        }
        
        let callType: CallType = callTypeString == "video" ? .video : .audio
        
        // Handle incoming call
        handleIncomingCall(
            from: callerID,
            callerName: callerName,
            type: callType,
            callUUID: callUUID
        )
        
        completion()
    }
}

// MARK: - Push Payload Structure
struct VoIPPushPayload {
    let callerID: String
    let callerName: String
    let callType: CallType
    let callUUID: UUID
    let timestamp: Date
    
    init(
        callerID: String,
        callerName: String,
        callType: CallType,
        callUUID: UUID = UUID(),
        timestamp: Date = Date()
    ) {
        self.callerID = callerID
        self.callerName = callerName
        self.callType = callType
        self.callUUID = callUUID
        self.timestamp = timestamp
    }
    
    var dictionaryPayload: [String: Any] {
        return [
            "aps": [
                "alert": [
                    "title": "Appel entrant",
                    "body": "\(callerName) vous appelle"
                ],
                "sound": "TekiyoRingtone.caf",
                "badge": 1
            ],
            "caller_id": callerID,
            "caller_name": callerName,
            "call_type": callType == .video ? "video" : "audio",
            "call_uuid": callUUID.uuidString,
            "timestamp": timestamp.timeIntervalSince1970
        ]
    }
}

// MARK: - Push Notification Service Extension Helper
class VoIPPushService {
    static let shared = VoIPPushService()
    
    private init() {}
    
    func sendVoIPPush(
        to deviceToken: String,
        payload: VoIPPushPayload,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // This would typically integrate with your backend service
        // to send the push notification to Apple's servers
        
        let url = URL(string: "https://api.tekiyo.fr/voip-push")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "device_token": deviceToken,
            "payload": payload.dictionaryPayload
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
}
