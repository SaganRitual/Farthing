// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import GameplayKit

class InputState: GKState {

    static let states: [InputState] = [
        DraggingBackground(),
        DraggingGenericEntity(),
        EditSpaceAttributes(),
        PrimaryState(),
        PlaceWaypoint()
    ]

    var isDraggingState: Bool { false }
    var isTappableState: Bool { false }

    var sm: InputStateMachine { stateMachine! as! InputStateMachine }

    override func didEnter(from previousState: GKState?) {
        print("Did enter \(type(of: self))")
    }

    func setDragAnchors(for entities: Set<ECS.Entity>) {
        entities.forEach { entity in
            let cSprite = entity.component(ofType: ECS.Components.Sprite.self)!
            entity.dragAnchor = cSprite.sprite.position
        }
    }

    func controlTapBackground(at position: CGPoint, shiftKey: Bool = false) { }
    func controlTapEntity(_ entity: ECS.Entity, shiftKey: Bool = false) { }

    func drag(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) { }
    func dragEnd(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool = false) { }

    func tapBackground(at position: CGPoint, shiftKey: Bool = false) { }
    func tapEntity(_ entity: ECS.Entity, shiftKey: Bool = false) { }
}

extension InputState {

    final class DraggingHandleAddPoint: InputState {
        override var isDraggingState: Bool { true }
    }

    final class DraggingHandleSpaceAttributes: InputState {
        override var isDraggingState: Bool { true }
    }

    final class DraggingWaypoint: InputState {
        override var isDraggingState: Bool { true }
    }

    final class EditAddPin: InputState {
        override var isTappableState: Bool { true }
    }

}
