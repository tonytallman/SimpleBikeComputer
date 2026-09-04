import Observation
import PagesVM

@Observable
@MainActor
public final class RuntimeRootViewModel: RootViewModel {
    public let pages: RuntimePagesViewModel

    public init(pages: RuntimePagesViewModel) {
        self.pages = pages
    }
}
