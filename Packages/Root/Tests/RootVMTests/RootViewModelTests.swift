import LayoutsModel
import LayoutsVM
import PagesVM
import RootVM
import SettingsVM
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
        let viewModel = RuntimeRootViewModel(
            pages: pages,
            makeSettings: { RuntimeSettingsViewModel() },
        )

        #expect(viewModel.pages === pages)
    }

    @Test
    func makeSettingsUsesFactoryAndIsNotCalledAtInit() {
        var factoryCallCount = 0
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
        let viewModel = RuntimeRootViewModel(
            pages: pages,
            makeSettings: {
                factoryCallCount += 1
                return RuntimeSettingsViewModel()
            },
        )

        #expect(factoryCallCount == 0)

        let settings = viewModel.makeSettings()

        #expect(factoryCallCount == 1)
        #expect(settings is RuntimeSettingsViewModel)
    }

    @Test
    func settingsPresentationDefaultsToFalseAndCanBePresented() {
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
        let viewModel = RuntimeRootViewModel(
            pages: pages,
            makeSettings: { RuntimeSettingsViewModel() },
        )

        #expect(viewModel.isSettingsPresented == false)

        viewModel.isSettingsPresented = true

        #expect(viewModel.isSettingsPresented == true)
    }
}
