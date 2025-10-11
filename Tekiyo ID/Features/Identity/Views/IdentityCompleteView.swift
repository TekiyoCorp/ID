import SwiftUI

struct IdentityCompleteView: View {
    @StateObject private var viewModel: IdentityCompleteViewModel
    @State private var shouldNavigateToProfile = false
    @State private var showActivitiesOverlay = false
    
    private enum Layout {
        static let titleOffset: CGFloat = 108
        static let cardOffset: CGFloat = 241
        static let cardSize: CGFloat = 254.0
        static let cardPadding: CGFloat = 24.0
        static let cardTotalHeight: CGFloat = cardSize + (cardPadding * 2)
        static let activitiesSpacingBelowCard: CGFloat = 36
        static var activitiesOffset: CGFloat { cardOffset + cardTotalHeight + activitiesSpacingBelowCard }
        static let profileImageSize: CGFloat = 100
    }
    
    init(identityData: IdentityData, profileImage: UIImage?) {
        self._viewModel = StateObject(wrappedValue: IdentityCompleteViewModel(
            identityData: identityData,
            profileImage: profileImage
        ))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Title at Y=108
                VStack(spacing: 12) {
                    // Title
                    LargeTitle("Ton identité est prête.", alignment: .center)
                    
                    // Subtitle - 12px gap
                    Text("Tu es désormais vérifié, unique et anonyme à la fois.")
                        .font(.system(size: 18, weight: .regular))
                        .appTypography(fontSize: 18)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 48)
                }
                .frame(maxWidth: .infinity)
                .offset(y: Layout.titleOffset)
                
                // Profile Card at Y=241 - 254x254, padding 24, border radius 24
                VStack(spacing: 12) {
                    // Profile Photo
                    if let profileImage = viewModel.profileUIImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(.systemGray5), lineWidth: 1)
                            )
                    } else {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)
                            )
                    }
                    
                    // Name
                    Text(viewModel.fullName)
                        .font(.system(size: 18, weight: .semibold))
                        .appTypography(fontSize: 18)
                        .foregroundStyle(.primary)
                    
                    // Username - 6px gap
                    Text(viewModel.username)
                        .font(.system(size: 14, weight: .regular))
                        .appTypography(fontSize: 14)
                        .foregroundStyle(.secondary)
                        .padding(.top, -6) // 6px gap au lieu de 12
                    
                    // Separator - 12px gap
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                    
                    // Tekiyo ID - 12px gap
                    HStack {
                        Text("Tekiyo ID")
                            .font(.system(size: 14, weight: .regular))
                            .appTypography(fontSize: 14)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(viewModel.tekiyoID)
                            .font(.system(size: 14, weight: .semibold))
                            .appTypography(fontSize: 14)
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 20)
                }
                .frame(width: 254, height: 254)
                .padding(24)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .offset(y: Layout.cardOffset)
                
                // Activities preview
                ActivitiesPreview(
                    activities: viewModel.recentActivities,
                    onTap: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            showActivitiesOverlay = true
                        }
                    }
                )
                .offset(y: Layout.activitiesOffset)
                .padding(.horizontal, 32)
                .allowsHitTesting(!showActivitiesOverlay)
                
                // Action Button at bottom
                VStack {
                    Spacer()
                    
                    PrimaryButton(
                        title: "Afficher mon profil Tekiyo",
                        style: .blue,
                        action: {
                            shouldNavigateToProfile = true
                        }
                    )
                    .padding(.horizontal, 48)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(!showActivitiesOverlay)
                
                if showActivitiesOverlay {
                    ActivitiesOverlay(
                        activities: viewModel.recentActivities,
                        onClose: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                showActivitiesOverlay = false
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .bottom)),
                        removal: .opacity
                    ))
                    .zIndex(1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $shouldNavigateToProfile) {
            ProfileView(
                identityData: viewModel.identityData,
                profileImage: viewModel.profileUIImage,
                tekiyoID: viewModel.tekiyoID,
                username: viewModel.username
            )
        }
        .debugRenders("IdentityCompleteView")
    }
}

// MARK: - Activities Preview
private struct ActivitiesPreview: View {
    let activities: [IdentityActivity]
    let onTap: () -> Void
    
    private var previewActivities: [IdentityActivity] {
        Array(activities.prefix(3))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Activités récentes")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                ForEach(previewActivities) { activity in
                    ActivityPreviewRow(activity: activity)
                }
            }
            
            HStack(spacing: 6) {
                Text("Voir les détails")
                    .font(.system(size: 16, weight: .medium))
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(Color.blue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 16)
        )
        .onTapGesture(perform: onTap)
    }
}

private struct ActivityPreviewRow: View {
    let activity: IdentityActivity
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: activity.icon)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(Color.blue)
                .padding(12)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                )
            
            Text(activity.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            
            Text(activity.timestamp)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Activities Overlay
private struct ActivitiesOverlay: View {
    let activities: [IdentityActivity]
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text("Activités récentes")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(activities) { activity in
                            ActivityDetailRow(activity: activity)
                        }
                    }
                    .padding(.top, 4)
                }
                .scrollIndicators(.never)
            }
            .padding(24)
            .frame(maxWidth: 360, maxHeight: 520)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 24, x: 0, y: 18)
            .padding(.horizontal, 24)
            .contentShape(Rectangle())
            .onTapGesture { }
        }
    }
}

private struct ActivityDetailRow: View {
    let activity: IdentityActivity
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: activity.icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.blue)
                .padding(12)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.12))
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
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 8)
        )
    }
}

#Preview {
    IdentityCompleteView(
        identityData: IdentityData(
            nom: "Dupont",
            prenom: "Marie",
            dateNaissance: Date(),
            nationalite: "France",
            metier: "Directrice artistique",
            ville: "Paris"
        ),
        profileImage: nil
    )
}
