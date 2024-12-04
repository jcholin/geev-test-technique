//
//  AdDetailViewControllerWrapper.swift
//  AdDetail
//
//  Created by Julien Cholin on 02/12/2024.
//

import Domain
import SwiftUI

public struct AdDetailViewControllerWrapper: UIViewControllerRepresentable {
	let viewModel: AdDetailViewModel

	public init(viewModel: AdDetailViewModel) {
		self.viewModel = viewModel
	}

	public func makeUIViewController(context: Context) -> AdDetailViewController {
		AdDetailViewController(viewModel: viewModel)
	}

	public func updateUIViewController(_ uiViewController: AdDetailViewController, context: Context) {

	}
}
