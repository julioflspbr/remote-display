//
//  KeyboardControlerTests.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 02/09/2026.
//

import Testing
@testable import RemoteDisplay

@Suite
struct KeyboardControllerTests {
	@Test
	func testKeyboardInput() async {
		// given
		let semaphore = TestSemaphore()
		let sut = Keyboard.Controller()

		// when
		let collector = self.makeCollector(sut: sut, semaphore: semaphore)

		await semaphore.wait()
		Task {
			await sut.insertText("ab")
			await sut.insertText("c")
			await sut.endActionStream()
		}

		// then
		let result = await collector.value
		#expect(result.count == 2, "There were 2 valid text inputs, but the result does not contain 2 results")
		#expect(result[0].containedText == "ab", "The first input doesn't match the output")
		#expect(result[1].containedText == "c", "The first input doesn't match the output")
	}

	@Test
	func testBackspaces() async {
		// given
		let semaphore = TestSemaphore()
		let sut = Keyboard.Controller()

		// when
		let collector = self.makeCollector(sut: sut, semaphore: semaphore)

		await semaphore.wait()
		Task {
			await sut.deleteBackward()
			await sut.deleteBackward()
			await sut.deleteBackward()
			await sut.endActionStream()
		}

		// then
		let result = await collector.value
		#expect(result.count == 3, "There were 3 valid backspace inputs, but the result does not contain 3 results")
		#expect(result.allSatisfy({ it in it.isBackspace }), "Not all the inputs were backspaces")
	}

	func makeCollector(sut: Keyboard.Controller, semaphore: TestSemaphore) -> Task<[Keyboard.Action], Never> {
		Task {
			var result = [Keyboard.Action]()
			await semaphore.signal()
			for await input in await sut.keyboardAction {
				result.append(input)
			}
			return result
		}
	}
}

private extension Keyboard.Action {
	var containedText: String? {
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
