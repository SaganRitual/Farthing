// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import GameplayKit

extension InputState {

    final class DraggingGenericEntity: InputState,
                                       InputStateProtocols.Drag,
                                       InputStateProtocols.DragEnd
    {
        func drag(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
            var sv = sm.scene.convertPoint(fromView: startVertex)
            var ev = sm.scene.convertPoint(fromView: endVertex)

            sv.y *= -1
            ev.y *= -1

            let entities = sm.selectionController.getSelected()!

            sm.scene.moveSprites(entities: entities, startVertex: sv, endVertex: ev)
        }

        func dragEnd(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
            sm.dragPrimaryObject = nil
            sm.dragEnd(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
        }
    }

}
