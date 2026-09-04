#if DEBUG
import LayoutsModel
import Observation

@Observable
@MainActor
public final class PreviewMetric: Metric {
    public let name: String
    public let value: String
    public let units: String

    public init(name: String, value: String, units: String) {
        self.name = name
        self.value = value
        self.units = units
    }
}

@Observable
@MainActor
public final class PreviewPortraitSingleFieldLayoutViewModel: PortraitSingleFieldLayoutViewModel {
    public let metric = PreviewMetric(name: "Speed", value: "20.0", units: "mph")

    public init() {}
}

@Observable
@MainActor
public final class PreviewLandscapeSingleFieldLayoutViewModel: LandscapeSingleFieldLayoutViewModel {
    public let metric = PreviewMetric(name: "Speed", value: "20.0", units: "mph")

    public init() {}
}
#endif
