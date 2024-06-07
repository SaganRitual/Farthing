// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import SpriteKit

extension SpriteWorld {

    class Scene: SKScene {
        var cameraScale: CGFloat = 1

        let cameraNode = SKCameraNode()
        let rootNode = SKNode()

        // If we set the scene size in init(), we'll get that size on the first run
        // of the app, (or if we delete the app data and run again). It doesn't seem to
        // matter that we set the scaleMode in didMove(to view); the scene still won't
        // resize until the user actually drags the window to be a different size.
        // Some update happens in that user resizing that doesn't happen on just running
        // the app. By sheer brute-force trial and error, I've found that setting the
        // scale mode in this function cause the scene to resize itself without any
        // help from the user.
        //
        // Still, as of 2024.0512, the scene continues to report an incorrect node count
        // and incorrect frame rate until some sort of user activity occurs. Haven't
        // figured that one out yet
        override func didChangeSize(_ oldSize: CGSize) {
            scaleMode = .resizeFill

            let origin = CGPoint(x: -size.width / 2, y: -size.height / 2)
            let pb = SKPhysicsBody(edgeLoopFrom: CGRect(origin: origin, size: size))

            let m = SpriteWorld.Physics.CollisionMask.gremlin + SpriteWorld.Physics.CollisionMask.foobar
            pb.collisionBitMask = m
            pb.categoryBitMask = m
            pb.restitution = 1

            self.physicsBody = pb
        }

        override func didMove(to view: SKView) {
            scaleMode = .resizeFill
            backgroundColor = .black

            physicsWorld.gravity = .zero
            physicsWorld.speed = 0

            addChild(rootNode)

            addChild(cameraNode)
            camera = cameraNode

            cameraNode.position = CGPoint.zero
            cameraNode.setScale(cameraScale)
        }

        func getTopNode(at positionInView: CGPoint) -> SKNode? {
            var positionInScene = convertPoint(fromView: positionInView)
            positionInScene.y *= -1

            return rootNode.nodes(at: positionInScene).first
        }

        func getNodes(in rectangle: CGRect) -> Set<SKNode> {
            let nodes = rootNode.children.compactMap { node in
                rectangle.contains(node.position) ? node : nil
            }

            return Set(nodes)
        }

        func moveSprites(
            entities: Set<ECS.Entity>,
            startVertex: CGPoint,
            endVertex: CGPoint
        ) {
            let delta = endVertex - startVertex

            entities.forEach { entity in
                let cSprite = entity.component(ofType: ECS.Components.Sprite.self)!
                cSprite.sprite.position = entity.dragAnchor + delta
            }
        }

    }

}
