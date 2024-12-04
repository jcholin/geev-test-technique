//
//  UIKitCoordinator.swift
//  GeevTestTechnique
//
//  Created by Julien Cholin on 01/12/2024.
//

import AdDetail
import AdListing
import Api
import Domain
import Factory
import SwiftUI

final class UIKitCoordinator: AdListingCoordinatorProtocol {
	static let shared = UIKitCoordinator()

	private init() {
		self.navigationController = UINavigationController()
	}

	private let navigationController: UINavigationController

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func start() -> UIViewController {
		let viewModel = Container.shared.adListingViewModel()
		let listingViewController = AdListingViewController(viewModel: viewModel, coordinator: self)
		navigationController.viewControllers = [listingViewController]
		return navigationController
	}

	func startWithSwiftUIView() -> UIViewController {
		let viewModel = Container.shared.adListingViewModel()
		let listingView = AdListingView(viewModel: viewModel, coordinator: self)
		let hostingController = UIHostingController(rootView: listingView)
		navigationController.viewControllers = [hostingController]
		return navigationController
	}

	func navigateToAdDetailUIKit(ad: Ad) {
		let viewModel = Container.shared.adDetailViewModel(ad.id)
		let detailViewController = AdDetailViewController(viewModel: viewModel)
		navigationController.pushViewController(detailViewController, animated: true)
	}

	func navigateToAdDetailSwiftUI(ad: Ad) {
		let viewModel = Container.shared.adDetailViewModel(ad.id)
		let detailView = AdDetailView(viewModel: viewModel)
		let hostingController = UIHostingController(rootView: detailView)
		navigationController.pushViewController(hostingController, animated: true)
	}
}
