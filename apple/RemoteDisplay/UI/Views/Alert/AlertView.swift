//
//  AlertView.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 23/09/2026.
//

import SwiftUI

struct AlertView: View {
	let error: LocalizedError
	let actions: [Alert.Action]

	init(error: LocalizedError, actions: [Alert.Action]) {
		self.error = error
		self.actions = actions.adjusted
	}

	var body: some View {
		VStack {
			Text(error.localizedDescription + "\n" + (error.recoverySuggestion ?? ""))
				.foregroundColor(Color.Display.character)
				.font(.alert)
				.padding(.vertical)

			HStack(alignment: .center) {
				ForEach(actions) { action in
					AlertButton(style: action.style, title: action.title, action: action.action)
				}
			}
		}
	}
}

private extension Array where Element == Alert.Action {
	var adjusted: Self {
		var adjusting = self
		var preselectedIndex: Int?

		for (i, action) in self.enumerated().reversed() {
			if preselectedIndex == nil && action.style == .highlighted {
				preselectedIndex = i
			} else if action.style == .highlighted {
				adjusting[i] = Element(
					title: action.title,
					style: .default,
					action: action.action
				)
			}
		}
		if let preselectedIndex {
			let preselected = adjusting.remove(at: preselectedIndex)
			adjusting.append(preselected)
		}
		return adjusting
	}
}

#Preview {
	final class PreviewError: LocalizedError {
		let errorDescription: String?
		let recoverySuggestion: String?
		init() {
			errorDescription = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam eleifend tempor auctor. Mauris ac congue mi."
			recoverySuggestion = "Pellentesque ullamcorper id quam nec mollis. Nulla id urna ligula. Nullam fermentum vulputate tellus."
		}
	}

	let actions: [Alert.Action] = [
		.init(title: "Cancel", style: .highlighted) { },
		.init(title: "Opa") { },
		.init(title: "Retry") { }
	]

	return AlertView(error: PreviewError(), actions: actions)
		.previewBackground()
}
