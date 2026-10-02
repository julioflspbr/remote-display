//
//  DisplayView.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 18/08/2026.
//

import SwiftUI

struct DisplayView: View {
	let text: String
	@State private var viewModel = DisplayViewModel()
	@Environment(\.keyboardController) private var keyboardController

	var body: some View {
		DisplayTextView(display: viewModel.display)
			.respondToKeyboard(controller: keyboardController)
			.onAppear {
				self.viewModel.setText(self.text)
			}
			.onChange(of: keyboardController, initial: true) {
				self.viewModel.setKeyboardController(keyboardController)
			}
			.onDisappear {
				self.viewModel.unsetKeyboardController()
			}
	}
}

private struct DisplayTextView: View {
	let display: Display

	var body: some View {
		VStack(spacing: 5) {
			ForEach(display.lines.enumerated(), id: \.offset) { _, line in
				LineView(line: line)
			}
		}
	}
}

private struct LineView: View {
	let line: Display.Line

	var body: some View {
		HStack(spacing: 5) {
			ForEach(line.cells.enumerated(), id: \.offset) { _, cell in
				CharacterView(cell: cell)
			}
		}
	}
}

#Preview {
	DisplayView(text: "This is my\nMESSAGE TO YOU!")
		.padding(20)
		.previewBackground()
		.environment(\.keyboardController, KeyboardController())
}
