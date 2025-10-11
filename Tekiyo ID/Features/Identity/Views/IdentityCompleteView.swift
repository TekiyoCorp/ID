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
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Title at Y=108
                VStack(spacing: 12) {
                    // Title
                    LargeTitle("Ton identité est prête.", alignment: .center)
                    
                    // Subtitle - 12px gap
                    Text("Tu es désormais vérifié, unique et anonyme à la fois.")
                        .font(.system(size: 18, weight: .regular))
                        .appTypography(fontSize: 18)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 48)
                }
                .frame(maxWidth: .infinity)
                .offset(y: 108)
                
                // Profile Card at Y=241 - 254x254, padding 24, border radius 24
                VStack(spacing: 12) {
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
                    
                    // Username - 6px gap
                    Text(viewModel.username)
                        .font(.system(size: 14, weight: .regular))
                        .appTypography(fontSize: 14)
                        .foregroundStyle(.secondary)
                        .padding(.top, -6) // 6px gap au lieu de 12
                    
                    // Separator - 12px gap
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                    
                    // Tekiyo ID - 12px gap
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
                .frame(width: 254, height: 254)
                .padding(24)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .offset(y: 241)
                
                // Action Button at bottom
                VStack {
                    Spacer()
                    
                    PrimaryButton(
                        title: "Afficher mon profil Tekiyo",
                        style: .blue,
                        action: {
                            shouldNavigateToProfile = true
                        }
                    )
                    .padding(.horizontal, 48)
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            nationalite: "France",
            metier: "Directrice artistique",
            ville: "Paris"
        ),
        profileImage: nil
    )
}
