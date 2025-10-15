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
                            .foregroundColor(.white)
                    )
            } else if !message.isFromCurrentUser {
                        Circle()
                            .fill(Color(hex: "1D1D1D"))
                    .frame(width: 32, height: 32)
            }
            
            if message.isFromCurrentUser {
                Spacer(minLength: 60)
            }
            
            Text(message.text)
                .font(.body)
                .foregroundColor(message.isFromCurrentUser ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(message.isFromCurrentUser ? Color.blue : Color(hex: "1D1D1D"))
                )
            
            if !message.isFromCurrentUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 16)
    }
}

