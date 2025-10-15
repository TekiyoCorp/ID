import Foundation

struct EventRequirements: Equatable {
    let profileVerified: Bool
    let trustScoreMin: Int // 20%, 90%, etc.
    
    init(profileVerified: Bool = false, trustScoreMin: Int = 0) {
        self.profileVerified = profileVerified
        self.trustScoreMin = trustScoreMin
    }
}
