import SwiftUI

struct IdentityCompleteView: View {
    @StateObject private var viewModel: IdentityCompleteViewModel
    @State private var shouldNavigateToProfile = false
    
    init(identityData: IdentityData, profileImage: UIImage?) {
        self._viewModel = StateObject(wrappedValue: IdentityCompleteViewModel(
            identityData: identityData,
            profileImage: profileImage
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 60)
                
                // Title
                LargeTitle("Ton identité est prête.", alignment: .center)
                
                // Subtitle
                Text("Tu es désormais vérifié, unique et anonyme à la fois.")
                    .font(.system(size: 18, weight: .regular))
                    .appTypography(fontSize: 18)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 48)
                
                // Profile Card
                VStack(spacing: 16) {
                    // Profile Photo
                    if let profileImage = viewModel.profileUIImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(.systemGray5), lineWidth: 1)
                            )
                    } else {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.secondary)
                            )
                    }
                    
                    // Name
                    Text(viewModel.fullName)
                        .font(.system(size: 18, weight: .semibold))
                        .appTypography(fontSize: 18)
                        .foregroundStyle(.primary)
                    
                    // Username
                    Text(viewModel.username)
                        .font(.system(size: 14, weight: .regular))
                        .appTypography(fontSize: 14)
                        .foregroundStyle(.secondary)
                    
                    // Separator
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                    
                    // Tekiyo ID
                    HStack {
                        Text("Tekiyo ID")
                            .font(.system(size: 14, weight: .regular))
                            .appTypography(fontSize: 14)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(viewModel.tekiyoID)
                            .font(.system(size: 14, weight: .semibold))
                            .appTypography(fontSize: 14)
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(24)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 48)
                
                // QR Code Section
                VStack(spacing: 12) {
                    OptimizedCircularCodeView(url: "https://tekiyo.fr/\(viewModel.tekiyoID)")
                        .frame(width: 120, height: 120)
                        .debugRenders("QR Code - IdentityCompleteView")
                    
                    Text("Ce code QR prouve ton humanité.")
                        .font(.system(size: 16, weight: .regular))
                        .appTypography(fontSize: 16)
                        .foregroundStyle(.primary)
                        .opacity(0.7)
                        .multilineTextAlignment(.center)
                }
                
                Spacer(minLength: 40)
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button("Partager mon ID") {
                        // TODO: Implement share functionality
                    }
                    .font(.system(size: 17, weight: .medium))
                    .appTypography(fontSize: 17)
                    .foregroundStyle(Color(red: 0.0, green: 0.18, blue: 1.0))
                    
                    PrimaryButton(
                        title: "Afficher mon profil Tekiyo",
                        style: .blue,
                        action: {
                            shouldNavigateToProfile = true
                        }
                    )
                    .padding(.horizontal, 48)
                }
                
                Spacer(minLength: 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $shouldNavigateToProfile) {
            ProfileView(
                identityData: viewModel.identityData,
                profileImage: viewModel.profileUIImage,
                tekiyoID: viewModel.tekiyoID,
                username: viewModel.username
            )
        }
        .debugRenders("IdentityCompleteView")
    }
}

#Preview {
    IdentityCompleteView(
        identityData: IdentityData(
            nom: "Dupont",
            prenom: "Marie",
            dateNaissance: Date(),
            nationalite: "France"
        ),
        profileImage: nil
    )
}
