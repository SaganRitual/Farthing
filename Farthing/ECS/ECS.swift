// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import GameplayKit

final class ECS {
    let handleAddPin = ECS.Entities.HandleAddPin()
    let handleSpaceEdit = ECS.Entities.HandleSpaceEdit()

    var entities = [UUID: ECS.Entity]()

    func getOwnerEntity(for node: SKNode) -> ECS.Entity? {
        guard
            let uuid = node.getOwnerEntityId(),
            let entity = entities[uuid] else {
            return nil
        }

        return entity
    }

    func getSelectioner(for entity: ECS.Entity) -> ECS.Components.Selectioner {
        entity.component(ofType: ECS.Components.Selectioner.self)!
    }

    func getSelectioner(for uuid: UUID) -> ECS.Components.Selectioner {
        entities[uuid]!.component(ofType: ECS.Components.Selectioner.self)!
    }

    func isEntitySelectable(_ entity: ECS.Entity) -> Bool {
        entity.component(ofType: ECS.Components.Selectioner.self) != nil
    }

    func isEntitySelected(_ entity: ECS.Entity) -> Bool {
        guard let cSelectioner = entity.component(ofType: ECS.Components.Selectioner.self) else {
            return false
        }

        return cSelectioner.isSelected
    }

    func setDragAnchors(for entities: Set<ECS.Entity>) {
        entities.forEach { entity in
            let cSprite = entity.component(ofType: ECS.Components.Sprite.self)!
            entity.dragAnchor = cSprite.sprite.position
        }
    }
}

extension ECS {

    class Entity: GKEntity {
        let uuid = UUID()

        var dragAnchor = CGPoint.zero
    }

    enum Entities { }
}

extension ECS {

    class Component: GKComponent {

    }

    enum Components { }

}

extension ECS {

    enum Systems {

    }

}
