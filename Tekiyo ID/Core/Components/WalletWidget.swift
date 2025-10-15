import SwiftUI

struct WalletWidget: View {
    let balance: String
    let onSend: () -> Void
    let onReceive: () -> Void
    let onAdd: () -> Void
    
    init(
        balance: String = "12,754.84€",
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
        VStack(spacing: 24) {
            // Wallet Container (326x167px, radius 52px, padding 28x32px)
            VStack(spacing: 10) {
                // Header (icon + "Wallet")
                HStack(spacing: 10) {
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("Wallet")
                        .font(.system(size: 24, weight: .regular))
                        .kerning(-1.44) // -6% of 24px
                        .foregroundColor(.primary)
                }
                .frame(height: 55)
                
                // Balance
                Text(balance)
                    .font(.system(size: 46, weight: .regular))
                    .kerning(-2.76) // -6% of 46px
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Action Buttons (56x44px each, radius 24px)
                HStack(spacing: 0) {
                    // Envoyer
                    VStack(spacing: 12) {
                        Button(action: onSend) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                                .frame(width: 56, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .buttonStyle(.plain)
                        
                        Text("Envoyer")
                            .font(.system(size: 14, weight: .medium))
                            .kerning(-0.84) // -6% of 14px
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Recevoir
                    VStack(spacing: 12) {
                        Button(action: onReceive) {
                            Image(systemName: "arrow.down.left")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                                .frame(width: 56, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .buttonStyle(.plain)
                        
                        Text("Recevoir")
                            .font(.system(size: 14, weight: .medium))
                            .kerning(-0.84) // -6% of 14px
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Ajouter
                    VStack(spacing: 12) {
                        Button(action: onAdd) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                                .frame(width: 56, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .buttonStyle(.plain)
                        
                        Text("Ajouter")
                            .font(.system(size: 14, weight: .medium))
                            .kerning(-0.84) // -6% of 14px
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 24)
            }
            .frame(width: 326, height: 167)
            .padding(.horizontal, 32)
            .padding(.vertical, 28)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 52))
        }
        .frame(width: 342, height: 291.64)
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 60))
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
