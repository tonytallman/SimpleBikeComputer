import Foundation
import Location
import Metrics

extension CoreLocationSpeedSource {
    func asSpeedMetric() -> any Metric<Measurement<UnitSpeed>> {
        RuntimeMetric(
            values: speed,
            isAvailable: isAvailable,
            source: .phone,
        )
    }
}
