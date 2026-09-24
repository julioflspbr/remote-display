//
//  AlertView.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 23/09/2026.
//

import SwiftUI

struct AlertView: View {
	@State private var viewModel: AlertViewModel

	init(initialAlert: Alert?) {
		_viewModel = State(initialValue: AlertViewModel(initialAlert: initialAlert))
	}

	var body: some View {
		if viewModel.isAlerting {
			VStack {
				Text(viewModel.message)
					.foregroundColor(Color.Display.character)
					.font(.alert)
					.padding(.vertical)

				HStack(alignment: .center) {
					ForEach(viewModel.actions) { action in
						AlertActionButton(style: action.style, title: action.title, action: action.action)
					}
				}
			}
		}
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
	let previewAlert = Alert(error: PreviewError(), actions: actions)

	return AlertView(initialAlert: previewAlert)
		.previewBackground()
}
