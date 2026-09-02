//
//  KeyboardController.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 01/09/2026.
//

extension Keyboard {
	@MainActor
	final class Controller {
		private var subscriptions: Set<AsyncStream<Keyboard.Action>.Continuation> = []
		private func removeSubscription(_ subscription: AsyncStream<Keyboard.Action>.Continuation) {
			subscriptions.remove(subscription)
		}

		deinit {
			for subscription in self.subscriptions {
				subscription.finish()
			}
		}
	}
}

extension Keyboard.Controller: Keyboard.Receiver {
	func insertText(_ text: String) {
		guard !text.isEmpty else {
			return
		}
		for subscription in self.subscriptions {
			subscription.yield(.text(text))
		}
	}

	func deleteBackward() {
		for subscription in self.subscriptions {
			subscription.yield(.backspace)
		}
	}
}

extension Keyboard.Controller: Keyboard.Forwarder {
	var keyboardAction: AsyncStream<Keyboard.Action> {
		AsyncStream<Keyboard.Action> { continuation in
			self.subscriptions.insert(continuation)
			continuation.onTermination = { _ in
				Task {
					await self.removeSubscription(continuation)
				}
			}
		}
	}

	func endActionStream() {
		for subscription in self.subscriptions {
			subscription.finish()
		}
		subscriptions.removeAll()
	}
}
