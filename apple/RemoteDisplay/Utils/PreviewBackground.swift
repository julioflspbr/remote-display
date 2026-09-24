//
//  PreviewBackground.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 24/09/2026.
//

import SwiftUI

extension View {
	func previewBackground(color: Color = .black.opacity(0.2), radius: CGFloat = 0, offset: CGFloat = 2) -> some View {
		modifier(PreviewBackground(color: color, radius: radius, offset: offset))
	}
}

private struct PreviewBackground: ViewModifier {
	let color: Color
	let radius: CGFloat
	let offset: CGFloat

	func body(content: Content) -> some View {
		content
			.shadow(color: self.color, radius: self.radius, x: self.offset, y: self.offset)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(Color.Display.displayBackground)
	}
}
