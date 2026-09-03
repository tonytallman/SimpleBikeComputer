//
//  SimpleBikeComputerApp.swift
//  SimpleBikeComputer
//
//  Created by Tony Tallman on 9/2/26.
//

import SwiftUI
import DependencyContainer

@main
struct SimpleBikeComputerApp: App {
    let dependencyContainer = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
