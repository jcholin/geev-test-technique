//
//  AdDTO.swift
//  Api
//
//  Created by Julien Cholin on 02/12/2024.
//

import Foundation

public struct AdDTO: Decodable, Sendable {
	public let id: String
	public let title: String
	public let description: String
	public let pictures: [Picture]
	public let time = Int.random(in: 0...60) // on simule un temps de trajet
	public let distance = Double.random(in: 0...20) // on simule une distance

	/// Représentation d'une image, soit par URL, soit par ID vu que Geev
	/// renvoi soit un tableau d'ids ou d'url (pour le détail)
	public enum Picture: Decodable, Sendable {
		case url(PictureURL)
		case id(String)

		public struct PictureURL: Decodable, Sendable {
			public let squares32: String?
			public let squares64: String?
			public let squares128: String?
			public let squares300: String?
			public let squares600: String?
			public let resizes1000: String?
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()
			if let url = try? container.decode(PictureURL.self) {
				self = .url(url)
			} else if let id = try? container.decode(String.self) {
				self = .id(id)
			} else {
				throw DecodingError.dataCorruptedError(
					in: container,
					debugDescription: "Invalid format for picture: expected PictureURL or String."
				)
			}
		}
	}

	private enum CodingKeys: String, CodingKey {
		case id = "_id"
		case title
		case description
		case pictures
	}
}
