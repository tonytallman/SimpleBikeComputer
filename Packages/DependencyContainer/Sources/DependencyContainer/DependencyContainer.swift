import Foundation
import LayoutsModel
import LayoutsVM
import PagesVM
import RootVM

@MainActor
public final class DependencyContainer {
    private let speedMetric: RuntimeMetric

    public init() {
        speedMetric = Self.makeSpeedMetric()
    }

    public func makeRootViewModel() -> RuntimeRootViewModel {
        RuntimeRootViewModel(
            pages: RuntimePagesViewModel(
                portraitPages: RuntimePortraitPagesViewModel(
                    layout: RuntimePortraitSingleFieldLayoutViewModel(
                        metric: speedMetric,
                    ),
                ),
                landscapePages: RuntimeLandscapePagesViewModel(
                    layout: RuntimeLandscapeSingleFieldLayoutViewModel(
                        metric: speedMetric,
                    ),
                ),
            ),
        )
    }

    private static func makeSpeedMetric() -> RuntimeMetric {
        let stream = AsyncStream<Measurement<UnitSpeed>> { continuation in
            continuation.yield(Measurement(value: 20, unit: .milesPerHour))
        }
        return RuntimeMetric(name: "Speed", values: stream)
    }
}
