import Foundation

public struct RuntimeMetric<MeasurementType: Sendable>: Metric {
    public let snapshots: AsyncStream<MetricSnapshot<MeasurementType>>

    public init(snapshots: AsyncStream<MetricSnapshot<MeasurementType>>) {
        self.snapshots = snapshots
    }
}
