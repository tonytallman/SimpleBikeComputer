#if DEBUG
import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
public final class PreviewUnitSettingsViewModel: UnitSettingsViewModel {
    public var currentSpeedUnits: UnitSpeed = .milesPerHour
    public var currentDistanceUnits: UnitLength = .miles
    public let availableSpeedUnits: [UnitSpeed] = [.milesPerHour, .kilometersPerHour]
    public let availableDistanceUnits: [UnitLength] = [.miles, .kilometers]

    public init() {}

    public func setSpeedUnits(_ units: UnitSpeed) {
        currentSpeedUnits = units
    }

    public func setDistanceUnits(_ units: UnitLength) {
        currentDistanceUnits = units
    }
}

@Observable
@MainActor
public final class PreviewAutopauseSettingsViewModel: AutopauseSettingsViewModel {
    public var currentAutoPauseThreshold = Measurement<UnitSpeed>(value: 3, unit: .milesPerHour)
    public var currentSpeedUnits: UnitSpeed = .milesPerHour

    public init() {}

    public func setAutoPauseThreshold(_ threshold: Measurement<UnitSpeed>) {
        currentAutoPauseThreshold = threshold
    }
}

@Observable
@MainActor
public final class PreviewSystemSettingsViewModel: SystemSettingsViewModel {
    public var keepScreenOn = true
    public var locationPermissionStatusText = "Always"

    public init() {}

    public func setKeepScreenOn(_ keepOn: Bool) {
        keepScreenOn = keepOn
    }

    public func viewAppeared() {}

    public func scenePhaseChanged(to phase: ScenePhase) {}

    public func openLocationPermissions() {}
}

@Observable
@MainActor
public final class PreviewSettingsViewModel: SettingsViewModel {
    public let units = PreviewUnitSettingsViewModel()
    public let autopause = PreviewAutopauseSettingsViewModel()
    public let system = PreviewSystemSettingsViewModel()

    public init() {}
}
#endif
