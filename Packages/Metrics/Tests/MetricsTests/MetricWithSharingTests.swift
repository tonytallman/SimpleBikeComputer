import Foundation
import Metrics
import Testing

@MainActor
struct MetricWithSharingTests {
    @Test
    func multipleSubscribersReceiveYields() async {
        let (snapshotsStream, snapshotsContinuation) = AsyncStream.makeStream(
            of: MetricSnapshot<Int>.self,
        )
        let metric = RuntimeMetric(snapshots: snapshotsStream).shared()

        var firstSnapshots: [MetricSnapshot<Int>] = []
        var secondSnapshots: [MetricSnapshot<Int>] = []

        let firstTask = Task {
            for await snapshot in metric.snapshots {
                firstSnapshots.append(snapshot)
                if firstSnapshots.count == 2 { break }
            }
        }
        let secondTask = Task {
            for await snapshot in metric.snapshots {
                secondSnapshots.append(snapshot)
                if secondSnapshots.count == 2 { break }
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        snapshotsContinuation.yield(.available(value: 1, source: .phone))
        try? await Task.sleep(for: .milliseconds(50))
        snapshotsContinuation.yield(.available(value: 2, source: .phone))
        try? await Task.sleep(for: .milliseconds(50))

        #expect(firstSnapshots == [
            .available(value: 1, source: .phone),
            .available(value: 2, source: .phone),
        ])
        #expect(secondSnapshots == [
            .available(value: 1, source: .phone),
            .available(value: 2, source: .phone),
        ])

        snapshotsContinuation.finish()
        await firstTask.value
        await secondTask.value
    }

    @Test
    func lateSubscriberReceivesLatestSnapshot() async {
        let (snapshotsStream, snapshotsContinuation) = AsyncStream.makeStream(
            of: MetricSnapshot<Int>.self,
        )
        let metric = RuntimeMetric(snapshots: snapshotsStream).shared()

        snapshotsContinuation.yield(.available(value: 10, source: .watch))
        try? await Task.sleep(for: .milliseconds(50))

        var lateSnapshots: [MetricSnapshot<Int>] = []
        let lateTask = Task {
            for await snapshot in metric.snapshots {
                lateSnapshots.append(snapshot)
                break
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        #expect(lateSnapshots == [.available(value: 10, source: .watch)])

        snapshotsContinuation.finish()
        await lateTask.value
    }

    @Test
    func finishIsObservedByAllSubscribers() async {
        let (snapshotsStream, snapshotsContinuation) = AsyncStream.makeStream(
            of: MetricSnapshot<Int>.self,
        )
        let metric = RuntimeMetric(snapshots: snapshotsStream).shared()

        var firstFinished = false
        var secondFinished = false

        let firstTask = Task {
            for await _ in metric.snapshots {}
            firstFinished = true
        }
        let secondTask = Task {
            for await _ in metric.snapshots {}
            secondFinished = true
        }

        try? await Task.sleep(for: .milliseconds(50))
        snapshotsContinuation.finish()
        try? await Task.sleep(for: .milliseconds(50))

        #expect(firstFinished)
        #expect(secondFinished)

        await firstTask.value
        await secondTask.value
    }

    @Test
    func sharesUnavailableSnapshots() async {
        let (snapshotsStream, snapshotsContinuation) = AsyncStream.makeStream(
            of: MetricSnapshot<Int>.self,
        )
        let metric = RuntimeMetric(snapshots: snapshotsStream).shared()

        var firstSnapshots: [MetricSnapshot<Int>] = []
        var secondSnapshots: [MetricSnapshot<Int>] = []

        let firstTask = Task {
            for await snapshot in metric.snapshots {
                firstSnapshots.append(snapshot)
                if firstSnapshots.count == 1 { break }
            }
        }
        let secondTask = Task {
            for await snapshot in metric.snapshots {
                secondSnapshots.append(snapshot)
                if secondSnapshots.count == 1 { break }
            }
        }

        try? await Task.sleep(for: .milliseconds(50))
        snapshotsContinuation.yield(.unavailable)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(firstSnapshots == [.unavailable])
        #expect(secondSnapshots == [.unavailable])

        snapshotsContinuation.finish()
        await firstTask.value
        await secondTask.value
    }
}
