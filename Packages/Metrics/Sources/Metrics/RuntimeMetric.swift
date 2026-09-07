import Foundation

public struct RuntimeMetric<MeasurementType: Sendable>: Metric {
    public let values: AsyncStream<MeasurementType>
    public let isAvailable: AsyncStream<Bool>
    public let source: MetricSource

    public init(
        values: AsyncStream<MeasurementType>,
        isAvailable: AsyncStream<Bool>,
        source: MetricSource,
    ) {
        self.values = values
        self.isAvailable = isAvailable
        self.source = source
    }
}
