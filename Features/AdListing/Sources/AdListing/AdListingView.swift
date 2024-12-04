//
//  AdListingView.swift
//  AdListing
//
//  Created by Julien Cholin on 29/11/2024.
//

import AdDetail
import Domain
import SwiftUI
import Factory
import Core

public struct AdListingView: View {
	@StateObject var viewModel: AdListingViewModel
	@Binding var navigationPath: NavigationPath
	@State private var showNavigationChoice = false
	@State private var selectedAd: Ad?
	public weak var coordinator: AdListingCoordinatorProtocol?

	private var isSheetPresented: Binding<Bool> {
		Binding(
			get: { showNavigationChoice && selectedAd != nil },
			set: { newValue in
				showNavigationChoice = newValue
				if !newValue { selectedAd = nil }
			}
		)
	}

	public init(
		viewModel: AdListingViewModel,
		navigationPath: Binding<NavigationPath> = .constant(NavigationPath()),
		coordinator: AdListingCoordinatorProtocol?
	) {
		self._viewModel = StateObject(wrappedValue: viewModel)
		self._navigationPath = navigationPath
		self.coordinator = coordinator
	}

	let columns = [
		GridItem(.flexible(), spacing: 16),
		GridItem(.flexible(), spacing: 16)
	]

	public var body: some View {
		ZStack {
			GeometryReader { geometry in
				ScrollView {
					if viewModel.isLoading {
						CircularLoader()
							.frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
					} else if let error = viewModel.errorMessage {
						Text("Error: \(error)")
							.foregroundColor(.red)
							.multilineTextAlignment(.center)
							.padding()
							.frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
					} else {
						VStack {
							LazyVGrid(columns: columns, spacing: 16) {
								ForEach(viewModel.ads) { ad in
									AdCardView(ad: ad)
										.onTapGesture {
											selectedAd = ad
											showNavigationChoice = true
										}
										.onAppear {
											if ad == viewModel.ads.last {
												viewModel.fetchNextAds()
											}
										}
								}
							}
							.padding(.horizontal)

							// Loader pour la pagination
							if viewModel.isLoadingMore {
								CircularLoader()
									.frame(maxWidth: .infinity)
									.padding()
							}
						}
					}
				}
			}
			.refreshable {
				viewModel.fetchAds(reset: true)
			}
		}
		.onAppear {
			if viewModel.ads.isEmpty {
				viewModel.fetchAds()
			}
		}
		.navigationTitle("AdListingView.SwiftUI.title")
		.confirmationDialog("Alert.navigateTo.choice.title", isPresented: isSheetPresented, titleVisibility: .visible) {
			Button("SwiftUI") {
				if let selectedAd {
					coordinator?.navigateToAdDetailSwiftUI(ad: selectedAd)
				}
			}

			Button("UIKit") {
				if let selectedAd {
					coordinator?.navigateToAdDetailUIKit(ad: selectedAd)
				}
			}
		}
	}
}
