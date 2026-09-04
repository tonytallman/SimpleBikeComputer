import LayoutsModel
import Observation

@Observable
@MainActor
public final class RuntimePortraitSingleFieldLayoutViewModel: PortraitSingleFieldLayoutViewModel {
    public let metric: RuntimeMetric

    public init(metric: RuntimeMetric) {
        self.metric = metric
    }
}
