// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import SpriteKit
import SwiftUI

enum SpriteWorld { }

final class Game: ObservableObject {
    let ecs = ECS()
    let inputStateMachine: InputStateMachine
    let scene = SpriteWorld.Scene()
    let selectionController: SelectionController
    let selectionMarquee: SpriteWorld.SelectionMarquee
    let sceneDelegate = SpriteWorld.SceneDelegate()

    @Published var hoverLocation: CGPoint?
    @Published var viewSize: CGSize = .zero

    init() {
        scene.delegate = sceneDelegate

        selectionController = SelectionController(ecs, scene)
        selectionMarquee = SpriteWorld.SelectionMarquee(scene)
        inputStateMachine = InputStateMachine(ecs, scene, selectionController, selectionMarquee)
    }

    func continueDrag(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
        inputStateMachine.continueDrag(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
    }

    func controlTap(at position: CGPoint, shiftKey: Bool = false) {
        inputStateMachine.controlTap(at: position)
    }

    func drag(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
        if inputStateMachine.cs.isDraggingState {
            continueDrag(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
            return
        }

        // We're not already in a dragging state, so this is a dragBegin

        guard let topNode = scene.getTopNode(at: startVertex) else {
            inputStateMachine.dragBackground(
                startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey
            )

            return
        }

        guard let entity = ecs.getOwnerEntity(for: topNode) else {
            return
        }

        if !selectionController.entityIsSelected(entity) {
            selectionController.deselectAll()
            selectionController.select(entity)
        }

        inputStateMachine.dragSelected(
            startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey
        )
    }

    func dragEnd(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
        inputStateMachine.dragEnd(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
    }

    func tap(at position: CGPoint, shiftKey: Bool = false) {
        guard let tappedNode = scene.getTopNode(at: position) else {
            inputStateMachine.tapBackground(at: position, shiftKey: shiftKey)
            return
        }

        guard let entity = ecs.getOwnerEntity(for: tappedNode) else {
            // So far we don't have any tappable sprites that aren't
            // entities or children of entities
            return
        }

        inputStateMachine.tapEntity(entity, shiftKey: shiftKey)
    }
}
