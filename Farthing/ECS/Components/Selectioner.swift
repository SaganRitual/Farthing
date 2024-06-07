// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import SpriteKit

extension ECS.Components {

    final class Selectioner: ECS.Component {
        let node: SKShapeNode

        var isSelected: Bool {
            !node.isHidden
        }

        init(parentSprite: SKSpriteNode) {
            // Try to make the selection indicator big enough to see and grab with the mouse
            let radius_ = 1.05 * max(parentSprite.size.width, parentSprite.size.height) / 2
            let radius = max(radius_, 15)

            node = SKShapeNode(circleOfRadius: radius)
            node.lineWidth = 1
            node.strokeColor = .white
            node.fillColor = .clear
            node.blendMode = .replace
            node.isHidden = true
            node.zPosition = parentSprite.zPosition + 1
            node.name = "fuckall"

            parentSprite.addChild(node)

            super.init()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func select() {
            node.isHidden = false
        }

        func deselect() {
            node.isHidden = true
        }

        func toggleSelect() {
            node.isHidden = !node.isHidden
        }
    }

}
