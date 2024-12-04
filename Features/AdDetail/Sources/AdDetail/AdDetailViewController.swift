//
//  AdDetailViewController.swift
//  AdDetail
//
//  Created by Julien Cholin on 29/11/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

public class AdDetailViewController: UIViewController {
	private let viewModel: AdDetailViewModel
	private let imageView = UIImageView()
	private let titleLabel = UILabel()
	private let descriptionLabel = UILabel()
	private let loadingIndicator = UIActivityIndicatorView(style: .medium)
	private let disposeBag = DisposeBag()

	public init(viewModel: AdDetailViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		bindViewModel()
		viewModel.fetchAdWithRxSwift()
	}

	private func setupUI() {
		view.backgroundColor = .systemBackground
		title = "UIKit Detail"

		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 16
		stackView.translatesAutoresizingMaskIntoConstraints = false

		imageView.contentMode = .scaleAspectFill
		imageView.backgroundColor = .yellow
		imageView.clipsToBounds = true

		loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
		imageView.addSubview(loadingIndicator)
		loadingIndicator.hidesWhenStopped = true

		titleLabel.font = .boldSystemFont(ofSize: 24)
		titleLabel.numberOfLines = 0

		descriptionLabel.numberOfLines = 0
		descriptionLabel.font = .systemFont(ofSize: 17)

		let textStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
		textStackView.axis = .vertical
		textStackView.spacing = 8
		textStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		textStackView.isLayoutMarginsRelativeArrangement = true

		stackView.addArrangedSubview(imageView)
		stackView.addArrangedSubview(textStackView)

		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

			loadingIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
			loadingIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),

			imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.75)
		])
	}

	private func bindViewModel() {
		viewModel.adObservable
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] ad in
				guard let ad = ad else { return }
				self?.titleLabel.text = String(format: NSLocalizedString("Ad.title.uikit", comment: ""), ad.title)
				self?.descriptionLabel.text = ad.description
				self?.title = String(format: NSLocalizedString("Ad.title.uikit", comment: ""), ad.title)

				if let imageUrl = ad.pictureLarge, let url = URL(string: imageUrl) {
					self?.loadingIndicator.startAnimating()
					self?.imageView.kf.setImage(
						with: url,
						placeholder: nil,
						options: [.transition(.fade(0.3))],
						completionHandler: { [weak self] result in
							self?.loadingIndicator.stopAnimating()
							switch result {
							case .success(_): break
							case .failure(let error):
								print("Kingfisher error: \(error.localizedDescription)")
							}
						}
					)
				}
			})
			.disposed(by: disposeBag)

		viewModel.isLoadingObservable
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] isLoading in
				if isLoading {
					self?.loadingIndicator.startAnimating()
				} else {
					self?.loadingIndicator.stopAnimating()
				}
			})
			.disposed(by: disposeBag)

		viewModel.errorMessageObservable
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] error in
				if let error = error {
					let alert = UIAlertController(
						title: "Error",
						message: error,
						preferredStyle: .alert
					)
					alert.addAction(UIAlertAction(title: "OK", style: .default))
					self?.present(alert, animated: true)
				}
			})
			.disposed(by: disposeBag)
	}
}
