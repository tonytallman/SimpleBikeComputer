import Foundation
import LayoutsModel
import LayoutsVM
import Location
import Metrics
import PagesVM
import RootVM
import SettingsVM

@MainActor
public final class DependencyContainer {
    private let coreLocationSpeedSource: CoreLocationSpeedSource
    private let speedSource: any Metrics.Metric<Measurement<UnitSpeed>>
    private let speedMetric: LayoutsModel.RuntimeMetric

    public init() {
        coreLocationSpeedSource = CoreLocationSpeedSource()
        speedSource = coreLocationSpeedSource.asSpeedMetric().shared()
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
            makeSettings: { RuntimeSettingsViewModel() },
        )
    }
}
