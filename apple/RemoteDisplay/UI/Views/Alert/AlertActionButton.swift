//
//  AlertButton.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 24/09/2026.
//

import SwiftUI

struct AlertActionButton: View {
	let style: Alert.Action.Style
	let title: LocalizedStringResource
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			Text(title)
				.font(.alert)
				.foregroundStyle(style.foregroundStyle)
				.padding(.vertical, 3)
				.padding(.horizontal)
				.background { style.backgroundContent }
		}
	}
}

private extension Alert.Action.Style {
	var foregroundStyle: any ShapeStyle {
		switch self {
			case .highlighted:
				return Color.Display.displayBackground
			case .default:
				return Color.accent
		}
	}

	var backgroundContent: some View {
		Group {
			switch self {
				case .highlighted:
					RoundedRectangle(cornerRadius: 8)
						.fill(Color.accent)
				case .default:
					RoundedRectangle(cornerRadius: 8)
						.stroke(Color.accent, lineWidth: 1)
			}
		}
	}
}

#Preview {
	HStack {
		AlertActionButton(style: .default, title: "OK") { }
		AlertActionButton(style: .highlighted, title: "Cancel") { }
	}
	.previewBackground()
}
