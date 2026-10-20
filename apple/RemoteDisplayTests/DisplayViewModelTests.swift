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
	func `setText displays character`() {
		// given
		let sut = DisplayViewModel()

		// when
		sut.setText("Hello")

		// then
		#expect(sut.display.lines[0].cells[0] == .char("H"))
		#expect(sut.display.lines[0].cells[1] == .char("e"))
		#expect(sut.display.lines[0].cells[2] == .char("l"))
		#expect(sut.display.lines[0].cells[3] == .char("l"))
		#expect(sut.display.lines[0].cells[4] == .char("o"))
		#expect(sut.display.lines[0].cells[5] == .cursor)
	}

	@Test
	func setTextPlacesCursor() {
		// given
		let sut = DisplayViewModel()

		// when
		sut.setText("abc")

		// then
		#expect(sut.display.lines[0].cells[3] == .cursor)
	}

	@Test
	func `setText handles new lines`() {
		// given
		let sut = DisplayViewModel()

		// when
		sut.setText("abc\ndef")

		// then
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
	func `setText resets previous contents`() {
		// given
		let sut = DisplayViewModel()

		// when
		sut.setText("first")
		sut.setText("second")

		// then
		#expect(sut.display.lines[0].cells[0] == .char("s"))
		#expect(sut.display.lines[0].cells[1] == .char("e"))
		#expect(sut.display.lines[0].cells[2] == .char("c"))
		#expect(sut.display.lines[0].cells[3] == .char("o"))
		#expect(sut.display.lines[0].cells[4] == .char("n"))
		#expect(sut.display.lines[0].cells[5] == .char("d"))
		#expect(sut.display.lines[0].cells[6] == .cursor)
	}

	@Test
	func `setText ignores non-ASCII characters`() {
		// given
		let sut = DisplayViewModel()

		// when
		sut.setText("a😀b")

		// then
		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .cursor)
	}

	// MARK: - insertText

	@Test
	func `insertText appends characters`() async throws {
		//given
		let sut = DisplayViewModel()
		let keyboardController = KeyboardController()
		let subscription = sut.startListeningToKeyboard(in: keyboardController)
		try await Task.waitForNextFrame()

		// when
		sut.setText("Hello")
		keyboardController.insertText(" world")
		sut.stopListeningToKeyboard()
		try await subscription?.waitForTermination()

		// then
		#expect(sut.display.lines[0].cells[0] == .char("H"))
		#expect(sut.display.lines[0].cells[5] == .char(" "))
		#expect(sut.display.lines[0].cells[10] == .char("d"))
		#expect(sut.display.lines[0].cells[11] == .cursor)
	}

	@Test
	func `insertText handles new lines`() async throws {
		// given
		let sut = DisplayViewModel()
		let keyboardController = KeyboardController()
		let subscription = sut.startListeningToKeyboard(in: keyboardController)
		try await Task.waitForNextFrame()

		// when
		sut.setText("abc")
		keyboardController.insertText("\ndef")
		sut.stopListeningToKeyboard()
		try await subscription?.waitForTermination()

		// then
		#expect(sut.display.lines[0].cells[3] == .blank)
		#expect(sut.display.lines[1].cells[0] == .char("d"))
		#expect(sut.display.lines[1].cells[1] == .char("e"))
		#expect(sut.display.lines[1].cells[2] == .char("f"))
		#expect(sut.display.lines[1].cells[3] == .cursor)
	}

	@Test
	func `insertText ignores non-ASCII characters`() async throws {
		// given
		let sut = DisplayViewModel()
		let keyboardController = KeyboardController()
		let subscription = sut.startListeningToKeyboard(in: keyboardController)
		try await Task.waitForNextFrame()

		// when
		sut.setText("ab")
		keyboardController.insertText("😀cd")
		sut.stopListeningToKeyboard()
		try await subscription?.waitForTermination()

		// then
		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .char("c"))
		#expect(sut.display.lines[0].cells[3] == .char("d"))
		#expect(sut.display.lines[0].cells[4] == .cursor)
	}

	// MARK: - deleteBackward

	@Test
	func `deleteBacward removes character`() async throws {
		// given
		let sut = DisplayViewModel()
		let keyboardController = KeyboardController()
		let subscription = sut.startListeningToKeyboard(in: keyboardController)
		try await Task.waitForNextFrame()

		// when
		sut.setText("abc")
		keyboardController.deleteBackward()
		sut.stopListeningToKeyboard()
		try await subscription?.waitForTermination()

		// theb
		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .cursor)
	}

	@Test
	func `deleteBacward removes all characters`() async throws {
		// given
		let sut = DisplayViewModel()
		let keyboardController = KeyboardController()
		let subscription = sut.startListeningToKeyboard(in: keyboardController)
		try await Task.waitForNextFrame()

		// when
		sut.setText("abc")
		keyboardController.deleteBackward()
		keyboardController.deleteBackward()
		keyboardController.deleteBackward()

		sut.stopListeningToKeyboard()
		try await subscription?.waitForTermination()

		// then
		#expect(sut.display.lines[0].cells[0] == .cursor)
	}

	@Test
	func `deleteBackward across new line`() async throws {
		// given
		let sut = DisplayViewModel()
		let keyboardController = KeyboardController()
		let subscription = sut.startListeningToKeyboard(in: keyboardController)
		try await Task.waitForNextFrame()

		// when
		sut.setText("abc\ndef")
		keyboardController.deleteBackward()
		keyboardController.deleteBackward()
		keyboardController.deleteBackward()
		keyboardController.deleteBackward()

		sut.stopListeningToKeyboard()
		try await subscription?.waitForTermination()

		// then
		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .char("c"))
		#expect(sut.display.lines[0].cells[3] == .cursor)

		#expect(sut.display.lines[1].cells[0] == .blank)
	}

	@Test
	func `deleteBackward across line break`() async throws {
		// given
		let sut = DisplayViewModel()
		let keyboardController = KeyboardController()
		let subscription = sut.startListeningToKeyboard(in: keyboardController)
		try await Task.waitForNextFrame()

		// when
		// i is the 9th char that goes to the next line
		sut.setText("abcdefghijk")
		keyboardController.deleteBackward()
		keyboardController.deleteBackward()
		keyboardController.deleteBackward()
		keyboardController.deleteBackward()

		sut.stopListeningToKeyboard()
		try await subscription?.waitForTermination()

		// then
		#expect(sut.display.lines[0].cells[4] == .char("e"))
		#expect(sut.display.lines[0].cells[5] == .char("f"))
		#expect(sut.display.lines[0].cells[6] == .char("g"))
		#expect(sut.display.lines[0].cells[7] == .cursor)

		#expect(sut.display.lines[1].cells[0] == .blank)
	}

	@Test
	func `deleteBackward removes new line`() async throws {
		// given
		let sut = DisplayViewModel()
		let keyboardController = KeyboardController()
		let subscription = sut.startListeningToKeyboard(in: keyboardController)
		try await Task.waitForNextFrame()

		// when
		sut.setText("abc\n")
		keyboardController.deleteBackward()
		sut.stopListeningToKeyboard()
		try await subscription?.waitForTermination()

		// then
		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .char("c"))
		#expect(sut.display.lines[0].cells[3] == .cursor)
	}
}

private extension Task {
	func waitForTermination() async throws {
		do {
			_ = try await self.value
		} catch is CancellationError {
			// terminated, just let it go
		}
	}
}
