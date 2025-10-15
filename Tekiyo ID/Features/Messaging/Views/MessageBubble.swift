import SwiftUI

struct MessageBubble: View {
    let message: Message
    let userAvatar: ConversationUser?
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isFromCurrentUser, let user = userAvatar {
                // Contact avatar on left
                Circle()
                    .fill(user.avatarColor)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: user.avatarImage)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                    )
            } else if !message.isFromCurrentUser {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
            }
            
            if message.isFromCurrentUser {
                Spacer(minLength: 60)
            }
            
            Text(message.text)
                .font(.custom("SF Pro Display", size: 16))
                .fontWeight(.regular)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(message.isFromCurrentUser ? Color.white.opacity(0.15) : Color.white.opacity(0.08))
                )
            
            if !message.isFromCurrentUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 16)
    }
}

