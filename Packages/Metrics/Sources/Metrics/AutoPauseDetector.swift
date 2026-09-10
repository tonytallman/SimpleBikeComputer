import AsyncAlgorithms
import Foundation

/// Monitors speed against a threshold and publishes moving/paused state.
/// Speed at or above the threshold is `.moving`; below is `.paused`.
public final class AutoPauseDetector: Sendable {
    private let statesBroadcaster: MotionStateBroadcaster
    private let upstreamTask: Task<Void, Never>

    public var states: AsyncStream<MotionState> {
        statesBroadcaster.makeStream()
    }

    public init<Speed: AsyncSequence, Threshold: AsyncSequence>(
        speed: Speed,
        threshold: Threshold,
    ) where
        Speed.Element == Measurement<UnitSpeed>,
        Speed.Failure == Never,
        Speed: Sendable,
        Threshold.Element == Measurement<UnitSpeed>,
        Threshold.Failure == Never,
        Threshold: Sendable
    {
        let broadcaster = MotionStateBroadcaster(initial: .paused)
        statesBroadcaster = broadcaster

        upstreamTask = Task {
            let combined = combineLatest(speed, threshold)
            var lastState: MotionState?

            for await (speed, threshold) in combined {
                guard !Task.isCancelled else { return }

                let state: MotionState = speed >= threshold ? .moving : .paused
                guard state != lastState else { continue }

                lastState = state
                broadcaster.send(state)
            }
        }
    }
}

private final class MotionStateBroadcaster: @unchecked Sendable {
    private let lock = NSLock()
    private var latest: MotionState
    private var subscribers: [UUID: AsyncStream<MotionState>.Continuation] = [:]

    init(initial: MotionState) {
        latest = initial
    }

    func send(_ state: MotionState) {
        lock.lock()
        latest = state
        let currentSubscribers = subscribers.values
        lock.unlock()

        for continuation in currentSubscribers {
            continuation.yield(state)
        }
    }

    func makeStream() -> AsyncStream<MotionState> {
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
