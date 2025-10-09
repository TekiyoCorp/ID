import SwiftUI

struct ProgressBar: View {
    let progress: Double
    let accentColor: Color
    
    init(
        progress: Double,
        accentColor: Color = Color(red: 0.0, green: 0.187, blue: 1.0)
    ) {
        self.progress = progress
        self.accentColor = accentColor
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                    .frame(height: 8)
                
                Capsule()
                    .fill(accentColor)
                    .frame(width: geometry.size.width * progress, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 8)
        .accessibilityLabel("Progression")
        .accessibilityValue("\(Int(progress * 100)) pourcents")
    }
}

