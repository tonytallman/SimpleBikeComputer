import CoreLocation
import SettingsVM
import SwiftUI
import Testing

@Suite("Location permission status mapping")
struct LocationPermissionStatusMappingTests {
    @Test("authorizedAlways maps to Always")
    func authorizedAlways() {
        #expect(locationPermissionStatusText(for: .authorizedAlways) == "Always")
    }

    @Test("authorizedWhenInUse maps to While Using")
    func authorizedWhenInUse() {
        #expect(locationPermissionStatusText(for: .authorizedWhenInUse) == "While Using")
    }

    @Test("denied maps to Denied")
    func denied() {
        #expect(locationPermissionStatusText(for: .denied) == "Denied")
    }

    @Test("restricted maps to Restricted")
    func restricted() {
        #expect(locationPermissionStatusText(for: .restricted) == "Restricted")
    }

    @Test("notDetermined maps to Not Determined")
    func notDetermined() {
        #expect(locationPermissionStatusText(for: .notDetermined) == "Not Determined")
    }
}

@MainActor
private final class MockLocationPermissionsSettings: LocationPermissionsSettings {
    var locationPermissionStatus = "Always"
}

@MainActor
private final class MockSystemSettingsNavigator: SystemSettingsNavigator {
    private(set) var openAppPermissionsCallCount = 0

    func openAppPermissions() {
        openAppPermissionsCallCount += 1
    }
}

@MainActor
@Suite("RuntimeSystemSettingsViewModel location permission")
struct RuntimeSystemSettingsViewModelLocationPermissionTests {
    @Test("viewAppeared copies status from permissions settings")
    func viewAppeared() async {
        let mockPermissions = MockLocationPermissionsSettings()
        mockPermissions.locationPermissionStatus = "While Using"
        let viewModel = RuntimeSystemSettingsViewModel(
            systemSettings: DefaultSystemSettings(storage: InMemorySettingsStorage()),
            locationPermissionsSettings: mockPermissions,
            systemSettingsNavigator: MockSystemSettingsNavigator(),
        )

        try? await Task.sleep(for: .milliseconds(50))

        mockPermissions.locationPermissionStatus = "Denied"
        viewModel.viewAppeared()

        #expect(viewModel.locationPermissionStatusText == "Denied")
    }

    @Test("scenePhaseChanged to active copies status from permissions settings")
    func scenePhaseChangedToActive() async {
        let mockPermissions = MockLocationPermissionsSettings()
        mockPermissions.locationPermissionStatus = "While Using"
        let viewModel = RuntimeSystemSettingsViewModel(
            systemSettings: DefaultSystemSettings(storage: InMemorySettingsStorage()),
            locationPermissionsSettings: mockPermissions,
            systemSettingsNavigator: MockSystemSettingsNavigator(),
        )

        try? await Task.sleep(for: .milliseconds(50))

        mockPermissions.locationPermissionStatus = "Always"
        viewModel.scenePhaseChanged(to: .active)

        #expect(viewModel.locationPermissionStatusText == "Always")
    }

    @Test("scenePhaseChanged to inactive does not refresh status")
    func scenePhaseChangedToInactive() async {
        let mockPermissions = MockLocationPermissionsSettings()
        mockPermissions.locationPermissionStatus = "While Using"
        let viewModel = RuntimeSystemSettingsViewModel(
            systemSettings: DefaultSystemSettings(storage: InMemorySettingsStorage()),
            locationPermissionsSettings: mockPermissions,
            systemSettingsNavigator: MockSystemSettingsNavigator(),
        )

        try? await Task.sleep(for: .milliseconds(50))

        mockPermissions.locationPermissionStatus = "Denied"
        viewModel.scenePhaseChanged(to: .inactive)

        #expect(viewModel.locationPermissionStatusText == "While Using")
    }

    @Test("scenePhaseChanged to background does not refresh status")
    func scenePhaseChangedToBackground() async {
        let mockPermissions = MockLocationPermissionsSettings()
        mockPermissions.locationPermissionStatus = "While Using"
        let viewModel = RuntimeSystemSettingsViewModel(
            systemSettings: DefaultSystemSettings(storage: InMemorySettingsStorage()),
            locationPermissionsSettings: mockPermissions,
            systemSettingsNavigator: MockSystemSettingsNavigator(),
        )

        try? await Task.sleep(for: .milliseconds(50))

        mockPermissions.locationPermissionStatus = "Denied"
        viewModel.scenePhaseChanged(to: .background)

        #expect(viewModel.locationPermissionStatusText == "While Using")
    }

    @Test("openLocationPermissions delegates to navigator")
    func openLocationPermissions() {
        let navigator = MockSystemSettingsNavigator()
        let viewModel = RuntimeSystemSettingsViewModel(
            systemSettings: DefaultSystemSettings(storage: InMemorySettingsStorage()),
            locationPermissionsSettings: MockLocationPermissionsSettings(),
            systemSettingsNavigator: navigator,
        )

        viewModel.openLocationPermissions()

        #expect(navigator.openAppPermissionsCallCount == 1)
    }
}
