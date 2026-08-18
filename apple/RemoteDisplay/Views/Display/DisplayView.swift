//
//  DisplayView.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 18/08/2026.
//

import SwiftUI

struct DisplayView: View {
	@Binding var text: String
	@Bindable private var viewModel = DisplayViewModel()

	var body: some View {
		DisplayTextView(display: viewModel.display)
			.respondToKeyboard(
				insertText: viewModel.insertText,
				deleteBackward: viewModel.deleteBackward
			)
			.onAppear {
				self.viewModel.setText(self.text)
			}
			.onChange(of: viewModel.text) {
				self.text = self.viewModel.text
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
	@Previewable @State var text: String = "This is my\nMESSAGE TO YOU!"
	DisplayView(text: $text)
		.padding(20)
		.background(.displayBackground)
}
