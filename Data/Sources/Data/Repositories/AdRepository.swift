//
//  AdRepository.swift
//  Data
//
//  Created by Julien Cholin on 02/12/2024.
//

import Api
import Domain
import RxSwift

public class AdRepository: AdRepositoryProtocol {
	private let remoteDataSource: AdRemoteDataSourceProtocol

	public init(remoteDataSource: AdRemoteDataSourceProtocol) {
		self.remoteDataSource = remoteDataSource
	}

	public func fetchAds(limit: Int, after: String? = nil, before: String? = nil) async throws -> AdResponse {
		let responseDTO = try await remoteDataSource.fetchAds(limit: limit, after: after, before: before)
		let data = AdMapper.map(dtoList: responseDTO.data)
		let paging = Pagination(
			after: responseDTO.paging.after,
			before: responseDTO.paging.before,
			pageLength: responseDTO.paging.pageLength
		)

		return AdResponse(data: data, paging: paging)
	}

	public func fetchAdDetail(id: String) async throws -> Ad {
		let dto = try await remoteDataSource.fetchAdDetail(id: id)
		return AdMapper.map(dto: dto)
	}

	public func fetchAdDetailWithRxSwift(id: String) -> Single<Ad> {
		return remoteDataSource
			.fetchAdDetailWithRxSwift(id: id)
			.map { dto in AdMapper.map(dto: dto) }
	}
}
