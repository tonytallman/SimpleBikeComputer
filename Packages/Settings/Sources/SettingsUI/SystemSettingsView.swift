import SettingsVM
import SwiftUI

struct SystemSettingsView<ViewModel: SystemSettingsViewModel>: View {
    @Environment(\.scenePhase) private var scenePhase
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

            HStack {
                Text("Location permission")
                Spacer()
                Text(viewModel.locationPermissionStatusText)
                    .foregroundStyle(.secondary)
                Button {
                    viewModel.openLocationPermissions()
                } label: {
                    Image(systemName: "arrow.up.forward.app")
                }
                .buttonStyle(.borderless)
            }
        }
        .onAppear {
            viewModel.viewAppeared()
        }
        .onChange(of: scenePhase) { _, newPhase in
            viewModel.scenePhaseChanged(to: newPhase)
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
