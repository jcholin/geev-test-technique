//
//  AdMapper.swift
//  Data
//
//  Created by Julien Cholin on 03/12/2024.
//

import Api
import Domain
import Core
import Foundation

public struct AdMapper {
	public static func map(dto: AdDTO) -> Ad {
		let pictureThumb = dto.pictures.compactMap { picture in
			return switch picture {
			case .url(let pictureURL): pictureURL.squares300
			case .id(let id): buildImageUrlFromId(id: id, size: ImageConfig.imageThumbnailSize)
			}
		}.first
		
		let pictureLarge = dto.pictures.compactMap { picture in
			switch picture {
			case .url(let pictureURL): pictureURL.squares600
			case .id(let id): buildImageUrlFromId(id: id, size: ImageConfig.imageLargeSize)
			}
		}.first
		
		return Ad(
			id: dto.id,
			title: dto.title,
			description: dto.description,
			pictureThumb: pictureThumb,
			pictureLarge: pictureLarge,
			time: dto.time,
			distance: dto.distance
		)
	}
	
	public static func map(dtoList: [AdDTO]) -> [Ad] {
		return dtoList.map { map(dto: $0) }
	}
	
	private static func buildImageUrlFromId(id: String, size: CGFloat) -> String {
		return APIConfig.picture(id: id, size: size)
	}
}
