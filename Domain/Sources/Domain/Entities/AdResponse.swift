//
//  AdResponse.swift
//  Domain
//
//  Created by Julien Cholin on 03/12/2024.
//

public struct AdResponse: Sendable {
	public let data: [Ad]
	public let paging: Pagination
	
	public init(data: [Ad], paging: Pagination) {
		self.data = data
		self.paging = paging
	}
}

public struct Pagination: Sendable {
	public let after: String?
	public let before: String?
	public let pageLength: Int
	
	public init(after: String?, before: String?, pageLength: Int) {
		self.after = after
		self.before = before
		self.pageLength = pageLength
	}
}
