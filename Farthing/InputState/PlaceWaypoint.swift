// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import GameplayKit

extension InputState {

    final class PlaceWaypoint: InputState,
                               InputStateProtocols.Drag,
                               InputStateProtocols.Tap,
                               InputStateProtocols.TapBackground,
                               InputStateProtocols.TapEntity
    {
        func drag(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
            sm.dragBegin(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
        }

        func tap(at position: CGPoint, shiftKey: Bool = false) {
            sm.tap(at: position, shiftKey: shiftKey)
        }

        func tapBackground(at position: CGPoint, shiftKey: Bool = false) {
            sm.selectionController.deselectAll()

            let waypoint = ECS.Entities.Waypoint(at: position, scene: sm.scene)
            sm.ecs.entities[waypoint.uuid] = waypoint

            sm.selectionController.select(waypoint)
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
