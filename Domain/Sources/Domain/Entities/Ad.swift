//
//  Ad.swift
//  Domain
//
//  Created by Julien Cholin on 29/11/2024.
//

import Foundation

public struct Ad: Identifiable, Hashable, Sendable {
	public let id: String
	public let title: String
	public let description: String
	public let pictureThumb: String?
	public let pictureLarge: String?
	public let time: Int
	public let distance: Double

	public init(
		id: String,
		title: String,
		description: String,
		pictureThumb: String?,
		pictureLarge: String?,
		time: Int,
		distance: Double
	) {
		self.id = id
		self.title = title
		self.description = description
		self.pictureThumb = pictureThumb
		self.pictureLarge = pictureLarge
		self.time = time
		self.distance = distance
	}
}
