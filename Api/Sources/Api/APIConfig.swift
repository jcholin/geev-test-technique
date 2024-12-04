//
//  APIConfig.swift
//  Api
//
//  Created by Julien Cholin on 02/12/2024.
//

import Foundation

public struct APIConfig {
	// MARK: - Configuration
	public static let environment: Environment = .prod

	// MARK: - Environment
	public enum Environment : Sendable {
		case prod
		case staging

		var endpointBaseUrl: String {
			switch self {
			case .prod:
				return "https://prod.geev.fr"
			case .staging:
				return "https://stage.geev.fr"
			}
		}

		var imageBaseUrl: String {
			switch self {
			case .prod:
				return "https://images.geev.fr"
			case .staging:
				return "https://stage-images.geev.fr"
			}
		}
	}

	// MARK: - Endpoints
	public struct Endpoints {
		public static var ads: String {
			"\(environment.endpointBaseUrl)/v2/search/items/geo"
		}

		public static func adDetail(id: String) -> String {
			"\(environment.endpointBaseUrl)/v1/api/v0.19/articles/\(id)"
		}
	}

	// MARK: - Images
	public static func picture(id: String, size: CGFloat) -> String {
		"\(environment.imageBaseUrl)/\(id)/squares/\(size)"
	}
}
