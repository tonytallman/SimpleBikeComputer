import Foundation

public final class CoreLocationSpeedSource: @unchecked Sendable {
    public let speed: AsyncStream<Measurement<UnitSpeed>>
    public let isAvailable: AsyncStream<Bool>

    private let consumeTask: Task<Void, Never>?

    public convenience init() {
        self.init(updates: LiveLocationUpdates())
    }

    package init<Provider: LocationUpdatesProviding>(updates: Provider) {
        let streams = Self.makeStreams(from: updates)
        speed = streams.speed
        isAvailable = streams.isAvailable
        consumeTask = streams.consumeTask
    }

    deinit {
        consumeTask?.cancel()
    }

    private static func isAvailable(_ snapshot: LocationUpdateSnapshot) -> Bool {
        !snapshot.authorizationDenied && !snapshot.authorizationDeniedGlobally
    }

    private static func makeStreams<Provider: LocationUpdatesProviding>(
        from updates: Provider,
    ) -> (
        speed: AsyncStream<Measurement<UnitSpeed>>,
        isAvailable: AsyncStream<Bool>,
        consumeTask: Task<Void, Never>,
    ) {
        let (speedStream, speedContinuation) = AsyncStream.makeStream(
            of: Measurement<UnitSpeed>.self,
        )
        let (availabilityStream, availabilityContinuation) = AsyncStream.makeStream(
            of: Bool.self,
        )

        let consumeTask = Task {
            do {
                for try await snapshot in updates.updates {
                    let available = isAvailable(snapshot)
                    availabilityContinuation.yield(available)

                    if let speedValue = snapshot.speed {
                        speedContinuation.yield(
                            Measurement(value: speedValue, unit: .metersPerSecond),
                        )
                    }
                }
            } catch {
                // liveUpdates failures end both streams without leaking errors.
            }

            speedContinuation.finish()
            availabilityContinuation.finish()
        }

        return (speedStream, availabilityStream, consumeTask)
    }
}
