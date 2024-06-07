// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit
import SwiftUI

struct SpriteWorldView: View {
    @EnvironmentObject var game: Game

    @State private var dialogMode = "none"
    @State private var viewSize = CGSize.zero

    let dialogModes = ["Actions", "Physics", "Properties"]

    // With eternal gratitude to
    // https://forums.developer.apple.com/forums/profile/billh04
    // Adding a nearly invisible view to make DragGesture() respond
    // https://forums.developer.apple.com/forums/thread/724082
    let glassPaneColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.01)

    var body: some View {
        ZStack {
            SpriteView(
                scene: game.scene,
                debugOptions: [.showsFields, .showsFPS, .showsNodeCount, .showsPhysics]
            )

            Color(cgColor: glassPaneColor)
                .background() {
                    GeometryReader { geometry in
                        Path { _ in
                            DispatchQueue.main.async {
                                if game.viewSize != geometry.size {
                                    game.viewSize = geometry.size
                                }
                            }
                        }
                    }
                }
        }

        .gesture(
            DragGesture().modifiers(.shift)
                .onChanged { value in
                    game.hoverLocation = value.location
                    game.drag(startVertex: value.startLocation, endVertex: value.location, shiftKey: true)
                }
                .onEnded { value in
                    game.hoverLocation = value.location
                    game.dragEnd(startVertex: value.startLocation, endVertex: value.location, shiftKey: true)
                }
        )

        .gesture(
            DragGesture()
                .onChanged { value in
                    game.hoverLocation = value.location
                    game.drag(startVertex: value.startLocation, endVertex: value.location, shiftKey: false)
                }
                .onEnded { value in
                    game.hoverLocation = value.location
                    game.dragEnd(startVertex: value.startLocation, endVertex: value.location, shiftKey: false)
                }
        )

        .gesture(
            TapGesture().modifiers(.control).onEnded {
                game.controlTap(at: game.hoverLocation!)
            }
        )

        .gesture(
            TapGesture().modifiers(.shift).onEnded {
                game.tap(at: game.hoverLocation!, shiftKey: true)
            }
        )

        .gesture(
            TapGesture().onEnded {
                game.tap(at: game.hoverLocation!, shiftKey: false)
            }
        )

        // With eternal gratitude to Natalia Panferova
        // Using .onContinuousHover to track mouse position
        // https://nilcoalescing.com/blog/TrackingHoverLocationInSwiftUI/
        .onContinuousHover { phase in
            switch phase {
            case .active(let location):
                game.hoverLocation = location
            case .ended:
                game.hoverLocation = nil
            }
        }
    }
}
