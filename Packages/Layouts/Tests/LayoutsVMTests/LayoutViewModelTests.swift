import Foundation
import LayoutsModel
import LayoutsVM
import Testing

@MainActor
struct PortraitSingleFieldLayoutViewModelTests {
    @Test
    func exposesGivenMetric() async {
        let (stream, continuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let metric = RuntimeMetric(name: "Speed", values: stream)
        let viewModel = RuntimePortraitSingleFieldLayoutViewModel(metric: metric)

        continuation.yield(Measurement(value: 20, unit: .milesPerHour))

        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.metric === metric)
        #expect(viewModel.metric.name == "Speed")
        #expect(viewModel.metric.value == "20")

        continuation.finish()
    }
}

@MainActor
struct LandscapeSingleFieldLayoutViewModelTests {
    @Test
    func exposesGivenMetric() async {
        let (stream, continuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let metric = RuntimeMetric(name: "Speed", values: stream)
        let viewModel = RuntimeLandscapeSingleFieldLayoutViewModel(metric: metric)

        continuation.yield(Measurement(value: 20, unit: .milesPerHour))

        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.metric === metric)
        #expect(viewModel.metric.name == "Speed")
        #expect(viewModel.metric.value == "20")

        continuation.finish()
    }
}
