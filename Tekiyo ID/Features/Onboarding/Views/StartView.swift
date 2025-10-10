import SwiftUI

struct StartView: View {
    @StateObject private var viewModel = StartViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("VectorLogo")
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .accessibilityLabel("Logo de l'application")

                Spacer()

                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    .font(.system(size: 22, weight: .medium))
                    .appTypography(fontSize: 22)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 48)

                Spacer()

                PrimaryButton(
                    title: "Commencer",
                    action: viewModel.startOnboarding
                )
                .padding(.horizontal, 48)
                .accessibilityHint("Démarrer l'application")
            }
            .padding(.vertical, 48)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .ignoresSafeArea(edges: .bottom)
            .navigationDestination(isPresented: $viewModel.shouldNavigateToIntroduction) {
                IntroductionView()
            }
        }
        .debugRenders("StartView")
    }
}

#Preview {
    StartView()
}
