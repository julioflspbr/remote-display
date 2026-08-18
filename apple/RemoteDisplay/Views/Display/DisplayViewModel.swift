//
//  DisplayController.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 22/08/2026.
//

import SwiftUI

@Observable
final class DisplayViewModel {
	typealias Position = (line: Int, cell: Int)

	@ObservationIgnored private var positions: [Int] = [] // current position for each line

	private(set) var text = ""
	private(set) var display = Display()

	func setText(_ text: String) {
		self.positions = []
		self.text = self.fillUpDisplay(text: text)
	}

	func insertText(_ text: String) {
		self.text.append(self.fillUpDisplay(text: text))
	}

	func deleteBackward() {
		guard !self.text.isEmpty else {
			return
		}

		let c = self.text.removeLast()
		if c.isNewline {
			self.display.lines[self.positions.lastIndex].cells[0] = .blank
			self.positions.removeLast()
		} else {
			if self.positions.last < Display.Line.Specs.charCount {
				self.display.lines[self.positions.lastIndex].cells[self.positions.last] = .blank
			}
			self.positions.last -= 1
			if self.positions.last < 0 {
				self.positions.removeLast()
				self.positions.last -= 1
			}
		}
		if self.positions.lastIndex < Display.Specs.lineCount && self.positions.last < Display.Line.Specs.charCount {
			self.display.lines[self.positions.lastIndex].cells[self.positions.last] = .cursor
		}
	}

	private func fillUpDisplay(text: String) -> String {
		if self.positions.isEmpty {
			self.positions.append(0)
		}
		var result = ""
		for c in text {
			if c.isNewline {
				if self.positions.count < Display.Specs.lineCount {
					result += String(c)
					self.display.lines[self.positions.lastIndex].cells[self.positions.last] = .blank
					self.positions.append(0)
				}
			} else if c.isASCII {
				guard self.positions.lastIndex < Display.Specs.lineCount && self.positions.last < Display.Line.Specs.charCount else {
					break
				}
				result += String(c)
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
		return result
	}
}

private extension Array where Index == Int {
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
