//
//  DisplayController.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 22/08/2026.
//

import SwiftUI

@Observable @MainActor
final class DisplayViewModel {
	@ObservationIgnored
	private var keyPressTask: Task<Void, Never>!
	private var positions: [Int] = [] // current position for each line

	private(set) var display = Display()

	init(keyEvents: any Keyboard.Forwarder = Keyboard.Controller.shared) {
		self.keyPressTask = Task { @MainActor in
			for await input in keyEvents.keyboardAction {
				switch input {
					case .backspace:
						self.deleteBackward()
					case .text(let text):
						self.insertText(text)
				}
			}
		}
	}

	deinit {
		self.keyPressTask.cancel()
	}

	func setText(_ text: String) {
		self.positions = []
		self.display = Display()
		self.insertText(text)
	}

	func deleteBackward() {
		guard !positions.isEmpty && positions[0] > 0 else {
			return
		}

		if self.positions.last < Display.Line.Specs.charCount {
			self.display.lines[self.positions.lastIndex].cells[self.positions.last] = .blank
		}
		self.positions.last -= 1
		if self.positions.last < 0 {
			self.positions.removeLast()
			if self.positions.last >= Display.Line.Specs.charCount {
				self.positions.last = Display.Line.Specs.charCount - 1
			}
		}
		if self.positions.lastIndex < Display.Specs.lineCount && self.positions.last < Display.Line.Specs.charCount {
			self.display.lines[self.positions.lastIndex].cells[self.positions.last] = .cursor
		}
	}

	private func insertText(_ text: String) {
		if self.positions.isEmpty {
			self.positions.append(0)
		}
		for c in text {
			if c.isNewline {
				if self.positions.count < Display.Specs.lineCount && self.positions.last > 0 {
					self.display.lines[self.positions.lastIndex].cells[self.positions.last] = .blank
					self.positions.append(0)
				}
			} else if c.isASCII {
				guard self.positions.lastIndex < Display.Specs.lineCount && self.positions.last < Display.Line.Specs.charCount else {
					break
				}
				self.display.lines[self.positions.lastIndex].cells[self.positions.last] = .char(c)
				self.positions.last += 1
				if self.positions.last >= Display.Line.Specs.charCount && self.positions.count < Display.Specs.lineCount {
					self.positions.append(0)
				}
			}
		}
		if self.positions.lastIndex < Display.Specs.lineCount && self.positions.last < Display.Line.Specs.charCount {
			self.display.lines[self.positions.lastIndex].cells[self.positions.last] = .cursor
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
