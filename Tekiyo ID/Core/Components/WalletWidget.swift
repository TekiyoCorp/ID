import SwiftUI

struct WalletWidget: View {
    let balance: String
    let onSend: () -> Void
    let onReceive: () -> Void
    let onAdd: () -> Void
    
    init(
        balance: String = "12,754.84 €",
        onSend: @escaping () -> Void = {},
        onReceive: @escaping () -> Void = {},
        onAdd: @escaping () -> Void = {}
    ) {
        self.balance = balance
        self.onSend = onSend
        self.onReceive = onReceive
        self.onAdd = onAdd
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header "Wallet"
            Text("Wallet")
                .font(.custom("SF Pro Display", size: 24))
                .fontWeight(.regular)
                .kerning(-1.44) // -6% of 24px
                .foregroundColor(.white.opacity(0.9))
                .padding(.bottom, 12)
            
            Spacer()
            
            // Balance
            Text(balance)
                .font(.custom("SF Pro Display", size: 46))
                .fontWeight(.regular)
                .kerning(-2.76) // -6% of 46px
                .foregroundColor(.white.opacity(0.9))
                .padding(.bottom, 20)
            
            // Action Buttons Row
            HStack(spacing: 24) {
                walletButton(icon: "arrow.up.right", label: "Envoyer", action: onSend)
                walletButton(icon: "arrow.down.left", label: "Recevoir", action: onReceive)
                walletButton(icon: "plus", label: "Ajouter", action: onAdd)
            }
        }
        .frame(width: 342, height: 291)
        .padding(8)
           .background(
               RoundedRectangle(cornerRadius: 60, style: .continuous)
                   .fill(Color.black.opacity(0.15))
                   .shadow(color: .white.opacity(0.05), radius: 12, x: 0, y: 8)
                   .background(.ultraThinMaterial) // Frosted glass effect
           )
           .clipShape(RoundedRectangle(cornerRadius: 60, style: .continuous))
    }
    
    private func walletButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 56, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .buttonStyle(.plain)
            
            Text(label)
                .font(.custom("SF Pro Display", size: 14))
                .fontWeight(.medium)
                .kerning(-0.84) // -6% of 14px
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

#Preview {
    VStack {
        WalletWidget()
            .padding()
        
        Spacer()
    }
    .background(Color(.systemBackground))
}
