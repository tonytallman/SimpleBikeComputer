import Foundation
import Observation

@MainActor
public protocol Metric: AnyObject, Observable {
    var name: String { get }
    var value: String { get }
    var units: String { get }
}
