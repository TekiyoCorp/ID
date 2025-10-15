import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(transaction.user.avatarColor)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: transaction.user.avatarImage)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                )
            
            // Name and time
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.user.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(transaction.timeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(transaction.formattedAmount)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(transaction.type == .credit ? Color.green : Color.primary)
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial)
        )
    }
}

