import SwiftUI

struct TestCircularCodeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Test CircularCodeView")
                .font(.title)
            
            CircularCodeView(url: "https://tekiyo.fr/test123")
                .frame(width: 120, height: 120)
            
            CircularCodeView(url: "https://tekiyo.fr/different-url")
                .frame(width: 120, height: 120)
            
            Text("Same URL should generate same pattern")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    TestCircularCodeView()
}
