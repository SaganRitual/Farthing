// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

@main
struct FarthingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Game())
        }
    }
}
