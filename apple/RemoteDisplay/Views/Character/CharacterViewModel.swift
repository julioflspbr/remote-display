//
//  CharacterViewModel.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 22/08/2026.
//

import SwiftUI

@Observable
final class CharacterViewModel {
	private(set) var showCursor: Bool = true
	private var blinkTimer: Timer?

	func blink() {
		blinkTimer?.invalidate()
		blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
			self?.showCursor.toggle()
		}
	}

	deinit {
		blinkTimer?.invalidate()
	}
}
