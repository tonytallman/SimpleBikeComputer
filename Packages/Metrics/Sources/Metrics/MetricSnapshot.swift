import AsyncAlgorithms
import Foundation

private enum CombiningEvent<Value: Sendable>: Sendable {
    case value(Value)
    case availability(Bool)
}

public enum MetricSnapshot<Value: Sendable>: Sendable {
    case unavailable
    case available(value: Value, source: MetricSource)
}

extension MetricSnapshot: Equatable where Value: Equatable {}

extension MetricSnapshot {
    /// Folds separate value and availability streams into atomic snapshots.
    ///
    /// Holds a value received before the first availability event and emits it when
    /// availability becomes true. While unavailable, values are dropped and
    /// `.unavailable` is emitted. While available, `.available` is emitted only when a
    /// new value arrives; restoring availability does not replay a cached value.
    public static func combining(
        values: AsyncStream<Value>,
        isAvailable: AsyncStream<Bool>,
        source: MetricSource,
    ) -> AsyncStream<MetricSnapshot<Value>> {
        AsyncStream { continuation in
            let task = Task {
                let valueEvents = values.map { CombiningEvent<Value>.value($0) }
                let availabilityEvents = isAvailable.map { CombiningEvent<Value>.availability($0) }
                let events = merge(valueEvents, availabilityEvents)

                var available: Bool?
                var pendingValue: Value?

                for await event in events {
                    guard !Task.isCancelled else { return }

                    switch event {
                    case .availability(let isAvailable):
                        available = isAvailable
                        if isAvailable {
                            if let held = pendingValue {
                                continuation.yield(.available(value: held, source: source))
                                pendingValue = nil
                            }
                        } else {
                            pendingValue = nil
                            continuation.yield(.unavailable)
                        }
                    case .value(let value):
                        switch available {
                        case true:
                            continuation.yield(.available(value: value, source: source))
                        case nil:
                            pendingValue = value
                        case false:
                            break
                        }
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
