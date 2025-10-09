import SwiftUI

struct AppTypography: ViewModifier {
    let fontSize: CGFloat

    func body(content: Content) -> some View {
        // Approximate -6% letter spacing relative to the font size.
        // SwiftUI tracking is in points, so we convert percentage to points.
        content
            .tracking(fontSize * -0.06)
            // Approximate a 26pt line height by adding line spacing relative to the font size.
            // lineSpacing adds extra space between baselines, so we clamp at 0 to avoid negative spacing.
            .lineSpacing(max(0, 26 - fontSize))
    }
}

extension View {
    func appTypography(fontSize: CGFloat) -> some View {
        modifier(AppTypography(fontSize: fontSize))
    }
}
