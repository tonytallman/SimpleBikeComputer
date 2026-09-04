import Foundation
import Observation

@Observable
@MainActor
public final class RuntimeMetric: Metric {
    public let name: String
    public private(set) var value: String
    public private(set) var units: String

    @ObservationIgnored
    private var consumeTask: Task<Void, Never>?

    public init<Values, Unit: Dimension>(
        name: String,
        values: Values,
    ) where Values: AsyncSequence,
        Values.Element == Measurement<Unit>,
        Values.Failure == Never,
        Values: Sendable
    {
        self.name = name
        self.value = "--"
        self.units = ""

        consumeTask = Task { @MainActor [weak self] in
            for await measurement in values {
                guard !Task.isCancelled else { return }
                self?.apply(measurement)
            }
        }
    }

    deinit {
        consumeTask?.cancel()
    }

    private func apply<Unit: Dimension>(_ measurement: Measurement<Unit>) {
        value = Self.formatValue(measurement.value)
        units = measurement.unit.symbol
    }

    private static func formatValue(_ numericValue: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: numericValue)) ?? String(numericValue)
    }
}
