//
//  RootView.swift
//  GeevTestTechnique
//
//  Created by Julien Cholin on 29/11/2024.
//

import AdDetail
import Factory
import SwiftUI

struct RootView: View {
	@StateObject private var swiftUICoordinator: SwiftUICoordinator
	private let uiKitCoordinator: UIKitCoordinator
	@State private var useUIKit: Bool? = nil

	init(
		swiftUICoordinator: SwiftUICoordinator,
		uiKitCoordinator: UIKitCoordinator
	) {
		_swiftUICoordinator = StateObject(wrappedValue: swiftUICoordinator)
		self.uiKitCoordinator = uiKitCoordinator
	}

	var body: some View {
		Group {
			if let useUIKit = useUIKit {
				if useUIKit {
					UIKitCoordinatorWrapper(coordinator: uiKitCoordinator)
				} else {
					NavigationStack(path: $swiftUICoordinator.navigationPath) {
						if let rootView = swiftUICoordinator.rootView {
							rootView
								.navigationDestination(for: NavigationDestination.self) { destination in
									switch destination {
									case .adDetailSwiftUI(let ad):
										let viewModel = Container.shared.adDetailViewModel(ad.id)
										AdDetailView(viewModel: viewModel)
									case .adDetailUIKit(let ad):
										let viewModel = Container.shared.adDetailViewModel(ad.id)
										AdDetailViewControllerWrapper(viewModel: viewModel)
									}
								}
						}
					}
				}
			} else {
				CoordinatorChoiceSheet(
					onSelectSwiftUI: {
						swiftUICoordinator.start()
						useUIKit = false
					},
					onSelectUIKit: {
						useUIKit = true
					}
				)
			}
		}
		.animation(.snappy, value: useUIKit)
	}
}
