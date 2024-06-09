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
    var editCompletionState: InputState.Type!
    var handleRotationOffset: Double?

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

    func controlTap(at position: CGPoint, shiftKey: Bool = false) {
        guard let tappedNode = scene.getTopNode(at: position) else {
            controlTapBackground(at: position, shiftKey: shiftKey)
            return
        }

        guard let entity = ecs.getOwnerEntity(for: tappedNode) else {
            // So far we don't have any tappable sprites that aren't
            // entities or children of entities
            return
        }

        controlTapEntity(entity, shiftKey: shiftKey)
    }

    func controlTapBackground(at position: CGPoint, shiftKey: Bool = false) {
        // Don't call into the states bc right now this is just
        // a q&d way to toggle between gremlins & waypoints. Control-tap
        // on the background will ultimately cause a context menu, or maybe nothing
        if cs is InputState.PrimaryState {
            enter(InputState.PlaceWaypoint.self)
        } else if cs is InputState.PlaceWaypoint {
            enter(InputState.PrimaryState.self)
        }
    }

    func controlTapEntity(_ entity: ECS.Entity, shiftKey: Bool = false) {
        (cs as! InputStateProtocols.ControlTapEntity).controlTapEntity(entity, shiftKey: shiftKey)

        if cs is InputState.EditSpaceAttributes {
            if entity === ecs.handleSpaceEdit {
                // User control-tapped the current edit target, so we're just leaving edit mode
                enter(editCompletionState)
                editCompletionState = nil
            }

            // If the user control-tapped a different edit target we'll stay
            // in edit mode, but the state will have attached us to that new target

        } else {
            editCompletionState = type(of: cs)
            enter(InputState.EditSpaceAttributes.self)
        }
    }

    func dragBackgroundBegin(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
        enter(InputState.DraggingBackground.self)
        (cs as! InputStateProtocols.Drag).drag(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
    }

    func dragBackground(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
        if !cs.isDraggingState {
            // If this is a dragBegin, remember what state to return to on dragEnd
            dragCompletionState = type(of: cs)
        }

        enter(InputState.DraggingBackground.self)
        (cs as! InputStateProtocols.Drag).drag(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
    }

    func dragBegin(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
        dragCompletionState = type(of: cs)

        // This is a begin drag. Figure out what's under the mouse and decide
        // which state to enter, although I think we're not supposed to enter
        // the state from here. I'll ask the ai about that part
        guard let topNode = scene.getTopNode(at: startVertex) else {
            dragBackgroundBegin(
                startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey
            )

            return
        }

        guard let entity = ecs.getOwnerEntity(for: topNode) else {
            return
        }

        if entity is ECS.Entities.HandleSpaceEdit {
            dragHandleBegin(
                topNode: topNode,
                entity: entity,
                startVertex: startVertex,
                endVertex: endVertex,
                shiftKey: shiftKey
            )

            return
        }

        if ecs.isEntitySelectable(entity) {
            dragSelectedBegin(
                entity: entity, startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey
            )

            return
        }
    }

    func dragEnd(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
        enter(dragCompletionState)

        dragCompletionState = nil
        dragPrimaryObject = nil
    }

    func dragHandleBegin(
        topNode: SKNode,
        entity: ECS.Entity,
        startVertex: CGPoint,
        endVertex: CGPoint,
        shiftKey: Bool = false
    ) {
        dragPrimaryObject = entity

        if let handleRotationOffset = topNode.userData?["rotationOffset"] as? Double {
            self.handleRotationOffset = handleRotationOffset
        } else {
            let te = entity as! ECS.Entities.HandleSpaceEdit

            if topNode === te.primaryNode {
                self.handleRotationOffset = nil
            }
        }

        dragCompletionState = type(of: cs)
        ecs.handleSpaceEdit.setDragAnchor()
        enter(InputState.DraggingHandleSpaceAttributes.self)
    }

    func dragSelectedBegin(
        entity: ECS.Entity, startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false
    ) {
        if !selectionController.entityIsSelected(entity) {
            reselect(entity)
        }

        dragCompletionState = type(of: cs)

        // And remember where all the dragees started
        if let selected = selectionController.getSelected() {
            cs.setDragAnchors(for: selected)
        }

        enter(InputState.DraggingGenericEntity.self)
        (cs as! InputStateProtocols.Drag).drag(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
    }

    func reselect(_ entity: ECS.Entity) {
        let ss = selectionController.selectionState()

        selectionController.deselectAll()
        selectionController.select(entity)

        if !ss.contains(where: { $0 == type(of: entity) }) {
            // The newly selected entity is of a type that was not
            // already selected. For example, waypoints were selected
            // and we just selected a gremlin. For that we need to
            // enter gremlin-planting state. Or if gremlins were selected
            // and we just selected a waypoint, we need to go to waypoint-
            // planting state
            switch entity {
            case is ECS.Entities.Gremlin:
                enter(InputState.PrimaryState.self)
                break

            case is ECS.Entities.Waypoint:
                enter(InputState.PlaceWaypoint.self)
                break

            default:
                fatalError()
            }
        }
    }

    func tap(at position: CGPoint, shiftKey: Bool = false) {
        guard let tappedNode = scene.getTopNode(at: position) else {
            tapBackground(at: position, shiftKey: shiftKey)
            return
        }

        guard let entity = ecs.getOwnerEntity(for: tappedNode) else {
            // So far we don't have any tappable sprites that aren't
            // entities or children of entities
            return
        }

        tapEntity(entity, shiftKey: shiftKey)
    }

    func tapBackground(at position: CGPoint, shiftKey: Bool = false) {
        (cs as! InputStateProtocols.TapBackground).tapBackground(at: position, shiftKey: shiftKey)

        if cs is InputState.EditSpaceAttributes {
            // We're in edit mode and the user clicked on
            // the background. Exit edit mode, and pass the
            // tap to the new state
            enter(editCompletionState)
            (cs as! InputStateProtocols.TapBackground).tapBackground(at: position, shiftKey: shiftKey)
            return
        }
    }

    func tapEntity(_ entity: ECS.Entity, shiftKey: Bool = false) {
        if entity === ecs.handleSpaceEdit {
            // The user clicked on the edit handles; just do nothing
            assert(cs is InputState.EditSpaceAttributes)
            return
        }

        (cs as! InputStateProtocols.TapEntity).tapEntity(entity, shiftKey: shiftKey)

        if cs is InputState.EditSpaceAttributes {
            // We're in edit mode and the user clicked on
            // an entity other than the handles. Leave edit mode
            enter(editCompletionState)
            return
        }
    }
}
