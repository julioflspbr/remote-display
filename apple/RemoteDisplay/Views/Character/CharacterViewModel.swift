//
//  CharacterViewModel.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 22/08/2026.
//

import SwiftUI

@Observable
final class CharacterViewModel: Sendable {
	private let blinkInterval: TimeInterval
	private(set) var showCursor: Bool = true
	private var blinkTimer: Timer?

	init(blinkInterval: TimeInterval = 0.5) {
		self.blinkInterval = blinkInterval
	}

	func blink() {
		blinkTimer?.invalidate()
		blinkTimer = Timer.scheduledTimer(withTimeInterval: self.blinkInterval, repeats: true) { [weak self] _ in
			self?.showCursor.toggle()
		}
	}

	func steady() {
		blinkTimer?.invalidate()
		blinkTimer = nil
		showCursor = false
	}

	deinit {
		blinkTimer?.invalidate()
	}
}
