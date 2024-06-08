// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import GameplayKit

extension InputState {

    final class DraggingHandleSpaceAttributes: InputState {
        override var isDraggingState: Bool { true }

        override func drag(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
            var sv = sm.scene.convertPoint(fromView: startVertex)
            var ev = sm.scene.convertPoint(fromView: endVertex)

            sv.y *= -1
            ev.y *= -1

            if let rotationOffset = sm.handleRotationOffset {
                dragMinorHandle(sv, ev, rotationOffset)
            } else {
                dragMajorHandle(sv, ev)
            }
        }

        private func dragMinorHandle(_ sv: CGPoint, _ ev: CGPoint, _ ro: Double) {
            let delta = ev - sm.ecs.handleSpaceEdit.primaryNode.position
            let angle = atan2(delta.y, delta.x)

            let distance = sv.distance(to: ev)
            let au = ECS.Entities.HandleSpaceEdit.ringRadius
            let scale = 1 + distance / au

            let withRotationOffset = angle + ro

            sm.ecs.handleSpaceEdit.primaryNode.zRotation = withRotationOffset
            sm.ecs.handleSpaceEdit.primaryNode.setScale(scale)

            let te = sm.ecs.handleSpaceEdit.targetEntity!
            let cSprite = te.component(ofType: ECS.Components.Sprite.self)!
            
            cSprite.sprite.setScale(scale)
            cSprite.sprite.zRotation = withRotationOffset
        }

        private func dragMajorHandle(_ sv: CGPoint, _ ev: CGPoint) {
            let delta = ev - sv
            sm.ecs.handleSpaceEdit.primaryNode.position = sm.ecs.handleSpaceEdit.dragAnchor + delta

            let te = sm.ecs.handleSpaceEdit.targetEntity!
            let cSprite = te.component(ofType: ECS.Components.Sprite.self)!

            cSprite.sprite.position = sm.ecs.handleSpaceEdit.primaryNode.position
        }

        override func dragEnd(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) {
            sm.handleRotationOffset = nil
        }
    }

}
