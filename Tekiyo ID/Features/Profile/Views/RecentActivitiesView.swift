import SwiftUI

struct RecentActivitiesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Today section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Aujourd'hui")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: Color.orange,
                                title: "Connexion avec Damien R.",
                                icon: "person.2.fill",
                                color: Color.blue
                            )
                            
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: Color.gray,
                                title: "Thomas S. vous a scanné.",
                                icon: "square.dashed.inset.filled",
                                color: Color.blue
                            )
                            
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: .pink.opacity(0.6),
                                title: "Julie F. vous fait confiance.",
                                icon: "hand.thumbsup.fill",
                                color: Color.blue
                            )
                        }
                    }
                    
                    // Yesterday section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Hier")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: Color.orange,
                                title: "Connexion avec Damien R.",
                                icon: "person.2.fill",
                                color: Color.blue
                            )
                            
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: Color.gray,
                                title: "Thomas S. vous a signalé.",
                                icon: "exclamationmark.octagon.fill",
                                color: Color.red
                            )
                            
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: .pink.opacity(0.6),
                                title: "Julie F. vous fait confiance.",
                                icon: "hand.thumbsup.fill",
                                color: Color.blue
                            )
                            
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: Color.orange,
                                title: "Connexion avec Damien R.",
                                icon: "person.2.fill",
                                color: Color.blue
                            )
                            
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: Color.orange,
                                title: "Connexion avec Damien R.",
                                icon: "person.2.fill",
                                color: Color.blue
                            )
                            
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: Color.gray,
                                title: "Thomas S. vous a scanné.",
                                icon: "square.dashed.inset.filled",
                                color: Color.blue
                            )
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Activités récentes")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


// MARK: - Enhanced Activity Row Component
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

// MARK: - Preview
#Preview {
    RecentActivitiesView()
}
