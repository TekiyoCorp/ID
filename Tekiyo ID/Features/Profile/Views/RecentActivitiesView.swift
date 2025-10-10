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
                                profileColor: .orange,
                                title: "Connexion avec Damien R.",
                                icon: "person.2.fill",
                                color: .blue
                            )
                            
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: .gray,
                                title: "Thomas S. vous a scanné.",
                                icon: "square.dashed.inset.filled",
                                color: .blue
                            )
                            
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: .pink.opacity(0.6),
                                title: "Julie F. vous fait confiance.",
                                icon: "hand.thumbsup.fill",
                                color: .blue
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
                                profileColor: .orange,
                                title: "Connexion avec Damien R.",
                                icon: "person.2.fill",
                                color: .blue
                            )
                            
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: .gray,
                                title: "Thomas S. vous a signalé.",
                                icon: "exclamationmark.octagon.fill",
                                color: .red
                            )
                            
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: .pink.opacity(0.6),
                                title: "Julie F. vous fait confiance.",
                                icon: "hand.thumbsup.fill",
                                color: .blue
                            )
                            
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: .orange,
                                title: "Connexion avec Damien R.",
                                icon: "person.2.fill",
                                color: .blue
                            )
                            
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: .orange,
                                title: "Connexion avec Damien R.",
                                icon: "person.2.fill",
                                color: .blue
                            )
                            
                            EnhancedActivityRow(
                                profileImage: "person.circle.fill",
                                profileColor: .gray,
                                title: "Thomas S. vous a scanné.",
                                icon: "square.dashed.inset.filled",
                                color: .blue
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


// MARK: - Preview
#Preview {
    RecentActivitiesView()
}
