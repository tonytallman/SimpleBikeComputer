import Observation

@MainActor
public protocol SettingsViewModel: AnyObject, Observable {
    associatedtype Units: UnitSettingsViewModel
    var units: Units { get }
}
