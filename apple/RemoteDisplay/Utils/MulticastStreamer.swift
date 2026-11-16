//
//  MulticastStreamer.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 13/10/2026.
//

import Foundation
import Synchronization

enum Multicast {
	typealias Streamer<Element> = ThrowingStreamer<Element, Never>
	typealias ThrowingStream<Element, Failure> = AsyncSequence<Element, Failure> & Sendable
	typealias Stream<Element> = ThrowingStream<Element, Never>

	final class ThrowingStreamer<Element: Sendable, Failure: Error>: Sendable {
		private let subscriptions = Mutex<[Int: any Continuation<Element, Failure>]>([:])

		deinit {
			for subscription in self.subscriptions>>.values {
				subscription.finish()
			}
		}

		var isStreaming: Bool {
			!self.subscriptions>>.isEmpty
		}

		@discardableResult
		func send(_ value: Element) -> Bool {
			var hasYielded = false

			for subscription in self.subscriptions>>.values {
				subscription.yield(value)
				hasYielded = true
			}

			return hasYielded
		}

		func finish() {
			for subscription in subscriptions>>.values {
				subscription.finish()
			}
		}

		private func saveSubscription(continuation: any Continuation<Element, Failure>) {
			self.subscriptions.withLock { subscriptions -> Void in
				subscriptions[continuation.hashValue] = continuation
			}
			continuation.onTermination { [weak self] _ in
				self?.subscriptions.withLock { subscriptions -> Void in
					subscriptions.removeValue(forKey: continuation.hashValue)
				}
			}
		}
	}
}

extension Multicast.ThrowingStreamer where Failure == any Error {
	func makeStream() -> some Multicast.ThrowingStream<Element, Failure> {
		let (stream, cont) = AsyncThrowingStream<Element, Failure>.makeStream()
		let continuation = ThrowingContinuation(with: cont)
		self.saveSubscription(continuation: continuation)
		return stream
	}

	func `throw`(error: Failure) {
		for subscription in subscriptions>>.values {
			subscription.throw(error: error)
		}
	}
}

extension Multicast.ThrowingStreamer where Failure == Never {
	func makeStream() -> some Multicast.Stream<Element> {
		let (stream, cont) = AsyncStream<Element>.makeStream()
		let continuation = NonThrowingContinuation(with: cont)
		self.saveSubscription(continuation: continuation)
		return stream
	}
}

private extension Multicast {
	protocol Continuation<Element, Failure>: Hashable, Sendable {
		associatedtype Element
		associatedtype Failure: Error

		func yield(_ value: Element)
		func `throw`(error: Failure)
		func finish()
		func hash(into hasher: inout Hasher)
		func onTermination(_ callback: @Sendable @escaping (Int) -> Void)
	}
}

private extension Multicast.ThrowingStreamer where Failure == any Error {
	struct ThrowingContinuation: Multicast.Continuation<Element, Failure> {
		private let underlying: AsyncThrowingStream<Element, Failure>.Continuation

		init(with continuation: AsyncThrowingStream<Element, Failure>.Continuation) {
			self.underlying = continuation
		}

		func yield(_ value: Element) {
			self.underlying.yield(value)
		}

		func `throw`(error: Failure) {
			self.underlying.finish(throwing: error)
		}

		func finish() {
			self.underlying.finish()
		}

		func onTermination(_ callback: @Sendable @escaping (Int) -> Void) {
			let hash = self.underlying.hashValue
			self.underlying.onTermination = { _ in
				callback(hash)
			}
		}
	}
}

private extension Multicast.ThrowingStreamer where Failure == Never {
	struct NonThrowingContinuation: Multicast.Continuation<Element, Failure> {
		private let underlying: AsyncStream<Element>.Continuation

		init(with continuation: AsyncStream<Element>.Continuation) {
			self.underlying = continuation
		}

		func yield(_ value: Element) {
			self.underlying.yield(value)
		}

		func `throw`(error: Never) {
			// Non-throwing continuation should never throw"
		}

		func finish() {
			self.underlying.finish()
		}

		func onTermination(_ callback: @Sendable @escaping (Int) -> Void) {
			let hash = self.underlying.hashValue
			self.underlying.onTermination = { _ in
				callback(hash)
			}
		}
	}
}
