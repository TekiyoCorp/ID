import SwiftUI

struct ProfileView: View {
    let identityData: IdentityData
    let profileImage: UIImage?
    let tekiyoID: String
    let username: String
    
    @State private var trustScore: Int = 3 // Out of 10
    @State private var lastVerification: String = "il y a 2 jours"
    @State private var showActivitiesOverlay = false
    
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with profile info
                    VStack(spacing: 16) {
                    // Profile picture (agrandie de 25%)
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 125, height: 125)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Self.profileBorderGradient, lineWidth: 3)
                            )
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 125, height: 125)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    VStack(spacing: 6) {
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
                    }
                    
                    // Métier + Localisation
                    HStack(spacing: 8) {
                        Text(identityData.metier)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.primary)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 1, height: 12)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            Text(identityData.ville)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 12)
                
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
                            
                            Image(systemName: "checkmark.fill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "002FFF"))
                        .clipShape(Capsule())
                    }
                    .padding(.bottom, 34)
                    
                    // Trust score
                    VStack(spacing: 8) {
                        Text("Trust score")
                            .font(.system(size: 22, weight: .medium))
                            .kerning(-1.32)
                            .foregroundColor(.primary)
                        
                        // Score indicator
                        HStack(spacing: 4) {
                            ForEach(0..<10, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(index < trustScore ? Color(hex: "002FFF") : Color.gray.opacity(0.3))
                                    .frame(width: 12, height: 24)
                                    .shadow(
                                        color: index < trustScore ? Color(hex: "FF0000").opacity(0.25) : Color.clear,
                                        radius: 6,
                                        x: 0,
                                        y: 0
                                    )
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
                    
                    OptimizedCircularCodeView(url: "https://tekiyo.fr/\(tekiyoID)")
                        .frame(width: 120, height: 120)
                        .debugRenders("QR Code - ProfileView")
                    
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
                    
                    ProfileActivityCirclesRow(activities: profileActivities)
                        .padding(.leading, 24)
                        .padding(.vertical, 4)
                    
                    Button("Voir plus") {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            showActivitiesOverlay = true
                        }
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
            .blur(radius: showActivitiesOverlay ? 10 : 0, opaque: false)
            .allowsHitTesting(!showActivitiesOverlay)
            
            if showActivitiesOverlay {
                ActivitiesOverlayContainer(
                    isPresented: $showActivitiesOverlay,
                    activities: profileActivities
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
        }
        .background(Color(.systemBackground))
        .toolbar(.hidden, for: .navigationBar)
        .debugRenders("ProfileView")
    }
}

}
private extension ProfileView {
    static let profileBorderGradient = LinearGradient(
        colors: [
            Color(red: 0.61, green: 0.36, blue: 0.9),
            Color(red: 0.0, green: 0.73, blue: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let defaultActivities: [ProfileActivity] = [
        ProfileActivity(
            id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA") ?? UUID(),
            contactName: "Damien R.",
            title: "Connexion avec Damien R.",
            detail: "Connexion confirmée et sécurisée via Tekiyo ID.",
            iconName: "person.2.fill",
            iconColor: Color(hex: "002FFF"),
            backgroundColor: Color(hex: "F5A3BC"),
            timestamp: "Il y a 2 heures"
        ),
        ProfileActivity(
            id: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB") ?? UUID(),
            contactName: "Thomas S.",
            title: "Thomas S. vous a scanné.",
            detail: "Thomas a validé votre identité en scannant votre QR code Tekiyo.",
            iconName: "qrcode",
            iconColor: Color(hex: "0047FF"),
            backgroundColor: Color(hex: "F0E9D2"),
            timestamp: "Il y a 1 heure"
        ),
        ProfileActivity(
            id: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC") ?? UUID(),
            contactName: "Julie F.",
            title: "Julie F. vous fait confiance.",
            detail: "Julie a confirmé qu’elle vous reconnaît et vous fait confiance.",
            iconName: "hand.thumbsup.fill",
            iconColor: Color(hex: "0061FF"),
            backgroundColor: Color(hex: "F9C7A0"),
            timestamp: "Hier"
        ),
        ProfileActivity(
            id: UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD") ?? UUID(),
            contactName: "Laura M.",
            title: "Laura M. a partagé ton ID.",
            detail: "Laura a partagé ton identité Tekiyo avec son cercle.",
            iconName: "arrowshape.turn.up.right.fill",
            iconColor: Color(hex: "FF6B35"),
            backgroundColor: Color(hex: "0F0F0F"),
            timestamp: "Il y a 3 jours"
        )
    ]
    
    var profileActivities: [ProfileActivity] {
        Self.defaultActivities
    }
    
    struct ProfileActivity: Identifiable, Hashable {
        let id: UUID
        let contactName: String
        let title: String
        let detail: String
        let iconName: String
        let iconColor: Color
        let backgroundColor: Color
        let timestamp: String
        
        var initials: String {
            contactName
                .split(whereSeparator: { !$0.isLetter })
                .compactMap { $0.first }
                .prefix(2)
                .map { String($0).uppercased() }
                .joined()
        }
    }
}

// MARK: - Interactive Activity Circles
private struct ProfileActivityCirclesRow: View {
    let activities: [ProfileView.ProfileActivity]
    
    var body: some View {
        HStack(spacing: -40) {
            ForEach(Array(activities.enumerated()), id: \.element.id) { index, activity in
                ActivityCircleView(activity: activity, opacity: opacity(for: index))
                    .zIndex(Double(activities.count - index))
            }
        }
        .padding(.trailing, CGFloat(max(activities.count - 1, 0)) * 40)
    }
    
    private func opacity(for index: Int) -> Double {
        let base: Double = 0.7
        let step: Double = 0.15
        return min(1.0, base + step * Double((activities.count - 1) - index))
    }
}

private struct ActivityCircleView: View {
    let activity: ProfileView.ProfileActivity
    let opacity: Double
    
    var body: some View {
        Circle()
            .fill(activity.backgroundColor)
            .frame(width: 82, height: 82)
            .overlay(
                Text(activity.initials)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.white)
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.4), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 6)
            .opacity(opacity)
    }
}

// MARK: - Activities Overlay
private struct ActivitiesOverlayContainer: View {
    @Binding var isPresented: Bool
    let activities: [ProfileView.ProfileActivity]
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .trailing) {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture(perform: close)
                
                ActivitiesOverlayPanel(activities: activities, onClose: close)
                    .frame(width: min(proxy.size.width * 0.85, 340))
                    .offset(x: max(0, dragOffset))
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                if value.translation.width > 0 {
                                    state = value.translation.width
                                }
                            }
                            .onEnded { value in
                                if value.translation.width > 140 {
                                    close()
                                }
                            }
                    )
                    .padding(.vertical, max(24, proxy.safeAreaInsets.top + 16))
                    .padding(.trailing, 16)
            }
        }
    }
    
    private func close() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85, blendDuration: 0.25)) {
            isPresented = false
        }
    }
}

private struct ActivitiesOverlayPanel: View {
    let activities: [ProfileView.ProfileActivity]
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Activités récentes")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(activities) { activity in
                        ActivityOverlayRow(activity: activity)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(24)
        .frame(maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.25), radius: 24, x: 0, y: 18)
        )
    }
}

private struct ActivityOverlayRow: View {
    let activity: ProfileView.ProfileActivity
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(activity.backgroundColor)
                .frame(width: 48, height: 48)
                .overlay(
                    Text(activity.initials)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                )
                .overlay(
                    Circle().stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(activity.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(activity.detail)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(activity.timestamp)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: activity.iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(activity.iconColor)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.06))
        )
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
                nationalite: "Française",
                metier: "Directrice artistique",
                ville: "Paris"
            ),
            profileImage: nil,
            tekiyoID: "3A1B-7E21",
            username: "@marieD77"
        )
    }
}
