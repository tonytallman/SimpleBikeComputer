import Foundation

public protocol SettingsStorage: Sendable {
    func get(forKey key: String) -> Any?
    func set(value: Any?, forKey key: String)
}
