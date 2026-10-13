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
	private var service: (any Keyboard.Service)?
	private let subscriptions = Mutex<Set<AsyncStream<Keyboard.Action>.Continuation>>([])
	private var isShowingKeyboard = false

	deinit {
		self.subscriptions.withLock { continuations in
			for continuation in continuations {
				continuation.finish()
			}
		}
	}

	var canShowKeyboard: Bool = false {
		didSet {
			if !self.canShowKeyboard {
				self.service?.hideKeyboard()
				self.isShowingKeyboard = false
			}
		}
	}

	var actions: AsyncStream<Keyboard.Action> {
		AsyncStream { continuation in
			self.subscriptions.withLock { subscriptions -> Void in
				subscriptions.insert(continuation)
			}
			continuation.onTermination = { [weak self] _ in
				self?.subscriptions.withLock { subscriptions -> Void in
					subscriptions.remove(continuation)
				}
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

	func insertText(_ text: String) {
		guard !text.isEmpty else {
			return
		}
		for client in *self.subscriptions {
			client.yield(.text(text))
		}
	}

	func deleteBackward() {
		for client in *self.subscriptions {
			client.yield(.backspace)
		}
	}
}

extension KeyboardController: @MainActor Equatable {
	static func == (lhs: KeyboardController, rhs: KeyboardController) -> Bool {
		lhs === rhs
	}
}

