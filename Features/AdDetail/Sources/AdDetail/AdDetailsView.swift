//
//  AdDetailViewController.swift
//  AdDetail
//
//  Created by Julien Cholin on 29/11/2024.
//

import UIKit
import Domain
import Api
import SwiftUI
import Factory
import Kingfisher
import Core

public struct AdDetailView: View {
	@StateObject var viewModel: AdDetailViewModel

	private var title: String {
		if let adTitle = viewModel.ad?.title {
			return String(format: NSLocalizedString("Ad.title.swiftui", comment: ""), adTitle)
		}
		return NSLocalizedString("AdDetailView.title", comment: "")
	}

	public init(viewModel: AdDetailViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}

	public var body: some View {
		VStack(alignment: .leading) {
			if viewModel.isLoading {
				CircularLoader()
					.frame(maxHeight: .infinity, alignment: .center)
			} else if let error = viewModel.errorMessage {
				Text("Error: \(error)")
					.foregroundColor(.red)
					.multilineTextAlignment(.center)
					.padding()
			} else if let ad = viewModel.ad {
				if let imageUrl = ad.pictureLarge, let url = URL(string: imageUrl) {
					KFImage(url)
						.onFailure { error in
							print("Kingfisher error: \(error.localizedDescription)")
						}
						.placeholder {
							CircularLoader(size: 20, thickness: 3)
								.frame(maxHeight: .infinity, alignment: .center)
						}
						.resizable()
						.aspectRatio(contentMode: .fit)
						.clipped()

					VStack(alignment: .leading, spacing: 8) {
						Text(String(format: NSLocalizedString("Ad.title.swiftui", comment: ""), ad.title))
							.font(.headline)
						Text(ad.description)
							.font(.body)
					}
					.padding()
				}
			}

			Spacer()
		}
		.onAppear {
//			viewModel.fetchAd()
			viewModel.fetchAdWithRxSwift()
		}
	}
}
