import CoreLocation
import Foundation

struct LiveLocationUpdates: LocationUpdatesProviding, Sendable {
    var updates: LiveLocationUpdateSequence {
        LiveLocationUpdateSequence()
    }
}

struct LiveLocationUpdateSequence: AsyncSequence, Sendable {
    typealias Element = LocationUpdateSnapshot
    typealias AsyncIterator = Iterator

    struct Iterator: AsyncIteratorProtocol {
        private var iterator: CLLocationUpdate.Updates.AsyncIterator

        init() {
            iterator = CLLocationUpdate.liveUpdates(.fitness).makeAsyncIterator()
        }

        mutating func next() async throws -> LocationUpdateSnapshot? {
            guard let update = try await iterator.next() else {
                return nil
            }

            let speed: Double?
            if let location = update.location {
                speed = LocationUpdateSnapshot.speed(fromMetersPerSecond: location.speed)
            } else {
                speed = nil
            }

            return LocationUpdateSnapshot(
                speed: speed,
                authorizationDenied: update.authorizationDenied,
                authorizationDeniedGlobally: update.authorizationDeniedGlobally,
            )
        }
    }

    func makeAsyncIterator() -> Iterator {
        Iterator()
    }
}
