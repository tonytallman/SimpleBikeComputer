import Foundation

package final class MetricWithSharing<MeasurementType: Sendable>: Metric {
    private let snapshotsBroadcaster: SharedBroadcaster<MetricSnapshot<MeasurementType>>

    package init(wrapping wrapped: any Metric<MeasurementType>) {
        snapshotsBroadcaster = SharedBroadcaster(upstream: wrapped.snapshots)
    }

    public var snapshots: AsyncStream<MetricSnapshot<MeasurementType>> {
        snapshotsBroadcaster.makeStream()
    }
}

public extension Metric {
    func shared() -> any Metric<MeasurementType> {
        MetricWithSharing(wrapping: self)
    }
}

private final class SharedBroadcaster<Element: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var subscribers: [UUID: AsyncStream<Element>.Continuation] = [:]
    private var latest: Element?
    private var finished = false
    private var upstreamTask: Task<Void, Never>?

    init(upstream: AsyncStream<Element>) {
        upstreamTask = Task {
            for await element in upstream {
                yield(element)
            }
            finish()
        }
    }

    func makeStream() -> AsyncStream<Element> {
        let id = UUID()
        return AsyncStream { continuation in
            lock.lock()
            if finished {
                if let latest {
                    continuation.yield(latest)
                }
                continuation.finish()
                lock.unlock()
                return
            }

            if let latest {
                continuation.yield(latest)
            }

            subscribers[id] = continuation
            lock.unlock()

            continuation.onTermination = { [weak self] _ in
                self?.removeSubscriber(id)
            }
        }
    }

    private func yield(_ element: Element) {
        lock.lock()
        latest = element
        let currentSubscribers = subscribers.values
        lock.unlock()

        for continuation in currentSubscribers {
            continuation.yield(element)
        }
    }

    private func finish() {
        lock.lock()
        finished = true
        let currentSubscribers = subscribers.values
        lock.unlock()

        for continuation in currentSubscribers {
            continuation.finish()
        }
    }

    private func removeSubscriber(_ id: UUID) {
        lock.lock()
        subscribers.removeValue(forKey: id)
        lock.unlock()
    }
}
