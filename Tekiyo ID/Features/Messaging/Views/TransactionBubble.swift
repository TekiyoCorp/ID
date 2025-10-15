import SwiftUI

struct TransactionBubble: View {
    let user: ConversationUser
    let amount: String = "50€"
    
    var body: some View {
        HStack(spacing: 0) {
            // Sender avatar on left
            Circle()
                .fill(user.avatarColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: user.avatarImage)
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.9))
                )
                .padding(.leading, 16)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("TekiyoPay")
                    .font(.custom("SF Pro Display", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(amount)
                    .font(.custom("SF Pro Display", size: 56))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .kerning(-3.36)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 20)
        }
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .padding(.horizontal, 16)
    }
}

