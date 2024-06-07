// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import SpriteKit

extension SpriteWorld {

    enum Physics {
        enum CollisionMask {
            static let gremlin = UInt32(0x0000_0001)
            static let foobar = UInt32(0x0000_0002)
        }
    }

}
