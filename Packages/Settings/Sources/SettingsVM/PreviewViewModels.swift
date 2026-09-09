#if DEBUG
import Foundation
import Observation

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
public final class PreviewSettingsViewModel: SettingsViewModel {
    public let units = PreviewUnitSettingsViewModel()

    public init() {}
}
#endif
