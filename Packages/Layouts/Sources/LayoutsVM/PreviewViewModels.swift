#if DEBUG
import LayoutsModel
import Observation

@Observable
@MainActor
package final class PreviewMetric: Metric {
    package let name: String
    package let value: String
    package let units: String

    package init(name: String, value: String, units: String) {
        self.name = name
        self.value = value
        self.units = units
    }
}

@Observable
@MainActor
package final class PreviewPortraitSingleFieldLayoutViewModel: PortraitSingleFieldLayoutViewModel {
    package let metric = PreviewMetric(name: "Speed", value: "20.0", units: "mph")

    package init() {}
}

@Observable
@MainActor
package final class PreviewLandscapeSingleFieldLayoutViewModel: LandscapeSingleFieldLayoutViewModel {
    package let metric = PreviewMetric(name: "Speed", value: "20.0", units: "mph")

    package init() {}
}
#endif
