//
//  KeyboardController.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 01/09/2026.
//

import Foundation

@MainActor
final class KeyboardController {
	private var service: (any Keyboard.Service)?
	private var subscriptions: [UUID: any Keyboard.Client] = [:]
	private var isShowingKeyboard = false

	var canShowKeyboard: Bool = false {
		didSet {
			if !self.canShowKeyboard {
				self.service?.hideKeyboard()
				self.isShowingKeyboard = false
			}
		}
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

	func subscribe(client: any Keyboard.Client) {
		self.subscriptions[client.id] = client
	}

	func unsubscribe(client: any Keyboard.Client) {
		self.subscriptions.removeValue(forKey: client.id)
	}

	func insertText(_ text: String) {
		guard !text.isEmpty else {
			return
		}
		for client in self.subscriptions.values {
			client.receive(action: .text(text))
		}
	}

	func deleteBackward() {
		for client in self.subscriptions.values {
			client.receive(action: .backspace)
		}
	}
}

extension KeyboardController: @MainActor Equatable {
	static func == (lhs: KeyboardController, rhs: KeyboardController) -> Bool {
		lhs === rhs
	}
}

