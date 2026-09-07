import Foundation
import Metrics
import Testing

@MainActor
struct RuntimeMetricTests {
    @Test
    func vendsGivenStreamsAndSource() async {
        let (valuesStream, valuesContinuation) = AsyncStream.makeStream(of: Int.self)
        let (availabilityStream, availabilityContinuation) = AsyncStream.makeStream(of: Bool.self)
        let metric = RuntimeMetric(
            values: valuesStream,
            isAvailable: availabilityStream,
            source: MetricSource.bluetooth,
        )

        #expect(metric.source == .bluetooth)

        valuesContinuation.yield(42)
        availabilityContinuation.yield(true)

        var values: [Int] = []
        var availability: [Bool] = []

        let valuesTask = Task {
            for await value in metric.values {
                values.append(value)
                if values.count == 1 { break }
            }
        }
        let availabilityTask = Task {
            for await isAvailable in metric.isAvailable {
                availability.append(isAvailable)
                if availability.count == 1 { break }
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        #expect(values == [42])
        #expect(availability == [true])

        valuesContinuation.finish()
        availabilityContinuation.finish()
        await valuesTask.value
        await availabilityTask.value
    }
}
