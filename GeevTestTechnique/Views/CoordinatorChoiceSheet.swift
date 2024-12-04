//
//  CoordinatorChoiceSheet.swift
//  GeevTestTechnique
//
//  Created by Julien Cholin on 28/11/2024.
//

import SwiftUI

struct CoordinatorChoiceSheet: View {
	let onSelectSwiftUI: () -> Void
	let onSelectUIKit: () -> Void

	var body: some View {
		VStack(spacing: 20) {
			Text("RootView.coordinator.choice")
				.font(.largeTitle)
				.fontWeight(.bold)
				.multilineTextAlignment(.center)
				.padding()

			button(
				text: "SwiftUI",
				systemName: "swift",
				color: .orange,
				action: onSelectSwiftUI
			)
			.frame(width: UIScreen.main.bounds.width * 0.8)

			button(
				text: "UIKit",
				systemName: "square.stack.3d.up.fill",
				color: .blue,
				action: onSelectUIKit
			)
			.frame(width: UIScreen.main.bounds.width * 0.8)
		}
		.padding(24)
	}

	private func button(text: String, systemName: String, color: Color, action: @escaping () -> Void) -> Button<some View> {
		return Button(action: action) {
			VStack(alignment: .center, spacing: 8) {
				Image(systemName: systemName)
					.font(Font.system(size: 60, weight: .bold))
					.foregroundStyle(.white)

				Text(text)
					.font(.largeTitle)
					.foregroundColor(.white)
					.frame(maxWidth: .infinity)
			}
			.frame(minHeight: 130)
			.padding()
			.background(color)
			.cornerRadius(10)
			.shadow(color: color.opacity(1), radius: 8, x: 0, y: 2)
			.shadow(color: .white.opacity(1), radius: 4, x: 0, y: 2)
		}
	}
}
