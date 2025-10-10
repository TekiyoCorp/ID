import SwiftUI

struct FingerprintCreationView: View {
    let identityData: IdentityData?
    let capturedImage: UIImage?
    
    init(identityData: IdentityData?, capturedImage: UIImage?) {
        self.identityData = identityData
        self.capturedImage = capturedImage
    }
    
    var body: some View {
        OptimizedFingerprintCreationView(
            identityData: identityData,
            capturedImage: capturedImage
        )
    }
}

#Preview {
    FingerprintCreationView(
        identityData: IdentityData(
            nom: "Dupont",
            prenom: "Marie",
            dateNaissance: Date(),
            nationalite: "France"
        ),
        capturedImage: nil
    )
}
