import SwiftUI
import UIKit

struct ProfileView: View {
    let identityData: Tekiyo_ID.IdentityData
    let profileImage: UIImage?
    let tekiyoID: String
    let username: String
    
    @StateObject private var viewModel = ProfileViewModel()
    @State private var trustScore: Int = 3 // Out of 10
    @State private var lastVerification: String = "il y a 2 jours"
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Global Background - OLED Black
            Color(hex: "111111")
                .ignoresSafeArea(.all)
            
            // Content ScrollView - Full screen
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
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 160)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .onAppear {
            viewModel.requestLocation()
        }
        .debugRenders("ProfileView")
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
            profileImage: (nil as UIImage?),
            tekiyoID: "3A1B-7E21",
            username: "@marieD77"
        )
    }
}

