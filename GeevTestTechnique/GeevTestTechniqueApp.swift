//
//  GeevTestTechniqueApp.swift
//  GeevTestTechnique
//
//  Created by Julien Cholin on 27/11/2024.
//

import SwiftUI

@main
struct GeevTestTechniqueApp: App {
	private let swiftUICoordinator = SwiftUICoordinator.shared
	private let uiKitCoordinator = UIKitCoordinator.shared

	var body: some Scene {
		WindowGroup {
			RootView(
				swiftUICoordinator: swiftUICoordinator,
				uiKitCoordinator: uiKitCoordinator
			)
		}
	}
}
