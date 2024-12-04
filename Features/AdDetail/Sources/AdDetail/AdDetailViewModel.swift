//
//  AdDetailViewModel.swift
//  AdDetail
//
//  Created by Julien Cholin on 29/11/2024.
//

import SwiftUI
import Api
import Domain
import RxSwift
import RxCocoa

public class AdDetailViewModel: ObservableObject {
	// MARK: - Pour SwiftUI
	@Published var ad: Ad?
	@Published var isLoading: Bool = false
	@Published var errorMessage: String?

	// MARK: - Observable RxSwift pour UIKit
	public let adObservable: Observable<Ad?>
	public let isLoadingObservable: Observable<Bool>
	public let errorMessageObservable: Observable<String?>

	// MARK: - Subject
	private let adSubject = BehaviorSubject<Ad?>(value: nil)
	private let isLoadingSubject = BehaviorSubject<Bool>(value: false)
	private let errorMessageSubject = BehaviorSubject<String?>(value: nil)

	private let disposeBag = DisposeBag()

	private let repository: AdRepositoryProtocol
	private let adId: String
	private var task: Task<Void, Never>?

	public init(repository: AdRepositoryProtocol, adId: String) {
		self.repository = repository
		self.adId = adId

		self.adObservable = adSubject.asObservable()
		self.isLoadingObservable = isLoadingSubject.asObservable()
		self.errorMessageObservable = errorMessageSubject.asObservable()

		// Synchro avec SwiftUI
		adObservable
			.subscribe(onNext: { [weak self] ad in
				self?.ad = ad
			})
			.disposed(by: disposeBag)

		isLoadingObservable
			.subscribe(onNext: { [weak self] isLoading in
				self?.isLoading = isLoading
			})
			.disposed(by: disposeBag)

		errorMessageObservable
			.subscribe(onNext: { [weak self] errorMessage in
				self?.errorMessage = errorMessage
			})
			.disposed(by: disposeBag)
	}

	@MainActor
	func fetchAd() {
		isLoading = true
		errorMessage = nil

		task = Task { @MainActor in
			do {
				let result = try await repository.fetchAdDetail(id: adId)
				guard !Task.isCancelled else { return }
				self.ad = result
				isLoading = false
			} catch {
				guard !Task.isCancelled else { return }
				self.errorMessage = error.localizedDescription
				isLoading = false
			}
		}
	}

	public func fetchAdWithRxSwift() {
		isLoadingSubject.onNext(true)
		errorMessageSubject.onNext(nil)

		repository.fetchAdDetailWithRxSwift(id: adId)
			.observe(on: MainScheduler.instance)
			.subscribe(
				onSuccess: { [weak self] ad in
					self?.adSubject.onNext(ad)
					self?.isLoadingSubject.onNext(false)
				},
				onFailure: { [weak self] error in
					self?.errorMessageSubject.onNext(error.localizedDescription)
					self?.isLoadingSubject.onNext(false)
				}
			)
			.disposed(by: disposeBag)
	}
}
