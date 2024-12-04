//
//  AdResponseDTO.swift
//  Api
//
//  Created by Julien Cholin on 03/12/2024.
//

public struct AdResponseDTO: Decodable, Sendable {
	public let data: [AdDTO]
	public let paging: PaginationDTO

	private enum CodingKeys: String, CodingKey {
		case data
		case paging
	}
}

public struct PaginationDTO: Decodable, Sendable {
	public let after: String?
	public let before: String?
	public let pageLength: Int
}
