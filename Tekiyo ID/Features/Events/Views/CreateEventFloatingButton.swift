import SwiftUI

struct CreateEventFloatingButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 56, height: 56)
        }
        .floatingGlassButton()
        .buttonStyle(.plain)
    }
}
