import Foundation
import Combine

@MainActor
final class StartViewModel: ObservableObject {
    @Published var shouldNavigateToIntroduction = false
    
    func startOnboarding() {
        shouldNavigateToIntroduction = true
    }
}

