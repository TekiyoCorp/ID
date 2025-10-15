import SwiftUI

struct WalletActionButtons: View {
    let onSend: () -> Void
    let onReceive: () -> Void
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            actionButton(icon: "arrow.up.right", label: "Envoyer", action: onSend)
            actionButton(icon: "arrow.down.left", label: "Recevoir", action: onReceive)
            actionButton(icon: "plus", label: "", action: onAdd, isCompact: true)
        }
    }
    
    private func actionButton(icon: String, label: String, action: @escaping () -> Void, isCompact: Bool = false) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                if !isCompact && !label.isEmpty {
                    Text(label)
                        .font(.custom("SF Pro Display", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .frame(maxWidth: isCompact ? nil : .infinity)
            .frame(height: 48)
            .padding(.horizontal, isCompact ? 16 : 20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}

