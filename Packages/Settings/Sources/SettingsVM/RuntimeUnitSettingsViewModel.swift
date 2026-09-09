import Foundation
import Observation

@MainActor
public protocol UnitSettingsViewModel: AnyObject, Observable {
    var currentSpeedUnits: UnitSpeed { get }
    var currentDistanceUnits: UnitLength { get }
    var availableSpeedUnits: [UnitSpeed] { get }
    var availableDistanceUnits: [UnitLength] { get }
    func setSpeedUnits(_ units: UnitSpeed)
    func setDistanceUnits(_ units: UnitLength)
}

@Observable
@MainActor
public final class RuntimeUnitSettingsViewModel: UnitSettingsViewModel {
    public var currentSpeedUnits: UnitSpeed = .milesPerHour
    public var currentDistanceUnits: UnitLength = .miles
    public let availableSpeedUnits: [UnitSpeed] = [.milesPerHour, .kilometersPerHour]
    public let availableDistanceUnits: [UnitLength] = [.miles, .kilometers]

    @ObservationIgnored
    private let metricsSettings: MetricsSettings

    @ObservationIgnored
    private var speedObserveTask: Task<Void, Never>?

    @ObservationIgnored
    private var distanceObserveTask: Task<Void, Never>?

    public init(metricsSettings: MetricsSettings) {
        self.metricsSettings = metricsSettings
        let speedUnits = metricsSettings.speedUnits
        let distanceUnits = metricsSettings.distanceUnits
        speedObserveTask = Task { @MainActor [weak self] in
            for await units in speedUnits {
                guard !Task.isCancelled else { return }
                self?.currentSpeedUnits = units
            }
        }
        distanceObserveTask = Task { @MainActor [weak self] in
            for await units in distanceUnits {
                guard !Task.isCancelled else { return }
                self?.currentDistanceUnits = units
            }
        }
    }

    deinit {
        speedObserveTask?.cancel()
        distanceObserveTask?.cancel()
    }

    public func setSpeedUnits(_ units: UnitSpeed) {
        metricsSettings.setSpeedUnits(units)
    }

    public func setDistanceUnits(_ units: UnitLength) {
        metricsSettings.setDistanceUnits(units)
    }
}
