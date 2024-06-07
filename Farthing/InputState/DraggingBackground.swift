// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import GameplayKit

extension InputState {

    final class DraggingBackground: InputState {
        override var isDraggingState: Bool { true }

        override func drag(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool) {
            sm.selectionMarquee.draw(from: startVertex, to: endVertex)
        }

        override func dragEnd(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
            sm.selectionMarquee.reset()

            let rect = sm.selectionMarquee.makeRectangle(vertexA: startVertex, vertexB: endVertex)

            guard let selectables = sm.selectionController.getSelectableObjects(in: rect) else {
                if !shiftKey {
                    sm.selectionController.deselectAll()
                }

                return
            }

            if shiftKey {
                sm.selectionController.toggleSelect(selectables)
            } else {
                sm.selectionController.deselectAll()
                sm.selectionController.select(selectables)
            }
        }
    }

}
