//
//  KeyboardControlerTests.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 02/09/2026.
//

import Testing
import Foundation
import Synchronization
@testable import RemoteDisplay

@Suite @MainActor
struct KeyboardControllerTests {
	@Test("toggle keyboard when controller allows it")
	func toggleKeyboardWhenAllowed() {
		// given
		let service = MockKeyboardService(isKeyboardVisible: false)
		let sut = KeyboardController()
		sut.setService(service)

		// when
		sut.canShowKeyboard = true
		sut.toggleKeyboard()
		// then
		#expect(service.isKeyboardVisible, "The keyboard should be visible on first toggle")

		// when
		sut.toggleKeyboard()
		// then
		#expect(!service.isKeyboardVisible, "The keyboard should be hidden on second toggle")
	}

	@Test("controller does not allow keyboard toggling")
	func toggleKeyboardNotAllowed() {
		// given
		let service = MockKeyboardService(isKeyboardVisible: false)
		let sut = KeyboardController()
		sut.setService(service)

		// when
		sut.canShowKeyboard = false
		sut.toggleKeyboard()

		// then
		#expect(!service.isKeyboardVisible, "The keyboard should not be toggled when not allowed")
	}

	@Test("canShoKeyboard automatically hides the keyboard when set to false")
	func canShowKeyboardHidesKeyboard() {
		// given
		let service = MockKeyboardService(isKeyboardVisible: true)
		let sut = KeyboardController()
		sut.setService(service)

		// when
		sut.canShowKeyboard = true
		sut.toggleKeyboard()
		// then
		#expect(service.isKeyboardVisible, "The keyboard should be visible on first toggle")

		// when
		sut.canShowKeyboard = false

		// then
		#expect(!service.isKeyboardVisible, "The keyboard should be hidden when canShowKeyboard is set to false")
	}

	@Test("multiple subscribers receive the same actions and in sequence")
	func multipleSubscribersReceiveTextInSequence() async {
		// given
		var sut: KeyboardController? = KeyboardController()
		let client1 = await MockKeyboardClient(keyboardController: sut)
		let client2 = await MockKeyboardClient(keyboardController: sut)

		// when
		sut?.insertText("ab")
		sut?.insertText("c")
		sut?.deleteBackward()
		sut?.insertText("")
		sut?.deleteBackward()
		sut = nil

		// then
		await client1.thatsIt()
		await client2.thatsIt()

		let expectedActions: [Keyboard.Action] = [.text("ab"), .text("c"), .backspace, .backspace]
		#expect(await client1.actions == expectedActions, "Client 1 should receive the same actions in the same order")
		#expect(await client2.actions == expectedActions, "Client 2 should receive the same actions in the same order")
	}
}

private final class MockKeyboardService: Keyboard.Service {
	var isKeyboardVisible: Bool

	init(isKeyboardVisible: Bool) {
		self.isKeyboardVisible = isKeyboardVisible
	}

	func showKeyboard() {
		self.isKeyboardVisible = true
	}

	func hideKeyboard() {
		self.isKeyboardVisible = false
	}
}

private actor MockKeyboardClient {
	private(set) var actions: [Keyboard.Action] = []
	private(set) var isListening = false

	init(keyboardController: KeyboardController!) async {
		let actionStream = await keyboardController.actions
		Task {
			self.setListening(true)
			for await action in actionStream {
				self.appendAction(action)
			}
			self.setListening(false)
		}
		while !isListening {
			try? await Task.waitForNextFrame()
		}
	}

	func thatsIt() async {
		while isListening {
			try? await Task.waitForNextFrame()
		}
	}

	private func setListening(_ isListening: Bool) {
		self.isListening = isListening
	}

	private func appendAction(_ action: Keyboard.Action) {
		self.actions.append(action)
	}
 }

private extension Keyboard.Action {
	var text: String? {
		guard case let .text(text) = self else {
			return nil
		}
		return text
	}

	var isBackspace: Bool {
		if case .backspace = self {
			true
		} else {
			false
		}
	}
}

extension Keyboard.Action: @retroactive Equatable {
	public static func == (lhs: Keyboard.Action, rhs: Keyboard.Action) -> Bool {
		switch (lhs, rhs) {
			case let (.text(ltext), .text(rtext)):
				return ltext == rtext
			case (.backspace, .backspace):
				return true
			default:
				return false
		}
	}
}
