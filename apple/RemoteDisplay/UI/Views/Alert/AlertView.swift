//
//  AlertView.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 23/09/2026.
//

import SwiftUI

struct AlertView: View {
	@State private var viewModel = AlertViewModel()
	@Environment(\.alertController) private var alertController

	var body: some View {
		AlertTextView(viewModel: $viewModel)
			.onChange(of: alertController, initial: true) {
				self.viewModel.startListningToErrors(in: alertController)
			}
			.onDisappear {
				self.viewModel.stopListeningToErrors()
			}
	}
}

private struct AlertTextView: View {
	@Binding var viewModel: AlertViewModel

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

#Preview("A well-constructed error") {
	@MainActor
	final class PreviewError: LocalizedError, Alert.ErrorWithActions {
		let errorDescription: String? = "This is an error description."
		let failureReason: String? = "Followed by a possible error reason."
		let recoverySuggestion: String? = "And these are some suggestions of how to recover from this error."
		let actions = [
			Alert.Action(
				title: LocalizedStringResource(stringLiteral: "Lalalones"),
				style: .highlighted
			),
			Alert.Action(
				title: LocalizedStringResource(stringLiteral: "Cancel"),
				style: .default
			),
			Alert.Action(
				title: LocalizedStringResource(stringLiteral: "Try again"),
				style: .default
			)
		]
	}

	@Previewable @State var viewModel = AlertViewModel()
	viewModel.setCurrentError(PreviewError())

	return AlertTextView(viewModel: $viewModel)
		.previewBackground()
}

#Preview("A generic error") {
	enum Generic: Error {
		case error
	}

	@Previewable @State var viewModel = AlertViewModel()
	viewModel.setCurrentError(Generic.error)

	return AlertTextView(viewModel: $viewModel)
		.previewBackground()
}
