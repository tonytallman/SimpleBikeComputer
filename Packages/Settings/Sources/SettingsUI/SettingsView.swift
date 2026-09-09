import SettingsVM
import SwiftUI

public struct SettingsView<ViewModel: SettingsViewModel>: View {
    @Bindable private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            Form {
                UnitSettingsView(viewModel: viewModel.units)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    SettingsView(viewModel: PreviewSettingsViewModel())
}
#endif
