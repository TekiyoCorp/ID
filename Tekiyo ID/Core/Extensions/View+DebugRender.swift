import SwiftUI

extension View {
    func debugRenders(_ name: String) -> some View {
        #if DEBUG
        print("🔁 Re-render: \(name) @ \(Date())")
        #endif
        return self
    }
}

