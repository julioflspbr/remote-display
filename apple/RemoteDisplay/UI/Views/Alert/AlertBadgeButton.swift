//
//  AlertBadgeButton.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 08/10/2026.
//

import SwiftUI

struct AlertBadgeButton: View {
	@Environment(\.alertController) private var alertController
	@State private var viewModel = AlertBadgeViewModel()

	var body: some View {
		AlertBadgeContent(viewModel: $viewModel)
			.frame(width: 30, height: 30)
			.onChange(of: alertController, initial: true) {
				self.viewModel.startListeningToAlertCount(in: alertController)
			}
			.onDisappear {
				self.viewModel.stopListeningToAlertCount()
			}
	}
}

private struct AlertBadgeContent: View {
	@Binding var viewModel: AlertBadgeViewModel

	var body: some View {
		VStack {
			viewModel.alertCount.image
				.resizable()
				.scaledToFit()
				.padding(5)
				.foregroundStyle(viewModel.isPressed.foregroundColor)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.aspectRatio(1, contentMode: .fit)
		.background {
			RoundedRectangle(cornerRadius: 2)
				.fill(viewModel.isPressed.fillColor)
				.stroke(viewModel.isPressed.strokeColor, lineWidth: 1)
		}
	}
}

private extension Int {
	var image: Image {
		switch self {
			case 0:
				.Alert.empty
			case 1:
				.Alert.one
			default:
				.Alert.many
		}
	}
}

private extension Bool {
	var foregroundColor: Color {
		switch self {
			case false:
				.accent
			case true:
				.Display.displayBackground
		}
	}

	var fillColor: Color {
		switch self {
			case false:
				.clear
			case true:
				.accent
		}
	}

	var strokeColor: Color {
		switch self {
			case false:
				.accent
			case true:
				.clear
		}
	}
}

#Preview {
	@Previewable @State var viewModel0Released = AlertBadgeViewModel(alertCount: 0, isPressed: false)
	@Previewable @State var viewModel1Released = AlertBadgeViewModel(alertCount: 1, isPressed: false)
	@Previewable @State var viewModelManyReleased = AlertBadgeViewModel(alertCount: 2, isPressed: false)

	@Previewable @State var viewModel0Pressed = AlertBadgeViewModel(alertCount: 0, isPressed: true)
	@Previewable @State var viewModel1Pressed = AlertBadgeViewModel(alertCount: 1, isPressed: true)
	@Previewable @State var viewModelManyPressed = AlertBadgeViewModel(alertCount: 2, isPressed: true)

	VStack {
		HStack {
			AlertBadgeContent(viewModel: $viewModel0Released)
				.frame(width: 30, height: 30)

			AlertBadgeContent(viewModel: $viewModel1Released)
				.frame(width: 30, height: 30)

			AlertBadgeContent(viewModel: $viewModelManyReleased)
				.frame(width: 30, height: 30)
		}
		HStack {
			AlertBadgeContent(viewModel: $viewModel0Pressed)
				.frame(width: 30, height: 30)

			AlertBadgeContent(viewModel: $viewModel1Pressed)
				.frame(width: 30, height: 30)

			AlertBadgeContent(viewModel: $viewModelManyPressed)
				.frame(width: 30, height: 30)
		}
	}
	.previewBackground()
}
