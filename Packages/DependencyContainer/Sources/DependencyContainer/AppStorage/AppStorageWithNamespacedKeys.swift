import Foundation

final package class AppStorageWithNamespacedKeys: AppStorage, @unchecked Sendable {
    private let storage: AppStorage
    private let keyPrefix: String

    package init(storage: AppStorage, keyPrefix: String) {
        self.storage = storage
        self.keyPrefix = keyPrefix
    }

    package func get(forKey key: String) -> Any? {
        let fullKey = "\(keyPrefix).\(key)"
        return storage.get(forKey: fullKey)
    }

    package func set(value: Any?, forKey key: String) {
        let fullKey = "\(keyPrefix).\(key)"
        storage.set(value: value, forKey: fullKey)
    }
}

package extension AppStorage {
    func withNamespacedKeys(_ keyPrefix: String) -> any AppStorage {
        AppStorageWithNamespacedKeys(storage: self, keyPrefix: keyPrefix)
    }
}
