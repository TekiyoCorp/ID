import SwiftUI

struct ParticipantsRow: View {
    let participants: [EventParticipant]
    
    var body: some View {
        HStack(spacing: -8) {
            ForEach(Array(participants.prefix(5).enumerated()), id: \.element.id) { index, participant in
                Circle()
                    .fill(participant.avatarColor)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: participant.avatarImage)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color(.systemBackground), lineWidth: 2)
                    )
                    .zIndex(Double(participants.count - index))
            }
            
            // Plus button
            Circle()
                .fill(Color(hex: "1D1D1D"))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                )
                .overlay(
                    Circle()
                        .stroke(Color(.systemBackground), lineWidth: 2)
                )
        }
    }
}
