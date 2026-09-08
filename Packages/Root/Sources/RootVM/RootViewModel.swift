import Observation
import PagesVM
import SettingsVM

@MainActor
public protocol RootViewModel: AnyObject, Observable {
    associatedtype Pages: PagesViewModel
    associatedtype Settings: SettingsViewModel
    var pages: Pages { get }
    func makeSettings() -> Settings
    var isSettingsPresented: Bool { get set }
}
