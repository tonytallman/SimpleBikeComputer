import Foundation

public protocol MetricsSettings: Sendable {
    var speedUnits: AsyncStream<UnitSpeed> { get }
    var distanceUnits: AsyncStream<UnitLength> { get }
    var autoPauseThreshold: AsyncStream<Measurement<UnitSpeed>> { get }
    func setSpeedUnits(_ units: UnitSpeed)
    func setDistanceUnits(_ units: UnitLength)
    func setAutoPauseThreshold(_ threshold: Measurement<UnitSpeed>)
}

public final class DefaultMetricsSettings: MetricsSettings, @unchecked Sendable {
    private let storage: SettingsStorage
    private let speedUnitsBroadcaster: CurrentValueBroadcaster<UnitSpeed>
    private let distanceUnitsBroadcaster: CurrentValueBroadcaster<UnitLength>
    private let autoPauseThresholdBroadcaster: CurrentValueBroadcaster<Measurement<UnitSpeed>>

    private static let speedUnitsKey = "speedUnits"
    private static let distanceUnitsKey = "distanceUnits"
    private static let autoPauseThresholdBaseValueKey = "autoPauseThresholdBaseValue"
    private static let autoPauseThresholdUnitKey = "autoPauseThresholdUnit"

    public var speedUnits: AsyncStream<UnitSpeed> {
        speedUnitsBroadcaster.makeStream()
    }

    public var distanceUnits: AsyncStream<UnitLength> {
        distanceUnitsBroadcaster.makeStream()
    }

    public var autoPauseThreshold: AsyncStream<Measurement<UnitSpeed>> {
        autoPauseThresholdBroadcaster.makeStream()
    }

    public init(storage: SettingsStorage) {
        self.storage = storage

        let speedUnits: UnitSpeed = (storage.get(forKey: Self.speedUnitsKey) as? String)
            .flatMap(SpeedUnitKey.init(rawValue:))?.unit ?? .milesPerHour
        let distanceUnits: UnitLength = (storage.get(forKey: Self.distanceUnitsKey) as? String)
            .flatMap(DistanceUnitKey.init(rawValue:))?.unit ?? .miles
        let autoPauseThreshold = Self.restoreAutoPauseThreshold(storage: storage)

        speedUnitsBroadcaster = CurrentValueBroadcaster(initial: speedUnits)
        distanceUnitsBroadcaster = CurrentValueBroadcaster(initial: distanceUnits)
        autoPauseThresholdBroadcaster = CurrentValueBroadcaster(initial: autoPauseThreshold)
    }

    public func setSpeedUnits(_ units: UnitSpeed) {
        speedUnitsBroadcaster.send(units)
        storage.set(value: SpeedUnitKey(unit: units)?.rawValue, forKey: Self.speedUnitsKey)
    }

    public func setDistanceUnits(_ units: UnitLength) {
        distanceUnitsBroadcaster.send(units)
        storage.set(value: DistanceUnitKey(unit: units)?.rawValue, forKey: Self.distanceUnitsKey)
    }

    public func setAutoPauseThreshold(_ threshold: Measurement<UnitSpeed>) {
        autoPauseThresholdBroadcaster.send(threshold)
        let baseValue = threshold.converted(to: .metersPerSecond).value
        storage.set(value: baseValue, forKey: Self.autoPauseThresholdBaseValueKey)
        storage.set(value: SpeedUnitKey(unit: threshold.unit)?.rawValue, forKey: Self.autoPauseThresholdUnitKey)
    }

    private static func restoreAutoPauseThreshold(storage: SettingsStorage) -> Measurement<UnitSpeed> {
        guard
            let baseValue = storage.get(forKey: autoPauseThresholdBaseValueKey) as? Double,
            let unitKey = storage.get(forKey: autoPauseThresholdUnitKey) as? String,
            let speedUnitKey = SpeedUnitKey(rawValue: unitKey)
        else {
            return Measurement(value: 3, unit: .milesPerHour)
        }

        let baseMeasurement = Measurement<UnitSpeed>(value: baseValue, unit: .metersPerSecond)
        return baseMeasurement.converted(to: speedUnitKey.unit)
    }
}
