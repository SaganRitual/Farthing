// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import GameplayKit

extension InputState {

    final class EditSpaceAttributes: InputState,
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

        func controlTapEntity(_ newTargetEntity: ECS.Entity, shiftKey: Bool = false) {
            let previousTargetEntity = sm.ecs.handleSpaceEdit.targetEntity!

            sm.ecs.handleSpaceEdit.detach()

            if newTargetEntity === sm.ecs.handleSpaceEdit {
                // User control-tapped the current target, so
                // we'll be leaving edit mode
                return
            }

            // User control-tapped a new target; stay in this mode but attached to new one
            if newTargetEntity != previousTargetEntity {
                sm.selectionController.deselectAll()
                sm.selectionController.select(newTargetEntity)

                sm.ecs.handleSpaceEdit.attach(to: newTargetEntity)
            }
        }

        func drag(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
            sm.dragBegin(startVertex: startVertex, endVertex: endVertex, shiftKey: shiftKey)
        }

        func tap(at position: CGPoint, shiftKey: Bool = false) {
            sm.tap(at: position, shiftKey: shiftKey)
        }

        func tapBackground(at position: CGPoint, shiftKey: Bool = false) {
            sm.ecs.handleSpaceEdit.detach()
            sm.selectionController.deselectAll()
        }

        func tapEntity(_ entity: ECS.Entity, shiftKey: Bool = false) {
            sm.ecs.handleSpaceEdit.detach()
            sm.selectionController.deselectAll()
            sm.selectionController.select(entity)
        }
    }

}
