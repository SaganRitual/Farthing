// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import GameplayKit

final class InputStateMachine: GKStateMachine {
    let ecs: ECS
    let scene: SpriteWorld.Scene
    let selectionController: SelectionController
    let selectionMarquee: SpriteWorld.SelectionMarquee

    var dragPrimaryObject: ECS.Entity?
    var dragCompletionState: InputState.Type!

    var cs: InputState { currentState! as! InputState }

    init(
        _ ecs: ECS,
        _ scene: SpriteWorld.Scene,
        _ selectionController: SelectionController,
        _ selectionMarquee: SpriteWorld.SelectionMarquee
    ) {
        self.ecs = ecs
        self.scene = scene
        self.selectionController = selectionController
        self.selectionMarquee = selectionMarquee

        super.init(states: InputState.states)

        enter(InputState.PrimaryState.self)
    }

    func continueDrag(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
        cs.drag(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
    }

    func controlTap(at position: CGPoint, shiftKey: Bool = false) {
        if cs is InputState.PrimaryState {
            enter(InputState.PlaceWaypoint.self)
        } else if cs is InputState.PlaceWaypoint {
            enter(InputState.PrimaryState.self)
        }
    }

    func controlTapEntity(_ entity: ECS.Entity, shiftKey: Bool = false) {
        cs.controlTapEntity(entity, shiftKey: shiftKey)

        if cs is InputState.EditSpaceAttributes {

            if entity === ecs.handleSpaceEdit {
                // User control-tapped the current edit target, so we're just leaving edit mode
                enter(dragCompletionState)
                dragCompletionState = nil
            }

            // If the user control-tapped a different edit target we'll stay
            // in edit mode, but the state will have attached us to that new target

        } else {
            dragCompletionState = type(of: cs)
            enter(InputState.EditSpaceAttributes.self)
        }
    }

    func dragBackground(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
        if !cs.isDraggingState {
            // If this is a dragBegin, remember what state to return to on dragEnd
            dragCompletionState = type(of: cs)
        }

        enter(InputState.DraggingBackground.self)
        cs.drag(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
    }

    func dragEnd(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
        cs.dragEnd(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
        enter(dragCompletionState)

        dragCompletionState = nil
        dragPrimaryObject = nil
    }

    func dragSelected(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
        if !cs.isDraggingState {
            // If this is a dragBegin, remember what state to return do on dragEnd
            dragCompletionState = type(of: cs)

            // And remember where all the dragees started
            if let selected = selectionController.getSelected() {
                cs.setDragAnchors(for: selected)
            }
        }

        enter(InputState.DraggingGenericEntity.self)
        cs.drag(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
    }

    func tapBackground(at position: CGPoint, shiftKey: Bool = false) {
        cs.tapBackground(at: position, shiftKey: shiftKey)

        if cs is InputState.EditSpaceAttributes {
            // We're in edit mode and the user clicked on
            // the background. Exit edit mode, and pass the
            // tap to the new state
            enter(dragCompletionState)
            cs.tapBackground(at: position, shiftKey: shiftKey)
            return
        }
    }

    func tapEntity(_ entity: ECS.Entity, shiftKey: Bool = false) {
        if entity === ecs.handleSpaceEdit {
            // The user clicked on the edit handles; just do nothing
            assert(cs is InputState.EditSpaceAttributes)
            return
        }

        cs.tapEntity(entity, shiftKey: shiftKey)

        if cs is InputState.EditSpaceAttributes {
            // We're in edit mode and the user clicked on
            // an entity other than the handles. Leave edit mode
            enter(dragCompletionState)
            return
        }
    }
}
