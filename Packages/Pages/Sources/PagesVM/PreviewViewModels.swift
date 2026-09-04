#if DEBUG
import LayoutsVM
import Observation

@Observable
@MainActor
public final class PreviewPortraitPagesViewModel: PortraitPagesViewModel {
    public let layout = PreviewPortraitSingleFieldLayoutViewModel()

    public init() {}
}

@Observable
@MainActor
public final class PreviewLandscapePagesViewModel: LandscapePagesViewModel {
    public let layout = PreviewLandscapeSingleFieldLayoutViewModel()

    public init() {}
}

@Observable
@MainActor
public final class PreviewPagesViewModel: PagesViewModel {
    public let portraitPages = PreviewPortraitPagesViewModel()
    public let landscapePages = PreviewLandscapePagesViewModel()

    public init() {}
}
#endif
