import LayoutsVM
import SwiftUI

public struct PortraitSingleFieldLayout<ViewModel: PortraitSingleFieldLayoutViewModel>: View {
    @Bindable private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
            DigitalField(viewModel: viewModel.metric)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

#if DEBUG
import LayoutsVM

#Preview {
    PortraitSingleFieldLayout(
        viewModel: PreviewPortraitSingleFieldLayoutViewModel(),
    )
}
#endif
