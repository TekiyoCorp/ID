import SwiftUI

struct CreateEventFloatingButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .fill(Color.blue.opacity(0.8))
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
