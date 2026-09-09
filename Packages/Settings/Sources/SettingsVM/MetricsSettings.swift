import Foundation

public protocol MetricsSettings: Sendable {
    var speedUnits: AsyncStream<UnitSpeed> { get }
    var distanceUnits: AsyncStream<UnitLength> { get }
    func setSpeedUnits(_ units: UnitSpeed)
    func setDistanceUnits(_ units: UnitLength)
}

public final class DefaultMetricsSettings: MetricsSettings, @unchecked Sendable {
    private let storage: SettingsStorage
    private let speedUnitsBroadcaster: CurrentValueBroadcaster<UnitSpeed>
    private let distanceUnitsBroadcaster: CurrentValueBroadcaster<UnitLength>

    private static let speedUnitsKey = "speedUnits"
    private static let distanceUnitsKey = "distanceUnits"

    public var speedUnits: AsyncStream<UnitSpeed> {
        speedUnitsBroadcaster.makeStream()
    }

    public var distanceUnits: AsyncStream<UnitLength> {
        distanceUnitsBroadcaster.makeStream()
    }

    public init(storage: SettingsStorage) {
        self.storage = storage

        let speedUnits: UnitSpeed = (storage.get(forKey: Self.speedUnitsKey) as? String)
            .flatMap(SpeedUnitKey.init(rawValue:))?.unit ?? .milesPerHour
        let distanceUnits: UnitLength = (storage.get(forKey: Self.distanceUnitsKey) as? String)
            .flatMap(DistanceUnitKey.init(rawValue:))?.unit ?? .miles

        speedUnitsBroadcaster = CurrentValueBroadcaster(initial: speedUnits)
        distanceUnitsBroadcaster = CurrentValueBroadcaster(initial: distanceUnits)
    }

    public func setSpeedUnits(_ units: UnitSpeed) {
        speedUnitsBroadcaster.send(units)
        storage.set(value: SpeedUnitKey(unit: units)?.rawValue, forKey: Self.speedUnitsKey)
    }

    public func setDistanceUnits(_ units: UnitLength) {
        distanceUnitsBroadcaster.send(units)
        storage.set(value: DistanceUnitKey(unit: units)?.rawValue, forKey: Self.distanceUnitsKey)
    }
}
