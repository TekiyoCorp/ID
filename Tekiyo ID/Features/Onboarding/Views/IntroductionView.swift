import SwiftUI

private extension AnyTransition {
    static var flowOpacity: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 10)),
            removal: .opacity.combined(with: .offset(y: -10))
        )
    }
}

struct IntroductionView: View {
    @StateObject private var viewModel = IntroductionViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Group {
                if viewModel.currentStep == 1 {
                    stepOne
                } else if viewModel.currentStep == 2 {
                    stepTwo
                } else {
                    stepThree
                }
            }
            .id(viewModel.currentStep)
            .transition(.flowOpacity)
            .animation(.easeInOut(duration: 0.18), value: viewModel.currentStep)
            
            Spacer()
            
            if viewModel.currentStep == 3 {
                PrimaryButton(
                    icon: "chevron.right",
                    action: viewModel.proceedToFaceID
                )
                .transition(.flowOpacity)
            } else {
                Text("Inclinez votre téléphone vers la droite")
                    .font(.system(size: 13, weight: .regular))
                    .appTypography(fontSize: 13)
                    .foregroundStyle(.primary)
                    .opacity(0.4)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.flowOpacity)
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
        .debugRenders("IntroductionView")
    }
    
    private var stepOne: some View {
        VStack(alignment: .leading, spacing: 12) {
            LargeTitle("Ce que tu es ne devrait pas quitter ton téléphone.")
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Tekiyo ne te regarde pas.")
                    .font(.system(size: 22, weight: .medium))
                    .appTypography(fontSize: 22)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                
                Text("Il te reconnaît, puis t'oublie.")
                    .font(.system(size: 22, weight: .medium))
                    .appTypography(fontSize: 22)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    private var stepTwo: some View {
        VStack(alignment: .leading, spacing: 12) {
            LargeTitle("Les machines imitent.")
            
            Text("Toi, tu existes.")
                .font(.system(size: 22, weight: .medium))
                .appTypography(fontSize: 22)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
        }
    }
    
    private var stepThree: some View {
        VStack(alignment: .leading, spacing: 12) {
            LargeTitle("Un seul ID.")
            
            Text("Dans un monde sans visage.")
                .font(.system(size: 22, weight: .medium))
                .appTypography(fontSize: 22)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    IntroductionView()
}
