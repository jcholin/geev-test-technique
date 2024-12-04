//
//  SwiftUICoordinator.swift
//  GeevTestTechnique
//
//  Created by Julien Cholin on 01/12/2024.
//

import AdListing
import Domain
import SwiftUI
import Factory

final class SwiftUICoordinator: ObservableObject, AdListingCoordinatorProtocol {
	static let shared = SwiftUICoordinator()
	@Published var navigationPath = NavigationPath()
	@Published private(set) var rootView: AnyView?
	
	private init() {}
	
	func start() {
		let viewModel = AdListingViewModel(repository: Container.shared.adRepository())
		rootView = AnyView(
			AdListingView(
				viewModel: viewModel,
				navigationPath: Binding(
					get: { self.navigationPath },
					set: { self.navigationPath = $0 }
				),
				coordinator: self
			)
		)
	}
	
	func navigateToAdDetailSwiftUI(ad: Ad) {
		navigationPath.append(NavigationDestination.adDetailSwiftUI(ad: ad))
	}
	
	func navigateToAdDetailUIKit(ad: Ad) {
		navigationPath.append(NavigationDestination.adDetailUIKit(ad: ad))
	}
}

public enum NavigationDestination: Hashable {
	case adDetailSwiftUI(ad: Ad)
	case adDetailUIKit(ad: Ad)
}
