import Foundation
import LayoutsModel
import Testing

@MainActor
struct RuntimeMetricTests {
    @Test
    func initialPlaceholderValues() {
        let (stream, _) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let metric = RuntimeMetric(name: "Speed", values: stream)

        #expect(metric.name == "Speed")
        #expect(metric.value == "--")
        #expect(metric.units == "")
    }

    @Test
    func updatesFromStream() async {
        let (stream, continuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let metric = RuntimeMetric(name: "Speed", values: stream)

        continuation.yield(Measurement(value: 20, unit: .milesPerHour))

        try? await Task.sleep(for: .milliseconds(50))

        #expect(metric.name == "Speed")
        #expect(metric.value == "20")
        #expect(metric.units == "mph")

        continuation.finish()
    }

    @Test
    func formatsFractionalValues() async {
        let (stream, continuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let metric = RuntimeMetric(name: "Speed", values: stream)

        continuation.yield(Measurement(value: 25.5, unit: .milesPerHour))

        try? await Task.sleep(for: .milliseconds(50))

        #expect(metric.value == "25.5")
        #expect(metric.units == "mph")

        continuation.finish()
    }
}
