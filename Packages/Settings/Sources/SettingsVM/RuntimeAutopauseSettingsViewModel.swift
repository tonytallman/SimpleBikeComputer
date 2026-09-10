import Foundation
import Observation

@MainActor
public protocol AutopauseSettingsViewModel: AnyObject, Observable {
    var currentAutoPauseThreshold: Measurement<UnitSpeed> { get }
    var currentSpeedUnits: UnitSpeed { get }
    func setAutoPauseThreshold(_ threshold: Measurement<UnitSpeed>)
}

@Observable
@MainActor
public final class RuntimeAutopauseSettingsViewModel: AutopauseSettingsViewModel {
    public var currentAutoPauseThreshold = Measurement<UnitSpeed>(value: 3, unit: .milesPerHour)
    public var currentSpeedUnits: UnitSpeed = .milesPerHour

    @ObservationIgnored
    private let metricsSettings: MetricsSettings

    @ObservationIgnored
    private var thresholdObserveTask: Task<Void, Never>?

    @ObservationIgnored
    private var speedUnitsObserveTask: Task<Void, Never>?

    public init(metricsSettings: MetricsSettings) {
        self.metricsSettings = metricsSettings
        let autoPauseThreshold = metricsSettings.autoPauseThreshold
        let speedUnits = metricsSettings.speedUnits

        thresholdObserveTask = Task { @MainActor [weak self] in
            for await threshold in autoPauseThreshold {
                guard !Task.isCancelled else { return }
                self?.currentAutoPauseThreshold = threshold
            }
        }

        speedUnitsObserveTask = Task { @MainActor [weak self] in
            for await units in speedUnits {
                guard !Task.isCancelled else { return }
                self?.currentSpeedUnits = units
            }
        }
    }

    deinit {
        thresholdObserveTask?.cancel()
        speedUnitsObserveTask?.cancel()
    }

    public func setAutoPauseThreshold(_ threshold: Measurement<UnitSpeed>) {
        metricsSettings.setAutoPauseThreshold(threshold)
    }
}
