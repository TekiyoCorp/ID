import SwiftUI

struct BottomNavigationBar: View {
    @Binding var selectedTab: TabItem
    @Environment(\.colorScheme) private var colorScheme
    
    enum TabItem: CaseIterable {
        case home
        case grid
        case bell
        case wallet
        
        var icon: String {
            switch self {
            case .home: return "house"
            case .grid: return "square.grid.3x3"
            case .bell: return "bell"
            case .wallet: return "wallet.pass"
            }
        }
        
        var isActive: Bool {
            return self == .grid // Grid est actif par défaut selon l'image
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(tab.isActive ? .primary : .secondary)
                            .frame(width: 44, height: 44)
                            .background(
                                tab.isActive ? 
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2)) :
                                nil
                            )
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColor)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    private var backgroundColor: Color {
        switch colorScheme {
        case .light:
            return Color.gray.opacity(0.1)
        case .dark:
            return Color(hex: "111111")
        @unknown default:
            return Color.gray.opacity(0.1)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        
        BottomNavigationBar(selectedTab: .constant(.grid))
    }
    .background(Color(.systemBackground))
}
