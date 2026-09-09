import SettingsVM

extension AnyAppStorage: SettingsStorage { }

package extension AppStorage {
    func asSettingsStorage() -> any SettingsStorage {
        AnyAppStorage(self)
    }
}
