import SwiftUI

struct PrimaryButton: View {
    let title: String?
    let icon: String?
    let style: ButtonStyle
    let isEnabled: Bool
    let action: () -> Void
    
    enum ButtonStyle {
        case black
        case blue
        
        var color: Color {
            switch self {
            case .black: return .black
            case .blue: return Color(red: 0.0, green: 0.187, blue: 1.0)
            }
        }
    }
    
    init(
        title: String? = nil,
        icon: String? = nil,
        style: ButtonStyle = .black,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Group {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                } else if let title = title {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .appTypography(fontSize: 17)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 293, style: .continuous)
                .fill(style.color)
        )
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.7)
    }
}

