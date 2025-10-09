import Foundation
import Combine

@MainActor
final class IntroductionViewModel: ObservableObject {
    @Published var currentStep: Int = 1
    @Published var shouldNavigateToFaceID = false
    
    private let motionManager: DeviceMotionManager
    private let hapticManager: HapticManager
    
    private var returnedToZero = true
    
    private let thresholds = (
        neutralStrict: 5.0 * .pi / 180.0,
        step2On: 30.0 * .pi / 180.0,
        step2Off: 12.0 * .pi / 180.0,
        step3On: 45.0 * .pi / 180.0,
        step3Off: 35.0 * .pi / 180.0
    )
    
    init(
        motionManager: DeviceMotionManager? = nil,
        hapticManager: HapticManager? = nil
    ) {
        self.motionManager = motionManager ?? DeviceMotionManager()
        self.hapticManager = hapticManager ?? HapticManager.shared
    }
    
    func startMonitoring() {
        motionManager.onAngleUpdate = { [weak self] angle in
            guard let self = self else { return }
            Task { @MainActor in
                self.handleAngleUpdate(angle)
            }
        }
        motionManager.startUpdates()
    }
    
    func stopMonitoring() {
        motionManager.stopUpdates()
    }
    
    func proceedToFaceID() {
        shouldNavigateToFaceID = true
    }
    
    private func handleAngleUpdate(_ smoothedAngle: Double) {
        let oldStep = currentStep
        
        switch currentStep {
        case 1:
            if smoothedAngle < thresholds.neutralStrict {
                returnedToZero = true
            }
            if smoothedAngle > thresholds.step2On {
                currentStep = 2
                returnedToZero = false
            }
        case 2:
            if smoothedAngle < thresholds.neutralStrict {
                returnedToZero = true
            }
            if returnedToZero && smoothedAngle > thresholds.step3On {
                currentStep = 3
                returnedToZero = false
            }
        case 3:
            break
        default:
            break
        }
        
        if currentStep != oldStep {
            hapticManager.success()
        }
    }
}

