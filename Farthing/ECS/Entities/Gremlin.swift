// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation

extension ECS.Entities {

    final class Gremlin: ECS.Entity {
        var isSelected: Bool {
            selectioner.isSelected
        }

        var selectioner: ECS.Components.Selectioner {
            component(ofType: ECS.Components.Selectioner.self)!
        }

        init(at position: CGPoint, scene: SpriteWorld.Scene) {
            super.init()

            var spritePosition = scene.convertPoint(fromView: position)

            // I still haven't figured this part out; for some reason, SpriteKit's
            // y-coordinates are inverted relative to the SwiftUI coordinate spaces
            spritePosition.y *= -1

            let cSprite = ECS.Components.Sprite(textureName: "cyclops", at: spritePosition, parentNode: scene.rootNode)
            let cSelectioner = ECS.Components.Selectioner(parentSprite: cSprite.sprite)

            cSprite.sprite.setOwnerEntityId(self.uuid)
            cSelectioner.node.setOwnerEntityId(self.uuid)

            addComponent(cSprite)
            addComponent(cSelectioner)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func deselect() {
            selectioner.deselect()
        }

        func select() {
            selectioner.select()
        }

        func toggleSelect() {
            selectioner.toggleSelect()
        }
    }

}
