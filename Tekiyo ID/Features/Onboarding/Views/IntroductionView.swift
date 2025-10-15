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
    #if DEBUG
    @State private var showDebugControls = false
    #endif
    
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
        #if DEBUG
        .overlay(alignment: .topTrailing) {
            VStack {
                Button(action: {
                    showDebugControls.toggle()
                }) {
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
                
                if showDebugControls {
                    VStack(spacing: 8) {
                        Button("Étape 1") {
                            viewModel.setStep(1)
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .clipShape(Capsule())
                        
                        Button("Étape 2") {
                            viewModel.setStep(2)
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .clipShape(Capsule())
                        
                        Button("Étape 3") {
                            viewModel.setStep(3)
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .clipShape(Capsule())
                        
                        Button("Passer l'intro") {
                            viewModel.proceedToFaceID()
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .clipShape(Capsule())
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        #endif
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
