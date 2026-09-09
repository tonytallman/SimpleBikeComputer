import Observation

@MainActor
public protocol SettingsViewModel: AnyObject, Observable {
    associatedtype Units: UnitSettingsViewModel
    associatedtype System: SystemSettingsViewModel
    var units: Units { get }
    var system: System { get }
}
