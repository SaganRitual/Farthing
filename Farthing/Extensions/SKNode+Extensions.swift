// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import SpriteKit

extension SKNode {
    func getOwnerEntityId() -> UUID? {
        guard let entry = userData?["ownerEntityId"] else { return nil }
        let uuid = entry as! UUID
        return uuid
    }

    func setOwnerEntityId(_ uuid: UUID) {
        if userData == nil {
            userData = [:]
        }

        userData!["ownerEntityId"] = uuid
    }
}
