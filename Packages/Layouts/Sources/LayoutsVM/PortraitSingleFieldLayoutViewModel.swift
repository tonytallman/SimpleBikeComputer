import LayoutsModel
import Observation

@MainActor
public protocol PortraitSingleFieldLayoutViewModel: AnyObject, Observable {
    associatedtype MetricType: Metric
    var metric: MetricType { get }
}
