import Foundation
import UIKit

@MainActor
package protocol ScreenController {
    func setIdleTimerDisabled(_ disabled: Bool)
}

@MainActor
package struct DefaultScreenController: ScreenController {
    package init() {}

    package func setIdleTimerDisabled(_ disabled: Bool) {
        UIApplication.shared.isIdleTimerDisabled = disabled
    }
}

@MainActor
package final class KeepScreenOnIdleTimer {
    private let observeTask: Task<Void, Never>

    package init(
        keepScreenOn: AsyncStream<Bool>,
        screenController: ScreenController = DefaultScreenController(),
    ) {
        observeTask = Task {
            for await keepOn in keepScreenOn {
                guard !Task.isCancelled else { return }
                screenController.setIdleTimerDisabled(keepOn)
            }
        }
    }

    deinit {
        observeTask.cancel()
    }
}
