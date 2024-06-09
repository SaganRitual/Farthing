// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import GameplayKit

extension InputState {

    final class PrimaryState: InputState,
                              InputStateProtocols.ControlTap,
                              InputStateProtocols.ControlTapEntity,
                              InputStateProtocols.Drag,
                              InputStateProtocols.Tap,
                              InputStateProtocols.TapBackground,
                              InputStateProtocols.TapEntity
    {
        func controlTap(at position: CGPoint, shiftKey: Bool = false) {
            sm.controlTap(at: position, shiftKey: shiftKey)
        }

        func controlTapBackground(at position: CGPoint, shiftKey: Bool = false) {
        }

        func controlTapEntity(_ entity: ECS.Entity, shiftKey: Bool = false) {
            sm.selectionController.deselectAll()
            sm.selectionController.select(entity)

            sm.ecs.handleSpaceEdit.attach(to: entity)
        }

        func drag(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
            sm.dragBegin(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
        }

        func tapBackground(at position: CGPoint, shiftKey: Bool = false) {
            sm.selectionController.deselectAll()

            let gremlin = ECS.Entities.Gremlin(at: position, scene: sm.scene)
            sm.ecs.entities[gremlin.uuid] = gremlin

            sm.selectionController.select(gremlin)
        }

        func tap(at position: CGPoint, shiftKey: Bool = false) {
            sm.tap(at: position, shiftKey: shiftKey)
        }

        func tapEntity(_ entity: ECS.Entity, shiftKey: Bool = false) {
            if shiftKey {
                sm.selectionController.toggleSelect(entity)
                return
            }

            sm.reselect(entity)
        }
    }

}
