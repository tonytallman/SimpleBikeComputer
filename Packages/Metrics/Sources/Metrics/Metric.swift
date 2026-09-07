import Foundation

public protocol Metric<MeasurementType> {
    associatedtype MeasurementType: Sendable
    var values: AsyncStream<MeasurementType> { get }
    var isAvailable: AsyncStream<Bool> { get }
    var source: MetricSource { get }
}
