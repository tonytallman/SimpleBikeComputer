import Observation
import PagesVM
import SettingsVM

@Observable
@MainActor
public final class RuntimeRootViewModel: RootViewModel {
    public let pages: RuntimePagesViewModel
    public var isSettingsPresented = false

    private let settingsFactory: () -> RuntimeSettingsViewModel

    public init(
        pages: RuntimePagesViewModel,
        makeSettings: @escaping () -> RuntimeSettingsViewModel,
    ) {
        self.pages = pages
        self.settingsFactory = makeSettings
    }

    public func makeSettings() -> RuntimeSettingsViewModel {
        settingsFactory()
    }
}
