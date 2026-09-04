//
//  SimpleBikeComputerApp.swift
//  SimpleBikeComputer
//

import DependencyContainer
import RootUI
import SwiftUI

@main
struct SimpleBikeComputerApp: App {
    @MainActor private static let dependencyContainer = DependencyContainer()
    @MainActor private static let rootViewModel = dependencyContainer.makeRootViewModel()

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: Self.rootViewModel)
        }
    }
}
