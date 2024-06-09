// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import SpriteKit
import SwiftUI

enum SpriteWorld { }

final class Game: ObservableObject {
    let ecs: ECS
    let inputStateMachine: InputStateMachine
    let scene = SpriteWorld.Scene()
    let selectionController: SelectionController
    let selectionMarquee: SpriteWorld.SelectionMarquee
    let sceneDelegate = SpriteWorld.SceneDelegate()

    @Published var hoverLocation: CGPoint?
    @Published var viewSize: CGSize = .zero

    init() {
        scene.delegate = sceneDelegate

        ecs = ECS(scene)
        selectionController = SelectionController(ecs, scene)
        selectionMarquee = SpriteWorld.SelectionMarquee(scene)
        inputStateMachine = InputStateMachine(ecs, scene, selectionController, selectionMarquee)
    }

    func controlTap(at position: CGPoint, shiftKey: Bool = false) {
        (inputStateMachine.cs as? InputStateProtocols.ControlTap)?.controlTap(at: position, shiftKey: shiftKey)
    }

    func drag(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
        (inputStateMachine.cs as? InputStateProtocols.Drag)?.drag(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
    }

    func dragEnd(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
        (inputStateMachine.cs as? InputStateProtocols.DragEnd)?.dragEnd(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
    }

    func tap(at position: CGPoint, shiftKey: Bool = false) {
        (inputStateMachine.cs as? InputStateProtocols.Tap)?.tap(at: position, shiftKey: shiftKey)
    }
}
