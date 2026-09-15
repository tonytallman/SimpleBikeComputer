import Foundation

public struct WheelSample: Sendable, Equatable {
    public let deltaDistance: Measurement<UnitLength>
    public let deltaTime: Measurement<UnitDuration>
}
