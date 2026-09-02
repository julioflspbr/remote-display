//
//  DisplayView.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 18/08/2026.
//

import SwiftUI

struct DisplayView: View {
	let text: String
	@Bindable private var viewModel = DisplayViewModel()

	var body: some View {
		DisplayTextView(display: viewModel.display)
			.respondToKeyboard()
			.onAppear {
				self.viewModel.setText(self.text)
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
		.background(.displayBackground)
}
