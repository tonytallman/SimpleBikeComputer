import Foundation
import LayoutsModel
import LayoutsVM
import Metrics
import PagesVM
import RootVM

@MainActor
public final class DependencyContainer {
    private let speedSource: any Metrics.Metric<Measurement<UnitSpeed>>
    private let speedMetric: LayoutsModel.RuntimeMetric

    public init() {
        speedSource = Self.makeSpeedSource()
        speedMetric = LayoutsModel.RuntimeMetric.speedMetric(
            values: speedSource.values,
        )
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

    private static func makeSpeedSource() -> any Metrics.Metric<Measurement<UnitSpeed>> {
        let values = AsyncStream<Measurement<UnitSpeed>> { continuation in
            continuation.yield(Measurement(value: 20, unit: .milesPerHour))
        }
        let isAvailable = AsyncStream<Bool> { continuation in
            continuation.yield(true)
        }
        return Metrics.RuntimeMetric(
            values: values,
            isAvailable: isAvailable,
            source: .phone,
        ).shared()
    }
}
