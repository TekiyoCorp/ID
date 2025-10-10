import SwiftUI

struct OptimizedProfileView: View {
    let identityData: IdentityData
    let profileImage: UIImage?
    let tekiyoID: String
    let username: String
    
    @State private var trustScore: Int = 3
    @State private var lastVerification: String = "il y a 2 jours"
    @State private var shouldNavigateToActivities = false
    
    // Pre-computed values to avoid recalculation
    private let fullName: String
    private let profileImageHash: String
    
    init(identityData: IdentityData, profileImage: UIImage?, tekiyoID: String, username: String) {
        self.identityData = identityData
        self.profileImage = profileImage
        self.tekiyoID = tekiyoID
        self.username = username
        
        // Pre-compute expensive operations
        self.fullName = "\(identityData.prenom) \(identityData.nom)"
        self.profileImageHash = profileImage?.description ?? "placeholder"
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) { // Use LazyVStack for better performance
                // Header with profile info
                ProfileHeaderView(
                    profileImage: profileImage,
                    fullName: fullName,
                    username: username
                )
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                // Verification section
                VerificationSectionView(
                    trustScore: trustScore,
                    lastVerification: lastVerification
                )
                .padding(.bottom, 32)
                
                // Share ID section
                ShareIDSectionView(tekiyoID: tekiyoID)
                .padding(.bottom, 32)
                
                // Recent activities
                RecentActivitiesSectionView(
                    shouldNavigateToActivities: $shouldNavigateToActivities
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                
                // Links section
                SocialLinksSectionView()
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $shouldNavigateToActivities) {
            RecentActivitiesView()
        }
    }
}

// MARK: - Profile Header Component
struct ProfileHeaderView: View {
    let profileImage: UIImage?
    let fullName: String
    let username: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile picture with optimized gradient
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(StaticGradient.profileBorder, lineWidth: 3)
                    )
                    .drawingGroup() // Force GPU rendering for complex overlay
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
            
            // Name
            Text(fullName)
                .font(.system(size: 22, weight: .medium))
                .kerning(-0.6)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            // Username
            Text(username)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            // Role tag
            Text("Directrice artistique")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Verification Section Component
struct VerificationSectionView: View {
    let trustScore: Int
    let lastVerification: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Verification button
            Button(action: {
                // Handle verification
            }) {
                HStack(spacing: 8) {
                    Text("Obtenir le badge vérifié")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .clipShape(Capsule())
            }
            
            // Trust score
            VStack(spacing: 8) {
                Text("Trust score")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
                
                // Score indicator - optimized with single HStack
                HStack(spacing: 4) {
                    ForEach(0..<10, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index < trustScore ? Color.red : Color.gray.opacity(0.3))
                            .frame(width: 20, height: 8)
                    }
                }
                
                Text("Dernière vérification : \(lastVerification)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.primary)
                
                Button("Comment augmenter mon score ?") {
                    // Handle score increase info
                }
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - Share ID Section Component
struct ShareIDSectionView: View {
    let tekiyoID: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Partager mon ID")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.blue)
            
            OptimizedCircularCodeView(url: "https://tekiyo.fr/\(tekiyoID)")
                .frame(width: 120, height: 120)
            
            Text("Ce code QR prouve ton humanité.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.primary)
                .opacity(0.7)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Recent Activities Section Component
struct RecentActivitiesSectionView: View {
    @Binding var shouldNavigateToActivities: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activités récentes")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ActivityRow(
                    profileImage: "person.circle.fill",
                    title: "Connexion avec Damien R.",
                    icon: "person.2.fill",
                    color: .blue
                )
                
                ActivityRow(
                    profileImage: "person.circle.fill",
                    title: "Thomas S. vous a scanné.",
                    icon: "qrcode",
                    color: .blue
                )
                
                ActivityRow(
                    profileImage: "person.circle.fill",
                    title: "Julie F. vous fait confiance.",
                    icon: "hand.thumbsup.fill",
                    color: .blue
                )
            }
            .frame(maxWidth: 250)
            
            Button("Voir plus") {
                shouldNavigateToActivities = true
            }
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
    }
}

// MARK: - Social Links Section Component
struct SocialLinksSectionView: View {
    // Pre-computed social links data
    private let socialLinks = [
        ("Facebook", "f.circle.fill", Color.blue),
        ("Twitter", "bird.fill", Color.blue),
        ("Instagram", "camera.fill", Color.pink),
        ("Snapchat", "ghost.fill", Color.yellow),
        ("LinkedIn", "briefcase.fill", Color.blue),
        ("GitHub", "terminal.fill", Color.black),
        ("TikTok", "music.note", Color.black),
        ("Discord", "bubble.left.fill", Color.blue),
        ("Telegram", "paperplane.fill", Color.blue),
        ("Gmail", "envelope.fill", Color.red),
        ("WhatsApp", "bubble.left.and.bubble.right.fill", Color.green),
        ("YouTube", "play.rectangle.fill", Color.red)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Liens")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(socialLinks, id: \.0) { platform, icon, color in
                    SocialCapsuleButton(platform: platform, icon: icon, color: color)
                }
            }
        }
    }
}

// MARK: - Static Gradient Helper
struct StaticGradient {
    static let profileBorder = LinearGradient(
        colors: [Color(red: 0.61, green: 0.36, blue: 0.9), Color(red: 0.0, green: 0.73, blue: 1.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Preview
#Preview {
    NavigationView {
        OptimizedProfileView(
            identityData: IdentityData(
                nom: "Dupont",
                prenom: "Marie",
                dateNaissance: Date(),
                nationalite: "Française"
            ),
            profileImage: nil,
            tekiyoID: "3A1B-7E21",
            username: "@marieD77"
        )
    }
}
