import SwiftUI

struct StartView: View {
    @State private var goToIntroduction = false
    var body: some View {
        NavigationStack {
            VStack {
                // Top: SVG Logo
                Image("VectorLogo")
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .drawingGroup()
                    .accessibilityLabel("Logo de l'application")

                Spacer()

                // Center: Lorem Ipsum text
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    .font(.system(size: 22, weight: .medium))
                    .appTypography(fontSize: 22)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 48)

                Spacer()

                // Bottom: Start button
                Button(action: { goToIntroduction = true }) {
                    Text("Commencer")
                        .font(.system(size: 17, weight: .semibold))
                        .appTypography(fontSize: 17)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 293, style: .continuous)
                        .fill(Color.black)
                )
                .padding(.horizontal, 48)
                .accessibilityHint("Démarrer l'application")
            }
            .padding(.vertical, 48)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .ignoresSafeArea(edges: .bottom)
            .navigationDestination(isPresented: $goToIntroduction) {
                IntroductionView()
            }
        }
    }
}

#Preview {
    StartView()
}
