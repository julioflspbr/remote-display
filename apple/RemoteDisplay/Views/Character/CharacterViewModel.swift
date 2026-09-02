//
//  CharacterViewModel.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 22/08/2026.
//

import SwiftUI

@Observable @MainActor
final class CharacterViewModel {
	private let blinkInterval: ContinuousClock.Duration

	@ObservationIgnored
	private var blinkTask: Task<Void, any Error>?
	private(set) var showCursor: Bool = true

	init(blinkInterval: ContinuousClock.Duration = .milliseconds(500)) {
		self.blinkInterval = blinkInterval
	}

	func blink() {
		self.blinkTask?.cancel()
		self.blinkTask = Task { @MainActor [weak self] in
			guard let self else {
				return
			}
			try await Task.sleep(for: self.blinkInterval)
			self.showCursor.toggle()
			self.blink()
		}
	}

	func steady() {
		self.blinkTask?.cancel()
		self.blinkTask = nil
		self.showCursor = false
	}

	deinit {
		self.blinkTask?.cancel()
	}
}
