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

            let positions = [
                CGPoint(x: 0, y: Self.ringRadius),
                CGPoint(x: Self.ringRadius, y: 0),
                CGPoint(x: 0, y: -Self.ringRadius),
                CGPoint(x: -Self.ringRadius, y: 0)
            ]

            handles = positions.map { position in
                let handle = Self.makeHandle()
                handle.position = position
                return handle
            }

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
            show()
        }

        func detach() {
            targetEntity = nil
            hide()
        }

        func hide() { primaryNode.isHidden = true }
        func show() { primaryNode.isHidden = false }

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
            ring.fillColor = .clear
            ring.blendMode = .replace
            ring.isHidden = false
            ring.zPosition = 10

            return ring
        }
    }

}
