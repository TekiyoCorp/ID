import Foundation
import CallKit

// MARK: - Call State
enum CallState {
    case idle
    case connecting
    case connected
    case disconnected
    case failed
}

// MARK: - Call Type
enum CallType {
    case audio
    case video
}

// MARK: - Call Direction
enum CallDirection {
    case incoming
    case outgoing
}

// MARK: - Call Model
struct Call: Identifiable, Equatable {
    let id: UUID
    let callerID: String
    let callerName: String
    let callerAvatar: String?
    let type: CallType
    let direction: CallDirection
    var state: CallState
    let startTime: Date?
    let endTime: Date?
    
    init(
        id: UUID = UUID(),
        callerID: String,
        callerName: String,
        callerAvatar: String? = nil,
        type: CallType,
        direction: CallDirection,
        state: CallState = .idle,
        startTime: Date? = nil,
        endTime: Date? = nil
    ) {
        self.id = id
        self.callerID = callerID
        self.callerName = callerName
        self.callerAvatar = callerAvatar
        self.type = type
        self.direction = direction
        self.state = state
        self.startTime = startTime
        self.endTime = endTime
    }
    
    // MARK: - Computed Properties
    var duration: TimeInterval {
        guard let start = startTime else { return 0 }
        let end = endTime ?? Date()
        return end.timeIntervalSince(start)
    }
    
    var formattedDuration: String {
        let duration = Int(duration)
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - CallKit Integration
    var cxCallUUID: UUID {
        return id
    }
}

// MARK: - Call Configuration
struct CallConfiguration {
    static let providerIdentifier = "com.tekiyo.id.callkit.provider"
    static let localizedName = "Tekiyo ID"
    static let supportVideo = true
    static let maximumCallGroups = 1
    static let maximumCallsPerCallGroup = 1
    static let supportedHandleTypes: Set<CXHandle.HandleType> = [.generic]
    
    // Tekiyo branding colors
    static let primaryColor = "#007AFF"
    static let secondaryColor = "#002FFF"
}
