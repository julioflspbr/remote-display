//
//  DisplayController.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 22/08/2026.
//

import SwiftUI

@Observable @MainActor
final class DisplayViewModel: Keyboard.Client {
	let id	= UUID()
	private weak var keyboardController: KeyboardController?
	private var positions: [Int] = [] // current position for each line

	private(set) var display = Display()

	func setKeyboardController(_ controller: KeyboardController?) {
		controller?.subscribe(client: self)
		self.keyboardController = controller
	}

	func unsetKeyboardController() {
		self.keyboardController?.unsubscribe(client: self)
	}

	func setText(_ text: String) {
		self.positions = []
		self.display = Display()
		self.insertText(text)
	}

	func receive(action: Keyboard.Action) {
		switch action {
			case let .text(text):
				self.insertText(text)
			case .backspace:
				self.deleteBackward()
		}
	}

	private var currentCell: Display.Line.Cell {
		get {
			self.display.lines[self.positions.lastIndex].cells[self.positions.last]
		}
		set {
			self.display.lines[self.positions.lastIndex].cells[self.positions.last] = newValue
		}
	}

	private func deleteBackward() {
		guard !positions.isEmpty && positions[0] > 0 else {
			return
		}

		if self.positions.last < Display.Line.Specs.charCount {
			currentCell = .blank
		}
		self.positions.last -= 1
		if self.positions.last < 0 {
			self.positions.removeLast()
			if self.positions.last >= Display.Line.Specs.charCount {
				self.positions.last = Display.Line.Specs.charCount - 1
			}
		}
		if self.positions.lastIndex < Display.Specs.lineCount && self.positions.last < Display.Line.Specs.charCount {
			currentCell = .cursor
		}
	}

	private func insertText(_ text: String) {
		if self.positions.isEmpty {
			self.positions.append(0)
		}
		for c in text {
			if c.isNewline {
				if self.positions.count < Display.Specs.lineCount && self.positions.last > 0 {
					currentCell = .blank
					self.positions.append(0)
				}
			} else if c.isASCII {
				guard self.positions.lastIndex < Display.Specs.lineCount && self.positions.last < Display.Line.Specs.charCount else {
					break
				}
				currentCell = .char(c)
				self.positions.last += 1
				if self.positions.last >= Display.Line.Specs.charCount && self.positions.count < Display.Specs.lineCount {
					self.positions.append(0)
				}
			}
		}
		if self.positions.lastIndex < Display.Specs.lineCount && self.positions.last < Display.Line.Specs.charCount {
			currentCell = .cursor
		}
	}
}

private extension Array {
	var last: Element {
		get {
			self[self.count - 1]
		}
		set {
			self[self.count - 1] = newValue
		}
	}
	var lastIndex: Index {
		self.count - 1
	}
}
