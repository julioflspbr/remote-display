//
//  DisplayViewModelTests.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 23/08/2026.
//

import Testing
import Foundation
@testable import RemoteDisplay

@Suite @MainActor
struct DisplayViewModelTests {

	// MARK: - setText

	@Test
	func setTextDisplaysCharacters() {
		let sut = DisplayViewModel(keyboardController: EmptyKeyboarController())

		sut.setText("Hello")

		#expect(sut.display.lines[0].cells[0] == .char("H"))
		#expect(sut.display.lines[0].cells[1] == .char("e"))
		#expect(sut.display.lines[0].cells[2] == .char("l"))
		#expect(sut.display.lines[0].cells[3] == .char("l"))
		#expect(sut.display.lines[0].cells[4] == .char("o"))
		#expect(sut.display.lines[0].cells[5] == .cursor)
	}

	@Test
	func setTextPlacesCursor() {
		let sut = DisplayViewModel(keyboardController: EmptyKeyboarController())

		sut.setText("abc")

		#expect(sut.display.lines[0].cells[3] == .cursor)
	}

	@Test
	func setTextHandlesNewlines() {
		let sut = DisplayViewModel(keyboardController: EmptyKeyboarController())

		sut.setText("abc\ndef")

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
		let sut = DisplayViewModel(keyboardController: EmptyKeyboarController())

		sut.setText("first")
		sut.setText("second")

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
		let sut = DisplayViewModel(keyboardController: EmptyKeyboarController())

		sut.setText("a😀b")

		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .cursor)
	}

	// MARK: - insertText

	@Test
	func insertTextAppendsCharacters() {
		let sut = DisplayViewModel(keyboardController: EmptyKeyboarController())

		sut.setText("Hello")
		sut.receive(action: .text(" world"))

		#expect(sut.display.lines[0].cells[0] == .char("H"))
		#expect(sut.display.lines[0].cells[5] == .char(" "))
		#expect(sut.display.lines[0].cells[10] == .char("d"))
		#expect(sut.display.lines[0].cells[11] == .cursor)
	}

	@Test
	func insertTextHandlesNewlines() {
		let sut = DisplayViewModel(keyboardController: EmptyKeyboarController())

		sut.setText("abc")
		sut.receive(action: .text("\ndef"))

		#expect(sut.display.lines[0].cells[3] == .blank)
		#expect(sut.display.lines[1].cells[0] == .char("d"))
		#expect(sut.display.lines[1].cells[1] == .char("e"))
		#expect(sut.display.lines[1].cells[2] == .char("f"))
		#expect(sut.display.lines[1].cells[3] == .cursor)
	}

	@Test
	func insertTextIgnoresNonASCIICharacters() {
		let sut = DisplayViewModel(keyboardController: EmptyKeyboarController())

		sut.setText("ab")
		sut.receive(action: .text("😀cd"))

		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .char("c"))
		#expect(sut.display.lines[0].cells[3] == .char("d"))
		#expect(sut.display.lines[0].cells[4] == .cursor)
	}

	// MARK: - deleteBackward

	@Test
	func deleteBackwardRemovesCharacter() {
		let sut = DisplayViewModel(keyboardController: EmptyKeyboarController())

		sut.setText("abc")
		sut.receive(action: .backspace)

		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .cursor)
	}

	@Test
	func deleteBackwardRemovesAllCharacters() {
		let sut = DisplayViewModel(keyboardController: EmptyKeyboarController())

		sut.setText("abc")
		sut.receive(action: .backspace)
		sut.receive(action: .backspace)
		sut.receive(action: .backspace)

		#expect(sut.display.lines[0].cells[0] == .cursor)
	}

	@Test
	func deleteBackwardAcrossNewline() {
		let sut = DisplayViewModel(keyboardController: EmptyKeyboarController())

		sut.setText("abc\ndef")
		sut.receive(action: .backspace)
		sut.receive(action: .backspace)
		sut.receive(action: .backspace)
		sut.receive(action: .backspace)

		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .char("c"))
		#expect(sut.display.lines[0].cells[3] == .cursor)

		#expect(sut.display.lines[1].cells[0] == .blank)
	}

	@Test
	func deleteBackwardAcrossLineBreak() {
		let sut = DisplayViewModel(keyboardController: EmptyKeyboarController())

		// i is the 9th char that goes to the next line
		sut.setText("abcdefghijk")
		sut.receive(action: .backspace)
		sut.receive(action: .backspace)
		sut.receive(action: .backspace)
		sut.receive(action: .backspace)

		#expect(sut.display.lines[0].cells[4] == .char("e"))
		#expect(sut.display.lines[0].cells[5] == .char("f"))
		#expect(sut.display.lines[0].cells[6] == .char("g"))
		#expect(sut.display.lines[0].cells[7] == .cursor)

		#expect(sut.display.lines[1].cells[0] == .blank)
	}

	@Test
	func deleteBackwardRemovesNewline() {
		let sut = DisplayViewModel(keyboardController: EmptyKeyboarController())

		sut.setText("abc\n")
		sut.receive(action: .backspace)

		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .char("c"))
		#expect(sut.display.lines[0].cells[3] == .cursor)
	}
}

private final class EmptyKeyboarController: Keyboard.Controller {
	var canShowKeyboard: Bool = false

	func insertText(_ text: String) {
	}
	
	func deleteBackward() {
	}
	
	func toggleKeyboard() {
	}
	
	func setService(_ service: any RemoteDisplay.Keyboard.Service) {
	}
	
	func subscribe(client: any RemoteDisplay.Keyboard.Client) {
	}
	
	func unsubscribe(clientID: UUID) {
	}
}
