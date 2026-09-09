import SettingsVM
import SwiftUI

struct SystemSettingsView<ViewModel: SystemSettingsViewModel>: View {
    @Bindable private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Section("System") {
            Toggle(isOn: Binding(
                get: { viewModel.keepScreenOn },
                set: { viewModel.setKeepScreenOn($0) },
            )) {
                Text("Keep screen on")
            }
        }
    }
}

#if DEBUG
#Preview {
    Form {
        SystemSettingsView(viewModel: PreviewSystemSettingsViewModel())
    }
}
#endif
