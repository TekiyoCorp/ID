import CoreMotion
import Foundation

final class DeviceMotionManager {
    private let motionManager = CMMotionManager()
    private var angleSamples: [Double] = []
    private var baselineAngle: Double?
    
    private let updateInterval: TimeInterval = 1.0 / 30.0
    private let maxSamples = 8
    
    var onAngleUpdate: ((Double) -> Void)?
    
    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self = self,
                  let attitude = motion?.attitude,
                  let gravity = motion?.gravity else { return }
            
            let smoothedAngle = self.processMotion(attitude: attitude, gravity: gravity)
            self.onAngleUpdate?(smoothedAngle)
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        angleSamples.removeAll()
        baselineAngle = nil
    }
    
    private func processMotion(attitude: CMAttitude, gravity: CMAcceleration) -> Double {
        let isFlat = abs(gravity.z) > 0.85
        let rawAngle = isFlat ? attitude.yaw : attitude.roll
        
        var normalizedAngle = rawAngle
        if normalizedAngle > .pi { normalizedAngle -= 2 * .pi }
        if normalizedAngle < -.pi { normalizedAngle += 2 * .pi }
        
        let sensitivityGain = isFlat ? 1.3 : 1.0
        let adjustedAngle = normalizedAngle * sensitivityGain
        
        if baselineAngle == nil {
            baselineAngle = adjustedAngle
        }
        
        let relativeAngle = adjustedAngle - (baselineAngle ?? 0)
        
        angleSamples.append(relativeAngle)
        if angleSamples.count > maxSamples {
            angleSamples.removeFirst(angleSamples.count - maxSamples)
        }
        
        return angleSamples.reduce(0, +) / Double(angleSamples.count)
    }
}

