// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import SpriteKit

extension SpriteWorld {

    class SelectionMarquee {
        enum Directions: Int, CaseIterable { case n = 0, e = 1, s = 2, w = 3 }

        let scene: SpriteWorld.Scene

        let selectionExtentRoot = SKNode()
        var selectionExtentSprites = [SKSpriteNode]()

        init(_ scene: SpriteWorld.Scene) {
            self.scene = scene

            self.selectionExtentSprites = Directions.allCases.map { ss in
                let sprite = SKSpriteNode(imageNamed: "pixel_1x1")
                sprite.name = "fuckse"

                sprite.alpha = 0.7
                sprite.colorBlendFactor = 1
                sprite.color = .yellow
                sprite.isHidden = false
                sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                sprite.size = CGSize(width: 1, height: 1)

                selectionExtentRoot.addChild(sprite)
                return sprite
            }

            selectionExtentRoot.isHidden = true

            borderSprite(.n).anchorPoint = CGPoint(x: 0, y: 0.5)
            borderSprite(.e).anchorPoint = CGPoint(x: 0.5, y: 0)

            borderSprite(.s).anchorPoint = CGPoint(x: 1, y: 0.5)
            borderSprite(.w).anchorPoint = CGPoint(x: 0.5, y: 1)

            scene.rootNode.addChild(selectionExtentRoot)
        }

        func borderSprite(_ which: Directions) -> SKSpriteNode {
            selectionExtentSprites[which.rawValue]
        }

        func draw(from startVertex: CGPoint, to endVertex: CGPoint) {
            // If the user begins dragging and moves the mouse up and to the left, this box size
            // will have negative width and height. Fortunately, that's exactly what we need for
            // scaling the width and height of the rubber band sprites to track perfectly with the mouse
            let boxSize = CGSize(width: endVertex.x - startVertex.x, height: endVertex.y - startVertex.y)

            if boxSize == .zero {
                // In case the user is futzing with the mouse and causes
                // the box size to go back to zero
                reset()
                return
            }

            selectionExtentRoot.isHidden = false

            let shift = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)

            // We can do this trick of setting the corners to the same
            // positions because of the anchor configuration we setup at init
            let sx = startVertex.x - shift.x
            let sy = scene.size.height - startVertex.y - shift.y
            let shiftedStart = CGPoint(x: sx, y: sy) * scene.cameraScale

            borderSprite(.n).position = shiftedStart
            borderSprite(.w).position = shiftedStart

            let ex = endVertex.x - shift.x
            let ey = scene.size.height - endVertex.y - shift.y
            let shiftedEnd = CGPoint(x: ex, y: ey) * scene.cameraScale

            borderSprite(.e).position = shiftedEnd
            borderSprite(.s).position = shiftedEnd

            let hScale = CGSize(width: boxSize.width, height: 2) * scene.cameraScale

            borderSprite(.n).scale(to: hScale)
            borderSprite(.s).scale(to: hScale)

            let vScale = CGSize(width: 2, height: boxSize.height) * scene.cameraScale

            borderSprite(.e).scale(to: vScale)
            borderSprite(.w).scale(to: vScale)
        }

        func makeRectangle(vertexA: CGPoint, vertexB: CGPoint) -> CGRect {
            var va = scene.convertPoint(fromView: vertexA)
            var vb = scene.convertPoint(fromView: vertexB)

            va.y *= -1
            vb.y *= -1

            let LL = CGPoint(x: min(va.x, vb.x), y: min(va.y, vb.y))
            let UR = CGPoint(x: max(va.x, vb.x), y: max(va.y, vb.y))

            let size = CGSize(width: UR.x - LL.x, height: UR.y - LL.y)

            return CGRect(origin: LL, size: size)
        }

        func reset() {
            selectionExtentRoot.isHidden = true
        }
    }

}
