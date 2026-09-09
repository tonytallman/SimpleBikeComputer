import Foundation

/// Multicast async stream that replays the latest value to each new subscriber.
final class CurrentValueBroadcaster<Element: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var latest: Element
    private var subscribers: [UUID: AsyncStream<Element>.Continuation] = [:]

    init(initial: Element) {
        latest = initial
    }

    var currentValue: Element {
        lock.lock()
        defer { lock.unlock() }
        return latest
    }

    func send(_ value: Element) {
        lock.lock()
        latest = value
        let currentSubscribers = subscribers.values
        lock.unlock()

        for continuation in currentSubscribers {
            continuation.yield(value)
        }
    }

    func makeStream() -> AsyncStream<Element> {
        let id = UUID()
        return AsyncStream { continuation in
            lock.lock()
            continuation.yield(latest)
            subscribers[id] = continuation
            lock.unlock()

            continuation.onTermination = { [weak self] _ in
                self?.removeSubscriber(id)
            }
        }
    }

    private func removeSubscriber(_ id: UUID) {
        lock.lock()
        subscribers.removeValue(forKey: id)
        lock.unlock()
    }
}
