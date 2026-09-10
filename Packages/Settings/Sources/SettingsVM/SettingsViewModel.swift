import Observation

@MainActor
public protocol SettingsViewModel: AnyObject, Observable {
    associatedtype Units: UnitSettingsViewModel
    associatedtype Autopause: AutopauseSettingsViewModel
    associatedtype System: SystemSettingsViewModel
    var units: Units { get }
    var autopause: Autopause { get }
    var system: System { get }
}
