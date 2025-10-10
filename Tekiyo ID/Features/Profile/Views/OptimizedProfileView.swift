import SwiftUI
import Combine

enum ProfileStep: Int, CaseIterable {
    case nationalite
    case resume
}

final class ProfileScreenState: ObservableObject {
    @Published var trustScore: Int
    @Published var lastVerification: String
    @Published var shouldNavigateToActivities = false
    @Published var showActivitiesOverlay = false
    @Published var searchText = ""
    
    @Published var selectedNationality: String = ""
    @Published var currentStep: ProfileStep = .nationalite
    @Published var completedSteps: Set<ProfileStep> = []
    
    var isNationalityComplete: Bool { !selectedNationality.isEmpty }
    
    init(trustScore: Int = 3, lastVerification: String = "il y a 2 jours") {
        self.trustScore = trustScore
        self.lastVerification = lastVerification
    }
}

struct OptimizedProfileView: View {
    let identityData: IdentityData
    let profileImage: UIImage?
    let tekiyoID: String
    let username: String
    
    @StateObject private var state: ProfileScreenState
    
    // Pre-computed values to avoid recalculation
    private let fullName: String
    private let profileImageHash: String
    
    private let countries = ["", "France", "Belgique", "Suisse", "Canada", "Maroc"]
    
    init(identityData: IdentityData, profileImage: UIImage?, tekiyoID: String, username: String) {
        self.identityData = identityData
        self.profileImage = profileImage
        self.tekiyoID = tekiyoID
        self.username = username
        self._state = StateObject(wrappedValue: ProfileScreenState())
        
        // Pre-compute expensive operations
        self.fullName = "\(identityData.prenom) \(identityData.nom)"
        self.profileImageHash = profileImage?.description ?? "placeholder"
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    // STEP: Nationalité
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Nationalité")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Picker("Choisir un pays", selection: $state.selectedNationality) {
                            ForEach(countries, id: \.self) { country in
                                Text(country.isEmpty ? "Sélectionner" : country).tag(country)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color(hex: "002FFF"))
                        .accessibilityLabel("Choisir la nationalité")
                        
                        // Debug: Afficher la valeur sélectionnée
                        #if DEBUG
                        Text("Sélectionné: '\(state.selectedNationality)' - Complete: \(state.isNationalityComplete ? "Oui" : "Non")")
                            .font(.caption)
                            .foregroundColor(.gray)
                        #endif
                        
                        // Bouton Suivant (visible dès qu'une nationalité est sélectionnée)
                        if !state.selectedNationality.isEmpty && state.selectedNationality != "" {
                            Button(action: {
                                state.completedSteps.insert(.nationalite)
                                state.currentStep = .resume
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(ProfileStep.resume, anchor: .top)
                                }
                            }) {
                                Text("Suivant")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(hex: "002FFF"))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .accessibilityLabel("Continuer vers le profil")
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                    .id(ProfileStep.nationalite)

                    // GATE: Afficher la suite uniquement si nationalité complétée
                    if state.completedSteps.contains(.nationalite) {
                        // Header with profile info
                        ProfileHeaderView(
                            profileImage: profileImage,
                            fullName: fullName,
                            username: username,
                            metier: identityData.metier,
                            ville: identityData.ville
                        )
                        .padding(.top, 0)
                        .padding(.bottom, 12)
                        .id(ProfileStep.resume)

                        // Verification section
                        VerificationSectionView(
                            trustScore: state.trustScore,
                            lastVerification: state.lastVerification
                        )
                        .padding(.bottom, 32)

                        // Share ID section
                        ShareIDSectionView(tekiyoID: tekiyoID)
                        .padding(.bottom, 32)

                        // Recent activities - Centered with blur and destack animation
                        RecentActivitiesCardView(
                            showOverlay: $state.showActivitiesOverlay,
                            searchText: $state.searchText
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)

                        // Links section
                        SocialLinksSectionView()
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .onAppear {
                if state.selectedNationality.isEmpty, !identityData.nationalite.isEmpty {
                    state.selectedNationality = identityData.nationalite
                    state.completedSteps.insert(.nationalite)
                    state.currentStep = .resume
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            proxy.scrollTo(ProfileStep.resume, anchor: .top)
                        }
                    }
                }
            }
        }
        // Fallback for NavigationView environments
        NavigationLink(destination: RecentActivitiesView(), isActive: $state.shouldNavigateToActivities) {
            EmptyView()
        }
        .hidden()
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $state.shouldNavigateToActivities) {
            RecentActivitiesView()
        }
        .overlay(
            // Activities Overlay with blur background
            Group {
                if state.showActivitiesOverlay {
                    ActivitiesOverlayView(
                        searchText: $state.searchText,
                        showOverlay: $state.showActivitiesOverlay
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.9)),
                        removal: .opacity.combined(with: .scale(scale: 1.1))
                    ))
                    .zIndex(1000)
                }
            }
        )
        .debugRenders("OptimizedProfileView")
    }
}

// MARK: - Profile Header Component
struct ProfileHeaderView: View {
    let profileImage: UIImage?
    let fullName: String
    let username: String
    let metier: String
    let ville: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile picture with optimized gradient (agrandie de 25%)
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 125, height: 125)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(StaticGradient.profileBorder, lineWidth: 3)
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
            }
            
            // Métier + Localisation
            HStack(spacing: 8) {
                Text(metier)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.primary)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 12)
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text(ville)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.primary)
                }
            }
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
                
                // Score indicator - optimized with single HStack
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
    }
}

// MARK: - Share ID Section Component
struct ShareIDSectionView: View {
    private let codeURL: String
    
    init(tekiyoID: String) {
        self.codeURL = "https://tekiyo.fr/\(tekiyoID)"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Partager mon ID")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.blue)
            
            OptimizedCircularCodeView(url: codeURL)
                .frame(width: 120, height: 120)
                .accessibilityLabel("Code Tekiyo à partager")
                .debugRenders("QR Code - OptimizedProfileView")
            
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
            VStack(spacing: 0) {
                ActivityRow(
                    profileImage: "person.circle.fill",
                    title: "Connexion avec Damien R.",
                    icon: "person.2.fill",
                    color: .blue
                )
                .opacity(0.65)
                .scaleEffect(0.95)
                .offset(y: -12)
                .allowsHitTesting(false)
                
                ActivityRow(
                    profileImage: "person.circle.fill",
                    title: "Thomas S. vous a scanné.",
                    icon: "qrcode",
                    color: .blue
                )
                .opacity(0.82)
                .scaleEffect(0.98)
                .offset(y: -4)
                .allowsHitTesting(false)
                
                ActivityRow(
                    profileImage: "person.circle.fill",
                    title: "Julie F. vous fait confiance.",
                    icon: "hand.thumbsup.fill",
                    color: .blue
                )
                .allowsHitTesting(false)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: 250)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
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
            // Dimmed background without live blur to avoid continuous GPU work
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
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
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground).opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 10)
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
                    if !isSearching {
                        isSearching = true
                    }
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isSearching = false
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
                .fill(Color(.systemBackground).opacity(0.9))
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
        .animation(.easeInOut(duration: 0.2), value: isSearching)
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
    NavigationStack {
        OptimizedProfileView(
            identityData: IdentityData(
                nom: "Dupont",
                prenom: "Marie",
                dateNaissance: Date(),
                nationalite: "Française",
                metier: "Développeuse iOS",
                ville: "Paris"
            ),
            profileImage: nil,
            tekiyoID: "3A1B-7E21",
            username: "@marieD77"
        )
    }
}
