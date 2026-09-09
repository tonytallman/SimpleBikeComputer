import Foundation
import UIKit

@MainActor
package protocol SystemSettingsNavigator {
    func openAppPermissions()
}

package struct DefaultSystemSettingsNavigator: SystemSettingsNavigator {
    package init() {}

    package func openAppPermissions() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
