//
//  AdListingViewModel.swift
//  AdListing
//
//  Created by Julien Cholin on 29/11/2024.
//

import SwiftUI
import Api
import Domain

public final class AdListingViewModel: ObservableObject {
	@Published var ads: [Ad] = []
	@Published var isLoading: Bool = false
	@Published var isLoadingMore = false
	@Published var errorMessage: String?
	@Published var pagination: Pagination?

	private let repository: AdRepositoryProtocol
	private var task: Task<Void, Never>?

	public init(repository: AdRepositoryProtocol) {
		self.repository = repository
	}

	@MainActor
	func fetchAds(reset: Bool = false) {
		if reset {
			ads = []
			pagination = nil
		}

		isLoading = true
		errorMessage = nil

		task = Task { @MainActor in
			do {
				let response = try await repository.fetchAds(
					limit: 26,
					after: reset ? nil : pagination?.after,
					before: reset ? nil : pagination?.before
				)
				guard !Task.isCancelled else { return }

				if reset {
					self.ads = response.data
				} else {
					self.ads.append(contentsOf: response.data)
				}

				self.pagination = response.paging
				isLoading = false
			} catch {
				guard !Task.isCancelled else { return }
				self.errorMessage = error.localizedDescription
				isLoading = false
			}
		}
	}

	@MainActor
	// la closure completion me sert pour l'écran UIKit
	func fetchNextAds(completion: (() -> Void)? = nil) {
		guard !isLoadingMore, let nextPage = pagination?.after else {
			completion?() // appelle la complétion pas de pagination possible
			return
		}

		isLoadingMore = true

		task = Task { @MainActor in
			do {
				let response = try await repository.fetchAds(
					limit: 26,
					after: nextPage,
					before: nil
				)
				guard !Task.isCancelled else { return }

				self.ads.append(contentsOf: response.data)
				self.pagination = response.paging
				self.isLoadingMore = false
			} catch {
				guard !Task.isCancelled else { return }
				self.errorMessage = error.localizedDescription
				self.isLoadingMore = false
			}
			completion?()
		}
	}
}
