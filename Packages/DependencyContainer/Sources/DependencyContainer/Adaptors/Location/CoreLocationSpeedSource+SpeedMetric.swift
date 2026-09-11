import Foundation
import Location
import Metrics

extension CoreLocationSpeedSource {
    func asSpeedMetric() -> any Metric<Measurement<UnitSpeed>> {
        RuntimeMetric(
            snapshots: MetricSnapshot.combining(
                values: speed,
                isAvailable: isAvailable,
                source: .phone,
            ),
        )
    }
}
