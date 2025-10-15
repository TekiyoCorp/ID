import SwiftUI

struct WalletWidget: View {
    let balance: String
    let onSend: () -> Void
    let onReceive: () -> Void
    let onAdd: () -> Void
    
    init(
        balance: String = "12, 754.84 €",
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
            // Wallet Container (326x167px, radius 52px, background #111111)
            VStack(spacing: 0) {
                // Header "Wallet"
                Text("Wallet")
                    .font(.system(size: 24, weight: .regular, design: .default))
                    .kerning(-1.44) // Exact tracking from Figma
                    .foregroundColor(Color.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 28)
                
                Spacer()
                
                // Balance
                Text(balance)
                    .font(.system(size: 46, weight: .regular, design: .default))
                    .kerning(-2.28) // Exact tracking from Figma
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 28)
            }
            .frame(width: 326, height: 167)
            .padding(.horizontal, 32)
            .background(Color(hex: "111111"))
            .clipShape(RoundedRectangle(cornerRadius: 52))
            
            // Action Buttons Row
            HStack(spacing: 0) {
                // Envoyer
                VStack(spacing: 12) {
                    Button(action: onSend) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 44)
                            .background(Color.clear)
                    }
                    .buttonStyle(.plain)
                    
                    Text("Envoyer")
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .kerning(-0.84) // Exact tracking from Figma
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Recevoir
                VStack(spacing: 12) {
                    Button(action: onReceive) {
                        Image(systemName: "arrow.down.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 44)
                            .background(Color.clear)
                    }
                    .buttonStyle(.plain)
                    
                    Text("Recevoir")
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .kerning(-0.84) // Exact tracking from Figma
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Ajouter
                VStack(spacing: 12) {
                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 44)
                            .background(Color.clear)
                    }
                    .buttonStyle(.plain)
                    
                    Text("Ajouter")
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .kerning(-0.84) // Exact tracking from Figma
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 24)
        }
        .frame(width: 342, height: 291)
        .padding(8)
        .background(Color.white.opacity(0.1))
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
