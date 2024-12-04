//
//  AdRemoteDataSourceProtocol.swift
//  Api
//
//  Created by Julien Cholin on 02/12/2024.
//

import Alamofire
import RxSwift
import Foundation

public protocol AdRemoteDataSourceProtocol {
	func fetchAds(limit: Int, after: String?, before: String?) async throws -> AdResponseDTO
	func fetchAdDetail(id: String) async throws -> AdDTO
	func fetchAdDetailWithRxSwift(id: String) -> Single<AdDTO>
}

public class AdRemoteDataSource: AdRemoteDataSourceProtocol {
	private let networkService: NetworkService

	public init(networkService: NetworkService) {
		self.networkService = networkService
	}

	public func fetchAds(limit: Int, after: String? = nil, before: String? = nil) async throws -> AdResponseDTO {
		var queryParameters: Parameters = ["limit": limit]

		if let after = after {
			queryParameters["after"] = after
		}
		if let before = before {
			queryParameters["before"] = before
		}

		let bodyParameters: Parameters = [
			"type": ["donation"],
			"distance": 10000,
			"donationState": ["open", "reserved"],
			"latitude": 44.838069099999998,
			"universe": ["object"],
			"longitude": -0.57776780000000005
		]

		let request = networkService.request(
			endpoint: APIConfig.Endpoints.ads,
			method: .post,
			queryParameters: queryParameters,
			bodyParameters: bodyParameters
		)

		return try await request
			.serializingDecodable(AdResponseDTO.self)
			.value
	}

	public func fetchAdDetail(id: String) async throws -> AdDTO {
		let request = networkService.request(
			endpoint: APIConfig.Endpoints.adDetail(id: id),
			method: .get
		)

		return try await request
			.serializingDecodable(AdDTO.self)
			.value
	}

	public func fetchAdDetailWithRxSwift(id: String) -> Single<AdDTO> {
		return Single.create { [weak self] single in
			guard let self = self else { return Disposables.create() }

			let request = self.networkService.request(
				endpoint: APIConfig.Endpoints.adDetail(id: id),
				method: .get,
				queryParameters: nil,
				bodyParameters: nil
			)
				.validate(statusCode: 200..<300)
				.responseData { response in
					switch response.result {
					case .success(let data):
						do {
							let adDTO = try JSONDecoder().decode(AdDTO.self, from: data)
							single(.success(adDTO))
						} catch {
							single(.failure(error))
						}
					case .failure(let error):
						single(.failure(error))
					}
				}

			return Disposables.create {
				request.cancel()
			}
		}
		.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
		.observe(on: MainScheduler.instance)
	}
}
