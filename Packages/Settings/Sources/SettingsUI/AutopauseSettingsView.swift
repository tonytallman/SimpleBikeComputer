import Foundation
import SettingsVM
import SwiftUI

struct AutopauseSettingsView<ViewModel: AutopauseSettingsViewModel>: View {
    @Bindable private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Section("Autopause") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Speed Threshold")
                    Spacer()
                    Text(String(
                        format: "%.1f %@",
                        viewModel.currentAutoPauseThreshold
                            .converted(to: viewModel.currentSpeedUnits).value,
                        viewModel.currentSpeedUnits.symbol,
                    ))
                    .foregroundStyle(.secondary)
                }

                Slider(
                    value: Binding(
                        get: {
                            viewModel.currentAutoPauseThreshold
                                .converted(to: viewModel.currentSpeedUnits).value
                        },
                        set: { newValue in
                            let newThreshold = Measurement(
                                value: newValue,
                                unit: viewModel.currentSpeedUnits,
                            )
                            viewModel.setAutoPauseThreshold(newThreshold)
                        },
                    ),
                    in: 0 ... 10,
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    Form {
        AutopauseSettingsView(viewModel: PreviewAutopauseSettingsViewModel())
    }
}
#endif
