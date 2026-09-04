import LayoutsVM
import Observation

@Observable
@MainActor
public final class RuntimePortraitPagesViewModel: PortraitPagesViewModel {
    public let layout: RuntimePortraitSingleFieldLayoutViewModel

    public init(layout: RuntimePortraitSingleFieldLayoutViewModel) {
        self.layout = layout
    }
}

@Observable
@MainActor
public final class RuntimeLandscapePagesViewModel: LandscapePagesViewModel {
    public let layout: RuntimeLandscapeSingleFieldLayoutViewModel

    public init(layout: RuntimeLandscapeSingleFieldLayoutViewModel) {
        self.layout = layout
    }
}

@Observable
@MainActor
public final class RuntimePagesViewModel: PagesViewModel {
    public let portraitPages: RuntimePortraitPagesViewModel
    public let landscapePages: RuntimeLandscapePagesViewModel

    public init(
        portraitPages: RuntimePortraitPagesViewModel,
        landscapePages: RuntimeLandscapePagesViewModel,
    ) {
        self.portraitPages = portraitPages
        self.landscapePages = landscapePages
    }
}
