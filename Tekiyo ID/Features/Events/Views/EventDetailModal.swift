import SwiftUI

struct EventDetailModal: View {
    let event: Event
    let onRegister: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Title
            HStack {
                Text(event.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if let emoji = event.emoji {
                    Text(emoji)
                        .font(.largeTitle)
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }
            }
            
            // Organizer + Location
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(event.organizer.logoColor)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: event.organizer.logo)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        )
                    
                    Text(event.organizer.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if event.organizer.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Text(event.location.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Map
            EventMapView(coordinate: event.location.coordinates)
            
            // Requirements
            VStack(alignment: .leading, spacing: 12) {
                Text("Requis")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    if event.requirements.profileVerified {
                        EventRequirementRow(
                            icon: "checkmark.seal.fill",
                            text: "Profil vérifié",
                            iconColor: .green
                        )
                    }
                    
                    EventRequirementRow(
                        icon: "sparkles",
                        text: "Trust score: \(event.requirements.trustScoreMin)%",
                        iconColor: .yellow
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Participants + Capacity
            VStack(alignment: .leading, spacing: 12) {
                ParticipantsRow(participants: event.participants)
                
                Text(event.capacity.formattedCapacity)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // CTA Button
            Button(action: onRegister) {
                Text("S'inscrire")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.blue)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(32, corners: [.topLeft, .topRight])
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
