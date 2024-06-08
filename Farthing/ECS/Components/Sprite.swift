// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import SpriteKit

extension ECS.Components {

    final class Sprite: ECS.Component {
        let sprite: SKSpriteNode

        init(textureName: String, at position: CGPoint, parentNode: SKNode) {
            sprite = SKSpriteNode(imageNamed: textureName)
            sprite.position = position

            parentNode.addChild(sprite)

            super.init()
        }

        init(sprite: SKSpriteNode, parentNode: SKNode) {
            self.sprite = sprite
            parentNode.addChild(sprite)
            super.init()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func hide() { sprite.isHidden = true }
        func show() { sprite.isHidden = false }
    }

}
