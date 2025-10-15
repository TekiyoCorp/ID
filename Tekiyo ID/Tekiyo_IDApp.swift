//
//  Tekiyo_IDApp.swift
//  Tekiyo ID
//
//  Created by zak on 10/10/2025.
//

import SwiftUI

@main
struct Tekiyo_IDApp: App {
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            // Démarrer directement sur le profil en dev
            ProfileTabContainerView(
                identityData: IdentityData(
                    nom: "Dupont",
                    prenom: "Marie",
                    dateNaissance: Date(),
                    nationalite: "Française",
                    metier: "Directrice artistique",
                    ville: "Paris"
                ),
                profileImage: nil,
                tekiyoID: "3A1B-7E21",
                username: "@marieD77"
            )
            .debugRenders("ProfileTabContainerView Root")
            .preferredColorScheme(.dark)
            #else
            // Flux normal de production - onboarding / formulaire
            StartView()
                .debugRenders("StartView Root")
                .preferredColorScheme(.dark)
            #endif
        }
    }
}
