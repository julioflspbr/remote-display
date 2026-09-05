//
//  CharacterViewModelTests.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 23/08/2026.
//

import Testing
import Foundation
@testable import RemoteDisplay

@Suite @MainActor
struct CharacterViewModelTests {
	@Test
	func characterBlink() async throws {
		// given
		let sut = CharacterViewModel(blinkInterval: .milliseconds(50))

		// when
		sut.blink()

		// then
		try await Task.sleep(for: .milliseconds(10)) // just puth the blinker and tests out of phase
		#expect(sut.showCursor, "Blinking should start with cursor visible")

		try await Task.sleep(for: .milliseconds(50))
		#expect(!sut.showCursor, "Blinking should hide cursor after the defined blink interval")

		try await Task.sleep(for: .milliseconds(50))
		#expect(sut.showCursor, "Blinking should show cursor after the defined blink interval")
	}

	@Test
	func characterSteady() async throws {
		// given
		let sut =  CharacterViewModel(blinkInterval: .milliseconds(50))
		sut.blink()

		// when
		sut.steady()

		// then
		try await Task.sleep(for: .milliseconds(70))
		#expect(!sut.showCursor, "Blinking should not change when calling steady")
	}
}
