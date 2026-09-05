//
//  DisplayViewModelTests.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 23/08/2026.
//

import Testing
@testable import RemoteDisplay

@Suite @MainActor
struct DisplayViewModelTests {

	// MARK: - setText

	@Test
	func setTextDisplaysCharacters() {
		let sut = DisplayViewModel(dependencies: .mock())

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
		let sut = DisplayViewModel(dependencies: .mock())

		sut.setText("abc")

		#expect(sut.display.lines[0].cells[3] == .cursor)
	}

	@Test
	func setTextHandlesNewlines() {
		let sut = DisplayViewModel(dependencies: .mock())

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
		let sut = DisplayViewModel(dependencies: .mock())

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
		let sut = DisplayViewModel(dependencies: .mock())

		sut.setText("a😀b")

		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .cursor)
	}

	// MARK: - insertText

	@Test
	func insertTextAppendsCharacters() async {
		let semaphore = TestSemaphore()
		let keyboard = Keyboard.Controller()
		let subscriptionContext = makeKeyEventSubscriptionContext(semaphore: semaphore)
		let sut = DisplayViewModel(dependencies: .mock(keyEvents: keyboard, keyEventSubscriptionContext: subscriptionContext))

		await semaphore.wait()
		sut.setText("Hello")
		keyboard.insertText(" world")
		keyboard.endActionStream()
		await semaphore.wait()

		#expect(sut.display.lines[0].cells[0] == .char("H"))
		#expect(sut.display.lines[0].cells[5] == .char(" "))
		#expect(sut.display.lines[0].cells[10] == .char("d"))
		#expect(sut.display.lines[0].cells[11] == .cursor)
	}

	@Test
	func insertTextHandlesNewlines() async {
		let semaphore = TestSemaphore()
		let keyboard = Keyboard.Controller()
		let subscriptionContext = makeKeyEventSubscriptionContext(semaphore: semaphore)
		let sut = DisplayViewModel(dependencies: .mock(keyEvents: keyboard, keyEventSubscriptionContext: subscriptionContext))

		await semaphore.wait()
		sut.setText("abc")
		keyboard.insertText("\ndef")
		keyboard.endActionStream()
		await semaphore.wait()

		#expect(sut.display.lines[0].cells[3] == .blank)
		#expect(sut.display.lines[1].cells[0] == .char("d"))
		#expect(sut.display.lines[1].cells[1] == .char("e"))
		#expect(sut.display.lines[1].cells[2] == .char("f"))
		#expect(sut.display.lines[1].cells[3] == .cursor)
	}

	@Test
	func insertTextIgnoresNonASCIICharacters() async {
		let semaphore = TestSemaphore()
		let keyboard = Keyboard.Controller()
		let subscriptionContext = makeKeyEventSubscriptionContext(semaphore: semaphore)
		let sut = DisplayViewModel(dependencies: .mock(keyEvents: keyboard, keyEventSubscriptionContext: subscriptionContext))

		await semaphore.wait()
		sut.setText("ab")
		keyboard.insertText("😀cd")
		keyboard.endActionStream()
		await semaphore.wait()

		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .char("c"))
		#expect(sut.display.lines[0].cells[3] == .char("d"))
		#expect(sut.display.lines[0].cells[4] == .cursor)
	}

	// MARK: - deleteBackward

	@Test
	func deleteBackwardRemovesCharacter() {
		let keyboard = Keyboard.Controller()
		let sut = DisplayViewModel(dependencies: .mock(keyEvents: keyboard))

		sut.setText("abc")
		sut.deleteBackward()

		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .cursor)
	}

	@Test
	func deleteBackwardRemovesAllCharacters() {
		let keyboard = Keyboard.Controller()
		let sut = DisplayViewModel(dependencies: .mock(keyEvents: keyboard))

		sut.setText("abc")

		sut.deleteBackward()
		sut.deleteBackward()
		sut.deleteBackward()

		#expect(sut.display.lines[0].cells[0] == .cursor)
	}

	@Test
	func deleteBackwardAcrossNewline() {
		let keyboard = Keyboard.Controller()
		let sut = DisplayViewModel(dependencies: .mock(keyEvents: keyboard))

		sut.setText("abc\ndef")
		sut.deleteBackward()
		sut.deleteBackward()
		sut.deleteBackward()
		sut.deleteBackward()

		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .char("c"))
		#expect(sut.display.lines[0].cells[3] == .cursor)

		#expect(sut.display.lines[1].cells[0] == .blank)
	}

	@Test
	func deleteBackwardAcrossLineBreak() {
		let keyboard = Keyboard.Controller()
		let sut = DisplayViewModel(dependencies: .mock(keyEvents: keyboard))

		// i is the 9th char that goes to the next line
		sut.setText("abcdefghijk")
		sut.deleteBackward()
		sut.deleteBackward()
		sut.deleteBackward()
		sut.deleteBackward()

		#expect(sut.display.lines[0].cells[4] == .char("e"))
		#expect(sut.display.lines[0].cells[5] == .char("f"))
		#expect(sut.display.lines[0].cells[6] == .char("g"))
		#expect(sut.display.lines[0].cells[7] == .cursor)

		#expect(sut.display.lines[1].cells[0] == .blank)
	}

	@Test
	func deleteBackwardRemovesNewline() {
		let keyboard = Keyboard.Controller()
		let sut = DisplayViewModel(dependencies: .mock(keyEvents: keyboard))

		sut.setText("abc\n")
		sut.deleteBackward()

		#expect(sut.display.lines[0].cells[0] == .char("a"))
		#expect(sut.display.lines[0].cells[1] == .char("b"))
		#expect(sut.display.lines[0].cells[2] == .char("c"))
		#expect(sut.display.lines[0].cells[3] == .cursor)
	}

	private func makeKeyEventSubscriptionContext(semaphore: TestSemaphore) -> DisplayViewModel.Dependencies.Subscription {
		{ subscription in
			Task {
				await semaphore.signal()
				await subscription()
				await semaphore.signal()
			}
		}
	}
}

private extension DisplayViewModel.Dependencies {
	static func mock(
		keyEvents: Keyboard.Controller = .init(),
		keyEventSubscriptionContext: @escaping Subscription = { operation in
			Task<Void, Never>(operation: operation)
		}
	) -> DisplayViewModel.Dependencies {
		.init(
			keyEvents: keyEvents,
			keyEventSubscriptionContext: keyEventSubscriptionContext
		)
	}
}
