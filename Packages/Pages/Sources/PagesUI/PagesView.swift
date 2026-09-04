import PagesVM
import SwiftUI

public struct PagesView<ViewModel: PagesViewModel>: View {
    @Bindable private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                LandscapePagesView(viewModel: viewModel.landscapePages)
            } else {
                PortraitPagesView(viewModel: viewModel.portraitPages)
            }
        }
    }
}

#if DEBUG
#Preview {
    PagesView(viewModel: PreviewPagesViewModel())
}
#endif
