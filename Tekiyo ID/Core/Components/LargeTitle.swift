import SwiftUI

struct LargeTitle: View {
    let text: String
    let fontSize: CGFloat
    let alignment: TextAlignment
    
    init(
        _ text: String,
        fontSize: CGFloat = 36,
        alignment: TextAlignment = .leading
    ) {
        self.text = text
        self.fontSize = fontSize
        self.alignment = alignment
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .medium))
            .appTypography(fontSize: fontSize)
            .foregroundStyle(.primary)
            .multilineTextAlignment(alignment)
    }
}

