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
    private let metricsSettings: DefaultMetricsSettings
    private let systemSettings: DefaultSystemSettings
    private let keepScreenOnIdleTimer: KeepScreenOnIdleTimer
    private let coreLocationSpeedSource: CoreLocationSpeedSource
    private let speedSource: any Metrics.Metric<Measurement<UnitSpeed>>
    private let speedMetric: LayoutsModel.RuntimeMetric
    private let appStorage = UserDefaults.standard.asAppStorage()

    public init() {
        let settingsStorage = appStorage
            .withNamespacedKeys("Settings")
            .asSettingsStorage()
        metricsSettings = DefaultMetricsSettings(storage: settingsStorage)
        systemSettings = DefaultSystemSettings(storage: settingsStorage)
        keepScreenOnIdleTimer = KeepScreenOnIdleTimer(keepScreenOn: systemSettings.keepScreenOn)
        coreLocationSpeedSource = CoreLocationSpeedSource()
        speedSource = coreLocationSpeedSource.asSpeedMetric().shared()
        speedMetric = LayoutsModel.RuntimeMetric.speedMetric(
            values: speedSource.values.inUnits(metricsSettings.speedUnits),
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
            makeSettings: { [metricsSettings, systemSettings] in
                RuntimeSettingsViewModel(
                    metricsSettings: metricsSettings,
                    systemSettings: systemSettings,
                )
            },
        )
    }
}
