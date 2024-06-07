// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import GameplayKit

extension InputState {

    final class PlaceWaypoint: InputState {
        override var isTappableState: Bool { true }

        override func tapBackground(at position: CGPoint, shiftKey: Bool = false) {
            sm.selectionController.deselectAll()

            let waypoint = ECS.Entities.Waypoint(at: position, scene: sm.scene)
            sm.ecs.entities[waypoint.uuid] = waypoint

            sm.selectionController.select(waypoint)
        }

        override func tapEntity(_ entity: ECS.Entity, shiftKey: Bool = false) {
            if !shiftKey {
                sm.selectionController.deselectAll()
            }

            sm.selectionController.select(entity)
        }
    }

}
