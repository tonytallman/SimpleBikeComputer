import AsyncAlgorithms
import Foundation

extension AsyncSequence where Failure == Never {
    /// Converts measurements to the units emitted by `units`.
    /// Re-emits when either the measurement or preferred unit changes.
    public func inUnits<UnitType: Dimension, Units: AsyncSequence>(
        _ units: Units,
    ) -> AsyncStream<Measurement<UnitType>>
    where Element == Measurement<UnitType>,
        Self: Sendable,
        Units.Element == UnitType,
        Units.Failure == Never,
        Units: Sendable
    {
        let combined = combineLatest(self, units)
        return AsyncStream { continuation in
            let task = Task {
                for await (measurement, unit) in combined {
                    guard !Task.isCancelled else { return }
                    continuation.yield(measurement.converted(to: unit))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    /// Converts available snapshot values to the units emitted by `units`.
    /// `.unavailable` passes through unchanged. Re-emits when either the snapshot or unit changes.
    public func inUnits<UnitType: Dimension, Units: AsyncSequence>(
        _ units: Units,
    ) -> AsyncStream<MetricSnapshot<Measurement<UnitType>>>
    where Element == MetricSnapshot<Measurement<UnitType>>,
        Self: Sendable,
        Units.Element == UnitType,
        Units.Failure == Never,
        Units: Sendable
    {
        let combined = combineLatest(self, units)
        return AsyncStream { continuation in
            let task = Task {
                for await (snapshot, unit) in combined {
                    guard !Task.isCancelled else { return }
                    switch snapshot {
                    case .unavailable:
                        continuation.yield(.unavailable)
                    case .available(let value, let source):
                        continuation.yield(.available(
                            value: value.converted(to: unit),
                            source: source,
                        ))
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
