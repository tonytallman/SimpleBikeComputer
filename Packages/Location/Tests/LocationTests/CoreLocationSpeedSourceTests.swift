import Foundation
import Location
import Testing

private struct FakeLocationUpdates: LocationUpdatesProviding, Sendable {
    let snapshots: [LocationUpdateSnapshot]

    var updates: FakeLocationUpdateSequence {
        FakeLocationUpdateSequence(snapshots: snapshots)
    }
}

private struct FakeLocationUpdateSequence: AsyncSequence, Sendable {
    typealias Element = LocationUpdateSnapshot
    typealias AsyncIterator = Iterator

    let snapshots: [LocationUpdateSnapshot]

    struct Iterator: AsyncIteratorProtocol {
        private var snapshots: [LocationUpdateSnapshot]

        init(snapshots: [LocationUpdateSnapshot]) {
            self.snapshots = snapshots
        }

        mutating func next() async -> LocationUpdateSnapshot? {
            guard !snapshots.isEmpty else { return nil }
            return snapshots.removeFirst()
        }
    }

    func makeAsyncIterator() -> Iterator {
        Iterator(snapshots: snapshots)
    }
}

@MainActor
struct CoreLocationSpeedSourceTests {
    @Test
    func yieldsSpeedWhenValid() async {
        let source = CoreLocationSpeedSource(
            updates: FakeLocationUpdates(
                snapshots: [
                    LocationUpdateSnapshot(
                        speed: 5.5,
                        authorizationDenied: false,
                        authorizationDeniedGlobally: false,
                    ),
                ],
            ),
        )

        var speeds: [Measurement<UnitSpeed>] = []
        let task = Task {
            for await speed in source.speed {
                speeds.append(speed)
                break
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        #expect(speeds.count == 1)
        #expect(speeds[0].value == 5.5)
        #expect(speeds[0].unit == .metersPerSecond)

        await task.value
    }

    @Test
    func speedMappingTreatsNegativeAsZero() {
        #expect(LocationUpdateSnapshot.speed(fromMetersPerSecond: -1) == 0)
        #expect(LocationUpdateSnapshot.speed(fromMetersPerSecond: 5.5) == 5.5)
        #expect(LocationUpdateSnapshot.speed(fromMetersPerSecond: 0) == 0)
    }

    @Test
    func yieldsZeroWhenStationary() async {
        let source = CoreLocationSpeedSource(
            updates: FakeLocationUpdates(
                snapshots: [
                    LocationUpdateSnapshot(
                        speed: 0,
                        authorizationDenied: false,
                        authorizationDeniedGlobally: false,
                    ),
                ],
            ),
        )

        var speeds: [Measurement<UnitSpeed>] = []
        let task = Task {
            for await speed in source.speed {
                speeds.append(speed)
                break
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        #expect(speeds.count == 1)
        #expect(speeds[0].value == 0)
        #expect(speeds[0].unit == .metersPerSecond)

        await task.value
    }

    @Test
    func skipsNilSpeedWhenNoLocation() async {
        let source = CoreLocationSpeedSource(
            updates: FakeLocationUpdates(
                snapshots: [
                    LocationUpdateSnapshot(
                        speed: nil,
                        authorizationDenied: false,
                        authorizationDeniedGlobally: false,
                    ),
                ],
            ),
        )

        var speeds: [Measurement<UnitSpeed>] = []
        let task = Task {
            for await speed in source.speed {
                speeds.append(speed)
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        #expect(speeds.isEmpty)

        await task.value
    }

    @Test
    func skipsNilSpeedThenYieldsValidSpeed() async {
        let source = CoreLocationSpeedSource(
            updates: FakeLocationUpdates(
                snapshots: [
                    LocationUpdateSnapshot(
                        speed: nil,
                        authorizationDenied: false,
                        authorizationDeniedGlobally: false,
                    ),
                    LocationUpdateSnapshot(
                        speed: 3.0,
                        authorizationDenied: false,
                        authorizationDeniedGlobally: false,
                    ),
                ],
            ),
        )

        var speeds: [Measurement<UnitSpeed>] = []
        let task = Task {
            for await speed in source.speed {
                speeds.append(speed)
                break
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        #expect(speeds.count == 1)
        #expect(speeds[0].value == 3.0)

        await task.value
    }

    @Test
    func isAvailableWhenAuthorized() async {
        let source = CoreLocationSpeedSource(
            updates: FakeLocationUpdates(
                snapshots: [
                    LocationUpdateSnapshot(
                        speed: nil,
                        authorizationDenied: false,
                        authorizationDeniedGlobally: false,
                    ),
                ],
            ),
        )

        var availability: [Bool] = []
        let task = Task {
            for await isAvailable in source.isAvailable {
                availability.append(isAvailable)
                break
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        #expect(availability == [true])

        await task.value
    }

    @Test
    func isUnavailableWhenAuthorizationDenied() async {
        let source = CoreLocationSpeedSource(
            updates: FakeLocationUpdates(
                snapshots: [
                    LocationUpdateSnapshot(
                        speed: nil,
                        authorizationDenied: true,
                        authorizationDeniedGlobally: false,
                    ),
                ],
            ),
        )

        var availability: [Bool] = []
        let task = Task {
            for await isAvailable in source.isAvailable {
                availability.append(isAvailable)
                break
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        #expect(availability == [false])

        await task.value
    }

    @Test
    func isUnavailableWhenLocationServicesDisabledGlobally() async {
        let source = CoreLocationSpeedSource(
            updates: FakeLocationUpdates(
                snapshots: [
                    LocationUpdateSnapshot(
                        speed: nil,
                        authorizationDenied: false,
                        authorizationDeniedGlobally: true,
                    ),
                ],
            ),
        )

        var availability: [Bool] = []
        let task = Task {
            for await isAvailable in source.isAvailable {
                availability.append(isAvailable)
                break
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        #expect(availability == [false])

        await task.value
    }

    @Test
    func reflectsAvailabilityChanges() async {
        let source = CoreLocationSpeedSource(
            updates: FakeLocationUpdates(
                snapshots: [
                    LocationUpdateSnapshot(
                        speed: nil,
                        authorizationDenied: false,
                        authorizationDeniedGlobally: false,
                    ),
                    LocationUpdateSnapshot(
                        speed: nil,
                        authorizationDenied: true,
                        authorizationDeniedGlobally: false,
                    ),
                ],
            ),
        )

        var availability: [Bool] = []
        let task = Task {
            for await isAvailable in source.isAvailable {
                availability.append(isAvailable)
                if availability.count == 2 { break }
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        #expect(availability == [true, false])

        await task.value
    }
}
