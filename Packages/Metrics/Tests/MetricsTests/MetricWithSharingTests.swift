import Foundation
import Metrics
import Testing

@MainActor
struct MetricWithSharingTests {
    @Test
    func multipleSubscribersReceiveYields() async {
        let (valuesStream, valuesContinuation) = AsyncStream.makeStream(of: Int.self)
        let metric = RuntimeMetric(
            values: valuesStream,
            isAvailable: AsyncStream { $0.finish() },
            source: MetricSource.phone,
        ).shared()

        var firstValues: [Int] = []
        var secondValues: [Int] = []

        let firstTask = Task {
            for await value in metric.values {
                firstValues.append(value)
                if firstValues.count == 2 { break }
            }
        }
        let secondTask = Task {
            for await value in metric.values {
                secondValues.append(value)
                if secondValues.count == 2 { break }
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        valuesContinuation.yield(1)
        try? await Task.sleep(for: .milliseconds(50))
        valuesContinuation.yield(2)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(firstValues == [1, 2])
        #expect(secondValues == [1, 2])

        valuesContinuation.finish()
        await firstTask.value
        await secondTask.value
    }

    @Test
    func lateSubscriberReceivesLatestValue() async {
        let (valuesStream, valuesContinuation) = AsyncStream.makeStream(of: Int.self)
        let metric = RuntimeMetric(
            values: valuesStream,
            isAvailable: AsyncStream { $0.finish() },
            source: MetricSource.watch,
        ).shared()

        valuesContinuation.yield(10)
        try? await Task.sleep(for: .milliseconds(50))

        var lateValues: [Int] = []
        let lateTask = Task {
            for await value in metric.values {
                lateValues.append(value)
                break
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        #expect(lateValues == [10])

        valuesContinuation.finish()
        await lateTask.value
    }

    @Test
    func finishIsObservedByAllSubscribers() async {
        let (valuesStream, valuesContinuation) = AsyncStream.makeStream(of: Int.self)
        let metric = RuntimeMetric(
            values: valuesStream,
            isAvailable: AsyncStream { $0.finish() },
            source: MetricSource.phone,
        ).shared()

        var firstFinished = false
        var secondFinished = false

        let firstTask = Task {
            for await _ in metric.values {}
            firstFinished = true
        }
        let secondTask = Task {
            for await _ in metric.values {}
            secondFinished = true
        }

        try? await Task.sleep(for: .milliseconds(50))
        valuesContinuation.finish()
        try? await Task.sleep(for: .milliseconds(50))

        #expect(firstFinished)
        #expect(secondFinished)

        await firstTask.value
        await secondTask.value
    }

    @Test
    func forwardsSource() {
        let metric = RuntimeMetric<Int>(
            values: AsyncStream { $0.finish() },
            isAvailable: AsyncStream { $0.finish() },
            source: MetricSource.bluetooth,
        ).shared()

        #expect(metric.source == .bluetooth)
    }

    @Test
    func sharesAvailabilityStream() async {
        let (availabilityStream, availabilityContinuation) = AsyncStream.makeStream(of: Bool.self)
        let metric = RuntimeMetric<Int>(
            values: AsyncStream { $0.finish() },
            isAvailable: availabilityStream,
            source: MetricSource.phone,
        ).shared()

        var firstAvailability: [Bool] = []
        var secondAvailability: [Bool] = []

        let firstTask = Task {
            for await isAvailable in metric.isAvailable {
                firstAvailability.append(isAvailable)
                if firstAvailability.count == 1 { break }
            }
        }
        let secondTask = Task {
            for await isAvailable in metric.isAvailable {
                secondAvailability.append(isAvailable)
                if secondAvailability.count == 1 { break }
            }
        }

        try? await Task.sleep(for: .milliseconds(50))
        availabilityContinuation.yield(false)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(firstAvailability == [false])
        #expect(secondAvailability == [false])

        availabilityContinuation.finish()
        await firstTask.value
        await secondTask.value
    }
}
