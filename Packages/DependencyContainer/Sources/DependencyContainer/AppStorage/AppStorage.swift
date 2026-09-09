import Foundation

package protocol AppStorage: Sendable {
    func get(forKey key: String) -> Any?
    func set(value: Any?, forKey key: String)
}
