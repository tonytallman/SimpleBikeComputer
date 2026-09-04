#if DEBUG
import Observation
import PagesVM

@Observable
@MainActor
public final class PreviewRootViewModel: RootViewModel {
    public let pages = PreviewPagesViewModel()

    public init() {}
}
#endif
