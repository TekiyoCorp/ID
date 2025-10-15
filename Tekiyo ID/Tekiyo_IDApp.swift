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
            StartView()
                .debugRenders("StartView Root")
                .preferredColorScheme(.dark)
        }
    }
}
