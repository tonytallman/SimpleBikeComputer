import LayoutsUI
import PagesVM
import SwiftUI

public struct PortraitPagesView<ViewModel: PortraitPagesViewModel>: View {
    @Bindable private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        PortraitSingleFieldLayout(viewModel: viewModel.layout)
    }
}

#if DEBUG
#Preview {
    PortraitPagesView(viewModel: PreviewPortraitPagesViewModel())
}
#endif
