import LayoutsUI
import PagesVM
import SwiftUI

public struct LandscapePagesView<ViewModel: LandscapePagesViewModel>: View {
    @Bindable private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        LandscapeSingleFieldLayout(viewModel: viewModel.layout)
    }
}

#if DEBUG
#Preview {
    LandscapePagesView(viewModel: PreviewLandscapePagesViewModel())
}
#endif
