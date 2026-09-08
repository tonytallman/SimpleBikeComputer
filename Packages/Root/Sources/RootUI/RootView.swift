import PagesUI
import RootVM
import SettingsUI
import SwiftUI

public struct RootView<ViewModel: RootViewModel>: View {
    @Bindable private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            PagesView(viewModel: viewModel.pages)

            Button {
                viewModel.isSettingsPresented = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityLabel("Settings")
            .padding(.top, 8)
            .padding(.trailing, 12)
            .safeAreaPadding(.top)
            .safeAreaPadding(.trailing)
        }
        .fullScreenCover(isPresented: $viewModel.isSettingsPresented) {
            SettingsView(viewModel: viewModel.makeSettings())
        }
    }
}

#if DEBUG
#Preview {
    RootView(viewModel: PreviewRootViewModel())
}
#endif
