import Observation

@Observable
@MainActor
public final class RuntimeSettingsViewModel: SettingsViewModel {
    public let units: RuntimeUnitSettingsViewModel
    public let system: RuntimeSystemSettingsViewModel

    public init(
        metricsSettings: MetricsSettings,
        systemSettings: SystemSettings,
    ) {
        units = RuntimeUnitSettingsViewModel(metricsSettings: metricsSettings)
        system = RuntimeSystemSettingsViewModel(systemSettings: systemSettings)
    }
}
