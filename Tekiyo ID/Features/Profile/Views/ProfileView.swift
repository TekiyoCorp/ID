import SwiftUI

struct ProfileView: View {
    let identityData: IdentityData
    let profileImage: UIImage?
    let tekiyoID: String
    let username: String
    
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab: BottomNavigationBar.TabItem = .grid
    @State private var trustScore: Int = 3 // Out of 10
    @State private var lastVerification: String = "il y a 2 jours"
    @State private var showActivitiesOverlay = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Global Background - OLED Black
            Color(hex: "111111")
                .ignoresSafeArea(.all)
            
            // Content ScrollView - Transparent and stops before TabBar
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header (Top Bar) - FIXED, NO BACKGROUND
                    headerView
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 24) {
                        // Location & Greeting
                        locationAndGreetingView
                            .padding(.top, 20)
                        
                        // Grand CircularCodeView
                        circularCodeView
                        
                        // Score Indicator
                        scoreIndicatorView
                        
                        // WalletWidget - Centered with fixed width
                        WalletWidget()
                            .frame(maxWidth: 342)
                            .padding(.horizontal, 16)
                        
                        // Links Section
                        linksSection
                            .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 96) // Space for floating TabBar
                }
            }
            .scrollContentBackground(.hidden) // Hide ScrollView background
            .background(Color.clear) // Transparent background
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80) // Stop ScrollView before TabBar
            }
            
            // Activities Overlay
            if showActivitiesOverlay {
                ActivitiesOverlayContainer(
                    isPresented: $showActivitiesOverlay,
                    activities: profileActivities
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
            
            // TabBar - Independent overlay
            tabBarView
                .background(Color.clear)
                .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            viewModel.requestLocation()
        }
        .debugRenders("ProfileView")
    }
    
    // MARK: - TabBar View
    private var tabBarView: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            Color.clear
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(BottomNavigationBar.TabItem.home)
            
            // Grid Tab (Active)
            Color.clear
                .tabItem {
                    Image(systemName: "square.grid.3x3")
                    Text("Grid")
                }
                .tag(BottomNavigationBar.TabItem.grid)
            
            // Bell Tab
            Color.clear
                .tabItem {
                    Image(systemName: "bell")
                    Text("Notifications")
                }
                .tag(BottomNavigationBar.TabItem.bell)
            
            // Wallet Tab
            Color.clear
                .tabItem {
                    Image(systemName: "wallet.pass")
                    Text("Wallet")
                }
                .tag(BottomNavigationBar.TabItem.wallet)
        }
        .frame(height: 60)
        .background(Color.clear)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            // Profile Photo (43x43px) - LEFT SIDE
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 43, height: 43)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Self.profileBorderGradient, lineWidth: 2)
                    )
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 43, height: 43)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    )
            }
            
            Spacer()
            
            // Search Button (43x43px, liquid glass) - RIGHT SIDE
            Button(action: {
                // Handle search
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 32, height: 32)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Location & Greeting
    private var locationAndGreetingView: some View {
        VStack(spacing: 8) {
            // Sun icon + City
            HStack(spacing: 6) {
                Image(systemName: "sun.max")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                Text(viewModel.getDisplayCity())
                    .font(.custom("SF Pro Display", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(0.8)
            }
            
            // Greeting
            Text("Bonjour \(identityData.prenom)!")
                .font(.custom("SF Pro Display", size: 28))
                .fontWeight(.medium)
                .kerning(-1.68) // -6% of 28px
                .foregroundColor(.white.opacity(0.9))
        }
    }
    
    // MARK: - Circular Code View
    private var circularCodeView: some View {
        VStack(spacing: 12) { // Harmonized spacing
            LargeCircularCodeView(url: "https://tekiyo.fr/\(tekiyoID)")
                .frame(width: 194, height: 194)
            
            Text("Ce code QR prouve ton humanité.")
                .font(.custom("SF Pro Display", size: 14))
                .fontWeight(.regular)
                .foregroundColor(.white.opacity(0.9))
                .opacity(0.7)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Score Indicator
    private var scoreIndicatorView: some View {
        VStack(spacing: 12) { // Harmonized spacing
            // Score bars
            HStack(spacing: 4) {
                ForEach(0..<10, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(index < trustScore ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 24)
                        .shadow(
                            color: index < trustScore ? Color.red.opacity(0.35) : Color.clear,
                            radius: 8,
                            x: 0,
                            y: 0
                        )
                }
            }
            
            // Percentage
            Text("27%")
                .font(.custom("SF Pro Display", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.9))
            
            // Last verification
            Text("Dernière vérification : \(lastVerification)")
                .font(.custom("SF Pro Display", size: 12))
                .fontWeight(.regular)
                .foregroundColor(.white.opacity(0.9))
            
            // Help link
            Button("Comment augmenter mon score ?") {
                // Handle score increase info
            }
            .font(.custom("SF Pro Display", size: 12))
            .fontWeight(.regular)
            .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: - Links Section
    private var linksSection: some View {
        VStack(alignment: .center, spacing: 12) { // Harmonized spacing
            Text("Liens")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
            
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
        .frame(maxWidth: 280) // Max width comme dans l'image
    }
    
}

// MARK: - Extensions
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
            detail: "Julie a confirmé qu'elle vous reconnaît et vous fait confiance.",
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