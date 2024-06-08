// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import SpriteKit

extension ECS.Entities {

    final class HandleAddPin: ECS.Entity {

    }

    final class HandleSpaceEdit: ECS.Entity {
        static let ringRadius = CGFloat(25)
        static let handleRadius = CGFloat(5)

        let primaryNode: SKNode
        let ring: SKShapeNode
        let handles: [SKShapeNode]

        var targetEntity: ECS.Entity?

        init(scene: SpriteWorld.Scene) {
            primaryNode = SKNode()

            ring = Self.makeRing()

            let setups: [(position: CGPoint, rotationOffset: Double)] = [
                (CGPoint(x: 0, y: +Self.ringRadius), 3 * .pi / 2),
                (CGPoint(x: +Self.ringRadius, y: 0), 0 * .pi / 2),
                (CGPoint(x: 0, y: -Self.ringRadius), 1 * .pi / 2),
                (CGPoint(x: -Self.ringRadius, y: 0), 2 * .pi / 2)
            ]

            handles = setups.indices.map { ix in
                let handle = Self.makeHandle()
                handle.position = setups[ix].position
                handle.userData = ["rotationOffset": setups[ix].rotationOffset]
                return handle
            }

            handles[0].fillColor = .red
            handles[1].fillColor = .green
            handles[2].fillColor = .blue
            handles[3].fillColor = .white

            super.init()

            hide()

            handles.forEach { handle in
                handle.setOwnerEntityId(self.uuid)
                ring.addChild(handle)
            }

            ring.setOwnerEntityId(self.uuid)
            primaryNode.addChild(ring)

            primaryNode.setOwnerEntityId(self.uuid)
            scene.rootNode.addChild(primaryNode)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func attach(to entity: ECS.Entity) {
            targetEntity = entity

            let cSprite = entity.component(ofType: ECS.Components.Sprite.self)!

            primaryNode.position = cSprite.sprite.position
            primaryNode.zRotation = cSprite.sprite.zRotation

            let scale = sqrt(cSprite.sprite.xScale)
            primaryNode.setScale(scale)

            show()
        }

        func detach() {
            targetEntity = nil
            hide()
        }

        func hide() { primaryNode.isHidden = true }
        func show() { primaryNode.isHidden = false }

        func setDragAnchor() {
            let cSprite = targetEntity!.component(ofType: ECS.Components.Sprite.self)!
            dragAnchor = cSprite.sprite.position
        }

        static func makeHandle() -> SKShapeNode {
            let handle = SKShapeNode(circleOfRadius: handleRadius)
            handle.isAntialiased = true
            handle.strokeColor = .clear
            handle.fillColor = .green
            handle.blendMode = .replace
            handle.isHidden = false
            handle.zPosition = 11

            return handle
        }

        static func makeRing() -> SKShapeNode {
            let ring = SKShapeNode(circleOfRadius: ringRadius)
            ring.lineWidth = 1
            ring.strokeColor = .green
            ring.fillColor = SKColor(calibratedWhite: 1, alpha: 0.01)
            ring.isHidden = false
            ring.zPosition = 10

            return ring
        }
    }

}
