import SwiftUI

struct EventCard: View {
    let event: Event
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Top: Logo + Title
                HStack(spacing: 12) {
                    Circle()
                        .fill(event.organizer.logoColor)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: event.organizer.logo)
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(event.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            if let emoji = event.emoji {
                                Text(emoji)
                                    .font(.title2)
                            }
                        }
                        
                        HStack(spacing: 6) {
                            Text(event.organizer.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if event.organizer.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                // Address
                Text(event.location.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Requirements section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Requis")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 4) {
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
                
                Spacer()
                
                // Bottom: Participants + Capacity + Button
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        ParticipantsRow(participants: event.participants)
                        
                        Text(event.capacity.formattedCapacity)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Button
                    if event.title.contains("Tennis") {
                        Circle()
                            .fill(Color(hex: "1D1D1D"))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.secondary)
                            )
                    } else {
                        Text("S'inscrire")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(hex: "1D1D1D"))
                            )
                    }
                }
            }
            .padding(24)
            .frame(width: 342, height: 281)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(hex: "1D1D1D"))
            )
        }
        .buttonStyle(.plain)
    }
}
