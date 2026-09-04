import Foundation
import LayoutsModel
import LayoutsVM
import PagesVM
import Testing

@MainActor
struct PortraitPagesViewModelTests {
    @Test
    func exposesGivenLayout() async {
        let (stream, continuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let metric = RuntimeMetric(name: "Speed", values: stream)
        let layout = RuntimePortraitSingleFieldLayoutViewModel(metric: metric)
        let viewModel = RuntimePortraitPagesViewModel(layout: layout)

        continuation.yield(Measurement(value: 20, unit: .milesPerHour))

        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.layout === layout)
        #expect(viewModel.layout.metric === metric)

        continuation.finish()
    }
}

@MainActor
struct LandscapePagesViewModelTests {
    @Test
    func exposesGivenLayout() async {
        let (stream, continuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let metric = RuntimeMetric(name: "Speed", values: stream)
        let layout = RuntimeLandscapeSingleFieldLayoutViewModel(metric: metric)
        let viewModel = RuntimeLandscapePagesViewModel(layout: layout)

        continuation.yield(Measurement(value: 20, unit: .milesPerHour))

        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.layout === layout)
        #expect(viewModel.layout.metric === metric)

        continuation.finish()
    }
}

@MainActor
struct PagesViewModelTests {
    @Test
    func exposesPortraitAndLandscapeChildren() async {
        let (stream, continuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let metric = RuntimeMetric(name: "Speed", values: stream)
        let portraitPages = RuntimePortraitPagesViewModel(
            layout: RuntimePortraitSingleFieldLayoutViewModel(metric: metric),
        )
        let landscapePages = RuntimeLandscapePagesViewModel(
            layout: RuntimeLandscapeSingleFieldLayoutViewModel(metric: metric),
        )
        let viewModel = RuntimePagesViewModel(
            portraitPages: portraitPages,
            landscapePages: landscapePages,
        )

        continuation.yield(Measurement(value: 20, unit: .milesPerHour))

        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.portraitPages === portraitPages)
        #expect(viewModel.landscapePages === landscapePages)

        continuation.finish()
    }
}
