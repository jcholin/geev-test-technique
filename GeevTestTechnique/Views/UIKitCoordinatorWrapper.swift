//
//  UIKitCoordinatorWrapper.swift
//  GeevTestTechnique
//
//  Created by Julien Cholin on 02/12/2024.
//

import SwiftUI

struct UIKitCoordinatorWrapper: UIViewControllerRepresentable {
	private let coordinator: UIKitCoordinator

	init(coordinator: UIKitCoordinator) {
		self.coordinator = coordinator
	}

	func makeUIViewController(context: Context) -> UIViewController {
		coordinator.start()
	}

	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {

	}
}
