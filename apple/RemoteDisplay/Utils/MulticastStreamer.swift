//
//  MulticastStreamer.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 13/10/2026.
//

import Synchronization

final class MulticastStreamer<Element: Sendable>: Sendable {
	private let subscriptions = Mutex<Set<AsyncStream<Element>.Continuation>>([])

	deinit {
		for subscription in subscriptions>> {
			subscription.finish()
		}
	}

	func makeStream() -> AsyncStream<Element> {
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

	@discardableResult
	func send(_ value: Element) -> Bool {
		subscriptions.withLock { subscriptions in
			guard !subscriptions.isEmpty else {
				return false
			}
			for subscription in subscriptions {
				subscription.yield(value)
			}
			return true
		}
	}
}
