import CoreLocation
import Foundation

public final class CoreLocationSpeedSource: @unchecked Sendable {
    public let speed: AsyncStream<Measurement<UnitSpeed>>
    public let isAvailable: AsyncStream<Bool>
    public let wheelSamples: AsyncStream<WheelSample>

    private let authorizationSession: CLServiceSession?
    private let backgroundActivitySession: CLBackgroundActivitySession?
    private let consumeTask: Task<Void, Never>?

    public convenience init() {
        self.init(
            updates: LiveLocationUpdates(),
            authorizationSession: CLServiceSession(authorization: .always),
            backgroundActivitySession: CLBackgroundActivitySession(),
        )
    }

    private init(
        updates: some LocationUpdatesProviding,
        authorizationSession: CLServiceSession?,
        backgroundActivitySession: CLBackgroundActivitySession?,
    ) {
        self.authorizationSession = authorizationSession
        self.backgroundActivitySession = backgroundActivitySession
        let streams = Self.makeStreams(from: updates)
        speed = streams.speed
        isAvailable = streams.isAvailable
        wheelSamples = streams.wheelSamples
        consumeTask = streams.consumeTask
    }

    package init<Provider: LocationUpdatesProviding>(updates: Provider) {
        authorizationSession = nil
        backgroundActivitySession = nil
        let streams = Self.makeStreams(from: updates)
        speed = streams.speed
        isAvailable = streams.isAvailable
        wheelSamples = streams.wheelSamples
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
        wheelSamples: AsyncStream<WheelSample>,
        consumeTask: Task<Void, Never>,
    ) {
        let (speedStream, speedContinuation) = AsyncStream.makeStream(
            of: Measurement<UnitSpeed>.self,
        )
        let (availabilityStream, availabilityContinuation) = AsyncStream.makeStream(
            of: Bool.self,
        )
        let (wheelSamplesStream, wheelSamplesContinuation) = AsyncStream.makeStream(
            of: WheelSample.self,
        )

        let consumeTask = Task {
            var previousTimestamp: Date?

            do {
                for try await snapshot in updates.updates {
                    let available = isAvailable(snapshot)
                    availabilityContinuation.yield(available)

                    guard let speedValue = snapshot.speed else {
                        previousTimestamp = nil
                        continue
                    }

                    speedContinuation.yield(
                        Measurement(value: speedValue, unit: .metersPerSecond),
                    )

                    guard let timestamp = snapshot.timestamp else {
                        previousTimestamp = nil
                        continue
                    }

                    if let previousTimestamp {
                        let deltaTime = timestamp.timeIntervalSince(previousTimestamp)
                        // A duplicate or out-of-order fix keeps the newer anchor so the
                        // next fix measures the interval that actually elapsed.
                        guard deltaTime > 0 else { continue }

                        wheelSamplesContinuation.yield(
                            WheelSample(
                                deltaDistance: Measurement(
                                    value: speedValue * deltaTime,
                                    unit: .meters,
                                ),
                                deltaTime: Measurement(
                                    value: deltaTime,
                                    unit: .seconds,
                                ),
                            ),
                        )
                    }

                    previousTimestamp = timestamp
                }
            } catch {
                // liveUpdates failures end all streams without leaking errors.
            }

            speedContinuation.finish()
            availabilityContinuation.finish()
            wheelSamplesContinuation.finish()
        }

        return (speedStream, availabilityStream, wheelSamplesStream, consumeTask)
    }
}
