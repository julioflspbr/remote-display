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
	typealias Stream<Element> = ThrowingStream<Element, Never>

	final class ThrowingStreamer<Element: Sendable, Failure: Error>: Sendable {
		private let subscriptions = Mutex<Set<ThrowingStream<Element, Failure>.Continuation>>([])

		deinit {
			for subscription in self.subscriptions>> {
				subscription.finish()
			}
		}

		var isStreaming: Bool {
			!self.subscriptions>>.isEmpty
		}

		func makeStream() -> ThrowingStream<Element, Failure> {
			let stream = ThrowingStream<Element, Failure>()
			self.subscriptions.withLock { subscriptions -> Void in
				subscriptions.insert(stream.continuation)
			}
			stream.continuation.onTermination = { [weak self] in
				self?.subscriptions.withLock { subscriptions -> Void in
					subscriptions.remove(stream.continuation)
				}
			}
			return stream
		}

		@discardableResult
		func send(value: Element) -> Bool {
			var hasYielded = false

			for subscription in self.subscriptions>> {
				subscription.yield(value)
				hasYielded = true
			}

			return hasYielded
		}

		func `throw`(error: Failure) {
			for subscription in subscriptions>> {
				subscription.finish(throwing: error)
			}
		}

		func finish() {
			for subscription in subscriptions>> {
				subscription.finish()
			}
		}
	}
}

extension Multicast {
	final class ThrowingStream<Element: Sendable, Failure: Error>: AsyncSequence<Element, Failure>, Sendable {
		fileprivate let continuation = Continuation()

		func makeAsyncIterator() -> Iterator {
			Iterator(continuation: self.continuation)
		}
	}
}

extension Multicast.ThrowingStream {
	final class Iterator: AsyncIteratorProtocol<Element, Failure>, Sendable {
		private let continuation: Continuation
		private let queue = DispatchQueue(label: "dk.flores.remotedisplay.multicast.stream")

		fileprivate init(continuation: Continuation) {
			self.continuation = continuation
		}

		func next() async throws -> Element? {
			try await withTaskCancellationHandler {
				try await withCheckedThrowingContinuation { continuation in
					self.queue.async {
						switch self.continuation.fetchNext() {
							case let .success(element):
								continuation.resume(returning: element)
							case let .failure(error):
								if Failure.self == Never.self {
									continuation.resume(returning: nil)
								} else {
									continuation.resume(throwing: error)
								}
						}
					}
				}
			} onCancel: {
				self.continuation.finish(throwing: CancellationError())
			}
		}
	}
}

private extension Multicast.ThrowingStream {
	final class Continuation: Hashable, Identifiable, @unchecked Sendable {
		let id = UUID()

		var onTermination: (() -> Void)?

		private var cache = [Element]()
		private var error: (any Error)?
		private var isFinished = false
		private var semaphore = DispatchSemaphore(value: 0)

		func fetchNext() -> Result<Element?, any Error> {
			if let element = self.cache.first {
				self.cache.removeFirst()
				return .success(element)
			} else if let error {
				return .failure(error)
			} else if !self.isFinished {
				self.semaphore.wait()
				return self.fetchNext()
			} else {
				return .success(nil)
			}
		}

		func yield(_ value: Element) {
			self.cache.append(value)
			self.semaphore.signal()
		}

		func finish(throwing error: (any Error)? = nil) {
			self.error = error
			self.isFinished = true
			self.semaphore.signal()
			self.onTermination?()
		}

		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}

		static func == (lhs: Continuation, rhs: Continuation) -> Bool {
			lhs.id == rhs.id
		}
	}
}
