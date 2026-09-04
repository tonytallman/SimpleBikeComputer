import PagesUI
import RootVM
import SwiftUI

public struct RootView<ViewModel: RootViewModel>: View {
    @Bindable private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        PagesView(viewModel: viewModel.pages)
    }
}

#if DEBUG
#Preview {
    RootView(viewModel: PreviewRootViewModel())
}
#endif
