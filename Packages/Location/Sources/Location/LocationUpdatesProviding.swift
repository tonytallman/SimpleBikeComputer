import Foundation

package protocol LocationUpdatesProviding: Sendable {
    associatedtype Updates: AsyncSequence & Sendable where Updates.Element == LocationUpdateSnapshot

    var updates: Updates { get }
}
