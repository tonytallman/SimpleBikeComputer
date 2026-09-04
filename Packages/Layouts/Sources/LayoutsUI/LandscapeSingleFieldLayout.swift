import LayoutsVM
import SwiftUI

public struct LandscapeSingleFieldLayout<ViewModel: LandscapeSingleFieldLayoutViewModel>: View {
    @Bindable private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        HStack(spacing: 0) {
            Spacer()
            DigitalField(viewModel: viewModel.metric)
            Spacer()
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

#if DEBUG
import LayoutsVM

#Preview {
    LandscapeSingleFieldLayout(
        viewModel: PreviewLandscapeSingleFieldLayoutViewModel(),
    )
}
#endif
