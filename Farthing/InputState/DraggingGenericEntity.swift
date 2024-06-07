// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import GameplayKit

extension InputState {

    final class DraggingGenericEntity: InputState {
        override var isDraggingState: Bool { true }

        override func drag(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
            var sv = sm.scene.convertPoint(fromView: startVertex)
            var ev = sm.scene.convertPoint(fromView: endVertex)

            sv.y *= -1
            ev.y *= -1

            let entities = sm.selectionController.getSelected()!

            sm.scene.moveSprites(entities: entities, startVertex: sv, endVertex: ev)
        }
    }

}
