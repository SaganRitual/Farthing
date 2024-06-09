// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import GameplayKit

enum InputStateProtocols {

    protocol ControlTap {
        func controlTap(at position: CGPoint, shiftKey: Bool)
    }

    protocol ControlTapBackground {
        func controlTapBackground(at position: CGPoint, shiftKey: Bool)
    }

    protocol ControlTapEntity {
        func controlTapEntity(_ entity: ECS.Entity, shiftKey: Bool)
    }

    protocol Drag {
        func drag(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool)
    }

    protocol DragBackground {
        func dragBackground(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool)
    }

    protocol DragEntity {
        func dragEntity(_ entity: ECS.Entity, startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool)
    }

    protocol DragEnd {
        func dragEnd(startVertex: CGPoint, endVertex: CGPoint, shiftKey: Bool)
    }

    protocol Tap {
        func tap(at position: CGPoint, shiftKey: Bool)
    }

    protocol TapBackground {
        func tapBackground(at position: CGPoint, shiftKey: Bool)
    }

    protocol TapEntity {
        func tapEntity(_ entity: ECS.Entity, shiftKey: Bool)
    }

}

class InputState: GKState {

    static let states: [InputState] = [
        DraggingBackground(),
        DraggingHandleSpaceAttributes(),
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
}

extension InputState {

    final class DraggingHandleAddPoint: InputState {
        override var isDraggingState: Bool { true }
    }

    final class DraggingWaypoint: InputState {
        override var isDraggingState: Bool { true }
    }

    final class EditAddPin: InputState {
        override var isTappableState: Bool { true }
    }

}
