// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import SpriteKit

extension ECS.Components {

    final class Shape: ECS.Component {
        let shape: SKShapeNode

        init(shape: SKShapeNode, parentNode: SKNode) {
            self.shape = shape
            parentNode.addChild(shape)
            super.init()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func hide() { shape.isHidden = true }
        func show() { shape.isHidden = false }
    }

}
