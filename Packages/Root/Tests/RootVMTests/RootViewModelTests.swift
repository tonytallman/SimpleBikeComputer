import LayoutsModel
import LayoutsVM
import PagesVM
import RootVM
import Testing

@MainActor
struct RootViewModelTests {
    @Test
    func exposesGivenPagesViewModel() {
        let pages = RuntimePagesViewModel(
            portraitPages: RuntimePortraitPagesViewModel(
                layout: RuntimePortraitSingleFieldLayoutViewModel(
                    metric: RuntimeMetric(
                        name: "Speed",
                        values: AsyncStream { $0.finish() },
                    ),
                ),
            ),
            landscapePages: RuntimeLandscapePagesViewModel(
                layout: RuntimeLandscapeSingleFieldLayoutViewModel(
                    metric: RuntimeMetric(
                        name: "Speed",
                        values: AsyncStream { $0.finish() },
                    ),
                ),
            ),
        )
        let viewModel = RuntimeRootViewModel(pages: pages)

        #expect(viewModel.pages === pages)
    }
}
