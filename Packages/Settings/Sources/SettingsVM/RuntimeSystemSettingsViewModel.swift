import Foundation
import Observation

@MainActor
public protocol SystemSettingsViewModel: AnyObject, Observable {
    var keepScreenOn: Bool { get }
    func setKeepScreenOn(_ keepOn: Bool)
}

@Observable
@MainActor
public final class RuntimeSystemSettingsViewModel: SystemSettingsViewModel {
    public var keepScreenOn = true

    @ObservationIgnored
    private let systemSettings: SystemSettings

    @ObservationIgnored
    private var keepScreenOnObserveTask: Task<Void, Never>?

    public init(systemSettings: SystemSettings) {
        self.systemSettings = systemSettings
        let keepScreenOnStream = systemSettings.keepScreenOn
        keepScreenOnObserveTask = Task { @MainActor [weak self] in
            for await keepOn in keepScreenOnStream {
                guard !Task.isCancelled else { return }
                self?.keepScreenOn = keepOn
            }
        }
    }

    deinit {
        keepScreenOnObserveTask?.cancel()
    }

    public func setKeepScreenOn(_ keepOn: Bool) {
        systemSettings.setKeepScreenOn(keepOn)
    }
}
