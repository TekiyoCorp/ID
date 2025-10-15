import SwiftUI

/// Native tab container wrapping the profile and companion tabs.
struct ProfileTabContainerView: View {
    enum Tab: Hashable {
        case home
        case tekiyoID
        case notifications
        case wallet
        
        var label: String {
            switch self {
            case .home: return "Accueil"
            case .tekiyoID: return "Tekiyo ID"
            case .notifications: return "Notifications"
            case .wallet: return "Portefeuille"
            }
        }
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .tekiyoID: return "square.grid.3x3.fill"
            case .notifications: return "bell.fill"
            case .wallet: return "wallet.pass.fill"
            }
        }
    }
    
    @State private var selectedTab: Tab = .tekiyoID
    
    let identityData: Tekiyo_ID.IdentityData
    let profileImage: UIImage?
    let tekiyoID: String
    let username: String
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PlaceholderTabView(title: "Accueil")
                .tabItem {
                    Label(Tab.home.label, systemImage: Tab.home.icon)
                }
                .tag(Tab.home)
            
            ProfileView(
                identityData: identityData,
                profileImage: profileImage,
                tekiyoID: tekiyoID,
                username: username
            )
            .tabItem {
                Label(Tab.tekiyoID.label, systemImage: Tab.tekiyoID.icon)
            }
            .tag(Tab.tekiyoID)
            
            PlaceholderTabView(title: "Notifications")
                .tabItem {
                    Label(Tab.notifications.label, systemImage: Tab.notifications.icon)
                }
                .tag(Tab.notifications)
            
            PlaceholderTabView(title: "Portefeuille")
                .tabItem {
                    Label(Tab.wallet.label, systemImage: Tab.wallet.icon)
                }
                .tag(Tab.wallet)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.16),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
                .blendMode(.overlay)
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false)
        }
        .tint(.primary)
        .debugRenders("ProfileTabContainerView")
    }
}

private struct PlaceholderTabView: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.dashed")
                .font(.system(size: 46))
                .foregroundColor(.secondary)
            Text("Écran “\(title)” à intégrer ici.")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ProfileTabContainerView(
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
