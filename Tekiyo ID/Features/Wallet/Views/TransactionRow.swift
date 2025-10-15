import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(transaction.user.avatarColor)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: transaction.user.avatarImage)
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.9))
                )
            
            // Name and time
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.user.name)
                    .font(.custom("SF Pro Display", size: 17))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                
                Text(transaction.timeString)
                    .font(.custom("SF Pro Display", size: 14))
                    .fontWeight(.regular)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Amount
            Text(transaction.formattedAmount)
                .font(.custom("SF Pro Display", size: 20))
                .fontWeight(.medium)
                .foregroundColor(transaction.type == .credit ? Color.green : Color.white.opacity(0.9))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }
}

