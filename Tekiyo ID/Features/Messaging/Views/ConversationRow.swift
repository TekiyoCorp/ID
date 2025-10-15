import SwiftUI

struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar with online indicator
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(conversation.user.avatarColor)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: conversation.user.avatarImage)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    )
                
                if conversation.user.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 2)
                        )
                }
            }
            
            // Name and message
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(conversation.user.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if conversation.user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Text(conversation.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Timestamp and unread indicator
            VStack(alignment: .trailing, spacing: 8) {
                Text(conversation.timeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if conversation.isUnread {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial)
        )
        .padding(.horizontal, 20)
    }
}

