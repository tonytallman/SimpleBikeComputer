import LayoutsModel
import Observation

@Observable
@MainActor
public final class RuntimeLandscapeSingleFieldLayoutViewModel: LandscapeSingleFieldLayoutViewModel {
    public let metric: RuntimeMetric

    public init(metric: RuntimeMetric) {
        self.metric = metric
    }
}
