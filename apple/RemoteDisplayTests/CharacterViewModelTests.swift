//
//  CharacterViewModelTests.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 23/08/2026.
//

import Testing
import Foundation
@testable import RemoteDisplay

@Suite
struct CharacterViewModelTests {
	@Test
	func characterBlink() async throws {
		// given
		let viewModel = await CharacterViewModel(blinkInterval: 0.05)

		// when
		await viewModel.blink()

		// then
		#expect(viewModel.showCursor, "Blinking should start with cursor visible")

		try await Task.sleep(for: .milliseconds(50))
		#expect(!viewModel.showCursor, "Blinking should hide cursor after the defined blink interval")

		try await Task.sleep(for: .milliseconds(50))
		#expect(viewModel.showCursor, "Blinking should show cursor after the defined blink interval")
	}
}
