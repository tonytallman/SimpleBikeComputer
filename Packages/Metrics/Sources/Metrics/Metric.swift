import Foundation

public protocol Metric<MeasurementType> {
    associatedtype MeasurementType: Sendable
    var snapshots: AsyncStream<MetricSnapshot<MeasurementType>> { get }
}
