import Foundation
import SettingsVM
import SwiftUI

struct UnitSettingsView<ViewModel: UnitSettingsViewModel>: View {
    @Bindable private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Section("Units") {
            Picker("Speed", selection: Binding(
                get: { viewModel.currentSpeedUnits },
                set: { viewModel.setSpeedUnits($0) },
            )) {
                ForEach(viewModel.availableSpeedUnits, id: \.self) { unit in
                    Text(unitDisplayName(unit)).tag(unit)
                }
            }

            Picker("Distance", selection: Binding(
                get: { viewModel.currentDistanceUnits },
                set: { viewModel.setDistanceUnits($0) },
            )) {
                ForEach(viewModel.availableDistanceUnits, id: \.self) { unit in
                    Text(unitDisplayName(unit)).tag(unit)
                }
            }
        }
    }
}

private func unitDisplayName(_ unit: Dimension) -> String {
    let formatter = MeasurementFormatter()
    formatter.unitStyle = .long
    let name = formatter.string(from: unit)
    return "\(name) (\(unit.symbol))"
}

#if DEBUG
#Preview {
    Form {
        UnitSettingsView(viewModel: PreviewUnitSettingsViewModel())
    }
}
#endif
