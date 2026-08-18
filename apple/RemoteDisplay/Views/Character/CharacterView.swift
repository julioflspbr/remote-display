//
//  CharacterView.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 17/08/2026.
//

import SwiftUI

struct CharacterView: View {
	let cell: Display.Line.Cell

	@State private var viewModel = CharacterViewModel()
	@State private var parentSize: CGSize = .zero
	@State private var textSize: CGSize = .zero

	var body: some View {
		Text(LocalizedStringResource(unicodeScalarLiteral: "\(characterOrCursor)"))
			.font(.display)
			.foregroundStyle(.character)
			.aspectRatio(5/8, contentMode: .fit)
			.background(.characterBackground)
			.onChange(of: cell, initial: true, manageBlinking)
	}

	var characterOrCursor: Character {
		switch self.cell {
			case let .char(character):
				character
			case .blank:
				" "
			case .cursor:
				self.viewModel.showCursor ? "_" : " "
		}
	}

	private func manageBlinking() {
		if case .cursor = cell {
			self.viewModel.blink()
		}
	}
}

#Preview {
	CharacterView(cell: .cursor)
		.frame(width: 50, height: 80)
		.padding()
		.background(.displayBackground)
}
