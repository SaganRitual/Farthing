// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import GameplayKit

extension InputState {

    final class PrimaryState: InputState {
        override var isTappableState: Bool { true }

        override func controlTapBackground(at position: CGPoint, shiftKey: Bool = false) {

        }

        override func controlTapEntity(_ entity: ECS.Entity, shiftKey: Bool = false) {
            sm.selectionController.deselectAll()
            sm.selectionController.select(entity)

            sm.ecs.handleSpaceEdit.attach(to: entity)
        }

        override func tapBackground(at position: CGPoint, shiftKey: Bool = false) {
            sm.selectionController.deselectAll()

            let gremlin = ECS.Entities.Gremlin(at: position, scene: sm.scene)
            sm.ecs.entities[gremlin.uuid] = gremlin

            sm.selectionController.select(gremlin)
        }

        override func tapEntity(_ entity: ECS.Entity, shiftKey: Bool = false) {
            if shiftKey {
                sm.selectionController.toggleSelect(entity)
                return
            }

            sm.selectionController.deselectAll()
            sm.selectionController.select(entity)
        }
    }

}
