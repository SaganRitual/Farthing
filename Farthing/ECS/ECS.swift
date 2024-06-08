// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import GameplayKit

final class ECS {
    let handleAddPin = ECS.Entities.HandleAddPin()
    let handleSpaceEdit: ECS.Entities.HandleSpaceEdit

    var entities = [UUID: ECS.Entity]()

    init(_ scene: SpriteWorld.Scene) {
        handleSpaceEdit = ECS.Entities.HandleSpaceEdit(scene: scene)
    }

    func getOwnerEntity(for node: SKNode) -> ECS.Entity? {
        guard let uuid = node.getOwnerEntityId() else {
            return nil
        }

        if let entity = entities[uuid] {
            return entity
        }

        if uuid == handleSpaceEdit.uuid {
            return handleSpaceEdit
        }

        return nil
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
