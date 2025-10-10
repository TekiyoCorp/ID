import SwiftUI

struct ProfileView: View {
    let identityData: IdentityData
    let profileImage: UIImage?
    let tekiyoID: String
    let username: String
    
    @State private var trustScore: Int = 3 // Out of 10
    @State private var lastVerification: String = "il y a 2 jours"
    @State private var shouldNavigateToActivities = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with profile info
                VStack(spacing: 16) {
                    // Profile picture
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(red: 0.61, green: 0.36, blue: 0.9), Color(red: 0.0, green: 0.73, blue: 1.0)], // #9b5de5, #00bbff
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
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
                    Text("\(identityData.prenom) \(identityData.nom)")
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
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                // Verification section
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
                        
                        // Score indicator
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
                .padding(.bottom, 32)
                
                // Share ID section
                VStack(spacing: 16) {
                    Text("Partager mon ID")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.blue)
                    
                    CircularCodeView(url: "https://tekiyo.fr/\(tekiyoID)")
                        .frame(width: 120, height: 120)
                    
                    Text("Ce code QR prouve ton humanité.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.primary)
                        .opacity(0.7)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 32)
                
                // Recent activities
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
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                
                // Links section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Liens")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        SocialCapsuleButton(platform: "Facebook", icon: "f.circle.fill", color: .blue)
                        SocialCapsuleButton(platform: "Twitter", icon: "bird.fill", color: .blue)
                        SocialCapsuleButton(platform: "Instagram", icon: "camera.fill", color: .pink)
                        SocialCapsuleButton(platform: "Snapchat", icon: "ghost.fill", color: .yellow)
                        SocialCapsuleButton(platform: "LinkedIn", icon: "briefcase.fill", color: .blue)
                        SocialCapsuleButton(platform: "GitHub", icon: "terminal.fill", color: .black)
                        SocialCapsuleButton(platform: "TikTok", icon: "music.note", color: .black)
                        SocialCapsuleButton(platform: "Discord", icon: "bubble.left.fill", color: .blue)
                        SocialCapsuleButton(platform: "Telegram", icon: "paperplane.fill", color: .blue)
                        SocialCapsuleButton(platform: "Gmail", icon: "envelope.fill", color: .red)
                        SocialCapsuleButton(platform: "WhatsApp", icon: "bubble.left.and.bubble.right.fill", color: .green)
                        SocialCapsuleButton(platform: "YouTube", icon: "play.rectangle.fill", color: .red)
                    }
                }
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

// MARK: - Activity Row Component
struct ActivityRow: View {
    let profileImage: String
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: profileImage)
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                )
            
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Enhanced Activity Row Component (for RecentActivitiesView)
struct EnhancedActivityRow: View {
    let profileImage: String
    let profileColor: Color
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(profileColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: profileImage)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                )
            
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Social Capsule Button Component
struct SocialCapsuleButton: View {
    let platform: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Handle social link tap
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Text(platform)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .clipShape(Capsule())
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ProfileView(
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
