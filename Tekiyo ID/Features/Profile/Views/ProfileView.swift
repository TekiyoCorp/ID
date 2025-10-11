import SwiftUI

struct ProfileView: View {
    let identityData: IdentityData
    let profileImage: UIImage?
    let tekiyoID: String
    let username: String
    
    @State private var trustScore: Int = 3 // Out of 10
    @State private var lastVerification: String = "il y a 2 jours"
    @State private var shouldNavigateToActivities = false
    @State private var selectedActivity: ProfileActivity?
    @Namespace private var activityNamespace
    
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
                    
                    VStack(spacing: 12) {
                        ForEach(profileActivities) { activity in
                            ActivityListItem(
                                activity: activity,
                                namespace: activityNamespace
                            )
                            .opacity(selectedActivity?.id == activity.id ? 0 : 1)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                presentActivity(activity)
                            }
                            .accessibilityElement()
                            .accessibilityLabel(activity.title)
                            .accessibilityAddTraits(.isButton)
                        }
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
            .blur(radius: selectedActivity == nil ? 0 : 10, opaque: false)
            .allowsHitTesting(selectedActivity == nil)
            
            if let activity = selectedActivity {
                ActivityDetailOverlay(
                    activity: activity,
                    namespace: activityNamespace,
                    onClose: dismissSelectedActivity
                )
                .transition(.asymmetric(
                    insertion: AnyTransition.scale(scale: 0.95, anchor: .center)
                        .combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $shouldNavigateToActivities) {
            RecentActivitiesView()
        }
        .debugRenders("ProfileView")
    }
    
    private func presentActivity(_ activity: ProfileActivity) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85, blendDuration: 0.25)) {
            selectedActivity = activity
        }
    }
    
    private func dismissSelectedActivity() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.25)) {
            selectedActivity = nil
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
            timestamp: "Il y a 2 heures"
        ),
        ProfileActivity(
            id: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB") ?? UUID(),
            contactName: "Thomas S.",
            title: "Thomas S. vous a scanné.",
            detail: "Thomas a validé votre identité en scannant votre QR code Tekiyo.",
            iconName: "qrcode",
            iconColor: Color(hex: "0047FF"),
            timestamp: "Il y a 1 heure"
        ),
        ProfileActivity(
            id: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC") ?? UUID(),
            contactName: "Julie F.",
            title: "Julie F. vous fait confiance.",
            detail: "Julie a confirmé qu’elle vous reconnaît et vous fait confiance.",
            iconName: "hand.thumbsup.fill",
            iconColor: Color(hex: "0061FF"),
            timestamp: "Hier"
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
        let timestamp: String
        
    }
}

// MARK: - Interactive Activity Cards
private struct ActivityListItem: View {
    let activity: ProfileView.ProfileActivity
    let namespace: Namespace.ID
    var backgroundColor: Color = Color.gray.opacity(0.1)
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                )
                .matchedGeometryEffect(id: ActivityCardID.avatar(activity.id), in: namespace)
            
            Text(activity.title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.primary)
                .lineLimit(2)
                .matchedGeometryEffect(id: ActivityCardID.title(activity.id), in: namespace)
            
            Spacer()
            
            Image(systemName: activity.iconName)
                .font(.system(size: 16))
                .foregroundColor(activity.iconColor)
                .matchedGeometryEffect(id: ActivityCardID.icon(activity.id), in: namespace)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(backgroundColor)
                .matchedGeometryEffect(id: ActivityCardID.background(activity.id), in: namespace)
        )
        .matchedGeometryEffect(id: ActivityCardID.card(activity.id), in: namespace)
    }
}

private struct ActivityDetailOverlay: View {
    let activity: ProfileView.ProfileActivity
    let namespace: Namespace.ID
    let onClose: () -> Void
    
    @GestureState private var dragOffset: CGFloat = 0
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)
            
            VStack(spacing: 20) {
                ActivityListItem(activity: activity, namespace: namespace, backgroundColor: Color.white.opacity(0.12))
                    .padding(.top, 12)
                
                Divider()
                    .opacity(0.1)
                
                VStack(alignment: .leading, spacing: 12) {
                    Label(activity.timestamp, systemImage: "clock")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(activity.detail)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(24)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.22), radius: 24, x: 0, y: 18)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(Color.white.opacity(0.06))
            )
            .scaleEffect(appeared ? 1 : 0.92)
            .rotationEffect(.degrees(appeared ? 0 : -4))
            .offset(y: dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if value.translation.height > 0 {
                            state = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 120 {
                            onClose()
                        }
                    }
            )
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.82, blendDuration: 0.25)) {
                    appeared = true
                }
            }
            .onDisappear {
                appeared = false
            }
        }
    }
}

private enum ActivityCardID {
    static func card(_ id: UUID) -> String { "activity-card-\(id.uuidString)" }
    static func background(_ id: UUID) -> String { "activity-background-\(id.uuidString)" }
    static func avatar(_ id: UUID) -> String { "activity-avatar-\(id.uuidString)" }
    static func title(_ id: UUID) -> String { "activity-title-\(id.uuidString)" }
    static func icon(_ id: UUID) -> String { "activity-icon-\(id.uuidString)" }
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
