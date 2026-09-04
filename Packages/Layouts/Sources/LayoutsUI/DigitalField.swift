import LayoutsModel
import Observation
import SwiftUI

public struct DigitalField<ViewModel: Metric>: View {
    @Bindable private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 12) {
            Text(viewModel.name)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text(viewModel.value)
                .font(.system(size: 90, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .foregroundStyle(.primary)

            Text(viewModel.units)
                .font(.title2.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
import LayoutsVM

#Preview {
    DigitalField(viewModel: PreviewMetric(name: "Speed", value: "20.0", units: "mph"))
        .padding()
        .background(Color(.systemBackground))
}
#endif
