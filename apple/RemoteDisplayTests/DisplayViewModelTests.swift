//
//  DisplayViewModelTests.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 23/08/2026.
//

import Testing
@testable import RemoteDisplay

@Suite
struct DisplayViewModelTests {

	// MARK: - Initial state

	@Test
	func initialState() {
		let sut = DisplayViewModel()

		#expect(sut.text.isEmpty)
	}

	// MARK: - setText

	@Test
	func setTextDisplaysCharacters() {
		let sut = DisplayViewModel()

		sut.setText("Hello")

		#expect(sut.text == "Hello")
		#expect(sut.display.lines[0].cells[0] == .char("H"))
		#expect(sut.display.lines[0].cells[1] == .char("e"))
		#expect(sut.display.lines[0].cells[2] == .char("l"))
		#expect(sut.display.lines[0].cells[3] == .char("l"))
		#expect(sut.display.lines[0].cells[4] == .char("o"))
		#expect(sut.display.lines[0].cells[5] == .cursor)
	}

	@Test
	func setTextPlacesCursor() {
		let sut = DisplayViewModel()

		sut.setText("abc")

		#expect(sut.display.lines[0].cells[3] == .cursor)
	}

	@Test
	func setTextHandlesNewlines() {
		let sut = DisplayViewModel()

		sut.setText("abc\ndef")

		#expect(sut.text == "abc\ndef")

		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .char("c"))
		#expect(sut.display.lines[0].cells[3] == .blank)

		#expect(sut.display.lines[1].cells[0] == .char("d"))
		#expect(sut.display.lines[1].cells[1] == .char("e"))
		#expect(sut.display.lines[1].cells[2] == .char("f"))
		#expect(sut.display.lines[1].cells[3] == .cursor)
	}

	@Test
	func setTextResetsPreviousContents() {
		let sut = DisplayViewModel()

		sut.setText("first")
		sut.setText("second")

		#expect(sut.text == "second")
		#expect(sut.display.lines[0].cells[0] == .char("s"))
		#expect(sut.display.lines[0].cells[1] == .char("e"))
		#expect(sut.display.lines[0].cells[2] == .char("c"))
		#expect(sut.display.lines[0].cells[3] == .char("o"))
		#expect(sut.display.lines[0].cells[4] == .char("n"))
		#expect(sut.display.lines[0].cells[5] == .char("d"))
		#expect(sut.display.lines[0].cells[6] == .cursor)
	}

	@Test
	func setTextIgnoresNonASCIICharacters() {
		let sut = DisplayViewModel()

		sut.setText("a😀b")

		#expect(sut.text == "ab")
		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .cursor)
	}

	// MARK: - insertText

	@Test
	func insertTextAppendsCharacters() {
		let sut = DisplayViewModel()

		sut.setText("Hello")
		sut.insertText(" world")

		#expect(sut.text == "Hello world")

		#expect(sut.display.lines[0].cells[0] == .char("H"))
		#expect(sut.display.lines[0].cells[5] == .char(" "))
		#expect(sut.display.lines[0].cells[10] == .char("d"))
		#expect(sut.display.lines[0].cells[11] == .cursor)
	}

	@Test
	func insertTextHandlesNewlines() {
		let sut = DisplayViewModel()

		sut.setText("abc")
		sut.insertText("\ndef")

		#expect(sut.text == "abc\ndef")

		#expect(sut.display.lines[0].cells[3] == .blank)
		#expect(sut.display.lines[1].cells[0] == .char("d"))
		#expect(sut.display.lines[1].cells[1] == .char("e"))
		#expect(sut.display.lines[1].cells[2] == .char("f"))
		#expect(sut.display.lines[1].cells[3] == .cursor)
	}

	@Test
	func insertTextIgnoresNonASCIICharacters() {
		let sut = DisplayViewModel()

		sut.setText("ab")
		sut.insertText("😀cd")

		#expect(sut.text == "abcd")
		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .char("c"))
		#expect(sut.display.lines[0].cells[3] == .char("d"))
		#expect(sut.display.lines[0].cells[4] == .cursor)
	}

	// MARK: - deleteBackward

	@Test
	func deleteBackwardOnEmptyText() {
		let sut = DisplayViewModel()

		sut.deleteBackward()

		#expect(sut.text.isEmpty)
	}

	@Test
	func deleteBackwardRemovesCharacter() {
		let sut = DisplayViewModel()

		sut.setText("abc")
		sut.deleteBackward()

		#expect(sut.text == "ab")
		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .cursor)
	}

	@Test
	func deleteBackwardRemovesAllCharacters() {
		let sut = DisplayViewModel()

		sut.setText("abc")

		sut.deleteBackward()
		sut.deleteBackward()
		sut.deleteBackward()

		#expect(sut.text.isEmpty)
		#expect(sut.display.lines[0].cells[0] == .cursor)
	}

	@Test
	func deleteBackwardAcrossNewline() {
		let sut = DisplayViewModel()

		sut.setText("abc\ndef")
		sut.deleteBackward()
		sut.deleteBackward()
		sut.deleteBackward()
		sut.deleteBackward()

		#expect(sut.text == "abc")

		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .char("c"))
		#expect(sut.display.lines[0].cells[3] == .cursor)

		#expect(sut.display.lines[1].cells[0] == .blank)
	}

	@Test
	func deleteBackwardRemovesNewline() {
		let sut = DisplayViewModel()

		sut.setText("abc\n")
		sut.deleteBackward()

		#expect(sut.text == "abc")

		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .char("c"))
		#expect(sut.display.lines[0].cells[3] == .cursor)
	}

	// MARK: - Capacity

	@Test
	func setTextRespectsLineCapacity() {
		let sut = DisplayViewModel()
		let input = String(repeating: "a", count: Display.Specs.charCount + 10)

		sut.setText(input)

		#expect(sut.text.count == Display.Specs.charCount)
	}

	@Test
	func setTextRespectsDisplayLineCount() {
		let input = (0..<Display.Specs.lineCount + 5).map { _ in "a" }.joined(separator: "\n")

		let sut = DisplayViewModel()
		sut.setText(input)

		#expect(sut.display.lines.count == Display.Specs.lineCount)
	}

	@Test
	func insertTextRespectsDisplayCapacity() {
		let sut = DisplayViewModel()

		let input = String(
			repeating: "a",
			count: Display.Line.Specs.charCount * Display.Specs.lineCount + 10
		)

		sut.setText(input)

		#expect(
			sut.text.count <=
				Display.Line.Specs.charCount * Display.Specs.lineCount
		)
	}
}
