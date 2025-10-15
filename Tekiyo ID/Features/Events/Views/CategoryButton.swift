import SwiftUI

struct CategoryButton: View {
    let category: EventCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(category.emoji)
                    .font(.title2)
                
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? category.color.opacity(0.2) : Color(hex: "1D1D1D"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? category.color.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
