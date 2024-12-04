//
//  AdRepositoryProtocol.swift
//  Domain
//
//  Created by Julien Cholin on 02/12/2024.
//

import Foundation
import RxSwift

public protocol AdRepositoryProtocol {
	func fetchAds(limit: Int, after: String?, before: String?) async throws -> AdResponse
	func fetchAdDetail(id: String) async throws -> Ad
	func fetchAdDetailWithRxSwift(id: String) -> Single<Ad>
}
