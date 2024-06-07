// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation

final class SelectionController {
    let ecs: ECS
    let scene: SpriteWorld.Scene

    init(_ ecs: ECS, _ scene: SpriteWorld.Scene) {
        self.ecs = ecs
        self.scene = scene
    }

    func deselect(_ uuid: UUID) {
        ecs.getSelectioner(for: uuid).deselect()
    }

    func deselect(_ uuids: Set<UUID>) {
        uuids.forEach { deselect($0) }
    }

    func deselect(_ objectType: ECS.Entity.Type) {
        ecs.entities.values.forEach { entity in
            if getObjectType(entity.uuid) == objectType {
                deselect(entity.uuid)
            }
        }
    }

    func deselect(ifNot objectType: ECS.Entity.Type) {
        ecs.entities.values.forEach { entity in
            if getObjectType(entity.uuid) != objectType {
                deselect(entity.uuid)
            }
        }
    }

    func deselectAll() {
        ecs.entities.keys.forEach { deselect($0) }
    }

    func entityIsSelected(_ entity: ECS.Entity) -> Bool {
        ecs.getSelectioner(for: entity).isSelected
    }

    func getTopSelectable(at positionInView: CGPoint) -> ECS.Entity? {
        guard
            let node = scene.getTopNode(at: positionInView),
            let entity = ecs.getOwnerEntity(for: node) else {
            return nil
        }

        return entity
    }

    func getSelectableObjects(in rectangle: CGRect) -> Set<ECS.Entity>? {
        let nodes = scene.getNodes(in: rectangle)

        if nodes.isEmpty { return nil }

        let entities = nodes.compactMap { node in
            ecs.getOwnerEntity(for: node)
        }

        if entities.isEmpty { return nil }

        let selectables = entities.compactMap {
            ecs.isEntitySelectable($0) ? $0 : nil
        }

        return selectables.isEmpty ? nil : Set(selectables)
    }

    func getObjectType(_ uuid: UUID) -> ECS.Entity.Type {
        let entity = ecs.entities[uuid]!
        return type(of: entity)
    }

    func getSelected() -> Set<ECS.Entity>? {
        let selected: [ECS.Entity] = ecs.entities.values.compactMap { entity in
            ecs.isEntitySelected(entity) ? entity : nil
        }

        return selected.isEmpty ? nil : Set(selected)
    }

    func select(_ entity: ECS.Entity) {
        let selectioner = entity.component(ofType: ECS.Components.Selectioner.self)!
        selectioner.select()
    }

    func select(_ entities: Set<ECS.Entity>) {
        entities.forEach { select($0) }
    }

    func toggleSelect(_ entity: ECS.Entity) {
        let selectioner = entity.component(ofType: ECS.Components.Selectioner.self)!
        selectioner.toggleSelect()
    }

    func toggleSelect(_ entities: Set<ECS.Entity>) {
        entities.forEach { toggleSelect($0) }
    }

}
