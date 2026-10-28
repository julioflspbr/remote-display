//
//  KeyboardController.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 01/09/2026.
//

import Foundation
import Synchronization

@MainActor
final class KeyboardController {
	private let streamer = Multicast.Streamer<Keyboard.Action>()
	private var service: (any Keyboard.Service)?
	private var isShowingKeyboard = false

	var canShowKeyboard: Bool = false {
		didSet {
			if !self.canShowKeyboard {
				self.service?.hideKeyboard()
				self.isShowingKeyboard = false
			}
		}
	}

	var actions: Multicast.Stream<Keyboard.Action> {
		self.streamer.makeStream()
	}

	func toggleKeyboard() {
		guard let service, self.canShowKeyboard else {
			return
		}
		if self.isShowingKeyboard {
			service.hideKeyboard()
			self.isShowingKeyboard = false
		} else {
			service.showKeyboard()
			self.isShowingKeyboard = true
		}
	}

	func setService(_ service: any Keyboard.Service) {
		self.service = service
	}

	func insertText(_ text: String) {
		guard !text.isEmpty else {
			return
		}
		self.streamer.send(value: .text(text))
	}

	func deleteBackward() {
		self.streamer.send(value: .backspace)
	}
}

extension KeyboardController: @MainActor Equatable {
	static func == (lhs: KeyboardController, rhs: KeyboardController) -> Bool {
		lhs === rhs
	}
}

