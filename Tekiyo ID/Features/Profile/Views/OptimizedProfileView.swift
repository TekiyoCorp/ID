import SwiftUI

struct OptimizedProfileView: View {
    let identityData: IdentityData
    let profileImage: UIImage?
    let tekiyoID: String
    let username: String
    
    @State private var trustScore: Int = 3
    @State private var lastVerification: String = "il y a 2 jours"
    @State private var shouldNavigateToActivities = false
    @State private var showActivitiesOverlay = false
    @State private var searchText = ""
    
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
                
                // Recent activities - Centered with blur and destack animation
                RecentActivitiesCardView(
                    showOverlay: $showActivitiesOverlay,
                    searchText: $searchText
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
        .overlay(
            // Activities Overlay with blur background
            Group {
                if showActivitiesOverlay {
                    ActivitiesOverlayView(
                        searchText: $searchText,
                        showOverlay: $showActivitiesOverlay
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.9)),
                        removal: .opacity.combined(with: .scale(scale: 1.1))
                    ))
                    .zIndex(1000)
                }
            }
        )
        .animation(.easeInOut(duration: 0.3), value: showActivitiesOverlay)
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
            
            // TODO: Restore OptimizedCircularCodeView when QR code functionality is needed
            // Temporarily replaced with simple blue circle
            Circle()
                .fill(Color.blue)
                .frame(width: 120, height: 120)
            
            Text("Ce code QR prouve ton humanité.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.primary)
                .opacity(0.7)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Recent Activities Card Component with Destack Animation
struct RecentActivitiesCardView: View {
    @Binding var showOverlay: Bool
    @Binding var searchText: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Activités récentes")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary)
            
            // Stacked activities with blur effect
            VStack(spacing: 8) {
                ActivityRow(
                    profileImage: "person.circle.fill",
                    title: "Connexion avec Damien R.",
                    icon: "person.2.fill",
                    color: .blue
                )
                .blur(radius: 2)
                .scaleEffect(0.95)
                
                ActivityRow(
                    profileImage: "person.circle.fill",
                    title: "Thomas S. vous a scanné.",
                    icon: "qrcode",
                    color: .blue
                )
                .blur(radius: 1)
                .scaleEffect(0.98)
                
                ActivityRow(
                    profileImage: "person.circle.fill",
                    title: "Julie F. vous fait confiance.",
                    icon: "hand.thumbsup.fill",
                    color: .blue
                )
                .scaleEffect(1.0)
            }
            .frame(maxWidth: 250)
            .onTapGesture {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showOverlay = true
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Social Links Section Component
struct SocialLinksSectionView: View {
    var body: some View {
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
    }
}

// MARK: - Activities Overlay View
struct ActivitiesOverlayView: View {
    @Binding var searchText: String
    @Binding var showOverlay: Bool
    
    var body: some View {
        ZStack {
            // Blur background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showOverlay = false
                    }
                }
            
            // Content card
            VStack(spacing: 20) {
                // Liquid Glass Search Bar
                LiquidGlassSearchBar(searchText: $searchText)
                    .padding(.horizontal, 20)
                
                // Activities list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredActivities, id: \.id) { activity in
                            EnhancedActivityRow(
                                profileImage: activity.profileImage,
                                profileColor: activity.profileColor,
                                title: activity.title,
                                icon: activity.icon,
                                color: activity.color
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 400)
            }
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 20)
        }
    }
    
    private var filteredActivities: [ActivityData] {
        if searchText.isEmpty {
            return allActivities
        } else {
            return allActivities.filter { activity in
                activity.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private let allActivities = [
        ActivityData(id: 1, profileImage: "person.circle.fill", profileColor: .orange, title: "Connexion avec Damien R.", icon: "person.2.fill", color: .blue),
        ActivityData(id: 2, profileImage: "person.circle.fill", profileColor: .gray, title: "Thomas S. vous a scanné.", icon: "square.dashed.inset.filled", color: .blue),
        ActivityData(id: 3, profileImage: "person.circle.fill", profileColor: .pink.opacity(0.6), title: "Julie F. vous fait confiance.", icon: "hand.thumbsup.fill", color: .blue),
        ActivityData(id: 4, profileImage: "person.circle.fill", profileColor: .orange, title: "Connexion avec Damien R.", icon: "person.2.fill", color: .blue),
        ActivityData(id: 5, profileImage: "person.circle.fill", profileColor: .gray, title: "Thomas S. vous a signalé.", icon: "exclamationmark.octagon.fill", color: .red),
        ActivityData(id: 6, profileImage: "person.circle.fill", profileColor: .pink.opacity(0.6), title: "Julie F. vous fait confiance.", icon: "hand.thumbsup.fill", color: .blue),
        ActivityData(id: 7, profileImage: "person.circle.fill", profileColor: .orange, title: "Connexion avec Damien R.", icon: "person.2.fill", color: .blue),
        ActivityData(id: 8, profileImage: "person.circle.fill", profileColor: .orange, title: "Connexion avec Damien R.", icon: "person.2.fill", color: .blue),
        ActivityData(id: 9, profileImage: "person.circle.fill", profileColor: .gray, title: "Thomas S. vous a scanné.", icon: "square.dashed.inset.filled", color: .blue)
    ]
}

// MARK: - Liquid Glass Search Bar
struct LiquidGlassSearchBar: View {
    @Binding var searchText: String
    @State private var isSearching = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary.opacity(0.6))
            
            TextField("Rechercher dans les activités...", text: $searchText)
                .font(.system(size: 16, weight: .regular))
                .textFieldStyle(PlainTextFieldStyle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        isSearching = true
                    }
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        searchText = ""
                        isSearching = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(isSearching ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSearching)
    }
}

// MARK: - Activity Data Model
struct ActivityData {
    let id: Int
    let profileImage: String
    let profileColor: Color
    let title: String
    let icon: String
    let color: Color
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
