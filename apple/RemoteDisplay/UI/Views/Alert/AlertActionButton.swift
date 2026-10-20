//
//  AlertButton.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 24/09/2026.
//

import SwiftUI

struct AlertActionButton: View {
	let action: Alert.Action

	var body: some View {
		Button {
			Task {
				await action.action()
			}
		} label: {
			Text(action.title)
				.font(.alert)
				.foregroundStyle(action.style.foregroundStyle)
				.padding(.vertical, 3)
				.padding(.horizontal)
				.background { action.style.backgroundContent }
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
		AlertActionButton(action: Alert.Action(title: "OK", style: .default))
		AlertActionButton(action: Alert.Action(title: "Cancel", style: .highlighted))
	}
	.previewBackground()
}
