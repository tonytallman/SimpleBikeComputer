import Foundation

import SettingsVM

final package class AnyAppStorage: AppStorage, @unchecked Sendable {
    private let appStorage: AppStorage

    package init(_ appStorage: AppStorage) {
        self.appStorage = appStorage
    }

    package func get(forKey key: String) -> Any? {
        appStorage.get(forKey: key)
    }

    package func set(value: Any?, forKey key: String) {
        appStorage.set(value: value, forKey: key)
    }
}
