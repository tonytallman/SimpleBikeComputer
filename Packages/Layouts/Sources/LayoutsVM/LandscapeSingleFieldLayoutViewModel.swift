import LayoutsModel
import Observation

@MainActor
public protocol LandscapeSingleFieldLayoutViewModel: AnyObject, Observable {
    associatedtype MetricType: Metric
    var metric: MetricType { get }
}
