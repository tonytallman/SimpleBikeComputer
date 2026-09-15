import Foundation

package struct LocationUpdateSnapshot: Sendable {
    package let speed: Double?
    package let timestamp: Date?
    package let authorizationDenied: Bool
    package let authorizationDeniedGlobally: Bool

    package init(
        speed: Double?,
        timestamp: Date? = nil,
        authorizationDenied: Bool,
        authorizationDeniedGlobally: Bool,
    ) {
        self.speed = speed
        self.timestamp = timestamp
        self.authorizationDenied = authorizationDenied
        self.authorizationDeniedGlobally = authorizationDeniedGlobally
    }

    package static func speed(fromMetersPerSecond raw: Double) -> Double {
        raw >= 0 ? raw : 0
    }
}
