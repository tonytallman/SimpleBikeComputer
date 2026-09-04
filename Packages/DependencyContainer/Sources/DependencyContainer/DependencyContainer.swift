import Foundation
import LayoutsModel
import LayoutsVM

public struct RootViewModel {
    public let portraitSingleFieldLayoutViewModel: RuntimePortraitSingleFieldLayoutViewModel
    public let landscapeSingleFieldLayoutViewModel: RuntimeLandscapeSingleFieldLayoutViewModel
}

@MainActor
public final class DependencyContainer {
    private let speedMetric: RuntimeMetric

    public init() {
        speedMetric = Self.makeSpeedMetric()
    }

    public func makeRootViewModel() -> RootViewModel {
        RootViewModel(
            portraitSingleFieldLayoutViewModel: RuntimePortraitSingleFieldLayoutViewModel(
                metric: speedMetric,
            ),
            landscapeSingleFieldLayoutViewModel: RuntimeLandscapeSingleFieldLayoutViewModel(
                metric: speedMetric,
            ),
        )
    }

    private static func makeSpeedMetric() -> RuntimeMetric {
        let stream = AsyncStream<Measurement<UnitSpeed>> { continuation in
            continuation.yield(Measurement(value: 20, unit: .milesPerHour))
        }
        return RuntimeMetric(name: "Speed", values: stream)
    }
}
