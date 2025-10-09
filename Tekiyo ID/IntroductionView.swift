import SwiftUI
import CoreMotion
import UIKit

// Custom blur + opacity transition since AnyTransition has no built-in blur
private struct BlurOpacityModifier: ViewModifier {
    let isActive: Bool
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 0 : 1)
            .blur(radius: isActive ? radius : 0)
    }
}

private extension AnyTransition {
    static func blurOpacity(radius: CGFloat = 10) -> AnyTransition {
        .modifier(
            active: BlurOpacityModifier(isActive: true, radius: radius),
            identity: BlurOpacityModifier(isActive: false, radius: radius)
        )
    }
}

struct IntroductionView: View {
    @State private var step: Int = 1
    @State private var angleSamples: [Double] = []
    @State private var returnedToZero: Bool = true
    @State private var returnedToNeutral: Bool = true
    @State private var baselineAngle: Double? = nil
    @State private var goToFaceID = false
    private let motionManager = CMMotionManager()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch step {
            case 1:
                Text("Ce que tu es ne devrait pas quitter ton téléphone.")
                    .font(.system(size: 36, weight: .medium))
                    .appTypography(fontSize: 36)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .transition(.blurOpacity(radius: 10))
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tekiyo ne te regarde pas.")
                        .font(.system(size: 22, weight: .medium))
                        .appTypography(fontSize: 22)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .transition(.blurOpacity(radius: 10))
                    
                    Text("Il te reconnaît, puis t’oublie.")
                        .font(.system(size: 22, weight: .medium))
                        .appTypography(fontSize: 22)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .transition(.blurOpacity(radius: 10))
                }
            case 2:
                Text("Les machines imitent.")
                    .font(.system(size: 36, weight: .medium))
                    .appTypography(fontSize: 36)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .transition(.blurOpacity(radius: 10))
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Toi, tu existes.")
                        .font(.system(size: 22, weight: .medium))
                        .appTypography(fontSize: 22)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .transition(.blurOpacity(radius: 10))
                }
            case 3:
                Text("Un seul ID.")
                    .font(.system(size: 36, weight: .medium))
                    .appTypography(fontSize: 36)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .transition(.blurOpacity(radius: 10))
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dans un monde sans visage.")
                        .font(.system(size: 22, weight: .medium))
                        .appTypography(fontSize: 22)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .transition(.blurOpacity(radius: 10))
                }
                
            default:
                EmptyView()
            }
            
            Spacer()
            
            if step == 3 {
                Button(action: { goToFaceID = true }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 293, style: .continuous)
                        .fill(Color.black)
                )
                .transition(.blurOpacity(radius: 10))
            } else {
                Text("Inclinez votre téléphone vers la droite")
                    .font(.system(size: 13, weight: .regular))
                    .appTypography(fontSize: 13)
                    .foregroundStyle(.primary)
                    .opacity(0.4)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.blurOpacity(radius: 10))
            }
        }
        .frame(maxWidth: 274, alignment: .leading)
        .padding(EdgeInsets(top: 48, leading: 48, bottom: 48, trailing: 48))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground))
        .navigationDestination(isPresented: $goToFaceID) {
            FaceIDSetupView()
        }
        .onAppear {
            startMotionUpdates()
        }
        .onDisappear {
            stopMotionUpdates()
        }
    }
    
    private func hapticStepChanged() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let attitude = motion?.attitude else { return }
            let gravity = motion?.gravity
            
            // Determine if device is near flat (face up) using gravity.z magnitude
            let isFlat = {
                guard let g = gravity else { return false }
                // When face-up, |g.z| is close to 1.0; threshold ~0.85 works well
                return abs(g.z) > 0.85
            }()
            
            // Choose axis: roll when upright (portrait in hand), yaw when flat on a table
            let rawAngle: Double = isFlat ? attitude.yaw : attitude.roll
            // Normalize yaw to a continuous range [-pi, pi]
            var tiltAngle = rawAngle
            if tiltAngle > .pi { tiltAngle -= 2 * .pi }
            if tiltAngle < -.pi { tiltAngle += 2 * .pi }
            
            // Sensitivity gain when device is flat: amplify angle slightly to ease detection on a table
            let sensitivityGain: Double = isFlat ? 1.3 : 1.0
            let adjustedAngle = tiltAngle * sensitivityGain
            
            // Calibrate baseline on first frames to avoid starting at a high step when user is already tilted
            if baselineAngle == nil {
                baselineAngle = adjustedAngle
            }
            let relativeAngle = adjustedAngle - (baselineAngle ?? 0)
            
            let newAngle = relativeAngle
            
            // Keep a rolling window of the last 8 samples for smoothing
            let maxSamples = 8
            angleSamples.append(newAngle)
            if angleSamples.count > maxSamples { angleSamples.removeFirst(angleSamples.count - maxSamples) }
            let smoothedAngle = angleSamples.reduce(0, +) / Double(angleSamples.count)
            
            // Stricter thresholds with mandatory return-to-zero before step 3
            let neutralStrict = 5.0 * .pi / 180.0    // ~5° considered zero
            let step2On      = 30.0 * .pi / 180.0    // enter step 2 from strict neutral
            let step2Off     = 12.0 * .pi / 180.0    // fall back to neutral zone
            let step3On      = 45.0 * .pi / 180.0    // enter step 3 only after returning to strict neutral
            let step3Off     = 35.0 * .pi / 180.0    // fall back to step 2

            let oldStep = step

            withAnimation(.easeInOut(duration: 0.3)) {
                switch step {
                case 1:
                    // Mark returnedToZero when flat
                    if smoothedAngle < neutralStrict { returnedToZero = true }
                    // Advance to step 2 only when clearly tilted enough
                    if smoothedAngle > step2On {
                        step = 2
                        returnedToZero = false
                    }
                case 2:
                    // Do not go back to 1 automatically.
                    // Require a strict neutral before allowing step 3.
                    if smoothedAngle < neutralStrict {
                        returnedToZero = true
                    }
                    if returnedToZero && smoothedAngle > step3On {
                        step = 3
                        returnedToZero = false
                    }
                case 3:
                    // Stay at step 3; no regression.
                    break
                default:
                    break
                }
            }
            
            // Trigger haptic on step change
            if step != oldStep {
                hapticStepChanged()
            }
        }
    }
    
    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}

#Preview {
    IntroductionView()
}
