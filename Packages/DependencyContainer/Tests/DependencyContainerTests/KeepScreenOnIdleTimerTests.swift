import DependencyContainer
import SettingsVM
import Testing

@MainActor
final class MockScreenController: ScreenController {
    private(set) var callCount = 0
    private(set) var lastDisabledValue: Bool?

    func setIdleTimerDisabled(_ disabled: Bool) {
        callCount += 1
        lastDisabledValue = disabled
    }

    func reset() {
        callCount = 0
        lastDisabledValue = nil
    }
}

@MainActor
@Suite("KeepScreenOnIdleTimer Tests")
struct KeepScreenOnIdleTimerTests {
    private func waitForScreenControllerUpdate(
        _ screenController: MockScreenController,
        minimumCallCount: Int = 1,
    ) async {
        for _ in 0 ..< 100 {
            if screenController.callCount >= minimumCallCount {
                return
            }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    @Test("applies idle timer for initial keepScreenOn value")
    func appliesInitialValue() async {
        let settings = DefaultSystemSettings(storage: InMemorySettingsStorage())
        let screenController = MockScreenController()
        let idleTimer = KeepScreenOnIdleTimer(
            keepScreenOn: settings.keepScreenOn,
            screenController: screenController,
        )

        await waitForScreenControllerUpdate(screenController)

        #expect(screenController.callCount >= 1)
        #expect(screenController.lastDisabledValue == true)

        _ = idleTimer
    }

    @Test("applies idle timer when keepScreenOn changes")
    func appliesOnChange() async {
        let settings = DefaultSystemSettings(storage: InMemorySettingsStorage())
        let screenController = MockScreenController()
        let idleTimer = KeepScreenOnIdleTimer(
            keepScreenOn: settings.keepScreenOn,
            screenController: screenController,
        )

        await waitForScreenControllerUpdate(screenController)
        screenController.reset()

        settings.setKeepScreenOn(false)

        await waitForScreenControllerUpdate(screenController)

        #expect(screenController.callCount >= 1)
        #expect(screenController.lastDisabledValue == false)

        _ = idleTimer
    }

    @Test("restores idle timer from persisted keepScreenOn")
    func restoresFromStorage() async {
        let storage = InMemorySettingsStorage()
        storage.set(value: false, forKey: "keepScreenOn")
        let settings = DefaultSystemSettings(storage: storage)
        let screenController = MockScreenController()
        let idleTimer = KeepScreenOnIdleTimer(
            keepScreenOn: settings.keepScreenOn,
            screenController: screenController,
        )

        await waitForScreenControllerUpdate(screenController)

        #expect(screenController.callCount >= 1)
        #expect(screenController.lastDisabledValue == false)

        _ = idleTimer
    }
}
