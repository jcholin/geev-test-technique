//
//  AdListingViewController.swift
//  AdListing
//
//  Created by Julien Cholin on 29/11/2024.
//

import Combine
import Domain
import UIKit
import Factory
import Core

// MARK: - AdListingViewController
public class AdListingViewController: UIViewController {
	private let viewModel: AdListingViewModel
	private var cancellables = Set<AnyCancellable>()
	weak var coordinator: AdListingCoordinatorProtocol?
	
	private var isLoadingMore = false
	
	// MARK: - UI Components
	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.minimumInteritemSpacing = 16
		layout.minimumLineSpacing = 16
		layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .systemBackground
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.register(AdCardCell.self, forCellWithReuseIdentifier: "AdCardCell")
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()
	
	private lazy var loadingIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(style: .large)
		indicator.hidesWhenStopped = true
		indicator.translatesAutoresizingMaskIntoConstraints = false
		return indicator
	}()
	
	private lazy var errorLabel: UILabel = {
		let label = UILabel()
		label.textColor = .systemRed
		label.textAlignment = .center
		label.numberOfLines = 0
		label.isHidden = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
		return refreshControl
	}()
	
	// MARK: - Initialization
	public init(viewModel: AdListingViewModel, coordinator: AdListingCoordinatorProtocol?) {
		self.viewModel = viewModel
		self.coordinator = coordinator
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Lifecycle
	public override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupBindings()
		viewModel.fetchAds()
	}
	
	// MARK: - Setup
	private func setupUI() {
		title = NSLocalizedString("AdListingView.UIKit.title", comment: "")
		view.backgroundColor = .systemBackground
		
		view.addSubview(collectionView)
		view.addSubview(loadingIndicator)
		view.addSubview(errorLabel)
		collectionView.refreshControl = refreshControl
		
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			
			errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
		])
	}
	
	private func setupBindings() {
		viewModel.$isLoading
			.receive(on: DispatchQueue.main)
			.sink { [weak self] isLoading in
				if isLoading {
					self?.loadingIndicator.startAnimating()
				} else {
					self?.loadingIndicator.stopAnimating()
					self?.refreshControl.endRefreshing()
				}
				self?.collectionView.isHidden = isLoading
			}
			.store(in: &cancellables)
		
		viewModel.$errorMessage
			.receive(on: DispatchQueue.main)
			.sink { [weak self] error in
				self?.errorLabel.text = error.map { "Error: \($0)" }
				self?.errorLabel.isHidden = error == nil
				self?.collectionView.isHidden = error != nil
			}
			.store(in: &cancellables)
		
		viewModel.$ads
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.collectionView.reloadData()
			}
			.store(in: &cancellables)
	}
	
	@objc private func handleRefresh() {
		viewModel.fetchAds()
	}
	
	private func showNavigationChoice(for ad: Ad) {
		let alert = UIAlertController(
			title: NSLocalizedString("Alert.navigateTo.choice.title", comment: ""),
			message: nil,
			preferredStyle: .actionSheet
		)
		
		alert.addAction(UIAlertAction(title: "SwiftUI", style: .default) { [weak self] _ in
			self?.coordinator?.navigateToAdDetailSwiftUI(ad: ad)
		})
		
		alert.addAction(UIAlertAction(title: "UIKit", style: .default) { [weak self] _ in
			self?.coordinator?.navigateToAdDetailUIKit(ad: ad)
		})
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		
		present(alert, animated: true)
	}
}

// MARK: - UICollectionViewDataSource & Delegate
extension AdListingViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewModel.ads.count
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdCardCell", for: indexPath) as! AdCardCell
		cell.configure(with: viewModel.ads[indexPath.item])
		return cell
	}
	
	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let ad = viewModel.ads[indexPath.item]
		showNavigationChoice(for: ad)
	}
	
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let screenWidth = UIScreen.main.bounds.width
		let itemWidth = (screenWidth - 48) / 2
		
		// Créer une cellule temporaire pour calculer la taille
		let cell = AdCardCell(frame: CGRect(x: 0, y: 0, width: itemWidth, height: 1000))
		cell.configure(with: viewModel.ads[indexPath.item])
		
		let size = cell.contentView.systemLayoutSizeFitting(
			CGSize(width: itemWidth, height: UIView.layoutFittingExpandedSize.height),
			withHorizontalFittingPriority: .required,
			verticalFittingPriority: .fittingSizeLevel
		)
		
		return CGSize(width: itemWidth, height: size.height)
	}
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let position = scrollView.contentOffset.y
		let contentHeight = scrollView.contentSize.height
		let frameHeight = scrollView.frame.size.height
		
		// Charger les annonces suivantes si l'utilisateur atteint la fin
		if position > contentHeight - frameHeight * 1.5 && !isLoadingMore {
			isLoadingMore = true
			viewModel.fetchNextAds { [weak self] in
				self?.isLoadingMore = false
			}
		}
	}
}

// MARK: - AdCardCell
class AdCardCell: UICollectionViewCell {
	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.backgroundColor = .systemYellow
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let loadingIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(style: .medium)
		indicator.hidesWhenStopped = true
		indicator.translatesAutoresizingMaskIntoConstraints = false
		return indicator
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 17, weight: .semibold)
		label.numberOfLines = 1
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let timeImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "clock")
		imageView.tintColor = .systemGray
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let timeLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 15)
		label.textColor = .systemGray
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let distanceImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "location")
		imageView.tintColor = .systemGray
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let distanceLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 15)
		label.textColor = .systemGray
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		contentView.backgroundColor = .white
		contentView.layer.cornerRadius = 10
		contentView.layer.masksToBounds = true
		
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = CGSize(width: 0, height: 2)
		layer.shadowRadius = 4
		layer.shadowOpacity = 0.1
		layer.masksToBounds = false
		
		// Bottom StackView
		let bottomStack = UIStackView(arrangedSubviews: [timeImageView, timeLabel, UIView(), distanceImageView, distanceLabel])
		bottomStack.axis = .horizontal
		bottomStack.spacing = 4
		bottomStack.translatesAutoresizingMaskIntoConstraints = false
		
		contentView.addSubview(imageView)
		imageView.addSubview(loadingIndicator)
		contentView.addSubview(titleLabel)
		contentView.addSubview(bottomStack)
		
		timeImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
		timeImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
		distanceImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
		distanceImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
		
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			imageView.heightAnchor.constraint(equalToConstant: ImageConfig.imageThumbnailSize),
			
			loadingIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
			loadingIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
			
			// espace après l'image
			titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			
			// espace après le titre
			bottomStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
			bottomStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			bottomStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			// espace en bas de la card
			bottomStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
		])
	}
	
	func configure(with ad: Ad) {
		titleLabel.text = ad.title
		timeLabel.text = "0min"
		distanceLabel.text = "5.3 km"
		
		loadingIndicator.startAnimating()
		
		if let imageUrlString = ad.pictureThumb, let imageUrl = URL(string: imageUrlString) {
			imageView.kf.setImage(
				with: imageUrl,
				placeholder: nil,
				options: [.transition(.fade(0.2))],
				completionHandler: { [weak self] result in
					self?.loadingIndicator.stopAnimating()
					switch result {
					case .success(_): break
					case .failure(let error):
						print("Kingfisher error: \(error.localizedDescription)")
					}
				}
			)
		} else {
			imageView.backgroundColor = .systemYellow
			loadingIndicator.stopAnimating()
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		imageView.kf.cancelDownloadTask()
		imageView.image = nil
		loadingIndicator.stopAnimating()
		titleLabel.text = nil
		timeLabel.text = nil
		distanceLabel.text = nil
	}
}
