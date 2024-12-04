//
//  AdCardView.swift
//  AdListing
//
//  Created by Julien Cholin on 02/12/2024.
//

import Kingfisher
import Domain
import SwiftUI
import Core

public struct AdCardView: View {
	let ad: Ad
	
	public var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			KFImage(URL(string: ad.pictureThumb ?? ""))
				.onFailure { error in
					print("Kingfisher error: \(error.localizedDescription)")
				}
				.placeholder {
					Color.yellow
				}
				.resizable()
				.scaledToFill()
				.frame(height: ImageConfig.imageThumbnailSize)
				.clipped()
			
			Text(ad.title)
				.font(.headline)
				.lineLimit(2, reservesSpace: true)
				.multilineTextAlignment(.leading)
				.padding(.horizontal)
			
			HStack(spacing: 0) {
				HStack(spacing: 4) {
					Image(systemName: "clock")
					Text(String(format: "%dmin", ad.time))
				}
				
				Spacer()
				
				HStack(spacing: 4) {
					Image(systemName: "location")
					Text(String(format: "%.1fkm", ad.distance))
				}
			}
			.foregroundColor(.gray)
			.font(.footnote)
			.padding(.horizontal)
		}
		.padding(.bottom)
		.background(Color.white)
		.cornerRadius(10)
		.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
	}
}
