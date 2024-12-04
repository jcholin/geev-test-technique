//
//  NetworkService.swift
//  Api
//
//  Created by Julien Cholin on 29/11/2024.
//

import Alamofire
import Foundation

public protocol NetworkServiceProtocol {
	func request(
		endpoint: String,
		method: HTTPMethod,
		queryParameters: Parameters?,
		bodyParameters: Parameters?
	) -> DataRequest
}

public final class NetworkService: NetworkServiceProtocol {
	private let session: Session
	private let commonHeaders: HTTPHeaders

	public init() {
		self.commonHeaders = [
			"Accept": "application/json",
			"Content-Type": "application/json"
		]

		let configuration = URLSessionConfiguration.default
		configuration.httpAdditionalHeaders = HTTPHeaders.default.dictionary

		let eventMonitor = NetworkLogger()
		self.session = Session(configuration: configuration, eventMonitors: [eventMonitor])
	}

	public func request(
		endpoint: String,
		method: HTTPMethod = .get,
		queryParameters: Parameters? = nil,
		bodyParameters: Parameters? = nil
	) -> DataRequest {
		var urlComponents = URLComponents(string: endpoint)

		if let queryParameters = queryParameters {
			let queryItems = queryParameters.map {
				URLQueryItem(name: $0.key, value: "\($0.value)")
			}
			urlComponents?.queryItems = queryItems
		}

		return session.request(
			urlComponents?.url ?? endpoint,
			method: method,
			parameters: bodyParameters,
			encoding: JSONEncoding.default,
			headers: commonHeaders
		)
		.validate()
	}
}

public final class NetworkLogger: EventMonitor {
	public func requestDidResume(_ request: Request) {
		print("➡️ Request: \(request.description)")
		if let urlRequest = request.performedRequests.last {
			print("Headers: \(urlRequest.headers)")
			print("Method: \(urlRequest.method)")
		}
	}

	public func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
		print("⬅️ Response received for \(request.description)")
		if let data = response.data, let json = try? JSONSerialization.jsonObject(with: data) {
			print("✅ Response JSON: \(json)")
		}
		if let error = response.error {
			print("❌ Error: \(error)")
		}
		print("Status Code: \(response.response?.statusCode ?? -1)")
	}
}
