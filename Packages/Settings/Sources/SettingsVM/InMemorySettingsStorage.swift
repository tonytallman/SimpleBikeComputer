import Foundation

/// In-memory settings storage for previews and tests.
public final class InMemorySettingsStorage: SettingsStorage, @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String: Any] = [:]

    public init() {}

    public func get(forKey key: String) -> Any? {
        lock.lock()
        defer { lock.unlock() }
        return storage[key]
    }

    public func set(value: Any?, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        if let value {
            storage[key] = value
        } else {
            storage.removeValue(forKey: key)
        }
    }
}
