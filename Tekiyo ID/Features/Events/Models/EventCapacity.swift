import Foundation

struct EventCapacity: Equatable {
    let current: Int
    let max: Int
    
    init(current: Int, max: Int) {
        self.current = current
        self.max = max
    }
    
    var formattedCapacity: String {
        "\(current)/\(max) places."
    }
}
