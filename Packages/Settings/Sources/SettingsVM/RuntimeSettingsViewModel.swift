import Observation

@Observable
@MainActor
public final class RuntimeSettingsViewModel: SettingsViewModel {
    public let units: RuntimeUnitSettingsViewModel

    public init(metricsSettings: MetricsSettings) {
        units = RuntimeUnitSettingsViewModel(metricsSettings: metricsSettings)
    }
}
