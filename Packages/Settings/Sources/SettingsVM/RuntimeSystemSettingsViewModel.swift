import Foundation
import Observation
import SwiftUI

@MainActor
public protocol SystemSettingsViewModel: AnyObject, Observable {
    var keepScreenOn: Bool { get }
    var locationPermissionStatusText: String { get }
    func setKeepScreenOn(_ keepOn: Bool)
    func viewAppeared()
    func scenePhaseChanged(to phase: ScenePhase)
    func openLocationPermissions()
}

@Observable
@MainActor
public final class RuntimeSystemSettingsViewModel: SystemSettingsViewModel {
    public var keepScreenOn = true
    public var locationPermissionStatusText = ""

    @ObservationIgnored
    private let systemSettings: SystemSettings

    @ObservationIgnored
    private let locationPermissionsSettings: LocationPermissionsSettings

    @ObservationIgnored
    private let systemSettingsNavigator: SystemSettingsNavigator

    @ObservationIgnored
    private var keepScreenOnObserveTask: Task<Void, Never>?

    public convenience init(systemSettings: SystemSettings) {
        self.init(
            systemSettings: systemSettings,
            locationPermissionsSettings: DefaultLocationPermissionsSettings(),
            systemSettingsNavigator: DefaultSystemSettingsNavigator(),
        )
    }

    package init(
        systemSettings: SystemSettings,
        locationPermissionsSettings: LocationPermissionsSettings,
        systemSettingsNavigator: SystemSettingsNavigator,
    ) {
        self.systemSettings = systemSettings
        self.locationPermissionsSettings = locationPermissionsSettings
        self.systemSettingsNavigator = systemSettingsNavigator
        let keepScreenOnStream = systemSettings.keepScreenOn
        keepScreenOnObserveTask = Task { @MainActor [weak self] in
            for await keepOn in keepScreenOnStream {
                guard !Task.isCancelled else { return }
                self?.keepScreenOn = keepOn
            }
        }
        refreshLocationStatus()
    }

    deinit {
        keepScreenOnObserveTask?.cancel()
    }

    public func setKeepScreenOn(_ keepOn: Bool) {
        systemSettings.setKeepScreenOn(keepOn)
    }

    public func viewAppeared() {
        refreshLocationStatus()
    }

    public func scenePhaseChanged(to phase: ScenePhase) {
        if phase == .active {
            refreshLocationStatus()
        }
    }

    public func openLocationPermissions() {
        systemSettingsNavigator.openAppPermissions()
    }

    private func refreshLocationStatus() {
        locationPermissionStatusText = locationPermissionsSettings.locationPermissionStatus
    }
}
