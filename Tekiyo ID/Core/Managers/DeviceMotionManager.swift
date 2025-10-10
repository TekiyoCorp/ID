import CoreMotion
import Foundation

final class DeviceMotionManager {
    private let motionManager = CMMotionManager()
    private let updateQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "DeviceMotionManager.Queue"
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    private var angleSamples: [Double] = []
    private var baselineAngle: Double?
    private var lastNotifiedAngle: Double?
    private var lastNotificationDate: Date?
    private var isUpdating = false
    
    private let maxSamples = 8
    private let minimumNotificationDelta = 1.2 * .pi / 180.0 // ≈1.2°
    private let minimumNotificationInterval: TimeInterval = 0.18
    private let recenterThreshold = 0.8 * .pi / 180.0 // ≈0.8°
    
    var onAngleUpdate: ((Double) -> Void)?
    
    func startUpdates(sampleInterval: TimeInterval = 1.0 / 20.0) {
        guard motionManager.isDeviceMotionAvailable else { return }
        guard !isUpdating else { return }
        
        baselineAngle = nil
        angleSamples.removeAll()
        lastNotifiedAngle = nil
        lastNotificationDate = nil
        
        motionManager.deviceMotionUpdateInterval = sampleInterval
        motionManager.startDeviceMotionUpdates(to: updateQueue) { [weak self] motion, _ in
            guard let self = self,
                  let attitude = motion?.attitude,
                  let gravity = motion?.gravity else { return }
            
            let smoothedAngle = self.processMotion(attitude: attitude, gravity: gravity)
            
            let now = Date()
            if let lastAngle = self.lastNotifiedAngle,
               abs(smoothedAngle - lastAngle) < self.minimumNotificationDelta,
               let lastDate = self.lastNotificationDate,
               now.timeIntervalSince(lastDate) < self.minimumNotificationInterval {
                return
            }
            
            self.lastNotifiedAngle = smoothedAngle
            self.lastNotificationDate = now
            
            DispatchQueue.main.async {
                self.onAngleUpdate?(smoothedAngle)
            }
        }
        
        isUpdating = true
    }
    
    func stopUpdates() {
        guard isUpdating else { return }
        motionManager.stopDeviceMotionUpdates()
        updateQueue.cancelAllOperations()
        angleSamples.removeAll()
        baselineAngle = nil
        lastNotifiedAngle = nil
        lastNotificationDate = nil
        isUpdating = false
    }
    
    private func processMotion(attitude: CMAttitude, gravity: CMAcceleration) -> Double {
        let isFlat = abs(gravity.z) > 0.85
        let rawAngle = isFlat ? attitude.yaw : attitude.roll
        
        var normalizedAngle = rawAngle
        if normalizedAngle > .pi { normalizedAngle -= 2 * .pi }
        if normalizedAngle < -.pi { normalizedAngle += 2 * .pi }
        
        let sensitivityGain = isFlat ? 1.2 : 1.0
        let adjustedAngle = normalizedAngle * sensitivityGain
        
        if baselineAngle == nil {
            baselineAngle = adjustedAngle
        }
        
        var relativeAngle = adjustedAngle - (baselineAngle ?? 0)
        
        if abs(relativeAngle) < recenterThreshold {
            baselineAngle = adjustedAngle
            relativeAngle = 0
            angleSamples.removeAll(keepingCapacity: true)
        }
        
        angleSamples.append(relativeAngle)
        if angleSamples.count > maxSamples {
            angleSamples.removeFirst(angleSamples.count - maxSamples)
        }
        
        return angleSamples.reduce(0, +) / Double(angleSamples.count)
    }
}
