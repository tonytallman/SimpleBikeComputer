import DependencyContainer
import Foundation

final class MockAppStorage: AppStorage, @unchecked Sendable {
    private var storage: [String: Any] = [:]
    private(set) var setKeys: [String] = []

    func get(forKey key: String) -> Any? {
        storage[key]
    }

    func set(value: Any?, forKey key: String) {
        setKeys.append(key)
        if let value {
            storage[key] = value
        } else {
            storage.removeValue(forKey: key)
        }
    }

    func resetSetKeys() {
        setKeys.removeAll()
    }
}
