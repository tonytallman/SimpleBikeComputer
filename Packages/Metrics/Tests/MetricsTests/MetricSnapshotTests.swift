import Foundation
import Metrics
import Testing

@MainActor
@Suite("MetricSnapshot Tests")
struct MetricSnapshotTests {
    @Test("Combining waits for first availability before emitting")
    func waitsForFirstAvailability() async {
        let (valuesStream, valuesContinuation) = AsyncStream.makeStream(of: Int.self)
        let (availabilityStream, availabilityContinuation) = AsyncStream.makeStream(of: Bool.self)

        let snapshots = MetricSnapshot.combining(
            values: valuesStream,
            isAvailable: availabilityStream,
            source: .phone,
        )

        var received: [MetricSnapshot<Int>] = []
        let consumeTask = Task {
            for await snapshot in snapshots {
                received.append(snapshot)
                if received.count == 2 { break }
            }
        }

        try? await Task.sleep(for: .milliseconds(50))
        valuesContinuation.yield(10)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(received.isEmpty)

        availabilityContinuation.yield(true)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(received == [.available(value: 10, source: .phone)])

        valuesContinuation.yield(20)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(received == [
            .available(value: 10, source: .phone),
            .available(value: 20, source: .phone),
        ])

        valuesContinuation.finish()
        availabilityContinuation.finish()
        await consumeTask.value
    }

    @Test("Combining holds value received before first availability")
    func holdsValueBeforeFirstAvailability() async {
        let (valuesStream, valuesContinuation) = AsyncStream.makeStream(of: Int.self)
        let (availabilityStream, availabilityContinuation) = AsyncStream.makeStream(of: Bool.self)

        let snapshots = MetricSnapshot.combining(
            values: valuesStream,
            isAvailable: availabilityStream,
            source: .phone,
        )

        var received: [MetricSnapshot<Int>] = []
        let consumeTask = Task {
            for await snapshot in snapshots {
                received.append(snapshot)
                if received.count == 1 { break }
            }
        }

        valuesContinuation.yield(1)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(received.isEmpty)

        availabilityContinuation.yield(true)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(received == [.available(value: 1, source: .phone)])

        valuesContinuation.finish()
        availabilityContinuation.finish()
        await consumeTask.value
    }

    @Test("Combining does not emit available until first sample")
    func noAvailableUntilFirstSample() async {
        let (valuesStream, valuesContinuation) = AsyncStream.makeStream(of: Int.self)
        let (availabilityStream, availabilityContinuation) = AsyncStream.makeStream(of: Bool.self)

        let snapshots = MetricSnapshot.combining(
            values: valuesStream,
            isAvailable: availabilityStream,
            source: .bluetooth,
        )

        var received: [MetricSnapshot<Int>] = []
        let consumeTask = Task {
            for await snapshot in snapshots {
                received.append(snapshot)
            }
        }

        availabilityContinuation.yield(true)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(received.isEmpty)

        valuesContinuation.yield(5)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(received == [.available(value: 5, source: .bluetooth)])

        valuesContinuation.finish()
        availabilityContinuation.finish()
        await consumeTask.value
    }

    @Test("Combining drops values while unavailable")
    func dropsValuesWhileUnavailable() async {
        let (valuesStream, valuesContinuation) = AsyncStream.makeStream(of: Int.self)
        let (availabilityStream, availabilityContinuation) = AsyncStream.makeStream(of: Bool.self)

        let snapshots = MetricSnapshot.combining(
            values: valuesStream,
            isAvailable: availabilityStream,
            source: .phone,
        )

        var received: [MetricSnapshot<Int>] = []
        let consumeTask = Task {
            for await snapshot in snapshots {
                received.append(snapshot)
                if received.count == 2 { break }
            }
        }

        availabilityContinuation.yield(false)
        try? await Task.sleep(for: .milliseconds(50))
        valuesContinuation.yield(99)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(received == [.unavailable])

        valuesContinuation.finish()
        availabilityContinuation.finish()
        await consumeTask.value
    }

    @Test("Combining emits unavailable when availability becomes false")
    func emitsUnavailableWhenAvailabilityFalse() async {
        let (valuesStream, valuesContinuation) = AsyncStream.makeStream(of: Int.self)
        let (availabilityStream, availabilityContinuation) = AsyncStream.makeStream(of: Bool.self)

        let snapshots = MetricSnapshot.combining(
            values: valuesStream,
            isAvailable: availabilityStream,
            source: .watch,
        )

        var received: [MetricSnapshot<Int>] = []
        let consumeTask = Task {
            for await snapshot in snapshots {
                received.append(snapshot)
                if received.count == 3 { break }
            }
        }

        availabilityContinuation.yield(true)
        valuesContinuation.yield(7)
        try? await Task.sleep(for: .milliseconds(50))
        availabilityContinuation.yield(false)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(received == [
            .available(value: 7, source: .watch),
            .unavailable,
        ])

        valuesContinuation.finish()
        availabilityContinuation.finish()
        await consumeTask.value
    }

    @Test("Combining does not replay cached value when availability returns")
    func noCachedReplayOnRestore() async {
        let (valuesStream, valuesContinuation) = AsyncStream.makeStream(of: Int.self)
        let (availabilityStream, availabilityContinuation) = AsyncStream.makeStream(of: Bool.self)

        let snapshots = MetricSnapshot.combining(
            values: valuesStream,
            isAvailable: availabilityStream,
            source: .phone,
        )

        var received: [MetricSnapshot<Int>] = []
        let consumeTask = Task {
            for await snapshot in snapshots {
                received.append(snapshot)
                if received.count == 3 { break }
            }
        }

        availabilityContinuation.yield(true)
        valuesContinuation.yield(1)
        try? await Task.sleep(for: .milliseconds(50))
        availabilityContinuation.yield(false)
        try? await Task.sleep(for: .milliseconds(50))
        availabilityContinuation.yield(true)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(received == [
            .available(value: 1, source: .phone),
            .unavailable,
        ])

        valuesContinuation.yield(2)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(received == [
            .available(value: 1, source: .phone),
            .unavailable,
            .available(value: 2, source: .phone),
        ])

        valuesContinuation.finish()
        availabilityContinuation.finish()
        await consumeTask.value
    }

    @Test("Combining finishes when both upstream streams finish")
    func finishesWhenUpstreamFinishes() async {
        let (valuesStream, valuesContinuation) = AsyncStream.makeStream(of: Int.self)
        let (availabilityStream, availabilityContinuation) = AsyncStream.makeStream(of: Bool.self)

        let snapshots = MetricSnapshot.combining(
            values: valuesStream,
            isAvailable: availabilityStream,
            source: .phone,
        )

        var finished = false
        let consumeTask = Task {
            for await _ in snapshots {}
            finished = true
        }

        availabilityContinuation.yield(true)
        valuesContinuation.yield(3)
        valuesContinuation.finish()
        availabilityContinuation.finish()
        await consumeTask.value

        #expect(finished)
    }
}
