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
                            .foregroundColor(.white.opacity(0.9))
                    )
                
                if conversation.user.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "111111"), lineWidth: 2)
                        )
                }
            }
            
            // Name and message
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(conversation.user.name)
                        .font(.custom("SF Pro Display", size: 17))
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                    
                    if conversation.user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                    }
                }
                
                Text(conversation.lastMessage)
                    .font(.custom("SF Pro Display", size: 15))
                    .fontWeight(.regular)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Timestamp and unread indicator
            VStack(alignment: .trailing, spacing: 8) {
                Text(conversation.timeString)
                    .font(.custom("SF Pro Display", size: 13))
                    .fontWeight(.regular)
                    .foregroundColor(.white.opacity(0.5))
                
                if conversation.isUnread {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

