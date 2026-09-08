#if DEBUG
import Observation
import PagesVM
import SettingsVM

@Observable
@MainActor
public final class PreviewRootViewModel: RootViewModel {
    public let pages = PreviewPagesViewModel()
    public var isSettingsPresented = false

    public init() {}

    public func makeSettings() -> PreviewSettingsViewModel {
        PreviewSettingsViewModel()
    }
}
#endif
