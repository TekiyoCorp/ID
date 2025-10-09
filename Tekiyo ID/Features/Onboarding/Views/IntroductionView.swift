import SwiftUI

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
    @StateObject private var viewModel = IntroductionViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch viewModel.currentStep {
            case 1:
                stepOne
            case 2:
                stepTwo
            case 3:
                stepThree
            default:
                EmptyView()
            }
            
            Spacer()
            
            if viewModel.currentStep == 3 {
                PrimaryButton(
                    icon: "chevron.right",
                    action: viewModel.proceedToFaceID
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
        .navigationDestination(isPresented: $viewModel.shouldNavigateToFaceID) {
            FaceIDSetupView()
        }
        .onAppear {
            viewModel.startMonitoring()
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }
    
    private var stepOne: some View {
        VStack(alignment: .leading, spacing: 12) {
            LargeTitle("Ce que tu es ne devrait pas quitter ton téléphone.")
                .transition(.blurOpacity(radius: 10))
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Tekiyo ne te regarde pas.")
                    .font(.system(size: 22, weight: .medium))
                    .appTypography(fontSize: 22)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .transition(.blurOpacity(radius: 10))
                
                Text("Il te reconnaît, puis t'oublie.")
                    .font(.system(size: 22, weight: .medium))
                    .appTypography(fontSize: 22)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .transition(.blurOpacity(radius: 10))
            }
        }
    }
    
    private var stepTwo: some View {
        VStack(alignment: .leading, spacing: 12) {
            LargeTitle("Les machines imitent.")
                .transition(.blurOpacity(radius: 10))
            
            Text("Toi, tu existes.")
                .font(.system(size: 22, weight: .medium))
                .appTypography(fontSize: 22)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .transition(.blurOpacity(radius: 10))
        }
    }
    
    private var stepThree: some View {
        VStack(alignment: .leading, spacing: 12) {
            LargeTitle("Un seul ID.")
                .transition(.blurOpacity(radius: 10))
            
            Text("Dans un monde sans visage.")
                .font(.system(size: 22, weight: .medium))
                .appTypography(fontSize: 22)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .transition(.blurOpacity(radius: 10))
        }
    }
}

#Preview {
    IntroductionView()
}

