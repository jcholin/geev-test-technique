//
//  CircularLoader.swift
//  GeevTestTechnique
//
//  Created by Julien Cholin on 03/12/2024.
//

import SwiftUI

public struct CircularLoader: View {
	let color: Color
	let size: CGFloat
	let thickness: CGFloat
	let text: String
	@State private var isAnimating = false

	public init(
		color: Color = .yellow,
		size: CGFloat = 48,
		thickness: CGFloat = 5,
		text: String = NSLocalizedString("Common.loading", comment: ""),
		isAnimating: Bool = false
	) {
		self.color = color
		self.size = size
		self.thickness = thickness
		self.text = text
		self.isAnimating = isAnimating
	}

	public var body: some View {
		VStack(alignment: .center, spacing: 8) {
			Circle()
				.trim(from: 0, to: 0.7)
				.stroke(color, style: StrokeStyle(lineWidth: thickness, lineCap: .round, lineJoin: .round))
				.frame(width: size, height: size)
				.rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
				.animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
				.onAppear {
					self.isAnimating = true
				}
				.onDisappear {
					self.isAnimating = false
				}

			Text(text)
				.font(.headline)
				.fontWeight(.regular)
		}
	}
}
