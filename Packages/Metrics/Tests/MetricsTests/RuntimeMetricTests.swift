import Foundation
import Metrics
import Testing

@MainActor
struct RuntimeMetricTests {
    @Test
    func vendsGivenSnapshotStream() async {
        let (snapshotsStream, snapshotsContinuation) = AsyncStream.makeStream(
            of: MetricSnapshot<Int>.self,
        )
        let metric = RuntimeMetric(snapshots: snapshotsStream)

        snapshotsContinuation.yield(.available(value: 42, source: .bluetooth))

        var snapshots: [MetricSnapshot<Int>] = []
        let snapshotsTask = Task {
            for await snapshot in metric.snapshots {
                snapshots.append(snapshot)
                if snapshots.count == 1 { break }
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        #expect(snapshots == [.available(value: 42, source: .bluetooth)])

        snapshotsContinuation.finish()
        await snapshotsTask.value
    }
}
