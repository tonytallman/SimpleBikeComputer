//
//  ContentView.swift
//  SimpleBikeComputer
//

import DependencyContainer
import LayoutsUI
import SwiftUI

struct ContentView: View {
    let rootViewModel: RootViewModel

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                LandscapeSingleFieldLayout(
                    viewModel: rootViewModel.landscapeSingleFieldLayoutViewModel,
                )
            } else {
                PortraitSingleFieldLayout(
                    viewModel: rootViewModel.portraitSingleFieldLayoutViewModel,
                )
            }
        }
    }
}

#Preview {
    ContentView(rootViewModel: DependencyContainer().makeRootViewModel())
}
