import CoreLocation
import Foundation

@MainActor
package protocol LocationPermissionsSettings {
    var locationPermissionStatus: String { get }
}

package func locationPermissionStatusText(for status: CLAuthorizationStatus) -> String {
    switch status {
    case .authorizedAlways:
        "Always"
    case .authorizedWhenInUse:
        "While Using"
    case .denied:
        "Denied"
    case .restricted:
        "Restricted"
    case .notDetermined:
        "Not Determined"
    @unknown default:
        "Unknown"
    }
}

package struct DefaultLocationPermissionsSettings: LocationPermissionsSettings {
    package init() {}

    package var locationPermissionStatus: String {
        locationPermissionStatusText(for: CLLocationManager().authorizationStatus)
    }
}
