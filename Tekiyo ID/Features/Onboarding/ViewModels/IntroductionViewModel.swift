import Foundation
import Combine

@MainActor
final class IntroductionViewModel: ObservableObject {
    @Published var currentStep: Int = 1
    @Published var shouldNavigateToFaceID = false
    
    private let motionManager: DeviceMotionManager
    private let hapticManager: HapticManager
    
    private var returnedToZero = true
    private var didReachFinalStep = false
    
    private let thresholds = (
        neutralStrict: 3.0 * .pi / 180.0,
        step2On: 22.0 * .pi / 180.0,
        step2Off: 10.0 * .pi / 180.0,
        step3On: 34.0 * .pi / 180.0,
        step3Off: 22.0 * .pi / 180.0
    )
    
    init(
        motionManager: DeviceMotionManager? = nil,
        hapticManager: HapticManager? = nil
    ) {
        self.motionManager = motionManager ?? DeviceMotionManager()
        self.hapticManager = hapticManager ?? HapticManager.shared
    }
    
    func startMonitoring() {
        didReachFinalStep = false
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
        stopMonitoring()
    }
    
    #if DEBUG
    func setStep(_ step: Int) {
        currentStep = step
        if step == 3 {
            didReachFinalStep = true
            stopMonitoring()
        }
    }
    #endif
    
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
            if !didReachFinalStep {
                didReachFinalStep = true
                motionManager.stopUpdates()
            }
        default:
            break
        }
        
        if currentStep != oldStep {
            hapticManager.success()
        }
    }
}
